------------------------------------------------------------------------------
-- rx_mem_if.vhd
------------------------------------------------------------------------------
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
-- Filename:        rx_mem_if.vhd
-- Version:         v1.00a
-- Description:     Receive interface between AXIStream and Temac
--
-------------------------------------------------------------------------------
-- Structure:   This section shows the hierarchical structure of axi_ethernet.
--
--              axi_ethernet.vhd
--                axi_ethernt_soft_temac_wrap.vhd
--                axi_lite_ipif.vhd
--                embedded_top.vhd
--                  rx_if.vhd
--                    rx_axistream_if.vhd
--          ->        rx_mem_if
--                    rx_emac_if.vhd
--
-------------------------------------------------------------------------------
-- Author:          MSH
--
--  MSH     07/01/10
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

-- synopsys translate_off
library XilinxCoreLib;
-- synopsys translate_on

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

-------------------------------------------------------------------------------
-- Definition of Generics :
-------------------------------------------------------------------------------
--
--  C_FAMILY              -- Xilinx FPGA Family
--  C_RXD_MEM_ADDR_WIDTH           --
--  C_RXD_MEM_BYTES
--  C_RXS_MEM_ADDR_WIDTH           --
--  C_RXS_MEM_BYTES
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Ports :
-------------------------------------------------------------------------------
--
--  AXI_STR_RXD_ACLK
--  AXI_STR_RXD_DPMEM_WR_DATA
--  AXI_STR_RXD_DPMEM_RD_DATA
--  AXI_STR_RXD_DPMEM_WR_EN
--  AXI_STR_RXD_DPMEM_ADDR
--
--  AXI_STR_RXS_ACLK
--  AXI_STR_RXS_DPMEM_WR_DATA
--  AXI_STR_RXS_DPMEM_RD_DATA
--  AXI_STR_RXS_DPMEM_WR_EN
--  AXI_STR_RXS_DPMEM_ADDR
--
--  RX_CLIENT_CLK
--  RX_CLIENT_CLK_ENBL
--  RX_CLIENT_RXD_DPMEM_WR_DATA
--  RX_CLIENT_RXD_DPMEM_RD_DATA
--  RX_CLIENT_RXD_DPMEM_WR_EN
--  RX_CLIENT_RXD_DPMEM_ADDR
--  RESET2RX_CLIENT
--
--  RX_CLIENT_RXS_DPMEM_WR_DATA
--  RX_CLIENT_RXS_DPMEM_RD_DATA
--  RX_CLIENT_RXS_DPMEM_WR_EN
--  RX_CLIENT_RXS_DPMEM_ADDR
--
-------------------------------------------------------------------------------
----                  Entity Section
-------------------------------------------------------------------------------

entity rx_mem_if is
  generic (
    C_RXD_MEM_BYTES      : integer    := 4096;
    C_RXD_MEM_ADDR_WIDTH : integer    := 10;
    C_RXS_MEM_BYTES      : integer    := 4096;
    C_RXS_MEM_ADDR_WIDTH : integer    := 10;
    C_FAMILY             : string     := "virtex6"
  );

  port    (
    AXI_STR_RXD_ACLK            : in  std_logic;                                        --  AXI-Stream Receive Data Clock
    AXI_STR_RXD_DPMEM_WR_DATA   : in  std_logic_vector(35 downto 0);                    --  AXI-Stream Receive Data Write Data
    AXI_STR_RXD_DPMEM_RD_DATA   : out std_logic_vector(35 downto 0);                    --  AXI-Stream Receive Data Read Data
    AXI_STR_RXD_DPMEM_WR_EN     : in  std_logic_vector(0 downto 0);                     --  AXI-Stream Receive Data Write Enable
    AXI_STR_RXD_DPMEM_ADDR      : in  std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);  --  AXI-Stream Receive Data Address
    RESET2AXI_STR_RXD           : in  std_logic;                                        --  AXI-Stream Receive Data Rese

    AXI_STR_RXS_ACLK            : in  std_logic;                                        --  AXI-Stream Receive Status Clock
    AXI_STR_RXS_DPMEM_WR_DATA   : in  std_logic_vector(35 downto 0);                    --  AXI-Stream Receive Status Write Data
    AXI_STR_RXS_DPMEM_RD_DATA   : out std_logic_vector(35 downto 0);                    --  AXI-Stream Receive Status Read Data
    AXI_STR_RXS_DPMEM_WR_EN     : in  std_logic_vector(0 downto 0);                     --  AXI-Stream Receive Status Write Enable
    AXI_STR_RXS_DPMEM_ADDR      : in  std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);  --  AXI-Stream Receive Status Address
    RESET2AXI_STR_RXS           : in  std_logic;                                        --  AXI-Stream Receive Status Rese

    RX_CLIENT_CLK               : in  std_logic;                                        --  Receive MAC Clock
    RX_CLIENT_CLK_ENBL          : in  std_logic;                                        --  Receive MAC Clock Enable
    RX_CLIENT_RXD_DPMEM_WR_DATA : in  std_logic_vector(35 downto 0);                    --  Receive MAC Data Memory Write Data
    RX_CLIENT_RXD_DPMEM_RD_DATA : out std_logic_vector(35 downto 0);                    --  Receive MAC Data Memory Read Data
    RX_CLIENT_RXD_DPMEM_WR_EN   : in  std_logic_vector(0 downto 0);                     --  Receive MAC Data Memory Write Enable
    RX_CLIENT_RXD_DPMEM_ADDR    : in  std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);  --  Receive MAC Data Memory Address

    RX_CLIENT_RXS_DPMEM_WR_DATA : in  std_logic_vector(35 downto 0);                    --  Receive MAC Status Memory Write Data
    RX_CLIENT_RXS_DPMEM_RD_DATA : out std_logic_vector(35 downto 0);                    --  Receive MAC Status Memory Read Data
    RX_CLIENT_RXS_DPMEM_WR_EN   : in  std_logic_vector(0 downto 0);                     --  Receive MAC Status Memory Write Enable
    RX_CLIENT_RXS_DPMEM_ADDR    : in  std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);  --  Receive MAC Status Memory Address
    RESET2RX_CLIENT         : in  std_logic                                             --  Receive MAC Reset
  );
