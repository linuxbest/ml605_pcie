-------------------------------------------------------------------------------
-- axi_ethernet.vhd
-------------------------------------------------------------------------------
--
-- *************************************************************************
--
-- (c) Copyright 1998 - 2011 Xilinx, Inc. All rights reserved.
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
-------------------------------------------------------------------------------
-- Filename:        axi_ethernet.vhd
-- Description:     top level of axi_ethernet
--
-------------------------------------------------------------------------------
-- Structure:   This section shows the hierarchical structure of axi_uartlite.
--
--              axi_ethernet_v3_01_a
--              |
--              |-[IBUFDS_GTXE1]
--              |-[FDP]
--              |-[BUFG]
--              |-[IBUFDS]
--              |-[BUFIO2]
--              |-<GET_ROOT_FAMILY>
--              |-embedded_top
--              | |-actv_hi_reset_clk_cross
--              | |-axi_lite_ipif_v1_01_a
--              | | |-slave_attachment
--              | |   |-address_decoder
--              | |
--              | |-reset_combiner
--              | | |-actv_hi_reset_clock_cross
--              | | |-[SRLC32E]
--              | |
--              | |-actv_hi_pulse_clk_cross
--              | |-address_response_shim
--              | |-registers
--              | | |-<BLK_MEM_GEN_WRAPPER>
--              | | |-reg_cr
--              | | |-reg_ie
--              | | |-reg_ifgp
--              | | |-reg_ip
--              | | |-reg_is
--              | | |-reg_32b
--              | | |-reg_tp
--              | | |-reg_16bl
--              | |
--              | |-bus_clk_cross
--              | |-rx_if
--              | | |-rx_emac_if
--              | | |-rx_emac_if_vlan
--              | | |-rx_axistream_if
--              | | | |-<FIFO_GENERATOR_V7_3>
--              | | |
--              | | |-rx_mem_if
--              | | | |-<BLK_MEM_GEN_WRAPPER>
--              | |
--              | |-tx_if
--              | | |-tx_axistream_if
--              | | | |-tx_basic_if
--              | | | |-tx_csum_if
--              | | | | |-tx_csum_partial_if
--              | | | | | |-tx_csum_partial_calc_if
--              | | | | |-tx_full_csum_if
--              | | | |-tx_vlan_if
--              | | |
--              | | |-tx_emac_if
--              | | |-tx_mem_if
--              | | | |-<BLK_MEM_GEN_WRAPPER>
--              | |
--              | |-bus_and_enable_clk_cross
--              |
--              |-axi_ethernet_soft_temac_wrap_v3_01_a {encrypted}
--              |
--              |-v6_temac_wrap
--              | |
--              | |-v6_emac_block_gmii
--              | | |
--              | | |-[IDELATCTRL]
--              | | |
--              | | |-reset_sync
--              | | | |-[FDPE]
--              | | |
--              | | |-[BUFGMUX]
--              | | |
--              | | |-gmii_if
--              | | | |-[ODDR]
--              | | | |-[IODELAY]
--              | | |
--              | | |-vector_decode
--              | | |
--              | | |-v6_emac_v2_2
--              | |   |-emac_wrapper
--              | |     |-fcs_blk
--              | |     |-pausereq_shim
--              | |     |-v6_rx_axi_intf
--              | |     |-v6_tx_axi_intf
--              | |     |-sync_reset
--              | |     |-v6_ipic_host_if
--              | |     |-ipic_mux
--              | |     |-statistics_core
--              | |     | |-[RAM64X1D]
--              | |     | |-pre_accumulator
--              | |     | | |-sync_block
--              | |     | |   |-[FD]
--              | |     | |
--              | |     | |-increment_controller
--              | |     | | |-sync_block
--              | |     | |   |-[FD]
--              | |     | |
--              | |     | |-[SRL16E]
--              | |     | |-sync_block
--              | |     | | |-[FD]
--              | |     |
--              | |     |-address_filter_wrap
--              | |     | |-address_filter
--              | |     | | |-address_compare
--              | |     | | | |-[RAM64X1D]
--              | |     | | |
--              | |     | | |-sync_block
--              | |     | | | |-[FD]
--              | |     | | |
--              | |     | | |-[RAM64X1D]
--              | |     | | |-[LUT3]
--              | |     | | |-[SRL16E]
--              | |     |
--              | |     |-[TEMAC_SINGLE]
--              | |
--              | |-v6_emac_block_mii
--              | | |-mii_if
--              | | | |-[BUFG]
--              | | |
--              | | |-vector_decode
--              | | |
--              | | |-v6_emac_v2_2
--              | |   |-emac_wrapper
--              | |     |-fcs_blk
--              | |     |-v6_rx_axi_intf
--              | |     |-v6_tx_axi_intf
--              | |     |-sync_reset
--              | |     |-v6_ipic_host_if
--              | |     |-ipic_mux
--              | |     |-statistics_core
--              | |     | |-[RAM64X1D]
--              | |     | |-pre_accumulator
--              | |     | | |-sync_block
--              | |     | |   |-[FD]
--              | |     | |
--              | |     | |-increment_controller
--              | |     | | |-sync_block
--              | |     | |   |-[FD]
--              | |     | |
--              | |     | |-[SRL16E]
--              | |     | |-sync_block
--              | |     | | |-[FD]
--              | |     |
--              | |     |-address_filter_wrap
--              | |     | |-address_filter
--              | |     | | |-address_compare
--              | |     | | | |-[RAM64X1D]
--              | |     | | |
--              | |     | | |-sync_block
--              | |     | | | |-[FD]
--              | |     | | |
--              | |     | | |-[RAM64X1D]
--              | |     | | |-[LUT3]
--              | |     | | |-[SRL16E]
--              | |     |
--              | |     |-[TEMAC_SINGLE]
--              | |
--              | |-v6_emac_block_rgmii
--              | | |-[IDELATCTRL]
--              | | |
--              | | |-reset_sync
--              | | | |-[FDPE]
--              | | |
--              | | |-[BUFG]
--              | | |
--              | | |-rgmii_v2_0_if
--              | | | |-[ODDR]
--              | | | |-[IODELAYE1]
--              | | | |-[BUFIO]
--              | | | |-[BUFR]
--              | | | |-[IDDR]
--              | | |
--              | | |-vector_decode
--              | | |
--              | | |-v6_emac_v2_2
--              | |   |-emac_wrapper
--              | |     |-fcs_blk
--              | |     |-v6_rx_axi_intf
--              | |     |-v6_tx_axi_intf
--              | |     |-sync_reset
--              | |     |-v6_ipic_host_if
--              | |     |-ipic_mux
--              | |     |-statistics_core
--              | |     | |-[RAM64X1D]
--              | |     | |-pre_accumulator
--              | |     | | |-sync_block
--              | |     | |   |-[FD]
--              | |     | |
--              | |     | |-increment_controller
--              | |     | | |-sync_block
--              | |     | |   |-[FD]
--              | |     | |
--              | |     | |-[SRL16E]
--              | |     | |-sync_block
--              | |     | | |-[FD]
--              | |     |
--              | |     |-address_filter_wrap
--              | |     | |-address_filter
--              | |     | | |-address_compare
--              | |     | | | |-[RAM64X1D]
--              | |     | | |
--              | |     | | |-sync_block
--              | |     | | | |-[FD]
--              | |     | | |
--              | |     | | |-[RAM64X1D]
--              | |     | | |-[LUT3]
--              | |     | | |-[SRL16E]
--              | |     |
--              | |     |-[TEMAC_SINGLE]
--              | |
--              | |-v6_emac_block_sgmii
--              | | |
--              | | |-reset_sync
--              | | | |-[FDPE]
--              | | |
--              | | |-[BUFG]
--              | | |
--              | | |-v6_gtxwizard_top_sgmii
--              | | | |-[BUFR]
--              | | | |-rx_elastic_buffer
--              | | | | |-[RAM64X1D]
--              | | | |
--              | | | |-v6_gtxwiard_sgmii
--              | | |   |-v6_gtxwiard_gtx_sgmii
--              | | |   | |-[GTXE1]
--              | | |   |
--              | | |   |- double_reset
--              | | |
--              | | |-vector_decode
--              | | |
--              | | |-v6_emac_v2_2
--              | |   |-emac_wrapper
--              | |     |-fcs_blk
--              | |     |-v6_rx_axi_intf
--              | |     |-v6_tx_axi_intf
--              | |     |-sync_reset
--              | |     |-v6_ipic_host_if
--              | |     |-ipic_mux
--              | |     |-statistics_core
--              | |     | |-[RAM64X1D]
--              | |     | |-pre_accumulator
--              | |     | | |-sync_block
--              | |     | |   |-[FD]
--              | |     | |
--              | |     | |-increment_controller
--              | |     | | |-sync_block
--              | |     | |   |-[FD]
--              | |     | |
--              | |     | |-[SRL16E]
--              | |     | |-sync_block
--              | |     | | |-[FD]
--              | |     |
--              | |     |-address_filter_wrap
--              | |     | |-address_filter
--              | |     | | |-address_compare
--              | |     | | | |-[RAM64X1D]
--              | |     | | |
--              | |     | | |-sync_block
--              | |     | | | |-[FD]
--              | |     | | |
--              | |     | | |-[RAM64X1D]
--              | |     | | |-[LUT3]
--              | |     | | |-[SRL16E]
--              | |     |
--              | |     |-[TEMAC_SINGLE]
--              | |
--              | |-v6_emac_block_1000bx
--              |   |
--              |   |-reset_sync
--              |   | |-[FDPE]
--              |   |
--              |   |-v6_gtxwizard_top_1000bx
--              |   | |-[BUFR]
--              |   | |-v6_gtxwiard_1000bx
--              |   |   |-v6_gtxwiard_gtx_1000bx
--              |   |   | |-[GTXE1]
--              |   |   |
--              |   |   |- double_reset
--              |   |
--              |   |-vector_decode
--              |   |
--              |   |-v6_emac_v2_2
--              |     |-emac_wrapper
--              |       |-fcs_blk
--              |       |-v6_rx_axi_intf
--              |       |-v6_tx_axi_intf
--              |       |-sync_reset
--              |       |-v6_ipic_host_if
--              |       |-ipic_mux
--              |       |-statistics_core
--              |       | |-[RAM64X1D]
--              |       | |-pre_accumulator
--              |       | | |-sync_block
--              |       | |   |-[FD]
--              |       | |
--              |       | |-increment_controller
--              |       | | |-sync_block
--              |       | |   |-[FD]
--              |       | |
--              |       | |-[SRL16E]
--              |       | |-sync_block
--              |       | | |-[FD]
--              |       |
--              |       |-address_filter_wrap
--              |       | |-address_filter
--              |       | | |-address_compare
--              |       | | | |-[RAM64X1D]
--              |       | | |
--              |       | | |-sync_block
--              |       | | | |-[FD]
--              |       | | |
--              |       | | |-[RAM64X1D]
--              |       | | |-[LUT3]
--              |       | | |-[SRL16E]
--              |       |
--              |       |-[TEMAC_SINGLE]
--              |
--              |-axi_ethernet_pcs_pma_wrap_v3_01_a {encrypted}
--
--
-------------------------------------------------------------------------------
-- Author:          MSH & MW
-- History:
--  MSH & MW     07/01/10    v1_00_a
-- ^^^^^^
--  - Initial Release
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

library unisim;
use unisim.vcomponents.all;

library proc_common_v3_00_a;
-- SLV64_ARRAY_TYPE refered from ipif_pkg
use proc_common_v3_00_a.ipif_pkg.SLV64_ARRAY_TYPE;
-- INTEGER_ARRAY_TYPE refered from ipif_pkg
use proc_common_v3_00_a.ipif_pkg.INTEGER_ARRAY_TYPE;
-- calc_num_ce comoponent refered from ipif_pkg
use proc_common_v3_00_a.ipif_pkg.calc_num_ce;
use proc_common_v3_00_a.family_support.all;

library axi_lite_ipif_v1_01_a;
-- axi_lite_ipif refered from axi_lite_ipif_v1_01_a
use axi_lite_ipif_v1_01_a.axi_lite_ipif;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

library axi_ethernet_soft_temac_wrap_v3_01_a;
use axi_ethernet_soft_temac_wrap_v3_01_a.device_support.all;
use axi_ethernet_soft_temac_wrap_v3_01_a.all;

library axi_ethernet_pcs_pma_wrap_v3_01_a;
use axi_ethernet_pcs_pma_wrap_v3_01_a.all;

-------------------------------------------------------------------------------
-- Definition of Generics :
-------------------------------------------------------------------------------
-- System generics
--  C_FAMILY              -- Xilinx FPGA Family
--  C_S_AXI_ACLK_FREQ_HZ    -- System clock frequency driving Ethernet
--                           peripheral in Hz
-- AXI generics
--  C_S_AXI_ADDR_WIDTH     -- Width of AXI Address Bus (in bits) 32
--  C_S_AXI_DATA_WIDTH     -- Width of the AXI Data Bus (in bits) 32
--
-- Ethernet generics
--  C_TRANS               -- for spartan 6 soft TEMAC MGTs "A" or "B"
--  C_PHYADDR             -- Base address of PHY registers internal to TEMAC
--  C_INCLUDE_IO          -- Enable I/O components
--  C_TYPE
--     0  Soft TEMAC capable of 10 or 100 Mbps
--     1  Soft TEMAC capable of 10, 100, or 1000 Mbps
--     2  V6 hard TEMAC capable of 10, 100, or 1000 Mbps
--  C_PHY_TYPE
--     0  MII
--     1  GMII
--     2  RGMII V1.3
--     3  RGMII V2.0
--     4  SGMII
--     5  1000Base-X PCS/PMA @ 1 Gbps
--     6  1000Base-X PCS/PMA @ 2 Gbps (C_TYPE=2 only)
--     7  1000Base-X PCS/PMA @ 2.5 Gbps (C_TYPE=2 only)
--  C_HALFDUP             -- Enable half duplex
--  C_TXMEM               -- Depth of TX memory in Bytes
--  C_RXMEM               -- Depth of RX memory in Bytes
--  C_TXCSUM
--     0  No checksum offloading
--     1  Partial (legacy) checksum offloading
--     2  Full checksum offloading
--  C_RXCSUM
--     0  No checksum offloading
--     1  Partial (legacy) checksum offloading
--     2  Full checksum offloading
--  C_TXVLAN_TRAN         -- Enable TX enhanced VLAN translation
--  C_RXVLAN_TRAN         -- Enable RX enhanced VLAN translation
--  C_TXVLAN_TAG          -- Enable TX enhanced VLAN taging
--  C_RXVLAN_TAG          -- Enable RX enhanced VLAN taging
--  C_TXVLAN_STRP         -- Enable TX enhanced VLAN striping
--  C_RXVLAN_STRP         -- Enable RX enhanced VLAN striping
--  C_MCAST_EXTEND        -- Enable RX extended multicast address filtering
--  C_STATS               -- Enable statistics gathering
--  C_AVB                 -- Enable AVB functionality

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Ports :
-------------------------------------------------------------------------------
--System signals
-- S_AXI_ACLK            -- AXI Clock
-- S_AXI_ARESETN         -- AXI Reset
-- INTERRUPT             -- Ethernet INTERRUPT
--AXI Lite signals
-- S_AXI_AWADDR          -- AXI Write address
-- S_AXI_AWVALID         -- Write address valid
-- S_AXI_AWREADY         -- Write address ready
-- S_AXI_WDATA           -- Write data
-- S_AXI_WSTRB           -- Write strobes
-- S_AXI_WVALID          -- Write valid
-- S_AXI_WREADY          -- Write ready
-- S_AXI_BRESP           -- Write response
-- S_AXI_BVALID          -- Write response valid
-- S_AXI_BREADY          -- Response ready
-- S_AXI_ARADDR          -- Read address
-- S_AXI_ARVALID         -- Read address valid
-- S_AXI_ARREADY         -- Read address ready
-- S_AXI_RDATA           -- Read data
-- S_AXI_RRESP           -- Read response
-- S_AXI_RVALID          -- Read valid
-- S_AXI_RREADY          -- Read ready
--Ethernet Interface Signals
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--                  Entity Section
-------------------------------------------------------------------------------

