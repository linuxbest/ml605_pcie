library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity rx_csum_top is 
	port (
		reset			:	in	std_logic;
		clk			:	in	std_logic;
		enable			:	in	std_logic;
		rx_data			:	in	std_logic_vector(63 downto 0);
       		rx_valid		:	in	std_logic;
		rx_sop			:	in	std_logic;
		rx_eop			:	in	std_logic;
		rx_empty		:	in	std_logic_vector(2 downto 0);
		rx_keep			:	in	std_logic_vector(7 downto 0);
		rx_cnt			:	in	std_logic_vector(10 downto 0);
		cs_raw			:	out	std_logic_vector(15 downto 0);
		cs_valid		:	out	std_logic
	);
end rx_csum_top;

architecture rtl of rx_csum_top is

-- IPv4 Checksum
signal  ipv4_flag:	std_logic;
signal  ipv4_hdr_len:	std_logic_vector(15 downto 0);
signal  mac_iphdr_len:  std_logic_vector(15 downto 0);
signal	rx_csum_a0:	std_logic_vector(25 downto 0);
signal	rx_csum_a1:	std_logic_vector(25 downto 0);
signal	rx_csum_a2:	std_logic_vector(25 downto 0);
signal	rx_csum_a3:	std_logic_vector(25 downto 0);
signal	rx_csum_b0:	std_logic_vector(25 downto 0);
signal	rx_csum_b1:	std_logic_vector(25 downto 0);
signal	rx_csum_c:	std_logic_vector(25 downto 0);
signal	rx_csum_c1:	std_logic_vector(25 downto 0);
--signal  ipv4_csum:  	std_logic_vector(25 downto 0);

-- IPv4 Pseudo Header
signal  ipv4_src_addr:	std_logic_vector(31 downto 0);
signal  ipv4_dst_addr:  std_logic_vector(31 downto 0);
signal  ipv4_pro_len:   std_logic_vector(31 downto 0);
signal  ipv4_sa_csum:	std_logic_vector(25 downto 0);
signal  ipv4_da_csum:	std_logic_vector(25 downto 0);
signal  ipv4_addr_csum: std_logic_vector(25 downto 0);
signal  ipv4_pl_csum:   std_logic_vector(25 downto 0);
signal  ipv4_psd_csum:  std_logic_vector(25 downto 0);
signal  ipv4_psd_en:    std_logic;

-- IPv6 Checksum
signal  ipv6_flag:	std_logic;
signal  ipv6_csum_a0:	std_logic_vector(25 downto 0);
signal  ipv6_csum_a1:	std_logic_vector(25 downto 0);
signal  ipv6_csum_a2:	std_logic_vector(25 downto 0);
signal  ipv6_csum_a3:	std_logic_vector(25 downto 0);
signal  ipv6_csum_b0:	std_logic_vector(25 downto 0);
signal  ipv6_csum_b1:	std_logic_vector(25 downto 0);
signal  ipv6_csum:  	std_logic_vector(25 downto 0);

signal  rx_d_mask:	std_logic_vector(63 downto 0);
signal  rx_d_eop:	std_logic_vector(63 downto 0);

signal  rx_eop_d1:	std_logic;
signal  rx_eop_d2:	std_logic;
signal  rx_eop_d3:	std_logic;
signal  rx_eop_d4:	std_logic;
signal  rx_eop_d5:	std_logic;
signal  rx_eop_d6:	std_logic;
signal  rx_eop_d7:	std_logic;

signal	rx_csum_d0:	std_logic_vector(25 downto 0);
signal	rx_csum_d:	std_logic_vector(16 downto 0);
signal	rx_csum_e:	std_logic_vector(15 downto 0);
signal  ipv4_flag_d:	std_logic_vector(2 downto 0);
signal  ipv6_flag_d:	std_logic_vector(2 downto 0);


begin

