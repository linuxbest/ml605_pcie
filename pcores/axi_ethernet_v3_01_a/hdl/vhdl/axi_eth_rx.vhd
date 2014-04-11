library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.all;

entity axi_eth_rx is
  port (
    clk			     : in  std_logic;
    reset                    : in  std_logic;

    AXI_STR_RXD_TVALID       : out std_logic;                           --  AXI-Stream Receive Data Valid
    AXI_STR_RXD_TREADY       : in  std_logic;                           --  AXI-Stream Receive Data Ready
    AXI_STR_RXD_TLAST        : out std_logic;                           --  AXI-Stream Receive Data Last
    AXI_STR_RXD_TKEEP        : out std_logic_vector(7 downto 0);        --  AXI-Stream Receive Data Keep
    AXI_STR_RXD_TDATA        : out std_logic_vector(63 downto 0);       --  AXI-Stream Receive Data Data

    AXI_STR_RXS_TVALID       : out std_logic;                           --  AXI-Stream Receive Status Valid
    AXI_STR_RXS_TREADY       : in  std_logic;                           --  AXI-Stream Receive Status Ready
    AXI_STR_RXS_TLAST        : out std_logic;                           --  AXI-Stream Receive Status Last
    AXI_STR_RXS_TKEEP        : out std_logic_vector(3 downto 0);        --  AXI-Stream Receive Status Keep
    AXI_STR_RXS_TDATA        : out std_logic_vector(31 downto 0);       --  AXI-Stream Receive Status Data

    rx_axis_mac_tdata        : in  std_logic_vector(63 downto 0);
    rx_axis_mac_tvalid       : in  std_logic;
    rx_axis_mac_tkeep        : in  std_logic_vector(7 downto 0);
    rx_axis_mac_tlast        : in  std_logic;
    rx_axis_mac_tuser        : in  std_logic;
    rx_axis_mac_tready	     : out std_logic
  );
end axi_eth_rx;

architecture rtl of axi_eth_rx is

component rxd_fifo
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (72 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (72 DOWNTO 0)
	);
end component;

component rxs_fifo
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (36 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (36 DOWNTO 0)
	);
end component;

component rx_csum_top
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
end component;

signal 	rxd_fifo_data		:	std_logic_vector(72 downto 0);	
signal 	rxd_fifo_rdreq		:	std_logic;
signal 	rxd_fifo_wrreq		:	std_logic;
signal 	rxd_fifo_empty		:	std_logic;
signal 	rxd_fifo_full		:	std_logic;
signal 	rxd_fifo_q		:	std_logic_vector(72 downto 0);
signal 	rxs_fifo_data		:	std_logic_vector(36 downto 0);	
signal 	rxs_fifo_rdreq		:	std_logic;
signal 	rxs_fifo_wrreq		:	std_logic;
signal 	rxs_fifo_empty		:	std_logic;
signal 	rxs_fifo_full		:	std_logic;
signal 	rxs_fifo_q		:	std_logic_vector(36 downto 0);

signal  rxs_data		:	std_logic_vector(31 downto 0);
signal  rxs_keep		:	std_logic_vector(3 downto 0);
signal  rxs_last		:	std_logic;
signal  rxs_valid		:	std_logic;

signal  rx_axis_mac_tready_int	:	std_logic;

signal  ifg_cnt			:	std_logic_vector(3 downto 0);
signal  ifg_flag		:	std_logic;

signal	rx_data			:	std_logic_vector(63 downto 0);
signal	rx_valid		:	std_logic;
signal	rx_sop			:	std_logic;
signal	rx_eop			:	std_logic;
signal	rx_sop_int		:	std_logic;
signal	rx_empty		:	std_logic_vector(2 downto 0);
signal  rx_keep			:	std_logic_vector(7 downto 0);
signal	rx_cnt			:	std_logic_vector(15 downto 0);
signal	cs_raw			:	std_logic_vector(15 downto 0);
signal	cs_valid		:	std_logic;

signal  mcast_addr_u		:	std_logic_vector(31 downto 0);
signal  mcast_addr_l		:	std_logic_vector(31 downto 0);
signal  T_L_TPID		:	std_logic_vector(15 downto 0);
signal  vlan_tag		:	std_logic_vector(15 downto 0);

