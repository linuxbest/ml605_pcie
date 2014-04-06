------------------------------------------------------------------------------
-- rx_if.vhd
------------------------------------------------------------------------------
--
-- *************************************************************************
--
-- (c) Copyright 2004-2011 Xilinx, Inc. All rights reserved.
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
-- *************************************************************************
--
-- ------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
-- Filename:        rx_if.vhd
-- Description:     Receive interface between AXIStream and 10GE MAC
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to rtlrove
--              readability.
--
--              top_level.vhd
--                  -- second_level_file1.vhd
--                      -- third_level_file1.vhd
--                          -- fourth_level_file.vhd
--                      -- third_level_file2.vhd
--                  -- second_level_file2.vhd
--                  -- second_level_file3.vhd
--
--              This section is optional for common/shared modules but should
--              contain a statement stating it is a common/shared module.
------------------------------------------------------------------------------
-- Author:          MSH
--
--  MSH     07/01/10
-- ^^^^^^
--  - Initial release of v1.00.a
-- ~~~~~~
------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of : out   std_logic; port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Libraries used;
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.coregen_comp_defs.all;
use proc_common_v3_00_a.proc_common_pkg.log2;
use proc_common_v3_00_a.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

-------------------------------------------------------------------------------
-- Definition of Generics :
-------------------------------------------------------------------------------
-- System generics
--  C_FAMILY              -- Xilinx FPGA Family
--
-- Ethernet generics
--  C_RXMEM               -- Depth of RX memory in Bytes
--  C_RXCSUM
--     0  No checksum offloading
--     1  Partial (legacy) checksum offloading
--     2  Full checksum offloading
--  C_RXVLAN_TRAN         -- Enable RX enhanced VLAN translation
--  C_RXVLAN_TAG          -- Enable RX enhanced VLAN taging
--  C_RXVLAN_STRP         -- Enable RX enhanced VLAN striping

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Ports :
-------------------------------------------------------------------------------
--    BUS2IP_CLK
--    BUS2IP_RESET
--
--    AXI_STR_RXD_ACLK
--    AXI_STR_RXD_VALID
--    AXI_STR_RXD_READY
--    AXI_STR_RXD_LAST
--    AXI_STR_RXD_STRB
--    AXI_STR_RXD_DATA
--
--    AXI_STR_RXS_ACLK
--    AXI_STR_RXS_VALID
--    AXI_STR_RXS_READY
--    AXI_STR_RXS_LAST
--    AXI_STR_RXS_STRB
--    AXI_STR_RXS_DATA
--
--    EMAC_CLIENT_RXD_LEGACY
--    EMAC_CLIENT_RXD_VLD_LEGACY
--    EMAC_CLIENT_RX_GOODFRAME_LEGACY
--    EMAC_CLIENT_RX_BADFRAME_LEGACY
--    EMAC_CLIENT_RX_FRAMEDROP
--    LEGACY_RX_FILTER_MATCH
--
--    RX_CLIENT_CLK
--
--    RTAGREGDATA
--    TPID0REGDATA
--    TPID1REGDATA
--    LLINKCLKVLANADDR
--    LLINKCLKVLANRDDATA
--    LLINKCLKRXVLANBRAMENA
--
--    LLINKCLKEMULTIFLTRENBL
--    LLINKCLKNEWFNCENBL
--    LLINKCLKRXVSTRPMODE
--    LLINKCLKRXVTAGMODE
-------------------------------------------------------------------------------
----                  Entity Section
-------------------------------------------------------------------------------