-- IPv4 Checksum Calculation
--**************************************************************************************************--
process (reset, clk)
begin
	if (reset = '1') then
		ipv4_flag     <= '0';
	elsif (clk'event and clk='1') then
		if (rx_valid = '1') then
			-- Type = 0x0800: IPv4
			if ((rx_cnt(10 downto 3) = x"01") and (rx_data(31 downto 16) = x"0800")) then
				ipv4_flag <= '1';
			elsif (rx_sop = '1') then
				ipv4_flag <= '0';
			end if;
		end if;
	end if;
end process;

------------------------------------------------------------------------------------------------
-- IPv4 Pesudo Header for checksum calculation(96bit total)
-- Bit31          Bit24 Bit23              Bit16 Bit15			     Bit0
-- 				Source Address(from IP Header)				32bit
-- 				Destination Address(from IP Header)			32bit
--      Reserved	Protocol(from IP Header) TCP/UDP Segment Length(computed)	32bit
------------------------------------------------------------------------------------------------
process (reset, clk)
begin
	if (reset = '1') then
		ipv4_src_addr 			<= (others => '0');
		ipv4_dst_addr 			<= (others => '0');
		ipv4_pro_len(31 downto 16)  	<= (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_valid = '1' and ipv4_flag = '1') then
			case	rx_cnt(10 downto 3)   is
				when	x"02"	=>
					-- ZERO & Protocol
					-- Protocol: 0x06 --- TCP, 0x11 --- UDP, 0x01 --- ICMP, 0x02 --- IGMP
					ipv4_pro_len(31 downto 16) 	<= x"00" & rx_data(7 downto 0);
				when	x"03"	=>
					-- IP source address, IP destination address
					ipv4_src_addr 		    	<= rx_data(47 downto 16);
					ipv4_dst_addr(31 downto 16) 	<= rx_data(15 downto  0);
				when	x"04"	=>
					-- IP destination address
					ipv4_dst_addr(15 downto 0) 	<= rx_data(63 downto 48);
				when	others  =>
					null;
			end case;
		end if;
	end if;
end process;

process (reset, clk)
begin
	if (reset = '1') then
		ipv4_psd_en   <=   '0';
	elsif (clk'event and clk='1') then
		if (rx_valid = '1' and rx_eop = '1') then
			-- Protocol: 0x06 --- TCP, 0x11 --- UDP, 0x01 --- ICMP, 0x02 --- IGMP
			case	ipv4_pro_len(23 downto 16)   is
				when	x"06" | x"11"	=>
					ipv4_psd_en   <=   '1';
				when	others  =>
					ipv4_psd_en   <=   '0';
			end case;
		end if;
	end if;
end process;

process (reset, clk)
begin
	if (reset = '1') then
		ipv4_hdr_len  			<= (others => '0');
		mac_iphdr_len			<= (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_valid = '1') then
			-- Type = 0x0800: IPv4
			if ((rx_cnt(10 downto 3) = x"01") and (rx_data(31 downto 16) = x"0800")) then
				ipv4_hdr_len <= "00"&x"00" & rx_data(11 downto 8) & "00";
			end if;
			if (ipv4_flag = '1') then
				if (rx_cnt(10 downto 3) = x"02") then
					-- DA(6) + SA(6) + Type/Length(2) = 14
					mac_iphdr_len <= ipv4_hdr_len + x"000E";
				end if;
			end if;
		end if;
	end if;
end process;

process (reset, clk)
begin
	if (reset = '1') then
		ipv4_pro_len(15 downto 0) <= (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_eop_d1 = '1') then
			-- TCP/UDP/ICMP/IGMP Segment Length for IPv4
			-- Total Length(RX_BYTECNT) - (MAC Header Length(14) + IP Header Length)
			ipv4_pro_len(15 downto 0) <= ("00000" & rx_cnt) - mac_iphdr_len;
		end if;
	end if;
end process;

process (reset, clk)
begin
	if (reset = '1') then
		ipv4_sa_csum  	<= (others => '0');
		ipv4_da_csum  	<= (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_eop_d1 = '1') then
			ipv4_sa_csum <=	("00"&x"00" & ipv4_src_addr(31 downto 16)) + ("00"&x"00" & ipv4_src_addr(15 downto 0));
			ipv4_da_csum <=	("00"&x"00" & ipv4_dst_addr(31 downto 16)) + ("00"&x"00" & ipv4_dst_addr(15 downto 0));
		end if;
	end if;
end process;

process (reset, clk)
begin
	if (reset = '1') then
		ipv4_addr_csum  	<= (others => '0');
		ipv4_pl_csum		<= (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_eop_d2 = '1') then
			ipv4_addr_csum  <= ipv4_sa_csum + ipv4_da_csum;
			ipv4_pl_csum    <= ("00"&x"00" & ipv4_pro_len(31 downto 16)) + ("00"&x"00" & ipv4_pro_len(15 downto 0));
		end if;
	end if;
end process;

process (reset, clk)
begin
	if (reset = '1') then
		ipv4_psd_csum 	<= (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_eop_d3 = '1') then
			ipv4_psd_csum <= ipv4_addr_csum + ipv4_pl_csum;
		end if;
	end if;
end process;

process (reset, clk)
begin
	if (reset = '1') then
		rx_csum_a0 <= (others => '0');
		rx_csum_a1 <= (others => '0');
		rx_csum_a2 <= (others => '0');
		rx_csum_a3 <= (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_valid = '1') then
			if (rx_eop = '1') then
				rx_csum_a0 <= rx_csum_a0 + ("00"&x"00" & rx_d_eop(15 downto  0));
				rx_csum_a1 <= rx_csum_a1 + ("00"&x"00" & rx_d_eop(31 downto 16));
				rx_csum_a2 <= rx_csum_a2 + ("00"&x"00" & rx_d_eop(47 downto 32));
				rx_csum_a3 <= rx_csum_a3 + ("00"&x"00" & rx_d_eop(63 downto 48));
			else	       	 	
				case   	rx_cnt(10 downto 3)   is
				       	when	x"00"   =>
				       	        null;
				       	when	x"01"	=>
				       	       rx_csum_a0 <= "00"&x"00" & rx_data(15 downto 0);	-- Version, IHL & TOS
					       rx_csum_a1 <= (others => '0');
					       rx_csum_a2 <= (others => '0');
					       rx_csum_a3 <= (others => '0');		
					when	others  =>
					       rx_csum_a0 <= rx_csum_a0 + ("00"&x"00" & rx_data(15 downto  0));
					       rx_csum_a1 <= rx_csum_a1 + ("00"&x"00" & rx_data(31 downto 16));
					       rx_csum_a2 <= rx_csum_a2 + ("00"&x"00" & rx_data(47 downto 32));
					       rx_csum_a3 <= rx_csum_a3 + ("00"&x"00" & rx_data(63 downto 48));
				end case;			
			end if;
		end if;
	end if;
end process;

process (reset, clk)
begin
	if (reset = '1') then
		rx_csum_b0 <= (others => '0');
		rx_csum_b1 <= (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_eop_d1 = '1') then
			rx_csum_b0 <= rx_csum_a0 + rx_csum_a1;
			rx_csum_b1 <= rx_csum_a2 + rx_csum_a3;
		end if;
	end if;
end process;

process (reset, clk)
begin
	if (reset = '1') then
		rx_csum_c <= (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_eop_d2 = '1') then
			rx_csum_c <= rx_csum_b0 + rx_csum_b1;
		end if;
	end if;
end process;

process (reset, clk)
begin
	if (reset = '1') then
		rx_csum_c1 <= (others => '0');
	elsif (clk'event and clk='1') then
		-- Add one cycle delay for RX Checksum
		if (rx_eop_d3 = '1') then
			rx_csum_c1 <= rx_csum_c;
		end if;
	end if;
end process;
--**************************************************************************************************--


-- IPv6 Checksum Calculation
--**************************************************************************************************--
process (reset, clk)
begin
	if (reset = '1') then
		ipv6_flag     <= '0';
	elsif (clk'event and clk='1') then
		if (rx_valid = '1') then
			-- Type = 0x86dd: IPv6
			if ((rx_cnt(10 downto 3) = x"01") and (rx_data(31 downto 16) = x"86dd")) then
				ipv6_flag <= '1';
			elsif (rx_sop = '1') then
				ipv6_flag <= '0';
			end if;
		end if;
	end if;
end process;

process (reset, clk)
begin
	if (reset = '1') then
		ipv6_csum_a3 	<= (others => '0');
		ipv6_csum_a2 	<= (others => '0');
		ipv6_csum_a1  	<= (others => '0');
		ipv6_csum_a0  	<= (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_valid = '1' and ipv6_flag = '1') then
			if (rx_eop = '1') then
				ipv6_csum_a3 <= ipv6_csum_a3 + ("00"&x"00" & rx_d_eop(63 downto 48));
				ipv6_csum_a2 <= ipv6_csum_a2 + ("00"&x"00" & rx_d_eop(47 downto 32));
				ipv6_csum_a1 <= ipv6_csum_a1 + ("00"&x"00" & rx_d_eop(31 downto 16));
				ipv6_csum_a0 <= ipv6_csum_a0 + ("00"&x"00" & rx_d_eop(31 downto 16));
			else
				case	rx_cnt(10 downto 3)   is
					when	x"00" | x"01"		=>
						null;
					when	x"02"			=>
						ipv6_csum_a3 <= (others => '0');
						ipv6_csum_a2 <= "00"&x"00" & rx_data(47 downto 32);	-- TCP/UDP Segment Length
						ipv6_csum_a1 <= "00" & x"0000" & rx_data(31 downto 24); -- Zeros & Next Header
						ipv6_csum_a0 <= "00"&x"00" & rx_data(15 downto 0);	-- SA First Two Bytes
					when	others  		=>
						ipv6_csum_a3 <= ipv6_csum_a3 + ("00"&x"00" & rx_data(63 downto 48));
						ipv6_csum_a2 <= ipv6_csum_a2 + ("00"&x"00" & rx_data(47 downto 32));
						ipv6_csum_a1 <= ipv6_csum_a1 + ("00"&x"00" & rx_data(31 downto 16));
						ipv6_csum_a0 <= ipv6_csum_a0 + ("00"&x"00" & rx_data(15 downto 0));
				end case;
			end if;
		end if;
	end if;
end process;

process (reset, clk)
begin
	if (reset = '1') then
		ipv6_csum_b0 <= (others => '0');
		ipv6_csum_b1 <= (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_eop_d1 = '1') then
			ipv6_csum_b0 <= ipv6_csum_a0 + ipv6_csum_a1;
			ipv6_csum_b1 <= ipv6_csum_a2 + ipv6_csum_a3;
		end if;
	end if;
end process;

process (reset, clk)
begin
	if (reset = '1') then
		ipv6_csum <= (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_eop_d2 = '1') then
			ipv6_csum <= ipv6_csum_b0 + ipv6_csum_b1;
		end if;
	end if;
end process;
--**************************************************************************************************--

rx_d_eop	<=	rx_data and rx_d_mask;
-- Data Mask Logic for EOP Checksum Computation
rx_d_mask(7  downto  0)	<=	x"FF" when (rx_keep(0) = '1') else x"00";
rx_d_mask(15 downto  8)	<=	x"FF" when (rx_keep(1) = '1') else x"00";
rx_d_mask(23 downto 16)	<=	x"FF" when (rx_keep(2) = '1') else x"00";
rx_d_mask(31 downto 24)	<=	x"FF" when (rx_keep(3) = '1') else x"00";
rx_d_mask(39 downto 32)	<=	x"FF" when (rx_keep(4) = '1') else x"00";
rx_d_mask(47 downto 40)	<=	x"FF" when (rx_keep(5) = '1') else x"00";
rx_d_mask(55 downto 48)	<=	x"FF" when (rx_keep(6) = '1') else x"00";
rx_d_mask(63 downto 56)	<=	x"FF" when (rx_keep(7) = '1') else x"00";
-- with	rx_empty	select
--	rx_d_mask	<=	x"FFFFFFFFFFFFFFFF"	when	"000",
--				x"FFFFFFFFFFFFFF00"	when	"001",
--				x"FFFFFFFFFFFF0000"	when	"010",
--				x"FFFFFFFFFF000000"	when	"011",
--				x"FFFFFFFF00000000"	when	"100",
--				x"FFFFFF0000000000"	when	"101",
--				x"FFFF000000000000"	when	"110",
--				x"FF00000000000000"	when	others;
				
--**************************************************************************************************--
process (reset, clk)
begin
	if (reset = '1') then
		rx_csum_d0 <= (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_eop_d4 = '1') then
			if (ipv4_flag_d(2) = '1') then
				if (ipv4_psd_en = '1') then
					-- IPv4 Checksum including Pseudo Header
					rx_csum_d0 <= rx_csum_c1 + ipv4_psd_csum;
				else
					rx_csum_d0 <= rx_csum_c1;
				end if;
			-- Disable RX IPv6 HW CSUM to save logic elements, 2013/01/18
			-- elsif (ipv6_flag_d(2) = '1') then
				-- IPv6 Checksum including Pseudo Header
				-- No IP Header Checksum for IPv6 Format
				-- rx_csum_d0 <= ipv6_csum;
			else
				rx_csum_d0 <= (others => '0');
			end if;
		end if;
	end if;
end process;

process (reset, clk)
begin
	if (reset = '1') then
		rx_csum_d <= (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_eop_d5 = '1') then
			rx_csum_d <= ("0000000" & rx_csum_d0(25 downto 16)) + ('0' & rx_csum_d0(15 downto 0));
		end if;
	end if;
end process;

process (reset, clk)
begin
	if (reset = '1') then
		rx_csum_e <= (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_eop_d6 = '1') then
			rx_csum_e <= rx_csum_d(15 downto 0) + ("000000000000000" & rx_csum_d(16));
		end if;
	end if;
end process;

-- We need 8 cycles to generate checksum
process (reset, clk)
begin
	if (reset = '1') then
		cs_valid <= '0';
		cs_raw	 <= (others => '0');
	elsif (clk'event and clk='1') then
		cs_valid <= rx_eop_d7;
		if (enable = '1') then
			if (rx_eop_d7 = '1') then
				if (rx_csum_e = x"0000") then
					cs_raw  <= not rx_csum_e;
				else
					cs_raw	<= rx_csum_e;
				end if;
			end if;
		else
			cs_raw	<= (others => '0');
		end if;
	end if;
end process;

-- EOP Pulse, IPv4 & IPv6 Flag delay signals
process (reset, clk)
begin
	if (reset = '1') then
		rx_eop_d1	<=	'0';
		rx_eop_d2	<=	'0';
		rx_eop_d3	<=	'0';
		rx_eop_d4	<=	'0';
		rx_eop_d5	<=	'0';
		rx_eop_d6	<=	'0';
		rx_eop_d7	<=	'0';
		ipv4_flag_d     <=	(others => '0');
		ipv6_flag_d     <=	(others => '0');
	elsif (clk'event and clk='1') then
		rx_eop_d1	<=	rx_valid and rx_eop;
		rx_eop_d2	<=	rx_eop_d1;
		rx_eop_d3	<=	rx_eop_d2;
		rx_eop_d4	<=	rx_eop_d3;
		rx_eop_d5	<=	rx_eop_d4;
		rx_eop_d6	<=	rx_eop_d5;
		rx_eop_d7	<=	rx_eop_d6;
		ipv4_flag_d	<=	ipv4_flag_d(1 downto 0) & ipv4_flag;
		ipv6_flag_d	<=	ipv6_flag_d(1 downto 0) & ipv6_flag;
	end if;
end process;
		
end rtl;