signal  RXS_RXDn_flag		:	std_logic;
signal  AXI_STR_RXS_TLAST_int	:	std_logic;
signal  AXI_STR_RXD_TLAST_int	:	std_logic;

begin

-- Ethernet Packet Counter
process (reset, clk)
begin
	if (reset = '1') then
		rx_cnt <= (others => '0');
	elsif (clk'event and clk='1') then
		-- Clear packet counter
		if (ifg_flag = '1' and ifg_cnt=x"A") then
			rx_cnt <= x"0000";
		elsif (rx_valid = '1') then
			if (rx_sop = '1') then
				rx_cnt <= x"0008";
			elsif (rx_eop = '1') then
				rx_cnt <= rx_cnt + x"0008" - (x"000"&'0'&rx_empty);
			else
				rx_cnt <= rx_cnt + x"0008"; 
			end if;
		end if;
	end if;
end process;

process (clk, reset)
begin
	if (reset = '1') then
		rx_sop_int   <=   '1';
	elsif (clk'event and clk='1') then
		if (rx_valid = '1') then
			if (rx_eop = '1') then
				rx_sop_int   <=   '1';
			else
				rx_sop_int   <=   '0';
			end if;
		end if;
	end if;
end process;

rx_keep(0)	<=	rx_axis_mac_tkeep(7);
rx_keep(1)	<=	rx_axis_mac_tkeep(6);
rx_keep(2)	<=	rx_axis_mac_tkeep(5);
rx_keep(3)	<=	rx_axis_mac_tkeep(4);
rx_keep(4)	<=	rx_axis_mac_tkeep(3);
rx_keep(5)	<=	rx_axis_mac_tkeep(2);
rx_keep(6)	<=	rx_axis_mac_tkeep(1);
rx_keep(7)	<=	rx_axis_mac_tkeep(0);

process (rx_axis_mac_tkeep)
begin
	case   rx_axis_mac_tkeep   is
	    when   "00000001"   =>
		rx_empty   <= "111";
	    when   "00000011"   =>
		rx_empty   <= "110";
	    when   "00000111"   =>
		rx_empty   <= "101";
	    when   "00001111"   =>
		rx_empty   <= "100";
	    when   "00011111"   =>
		rx_empty   <= "011";
	    when   "00111111"   =>
		rx_empty   <= "010";
	    when   "01111111"   =>
		rx_empty   <= "001";
	    when   others       =>
		rx_empty   <= "000";
	end case;
end process;

rx_data( 7 downto  0) 	<=   rx_axis_mac_tdata(63 downto 56);
rx_data(15 downto  8) 	<=   rx_axis_mac_tdata(55 downto 48);
rx_data(23 downto 16) 	<=   rx_axis_mac_tdata(47 downto 40);
rx_data(31 downto 24) 	<=   rx_axis_mac_tdata(39 downto 32);
rx_data(39 downto 32) 	<=   rx_axis_mac_tdata(31 downto 24);
rx_data(47 downto 40) 	<=   rx_axis_mac_tdata(23 downto 16);
rx_data(55 downto 48) 	<=   rx_axis_mac_tdata(15 downto  8);
rx_data(63 downto 56) 	<=   rx_axis_mac_tdata( 7 downto  0);
rx_valid		<=   rx_axis_mac_tvalid;
rx_sop			<=   rx_sop_int and rx_axis_mac_tvalid;
rx_eop			<=   rx_axis_mac_tvalid and rx_axis_mac_tlast;  

Inst_rx_csum_top: rx_csum_top
	port map (
		reset		=>	reset,
		clk		=>	clk,
		enable		=>	'1',
		rx_data		=>	rx_data,
       		rx_valid	=>	rx_valid,
		rx_sop		=>	rx_sop,
		rx_eop		=>	rx_eop,
		rx_empty	=>	rx_empty,
		rx_keep		=>	rx_keep,
		rx_cnt		=>	rx_cnt(10 downto 0),
		cs_raw		=>	cs_raw,
		cs_valid	=>	cs_valid
	);

-- These are the upper 16 bits of the multicast destination address of
-- this frame. This value is only valid if the AXI4-Stream Status word 2, bit 0 is a 1. The address is
-- ordered so the first byte received is the lowest positioned byte in the register; for example, MAC
-- address of AA-BB-CC-DD-EE-FF would be stored in UnicastAddr(47:0) as 0xFFEEDDCCBBAA.
-- This word would be 0xFFEE.
process (clk, reset)
begin
	if (reset = '1') then
		mcast_addr_u   <=   (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_valid='1' and rx_cnt(10 downto 3)=x"00") then
			mcast_addr_u   <=   x"0000" & rx_axis_mac_tdata(47 downto 32);
		end if;
	end if;
end process;

-- These are the lower 32 bits of the multicast destination address
-- of this frame. This value is only valid AXI4-Stream Status word 2, bit 0 is a 1. The address
-- is ordered so the first byte received is the lowest positioned byte in the register; for example,
-- MAC address of AA-BB-CC-DD-EE-FF would be stored in UnicastAddr(47:0) as
-- 0xFFEEDDCCBBAA. This word would be 0xDDCCBBAA.
process (clk, reset)
begin
	if (reset = '1') then
		mcast_addr_l   <=   (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_valid='1' and rx_cnt(10 downto 3)=x"00") then
			mcast_addr_l   <=   rx_axis_mac_tdata(31 downto 0);
		end if;
	end if;
end process;

-- This is the value of the 13th and 12th bytes of the frame (index
-- starts at zero). If the frame is not VLAN type, this is the type/length field. If the frame is VLAN
-- type, this is the value of the VLAN TPID field prior to any stripping, translation or tagging.
process (clk, reset)
begin
	if (reset = '1') then
		T_L_TPID   <=   x"0000";
	elsif (clk'event and clk='1') then
		if (rx_valid='1' and rx_cnt(10 downto 3)=x"01") then
			T_L_TPID   <=   rx_axis_mac_tdata(47 downto 32);
		end if;
	end if;
end process;

-- This is the value of the 15th and 14th bytes of the frame (index
-- starts at zero). If the frame is VLAN type, this is the value of the VLAN priority, CFI, and VID
-- fields prior to any stripping, translation, or tagging. If the frame is not VLAN type, this is the
-- first 2 bytes of the data field.
process (clk, reset)
begin
	if (reset = '1') then
		vlan_tag   <=   x"0000";
	elsif (clk'event and clk='1') then
		if (rx_valid='1' and rx_cnt(10 downto 3)=x"01") then
			vlan_tag   <=   rx_axis_mac_tdata(63 downto 48);
		end if;
	end if;
end process;

process (clk, reset)
begin
	if (reset = '1') then
		rxs_data    <=   (others => '0');
		rxs_keep    <=   (others => '0');
		rxs_last    <=   '0';
		rxs_valid   <=   '0';
	elsif (clk'event and clk='1') then
		if (ifg_flag = '1') then
			case   ifg_cnt  is
			    when   x"5"   =>
				-- RXS TAG, Receive AXI4-Stream Status Word 0
				rxs_data    <=   x"50000000";
				rxs_keep    <=   x"F";
				rxs_last    <=   '0';
				rxs_valid   <=   '1';	
			    when   x"6"   =>
				-- Receive AXI4-Stream Status Word 1, APP0
				-- Bit[15:0], Multicast Address[47:32]
				-- upper 16 bits of the multicast destination address
				rxs_data    <=   mcast_addr_u;
				rxs_keep    <=   x"F";
				rxs_last    <=   '0';
				rxs_valid   <=   '1';	
			    when   x"7"   =>
				-- Receive AXI4-Stream Status Word 2, APP1
				-- Multicast Address[31:0]
				-- lower 32 bits of the multicast destination address
				rxs_data    <=   mcast_addr_l;
				rxs_keep    <=   x"F";
				rxs_last    <=   '0';
				rxs_valid   <=   '1';	
			    when   x"8"   =>
				-- Receive AXI4-Stream Status Word 3, APP2
				-- Bit[7]: Bad Frame, Bit[6]: Good Frame
				rxs_data    <=   (6 => '1', others=>'0');
				rxs_keep    <=   x"F";
				rxs_last    <=   '0';
				rxs_valid   <=   '1';	
			    when   x"9"   =>
				-- Receive AXI4-Stream Status Word 4, APP3
				-- Bit[31:16], Type Length VLAN TPID
				-- Bit[15:0], RX_CSRAW
				rxs_data    <=   T_L_TPID & cs_raw;
				rxs_keep    <=   x"F";
				rxs_last    <=   '0';
				rxs_valid   <=   '1';	
			    when   x"A"   =>
				-- Receive AXI4-Stream Status Word 5, APP4
				-- Bit[31:16], VLAN Priority CFI and VID
				-- Bit[15:0], RX_BYTECNT
				rxs_data    <=   vlan_tag & rx_cnt;
				rxs_keep    <=   x"F";
				rxs_last    <=   '1';
				rxs_valid   <=   '1';	
			    when   others =>
				rxs_data    <=   (others => '0');
				rxs_keep    <=   (others => '0');
				rxs_last    <=   '0';
				rxs_valid   <=   '0';		
			end case;
		else
			rxs_data    <=   (others => '0');
			rxs_keep    <=   (others => '0');
			rxs_last    <=   '0';
			rxs_valid   <=   '0';
		end if;
	end if;
end process;

process (clk, reset)
begin
	if (reset = '1') then
		ifg_flag   <=   '0';
		ifg_cnt	   <=   (others => '0');
	elsif (clk'event and clk='1') then
		if (rx_axis_mac_tvalid='1' and rx_axis_mac_tlast='1') then
			ifg_cnt   <=   (others => '0');
		elsif (ifg_flag = '1') then
			ifg_cnt   <=   ifg_cnt + '1';
		end if;
		if (rx_axis_mac_tvalid='1' and rx_axis_mac_tlast='1') then
			ifg_flag   <=   '1';
		elsif (ifg_cnt >= x"B") then
			ifg_flag   <=   '0';
		end if;
	end if;
end process;

process (clk, reset)
begin
	if (reset = '1') then
		RXS_RXDn_flag   <=   '1';
	elsif (clk'event and clk='1') then
		if (AXI_STR_RXS_TLAST_int='1') then
			RXS_RXDn_flag   <=   '0';
		elsif (AXI_STR_RXD_TLAST_int='1') then
			RXS_RXDn_flag   <=   '1';
		end if;
	end if;
end process;

-- RXD FIFO Write Data Path
rx_axis_mac_tready		<=   rx_axis_mac_tready_int;
rx_axis_mac_tready_int		<=   (not rxd_fifo_full) and (not rxs_fifo_full);
rxd_fifo_data(72)		<=   rx_axis_mac_tlast;
rxd_fifo_data(71 downto 64)	<=   rx_axis_mac_tkeep;
rxd_fifo_data(63 downto 0)	<=   rx_axis_mac_tdata;
rxd_fifo_wrreq			<=   rx_axis_mac_tvalid;
-- RXD FIFO Read Data Path
AXI_STR_RXD_TLAST		<=   AXI_STR_RXD_TLAST_int;
AXI_STR_RXD_TLAST_int		<=   rxd_fifo_rdreq and rxd_fifo_q(72);
AXI_STR_RXD_TVALID		<=   (not rxd_fifo_empty) and (not RXS_RXDn_flag);
rxd_fifo_rdreq			<=   (not rxd_fifo_empty) and (not RXS_RXDn_flag) and AXI_STR_RXD_TREADY;
AXI_STR_RXD_TKEEP		<=   rxd_fifo_q(71 downto 64);
AXI_STR_RXD_TDATA		<=   rxd_fifo_q(63 downto 0);

    I_rxd_fifo : entity proc_common_v3_00_a.basic_sfifo_fg
    generic map(
      C_DWIDTH                      => 73,
        -- FIFO data Width (Read and write data ports are symetric)
      C_DEPTH                       => 1024,
        -- FIFO Depth (set to power of 2)
      C_HAS_DATA_COUNT              => 0,
        -- 0 = DataCount not used
        -- 1 = Data Count used 
      C_DATA_COUNT_WIDTH            => 10,
      -- Data Count bit width (Max value is log2(C_DEPTH))
      C_IMPLEMENTATION_TYPE         => 0, 
        --  0 = Common Clock BRAM / Distributed RAM (Synchronous FIFO)
        --  1 = Common Clock Shift Register (Synchronous FIFO)
      C_MEMORY_TYPE                 => 1,
        --   0 = Any
        --   1 = BRAM
        --   2 = Distributed Memory  
        --   3 = Shift Registers
      C_PRELOAD_REGS                => 1, 
        -- 0 = normal            
        -- 1 for FWFT
      C_PRELOAD_LATENCY             => 0,              
        -- 0 for FWFT
        -- 1 = normal            
      C_USE_FWFT_DATA_COUNT         => 0, 
        -- 0 = normal            
        -- 1 for FWFT
      C_FAMILY                      => "kintex7" 
      )
    port map(
      CLK                           =>  clk,
      DIN                           =>  rxd_fifo_data,                   
      RD_EN                         =>  rxd_fifo_rdreq,                  
      SRST                          =>  reset,            
      WR_EN                         =>  rxd_fifo_wrreq,                  
      DATA_COUNT                    =>  open,                
      DOUT                          =>  rxd_fifo_q,                  
      EMPTY                         =>  rxd_fifo_empty,                 
      FULL                          =>  rxd_fifo_full
      );    

-- RXS FIFO Write Data Path
rxs_fifo_data(36)		<=   rxs_last;
rxs_fifo_data(35 downto 32)	<=   rxs_keep;
rxs_fifo_data(31 downto 0)	<=   rxs_data;
rxs_fifo_wrreq			<=   rxs_valid;
-- RXS FIFO Read Data Path
AXI_STR_RXS_TLAST		<=   AXI_STR_RXS_TLAST_int;
AXI_STR_RXS_TLAST_int		<=   rxs_fifo_rdreq and rxs_fifo_q(36);
AXI_STR_RXS_TVALID		<=   (not rxs_fifo_empty) and RXS_RXDn_flag;
rxs_fifo_rdreq			<=   (not rxs_fifo_empty) and RXS_RXDn_flag and AXI_STR_RXS_TREADY;
AXI_STR_RXS_TKEEP		<=   rxs_fifo_q(35 downto 32);
AXI_STR_RXS_TDATA		<=   rxs_fifo_q(31 downto 0);


    I_rxs_fifo : entity proc_common_v3_00_a.basic_sfifo_fg
    generic map(
      C_DWIDTH                      => 37,
        -- FIFO data Width (Read and write data ports are symetric)
      C_DEPTH                       => 512,
        -- FIFO Depth (set to power of 2)
      C_HAS_DATA_COUNT              => 0,
        -- 0 = DataCount not used
        -- 1 = Data Count used 
      C_DATA_COUNT_WIDTH            => 9,
      -- Data Count bit width (Max value is log2(C_DEPTH))
      C_IMPLEMENTATION_TYPE         => 0, 
        --  0 = Common Clock BRAM / Distributed RAM (Synchronous FIFO)
        --  1 = Common Clock Shift Register (Synchronous FIFO)
      C_MEMORY_TYPE                 => 1,
        --   0 = Any
        --   1 = BRAM
        --   2 = Distributed Memory  
        --   3 = Shift Registers
      C_PRELOAD_REGS                => 1, 
        -- 0 = normal            
        -- 1 for FWFT
      C_PRELOAD_LATENCY             => 0,              
        -- 0 for FWFT
        -- 1 = normal            
      C_USE_FWFT_DATA_COUNT         => 0, 
        -- 0 = normal            
        -- 1 for FWFT
      C_FAMILY                      => "kintex7" 
      )
    port map(
      CLK                           =>  clk,
      DIN                           =>  rxs_fifo_data,                   
      RD_EN                         =>  rxs_fifo_rdreq,                  
      SRST                          =>  reset,            
      WR_EN                         =>  rxs_fifo_wrreq,                  
      DATA_COUNT                    =>  open,                
      DOUT                          =>  rxs_fifo_q,                  
      EMPTY                         =>  rxs_fifo_empty,                 
      FULL                          =>  rxs_fifo_full
      );    
 
end rtl;
