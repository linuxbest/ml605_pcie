-------------------------------------------------------------------------------
-- tx_csum_full_calc_if - entity/architecture pair
-------------------------------------------------------------------------------
--
-- (c) Copyright 2010 - 2010 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------
-- Filename:        tx_csum_full_calc_if.vhd
-- Version:         v1.00a
-- Description:     top level of embedded ip Ethernet MAC interface
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   This section shows the hierarchical structure of axi_ethernet.
--
--              axi_ethernet.vhd
--                axi_ethernt_soft_temac_wrap.vhd
--                axi_lite_ipif.vhd
--                embedded_top.vhd
--                  tx_if.vhd
--                    tx_axistream_if.vhd
--                      tx_basic_if.vhd
--                      tx_csum_if.vhd
--                        tx_csum_full_if.vhd
--                          tx_csum_full_fsm.vhd
--          ->              tx_csum_full_calc_if.vhd
--                        tx_partial_csum_if.vhd
--                          tx_csum_partial_calc_if.vhd
--                      tx_vlan_if.vhd
--                    tx_mem_if
--                    tx_emac_if.vhd
--
-------------------------------------------------------------------------------
-- Author:          MW
--
--  MW     09/16/10
-- ^^^^^^
--  - Initial release of v1.00.a
-- ~~~~~~
-------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_com"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;



-------------------------------------------------------------------------------
--                  Entity Section
-------------------------------------------------------------------------------


entity tx_csum_full_calc_if is
  generic (
    -- 0 = calculate the TCP/UDP CSUM
    -- 1 = calculate the IPv4 Header CSUM
    C_IPV4_HEADER_CSUM  : integer range 0 to 1 := 0
  );
  port (
    clk               : in  std_logic;                      --  clk
    reset             : in  std_logic;                      --  reset
    clr_csums         : in  std_logic;                      --  clear the csum
    txd_tlast         : in  std_logic;                      --  axi_str_txd_tlast_dly0,
    csum_calc_en      : in  std_logic;                      --  axi_str_txd_tvalid_dly0 and axi_str_txd_tready_int_dly;

    tcp_ptcl          : in  std_logic;                      --  tcp protocol flag
    udp_ptcl          : in  std_logic;                      --  udp protocol flag
    do_ipv4hdr        : in  std_logic;                      --  only do the ipv4 header csum
    not_tcp_udp       : in  std_logic;                      --  only do the ipv4 header csum after received tlast in ptcol header
    do_full_csum      : in  std_logic;                      --  do IPv4 Ethernet II or SNAP CSUM

    do_csum           : in  std_logic;                      --  Full CSUM FLAG is set
    csum_en_b32       : in  std_logic_vector(1 downto 0);   --  enables for either IPv4 header or TCP/UDP CSUM calc bytes 3,2
    csum_en_b10       : in  std_logic_vector(1 downto 0);   --  enables for either IPv4 header or TCP/UDP CSUM calc bytes 1,0
    zeroes_en         : in  std_logic_vector(1 downto 0);   --  zeroes for either IPv4 header or TCP/UDP CSUM calc

    data_last         : in  std_logic;                      --  last data to be included in the csum calculation
    inc_txd_addr_one  : in  std_logic;                       --  increments the Tx Data Memory Address at end of a packet
    inc_txd_addr_one_early : in  std_logic;                 --  Pulses onle clock cycle early when do_csum is enabled with
                                                            --  txd_tlast and csum_calc_en

    csum_din          : in  std_logic_vector(31 downto 0);  --  Data for CSUM calculation
    csum_dout         : out std_logic_vector(15 downto 0);  --  Computed CSUM Result
    csum_we           : out std_logic_vector( 3 downto 0);  --  Tx Data Memory Write Enables to perform 16-bit write
    csum_cmplt        : out std_logic                       --  CSUM Calculation has completed
  );

end tx_csum_full_calc_if;

