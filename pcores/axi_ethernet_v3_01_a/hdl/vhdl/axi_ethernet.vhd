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
-- Structure:   This section shows the hierarchical structure of axi_ethernet.
--
--              axi_ethernet_v3_01_a
--              |
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
--              | | | |-<FIFO_GENERATOR>
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

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Ports :
-------------------------------------------------------------------------------
--System signals
-- S_AXI_ACLK            -- AXI Clock
-- S_AXI_ARESETN         -- AXI Reset
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
    C_S_AXI_ACLK_FREQ_HZ   : INTEGER                       := 100000000;
    --  Frequency of the AXI clock in Hertz auto computed by the tools
    C_S_AXI_ADDR_WIDTH     : integer range 32 to 32        := 32;
    C_S_AXI_DATA_WIDTH     : integer range 32 to 32        := 32;
    C_S_AXI_ID_WIDTH       : INTEGER range 1 to 4          := 4;
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
    C_SIMULATION          : integer                       := 0
  );
  port (
    -- System signals ---------------------------------------------------------
    S_AXI_ACLK               : in  std_logic;                           --  AXI4-Lite Clk
    S_AXI_ARESETN            : in  std_logic;                           --  AXI4-Lite reset

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
    AXI_STR_TXD_TKEEP        : in  std_logic_vector(7 downto 0);        --  AXI-Stream Transmit Data Keep
    AXI_STR_TXD_TDATA        : in  std_logic_vector(63 downto 0);       --  AXI-Stream Transmit Data Data

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
    AXI_STR_RXD_TKEEP        : out std_logic_vector(7 downto 0);        --  AXI-Stream Receive Data Keep
    AXI_STR_RXD_TDATA        : out std_logic_vector(63 downto 0);       --  AXI-Stream Receive Data Data

    AXI_STR_RXS_ACLK         : in  std_logic;                           --  AXI-Stream Receive Status Clk
    AXI_STR_RXS_ARESETN      : in  std_logic;                           --  AXI-Stream Receive Status Reset
    AXI_STR_RXS_TVALID       : out std_logic;                           --  AXI-Stream Receive Status Valid
    AXI_STR_RXS_TREADY       : in  std_logic;                           --  AXI-Stream Receive Status Ready
    AXI_STR_RXS_TLAST        : out std_logic;                           --  AXI-Stream Receive Status Last
    AXI_STR_RXS_TKEEP        : out std_logic_vector(3 downto 0);        --  AXI-Stream Receive Status Keep
    AXI_STR_RXS_TDATA        : out std_logic_vector(31 downto 0);       --  AXI-Stream Receive Status Data

    rx_mac_aclk              : in  std_logic;
    rx_reset                 : in  std_logic;
    rx_axis_mac_tdata        : in  std_logic_vector(63 downto 0);
    rx_axis_mac_tvalid       : in  std_logic;
    rx_axis_mac_tkeep        : in  std_logic_vector(7 downto 0);
    rx_axis_mac_tlast        : in  std_logic;
    rx_axis_mac_tuser        : in  std_logic;
    rx_axis_mac_tready       : out std_logic;

    tx_mac_aclk              : in  std_logic;
    tx_reset                 : in  std_logic;
    tx_axis_mac_tdata        : out std_logic_vector(63 downto 0);
    tx_axis_mac_tvalid       : out std_logic;
    tx_axis_mac_tkeep        : out std_logic_vector(7 downto 0);
    tx_axis_mac_tlast        : out std_logic;
    tx_axis_mac_tuser        : out std_logic;
    tx_axis_mac_tready       : in std_logic

  );
end axi_ethernet;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture imp of axi_ethernet is


  ---------------------------------------------------------------------------
  -- Signal declarations
  ---------------------------------------------------------------------------

  signal axitxd_aclk               : std_logic;
  signal axitxc_aclk               : std_logic;
  signal axirxd_aclk               : std_logic;
  signal axirxs_aclk               : std_logic;

  attribute keep                        : boolean;                                
  attribute keep of  axitxd_aclk   : signal is true;
  attribute keep of  axitxc_aclk   : signal is true;
  attribute keep of  axirxd_aclk   : signal is true;
  attribute keep of  axirxs_aclk   : signal is true;


  signal  AXIS_ETH_TXD_TVALID             : std_logic;
  signal  AXIS_ETH_TXD_TREADY             : std_logic;
  signal  AXIS_ETH_TXD_TLAST              : std_logic;
  signal  AXIS_ETH_TXD_TKEEP              : std_logic_vector(7 downto 0);
  signal  AXIS_ETH_TXD_TDATA              : std_logic_vector(63 downto 0);
  signal  AXIS_ETH_TXC_TVALID             : std_logic;
  signal  AXIS_ETH_TXC_TREADY             : std_logic;
  signal  AXIS_ETH_TXC_TLAST              : std_logic;
  signal  AXIS_ETH_TXC_TKEEP              : std_logic_vector(3 downto 0);
  signal  AXIS_ETH_TXC_TDATA              : std_logic_vector(31 downto 0);