entity axi_ethernet is
  generic (
    --  System Generics
    C_FAMILY               : string                        := "virtex6";
    C_DEVICE               : string                        := "xc7z010";
    C_INSTANCE             : string                        :=  "axi_ethernet";
    C_S_AXI_ACLK_FREQ_HZ   : INTEGER                       := 100000000;
    --  Frequency of the AXI clock in Hertz auto computed by the tools
    C_S_AXI_ADDR_WIDTH     : integer range 32 to 32        := 32;
    C_S_AXI_DATA_WIDTH     : integer range 32 to 32        := 32;
    C_S_AXI_ID_WIDTH       : INTEGER range 1 to 16          := 16;
    -- auto computed by the tools
    --  Ethernet Generics
    C_TRANS               : string                        := "A";
    -- applies only to Spartan 6 MGT designs
    C_PHYADDR             : std_logic_vector(4 downto 0)  := "00001";
    C_INCLUDE_IO          : integer range 0 to 1          := 1;
    C_TYPE                : integer range 0 to 2          := 0;
      -- 0 - Soft TEMAC capable of 10 or 100 Mbps
      -- 1 - Soft TEMAC capable of 10, 100, or 1000 Mbps
      -- 2 - V6 hard TEMAC
    C_PHY_TYPE            : integer range 0 to 5          := 1;
      -- 0 - MII
      -- 1 - GMII
      -- 2 - RGMII V1.3 NO LONGER ALLOWED FOR ANY CONFIGURATION
      -- 3 - RGMII V2.0
      -- 4 - SGMII
      -- 5 - 1000Base-X PCS/PMA @ 1 Gbps
    C_USE_GTH             : integer range 0 to 1          := 0;
    C_HALFDUP             : integer range 0 to 1          := 0;
    C_TXMEM               : integer                       := 4096;
    C_RXMEM               : integer                       := 4096;
    C_TXCSUM              : integer range 0 to 2          := 0;
      -- 0 - No checksum offloading
      -- 1 - Partial (legacy) checksum offloading
      -- 2 - Full checksum offloading
    C_RXCSUM              : integer range 0 to 2          := 0;
      -- 0 - No checksum offloading
      -- 1 - Partial (legacy) checksum offloading
      -- 2 - Full checksum offloading
    C_TXVLAN_TRAN         : integer range 0 to 1          := 0;
    C_RXVLAN_TRAN         : integer range 0 to 1          := 0;
    C_TXVLAN_TAG          : integer range 0 to 1          := 0;
    C_RXVLAN_TAG          : integer range 0 to 1          := 0;
    C_TXVLAN_STRP         : integer range 0 to 1          := 0;
    C_RXVLAN_STRP         : integer range 0 to 1          := 0;
    C_MCAST_EXTEND        : integer range 0 to 1          := 0;
    C_STATS               : integer range 0 to 1          := 0;
    C_AVB                 : integer range 0 to 1          := 0;
    C_SIMULATION          : integer                       := 0;
    C_STATS_WIDTH         : integer range 32 to 64        := 64
  );
  port (
    -- System signals ---------------------------------------------------------
    S_AXI_ACLK               : in  std_logic;                           --  AXI4-Lite Clk
    S_AXI_ARESETN            : in  std_logic;                           --  AXI4-Lite reset
    INTERRUPT                : out std_logic;                           --  AXI Ethernet Interrupt

    -- AXI Lite signals
    S_AXI_AWADDR             : in  std_logic_vector                     --  AXI4-Lite Write Addr
                               (C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWVALID            : in  std_logic;                           --  AXI4-Lite Write Addr Valid
    S_AXI_AWREADY            : out std_logic;                           --  AXI4-Lite Write Addr Ready
    S_AXI_WDATA              : in  std_logic_vector                     --  AXI4-Lite Write Data
                               (C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB              : in  std_logic_vector                     --  AXI4-Lite Write Strobe
                               ((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID             : in  std_logic;                           --  AXI4-Lite Write Valid
    S_AXI_WREADY             : out std_logic;                           --  AXI4-Lite Write Ready
    S_AXI_BRESP              : out std_logic_vector(1 downto 0);        --  AXI4-Lite Write Response
    S_AXI_BVALID             : out std_logic;                           --  AXI4-Lite Write Response Valid
    S_AXI_BREADY             : in  std_logic;                           --  AXI4-Lite Write Response Ready
    S_AXI_ARADDR             : in  std_logic_vector                     --  AXI4-Lite Read Addr
                               (C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARVALID            : in  std_logic;                           --  AXI4-Lite Read Addr Valid
    S_AXI_ARREADY            : out std_logic;                           --  AXI4-Lite Read Addr Ready
    S_AXI_RDATA              : out std_logic_vector                     --  AXI4-Lite Read Data
                               (C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP              : out std_logic_vector(1 downto 0);        --  AXI4-Lite Read Response
    S_AXI_RVALID             : out std_logic;                           --  AXI4-Lite Read Valid
    S_AXI_RREADY             : in  std_logic;                           --  AXI4-Lite Read Ready

    -- AXI Stream signals
    AXI_STR_TXD_ACLK         : in  std_logic;                           --  AXI-Stream Transmit Data Clk
    AXI_STR_TXD_ARESETN      : in  std_logic;                           --  AXI-Stream Transmit Data Reset
    AXI_STR_TXD_TVALID       : in  std_logic;                           --  AXI-Stream Transmit Data Valid
    AXI_STR_TXD_TREADY       : out std_logic;                           --  AXI-Stream Transmit Data Ready
    AXI_STR_TXD_TLAST        : in  std_logic;                           --  AXI-Stream Transmit Data Last
    AXI_STR_TXD_TKEEP        : in  std_logic_vector(3 downto 0);        --  AXI-Stream Transmit Data Keep
    AXI_STR_TXD_TDATA        : in  std_logic_vector(31 downto 0);       --  AXI-Stream Transmit Data Data

    AXI_STR_TXC_ACLK         : in  std_logic;                           --  AXI-Stream Transmit Control Clk
    AXI_STR_TXC_ARESETN      : in  std_logic;                           --  AXI-Stream Transmit Control Reset
    AXI_STR_TXC_TVALID       : in  std_logic;                           --  AXI-Stream Transmit Control Valid
    AXI_STR_TXC_TREADY       : out std_logic;                           --  AXI-Stream Transmit Control Ready
    AXI_STR_TXC_TLAST        : in  std_logic;                           --  AXI-Stream Transmit Control Last
    AXI_STR_TXC_TKEEP        : in  std_logic_vector(3 downto 0);        --  AXI-Stream Transmit Control Keep
    AXI_STR_TXC_TDATA        : in  std_logic_vector(31 downto 0);       --  AXI-Stream Transmit Control Data

    AXI_STR_RXD_ACLK         : in  std_logic;                           --  AXI-Stream Receive Data Clk
    AXI_STR_RXD_ARESETN      : in  std_logic;                           --  AXI-Stream Receive Data Reset
    AXI_STR_RXD_TVALID       : out std_logic;                           --  AXI-Stream Receive Data Valid
    AXI_STR_RXD_TREADY       : in  std_logic;                           --  AXI-Stream Receive Data Ready
    AXI_STR_RXD_TLAST        : out std_logic;                           --  AXI-Stream Receive Data Last
    AXI_STR_RXD_TKEEP        : out std_logic_vector(3 downto 0);        --  AXI-Stream Receive Data Keep
    AXI_STR_RXD_TDATA        : out std_logic_vector(31 downto 0);       --  AXI-Stream Receive Data Data

    AXI_STR_RXS_ACLK         : in  std_logic;                           --  AXI-Stream Receive Status Clk
    AXI_STR_RXS_ARESETN      : in  std_logic;                           --  AXI-Stream Receive Status Reset
    AXI_STR_RXS_TVALID       : out std_logic;                           --  AXI-Stream Receive Status Valid
    AXI_STR_RXS_TREADY       : in  std_logic;                           --  AXI-Stream Receive Status Ready
    AXI_STR_RXS_TLAST        : out std_logic;                           --  AXI-Stream Receive Status Last
    AXI_STR_RXS_TKEEP        : out std_logic_vector(3 downto 0);        --  AXI-Stream Receive Status Keep
    AXI_STR_RXS_TDATA        : out std_logic_vector(31 downto 0);       --  AXI-Stream Receive Status Data

    -- Ethernet System signals ------------------------------------------------
    PHY_RST_N                : out std_logic;                           --  PHY Reset

    -- GTX_CLK 125 MHz clock
    GTX_CLK                  : in  std_logic;                           --  GTX_CLK

    -- SGMII MGT clock
    MGT_CLK_P                : in  std_logic;                           --  MGT Differential Clock
    MGT_CLK_N                : in  std_logic;                           --  MGT Differential Clock

    -- Reference 200 MHz clock for IODELAYs                             --  Reference Clock
    REF_CLK                  : in  std_logic;

    -- MII signals ----------------------------------------------------------
    MII_COL                  : in  std_logic;                           --  MII Collision - Half Duplex Only
    MII_CRS                  : in  std_logic;                           --  MII Carrier Sense - Half Duplex Only
    MII_TXD                  : out std_logic_vector(3 downto 0);        --  MII Transmit Data
    MII_TX_EN                : out std_logic;                           --  MII Transmit Enable
    MII_TX_ER                : out std_logic;                           --  MII Transmit Error
    MII_RXD                  : in  std_logic_vector(3 downto 0);        --  MII Receive Data
    MII_RX_DV                : in  std_logic;                           --  MII Receive Data Valid
    MII_RX_ER                : in  std_logic;                           --  MII Receive Error
    MII_RX_CLK               : in  std_logic;                           --  MII Receive Clk
    MII_TX_CLK               : in  std_logic;                           --  MII Transmit Clk

    -- GMII signals ---------------------------------------------------------
    GMII_COL                 : in  std_logic;                           --  GMII Collision - Half Duplex Only
    GMII_CRS                 : in  std_logic;                           --  GMII Carrier Sense - Half Duplex Only
    GMII_TXD                 : out std_logic_vector(7 downto 0);        --  GMII Transmit Data
    GMII_TX_EN               : out std_logic;                           --  GMII Transmit Enable
    GMII_TX_ER               : out std_logic;                           --  GMII Transmit Error
    GMII_TX_CLK              : out std_logic;                           --  GMII Transmit Clk
    GMII_RXD                 : in  std_logic_vector(7 downto 0);        --  GMII Receive Data
    GMII_RX_DV               : in  std_logic;                           --  GMII Receive Data Valid
    GMII_RX_ER               : in  std_logic;                           --  GMII Receive Error
    GMII_RX_CLK              : in  std_logic;                           --  GMII Receive Clk

    -- SGMII & 1000BASE_X signals -------------------------------------------
    TXP                      : out std_logic;                           --  MGT Transmit Differential Pair
    TXN                      : out std_logic;                           --  MGT Transmit Differential Pair
    RXP                      : in  std_logic;                           --  MGT Receive Differential Pair
    RXN                      : in  std_logic;                           --  MGT Receive Differential Pair

    -- RGMII signals --------------------------------------------------------
    RGMII_TXD                : out std_logic_vector(3 downto 0);        --  RGMII Transmit Data
    RGMII_TX_CTL             : out std_logic;                           --  RGMII Transmit Control
    RGMII_TXC                : out std_logic;                           --  RGMII Transmit Clk
    RGMII_RXD                : in  std_logic_vector(3 downto 0);        --  RGMII Receive Data
    RGMII_RX_CTL             : in  std_logic;                           --  RGMII Receive Control
    RGMII_RXC                : in  std_logic;                           --  RGMII Receive Clk

    -- MIIM signals ---------------------------------------------------------
    MDC                      : out std_logic;                           --  MDIO Clk
    MDIO_I                   : in  std_logic;                           --  MDIO Input
    MDIO_O                   : out std_logic;                           --  MDIO Output
    MDIO_T                   : out std_logic;                           --  MDIO Tri-State En

    -- AVB signals -----------------------------------------------------------
    AXI_STR_AVBTX_ACLK       : out std_logic;                           --  AXI-Stream Transmit AVB Clk
    AXI_STR_AVBTX_ARESETN    : in  std_logic;                           --  AXI-Stream Transmit AVB Reset
    AXI_STR_AVBTX_TVALID     : in  std_logic;                           --  AXI-Stream Transmit AVB Valid
    AXI_STR_AVBTX_TREADY     : out std_logic;                           --  AXI-Stream Transmit AVB Ready
    AXI_STR_AVBTX_TLAST      : in  std_logic;                           --  AXI-Stream Transmit AVB Last
    AXI_STR_AVBTX_TDATA      : in  std_logic_vector(7 downto 0);        --  AXI-Stream Transmit AVB Data
    AXI_STR_AVBTX_TUSER      : in  std_logic_vector(0 downto 0);        --  AXI-Stream Transmit AVB User

    AXI_STR_AVBRX_ACLK       : out std_logic;                           --  AXI-Stream Receive AVB Clk
    AXI_STR_AVBRX_ARESETN    : in  std_logic;                           --  AXI-Stream Receive AVB Reset
    AXI_STR_AVBRX_TVALID     : out std_logic;                           --  AXI-Stream Receive AVB Valid
    AXI_STR_AVBRX_TLAST      : out std_logic;                           --  AXI-Stream Receive AVB Last
    AXI_STR_AVBRX_TDATA      : out std_logic_vector(7 downto 0);        --  AXI-Stream Receive AVB Data
    AXI_STR_AVBRX_TUSER      : out std_logic_vector(0 downto 0);        --  AXI-Stream Receive AVB User

    RTC_CLK                  : in  std_logic;                           --  AVB Real Time Clock

    AV_INTERRUPT_10MS        : out std_logic;                           --  AVB 10ms Interrupt
    AV_INTERRUPT_PTP_TX      : out std_logic;                           --  AVB Transmit Precise Time Protocol Interrupt
    AV_INTERRUPT_PTP_RX      : out std_logic;                           --  AVB Receive Precise Time Protocol Interrupt

    AV_RTC_NANOSECFIELD      : out std_logic_vector(31 downto 0);       --  AVB Real Time Clock Nano-second Field
    AV_RTC_SECFIELD          : out std_logic_vector(47 downto 0);       --  AVB Real Time Clock Second Field
    AV_CLK_8K                : out std_logic;                           --  AVB 8kHz clock
    AV_RTC_NANOSECFIELD_1722 : out std_logic_vector(31 downto 0)        --  AVB Real Time Clock in 1722 format

  );

  ----------------------------------------------------------------------------
  -- Attributes
  ----------------------------------------------------------------------------

  ----------------------------------------------------------------------------
  -- Fan-Out attributes for XST
  ----------------------------------------------------------------------------

  ATTRIBUTE MAX_FANOUT                  : string;
  ATTRIBUTE MAX_FANOUT  of S_AXI_ACLK    : signal is "10000";
  ATTRIBUTE MAX_FANOUT  of S_AXI_ARESETN  : signal is "10000";

  -----------------------------------------------------------------
  -- Start of PSFUtil MPD attributes
  -----------------------------------------------------------------
  attribute IP_GROUP                            : string;
  attribute IP_GROUP     of axi_ethernet        : entity   is "LOGICORE";

  attribute IPTYPE                              : string;
  attribute IPTYPE       of axi_ethernet        : entity   is "PERIPHERAL";

  attribute RUN_NGCBUILD                        : string;
  attribute RUN_NGCBUILD of axi_ethernet        : entity   is "TRUE";

  attribute ALERT                               : string;
  attribute ALERT        of axi_ethernet        : entity   is
  "This design requires design constraints to guarantee performance. Refer to the axi_ethernet_v3_01_a data sheet for details.";

  -----------------------------------------------------------------
  -- End of PSFUtil MPD attributes
  -----------------------------------------------------------------

  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of axi_ethernet : entity is "axi_ethernet_v3_01_a, EDK 14.1";

end axi_ethernet;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture imp of axi_ethernet is

   function chr(sl: std_logic) return character is
    variable c: character;
    begin
      case sl is
         when 'U' => c:= 'U';
         when 'X' => c:= 'X';
         when '0' => c:= '0';
         when '1' => c:= '1';
         when 'Z' => c:= 'Z';
         when 'W' => c:= 'W';
         when 'L' => c:= 'L';
         when 'H' => c:= 'H';
         when '-' => c:= '-';
      end case;
    return c;
   end chr;

   function str(slv: std_logic_vector) return string is
     variable result : string (1 to slv'length);
     variable r : integer;
   begin
     r := 1;
     for i in slv'range loop
        result(r) := chr(slv(i));
        r := r + 1;
     end loop;
     return result;
   end str;



   
   constant C_CORE_GENERATION_INFO : string := C_INSTANCE & ",axi_ethernet,{"
      & "c_instance="                  & C_INSTANCE
      & ",c_device="                   & C_DEVICE
      & ",c_family="                   & C_FAMILY
      & ",c_s_axi_aclk_freq_hz="       & integer'image(C_S_AXI_ACLK_FREQ_HZ)
      & ",c_s_axi_addr_width="         & integer'image(C_S_AXI_ADDR_WIDTH)
      & ",c_s_axi_data_width="         & integer'image(C_S_AXI_DATA_WIDTH)
      & ",c_s_axi_id_width="           & integer'image(C_S_AXI_ID_WIDTH)
      & ",c_trans="                    & C_TRANS
      & ",c_phyaddr="                  & str(C_PHYADDR)
      & ",c_include_io="               & integer'image(C_INCLUDE_IO)
      & ",c_type="                     & integer'image(C_TYPE)
      & ",c_phy_type="                 & integer'image(C_PHY_TYPE)
     & ",c_use_gth="                   & integer'image(C_USE_GTH)
      & ",c_halfdup="                  & integer'image(C_HALFDUP)
      & ",c_txmem="                    & integer'image(C_TXMEM)
      & ",c_rxmem="                    & integer'image(C_RXMEM)
      & ",c_txcsum="                   & integer'image(C_TXCSUM)
      & ",c_rxcsum="                   & integer'image(C_RXCSUM)
      & ",c_txvlan_tran="              & integer'image(C_TXVLAN_TRAN)
      & ",c_rxvlan_tran="              & integer'image(C_RXVLAN_TRAN)
      & ",c_txvlan_tag="               & integer'image(C_TXVLAN_TAG)
      & ",c_rxvlan_tag="               & integer'image(C_RXVLAN_TAG)
      & ",c_txvlan_strp="              & integer'image(C_TXVLAN_STRP)
      & ",c_rxvlan_strp="              & integer'image(C_RXVLAN_STRP)
      & ",c_mcast_extend="             & integer'image(C_MCAST_EXTEND)
      & ",c_stats="                    & integer'image(C_STATS)
      & ",c_avb="                      & integer'image(C_AVB)
      & ",c_simulation="               & integer'image(C_SIMULATION)
      & ",c_stats_width="              & integer'image(C_STATS_WIDTH)
      & "}";

 attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of imp : architecture is C_CORE_GENERATION_INFO;

  component axi_ethernet_v3_01_a_tx_axi_intf
    port (
      tx_clk          : in  std_logic;                        --  Transmit Clk
      tx_reset        : in  std_logic;                        --  Transmit reset
      tx_enable       : in  std_logic;                        --  Transmit enable
      --------------------------------------------------------------------
      -- AXI Interface
      --------------------------------------------------------------------
      tx_mac_tdata    : in  std_logic_vector(7 downto 0);     --  Transmit Data from AXI-Stream
      tx_mac_tvalid   : in  std_logic;                        --  Transmit VALID from AXI-Stream
      tx_mac_tlast    : in  std_logic;                        --  Transmit Last from AXI-Stream
      tx_mac_tuser    : in  std_logic;                        --  Transmit User from AXI-Stream
      tx_mac_tready   : out std_logic;                        --  Transmit Ready to AXI-Stream
      --------------------------------------------------------------------
      -- Ethernet MAC TX Client Interface
      --------------------------------------------------------------------
      tx_enable_out   : out std_logic;                        --  Transmit Enable Out
      tx_continuation : out std_logic;                        --  Transmit Continuation
      tx_data         : out std_logic_vector(7 downto 0);     --  Transmit Data
      tx_data_valid   : out std_logic;                        --  Transmit Data Valid
      tx_underrun     : out std_logic;                        --  Transmit Underrun
      tx_ack          : in  std_logic                         --  Transmit Acknowledge
    );
  end component;

  component axi_ethernet_v3_01_a_rx_axi_intf
    generic (
      c_at_entries : integer  := 8
    );
    port (
      rx_clk        : in  std_logic;                          --  Receive Clk
      rx_reset      : in  std_logic;                          --  Receive reset
      rx_enable     : in  std_logic;                          --  Receive enable
      --------------------------------------------------------------------
      -- Ethernet MAC RX Client Interface
      --------------------------------------------------------------------
      rx_data       : in  std_logic_vector(7 downto 0);       --  Receive Data from MAC
      rx_data_valid : in  std_logic;                          --  Receive Data Valid from MAC
      rx_good_frame : in  std_logic;                          --  Receive Good Frame from MAC
      rx_bad_frame  : in  std_logic;                          --  Receive Bad Frame from MAC
      --------------------------------------------------------------------
      -- Ethernet MAC RX Filter support
      --------------------------------------------------------------------
      rx_filter_match : in  std_logic_vector(c_at_entries downto 0);  --  Receive Filter Match
      rx_filter_tuser : out std_logic_vector(c_at_entries downto 0);  --  Receive Filter User
      --------------------------------------------------------------------
      -- AXI Interface
      --------------------------------------------------------------------
      rx_mac_tdata  : out std_logic_vector(7 downto 0);       --  Receive Data to AXI-Stream
      rx_mac_tvalid : out std_logic;                          --  Receive Valid to AXI-Stream
      rx_mac_tlast  : out std_logic;                          --  Receive Last to AXI-Stream
      rx_mac_tuser  : out std_logic                           --  Receive User to AXI-Stream
    );
  end component;

  constant C_SOFT_SIMULATION     : boolean := (C_SIMULATION = 1);
  constant C_FAMILY_ROOT         : string  := get_root_family(C_FAMILY);
  constant C_HAS_STATS           : boolean := (C_STATS = 1);
  constant C_HAS_AVB             : boolean := (C_AVB = 1);

  constant C_AT_ENTRIES          : integer := 4;


  ---------------------------------------------------------------------------
  -- Signal declarations
  ---------------------------------------------------------------------------
  signal bus2ip_clk                   : std_logic;
  signal bus2ip_reset                 : std_logic;

  signal shim2ip_data                 : std_logic_vector(0 to C_S_AXI_DATA_WIDTH - 1 );
  signal shim2ip_addr                 : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH - 1 );
  signal shim2ip_r_nw                 : std_logic;
  signal shim2temac_cs               : std_logic;
  signal shim2temac_rd_ce            : std_logic;
  signal shim2temac_wr_ce            : std_logic;
  signal temac2bus_wr_ack            : std_logic;
  signal temac2bus_rd_ack            : std_logic;
  signal temac2bus_data              : std_logic_vector(0 to C_S_AXI_DATA_WIDTH - 1 );
  signal temac2bus_error             : std_logic;

  signal shim2avb_cs               : std_logic;
  signal shim2avb_rd_ce            : std_logic;
  signal shim2avb_wr_ce            : std_logic;
  signal avb2bus_wr_ack            : std_logic;
  signal avb2bus_rd_ack            : std_logic;
  signal avb2bus_data              : std_logic_vector(0 to C_S_AXI_DATA_WIDTH - 1 ) := (others => '0');
  signal avb2bus_error             : std_logic;

  signal emac_client_autoneg_int         : std_logic;
  signal emac_reset_done_int             : std_logic;
  signal emac_rx_dcm_locked_int          : std_logic;




  signal emac_client_tx_stats            : std_logic;
  signal emac_client_tx_stats_byte_vld   : std_logic;


  signal tx_client_clk                   : std_logic;
  signal rx_dcm_locked                   : std_logic;
  signal rx_client_clk_enbl              : std_logic;
  signal tx_client_clk_enbl              : std_logic;
--  signal tx_client_clk_enbl_legacy       : std_logic;

  signal emac_client_rxd_vld_2stats      : std_logic;
  signal mdc_i                           : std_logic;
  signal mdio_o_i                        : std_logic;
  signal mdio_i_i                        : std_logic;
  signal mdio_t_i                        : std_logic;
  signal pcspma_gtclkout                 : std_logic;
  signal pcspma_gtpresetin               : std_logic;
  signal pcspma_gmii_txd                 : std_logic_vector(7 downto 0);
  signal pcspma_gmii_tx_en               : std_logic;
  signal pcspma_gmii_tx_er               : std_logic;
  signal pcspma_gmii_rxd                 : std_logic_vector(7 downto 0);
  signal pcspma_gmii_rx_dv               : std_logic;
  signal pcspma_gmii_rx_er               : std_logic;
  signal pcspma_mdio_o                   : std_logic;
  signal pcspma_mdio_t                   : std_logic;
  signal speed_is_10_100                 : std_logic;
  signal speed_is_100                    : std_logic;
  signal pcspma_clkin                    : std_logic;
  signal pcspma_userclk                  : std_logic; -- V7/K7 PCS PMA
  signal pcspma_userclk2                 : std_logic;
  signal pcspma_txp0                     : std_logic;
  signal pcspma_txn0                     : std_logic;
  signal pcspma_rxp0                     : std_logic;
  signal pcspma_rxn0                     : std_logic;
  signal pcspma_txp1                     : std_logic;
  signal pcspma_txn1                     : std_logic;
  signal pcspma_rxp1                     : std_logic;
  signal pcspma_rxn1                     : std_logic;
  signal gmii_txd_i                      : std_logic_vector(7 downto 0);
  signal gmii_tx_en_i                    : std_logic;
  signal gmii_tx_er_i                    : std_logic;
  signal gmii_rxd_i                      : std_logic_vector(7 downto 0);
  signal gmii_rx_dv_i                    : std_logic;
  signal gmii_rx_er_i                    : std_logic;
  signal gmii_rx_clk_i                   : std_logic;
  signal gmii_tx_clk_i                   : std_logic;
  signal core_has_sgmii                  : std_logic;

  signal host2TEMAC_opcode     : std_logic_vector(1 downto 0);
  signal host2TEMAC_addr       : std_logic_vector(9 downto 0);
  signal host2TEMAC_wr_data    : std_logic_vector(31 downto 0);
  signal host2TEMAC_req        : std_logic;
  signal host2TEMAC_miim_sel   : std_logic;
  signal temac2host_rd_data  : std_logic_vector(31 downto 0);
  signal stats2host_rd_data  : std_logic_vector(31 downto 0);
  signal temac2host_miim_rdy : std_logic;
  signal stats2host_lsw_rdy  : std_logic;
  signal stats2host_msw_rdy  : std_logic;

  signal reset2temac         : std_logic;
  signal reset2temac_n       : std_logic;

  signal axi_str_avbtx_areset : std_logic;
  signal axi_str_avbrx_areset : std_logic;
  signal tx_client_clk_enbl_avb_out : std_logic;

  signal pcspma_status_vector : std_logic_vector(15 downto 0);

  signal pcspma_sgmii_clk_en  : std_logic;
  signal clk_enable           : std_logic;
  signal gtx_clk_in          : std_logic;


--  ******************************************
  signal pause_req            : std_logic;                              --client_emac_pause_req
  signal pause_val            : std_logic_vector(16 to 31);             --tx_pause_reg_data

  signal rx_clk_enable_out    : std_logic;
  signal rx_statistics_vector : std_logic_vector(27 downto 0);
  signal rx_statistics_valid  : std_logic;

  signal from_temac_rx_mac_aclk          : std_logic;
  signal from_temac_rx_reset             : std_logic;
  signal from_temac_rx_axis_mac_tdata    : std_logic_vector(7 downto 0);
  signal from_temac_rx_axis_mac_tvalid   : std_logic;
  signal from_temac_rx_axis_mac_tlast    : std_logic;
  signal from_temac_rx_axis_mac_tuser    : std_logic;

  signal to_embedded_top_rx_mac_aclk          : std_logic;
  signal to_embedded_top_rx_reset             : std_logic;
  signal to_embedded_top_rx_axis_mac_tdata    : std_logic_vector(7 downto 0);
  signal to_embedded_top_rx_axis_mac_tvalid   : std_logic;
  signal to_embedded_top_rx_axis_mac_tlast    : std_logic;
  signal to_embedded_top_rx_axis_mac_tuser    : std_logic;

 
  signal tx_ifg_delay         : std_logic_vector(24 to 31);             --ifgp_reg_data
  signal tx_statistics_vector : std_logic_vector(31 downto 0);
  signal tx_statistics_valid  : std_logic;

  signal tx_mac_aclk          : std_logic;
  signal tx_reset             : std_logic;
  signal tx_axis_mac_tdata    : std_logic_vector(7 downto 0);
  signal tx_axis_mac_tvalid   : std_logic;
  signal tx_axis_mac_tlast    : std_logic;
  signal tx_axis_mac_tuser    : std_logic;
  signal tx_axis_mac_tready   : std_logic;
  signal tx_collision         : std_logic;                                 --emac_client_tx_collision
  signal tx_retransmit        : std_logic;                                 --emac_client_tx_retransmit

 
 
  --  *********************************************
  -- added for avb connection 03/21/2011
  signal tx_avb_en_int            : std_logic;
  signal tx_avb_en                : std_logic;

  signal legacy_tx_data           : std_logic_vector(7 downto 0);
  signal legacy_tx_data_valid     : std_logic;
  signal legacy_tx_underrun       : std_logic;
  signal legacy_tx_ack            : std_logic;

  signal tx_avb_client_data       : std_logic_vector(7 downto 0);
  signal tx_avb_client_data_valid : std_logic;
  signal tx_avb_client_underrun   : std_logic;
  signal tx_avb_client_ack        : std_logic;


  signal tx_axis_mac_tready_int       : std_logic;                                 --emac_client_tx_collision
  signal tx_collision_int       : std_logic;                                 --emac_client_tx_collision
  signal tx_retransmit_int      : std_logic;                                 --emac_client_tx_retransmit

  signal rx_axis_filter_tuser : std_logic_vector(C_AT_ENTRIES downto 0);     -- from temac
  signal legacy_rx_filter_match : std_logic_vector(C_AT_ENTRIES-1 downto 0); -- from avb

  signal gtx_clk_or_pcspma_userclk2 :std_logic;
  signal gtx_clk_or_pcspma_userclk2_90 :std_logic;
  signal logic_1                : std_logic;
  signal logic_0                : std_logic;

  signal shim2temac_avb_cs : std_logic;
  signal shim2temac_avb_rd_ce : std_logic;
  signal shim2temac_avb_wr_ce : std_logic;
  signal shim2temac_avb_wr_ack : std_logic;
  signal shim2temac_avb_rd_ack : std_logic;
  signal shim2temac_avb_error : std_logic;
  signal rstdone          : std_logic;
  signal mac_irq          :std_logic;
  signal mmcm_locked            : std_logic;


  --  ***********************************_vector(7 downto 0)**********

begin


  logic_1         <= '1';
  logic_0         <= '0';
  temac2bus_error <= '0';

  AVB_CLKS : if(C_HAS_AVB = TRUE) generate
  begin
    AXI_STR_AVBTX_ACLK     <= tx_mac_aclk;
    AXI_STR_AVBRX_ACLK     <= from_temac_rx_mac_aclk;
  end generate AVB_CLKS;

   NO_AVB_CLKS : if(C_HAS_AVB = FALSE) generate
  begin
    AXI_STR_AVBTX_ACLK     <= '0';
    AXI_STR_AVBRX_ACLK     <= '0';
  end generate NO_AVB_CLKS;

   -- axi_str_avbtx_areset   <= not(AXI_STR_AVBTX_ARESETN) or not(emac_reset_done_int);
   -- axi_str_avbrx_areset   <= not(AXI_STR_AVBRX_ARESETN) or not(emac_reset_done_int);

    --tx_client_clk_enbl     <= tx_client_clk_enbl_avb_out;

    --tx_client_clk          <= tx_mac_aclk;


 
            
   
    --from MAC interface to embedded
    tx_collision_int       <= tx_collision;
    tx_retransmit_int      <= tx_retransmit;

    --from MAC interface to embedded
    to_embedded_top_rx_mac_aclk        <= from_temac_rx_mac_aclk;
    to_embedded_top_rx_reset           <= from_temac_rx_reset;
    to_embedded_top_rx_axis_mac_tdata  <= from_temac_rx_axis_mac_tdata;
    to_embedded_top_rx_axis_mac_tvalid <= from_temac_rx_axis_mac_tvalid;
    to_embedded_top_rx_axis_mac_tlast  <= from_temac_rx_axis_mac_tlast;
    to_embedded_top_rx_axis_mac_tuser  <= from_temac_rx_axis_mac_tuser;


  V6HARD_SYS: if(C_TYPE = 2 and (equalIgnoringCase(C_FAMILY_ROOT, "virtex6")= TRUE )) generate
  begin

    sftmc_avb_ipc: process (shim2temac_cs,shim2temac_rd_ce,
                shim2temac_wr_ce,temac2bus_wr_ack,temac2bus_rd_ack,
              temac2bus_error) begin
       shim2temac_avb_cs <= shim2temac_cs;
       shim2temac_avb_rd_ce <= shim2temac_rd_ce;
       shim2temac_avb_wr_ce <= shim2temac_wr_ce;
       shim2temac_avb_wr_ack <= temac2bus_wr_ack;
       shim2temac_avb_rd_ack <= temac2bus_rd_ack;
       shim2temac_avb_error  <= '0';
    end process sftmc_avb_ipc;

    I_TEMAC : entity axi_ethernet_v3_01_a.v6_temac_wrap(wrapper)
    generic map (
      C_PHY_TYPE              => C_PHY_TYPE,
      C_AT_ENTRIES            => C_AT_ENTRIES,
      C_HALFDUP               => C_HALFDUP,
      C_FAMILY                => C_FAMILY_ROOT,
      C_INCLUDE_IO            => C_INCLUDE_IO,
      C_HAS_STATS             => C_HAS_STATS,
      C_STATS_WIDTH           => C_STATS_WIDTH,
      C_TEMAC_PHYADDR         => C_PHYADDR
    )
   port map(
      gtx_clk                    => GTX_CLK,
      -- asynchronous reset
      RESET                      => reset2temac,

      -- Initial Unicast Address Value
--    unicast_address            => X"FFFF_FFFF_FFFF",  -- check this value

      -- Receiver Interface
      ----------------------------
      RX_CLK_ENABLE_OUT          =>  rx_clk_enable_out,
      rx_statistics_vector       => rx_statistics_vector,
      rx_statistics_valid        => rx_statistics_valid,
      rx_axis_filter_tuser       => rx_axis_filter_tuser,

      rx_mac_aclk                => from_temac_rx_mac_aclk,        --: out std_logic;
      rx_reset                   => from_temac_rx_reset,           --: out std_logic;
      rx_axis_mac_tdata          => from_temac_rx_axis_mac_tdata,  --: out std_logic_vector(7 downto 0);
      rx_axis_mac_tvalid         => from_temac_rx_axis_mac_tvalid, --: out std_logic;
      rx_axis_mac_tlast          => from_temac_rx_axis_mac_tlast,  --: out std_logic;
      rx_axis_mac_tuser          => from_temac_rx_axis_mac_tuser,  --: out std_logic;

      -- Transmitter Interface
      -------------------------------
      tx_ifg_delay               => tx_ifg_delay,
      tx_statistics_vector       => tx_statistics_vector,
      tx_statistics_valid        => tx_statistics_valid,

      tx_mac_aclk                => tx_mac_aclk,        --: out std_logic;
      tx_reset                   => tx_reset,           --: out std_logic;
      tx_axis_mac_tdata          => tx_axis_mac_tdata,  --: in  std_logic_vector(7 downto 0);
      tx_axis_mac_tvalid         => tx_axis_mac_tvalid, --: in  std_logic;
      tx_axis_mac_tlast          => tx_axis_mac_tlast,  --: in  std_logic;
      tx_axis_mac_tuser          => tx_axis_mac_tuser,
      tx_axis_mac_tready         => tx_axis_mac_tready_int, --: out std_logic;
      tx_collision               => tx_collision,       --: out std_logic;
      tx_retransmit              => tx_retransmit,      --: out std_logic;

      tx_avb_en                  => tx_avb_en,          -- added for avb connection 03/21/2011

      -- MAC Control Interface
      --------------------------
      pause_req                  => pause_req,
      pause_val                  => pause_val,

      -- Reference clock for IDELAYCTRL's
      refclk                     => REF_CLK,

      -- MII Interface
      -----------------
      mii_txd                    => MII_TXD,
      mii_tx_en                  => MII_TX_EN,
      mii_tx_er                  => MII_TX_ER,
      mii_rxd                    => MII_RXD,
      mii_rx_dv                  => MII_RX_DV,
      mii_rx_er                  => MII_RX_ER,
      mii_rx_clk                 => MII_RX_CLK,
      mii_col                    => logic_0,--MII_COL,   Half-Duplex is not supported
      mii_crs                    => logic_0,--MII_CRS,   Half-Duplex is not supported
      mii_tx_clk                 => MII_TX_CLK,

      -- GMII Interface
      -----------------
      gmii_txd                   => gmii_txd_i,
      gmii_tx_en                 => gmii_tx_en_i,
      gmii_tx_er                 => gmii_tx_er_i,
      gmii_rxd                   => GMII_RXD,
      gmii_rx_dv                 => GMII_RX_DV,
      gmii_rx_er                 => GMII_RX_ER,
      gmii_rx_clk                => GMII_RX_CLK,
      gmii_col                   => logic_0,--GMII_COL,   Half-Duplex is not supported,
      gmii_crs                   => logic_0,--GMII_CRS,   Half-Duplex is not supported,
      speedis10100               => open,
      gmii_tx_clk                => gmii_tx_clk_i,

      -- RGMII Interface
      --------------------
      rgmii_txd                  => RGMII_TXD,
      rgmii_tx_ctl               => RGMII_TX_CTL,
      rgmii_txc                  => RGMII_TXC,
      rgmii_rxd                  => RGMII_RXD,
      rgmii_rx_ctl               => RGMII_RX_CTL,
      rgmii_rxc                  => RGMII_RXC,

      -- MDIO Interface
      -------------------
      mdio_i                     => MDIO_I,
      mdio_o                     => MDIO_O,
      mdio_t                     => MDIO_T,
      mdc                        => MDC,

      -- IPIC Interface
      -----------------
      Bus2IP_Clk                 => bus2ip_clk,
      Bus2IP_Reset               => bus2ip_reset,
      Bus2IP_Addr                => shim2ip_addr,
      Bus2IP_CS                  => shim2temac_cs,
      Bus2IP_RdCE                => shim2temac_rd_ce,
      Bus2IP_WrCE                => shim2temac_wr_ce,
      Bus2IP_Data                => shim2ip_data,
      IP2Bus_Data                => temac2bus_data,
      IP2Bus_WrAck               => temac2bus_wr_ack,
      IP2Bus_RdAck               => temac2bus_rd_ack,
      IP2Bus_Error               => open,

      -- Speed Indicator
      speed_is_10_100            => speed_is_10_100,

      -- SGMII Interface
      TXP                        =>  TXP,
      TXN                        =>  TXN,
      RXP                        =>  RXP,
      RXN                        =>  RXN,

      EMACCLIENTANINTERRUPT      =>  emac_client_autoneg_int,
      EMACResetDoneInterrupt     =>  emac_reset_done_int,
      mac_irq                    =>  mac_irq,

      -- SGMII MGT Clock buffer inputs
      MGTCLK_P                   =>  MGT_CLK_P,
      MGTCLK_N                   =>  MGT_CLK_N
   );

    rx_dcm_locked             <= '1';
    emac_rx_dcm_locked_int    <= rx_dcm_locked;

  end generate V6HARD_SYS;

  reset2temac_n <= not reset2temac;

 
   

    
  SOFT_SYS: if(C_TYPE = 0 or C_TYPE = 1) generate
  begin

    emac_client_rxd_vld_2stats    <= '0';
    emac_rx_dcm_locked_int        <= '1'; -- DCM is not used so tie high instead --rx_dcm_locked;
    emac_client_tx_stats          <= '0';
    emac_client_tx_stats_byte_vld <= '0';

     sftmc_avb_ipc: process (shim2temac_cs,shim2avb_cs,shim2avb_rd_ce,shim2temac_rd_ce,
                shim2avb_wr_ce,shim2temac_wr_ce,temac2bus_wr_ack,temac2bus_rd_ack,
              avb2bus_rd_ack,temac2bus_error) begin
       shim2temac_avb_cs <= shim2temac_cs or  shim2avb_cs;
       shim2temac_avb_rd_ce <= shim2avb_rd_ce or  shim2temac_rd_ce;
       shim2temac_avb_wr_ce <= shim2avb_wr_ce or  shim2temac_wr_ce;
       shim2temac_avb_wr_ack <= temac2bus_wr_ack;
       shim2temac_avb_rd_ack <= temac2bus_rd_ack;
       shim2temac_avb_error  <= temac2bus_error;
    end process sftmc_avb_ipc;

    I_TEMAC : entity axi_ethernet_soft_temac_wrap_v3_01_a.axi_ethernet_soft_temac_wrap(wrapper)
    generic map (
      C_SAXI_CLK_FREQ_HZ      => C_S_AXI_ACLK_FREQ_HZ,
      C_TYPE                  => C_TYPE,
      C_PHY_TYPE              => C_PHY_TYPE,
      C_AT_ENTRIES            => C_AT_ENTRIES,
      C_HALFDUP               => C_HALFDUP,
      C_FAMILY                => C_FAMILY_ROOT,
      C_DEVICE                => C_DEVICE,
      C_AVB                   => C_HAS_AVB,
      C_INCLUDE_IO            => C_INCLUDE_IO,
      C_HAS_STATS             => C_HAS_STATS,
      C_STATS_WIDTH           => C_STATS_WIDTH,
      C_SIMULATION            => C_SOFT_SIMULATION
    )
   port map(
      gtx_clk                    => gtx_clk_or_pcspma_userclk2,--GTX_CLK, -when pcspma the GMII MAC uses userclk2 not gtx_clk
       gtx_clk90                    => gtx_clk_or_pcspma_userclk2_90,--GTX_CLK, -when pcspma the GMII MAC uses userclk2 not gtx_clk
      -- asynchronous reset
      glbl_rstn                  => reset2temac_n,
      rx_axi_rstn                => reset2temac_n,
      tx_axi_rstn                => reset2temac_n,

      -- Receiver Interface
      ----------------------------
      RX_CLK_ENABLE_OUT          => rx_clk_enable_out,
      rx_statistics_vector       => rx_statistics_vector,
      rx_statistics_valid        => rx_statistics_valid,
      rx_axis_filter_tuser       => rx_axis_filter_tuser,

      rx_mac_aclk                => from_temac_rx_mac_aclk,        --: out std_logic;
      rx_reset                   => from_temac_rx_reset,           --: out std_logic;
      rx_axis_mac_tdata          => from_temac_rx_axis_mac_tdata,  --: out std_logic_vector(7 downto 0);
      rx_axis_mac_tvalid         => from_temac_rx_axis_mac_tvalid, --: out std_logic;
      rx_axis_mac_tlast          => from_temac_rx_axis_mac_tlast,  --: out std_logic;
      rx_axis_mac_tuser          => from_temac_rx_axis_mac_tuser,  --: out std_logic;

      -- Transmitter Interface
      -------------------------------
      tx_ifg_delay               => tx_ifg_delay,
      tx_statistics_vector       => tx_statistics_vector,
      tx_statistics_valid        => tx_statistics_valid,

      tx_mac_aclk                => tx_mac_aclk,        --: out std_logic;
      tx_reset                   => tx_reset,           --: out std_logic;
      tx_axis_mac_tdata          => tx_axis_mac_tdata,  --: in  std_logic_vector(7 downto 0);
      tx_axis_mac_tvalid         => tx_axis_mac_tvalid, --: in  std_logic;
      tx_axis_mac_tlast          => tx_axis_mac_tlast,  --: in  std_logic;
      tx_axis_mac_tuser          => tx_axis_mac_tuser,  --: in  std_logic;
      tx_axis_mac_tready         => tx_axis_mac_tready_int, --: out std_logic;
      tx_collision               => tx_collision,       --: out std_logic;
      tx_retransmit              => tx_retransmit,      --: out std_logic;

      tx_avb_en                  => tx_avb_en_int,      -- added for avb connection 03/21/2011

            -- AVB AV interface
      -------------------------------
       
      tx_axis_av_tdata           => AXI_STR_AVBTX_TDATA,
      tx_axis_av_tvalid          => AXI_STR_AVBTX_TVALID,
      tx_axis_av_tlast           => AXI_STR_AVBTX_TLAST,
      tx_axis_av_tuser           => AXI_STR_AVBTX_TUSER(0),
      tx_axis_av_tready          => AXI_STR_AVBTX_TREADY,
      
    
      rx_axis_av_tdata           => AXI_STR_AVBRX_TDATA,
      rx_axis_av_tvalid          => AXI_STR_AVBRX_TVALID,
      rx_axis_av_tlast           => AXI_STR_AVBRX_TLAST,
      rx_axis_av_tuser           => AXI_STR_AVBRX_TUSER(0),
      
                -- AVB rtc interface
      --------------------------------
      rtc_nanosec_field          => AV_RTC_NANOSECFIELD,
      rtc_sec_field              => AV_RTC_SECFIELD,
      RTC_CLK                    => RTC_CLK,
 
      clk8k                      => AV_CLK_8K,
 
      rtc_nanosec_field_1722     => AV_RTC_NANOSECFIELD_1722,
      
      interrupt_ptp_timer        => AV_INTERRUPT_10MS,
      interrupt_ptp_rx           => AV_INTERRUPT_PTP_RX ,
      interrupt_ptp_tx           => AV_INTERRUPT_PTP_TX,



      -- MAC Control Interface
      --------------------------
      pause_req                  => pause_req,
      pause_val                  => pause_val,

      -- Reference clock for IDELAYCTRL's
      refclk                     => REF_CLK,

      -- MII Interface
      -----------------
      mii_txd                    => MII_TXD,
      mii_tx_en                  => MII_TX_EN,
      mii_tx_er                  => MII_TX_ER,
      mii_rxd                    => MII_RXD,
      mii_rx_dv                  => MII_RX_DV,
      mii_rx_er                  => MII_RX_ER,
      mii_rx_clk                 => MII_RX_CLK,
      mii_col                    => logic_0,--MII_COL,   Half-Duplex is not supported,
      mii_crs                    => logic_0,--MII_CRS,   Half-Duplex is not supported,
      mii_tx_clk                 => MII_TX_CLK,

      -- GMII Interface
      -----------------
      gmii_txd                   => gmii_txd_i,
      gmii_tx_en                 => gmii_tx_en_i,
      gmii_tx_er                 => gmii_tx_er_i,
      gmii_rxd                   => gmii_rxd_i,   --GMII_RXD,    -- switch in PCSPMA if needed
      gmii_rx_dv                 => gmii_rx_dv_i, --GMII_RX_DV,  -- switch in PCSPMA if needed
      gmii_rx_er                 => gmii_rx_er_i, --GMII_RX_ER,  -- switch in PCSPMA if needed
      gmii_rx_clk                => gmii_rx_clk_i,--GMII_RX_CLK, -- switch in PCSPMA if needed
      gmii_col                   => logic_0,--GMII_COL,   Half-Duplex is not supported,
      gmii_crs                   => logic_0,--GMII_CRS,   Half-Duplex is not supported,
      speedis100                 => speed_is_100,  --only driven from PCS PMA core
      speedis10100               => open,          --only driven from PCS PMA core, use speed_is_10_100 signal below
      gmii_tx_clk                => gmii_tx_clk_i,

      -- RGMII Interface
      --------------------
      rgmii_txd                  => RGMII_TXD,
      rgmii_tx_ctl               => RGMII_TX_CTL,
      rgmii_txc                  => RGMII_TXC,
      rgmii_rxd                  => RGMII_RXD,
      rgmii_rx_ctl               => RGMII_RX_CTL,
      rgmii_rxc                  => RGMII_RXC,

      -- RGMII Inband Status Registers
      ----------------------------------
      inband_link_status         => open,  --used on Spartan3 so NA
      inband_clock_speed         => open,  --used on Spartan3 so NA
      inband_duplex_status       => open,  --used on Spartan3 so NA

      -- PCS PMA Interface
      ------------------
      clk_enable                 => clk_enable,  --Connect to clk_enable from pcs/pma core
      pcspma_userclk2            => pcspma_userclk2,

      -- MDIO Interface
      -------------------
      mdio_i                     => mdio_i_i,
      mdio_o                     => mdio_o_i,
      mdio_t                     => mdio_t_i,
      mdc                        => mdc_i,

      -- IPIC Interface
      -----------------
      Bus2IP_Clk                 => bus2ip_clk,
      Bus2IP_Reset               => bus2ip_reset,
      Bus2IP_Addr                => shim2ip_addr,
      Bus2IP_CS                  => shim2temac_avb_cs,
      Bus2IP_RdCE                => shim2temac_avb_rd_ce,
      Bus2IP_WrCE                => shim2temac_avb_wr_ce,
      Bus2IP_Data                => shim2ip_data,
      IP2Bus_Data                => temac2bus_data,
      IP2Bus_WrAck               => temac2bus_wr_ack,
      IP2Bus_RdAck               => temac2bus_rd_ack,
      IP2Bus_Error               => open,

      -- Speed Indicator
      speed_is_10_100            => speed_is_10_100,

      mac_rx_good_frame          => open,
      mac_rx_bad_frame           => open
   );

    MDC      <= mdc_i;
    MDIO_O   <= mdio_o_i;
    MDIO_T   <= mdio_t_i;

     RGMII_TEMAC_USED : if (C_TYPE = 1 and (C_PHY_TYPE = 3)) generate
    GEN_RK7: if (equalIgnoringCase(C_FAMILY_ROOT, "kintex7")= TRUE or equalIgnoringCase(C_FAMILY_ROOT, "artix7")= TRUE
    or equalIgnoringCase(C_FAMILY_ROOT, "zynq") = TRUE)  generate
    signal clkfbout              : std_logic;                    -- MMCM feedback clock
    signal clkout0               : std_logic;                    -- MMCM clock0 output (62.5MHz).
    signal clkout1               : std_logic;                    -- MMCM clock1 output (125MHz).
    signal userclk               : std_logic;                    -- 62.5MHz clock for GT transceiver Tx/Rx user clocks
    signal userclk2              : std_logic;
    signal userclk3              : std_logic;                    -- 125MHz clock for core reference clock 90 degree phase shifted
    signal mmcm_reset            : std_logic;
    signal clkout2               : std_logic;                    --  125 MHz 90 degree phase shift clock.
    signal gtxclkin              : std_logic;

    -- PMA reset generation signals for tranceiver
    signal pma_reset_pipe        : std_logic_vector(3 downto 0); -- flip-flop pipeline for reset duration stretch

    begin  
    
      --  K7 does not have gtx_clk_in, so drive it low.
      gtx_clk_in <= '0';        
      
      -----------------------------------------------------------------------------
      -- Transceiver Clock Management
      -----------------------------------------------------------------------------
    
      -- Clock circuitry for the GT Transceiver uses a differential input clock.
      -- gtrefclk is routed to the tranceiver.
         
      bufh_gtxclk: BUFH
      port map (
         I     => GTX_CLK,
         O     => gtxclkin
      );    

    
      mmcm_adv_inst : MMCME2_ADV
      generic map
       (BANDWIDTH            => "OPTIMIZED",
        CLKOUT4_CASCADE      => FALSE,
        COMPENSATION         => "ZHOLD",
        STARTUP_WAIT         => FALSE,
        DIVCLK_DIVIDE        => 1,
        CLKFBOUT_MULT_F      => 9.000,
        CLKFBOUT_PHASE       => 0.000,
        CLKFBOUT_USE_FINE_PS => FALSE,
        CLKOUT0_DIVIDE_F     => 9.000,
        CLKOUT0_PHASE        => 0.000,
        CLKOUT0_DUTY_CYCLE   => 0.5,
        CLKOUT0_USE_FINE_PS  => FALSE,
        CLKOUT1_DIVIDE       => 9,
        CLKOUT1_PHASE        => 0.000,
        CLKOUT1_DUTY_CYCLE   => 0.5,
        CLKOUT1_USE_FINE_PS  => FALSE,
        CLKOUT2_DIVIDE       => 9,
        CLKOUT2_PHASE        => 90.000,
        CLKOUT2_DUTY_CYCLE   => 0.500,
        CLKOUT2_USE_FINE_PS  => FALSE,
        CLKIN1_PERIOD        => 8.0,
        REF_JITTER1          => 0.010)
      port map
        -- Output clocks
       (CLKFBOUT             => clkfbout,
        CLKFBOUTB            => open,
        CLKOUT0              => clkout0,
        CLKOUT0B             => open,
        CLKOUT1              => clkout1,
        CLKOUT1B             => open,
        CLKOUT2              => clkout2,
        CLKOUT2B             => open,
        CLKOUT3              => open,
        CLKOUT3B             => open,
        CLKOUT4              => open,
        CLKOUT5              => open,
        CLKOUT6              => open,
        -- Input clock control
        CLKFBIN              => clkfbout,
        CLKIN1               => gtxclkin,
        CLKIN2               => '0',
        -- Tied to always select the primary input clock
        CLKINSEL             => '1',
        -- Ports for dynamic reconfiguration
        DADDR                => (others => '0'),
        DCLK                 => '0',
        DEN                  => '0',
        DI                   => (others => '0'),
        DO                   => open,
        DRDY                 => open,
        DWE                  => '0',
        -- Ports for dynamic phase shift
        PSCLK                => '0',
        PSEN                 => '0',
        PSINCDEC             => '0',
        PSDONE               => open,
        -- Other control and status signals
        LOCKED               => open,
        CLKINSTOPPED         => open,
        CLKFBSTOPPED         => open,
        PWRDWN               => '0',
        RST                  => mmcm_reset);
    
        mmcm_reset <= reset2temac;  --reset;-- or (not resetdone);
    
    
      -- This 62.5MHz clock is placed onto global clock routing and is then used
      -- for tranceiver TXUSRCLK/RXUSRCLK.
      bufg_userclk: BUFG
      port map (
         I     => clkout0,
         O     => gtx_clk_or_pcspma_userclk2
      );    
    

      --pcspma_userclk <= userclk;
      
      
      -- This 125MHz clock is placed onto global clock routing and is then used
      -- to clock all Ethernet core logic.
      bufg_userclk2: BUFG
      port map (
         I     => clkout1,
         O     => userclk2
      );    
    
      --pcspma_userclk2 <= userclk2;
    
       -- This 125MHz clock is placed onto global clock routing and is then used
      -- to clock all Ethernet core logic.
      bufg_userclk2_90: BUFG
      port map (
         I     => clkout2,
         O     => userclk3
      );    

     --  gtx_clk_or_pcspma_userclk2 <= GTX_CLK;
      gtx_clk_or_pcspma_userclk2_90 <= userclk3;


    
      -----------------------------------------------------------------------------
      -- Transceiver PMA reset circuitry
      -----------------------------------------------------------------------------
    
      -- Create a reset pulse of a decent length
      process(reset2temac, S_AXI_ACLK)
      begin
        if (reset2temac = '1') then
          pma_reset_pipe <= "1111";
        elsif S_AXI_ACLK'event and S_AXI_ACLK = '1' then
          pma_reset_pipe <= pma_reset_pipe(2 downto 0) & reset2temac;
        end if;
      end process;
    
      --pma_reset <= pma_reset_pipe(3);                                                                           
      pcspma_gtpresetin <= pma_reset_pipe(3);                                                                                
    end generate GEN_RK7;                                                                           
  end generate RGMII_TEMAC_USED;

    NO_SOFT_PCS_PMA_USED: if (C_TYPE = 0 or
      not ((C_TYPE = 1) and ((C_PHY_TYPE = 4) or (C_PHY_TYPE = 5)))) generate
    begin
      emac_client_autoneg_int <= '0';  --changed to match Hard TEMAC
      pcspma_sgmii_clk_en     <= '0';
      pcspma_userclk2         <= '0';
      emac_reset_done_int     <= '1';
      clk_enable              <= '0';
      rstdone                 <= '0';
      tx_avb_en               <= tx_avb_en_int;  -- added for avb connection 03/21/2011
      NO_RGMII_K7_USED : if (not (C_TYPE = 1 and C_PHY_TYPE = 3 and  (equalIgnoringCase(C_FAMILY_ROOT, "kintex7") =
       TRUE or equalIgnoringCase(C_FAMILY_ROOT, "artix7") = TRUE or equalIgnoringCase(C_FAMILY_ROOT, "zynq") = TRUE)) ) generate begin
      gtx_clk_or_pcspma_userclk2 <= GTX_CLK;
    end generate NO_RGMII_K7_USED;

    end generate NO_SOFT_PCS_PMA_USED;

  end generate SOFT_SYS;

  SOFT_PCS_PMA: if((C_TYPE = 1) and ((C_PHY_TYPE = 4) or (C_PHY_TYPE = 5))) generate

  signal link_timer_value : std_logic_vector(8 downto 0);

  begin

    GMII_TXD          <= (others => '0');
    GMII_TX_EN        <= '0';
    GMII_TX_ER        <= '0';
    GMII_TX_CLK       <= '0';
    pcspma_gmii_txd   <= gmii_txd_i;
    pcspma_gmii_tx_en <= gmii_tx_en_i;
    pcspma_gmii_tx_er <= gmii_tx_er_i;
    rstdone           <= not emac_reset_done_int;

    gmii_rxd_i        <= pcspma_gmii_rxd;
    gmii_rx_dv_i      <= pcspma_gmii_rx_dv;
    gmii_rx_er_i      <= pcspma_gmii_rx_er;
    gmii_rx_clk_i     <= pcspma_userclk2;

    --  MDIO_I must be tied HIGH if the externel MDIO interface is not used.
    --  This signal is required to be pulled up on the board.
    mdio_i_i <= MDIO_I and (pcspma_mdio_o or pcspma_mdio_t);

    gtx_clk_or_pcspma_userclk2 <= pcspma_userclk2;
    gtx_clk_or_pcspma_userclk2_90 <= '0';


    GEN_SGMII_CONSTANTS : if C_PHY_TYPE = 4 generate
    begin

      link_timer_value <= "000110010";          --1.606 and 1.638 milliseconds (UG155 default)
      core_has_sgmii   <= '1';

      clk_enable       <= pcspma_sgmii_clk_en;

      tx_avb_en        <= pcspma_sgmii_clk_en;  -- added for avb connection 03/21/2011
    end generate GEN_SGMII_CONSTANTS;

    GEN_NOT_SGMII_CONSTANTS : if C_PHY_TYPE /= 4 generate
    begin

      link_timer_value <= "100111101"; --10.354 and 10.387 milliseconds (UG155 default)
      core_has_sgmii   <= '0';

      clk_enable       <= '1';

      tx_avb_en        <= '1';         -- added for avb connection 03/21/2011
    end generate GEN_NOT_SGMII_CONSTANTS;



    GEN_TRANS_A_ROUTE: if (
                           (equalIgnoringCase(C_TRANS, "A")= TRUE) and
                           (equalIgnoringCase(C_FAMILY_ROOT, "spartan6")= TRUE)
                                                                               ) generate
    begin

    pcspma_rxp0       <= RXP;
    pcspma_rxn0       <= RXN;

    pcspma_rxp1       <= '0';
    pcspma_rxn1       <= '0';
    mmcm_locked       <= '0';

    TXP               <= pcspma_txp0;
    TXN               <= pcspma_txn0;

    end generate GEN_TRANS_A_ROUTE;


    GEN_TRANS_B_ROUTE: if (
                           (equalIgnoringCase(C_TRANS, "A")= FALSE)  and
                           (equalIgnoringCase(C_FAMILY_ROOT, "spartan6")= TRUE)
                                                                               ) generate
    begin

    pcspma_rxp0       <= '0';
    pcspma_rxn0       <= '0';

    pcspma_rxp1       <= RXP;
    pcspma_rxn1       <= RXN;
    mmcm_locked       <= '0';

    TXP               <= pcspma_txp1;
    TXN               <= pcspma_txn1;

    end generate GEN_TRANS_B_ROUTE;

    GEN_V6_V7_K7_A7_ROUTE: if (
                            ((equalIgnoringCase(C_FAMILY_ROOT, "virtex6")= TRUE)) or
                            ((equalIgnoringCase(C_FAMILY_ROOT, "virtex7")= TRUE)) or
                            ((equalIgnoringCase(C_FAMILY_ROOT, "kintex7")= TRUE)) or
                            ((equalIgnoringCase(C_FAMILY_ROOT, "artix7")= TRUE)) or
                            ((equalIgnoringCase(C_FAMILY_ROOT, "zynq")= TRUE))
                                                                                 )generate
    begin

    pcspma_rxp0       <= RXP;
    pcspma_rxn0       <= RXN;

    pcspma_rxp1       <= '0';
    pcspma_rxn1       <= '0';

    TXP               <= pcspma_txp0;
    TXN               <= pcspma_txn0;

    end generate GEN_V6_V7_K7_A7_ROUTE;






    I_PCSPMA : entity axi_ethernet_pcs_pma_wrap_v3_01_a.axi_ethernet_pcs_pma_wrap(imp)
      generic map (
        SIM_GTPRESET_SPEEDUP => C_SIMULATION,
        C_TRANS              => C_TRANS,
        C_TYPE               => C_TYPE,
        C_PHY_TYPE           => C_PHY_TYPE,
        C_USE_GTH            => C_USE_GTH,
        C_FAMILY             => C_FAMILY_ROOT
      )
      port map (
                                                                  
        clkin                => pcspma_clkin,                     
        gtx_clk_in           => gtx_clk_in,                       
        independent_clock    => S_AXI_ACLK,
        txp0                 => pcspma_txp0,                      
        txn0                 => pcspma_txn0,                      
        rxp0                 => pcspma_rxp0,                      
        rxn0                 => pcspma_rxn0,                      
                                                                  
        txp1                 => pcspma_txp1,                      
        txn1                 => pcspma_txn1,                      
        rxp1                 => pcspma_rxp1,                      
        rxn1                 => pcspma_rxn1,                      
                                                                  
        ResetDoneInterrupt   => emac_reset_done_int,              
        mmcm_locked          => mmcm_locked,
                                                                  
                                                                  
        gtclkout             => pcspma_gtclkout,                  
        userclk2             => pcspma_userclk2,                  
        gtpreset             => pcspma_gtpresetin,                
                                                                  
        userclk              => pcspma_userclk,                   
                                                                  
                                                                  
        sgmii_clk_r          => open,                             
        sgmii_clk_f          => open,                             
        sgmii_clk_en         => pcspma_sgmii_clk_en,--open,       
                                                                  
        gmii_txd             => pcspma_gmii_txd,                  
        gmii_tx_en           => pcspma_gmii_tx_en,                
        gmii_tx_er           => pcspma_gmii_tx_er,                
        gmii_rxd             => pcspma_gmii_rxd,                  
        gmii_rx_dv           => pcspma_gmii_rx_dv,                
        gmii_rx_er           => pcspma_gmii_rx_er,                
        gmii_isolate         => open,                             
                                                                  
                                                                  
                                                                  
                                                                  
        mdc                  => mdc_i,                            
        mdio_i               => mdio_o_i,                         
        mdio_o               => pcspma_mdio_o,                    
        mdio_t               => pcspma_mdio_t,                    
        phyad                => C_PHYADDR,                        
                                                                  
                                                                  
        an_interrupt         => emac_client_autoneg_int,          
        link_timer_value     => link_timer_value,                 
                                                                  
                                                                  
                                                                  
        speed_is_10_100      => speed_is_10_100,                  
        speed_is_100         => speed_is_100,                     
                                                                  
                                                                  
                                                                  
        status_vector        => pcspma_status_vector,             
        reset                => reset2temac,                      
        signal_detect        => '1'                               

    );



    GEN_V6: if (equalIgnoringCase(C_FAMILY_ROOT, "virtex6")= TRUE) generate
    signal reset_sync_reg : std_logic;
    -- These attributes will stop timing errors being reported in back annotated
    -- SDF simulation.
    attribute ASYNC_REG                   : string;
    attribute ASYNC_REG of reset_sync_reg : signal is "TRUE";

    begin
    
        --  V6 does not have pcspma_userclk, so drive it low.
        pcspma_userclk <= '0'; 
        mmcm_locked   <= '0';

        reset_sync1 : FDP
        generic map (
          INIT => '1'
        )
        port map (
          C    => pcspma_userclk2,
          PRE  => reset2temac,
          D    => '0',
          Q    => reset_sync_reg
        );


        reset_sync2 : FDP
        generic map (
          INIT => '1'
        )
        port map (
          C    => pcspma_userclk2,
          PRE  => reset2temac,
          D    => reset_sync_reg,
          Q    => pcspma_gtpresetin
        );

        -----------------------------------------------------------------------------
        -- Virtex-6 Rocket I/O Clock Management
        -----------------------------------------------------------------------------

        -- Clock circuitry for the Rocket I/O uses a differential input clock.
        -- mgtrefclk is routed to the RocketIO.
        ibufds_mgtrefclk : IBUFDS_GTXE1
        port map (
           CEB   => '0',
           I     => MGT_CLK_P,
           IB    => MGT_CLK_N,
           O     => pcspma_clkin,--mgtrefclk,
           ODIV2 => open
        );


        -- txoutclk (125MHz) is made avaiable by the RocketIO to the FPGA
        -- fabric. This is placed onto global clock routing and is then used
        -- for RocketIO TXUSRCLK2/RXUSRCLK2 and used to clock all Ethernet
        -- core logic.
        bufg_userclk2: BUFG
        port map (                   --   V6
           I     => pcspma_gtclkout, --txoutclk,
           O     => pcspma_userclk2  --userclk2
        );

       -- Locally buffer the output of the IBUFDS_GTXE1 for reset logic
       bufr_mgtrefclk : BUFR port map (
         I   => pcspma_clkin, --mgtrefclk,
         O   => gtx_clk_in,   --mgtrefclk_bufr,
         CE  => '1',
         CLR => '0'
       );

    end generate GEN_V6;

     GEN_A7: if (equalIgnoringCase(C_FAMILY_ROOT, "artix7")= TRUE or (equalIgnoringCase(C_FAMILY_ROOT, "zynq")= TRUE and
     (equalIgnoringCasedevice(C_DEVICE, "xc7z010")= TRUE or equalIgnoringCasedevice(C_DEVICE, "xc7z020") = TRUE) )) generate
    signal txoutclk_bufg         : std_logic;                    -- txoutclk from GT transceiver routed onto global routing.
    signal clkfbout              : std_logic;                    -- MMCM feedback clock
    signal clkout0               : std_logic;                    -- MMCM clock0 output (62.5MHz).
    signal clkout1               : std_logic;                    -- MMCM clock1 output (125MHz).
    signal userclk               : std_logic;                    -- 62.5MHz clock for GT transceiver Tx/Rx user clocks
    signal userclk2              : std_logic;                    -- 125MHz clock for core reference clock.
    signal mmcm_reset            : std_logic;
   

    -- PMA reset generation signals for tranceiver
    signal pma_reset_pipe        : std_logic_vector(3 downto 0); -- flip-flop pipeline for reset duration stretch

    begin  
    
      --  K7 does not have gtx_clk_in, so drive it low.
      gtx_clk_in <= '0';        
      
      -----------------------------------------------------------------------------
      -- Transceiver Clock Management
      -----------------------------------------------------------------------------
    
      -- Clock circuitry for the GT Transceiver uses a differential input clock.
      -- gtrefclk is routed to the tranceiver.
      ibufds_gtrefclk : IBUFDS_GTE2
      port map (
         I     => MGT_CLK_P,    --  gtrefclk_p,
         IB    => MGT_CLK_N,    --  gtrefclk_n,
         CEB   => '0',
         O     => pcspma_clkin, --  gtrefclk,
         ODIV2 => open
      );
    
    
      -- Route txoutclk input through a BUFG
      bufg_txoutclk : BUFG
      port map (
         I         => pcspma_gtclkout,  --  txoutclk,
         O         => txoutclk_bufg
      );
    
    
      -- The GT transceiver provides a 62.5MHz clock to the FPGA fabrix.  This is 
      -- routed to an MMCM module where it is used to create phase and frequency
      -- related 62.5MHz and 125MHz clock sources
      mmcm_adv_inst : MMCME2_ADV
      generic map
       (BANDWIDTH            => "OPTIMIZED",
        CLKOUT4_CASCADE      => FALSE,
        COMPENSATION         => "ZHOLD",
        STARTUP_WAIT         => FALSE,
        DIVCLK_DIVIDE        => 1,
        CLKFBOUT_MULT_F      => 8.000,
        CLKFBOUT_PHASE       => 0.000,
        CLKFBOUT_USE_FINE_PS => FALSE,
        CLKOUT0_DIVIDE_F     => 8.000,
        CLKOUT0_PHASE        => 0.000,
        CLKOUT0_DUTY_CYCLE   => 0.5,
        CLKOUT0_USE_FINE_PS  => FALSE,
        CLKOUT1_DIVIDE       => 16,
        CLKOUT1_PHASE        => 0.000,
        CLKOUT1_DUTY_CYCLE   => 0.5,
        CLKOUT1_USE_FINE_PS  => FALSE,
        CLKIN1_PERIOD        => 8.0,
        REF_JITTER1          => 0.010)
      port map
        -- Output clocks
       (CLKFBOUT             => clkfbout,
        CLKFBOUTB            => open,
        CLKOUT0              => clkout0,
        CLKOUT0B             => open,
        CLKOUT1              => clkout1,
        CLKOUT1B             => open,
        CLKOUT2              => open,
        CLKOUT2B             => open,
        CLKOUT3              => open,
        CLKOUT3B             => open,
        CLKOUT4              => open,
        CLKOUT5              => open,
        CLKOUT6              => open,
        -- Input clock control
        CLKFBIN              => clkfbout,
        CLKIN1               => txoutclk_bufg,
        CLKIN2               => '0',
        -- Tied to always select the primary input clock
        CLKINSEL             => '1',
        -- Ports for dynamic reconfiguration
        DADDR                => (others => '0'),
        DCLK                 => '0',
        DEN                  => '0',
        DI                   => (others => '0'),
        DO                   => open,
        DRDY                 => open,
        DWE                  => '0',
        -- Ports for dynamic phase shift
        PSCLK                => '0',
        PSEN                 => '0',
        PSINCDEC             => '0',
        PSDONE               => open,
        -- Other control and status signals
        LOCKED               => mmcm_locked,
        CLKINSTOPPED         => open,
        CLKFBSTOPPED         => open,
        PWRDWN               => '0',
        RST                  => mmcm_reset);
    
        mmcm_reset <= reset2temac ;  --reset;-- or (not resetdone);
    
    
      -- This 62.5MHz clock is placed onto global clock routing and is then used
      -- for tranceiver TXUSRCLK/RXUSRCLK.
      bufg_userclk: BUFG
      port map (
         I     => clkout1,
         O     => userclk
      );    
    

      pcspma_userclk <= userclk;
      
      
      -- This 125MHz clock is placed onto global clock routing and is then used
      -- to clock all Ethernet core logic.
      bufg_userclk2: BUFG
      port map (
         I     => clkout0,
         O     => userclk2
      );    
    
      pcspma_userclk2 <= userclk2;
    
    
      -----------------------------------------------------------------------------
      -- Transceiver PMA reset circuitry
      -----------------------------------------------------------------------------
    
      -- Create a reset pulse of a decent length
      process(reset2temac, S_AXI_ACLK)
      begin
        if (reset2temac = '1') then
          pma_reset_pipe <= "1111";
        elsif S_AXI_ACLK'event and S_AXI_ACLK = '1' then
          pma_reset_pipe <= pma_reset_pipe(2 downto 0) & reset2temac;
        end if;
      end process;
    
      --pma_reset <= pma_reset_pipe(3);                                                                           
      pcspma_gtpresetin <= pma_reset_pipe(3);                                                                                
    end generate GEN_A7;                                                                           

    GEN_K7: if (equalIgnoringCase(C_FAMILY_ROOT, "kintex7")= TRUE or  (equalIgnoringCase(C_FAMILY_ROOT, "zynq")= TRUE and
     (equalIgnoringCasedevice(C_DEVICE, "xc7z030")= TRUE or equalIgnoringCasedevice(C_DEVICE, "xc7z045") = TRUE) )) generate
    signal txoutclk_bufg         : std_logic;                    -- txoutclk from GT transceiver routed onto global routing.
    signal clkfbout              : std_logic;                    -- MMCM feedback clock
    signal clkout0               : std_logic;                    -- MMCM clock0 output (62.5MHz).
    signal clkout1               : std_logic;                    -- MMCM clock1 output (125MHz).
    signal userclk               : std_logic;                    -- 62.5MHz clock for GT transceiver Tx/Rx user clocks
    signal userclk2              : std_logic;                    -- 125MHz clock for core reference clock.
    signal mmcm_reset            : std_logic;
   

    -- PMA reset generation signals for tranceiver
    signal pma_reset_pipe        : std_logic_vector(3 downto 0); -- flip-flop pipeline for reset duration stretch

    begin  
    
      --  K7 does not have gtx_clk_in, so drive it low.
      gtx_clk_in <= '0';        
      
      -----------------------------------------------------------------------------
      -- Transceiver Clock Management
      -----------------------------------------------------------------------------
    
      -- Clock circuitry for the GT Transceiver uses a differential input clock.
      -- gtrefclk is routed to the tranceiver.
      ibufds_gtrefclk : IBUFDS_GTE2
      port map (
         I     => MGT_CLK_P,    --  gtrefclk_p,
         IB    => MGT_CLK_N,    --  gtrefclk_n,
         CEB   => '0',
         O     => pcspma_clkin, --  gtrefclk,
         ODIV2 => open
      );
    
    
      -- Route txoutclk input through a BUFG
      bufg_txoutclk : BUFG
      port map (
         I         => pcspma_gtclkout,  --  txoutclk,
         O         => txoutclk_bufg
      );
    
    
      -- The GT transceiver provides a 62.5MHz clock to the FPGA fabrix.  This is 
      -- routed to an MMCM module where it is used to create phase and frequency
      -- related 62.5MHz and 125MHz clock sources
      mmcm_adv_inst : MMCME2_ADV
      generic map
       (BANDWIDTH            => "OPTIMIZED",
        CLKOUT4_CASCADE      => FALSE,
        COMPENSATION         => "ZHOLD",
        STARTUP_WAIT         => FALSE,
        DIVCLK_DIVIDE        => 1,
        CLKFBOUT_MULT_F      => 8.000,
        CLKFBOUT_PHASE       => 0.000,
        CLKFBOUT_USE_FINE_PS => FALSE,
        CLKOUT0_DIVIDE_F     => 8.000,
        CLKOUT0_PHASE        => 0.000,
        CLKOUT0_DUTY_CYCLE   => 0.5,
        CLKOUT0_USE_FINE_PS  => FALSE,
        CLKOUT1_DIVIDE       => 16,
        CLKOUT1_PHASE        => 0.000,
        CLKOUT1_DUTY_CYCLE   => 0.5,
        CLKOUT1_USE_FINE_PS  => FALSE,
        CLKIN1_PERIOD        => 8.0,
        REF_JITTER1          => 0.010)
      port map
        -- Output clocks
       (CLKFBOUT             => clkfbout,
        CLKFBOUTB            => open,
        CLKOUT0              => clkout0,
        CLKOUT0B             => open,
        CLKOUT1              => clkout1,
        CLKOUT1B             => open,
        CLKOUT2              => open,
        CLKOUT2B             => open,
        CLKOUT3              => open,
        CLKOUT3B             => open,
        CLKOUT4              => open,
        CLKOUT5              => open,
        CLKOUT6              => open,
        -- Input clock control
        CLKFBIN              => clkfbout,
        CLKIN1               => txoutclk_bufg,
        CLKIN2               => '0',
        -- Tied to always select the primary input clock
        CLKINSEL             => '1',
        -- Ports for dynamic reconfiguration
        DADDR                => (others => '0'),
        DCLK                 => '0',
        DEN                  => '0',
        DI                   => (others => '0'),
        DO                   => open,
        DRDY                 => open,
        DWE                  => '0',
        -- Ports for dynamic phase shift
        PSCLK                => '0',
        PSEN                 => '0',
        PSINCDEC             => '0',
        PSDONE               => open,
        -- Other control and status signals
        LOCKED               => mmcm_locked,
        CLKINSTOPPED         => open,
        CLKFBSTOPPED         => open,
        PWRDWN               => '0',
        RST                  => mmcm_reset);
    
        mmcm_reset <= reset2temac or rstdone;  --reset;-- or (not resetdone);
    
    
      -- This 62.5MHz clock is placed onto global clock routing and is then used
      -- for tranceiver TXUSRCLK/RXUSRCLK.
      bufg_userclk: BUFG
      port map (
         I     => clkout1,
         O     => userclk
      );    
    

      pcspma_userclk <= userclk;
      
      
      -- This 125MHz clock is placed onto global clock routing and is then used
      -- to clock all Ethernet core logic.
      bufg_userclk2: BUFG
      port map (
         I     => clkout0,
         O     => userclk2
      );    
    
      pcspma_userclk2 <= userclk2;
    
    
      -----------------------------------------------------------------------------
      -- Transceiver PMA reset circuitry
      -----------------------------------------------------------------------------
    
      -- Create a reset pulse of a decent length
      process(reset2temac, S_AXI_ACLK)
      begin
        if (reset2temac = '1') then
          pma_reset_pipe <= "1111";
        elsif S_AXI_ACLK'event and S_AXI_ACLK = '1' then
          pma_reset_pipe <= pma_reset_pipe(2 downto 0) & reset2temac;
        end if;
      end process;
    
      --pma_reset <= pma_reset_pipe(3);                                                                           
      pcspma_gtpresetin <= pma_reset_pipe(3);                                                                                
    end generate GEN_K7;                                                                           
                                                                                                                                                    

    GEN_V7: if (equalIgnoringCase(C_FAMILY_ROOT, "virtex7")= TRUE) generate
    signal clkfbout              : std_logic;                    -- MMCM feedback clock
    signal clkout0               : std_logic;                    -- MMCM clock0 output (62.5MHz).
    signal clkout1               : std_logic;                    -- MMCM clock1 output (125MHz).
    signal userclk               : std_logic;                    -- 62.5MHz clock for GT transceiver Tx/Rx user clocks
    signal userclk2              : std_logic;                    -- 125MHz clock for core reference clock.
    signal mmcm_reset            : std_logic;

    -- PMA reset generation signals for tranceiver
    signal pma_reset_pipe        : std_logic_vector(3 downto 0); -- flip-flop pipeline for reset duration stretch
    
    begin

      --  V7 does not have gtx_clk_in, so drive it low.
      gtx_clk_in <= '0';    
    
      -----------------------------------------------------------------------------
      -- Transceiver Clock Management
      -----------------------------------------------------------------------------
      
      -- Clock circuitry for the GT Transceiver uses a differential input clock.
      -- gtrefclk is routed to the tranceiver.
      ibufds_gtrefclk : IBUFDS_GTE2
      port map (
         I     => MGT_CLK_P,    --  gtrefclk_p,
         IB    => MGT_CLK_N,    --  gtrefclk_n,
         CEB   => '0',
         O     => pcspma_clkin, --  gtrefclk,
         ODIV2 => open
      );
      
      
      -- The GT transceiver provides a 62.5MHz clock to the FPGA fabrix.  This is 
      -- routed to an MMCM module where it is used to create phase and frequency
      -- related 62.5MHz and 125MHz clock sources
      mmcm_adv_inst : MMCME2_ADV
      generic map
       (BANDWIDTH            => "OPTIMIZED",
        CLKOUT4_CASCADE      => FALSE,
        COMPENSATION         => "ZHOLD",
        STARTUP_WAIT         => FALSE,
        DIVCLK_DIVIDE        => 1,
        CLKFBOUT_MULT_F      => 8.000,
        CLKFBOUT_PHASE       => 0.000,
        CLKFBOUT_USE_FINE_PS => FALSE,
        CLKOUT0_DIVIDE_F     => 8.000,
        CLKOUT0_PHASE        => 0.000,
        CLKOUT0_DUTY_CYCLE   => 0.5,
        CLKOUT0_USE_FINE_PS  => FALSE,
        CLKOUT1_DIVIDE       => 16,
        CLKOUT1_PHASE        => 0.000,
        CLKOUT1_DUTY_CYCLE   => 0.5,
        CLKOUT1_USE_FINE_PS  => FALSE,
        CLKIN1_PERIOD        => 8.0,
        REF_JITTER1          => 0.010)
      port map
        -- Output clocks
       (CLKFBOUT             => clkfbout,
        CLKFBOUTB            => open,
        CLKOUT0              => clkout0,
        CLKOUT0B             => open,
        CLKOUT1              => clkout1,
        CLKOUT1B             => open,
        CLKOUT2              => open,
        CLKOUT2B             => open,
        CLKOUT3              => open,
        CLKOUT3B             => open,
        CLKOUT4              => open,
        CLKOUT5              => open,
        CLKOUT6              => open,
        -- Input clock control
        CLKFBIN              => clkfbout,
        CLKIN1               => pcspma_gtclkout,  --  txoutclk,
        CLKIN2               => '0',
        -- Tied to always select the primary input clock
        CLKINSEL             => '1',
        -- Ports for dynamic reconfiguration
        DADDR                => (others => '0'),
        DCLK                 => '0',
        DEN                  => '0',
        DI                   => (others => '0'),
        DO                   => open,
        DRDY                 => open,
        DWE                  => '0',
        -- Ports for dynamic phase shift
        PSCLK                => '0',
        PSEN                 => '0',
        PSINCDEC             => '0',
        PSDONE               => open,
        -- Other control and status signals
        LOCKED               => mmcm_locked,
        CLKINSTOPPED         => open,
        CLKFBSTOPPED         => open,
        PWRDWN               => '0',
        RST                  => mmcm_reset);

       GEN_MMCM_GTH : if C_USE_GTH = 0 generate
       mmcm_reset <= reset2temac or rstdone;  --reset;-- or (not resetdone);
     end generate GEN_MMCM_GTH;
      
      GEN_MMCM_GTX : if C_USE_GTH = 1 generate
       mmcm_reset <= reset2temac ;
     end generate GEN_MMCM_GTX;
      

      
       -- This 62.5MHz clock is placed onto global clock routing and is then used
       -- for tranceiver TXUSRCLK/RXUSRCLK.
       bufg_userclk: BUFG
       port map (
          I     => clkout1,
          O     => userclk
       );    

       pcspma_userclk <= userclk;
       
             
       -- This 125MHz clock is placed onto global clock routing and is then used
       -- to clock all Ethernet core logic.
       bufg_userclk2: BUFG
       port map (
          I     => clkout0,
          O     => userclk2
       );    
      
       pcspma_userclk2 <= userclk2;
             
       -----------------------------------------------------------------------------
       -- Transceiver PMA reset circuitry
       -----------------------------------------------------------------------------
      
       -- Create a reset pulse of a decent length
       process(reset2temac, S_AXI_ACLK)
       begin
         if (reset2temac = '1') then
           pma_reset_pipe <= "1111";
         elsif S_AXI_ACLK'event and S_AXI_ACLK = '1' then
           pma_reset_pipe <= pma_reset_pipe(2 downto 0) & reset2temac;
         end if;
       end process;
      
      --pma_reset <= pma_reset_pipe(3);                                                                           
      pcspma_gtpresetin <= pma_reset_pipe(3);    

    end generate GEN_V7;

    S6: if((equalIgnoringCase(C_FAMILY_ROOT, "spartan6")= TRUE)) generate
      signal gtpclkout_bufio2 : std_logic;
      signal reset_sync_reg   : std_logic;
      signal reset_out        : std_logic;

      -- These attributes will stop timing errors being reported in back annotated
      -- SDF simulation.
      attribute ASYNC_REG                       : string;
      attribute ASYNC_REG of reset_sync_reg     : signal is "TRUE";
      attribute ASYNC_REG of reset_out          : signal is "TRUE";

      -- These attributes will stop XST translating the desired flip-flops into an
      -- SRL based shift register.
      attribute shreg_extract                   : string;
      attribute shreg_extract of reset_sync_reg : signal is "no";
      attribute shreg_extract of reset_out      : signal is "no";


      begin
  
        --  S6 does not have pcspma_userclk, so drive it low.
        pcspma_userclk <= '0';

        --  S6 does not have gtx_clk_in, so drive it low.
        gtx_clk_in <= '0';

        -----------------------------------------------------------------------------
        -- Spartan-6 Transceiver Clock Management
        -----------------------------------------------------------------------------

        -- NOTE: BREFCLK circuitry for the Transceiver requires the use of a
        -- 125MHz differential input clock.  clkin is routed to the tranceiver
        -- pair.

        clkingen : IBUFDS
        port map (
           I  => MGT_CLK_P,    --  brefclk_p,
           IB => MGT_CLK_N,    --  brefclk_n,
           O  => pcspma_clkin  --  clkin
        );


        -- gtpclkout (125MHz) is made avaiable by the tranceiver to the FPGA
        -- fabric. This is routed to a BUFIO2 before being placed onto global clock
        -- routing where it is then used for tranceiver TXUSRCLK2/RXUSRCLK2 and used
        -- to clock all Ethernet core logic.

        bufio2_clk125m : BUFIO2
        generic map (
           DIVIDE        => 1,
           DIVIDE_BYPASS => TRUE
        )
        port map (
           DIVCLK        => gtpclkout_bufio2,
           I             => pcspma_gtclkout, --  gtpclkout,
           IOCLK         => open,
           SERDESSTROBE  => open
        );


        -- Route through a BUFG
        bufg_clk125m : BUFG
        port map (
           I => gtpclkout_bufio2,
           O => pcspma_userclk2    --  userclk2
        );


        -----------------------------------------------------------------------------
        -- Spartan-6 Transceiver System Reset
        -----------------------------------------------------------------------------

        --  -- tranceiver 0
        --  gtpreset_gen0 : reset_sync
        --  port map(
        --     clk       => pcspma_userclk2, --  userclk2,
        --     reset_in  => reset2temac,     --  reset0,
        --     reset_out => pcspma_gtpresetin--  gtpreset0
        --  );

        reset_sync1 : FDP
        generic map (
          INIT => '1'
        )
        port map (
          C    => pcspma_userclk2,
          PRE  => reset2temac,
          D    => '0',
          Q    => reset_sync_reg
        );


        reset_sync2 : FDP
        generic map (
          INIT => '1'
        )
        port map (
          C    => pcspma_userclk2,
          PRE  => reset2temac,
          D    => reset_sync_reg,
          Q    => reset_out
        );

        pcspma_gtpresetin <= reset_out;

    end generate S6;

  end generate SOFT_PCS_PMA;

  NO_SOFT_PCS_PMA: if(((C_TYPE = 1) = FALSE) or (((C_PHY_TYPE = 4) = FALSE) and ((C_PHY_TYPE = 5)= FALSE))) generate
  begin
    GMII_TXD       <= gmii_txd_i;
    GMII_TX_EN     <= gmii_tx_en_i;
    GMII_TX_ER     <= gmii_tx_er_i;
    GMII_TX_CLK    <= gmii_tx_clk_i;
    gmii_rxd_i     <= GMII_RXD;
    gmii_rx_dv_i   <= GMII_RX_DV;
    gmii_rx_er_i   <= GMII_RX_ER;
    gmii_rx_clk_i  <= GMII_RX_CLK;

    mdio_i_i       <= MDIO_I;

    core_has_sgmii <= '0';
    pcspma_status_vector <= (others => '0');

  end generate NO_SOFT_PCS_PMA;

  I_EMBEDDED_TOP : entity axi_ethernet_v3_01_a.embedded_top(imp)
  generic map (
    C_FAMILY               => C_FAMILY,
    C_S_AXI_ACLK_FREQ_HZ   => C_S_AXI_ACLK_FREQ_HZ,
    C_S_AXI_ADDR_WIDTH     => C_S_AXI_ADDR_WIDTH,
    C_S_AXI_DATA_WIDTH     => C_S_AXI_DATA_WIDTH,
    C_S_AXI_ID_WIDTH       => C_S_AXI_ID_WIDTH,
    C_TYPE                 => C_TYPE,
      -- 0 - Soft TEMAC capable of 10 or 100 Mbps
      -- 1 - Soft TEMAC capable of 10, 100, or 1000 Mbps
      -- 2 - V6 hard TEMAC
    C_PHY_TYPE             => C_PHY_TYPE,
      -- 0 - MII
      -- 1 - GMII
      -- 2 - RGMII V1.3
      -- 3 - RGMII V2.0
      -- 4 - SGMII
      -- 5 - 1000Base-X PCS/PMA @ 1 Gbps
      -- 6 - 1000Base-X PCS/PMA @ 2 Gbps (C_TYPE=2 only)
      -- 7 - 1000Base-X PCS/PMA @ 2.5 Gbps (C_TYPE=2 only)
    C_HALFDUP              => C_HALFDUP,
    C_TXMEM                => C_TXMEM,
    C_RXMEM                => C_RXMEM,
    C_TXCSUM               => C_TXCSUM,
      -- 0 - No checksum offloading
      -- 1 - Partial (legacy) checksum offloading
      -- 2 - Full checksum offloading
    C_RXCSUM               => C_RXCSUM,
      -- 0 - No checksum offloading
      -- 1 - Partial (legacy) checksum offloading
      -- 2 - Full checksum offloading
    C_TXVLAN_TRAN          => C_TXVLAN_TRAN,
    C_RXVLAN_TRAN          => C_RXVLAN_TRAN,
    C_TXVLAN_TAG           => C_TXVLAN_TAG,
    C_RXVLAN_TAG           => C_RXVLAN_TAG,
    C_TXVLAN_STRP          => C_TXVLAN_STRP,
    C_RXVLAN_STRP          => C_RXVLAN_STRP,
    C_MCAST_EXTEND         => C_MCAST_EXTEND,
    C_STATS                => C_STATS,
    C_AVB                  => C_AVB,
    C_AT_ENTRIES           => C_AT_ENTRIES,
    C_SIMULATION           => C_SIMULATION
  )
  port map (
    S_AXI_ACLK              => S_AXI_ACLK,              -- in
    S_AXI_ARESETN           => S_AXI_ARESETN,            -- in
    INTERRUPT               => INTERRUPT,               -- out
    BUS2IP_CLK              => bus2ip_clk,              -- out
    BUS2IP_RESET            => bus2ip_reset,            -- out

    EMAC_CLIENT_AUTONEG_INT => emac_client_autoneg_int, -- in
    EMAC_RESET_DONE_INT     => emac_reset_done_int,     -- in
    EMAC_RX_DCM_LOCKED_INT  => emac_rx_dcm_locked_int,  -- in
    PCSPMA_STATUS_VECTOR    => pcspma_status_vector,    -- in

    -- AXI Lite signals
    S_AXI_AWADDR            => S_AXI_AWADDR,
    S_AXI_AWVALID           => S_AXI_AWVALID,
    S_AXI_AWREADY           => S_AXI_AWREADY,
    S_AXI_WDATA             => S_AXI_WDATA,
    S_AXI_WSTRB             => S_AXI_WSTRB,
    S_AXI_WVALID            => S_AXI_WVALID,
    S_AXI_WREADY            => S_AXI_WREADY,
    S_AXI_BRESP             => S_AXI_BRESP,
    S_AXI_BVALID            => S_AXI_BVALID,
    S_AXI_BREADY            => S_AXI_BREADY,
    S_AXI_ARADDR            => S_AXI_ARADDR,
    S_AXI_ARVALID           => S_AXI_ARVALID,
    S_AXI_ARREADY           => S_AXI_ARREADY,
    S_AXI_RDATA             => S_AXI_RDATA,
    S_AXI_RRESP             => S_AXI_RRESP,
    S_AXI_RVALID            => S_AXI_RVALID,
    S_AXI_RREADY            => S_AXI_RREADY,

    SHIM2IP_DATA            => shim2ip_data,        -- out
    SHIM2IP_ADDR            => shim2ip_addr,        -- out
    SHIM2IP_R_NW            => shim2ip_r_nw,        -- out

    shim2temac_CS           => shim2temac_cs,      -- out
    shim2temac_RD_CE        => shim2temac_rd_ce,   -- out
    shim2temac_WR_CE        => shim2temac_wr_ce,   -- out
    temac2bus_WR_ACK        => shim2temac_avb_wr_ack,   -- in
    temac2bus_RD_ACK        => shim2temac_avb_rd_ack,   -- in
    temac2bus_DATA          => temac2bus_data,     -- in
    temac2bus_ERROR         => temac2bus_error,    -- in
    TEMAC_IPIC2GHI_INTR     => mac_irq, -- in

    shim2avb_cs             => shim2avb_cs,       -- out
    shim2avb_rd_ce          => shim2avb_rd_ce,    -- out
    shim2avb_wr_ce          => shim2avb_wr_ce,    -- out
    avb2bus_wr_ack          => '0',    -- in
    avb2bus_rd_ack          => '0',    -- in
    avb2bus_data            => avb2bus_data,      -- in
    avb2bus_error           => shim2temac_avb_error,     -- in

    -- AXI Stream signals
    AXI_STR_TXD_ACLK       => AXI_STR_TXD_ACLK,
    AXI_STR_TXD_ARESETN    => AXI_STR_TXD_ARESETN,
    AXI_STR_TXD_TVALID     => AXI_STR_TXD_TVALID,
    AXI_STR_TXD_TREADY     => AXI_STR_TXD_TREADY,
    AXI_STR_TXD_TLAST      => AXI_STR_TXD_TLAST,
    AXI_STR_TXD_TSTRB      => AXI_STR_TXD_TKEEP,
    AXI_STR_TXD_TDATA      => AXI_STR_TXD_TDATA,

    AXI_STR_TXC_ACLK       => AXI_STR_TXC_ACLK,
    AXI_STR_TXC_ARESETN    => AXI_STR_TXC_ARESETN,
    AXI_STR_TXC_TVALID     => AXI_STR_TXC_TVALID,
    AXI_STR_TXC_TREADY     => AXI_STR_TXC_TREADY,
    AXI_STR_TXC_TLAST      => AXI_STR_TXC_TLAST,
    AXI_STR_TXC_TSTRB      => AXI_STR_TXC_TKEEP,
    AXI_STR_TXC_TDATA      => AXI_STR_TXC_TDATA,

    AXI_STR_RXD_ACLK       => AXI_STR_RXD_ACLK,
    AXI_STR_RXD_ARESETN    => AXI_STR_RXD_ARESETN,
    AXI_STR_RXD_VALID      => AXI_STR_RXD_TVALID,
    AXI_STR_RXD_READY      => AXI_STR_RXD_TREADY,
    AXI_STR_RXD_LAST       => AXI_STR_RXD_TLAST,
    AXI_STR_RXD_STRB       => AXI_STR_RXD_TKEEP,
    AXI_STR_RXD_DATA       => AXI_STR_RXD_TDATA,

    AXI_STR_RXS_ACLK       => AXI_STR_RXS_ACLK,
    AXI_STR_RXS_ARESETN    => AXI_STR_RXS_ARESETN,
    AXI_STR_RXS_VALID      => AXI_STR_RXS_TVALID,
    AXI_STR_RXS_READY      => AXI_STR_RXS_TREADY,
    AXI_STR_RXS_LAST       => AXI_STR_RXS_TLAST,
    AXI_STR_RXS_STRB       => AXI_STR_RXS_TKEEP,
    AXI_STR_RXS_DATA       => AXI_STR_RXS_TDATA,


    -- TEMAC Interface
    ------------------------
    pause_req               => pause_req,
    pause_val               => pause_val,

    RX_CLK_ENABLE_IN        => rx_clk_enable_out,
    rx_statistics_vector    => rx_statistics_vector,
    rx_statistics_valid     => rx_statistics_valid,

    rx_mac_aclk             => to_embedded_top_rx_mac_aclk,
    rx_reset                => to_embedded_top_rx_reset,
    rx_axis_mac_tdata       => to_embedded_top_rx_axis_mac_tdata,
    rx_axis_mac_tvalid      => to_embedded_top_rx_axis_mac_tvalid,
    rx_axis_mac_tlast       => to_embedded_top_rx_axis_mac_tlast,
    rx_axis_mac_tuser       => to_embedded_top_rx_axis_mac_tuser,

    tx_ifg_delay            => tx_ifg_delay,
    tx_statistics_vector    => tx_statistics_vector,
    tx_statistics_valid     => tx_statistics_valid,

    tx_mac_aclk             => tx_mac_aclk,
    tx_reset                => tx_reset,
    tx_axis_mac_tdata       => tx_axis_mac_tdata,
    tx_axis_mac_tvalid      => tx_axis_mac_tvalid,
    tx_axis_mac_tlast       => tx_axis_mac_tlast,
    tx_axis_mac_tuser       => tx_axis_mac_tuser,
    tx_axis_mac_tready      => tx_axis_mac_tready_int,
    tx_collision            => tx_collision_int,
    tx_retransmit           => tx_retransmit_int,

    tx_avb_en               => tx_avb_en,              -- added for avb connection 03/21/2011

    -- Legacy transmitter interface
    legacy_tx_data          => legacy_tx_data,
    legacy_tx_data_valid    => legacy_tx_data_valid,
    legacy_tx_underrun      => legacy_tx_underrun,
    legacy_tx_ack           => legacy_tx_ack,

    speed_is_10_100         => speed_is_10_100,               -- in

    RESET2TEMAC             => reset2temac,                    -- out
    -- Ethernet System signals -----------------------------------------------
    PHY_RST_N               => PHY_RST_N,

    -- GTX_CLK 125 MHz clock
    GTX_CLK                 => GTX_CLK,

    -- AVB signals -----------------------------------------------------------
    LEGACY_RX_FILTER_MATCH  => legacy_rx_filter_match, -- in

    RTC_CLK                 => RTC_CLK

  );

end imp;