architecture rtl of tx_csum_full_calc_if is

  signal csum_3_2      : std_logic_vector(16 downto 0);
  signal csum_1_0      : std_logic_vector(16 downto 0);
  signal data_last_dly : std_logic_vector( 3 downto 0);
  signal hold          : std_logic;
  signal force_dly     : std_logic;

  begin
    -----------------------------------------------------------------------
    --  It takes additional clocks after data_last for the csum
    --  calculation to complete
    -----------------------------------------------------------------------
    CSUM_ENABLE_DELAYS : process(clk)
    begin

      if rising_edge(clk) then
        if reset = '1' or clr_csums = '1' then
          data_last_dly <= (others => '0');
        else
          data_last_dly(0)          <= data_last;
          data_last_dly(3 downto 1) <= data_last_dly(2 downto 0);
        end if;
      end if;
    end process;

    -----------------------------------------------------------------------
    --  Calculate the 16 bit CSUM for AXI_STR_TXD_TDATA(31 downto 16)
    --    (bytes 3 and 2)
    --    This 16 bits is for the TCP csum
    -----------------------------------------------------------------------
    BYTE_3_2_CSUM : process(clk)
    begin

      if rising_edge(clk) then
        if reset = '1' or clr_csums = '1' then
          csum_3_2 <= (others => '0');
        else
          if data_last_dly(0) = '1' then
          --  add the carry at the end of the csum calculation
             csum_3_2 <= '0' & csum_3_2(15 downto 0) + csum_3_2(16);
          elsif csum_en_b32 = "01" then
          --  continually calculate the csum for each 16 bits written to memory
            csum_3_2 <= '0' & csum_3_2(15 downto 0) +           -- always zero out the carry and add the curren CSUM value to the next data
                        ("00000000" & csum_din(23 downto 16)) + -- add the data to the csum
                        csum_3_2(16);                           -- add the carry when it occurs


          elsif csum_en_b32 = "11" and zeroes_en(1) = '0' then
          --  when zeroes_en(1) = 1 then do not do CSUM; this is equivalent to muxing in zeroes when doing the TCP data csum calculation
          --  continually calculate the csum for each 16 bits written to memory
            csum_3_2 <= '0' & csum_3_2(15 downto 0) + -- always zero out the carry and add the curren CSUM value to the next data
                        csum_din(31 downto 16) +      -- add the data to the csum
                        csum_3_2(16);                 -- add the carry when it occurs
          else --also handles the case when data_last = 1 and csum_en_b32 = "00" (axi_str_txd_strb = "0011" or "0001")
            csum_3_2 <= csum_3_2;
          end if;
        end if;
      end if;
    end process;

    -----------------------------------------------------------------------
    --  Calculate the 16 bit CSUM for AXI_STR_TXD_TDATA(15 downto 0)
    --    (bytes 1 and 0)
    --    This 16 bits is for either the IPv4 header csum or the UDP csum
    -----------------------------------------------------------------------
    BYTE_1_0_CSUM : process(clk)
    begin

      if rising_edge(clk) then
        if reset = '1' or clr_csums = '1' then
          csum_1_0 <= (others => '0');
        else
          if data_last_dly(1) = '1' then
          --  Both csum_3_2 and csum_1_0 are calculated, but they need to be added
          --    to each other and then checked for overflow (inc_txd_addr_one_dly2)
             csum_1_0 <= '0' & csum_3_2(15 downto 0) + csum_1_0(15 downto 0);
          elsif data_last_dly(0) = '1' or data_last_dly(2) = '1' then
          --  add the carry at the end of the data written to memory or
          --  add the carry at the end of the csum calculation
          --    (after csum 3_2 has been added to csum(1_0))
             csum_1_0 <= '0' & csum_1_0(15 downto 0) + csum_1_0(16);
          elsif csum_en_b10 = "01" then
            --  continually calculate the csum for each 16 bits written to memory
              csum_1_0 <= '0' & csum_1_0(15 downto 0) +         -- always zero out the carry and add the curren CSUM value to the next data
                          ("00000000" & csum_din(7 downto  0)) +-- add the data to the csum
                          csum_1_0(16);                         -- add the carry when it occurs

          elsif csum_en_b10 = "11" and zeroes_en(0) = '0' then
          --  when zeroes_en(0) = 1 then do not do CSUM; this is equivalent to muxing in zeroes when doing the ipv4 header csum calculation
          --  or when doing the UDP data csum calculation

          -- also handles when data_last = 1 (csum_en_b10 must always be 11 or 01 when null strobes are not supported)
          -- (axi_str_txd_strb = "1111" or "0111" or "0011" or "0001")
            --  when zeroes_en(0) = 1 then do not do CSUM; this is equivalent to muxing in zeroes when doing the data csum calculation
            --  continually calculate the csum for each 16 bits written to memory
            csum_1_0 <= '0' & csum_1_0(15 downto 0) + -- always zero out the carry and add the curren CSUM value to the next data
                        csum_din(15 downto  0) +      -- add the data to the csum
                        csum_1_0(16);                 -- add the carry when it occurs
          else
            csum_1_0 <= csum_1_0;
          end if;
        end if;
      end if;
    end process;



      HOLD_REGISTER : process(clk)
      begin

        if rising_edge(clk) then
          if reset = '1' or clr_csums = '1' then
            hold     <= '0';
          else
            if (inc_txd_addr_one = '1' and (do_ipv4hdr = '1' or do_full_csum = '1') and not_tcp_udp = '0') then
            --  header CSUM or TCP/UDP CSUM is being done
              hold <= '1';
            elsif (inc_txd_addr_one = '1' and (do_ipv4hdr = '0' and do_full_csum = '0') and not_tcp_udp = '0' and do_csum = '1') then
            --  no header and no TCP/UDP CSUMs (>= 64bytes)
              hold <= '1';
            elsif (not_tcp_udp = '1' and data_last_dly(2) = '1' and inc_txd_addr_one_early = '0') or force_dly = '1' then
            --  no header and no TCP/UDP CSUMs (<64 bytes)
            --  inc_txd_addr_one cannot occure with hdr_csum_wr so use force_dly  to delay  hdr_csum_wr
              hold <= '1';
            else
              hold <= hold;
            end if;
          end if;
        end if;
      end process;


      -------------------------------------------------------------------------
      --  For packets <64 bytes when hdr_csum_wr cannot occur with inc_txd_addr_one
      -------------------------------------------------------------------------
      FORCE_DELAY : process(clk)
      begin

        if rising_edge(clk) then
          if not_tcp_udp = '1' and data_last_dly(2) = '1' and inc_txd_addr_one_early = '1' then
            force_dly <= '1';
          else
            force_dly <= '0';
          end if;
        end if;
      end process;



    -------------------------------------------------------------------------
    --  Generate the logic for the TCP/UDP CSUM
    -------------------------------------------------------------------------
    GEN_IPV4_DATA_CSUM : if C_IPV4_HEADER_CSUM = 0 generate
    begin

      --  The requirement for checksum is to invert the final value, if it is UDP and "0x0000" then
      --  set it back to "0xFFFF".  To save a step of inversion, just check it to see if it is
      --  0xFFFF before the inversion, and if it is, then do not invert it.

        csum_dout  <= x"FFFF" when (udp_ptcl = '1' and data_last_dly(3) = '1' and csum_1_0 = x"FFFF") else
                      not csum_1_0(15 downto 0);

        csum_we    <= "1100" when data_last_dly(3) = '1' and tcp_ptcl = '1' else
                      "0011" when data_last_dly(3) = '1' and udp_ptcl = '0' else
                      "0000";

        --csum_cmplt <= data_last_dly(3);





        CSUM_COMPLETE : process(clk)
        begin

          if rising_edge(clk) then
            if reset = '1' then
              csum_cmplt <= '0';
            else
              if do_csum = '1' and do_full_csum = '1' then  --did
                if data_last_dly(2) = '1' and do_full_csum = '1' then
                --  this will happen simultaneously with data_last_dly(3) when performing the csum
                  csum_cmplt <= '1';
                else
                  csum_cmplt <= '0';
                end if;
              elsif not_tcp_udp = '1' then
                if data_last_dly(0) = '1' then
                --  Not doing TCP or UDP CSUM and data ends during TCP/UDP bytes (data ends first byte after IPv4 header)
                --  delay the txd Write FSM in tx_csum_full_if until the ipv4 header is complete
                  csum_cmplt <= '1';
                else
                  csum_cmplt <= '0';
                end if;
              elsif not_tcp_udp = '0' then
                if (inc_txd_addr_one = '1' and do_ipv4hdr = '1' and do_full_csum = '0') or -- only do IPv4 header csum
                    data_last_dly(0) = '1' then -- not doing any csum, but need to set enable to exit FSMs
                  csum_cmplt <= '1';
                else
                  csum_cmplt <= '0';
                end if;
              else
                csum_cmplt <= '0';
              end if;

            end if;
          end if;
        end process;

    end generate GEN_IPV4_DATA_CSUM;

    -------------------------------------------------------------------------
    --  Generate the logic for the IPv4 Header CSUM
    -------------------------------------------------------------------------
    GEN_IPV4_HEADER_CSUM : if C_IPV4_HEADER_CSUM = 1 generate
    begin


--      HOLD_REGISTER : process(clk)
--      begin
--
--        if rising_edge(clk) then
--          if reset = '1' or clr_csums = '1' then
--            hold <= '0';
--          else
--            if inc_txd_addr_one = '1' and do_ipv4hdr = '1' then
--              hold <= '1';
--            else
--              hold <= hold;
--            end if;
--          end if;
--        end if;
--      end process;
--
      --  The requirement for checksum is to invert the final value
        csum_dout  <= not csum_1_0(15 downto 0);
        csum_we    <= "0011" when hold = '1' else
                      "0000";
        csum_cmplt <= hold;

    end generate GEN_IPV4_HEADER_CSUM;

end rtl;