begin

  axitxd_aclk <= AXI_STR_TXD_ACLK;
  axitxc_aclk <= AXI_STR_TXC_ACLK;
  axirxd_aclk <= AXI_STR_RXD_ACLK;
  axirxs_aclk <= AXI_STR_RXS_ACLK;

  I_EMBEDDED_TOP : entity axi_ethernet_v3_01_a.embedded_top(imp)
  generic map (
    C_FAMILY               => C_FAMILY,
    C_S_AXI_ACLK_FREQ_HZ   => C_S_AXI_ACLK_FREQ_HZ,
    C_S_AXI_ADDR_WIDTH     => C_S_AXI_ADDR_WIDTH,
    C_S_AXI_DATA_WIDTH     => C_S_AXI_DATA_WIDTH,
    C_S_AXI_ID_WIDTH       => C_S_AXI_ID_WIDTH,
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
    C_SIMULATION           => C_SIMULATION
  )
  port map (
    S_AXI_ACLK              => S_AXI_ACLK,              -- in
    S_AXI_ARESETN           => S_AXI_ARESETN,           -- in

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

    -- AXI Stream signals
    AXI_STR_TXD_ACLK       => axitxd_aclk,
    AXI_STR_TXD_ARESETN    => AXI_STR_TXD_ARESETN,
    AXI_STR_TXD_TVALID     => AXI_STR_TXD_TVALID,
    AXI_STR_TXD_TREADY     => AXI_STR_TXD_TREADY,
    AXI_STR_TXD_TLAST      => AXI_STR_TXD_TLAST,
    AXI_STR_TXD_TSTRB      => AXI_STR_TXD_TKEEP,
    AXI_STR_TXD_TDATA      => AXI_STR_TXD_TDATA,

    AXI_STR_TXC_ACLK       => axitxc_aclk,
    AXI_STR_TXC_ARESETN    => AXI_STR_TXC_ARESETN,
    AXI_STR_TXC_TVALID     => AXI_STR_TXC_TVALID,
    AXI_STR_TXC_TREADY     => AXI_STR_TXC_TREADY,
    AXI_STR_TXC_TLAST      => AXI_STR_TXC_TLAST,
    AXI_STR_TXC_TSTRB      => AXI_STR_TXC_TKEEP,
    AXI_STR_TXC_TDATA      => AXI_STR_TXC_TDATA,

    AXI_STR_RXD_ACLK       => axirxd_aclk,
    AXI_STR_RXD_ARESETN    => AXI_STR_RXD_ARESETN,
    AXI_STR_RXD_VALID      => open,
    AXI_STR_RXD_READY      => '0',
    AXI_STR_RXD_LAST       => open,
    AXI_STR_RXD_STRB       => open,
    AXI_STR_RXD_DATA       => open,

    AXI_STR_RXS_ACLK       => axirxs_aclk,
    AXI_STR_RXS_ARESETN    => AXI_STR_RXS_ARESETN,
    AXI_STR_RXS_VALID      => open,
    AXI_STR_RXS_READY      => '0',
    AXI_STR_RXS_LAST       => open,
    AXI_STR_RXS_STRB       => open,
    AXI_STR_RXS_DATA       => open,

    -- 10GEMAC Interface
    ------------------------
    rx_mac_aclk             => rx_mac_aclk,
    rx_reset                => rx_reset,
    rx_axis_mac_tdata       => rx_axis_mac_tdata,
    rx_axis_mac_tvalid      => rx_axis_mac_tvalid,
    rx_axis_mac_tkeep       => rx_axis_mac_tkeep,
    rx_axis_mac_tlast       => rx_axis_mac_tlast,
    rx_axis_mac_tuser       => rx_axis_mac_tuser,

    tx_mac_aclk             => tx_mac_aclk,
    tx_reset                => tx_reset,
    tx_axis_mac_tdata       => tx_axis_mac_tdata,
    tx_axis_mac_tvalid      => tx_axis_mac_tvalid,
    tx_axis_mac_tkeep       => tx_axis_mac_tkeep,
    tx_axis_mac_tlast       => tx_axis_mac_tlast,
    tx_axis_mac_tuser       => tx_axis_mac_tuser,
    tx_axis_mac_tready      => tx_axis_mac_tready

  );

  I_AXI_ETH_RX: entity axi_ethernet_v3_01_a.axi_eth_rx(rtl)
  port map (
    clk   => AXI_STR_RXD_ACLK,
    reset => rx_reset,

    AXI_STR_RXD_TVALID => AXI_STR_RXD_TVALID,
    AXI_STR_RXD_TREADY => AXI_STR_RXD_TREADY,
    AXI_STR_RXD_TLAST  => AXI_STR_RXD_TLAST,
    AXI_STR_RXD_TKEEP  => AXI_STR_RXD_TKEEP,
    AXI_STR_RXD_TDATA  => AXI_STR_RXD_TDATA,

    AXI_STR_RXS_TVALID => AXI_STR_RXS_TVALID,
    AXI_STR_RXS_TREADY => AXI_STR_RXS_TREADY,
    AXI_STR_RXS_TLAST  => AXI_STR_RXS_TLAST,
    AXI_STR_RXS_TKEEP  => AXI_STR_RXS_TKEEP,
    AXI_STR_RXS_TDATA  => AXI_STR_RXS_TDATA,

    rx_axis_mac_tdata  => rx_axis_mac_tdata,
    rx_axis_mac_tvalid => rx_axis_mac_tvalid,
    rx_axis_mac_tkeep  => rx_axis_mac_tkeep,
    rx_axis_mac_tlast  => rx_axis_mac_tlast,
    rx_axis_mac_tready => rx_axis_mac_tready,
    rx_axis_mac_tuser  => rx_axis_mac_tuser
  );

end imp;
