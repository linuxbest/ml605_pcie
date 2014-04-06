-------------------------------------------------------------------------------
-- tx_csum_partial_calc_if - entity/architecture pair
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
-- Filename:        tx_csum_partial_calc_if.vhd
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
--                        tx_csum_partial_if.vhd
--          ->              tx_csum_partial_calc_if.vhd
--                        tx_full_csum_if.vhd
--                      tx_vlan_if.vhd
--                    tx_mem_if
--                    tx_emac_if.vhd
--
-------------------------------------------------------------------------------
-- Author:          MW
--
--  MW     07/01/10
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

entity tx_csum_partial_calc_if is
  generic (
    C_FAMILY                  : string                      := "virtex6";
    C_TXCSUM                  : integer range 0 to 2        := 0;
    C_S_AXI_DATA_WIDTH        : integer range 32 to 32      := 32;
    c_TxD_addrb_width         : integer range  0 to 13      := 10
  );
  port (
    AXI_STR_TXC_ACLK           : in  std_logic;                                       --  AXI-Stream Transmit Control Clock
    reset2axi_str_txc          : in  std_logic;                                       --  Reset
    axi_str_txc_tready_int_dly : in  std_logic;                                       --  AXI-Stream Transmit Control Ready
    axi_str_txc_tvalid_dly0    : in  std_logic;                                       --  AXI-Stream Transmit Control Valid
    axi_str_txc_tlast_dly0     : in  std_logic;                                       --  AXI-Stream Transmit Control Last

    load_csum_int              : in  std_logic;                                       --  Load CSUM Initial Value
    axi_flag                   : in  std_logic_vector( 3 downto 0);                   --  AXI Flag From AXI-Stream Tx Control
    csum_cntrl                 : in  std_logic_vector( 1 downto 0);                   --  CSUM Control Bits = "01" for partial CSUM
    csum_begin                 : in  std_logic_vector(c_TxD_addrb_width -1 downto 0); --  CSUM Start Location
    csum_begin_bytes           : in  std_logic_vector( 1 downto 0);                   --  CSUM Enables for which Byte to start calc
    csum_insert                : in  std_logic_vector(c_TxD_addrb_width -1 downto 0); --  CSUM Insertion Location
    csum_insert_bytes          : in  std_logic_vector( 1 downto 0);                   --  CSUM Enables for which Byte to insert at
    csum_init                  : in  std_logic_vector(15 downto 0);                   --  CSUM INitial Value to start at

    AXI_STR_TXD_ACLK           : in  std_logic;                                       --  AXI-Stream Transmit Data Clock
    reset2axi_str_txd          : in  std_logic;                                       --  Reset
    csum_addr                  : in  std_logic_vector(c_TxD_addrb_width -1 downto 0); --  Current address to Tx Data Memory
    inc_txd_wr_addr            : in  std_logic;                                       --  Incraments the Wr address
    inc_txd_addr_one           : in  std_logic;                                       --  Incraments the Wr address at the end
    non_xilinx_ip_pulse        : in  std_logic;                                       --  Not Supported
    axi_str_txd_tdata_dly1     : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0); --  AXI-Stream Transmit Memory Data

    do_csum                    : out std_logic;                                       --  Enable to do CSUM
    csum_result                : out std_logic_vector(15 downto 0);                   --  Final CSUM result valid with csum_en
    csum_en                    : out std_logic;                                       --  Final CSUM resullt is valid
    csum_we                    : out std_logic_vector(3 downto 0);                    --  Memory Write Enables for 16-bit access
    csum_cmplt                 : out std_logic                                        --  Current CSUM calculation is complete
  );

end tx_csum_partial_calc_if;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of tx_csum_partial_calc_if is

signal do_csum_int           : std_logic;
signal csum_byte_3_2_en      : std_logic;
signal csum_byte_1_0_en      : std_logic;
signal csum_started          : std_logic;
signal csum_result_int       : std_logic_vector(15 downto 0);

signal csum_3_2              : std_logic_vector(16 downto 0);
signal csum_1_0              : std_logic_vector(16 downto 0);
signal csum_we_int           : std_logic_vector( 3 downto 0);
signal csum_en_int           : std_logic;
signal inc_txd_addr_one_dly1 : std_logic;
signal inc_txd_addr_one_dly2 : std_logic;
signal inc_txd_addr_one_dly3 : std_logic;
signal inc_txd_addr_one_dly4 : std_logic;
signal csum_clr              : std_logic;
signal csum_cmplt_int        : std_logic;