entity rx_if is
  generic (
    C_FAMILY              : string                        := "virtex6";
    C_RXCSUM              : integer range 0 to 2          := 0;
      -- 0 - No checksum offloading
      -- 1 - Partial (legacy) checksum offloading
      -- 2 - Full checksum offloading
    C_RXMEM               : integer                       := 4096;
    C_RXVLAN_TRAN         : integer range 0 to 1          := 0;
    C_RXVLAN_TAG          : integer range 0 to 1          := 0;
    C_RXVLAN_STRP         : integer range 0 to 1          := 0
    );

  port    (
    AXI_STR_RXD_ACLK                : in  std_logic;                          --  AXI-Stream Receive Data Clock
    AXI_STR_RXD_VALID               : out std_logic;                          --  AXI-Stream Receive Data Valid
    AXI_STR_RXD_READY               : in  std_logic;                          --  AXI-Stream Receive Data Ready
    AXI_STR_RXD_LAST                : out std_logic;                          --  AXI-Stream Receive Data Last
    AXI_STR_RXD_STRB                : out std_logic_vector(7 downto 0);       --  AXI-Stream Receive Data Keep
    AXI_STR_RXD_DATA                : out std_logic_vector(63 downto 0);      --  AXI-Stream Receive Data Data
    RESET2AXI_STR_RXD               : in  std_logic;                          --  AXI-Stream Receive Data Reset

    AXI_STR_RXS_ACLK                : in  std_logic;                          --  AXI-Stream Receive Status Clock
    AXI_STR_RXS_VALID               : out std_logic;                          --  AXI-Stream Receive Status Valid
    AXI_STR_RXS_READY               : in  std_logic;                          --  AXI-Stream Receive Status Ready
    AXI_STR_RXS_LAST                : out std_logic;                          --  AXI-Stream Receive Status Last
    AXI_STR_RXS_STRB                : out std_logic_vector(3 downto 0);       --  AXI-Stream Receive Status Keep
    AXI_STR_RXS_DATA                : out std_logic_vector(31 downto 0);      --  AXI-Stream Receive Status Data
    RESET2AXI_STR_RXS               : in  std_logic;                          --  AXI-Stream Receive Status Reset
                                                                        
    rx_mac_aclk                     : in  std_logic;                          -- Rx axistream clock from 10GE MAC
    rx_reset                        : in  std_logic;                          -- Rx axistream reset from 10GE MAC
    rx_axis_mac_tdata               : in  std_logic_vector(63 downto 0);      -- Rx axistream data from 10GE MAC
    rx_axis_mac_tvalid              : in  std_logic;                          -- Rx axistream valid from 10GE MAC
    rx_axis_mac_tkeep               : in  std_logic_vector(7 downto 0);       -- Rx axistream keep from 10GE MAC
    rx_axis_mac_tlast               : in  std_logic;                          -- Rx axistream last from 10GE MAC
    rx_axis_mac_tuser               : in  std_logic;                          -- Rx axistream good/bad indicator from 10GE MAC

    RX_CL_CLK_RX_TAG_REG_DATA       : in  std_logic_vector(0 to 31);          --  Receive VLAN TAG
    RX_CL_CLK_TPID0_REG_DATA        : in  std_logic_vector(0 to 31);          --  Receive VLAN TPID 0
    RX_CL_CLK_TPID1_REG_DATA        : in  std_logic_vector(0 to 31);          --  Receive VLAN TPID 1

    RX_CL_CLK_VLAN_ADDR             : out std_logic_vector(0 to 11);          --  Receive VLAN Memory Address
    RX_CL_CLK_VLAN_RD_DATA          : in  std_logic_vector(18 to 31);         --  Receive VLAN Memory Read Data
    RX_CL_CLK_VLAN_BRAM_EN_A        : out std_logic;                          --  Receive VLAN Memory Enable

    RX_CL_CLK_NEW_FNC_ENBL          : in  std_logic;                          --  Receive New Function Enable
    RX_CL_CLK_VSTRP_MODE            : in  std_logic_vector(0 to 1);           --  Receive VLAN Strip Mode
    RX_CL_CLK_VTAG_MODE             : in  std_logic_vector(0 to 1)            --  Receive VLAN TAG Mode

    );
end rx_if;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of rx_if is

------------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------------

constant C_RXD_MEM_BYTES      : integer := C_RXMEM;
constant C_RXD_MEM_ADDR_WIDTH : integer := (log2(C_RXD_MEM_BYTES/8))-1;
constant C_RXS_MEM_BYTES      : integer := (C_RXMEM/2);
constant C_RXS_MEM_ADDR_WIDTH : integer := (log2(C_RXS_MEM_BYTES/4))-1;
constant C_RXVLAN_WIDTH       : integer := (C_RXVLAN_TRAN*12) + C_RXVLAN_TAG + C_RXVLAN_STRP;

------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------
type type_end_of_frame_reset_array is array (1 to 18) of std_logic;
signal end_of_frame_reset_array : type_end_of_frame_reset_array;
signal end_of_frame_reset_array_in : std_logic;