end rx_mem_if;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of rx_mem_if is

------------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------------


------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------
signal rx_client_rxs_dpmem_wr_data_d1 :  std_logic_vector(35 downto 0);
signal rx_client_rxs_dpmem_wr_en_d1   :  std_logic_vector(0 downto 0);
signal rx_client_rxs_dpmem_addr_d1    :  std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rx_client_rxd_dpmem_wr_data_d1 :  std_logic_vector(35 downto 0);
signal rx_client_rxd_dpmem_wr_en_d1   :  std_logic_vector(0 downto 0);
signal rx_client_rxd_dpmem_addr_d1    :  std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);

signal rx_client_clk_enbl_d1          :  std_logic;


begin

  PIPELINE_RXSMEMREG : process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        rx_client_rxs_dpmem_wr_data_d1 <= (others => '0');
        rx_client_rxs_dpmem_wr_en_d1   <= (others => '0');
        rx_client_rxs_dpmem_addr_d1    <= (others => '0');
        rx_client_clk_enbl_d1          <= '0';
      else
        rx_client_rxs_dpmem_wr_data_d1 <= RX_CLIENT_RXS_DPMEM_WR_DATA;       
        rx_client_rxs_dpmem_wr_en_d1   <= RX_CLIENT_RXS_DPMEM_WR_EN;       
        rx_client_rxs_dpmem_addr_d1    <= RX_CLIENT_RXS_DPMEM_ADDR;       
        rx_client_clk_enbl_d1          <= RX_CLIENT_CLK_ENBL;
      end if;
    end if;
  end process;

  PIPELINE_RXDMEMREG : process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        rx_client_rxd_dpmem_wr_data_d1 <= (others => '0');
        rx_client_rxd_dpmem_wr_en_d1 <= (others => '0');
        rx_client_rxd_dpmem_addr_d1 <= (others => '0');
      else
        rx_client_rxd_dpmem_wr_data_d1 <= RX_CLIENT_RXD_DPMEM_WR_DATA;       
        rx_client_rxd_dpmem_wr_en_d1 <= RX_CLIENT_RXD_DPMEM_WR_EN;       
        rx_client_rxd_dpmem_addr_d1 <= RX_CLIENT_RXD_DPMEM_ADDR;       
      end if;
    end if;
  end process;

 I_RXD_MEM : entity proc_common_v3_00_a.blk_mem_gen_wrapper
   generic map(
      c_family                 => C_FAMILY,
      c_xdevicefamily          => C_FAMILY,

      -- Memory Specific Configurations
      c_mem_type               => 2,
         -- This wrapper only supports the True Dual Port RAM
         -- 0: Single Port RAM
         -- 1: Simple Dual Port RAM
         -- 2: True Dual Port RAM
         -- 3: Single Port Rom
         -- 4: Dual Port RAM
      c_algorithm              => 1,
         -- 0: Selectable Primative
         -- 1: Minimum Area
      c_prim_type              => 1,
         -- 0: ( 1-bit wide)
         -- 1: ( 2-bit wide)
         -- 2: ( 4-bit wide)
         -- 3: ( 9-bit wide)
         -- 4: (18-bit wide)
         -- 5: (36-bit wide)
         -- 6: (72-bit wide, single port only)
      c_byte_size              => 9,   -- 8 or 9

      -- Simulation Behavior Options
      c_sim_collision_check    => "NONE",
         -- "None"
         -- "Generate_X"
         -- "All"
         -- "Warnings_only"
      c_common_clk             => 0,   -- 0, 1
      c_disable_warn_bhv_coll  => 0,   -- 0, 1
      c_disable_warn_bhv_range => 0,   -- 0, 1

      -- Initialization Configuration Options
      c_load_init_file         => 0,
      c_init_file_name         => "no_coe_file_loaded",
      c_use_default_data       => 0,   -- 0, 1
      c_default_data           => "0", -- "..."

      -- Port A Specific Configurations
      c_has_mem_output_regs_a  => 0,   -- 0, 1
      c_has_mux_output_regs_a  => 0,   -- 0, 1
      c_write_width_a          => 36,  -- 1 to 1152
      c_read_width_a           => 36,  -- 1 to 1152
      c_write_depth_a          => (C_RXD_MEM_BYTES/4),  -- 2 to 9011200
      c_read_depth_a           => (C_RXD_MEM_BYTES/4),  -- 2 to 9011200
      c_addra_width            => (log2(C_RXD_MEM_BYTES/4)),   -- 1 to 24
      c_write_mode_a           => "NO_CHANGE",
         -- "Write_First"
         -- "Read_first"
         -- "No_Change"
      c_has_ena                => 1,   -- 0, 1
      c_has_regcea             => 0,   -- 0, 1
      c_has_ssra               => 0,   -- 0, 1
      c_sinita_val             => "0", --"..."
      c_use_byte_wea           => 0,   -- 0, 1
      c_wea_width              => 1,   -- 1 to 128

      -- Port B Specific Configurations
      c_has_mem_output_regs_b  => 0,   -- 0, 1
      c_has_mux_output_regs_b  => 0,   -- 0, 1
      c_write_width_b          => 36,  -- 1 to 1152
      c_read_width_b           => 36,  -- 1 to 1152
      c_write_depth_b          => (C_RXD_MEM_BYTES/4),  -- 2 to 9011200
      c_read_depth_b           => (C_RXD_MEM_BYTES/4),   -- 2 to 9011200
      c_addrb_width            => (log2(C_RXD_MEM_BYTES/4)),   -- 1 to 24
      c_write_mode_b           => "NO_CHANGE",
         -- "Write_First"
         -- "Read_first"
         -- "No_Change"
      c_has_enb                => 0,   -- 0, 1
      c_has_regceb             => 0,   -- 0, 1
      c_has_ssrb               => 0,   -- 0, 1
      c_sinitb_val             => "0", -- "..."
      c_use_byte_web           => 0,   -- 0, 1
      c_web_width              => 1,   -- 1 to 128

      -- Other Miscellaneous Configurations
      c_mux_pipeline_stages    => 0,   -- 0, 1, 2, 3
         -- The number of pipeline stages within the MUX
         --    for both Port A and Port B
      c_use_ecc                => 0,
         -- See DS512 for the limited core option selections for ECC support
      c_use_ramb16bwer_rst_bhv => 0    --0, 1
      )
   port map
      (
      clka    => RX_CLIENT_CLK,
      ssra    => RESET2RX_CLIENT,
      dina    => rx_client_rxd_dpmem_wr_data_d1,
      addra   => rx_client_rxd_dpmem_addr_d1,
      ena     => rx_client_clk_enbl_d1,
      regcea  => '0',
      wea     => rx_client_rxd_dpmem_wr_en_d1,
      douta   => RX_CLIENT_RXD_DPMEM_RD_DATA,


      clkb    => AXI_STR_RXD_ACLK,
      ssrb    => RESET2AXI_STR_RXD,
      dinb    => AXI_STR_RXD_DPMEM_WR_DATA,
      addrb   => AXI_STR_RXD_DPMEM_ADDR,
      enb     => '1',
      regceb  => '0',
      web     => AXI_STR_RXD_DPMEM_WR_EN,
      doutb   => AXI_STR_RXD_DPMEM_RD_DATA,

      dbiterr => open,
      sbiterr => open
      );

 I_RXS_MEM : entity proc_common_v3_00_a.blk_mem_gen_wrapper
   generic map(
      c_family                 => C_FAMILY,
      c_xdevicefamily          => C_FAMILY,

      -- Memory Specific Configurations
      c_mem_type               => 2,
         -- This wrapper only supports the True Dual Port RAM
         -- 0: Single Port RAM
         -- 1: Simple Dual Port RAM
         -- 2: True Dual Port RAM
         -- 3: Single Port Rom
         -- 4: Dual Port RAM
      c_algorithm              => 1,
         -- 0: Selectable Primative
         -- 1: Minimum Area
      c_prim_type              => 1,
         -- 0: ( 1-bit wide)
         -- 1: ( 2-bit wide)
         -- 2: ( 4-bit wide)
         -- 3: ( 9-bit wide)
         -- 4: (18-bit wide)
         -- 5: (36-bit wide)
         -- 6: (72-bit wide, single port only)
      c_byte_size              => 9,   -- 8 or 9

      -- Simulation Behavior Options
      c_sim_collision_check    => "NONE",
         -- "None"
         -- "Generate_X"
         -- "All"
         -- "Warnings_only"
      c_common_clk             => 0,   -- 0, 1
      c_disable_warn_bhv_coll  => 0,   -- 0, 1
      c_disable_warn_bhv_range => 0,   -- 0, 1

      -- Initialization Configuration Options
      c_load_init_file         => 0,
      c_init_file_name         => "no_coe_file_loaded",
      c_use_default_data       => 0,   -- 0, 1
      c_default_data           => "0", -- "..."

      -- Port A Specific Configurations
      c_has_mem_output_regs_a  => 0,   -- 0, 1
      c_has_mux_output_regs_a  => 0,   -- 0, 1
      c_write_width_a          => 36,  -- 1 to 1152
      c_read_width_a           => 36,  -- 1 to 1152
      c_write_depth_a          => (C_RXS_MEM_BYTES/4),  -- 2 to 9011200
      c_read_depth_a           => (C_RXS_MEM_BYTES/4),  -- 2 to 9011200
      c_addra_width            => (log2(C_RXS_MEM_BYTES/4)),   -- 1 to 24
      c_write_mode_a           => "NO_CHANGE",
         -- "Write_First"
         -- "Read_first"
         -- "No_Change"
      c_has_ena                => 1,   -- 0, 1
      c_has_regcea             => 0,   -- 0, 1
      c_has_ssra               => 0,   -- 0, 1
      c_sinita_val             => "0", --"..."
      c_use_byte_wea           => 0,   -- 0, 1
      c_wea_width              => 1,   -- 1 to 128

      -- Port B Specific Configurations
      c_has_mem_output_regs_b  => 0,   -- 0, 1
      c_has_mux_output_regs_b  => 0,   -- 0, 1
      c_write_width_b          => 36,  -- 1 to 1152
      c_read_width_b           => 36,  -- 1 to 1152
      c_write_depth_b          => (C_RXS_MEM_BYTES/4),  -- 2 to 9011200
      c_read_depth_b           => (C_RXS_MEM_BYTES/4),   -- 2 to 9011200
      c_addrb_width            => (log2(C_RXS_MEM_BYTES/4)),   -- 1 to 24
      c_write_mode_b           => "NO_CHANGE",
         -- "Write_First"
         -- "Read_first"
         -- "No_Change"
      c_has_enb                => 0,   -- 0, 1
      c_has_regceb             => 0,   -- 0, 1
      c_has_ssrb               => 0,   -- 0, 1
      c_sinitb_val             => "0", -- "..."
      c_use_byte_web           => 0,   -- 0, 1
      c_web_width              => 1,   -- 1 to 128

      -- Other Miscellaneous Configurations
      c_mux_pipeline_stages    => 0,   -- 0, 1, 2, 3
         -- The number of pipeline stages within the MUX
         --    for both Port A and Port B
      c_use_ecc                => 0,
         -- See DS512 for the limited core option selections for ECC support
      c_use_ramb16bwer_rst_bhv => 0    --0, 1
      )
   port map
      (
      clka    => RX_CLIENT_CLK,
      ssra    => RESET2RX_CLIENT,
      dina    => rx_client_rxs_dpmem_wr_data_d1,
      addra   => rx_client_rxs_dpmem_addr_d1,
      ena     => rx_client_clk_enbl_d1,
      regcea  => '0',
      wea     => rx_client_rxs_dpmem_wr_en_d1,
      douta   => RX_CLIENT_RXS_DPMEM_RD_DATA,


      clkb    => AXI_STR_RXS_ACLK,
      ssrb    => RESET2AXI_STR_RXS,
      dinb    => AXI_STR_RXS_DPMEM_WR_DATA,
      addrb   => AXI_STR_RXS_DPMEM_ADDR,
      enb     => '1',
      regceb  => '0',
      web     => AXI_STR_RXS_DPMEM_WR_EN,
      doutb   => AXI_STR_RXS_DPMEM_RD_DATA,

      dbiterr => open,
      sbiterr => open
      );

end rtl;