begin

GEN_LEGACY_CSUM : if C_TXCSUM = 1 generate
begin

  CSUM_ENABLE : process(AXI_STR_TXC_ACLK)
  begin

    if rising_edge(AXI_STR_TXC_ACLK) then
      if reset2axi_str_txc = '1' then
        do_csum_int <= '0';
      else
        if axi_str_txc_tready_int_dly = '1' and
           axi_str_txc_tvalid_dly0 = '1' and axi_str_txc_tlast_dly0 = '1' then
          case axi_flag is
            when "1010" =>
              case csum_cntrl is
                when "01"   => do_csum_int <= '1';
                when others => do_csum_int <= '0';
              end case;
            when others =>
              do_csum_int <= '0';
          end case;
        else
          do_csum_int <= do_csum_int;
        end if;
      end if;
    end if;
  end process;

  do_csum <= do_csum_int;


-------------------------------------------------------------------------------
--  The legacy CSUM stipulates that the starting position must be 16 bit
--  aligned
-------------------------------------------------------------------------------
SET_CSUM_ENABLES : process(AXI_STR_TXD_ACLK)
begin

  if rising_edge(AXI_STR_TXD_ACLK) then
    if reset2axi_str_txd = '1' or csum_clr = '1' then
      csum_byte_3_2_en <= '0';
      csum_byte_1_0_en <= '0';
      csum_started     <= '0';
    else
      if csum_addr = csum_begin and inc_txd_wr_addr = '1'then
        if csum_begin_bytes(1) = '1' then
          --  Set the enables for the 16 bit csums for 16 bit alignment
          --    Only enable the lower 16 bit csum for the first clock
          csum_byte_3_2_en <= '1';
          csum_byte_1_0_en <= '0';
          csum_started     <= '1';
        else
          --  Otherwise enable both of them
          csum_byte_3_2_en <= '1';
          csum_byte_1_0_en <= '1';
          csum_started     <= '1';
        end if;
      elsif csum_started = '1' and inc_txd_wr_addr = '1' then
        --  once started keep the enables asserted until the end
        --  of the packet
        csum_byte_3_2_en <= '1';
        csum_byte_1_0_en <= '1';
        csum_started     <= '1';
      else
        csum_byte_3_2_en <= csum_byte_3_2_en;
        csum_byte_1_0_en <= csum_byte_1_0_en;
        csum_started     <= csum_started    ;
      end if;
    end if;
  end if;
end process;

DELAY_END_CSUM : process(AXI_STR_TXD_ACLK)
begin

  if rising_edge(AXI_STR_TXD_ACLK) then
    inc_txd_addr_one_dly1 <= inc_txd_addr_one;
    inc_txd_addr_one_dly2 <= inc_txd_addr_one_dly1;
    inc_txd_addr_one_dly3 <= inc_txd_addr_one_dly2;
    inc_txd_addr_one_dly4 <= inc_txd_addr_one_dly3;
    csum_clr              <= inc_txd_addr_one_dly4;
  end if;
end process;




BYTE_3_2_CSUM : process(AXI_STR_TXD_ACLK)
begin

  if rising_edge(AXI_STR_TXD_ACLK) then
    if reset2axi_str_txd = '1' then
      csum_3_2 <= (others => '0');
    else
      if load_csum_int = '1' then
      --  Need to byte swap to properly offset the initial value
        csum_3_2 <= '0' & csum_init(7 downto 0) & csum_init(15 downto 8);
      elsif inc_txd_addr_one_dly1 = '1' then
      --  add the carry at the end of the csum calculation
         csum_3_2 <= '0' & csum_3_2(15 downto 0) + csum_3_2(16);
      elsif csum_byte_3_2_en = '1' and
            (inc_txd_wr_addr = '1' or inc_txd_addr_one = '1' or non_xilinx_ip_pulse = '1') then
      --  continually calculate the csum for each 16 bits written to memory
        csum_3_2 <= '0' & csum_3_2(15 downto 0) +               -- always zero out the carry
                    axi_str_txd_tdata_dly1(31 downto 16) +      -- add the data to the csum
                    csum_3_2(16);                               -- add the carry when it occurs
      else
        csum_3_2 <= csum_3_2;
      end if;
    end if;
  end if;