signal axi_str_rxd_dpmem_wr_data       : std_logic_vector(71 downto 0);
signal axi_str_rxd_dpmem_rd_data       : std_logic_vector(71 downto 0);
signal axi_str_rxd_dpmem_wr_en         : std_logic_vector(0 downto 0);
signal axi_str_rxd_dpmem_addr          : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);

signal axi_str_rxs_dpmem_wr_data       : std_logic_vector(35 downto 0);
signal axi_str_rxs_dpmem_rd_data       : std_logic_vector(35 downto 0);
signal axi_str_rxs_dpmem_wr_en         : std_logic_vector(0 downto 0);
signal axi_str_rxs_dpmem_addr          : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);

signal rx_client_rxd_dpmem_wr_data     : std_logic_vector(71 downto 0);
signal rx_client_rxd_dpmem_rd_data     : std_logic_vector(71 downto 0);
signal rx_client_rxd_dpmem_wr_en       : std_logic_vector(0 downto 0);
signal rx_client_rxd_dpmem_addr        : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);

signal rx_client_rxs_dpmem_wr_data     : std_logic_vector(35 downto 0);
signal rx_client_rxs_dpmem_rd_data     : std_logic_vector(35 downto 0);
signal rx_client_rxs_dpmem_wr_en       : std_logic_vector(0 downto 0);
signal rx_client_rxs_dpmem_addr        : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal axi_str_rxd_mem_last_read_out_ptr_gray : std_logic_vector(71 downto 0);
signal axi_str_rxs_mem_last_read_out_ptr_gray : std_logic_vector(35 downto 0);

signal derived_rx_good_frame_i         : std_logic;
signal derived_rx_bad_frame_i          : std_logic;
signal derived_rx_good_frame_d1        : std_logic;
signal derived_rx_bad_frame_d1         : std_logic;
signal derived_rx_good_frame           : std_logic;
signal derived_rx_bad_frame            : std_logic;
signal derived_rxd_vld                 : std_logic_vector(7 downto 0);
signal rx_empty			       : std_logic_vector(2 downto 0);
signal rx_axis_mac_tdata_d1            : std_logic_vector(63 downto 0); 

         
signal end_of_frame_pulse     : std_logic;
signal derived_sof_int		: std_logic;
signal derived_sof		: std_logic;
signal derived_eof		: std_logic;

begin

  end_of_frame_reset_array_in  <= end_of_frame_reset_array(10);		-- 17

  PIPE_ENDOFFRAMERESET : process (rx_mac_aclk)
  begin
   if rising_edge(rx_mac_aclk) then
     if rx_reset = '1' then
       end_of_frame_reset_array <= (others => '0');
     else
         end_of_frame_reset_array (1)  <= end_of_frame_pulse;
         for i in 1 to 17 loop
           end_of_frame_reset_array (i+1) <= end_of_frame_reset_array (i);
         end loop;
     end if;
   end if;
  end process;

  -- Create end of frame reset using TLAST which does not move in relationship
  -- to the next frame coming in.

  ENDOFFRAMEPULSE_PROCESS : process (rx_mac_aclk)
  begin
   if rising_edge(rx_mac_aclk) then
     if rx_reset = '1' then
       end_of_frame_pulse <= '0';
     else
       end_of_frame_pulse <= (rx_axis_mac_tlast and rx_axis_mac_tvalid);           -- set when tlast indicates end of frame
     end if;
   end if;
  end process;

  derived_rx_good_frame_i <= (rx_axis_mac_tlast and rx_axis_mac_tvalid) and not(rx_axis_mac_tuser);
  derived_rx_bad_frame_i  <= (rx_axis_mac_tlast and rx_axis_mac_tvalid) and    (rx_axis_mac_tuser);

   -- stretch good bad for 10/100 clock enable case
  STRETCH_GOOD_BAD_PROCESS : process(rx_mac_aclk)
  begin
   if rising_edge(rx_mac_aclk) then
     if rx_reset = '1' then
        derived_rx_good_frame_d1 <= '0';
        derived_rx_bad_frame_d1  <= '0';
      else
        derived_rx_good_frame_d1 <= derived_rx_good_frame_i;
        derived_rx_bad_frame_d1  <= derived_rx_bad_frame_i;
      end if;
    end if;
  end process STRETCH_GOOD_BAD_PROCESS;

  derived_rx_good_frame <= derived_rx_good_frame_i or derived_rx_good_frame_d1;
  derived_rx_bad_frame  <= derived_rx_bad_frame_i  or derived_rx_bad_frame_d1;

  process (rx_mac_aclk)
  begin
    if rising_edge(rx_mac_aclk) then
      if rx_reset = '1' then
        derived_sof_int   <=   '1'; 
  	derived_sof   	  <=   '0';
  	derived_eof       <=   '0';                             
      else
  	derived_sof   <= derived_sof_int and rx_axis_mac_tvalid after 1 ns;
  	derived_eof   <= rx_axis_mac_tlast and rx_axis_mac_tvalid after 1 ns;
        if rx_axis_mac_tvalid = '1' then
          if rx_axis_mac_tlast = '1' then
	    derived_sof_int   <=   '1';
	  else
            derived_sof_int   <=   '0';
	  end if;                        
        end if;
      end if;
    end if;
  end process;
   
  CREATE_RXD_VLD_PROCESS: process (rx_mac_aclk)
  begin
    if rising_edge(rx_mac_aclk) then
      if rx_reset = '1' then
        derived_rxd_vld       <= (others => '0');
	rx_empty	      <= (others => '0');
        rx_axis_mac_tdata_d1  <= (others => '0');                                      
      else
  	case   rx_axis_mac_tkeep   is
	   when   "00000001"   =>
		rx_empty   <=   "111" after 1 ns;	
	   when   "00000011"   =>
		rx_empty   <=   "110" after 1 ns;   
	   when   "00000111"   =>
		rx_empty   <=   "101" after 1 ns;   
	   when   "00001111"   =>
		rx_empty   <=   "100" after 1 ns;   
	   when   "00011111"   =>
		rx_empty   <=   "011" after 1 ns;   
	   when   "00111111"   =>
		rx_empty   <=   "010" after 1 ns;   
	   when   "01111111"   =>
		rx_empty   <=   "001" after 1 ns;   
	   when   others       =>
		rx_empty   <=   "000" after 1 ns;
	end case;
        rx_axis_mac_tdata_d1  <= rx_axis_mac_tdata after 1 ns;
        if rx_axis_mac_tvalid = '1' then
          derived_rxd_vld <= rx_axis_mac_tkeep after 1 ns;               
        else
          derived_rxd_vld <= (others => '0') after 1 ns;                                     
        end if;
      end if;
    end if;
  end process CREATE_RXD_VLD_PROCESS;

  RX_DP_MEM_IF_I : entity axi_ethernet_v3_01_a.rx_mem_if(rtl)
  generic map (
    C_RXD_MEM_BYTES      => C_RXD_MEM_BYTES,
    C_RXD_MEM_ADDR_WIDTH => C_RXD_MEM_ADDR_WIDTH,
    C_RXS_MEM_BYTES      => C_RXS_MEM_BYTES,
    C_RXS_MEM_ADDR_WIDTH => C_RXS_MEM_ADDR_WIDTH,
    C_FAMILY             => C_FAMILY
  )
  port map(
    AXI_STR_RXD_ACLK            => AXI_STR_RXD_ACLK,
    AXI_STR_RXD_DPMEM_WR_DATA   => axi_str_rxd_dpmem_wr_data,
    AXI_STR_RXD_DPMEM_RD_DATA   => axi_str_rxd_dpmem_rd_data,
    AXI_STR_RXD_DPMEM_WR_EN     => axi_str_rxd_dpmem_wr_en,
    AXI_STR_RXD_DPMEM_ADDR      => axi_str_rxd_dpmem_addr,
    RESET2AXI_STR_RXD           => RESET2AXI_STR_RXD,

    AXI_STR_RXS_ACLK            => AXI_STR_RXS_ACLK,
    AXI_STR_RXS_DPMEM_WR_DATA   => axi_str_rxs_dpmem_wr_data,
    AXI_STR_RXS_DPMEM_RD_DATA   => axi_str_rxs_dpmem_rd_data,
    AXI_STR_RXS_DPMEM_WR_EN     => axi_str_rxs_dpmem_wr_en,
    AXI_STR_RXS_DPMEM_ADDR      => axi_str_rxs_dpmem_addr,
    RESET2AXI_STR_RXS           => RESET2AXI_STR_RXS,

    RX_CLIENT_CLK               => rx_mac_aclk,  
    RX_CLIENT_CLK_ENBL		=> '1',          
    RX_CLIENT_RXD_DPMEM_WR_DATA => rx_client_rxd_dpmem_wr_data,
    RX_CLIENT_RXD_DPMEM_RD_DATA => rx_client_rxd_dpmem_rd_data,
    RX_CLIENT_RXD_DPMEM_WR_EN   => rx_client_rxd_dpmem_wr_en,
    RX_CLIENT_RXD_DPMEM_ADDR    => rx_client_rxd_dpmem_addr,

    RX_CLIENT_RXS_DPMEM_WR_DATA => rx_client_rxs_dpmem_wr_data,
    RX_CLIENT_RXS_DPMEM_RD_DATA => rx_client_rxs_dpmem_rd_data,
    RX_CLIENT_RXS_DPMEM_WR_EN   => rx_client_rxs_dpmem_wr_en,
    RX_CLIENT_RXS_DPMEM_ADDR    => rx_client_rxs_dpmem_addr,
    RESET2RX_CLIENT         => rx_reset
  );

  NO_INCLUDE_RX_VLAN: if(C_RXVLAN_TRAN = 0 and C_RXVLAN_TAG = 0 and C_RXVLAN_STRP = 0) generate
  begin
    RX_EMAC_IF_I : entity axi_ethernet_v3_01_a.rx_emac_if(rtl)
    generic map (
      C_RXVLAN_WIDTH        => C_RXVLAN_WIDTH,
      C_RXD_MEM_BYTES       => C_RXD_MEM_BYTES,
      C_RXD_MEM_ADDR_WIDTH  => C_RXD_MEM_ADDR_WIDTH,
      C_RXS_MEM_BYTES       => C_RXS_MEM_BYTES,
      C_RXS_MEM_ADDR_WIDTH  => C_RXS_MEM_ADDR_WIDTH,
      C_FAMILY              => C_FAMILY,
      C_RXCSUM              => C_RXCSUM,
      C_RXVLAN_TRAN         => C_RXVLAN_TRAN,
      C_RXVLAN_TAG          => C_RXVLAN_TAG,
      C_RXVLAN_STRP         => C_RXVLAN_STRP
    )
    port map(
      end_of_frame_reset_in           => end_of_frame_reset_array_in,
                                                               
      rx_mac_aclk                     =>  rx_mac_aclk,         
      rx_reset                        =>  rx_reset,            
      derived_rxd                     =>  rx_axis_mac_tdata_d1,
      derived_sof                     =>  derived_sof,
      derived_eof                     =>  derived_eof,
      derived_rx_clk_enbl	      =>  '1',   
                                                               
      derived_rx_good_frame           =>  derived_rx_good_frame,   
      derived_rx_bad_frame            =>  derived_rx_bad_frame,     
      derived_rxd_vld                 =>  derived_rxd_vld,
      rx_empty			      =>  rx_empty,

      RX_CL_CLK_RX_TAG_REG_DATA       => RX_CL_CLK_RX_TAG_REG_DATA,
      RX_CL_CLK_TPID0_REG_DATA        => RX_CL_CLK_TPID0_REG_DATA,
      RX_CL_CLK_TPID1_REG_DATA        => RX_CL_CLK_TPID1_REG_DATA,

      RX_CL_CLK_VLAN_ADDR             => RX_CL_CLK_VLAN_ADDR,
      RX_CL_CLK_VLAN_RD_DATA          => RX_CL_CLK_VLAN_RD_DATA,
      RX_CL_CLK_VLAN_BRAM_EN_A        => RX_CL_CLK_VLAN_BRAM_EN_A,

      RX_CL_CLK_NEW_FNC_ENBL          => RX_CL_CLK_NEW_FNC_ENBL,
      RX_CL_CLK_VSTRP_MODE            => RX_CL_CLK_VSTRP_MODE,
      RX_CL_CLK_VTAG_MODE             => RX_CL_CLK_VTAG_MODE,

      RX_CLIENT_RXD_DPMEM_WR_DATA     => rx_client_rxd_dpmem_wr_data,
      RX_CLIENT_RXD_DPMEM_RD_DATA     => rx_client_rxd_dpmem_rd_data,
      RX_CLIENT_RXD_DPMEM_WR_EN       => rx_client_rxd_dpmem_wr_en,
      RX_CLIENT_RXD_DPMEM_ADDR        => rx_client_rxd_dpmem_addr,
      RX_CLIENT_RXS_DPMEM_WR_DATA     => rx_client_rxs_dpmem_wr_data,
      RX_CLIENT_RXS_DPMEM_RD_DATA     => rx_client_rxs_dpmem_rd_data,
      RX_CLIENT_RXS_DPMEM_WR_EN       => rx_client_rxs_dpmem_wr_en,
      RX_CLIENT_RXS_DPMEM_ADDR        => rx_client_rxs_dpmem_addr,

      AXI_STR_RXS_MEM_LAST_READ_OUT_PTR_GRAY => axi_str_rxs_mem_last_read_out_ptr_gray,
      AXI_STR_RXD_MEM_LAST_READ_OUT_PTR_GRAY => axi_str_rxd_mem_last_read_out_ptr_gray
    );
  end generate NO_INCLUDE_RX_VLAN;

  INCLUDE_RX_VLAN: if(C_RXVLAN_TRAN = 1 or C_RXVLAN_TAG = 1 or C_RXVLAN_STRP = 1) generate
  begin
    RX_EMAC_IF_I : entity axi_ethernet_v3_01_a.rx_emac_if_vlan(rtl)
    generic map (
      C_RXVLAN_WIDTH        => C_RXVLAN_WIDTH,
      C_RXD_MEM_BYTES       => C_RXD_MEM_BYTES,
      C_RXD_MEM_ADDR_WIDTH  => C_RXD_MEM_ADDR_WIDTH,
      C_RXS_MEM_BYTES       => C_RXS_MEM_BYTES,
      C_RXS_MEM_ADDR_WIDTH  => C_RXS_MEM_ADDR_WIDTH,
      C_FAMILY              => C_FAMILY,
      C_RXCSUM              => C_RXCSUM,
      C_RXVLAN_TRAN         => C_RXVLAN_TRAN,
      C_RXVLAN_TAG          => C_RXVLAN_TAG,
      C_RXVLAN_STRP         => C_RXVLAN_STRP
    )
    port map(
      end_of_frame_reset_in           => end_of_frame_reset_array_in,
                                                               
      rx_mac_aclk                     =>  rx_mac_aclk,         
      rx_reset                        =>  rx_reset,            
      derived_rxd                     =>  rx_axis_mac_tdata_d1, 
      derived_sof                     =>  derived_sof,
      derived_eof                     =>  derived_eof,  
      derived_rx_clk_enbl	      =>  '1',  
                                                               
      derived_rx_good_frame           =>  derived_rx_good_frame,   
      derived_rx_bad_frame            =>  derived_rx_bad_frame,     
      derived_rxd_vld                 =>  derived_rxd_vld,
      
      RX_CL_CLK_RX_TAG_REG_DATA       => RX_CL_CLK_RX_TAG_REG_DATA,
      RX_CL_CLK_TPID0_REG_DATA        => RX_CL_CLK_TPID0_REG_DATA,
      RX_CL_CLK_TPID1_REG_DATA        => RX_CL_CLK_TPID1_REG_DATA,

      RX_CL_CLK_VLAN_ADDR             => RX_CL_CLK_VLAN_ADDR,
      RX_CL_CLK_VLAN_RD_DATA          => RX_CL_CLK_VLAN_RD_DATA,
      RX_CL_CLK_VLAN_BRAM_EN_A        => RX_CL_CLK_VLAN_BRAM_EN_A,

      RX_CL_CLK_NEW_FNC_ENBL          => RX_CL_CLK_NEW_FNC_ENBL,
      RX_CL_CLK_VSTRP_MODE            => RX_CL_CLK_VSTRP_MODE,
      RX_CL_CLK_VTAG_MODE             => RX_CL_CLK_VTAG_MODE,

      RX_CLIENT_RXD_DPMEM_WR_DATA     => rx_client_rxd_dpmem_wr_data,
      RX_CLIENT_RXD_DPMEM_RD_DATA     => rx_client_rxd_dpmem_rd_data,
      RX_CLIENT_RXD_DPMEM_WR_EN       => rx_client_rxd_dpmem_wr_en,
      RX_CLIENT_RXD_DPMEM_ADDR        => rx_client_rxd_dpmem_addr,
      RX_CLIENT_RXS_DPMEM_WR_DATA     => rx_client_rxs_dpmem_wr_data,
      RX_CLIENT_RXS_DPMEM_RD_DATA     => rx_client_rxs_dpmem_rd_data,
      RX_CLIENT_RXS_DPMEM_WR_EN       => rx_client_rxs_dpmem_wr_en,
      RX_CLIENT_RXS_DPMEM_ADDR        => rx_client_rxs_dpmem_addr,

      AXI_STR_RXS_MEM_LAST_READ_OUT_PTR_GRAY => axi_str_rxs_mem_last_read_out_ptr_gray,
      AXI_STR_RXD_MEM_LAST_READ_OUT_PTR_GRAY => axi_str_rxd_mem_last_read_out_ptr_gray
    );
  end generate INCLUDE_RX_VLAN;

  RX_AXISTREAM_IF_I : entity axi_ethernet_v3_01_a.rx_axistream_if(rtl)
  generic map (
    C_RXD_MEM_BYTES      => C_RXD_MEM_BYTES,
    C_RXD_MEM_ADDR_WIDTH => C_RXD_MEM_ADDR_WIDTH,
    C_RXS_MEM_BYTES      => C_RXS_MEM_BYTES,
    C_RXS_MEM_ADDR_WIDTH => C_RXS_MEM_ADDR_WIDTH,
    C_FAMILY             => C_FAMILY,
    C_RXCSUM             => C_RXCSUM,
    C_RXVLAN_TRAN        => C_RXVLAN_TRAN,
    C_RXVLAN_TAG         => C_RXVLAN_TAG,
    C_RXVLAN_STRP        => C_RXVLAN_STRP
  )
  port map(
    AXI_STR_RXD_ACLK                => AXI_STR_RXD_ACLK,
    AXI_STR_RXD_VALID               => AXI_STR_RXD_VALID,
    AXI_STR_RXD_READY               => AXI_STR_RXD_READY,
    AXI_STR_RXD_LAST                => AXI_STR_RXD_LAST,
    AXI_STR_RXD_STRB                => AXI_STR_RXD_STRB,
    AXI_STR_RXD_DATA                => AXI_STR_RXD_DATA,
    RESET2AXI_STR_RXD               => RESET2AXI_STR_RXD,

    AXI_STR_RXS_ACLK                => AXI_STR_RXS_ACLK,
    AXI_STR_RXS_VALID               => AXI_STR_RXS_VALID,
    AXI_STR_RXS_READY               => AXI_STR_RXS_READY,
    AXI_STR_RXS_LAST                => AXI_STR_RXS_LAST,
    AXI_STR_RXS_STRB                => AXI_STR_RXS_STRB,
    AXI_STR_RXS_DATA                => AXI_STR_RXS_DATA,
    RESET2AXI_STR_RXS               => RESET2AXI_STR_RXS,

    AXI_STR_RXD_DPMEM_WR_DATA       => axi_str_rxd_dpmem_wr_data,
    AXI_STR_RXD_DPMEM_RD_DATA       => axi_str_rxd_dpmem_rd_data,
    AXI_STR_RXD_DPMEM_WR_EN         => axi_str_rxd_dpmem_wr_en,
    AXI_STR_RXD_DPMEM_ADDR          => axi_str_rxd_dpmem_addr,

    AXI_STR_RXS_DPMEM_WR_DATA       => axi_str_rxs_dpmem_wr_data,
    AXI_STR_RXS_DPMEM_RD_DATA       => axi_str_rxs_dpmem_rd_data,
    AXI_STR_RXS_DPMEM_WR_EN         => axi_str_rxs_dpmem_wr_en,
    AXI_STR_RXS_DPMEM_ADDR          => axi_str_rxs_dpmem_addr,

      AXI_STR_RXS_MEM_LAST_READ_OUT_PTR_GRAY => axi_str_rxs_mem_last_read_out_ptr_gray,
    AXI_STR_RXD_MEM_LAST_READ_OUT_PTR_GRAY => axi_str_rxd_mem_last_read_out_ptr_gray
  );

end rtl;