end process;


BYTE_1_0_CSUM : process(AXI_STR_TXD_ACLK)
begin

  if rising_edge(AXI_STR_TXD_ACLK) then
    if reset2axi_str_txd = '1' or csum_clr = '1' then
      csum_1_0 <= (others => '0');
    else
      if inc_txd_addr_one_dly2 = '1' then
      --  Both csum_3_2 and csum_1_0 are calculated, but they need to be added
      --    to each other and then checked for overflow (inc_txd_addr_one_dly2)
         csum_1_0 <= '0' & csum_3_2(15 downto 0) + csum_1_0(15 downto 0);
      elsif inc_txd_addr_one_dly1 = '1' or inc_txd_addr_one_dly3 = '1' then
      --  add the carry at the end of the data written to memory or
      --  add the carry at the end of the csum calculation
      --    (after csum 3_2 has been added to csum(1_0))
         csum_1_0 <= '0' & csum_1_0(15 downto 0) + csum_1_0(16);
      elsif csum_byte_1_0_en = '1' and
            (inc_txd_wr_addr = '1' or inc_txd_addr_one = '1' or non_xilinx_ip_pulse = '1') then
      --  continually calculate the csum for each 16 bits written to memory
        csum_1_0 <= '0' & csum_1_0(15 downto 0) +               -- always zero out the carry
                    axi_str_txd_tdata_dly1(15 downto  0) +      -- add the data to the csum
                    csum_1_0(16);                               -- add the carry when it occurs
      else
        csum_1_0 <= csum_1_0;
      end if;
    end if;
  end if;
end process;


--  There is not way of detecting TCP or UDP with legacy CSUM, so always treat it as UDP
--    ie if csum_1_0 = x"FFFF" then invert it.

--  The requirement for checksum is to invert the final value, if it is "0x0000" then
--  set it back to "0xFFFF".  To save a step of inversion, just check it to see if it is
--  0xFFFF before the inversion, and if it is, then do not invert it.

  csum_result_int <= x"FFFF" when (inc_txd_addr_one_dly4 = '1' and csum_1_0 = x"FFFF") else
                     not csum_1_0(15 downto 0);

  csum_we_int <= "1100" when inc_txd_addr_one_dly4 = '1' and csum_insert_bytes(1) = '1' else
                 "0011" when inc_txd_addr_one_dly4 = '1' and csum_insert_bytes(1) = '0' else
                 "0000";

  csum_en_int <= '1' when (do_csum_int = '1' and inc_txd_addr_one_dly4 = '1') else
                 '0';


  csum_en     <= csum_en_int;
  csum_we     <= csum_we_int;
  csum_result <= csum_result_int;


  CSUM_COMPLETE : process(AXI_STR_TXD_ACLK)
  begin

    if rising_edge(AXI_STR_TXD_ACLK) then
      if reset2axi_str_txd = '1' then
        csum_cmplt_int <= '0';
      else
        if do_csum_int = '1' then
          if inc_txd_addr_one_dly3 = '1' then
            csum_cmplt_int <= '1';
          else
            csum_cmplt_int <= '0';
          end if;
        else
          if inc_txd_addr_one = '1' then
            csum_cmplt_int <= '1';
          else
            csum_cmplt_int <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  csum_cmplt  <= csum_cmplt_int;

end generate GEN_LEGACY_CSUM;



GEN_FULL_CSUM : if C_TXCSUM = 2 generate
begin

  CSUM_ENABLE : process(AXI_STR_TXC_ACLK)
  begin

    if rising_edge(AXI_STR_TXC_ACLK) then
      if reset2axi_str_txc = '1' then
        do_csum_int <= '0';
      else
        if axi_str_txc_tready_int_dly = '1' and
           axi_str_txc_tvalid_dly0 = '1' and axi_str_txc_tlast_dly0 = '1' then
          case axi_flag is
            when "1111" =>
              case csum_cntrl is
                when "10"   => do_csum_int <= '1';
                when others => do_csum_int <= '0';
              end case;
            when others =>
              do_csum_int <= '0';
          end case;
        else
          do_csum_int <= do_csum_int;
        end if;
      end if;
    end if;
  end process;

do_csum     <= '0';
csum_result <= (others => '0');
csum_en     <= '0';
csum_we     <= (others => '0');
csum_cmplt  <= '1';

end generate GEN_FULL_CSUM;










end rtl;
