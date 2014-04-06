-------------------------------------------------------------------------------
-- embedded_top.vhd
-- Author     : Xilinx Inc.
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
-- Filename:        embedded_top.vhd
-- Version:         v1.00a
-- Description:     top level of embedded_top
--
-------------------------------------------------------------------------------
-- Structure:   This section shows the hierarchical structure of axi_uartlite.
--
--              embedded_top.vhd
--                axi_ethernt_soft_temac_wrap.vhd
--                axi_lite_ipif.vhd
-------------------------------------------------------------------------------
-- Author:          MSH & MW
-- History:
--  MSH & MW     07/01/10
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

entity embedded_top is
  generic (
    --  System Generics
    C_FAMILY               : string                        := "virtex6";
    C_S_AXI_ACLK_FREQ_HZ   : INTEGER                       := 100000000;
    --  Frequency of the AXI clock in Hertz auto computed by the tools
    C_S_AXI_ADDR_WIDTH     : integer range 32 to 32        := 32;
    C_S_AXI_DATA_WIDTH     : integer range 32 to 32        := 32;
    C_S_AXI_ID_WIDTH       : INTEGER range 1 to 16          := 16;
    -- auto computed by the tools
    --  Ethernet Generics
    C_TYPE                 : integer range 0 to 2          := 0;
      -- 0 - Soft TEMAC capable of 10 or 100 Mbps
      -- 1 - Soft TEMAC capable of 10, 100, or 1000 Mbps
      -- 2 - V6 hard TEMAC
    C_PHY_TYPE             : integer range 0 to 7          := 1;
      -- 0 - MII
      -- 1 - GMII
      -- 2 - RGMII V1.3
      -- 3 - RGMII V2.0
      -- 4 - SGMII
      -- 5 - 1000Base-X PCS/PMA @ 1 Gbps
      -- 6 - 1000Base-X PCS/PMA @ 2 Gbps (C_TYPE=2 only)
      -- 7 - 1000Base-X PCS/PMA @ 2.5 Gbps (C_TYPE=2 only)
    C_HALFDUP              : integer range 0 to 1          := 0;
    C_TXMEM                : integer                       := 4096;
    C_RXMEM                : integer                       := 4096;
    C_TXCSUM               : integer range 0 to 2          := 0;
      -- 0 - No checksum offloading
      -- 1 - Partial (legacy) checksum offloading
      -- 2 - Full checksum offloading
    C_RXCSUM               : integer range 0 to 2          := 0;
      -- 0 - No checksum offloading
      -- 1 - Partial (legacy) checksum offloading
      -- 2 - Full checksum offloading
    C_TXVLAN_TRAN          : integer range 0 to 1          := 0;
    C_RXVLAN_TRAN          : integer range 0 to 1          := 0;
    C_TXVLAN_TAG           : integer range 0 to 1          := 0;
    C_RXVLAN_TAG           : integer range 0 to 1          := 0;
    C_TXVLAN_STRP          : integer range 0 to 1          := 0;
    C_RXVLAN_STRP          : integer range 0 to 1          := 0;
    C_MCAST_EXTEND         : integer range 0 to 1          := 0;
    C_STATS                : integer range 0 to 1          := 0;
    C_AVB                  : integer range 0 to 1          := 0;
    C_AT_ENTRIES           : integer                       := 8;
    C_SIMULATION           : integer                       := 0
  );
  port (
    -- System signals ---------------------------------------------------------
    S_AXI_ACLK              : in  std_logic;                                        --  AXI4-Lite Clk
    S_AXI_ARESETN           : in  std_logic;                                        --  AXI4-Lite reset
    INTERRUPT               : out std_logic;                                        --  AXI Ethernet Interrupt
    BUS2IP_CLK              : out std_logic;                                        --  AXI4-Lite Clk to top level
    BUS2IP_RESET            : out std_logic;                                        --  AXI4-Lite Reset to top level

    EMAC_CLIENT_AUTONEG_INT : in  std_logic;                                        --  Auto negotiation signal from EMAC
    EMAC_RESET_DONE_INT     : in  std_logic;                                        --  Reset Done signal from EMAC
    EMAC_RX_DCM_LOCKED_INT  : in  std_logic;                                        --  DCM Locked signal from EMAC
    PCSPMA_STATUS_VECTOR    : in  std_logic_vector(15 downto 0);                    --  Link Status vector from PCS/PMA core

    -- AXI Lite signals
    S_AXI_AWADDR            : in  std_logic_vector                                  --  AXI4-Lite Write Addr
                             (C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWVALID           : in  std_logic;                                        --  AXI4-Lite Write Addr Valid
    S_AXI_AWREADY           : out std_logic;                                        --  AXI4-Lite Write Addr Ready
    S_AXI_WDATA             : in  std_logic_vector                                  --  AXI4-Lite Write Data
                             (C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB             : in  std_logic_vector                                  --  AXI4-Lite Write Strobe
                             ((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID            : in  std_logic;                                        --  AXI4-Lite Write Valid
    S_AXI_WREADY            : out std_logic;                                        --  AXI4-Lite Write Ready
    S_AXI_BRESP             : out std_logic_vector(1 downto 0);                     --  AXI4-Lite Write Response
    S_AXI_BVALID            : out std_logic;                                        --  AXI4-Lite Write Response Valid
    S_AXI_BREADY            : in  std_logic;                                        --  AXI4-Lite Write Response Ready
    S_AXI_ARADDR            : in  std_logic_vector                                  --  AXI4-Lite Read Addr
                             (C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARVALID           : in  std_logic;                                        --  AXI4-Lite Read Addr Valid
    S_AXI_ARREADY           : out std_logic;                                        --  AXI4-Lite Read Addr Ready
    S_AXI_RDATA             : out std_logic_vector                                  --  AXI4-Lite Read Data
                             (C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP             : out std_logic_vector(1 downto 0);                     --  AXI4-Lite Read Response
    S_AXI_RVALID            : out std_logic;                                        --  AXI4-Lite Read Valid
    S_AXI_RREADY            : in  std_logic;                                        --  AXI4-Lite Read Ready

    SHIM2IP_DATA            : out std_logic_vector(0 to C_S_AXI_DATA_WIDTH - 1 );   --  Addr_response_shim data to AXI E-net
    SHIM2IP_ADDR            : out std_logic_vector(0 to C_S_AXI_ADDR_WIDTH - 1 );   --  Addr_response_shim addr to AXI E-net
    SHIM2IP_R_NW            : out std_logic;                                        --  Addr_response_shim R NW to AXI E-net
    
    SHIM2TEMAC_CS           : out std_logic;                                        --  Addr_response_shim cs to IP
    SHIM2TEMAC_RD_CE        : out std_logic;                                        --  Addr_response_shim rd ce to IP
    SHIM2TEMAC_WR_CE        : out std_logic;                                        --  Addr_response_shim wr ce to IP
    TEMAC2BUS_WR_ACK        : in  std_logic;                                        --  IP wr ack to address response shim
    TEMAC2BUS_RD_ACK        : in  std_logic;                                        --  IP rd ack to address response shim
    TEMAC2BUS_DATA          : in  std_logic_vector(0 to C_S_AXI_DATA_WIDTH - 1 );   --  IP data to address response shim
    TEMAC2BUS_ERROR         : in  std_logic;                                        --  IP error to address response shim
    TEMAC_IPIC2GHI_INTR     : in  std_logic;                                        --  Interrupt

    shim2avb_cs          : out std_logic;                                           --  Addr_response_shim to AVB CS
    shim2avb_rd_ce       : out std_logic;                                           --  Addr_response_shim to AVB RD CE
    shim2avb_wr_ce       : out std_logic;                                           --  Addr_response_shim to AVB WR CE
    avb2bus_wr_ack       : in  std_logic;                                           --  AVB to Addr_response_shim WR ACK
    avb2bus_rd_ack       : in  std_logic;                                           --  AVB to Addr_response_shim RD ACK
    avb2bus_data         : in  std_logic_vector(0 to C_S_AXI_DATA_WIDTH - 1 );      --  AVB to Addr_response_shim Data
    avb2bus_error        : in  std_logic;                                           --  AVB to Addr_response_shim Error

    -- AXI Stream signals
    AXI_STR_TXD_ACLK      : in  std_logic;                                          --  AXI-Stream Transmit Data Clk
    AXI_STR_TXD_ARESETN   : in  std_logic;                                          --  AXI-Stream Transmit Data Reset
    AXI_STR_TXD_TVALID    : in  std_logic;                                          --  AXI-Stream Transmit Data Valid
    AXI_STR_TXD_TREADY    : out std_logic;                                          --  AXI-Stream Transmit Data Ready
    AXI_STR_TXD_TLAST     : in  std_logic;                                          --  AXI-Stream Transmit Data Last
    AXI_STR_TXD_TSTRB     : in  std_logic_vector(3 downto 0);                       --  AXI-Stream Transmit Data Keep
    AXI_STR_TXD_TDATA     : in  std_logic_vector(31 downto 0);                      --  AXI-Stream Transmit Data Data

    AXI_STR_TXC_ACLK      : in  std_logic;                                          --  AXI-Stream Transmit Control Clk
    AXI_STR_TXC_ARESETN   : in  std_logic;                                          --  AXI-Stream Transmit Control Reset
    AXI_STR_TXC_TVALID    : in  std_logic;                                          --  AXI-Stream Transmit Control Valid
    AXI_STR_TXC_TREADY    : out std_logic;                                          --  AXI-Stream Transmit Control Ready
    AXI_STR_TXC_TLAST     : in  std_logic;                                          --  AXI-Stream Transmit Control Last
    AXI_STR_TXC_TSTRB     : in  std_logic_vector(3 downto 0);                       --  AXI-Stream Transmit Control Keep
    AXI_STR_TXC_TDATA     : in  std_logic_vector(31 downto 0);                      --  AXI-Stream Transmit Control Data

    AXI_STR_RXD_ACLK        : in  std_logic;                                        --  AXI-Stream Receive Data Clk
    AXI_STR_RXD_ARESETN     : in  std_logic;                                        --  AXI-Stream Receive Data Reset
    AXI_STR_RXD_VALID       : out std_logic;                                        --  AXI-Stream Receive Data Valid
    AXI_STR_RXD_READY       : in  std_logic;                                        --  AXI-Stream Receive Data Ready
    AXI_STR_RXD_LAST        : out std_logic;                                        --  AXI-Stream Receive Data Last
    AXI_STR_RXD_STRB        : out std_logic_vector(3 downto 0);                     --  AXI-Stream Receive Data Keep
    AXI_STR_RXD_DATA        : out std_logic_vector(31 downto 0);                    --  AXI-Stream Receive Data Data

    AXI_STR_RXS_ACLK        : in  std_logic;                                        --  AXI-Stream Receive Status Clk
    AXI_STR_RXS_ARESETN     : in  std_logic;                                        --  AXI-Stream Receive Status Reset
    AXI_STR_RXS_VALID       : out std_logic;                                        --  AXI-Stream Receive Status Valid
    AXI_STR_RXS_READY       : in  std_logic;                                        --  AXI-Stream Receive Status Ready
    AXI_STR_RXS_LAST        : out std_logic;                                        --  AXI-Stream Receive Status Last
    AXI_STR_RXS_STRB        : out std_logic_vector(3 downto 0);                     --  AXI-Stream Receive Status Keep
    AXI_STR_RXS_DATA        : out std_logic_vector(31 downto 0);                    --  AXI-Stream Receive Status Data

    -- TEMAC Interface
    ------------------------
    pause_req               : out std_logic;                                        -- pause req from register to TEMAC
    pause_val               : out std_logic_vector(16 to 31);                       -- pause value from register to TEMAC                                       

    -- added 05/5/2011     
    RX_CLK_ENABLE_IN        : in std_logic;                                         -- TEMAC clock domain enable

    rx_statistics_vector    : in  std_logic_vector(27 downto 0);                    -- RX statistics from TEMAC
    rx_statistics_valid     : in  std_logic;                                        -- Rx stats valid from TEMAC
                                                            
    rx_mac_aclk             : in  std_logic;                                        -- Rx axistream clock from TEMAC
    rx_reset                : in  std_logic;                                        -- Rx axistream reset from TEMAC
    rx_axis_mac_tdata       : in  std_logic_vector(7 downto 0);                     -- Rx axistream data from TEMAC
    rx_axis_mac_tvalid      : in  std_logic;                                        -- Rx axistream valid from TEMAC
    rx_axis_mac_tlast       : in  std_logic;                                        -- Rx axistream last from TEMAC
    rx_axis_mac_tuser       : in  std_logic;                                        -- Rx axistream good/bad indicator from TEMAC
                                                                           
    tx_ifg_delay            : out std_logic_vector(24 to 31);                       -- interframe gap delay from register to TEMAC
    tx_statistics_vector    : in  std_logic_vector(31 downto 0);                    -- Tx statistics from TEMAC
    tx_statistics_valid     : in  std_logic;                                        -- Tx stats valid from TEMAC
                                                            
    tx_mac_aclk             : in  std_logic;                                        -- Tx axistream clock from TEMAC
    tx_reset                : in  std_logic;                                        -- Tx axistream reset from TEMAC
    tx_axis_mac_tdata       : out std_logic_vector(7 downto 0);                     -- Tx axistream data to TEMAC
    tx_axis_mac_tvalid      : out std_logic;                                        -- Tx axistream valid to TEMAC
    tx_axis_mac_tlast       : out std_logic;                                        -- Tx axistream last to TEMAC
    tx_axis_mac_tuser       : out std_logic;                                        -- Tx axistream underrun indicator to TEMAC
    tx_axis_mac_tready      : in  std_logic;                                        -- Tx axistream ready from TEMAC
    tx_collision            : in  std_logic;                                        -- Tx collision not used from TEMAC
    tx_retransmit           : in  std_logic;                                        -- Tx retransmit not used from TEMAC
    
    tx_avb_en               : in  std_logic;                                        -- added for avb connection 03/21/2011 
    
    -- Legacy transmitter interface
    legacy_tx_data          : out std_logic_vector(7 downto 0);                     -- legacy tx data
    legacy_tx_data_valid    : out std_logic;                                        -- legacy tx data valid
    legacy_tx_underrun      : out std_logic;                                        -- legacy tx underrun
    legacy_tx_ack           : in  std_logic;                                        -- legacy tx ack

    speed_is_10_100         : in  std_logic;                                        -- speed is 10/100 not 1000 indicator
    
    RESET2TEMAC                     : out std_logic;                                --  Reset to TEMAC
    -- Ethernet System signals -----------------------------------------------
    PHY_RST_N                       : out std_logic;                                --  Reset to PHY

    -- GTX_CLK 125 MHz clock
    GTX_CLK                         : in  std_logic;                                --  GTX CLK

    -- AVB signals -----------------------------------------------------------
    LEGACY_RX_FILTER_MATCH          : in  std_logic_vector(C_AT_ENTRIES-1 downto 0); -- Legacy Address filter Match

    RTC_CLK                         : in  std_logic                                 --  Real Time Clock
  );

end embedded_top;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture imp of embedded_top is
  ----------------------------------------------------------------------------
  --  Function Declarations
  ----------------------------------------------------------------------------
  function SetClientWidth (inputPhyType : integer) return integer is
  Variable phytype : Integer := 1;

    begin
      if (inputPhyType = 6 or inputPhyType = 7) then
       -- 16-bit client interface
        phytype := 16;
      else
        -- 8-bit client interface
        phytype := 8;
      end if;
    return(phytype);
  end function SetClientWidth;

  function SetVLANWidth (inputTrans, inputStrip, inputTag : integer) return integer is
  Variable vlanWidth : Integer := 1;

    begin
      if (inputTrans = 0 and inputStrip = 0 and inputTag = 0) then
      --  force to be one for lint where in registers.vhd
      --    axiClkTxVlanRdData_i : std_logic_vector(((31-C_TXVLAN_WIDTH)+1) to 31)
      --    bus width would be 32 to 31
        vlanWidth := 1;
      else

        vlanWidth := ((inputTrans*12) + inputStrip + inputTag);
      end if;
    return(vlanWidth);
  end function SetVLANWidth;


  -- Set client width to either 8 or 16
  constant C_CLIENT_WIDTH : integer := SetClientWidth(C_PHY_TYPE);

  ---------------------------------------------------------------------------
  --  Constant Declarations
  ---------------------------------------------------------------------------
  constant C_NUM_CS              : integer := 10;
  constant C_NUM_CE              : integer := 41;
  constant C_SOFT_SIMULATION     : boolean := (C_SIMULATION = 1);
  constant C_TXVLAN_WIDTH : integer := SetVLANWidth(C_TXVLAN_TRAN,C_TXVLAN_STRP,C_TXVLAN_TAG);
  constant C_RXVLAN_WIDTH : integer := SetVLANWidth(C_RXVLAN_TRAN,C_RXVLAN_STRP,C_RXVLAN_TAG);
  --  constant C_TXVLAN_WIDTH : integer := (C_TXVLAN_TRAN*12) + C_TXVLAN_TAG + C_TXVLAN_STRP;
  --  constant C_RXVLAN_WIDTH : integer := (C_RXVLAN_TRAN*12) + C_RXVLAN_TAG + C_RXVLAN_STRP;

  constant C_ARD_ADDR_RANGE_ARRAY  : SLV64_ARRAY_TYPE :=
    -- Base address and high address pairs.
    (
--      X"00000000" & (C_BASEADDR), -- user0 base address soft registers
--      X"00000000" & (C_HIGHADDR)  -- user0 high address
      X"0000000000000000", -- user0 base address soft registers
      X"000000000003FFFF"  -- user0 high address
    );

  constant C_ARD_NUM_CE_ARRAY   : INTEGER_ARRAY_TYPE :=
    -- This array spcifies the number of Chip Enables (CE) that is
    -- required by the cooresponding baseaddr pair.
    (
      0 =>1
    );

  constant C_S_AXI_MIN_SIZE       : std_logic_vector(31 downto 0)
                                  := X"0003FFFF";

  constant C_USE_WSTRB            : integer := 0;

  constant C_DPHASE_TIMEOUT       : integer := 42;

  ---------------------------------------------------------------------------
  -- Signal declarations
  ---------------------------------------------------------------------------
  signal bus2ip_clk_i                 : std_logic;
  signal bus2ip_reset_i               : std_logic;
  signal bus2ip_reset_n_i             : std_logic;

  signal bus2shim_cs                  : std_logic_vector(0 to 0);
  signal bus2shim_rd_ce               : std_logic_vector(0 to 0);
  signal bus2shim_wr_ce               : std_logic_vector(0 to 0);
  signal bus2shim_addr                : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH - 1 );
  signal bus2shim_data                : std_logic_vector(0 to C_S_AXI_DATA_WIDTH - 1 );
  signal bus2shim_r_nw                : std_logic;
  signal shim2bus_data                : std_logic_vector (0 to C_S_AXI_DATA_WIDTH - 1 );
  signal shim2bus_wr_ack              : std_logic;
  signal shim2bus_rd_ack              : std_logic;

  signal shim2ip_cs                   : std_logic_vector(0 to C_NUM_CS);
  signal shim2ip_rd_ce                : std_logic_vector(0 to C_NUM_CE);
  signal shim2ip_wr_ce                : std_logic_vector(0 to C_NUM_CE);
  signal shim2ip_addr_i               : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH - 1 );
  signal shim2ip_data_i               : std_logic_vector(0 to C_S_AXI_DATA_WIDTH - 1 );
  signal shim2ip_r_nw_i               : std_logic;
  signal ip2shim_data                 : std_logic_vector (0 to C_S_AXI_DATA_WIDTH - 1 );
  signal ip2shim_wr_ack               : std_logic;
  signal ip2shim_rd_ack               : std_logic;
  signal ip2shim_error                : std_logic;

  signal intrpts2reg                  : std_logic_vector(23 to 31);
  signal tx_pause_request             : std_logic;
  signal cr_reg_data                  : std_logic_vector(17 to 31);
  signal tx_pause_reg_data_i          : std_logic_vector(16 to 31);
  signal tx_ifg_delay_i              : std_logic_vector(24 to 31);
  signal is_reg_data                  : std_logic_vector(23 to 31);
  signal ip_reg_data                  : std_logic_vector(23 to 31);
  signal ie_reg_data                  : std_logic_vector(23 to 31);
  signal ttag_reg_data                : std_logic_vector(0 to 31);
  signal rtag_reg_data                : std_logic_vector(0 to 31);
  signal tpid0_reg_data               : std_logic_vector(0 to 31);
  signal tpid1_reg_data               : std_logic_vector(0 to 31);
  signal uawl_reg_data                : std_logic_vector(0 to 31);
  signal uawu_reg_data                : std_logic_vector(16 to 31);
  signal reg_ip2bus_wr_ack            : std_logic;
  signal reg_ip2bus_rd_ack            : std_logic;
  signal reg_ip2bus_data              : std_logic_vector(0 to 31);

  signal reset2axi                    : std_logic;
  signal reset2axi_n                  : std_logic;
  signal reset2axi_str_txd            : std_logic;
  signal reset2axi_str_txc            : std_logic;
  signal reset2axi_str_rxd            : std_logic;
  signal reset2axi_str_rxs            : std_logic;
  signal reset2gtx_clk                : std_logic;

  signal phy_reset_cmplte_intr        : std_logic;

  signal rx_cl_clk_rx_tag_reg_data    : std_logic_vector(0 to 31);
  signal rx_cl_clk_tpid0_reg_data     : std_logic_vector(0 to 31);
  signal rx_cl_clk_tpid1_reg_data     : std_logic_vector(0 to 31);
  signal rx_cl_clk_uawl_reg_data      : std_logic_vector(0 to 31);
  signal rx_cl_clk_uawu_reg_data      : std_logic_vector(16 to 31);
  signal rx_cl_clk_raf_reg_data       : std_logic_vector(17 to 31);

  signal rx_cl_clk_mcast_addr         : std_logic_vector(0 to 14);
  signal rx_cl_clk_mcast_en           : std_logic;
  signal rx_cl_clk_mcast_rd_data      : std_logic_vector(0 to 0);

  signal rx_cl_clk_vlan_addr          : std_logic_vector(0 to 11);
  signal rx_cl_clk_vlan_rd_data       : std_logic_vector(18 to 31);
  signal rx_cl_clk_vlan_bram_en_a     : std_logic;
  signal axiStrTxDClk_vlan_addr       : std_logic_vector(11 downto 0);
  signal axiStrTxDClk_vlan_rd_data    : std_logic_vector(13 downto 0);
  signal axiStrTxDClk_vlan_bram_en_a  : std_logic;

  signal rx_cl_clk_bad_frame_enbl     : std_logic;
  signal rx_cl_clk_emulti_fltr_enbl   : std_logic;
  signal rx_cl_clk_new_fnc_enbl       : std_logic;
  signal rx_cl_clk_brdcast_rej        : std_logic;
  signal rx_cl_clk_mulcast_rej        : std_logic;
  signal rx_cl_clk_vstrp_mode         : std_logic_vector(0 to 1);
  signal rx_cl_clk_vtag_mode          : std_logic_vector(0 to 1);

  signal reset2rx_client              : std_logic;
  signal reset2tx_client              : std_logic;

  signal rxclclk_frame_received_intrpt     : std_logic;
  signal rxclclk_frame_rejected_intrpt     : std_logic;
  signal rxclclk_buffer_mem_overflow_intrpt: std_logic;
  signal axiclk_frame_received_intrpt     : std_logic;
  signal axiclk_frame_rejected_intrpt     : std_logic;
  signal axiclk_buffer_mem_overflow_intrpt: std_logic;

  --  Tx Clock Crossing Signals
  signal tx_cr_reg_data                  : std_logic_vector(4 downto 0);
  signal tx_axi_lite_2_txd_strm_raf_data : std_logic_vector(4 downto 0);
  signal TEMAC_IPIC2GHI_INTR_CROSS       : std_logic;
  signal EMAC_CLIENT_AUTONEG_INT_TXCROSS : std_logic;
  signal EMAC_CLIENT_AUTONEG_INT_RXCROSS : std_logic;
  signal EMAC_CLIENT_AUTONEG_INT_CROSS   : std_logic;
  signal tx_cmplt_cross                  : std_logic;
  signal EMAC_RX_DCM_LOCKED_CROSS        : std_logic;
  signal EMAC_RESET_DONE_TXCROSS         : std_logic;
  signal EMAC_RESET_DONE_RXCROSS         : std_logic;
  signal EMAC_RESET_DONE_CROSS           : std_logic;
  signal phy_reset_cmplte_intr_cross     : std_logic;
  signal tx_cmplt                        : std_logic;

  signal tpid0_reg_data_cross            : std_logic_vector(15 downto 0);
  signal tpid1_reg_data_cross            : std_logic_vector(15 downto 0);
  signal tpid2_reg_data_cross            : std_logic_vector(15 downto 0);
  signal tpid3_reg_data_cross            : std_logic_vector(15 downto 0);

  signal enable_newFncEn                 : std_logic; --Only perform VLAN when the FLAG = 0xA
  signal newFncEn_cross                  : std_logic;
  signal transMode_cross                 : std_logic;
  signal tagMode_cross                   : std_logic_vector( 1 downto 0);
  signal strpMode_cross                  : std_logic_vector( 1 downto 0);

  signal tpid0_cross                     : std_logic_vector(15 downto 0);
  signal tpid1_cross                     : std_logic_vector(15 downto 0);
  signal tpid2_cross                     : std_logic_vector(15 downto 0);
  signal tpid3_cross                     : std_logic_vector(15 downto 0);

  signal newTagData_cross                : std_logic_vector(31 downto 0);

  signal pcspma_status_cross             : std_logic_vector(16 to 31);

  signal tx_init_in_prog                 : std_logic;
  signal tx_init_in_prog_cross           : std_logic;


begin

  rx_cl_clk_bad_frame_enbl   <= rx_cl_clk_raf_reg_data(17);
  rx_cl_clk_emulti_fltr_enbl <= rx_cl_clk_raf_reg_data(19);
  rx_cl_clk_new_fnc_enbl     <= rx_cl_clk_raf_reg_data(20);
  rx_cl_clk_vstrp_mode       <= rx_cl_clk_raf_reg_data(21 to 22);
  rx_cl_clk_vtag_mode        <= rx_cl_clk_raf_reg_data(25 to 26);
  rx_cl_clk_brdcast_rej      <= rx_cl_clk_raf_reg_data(29);
  rx_cl_clk_mulcast_rej      <= rx_cl_clk_raf_reg_data(30);

  BUS2IP_CLK      <= bus2ip_clk_i;
  BUS2IP_RESET    <= bus2ip_reset_i;
  SHIM2IP_DATA    <= shim2ip_data_i;
  SHIM2IP_ADDR    <= shim2ip_addr_i;
  SHIM2IP_R_NW    <= shim2ip_r_nw_i;
  
  SHIM2TEMAC_CS    <= shim2ip_cs(1);  
  SHIM2TEMAC_RD_CE <= shim2ip_rd_ce(16);
  SHIM2TEMAC_WR_CE <= shim2ip_wr_ce(16);
  shim2avb_cs        <= shim2ip_cs(4);  
  shim2avb_rd_ce     <= shim2ip_rd_ce(19);
  shim2avb_wr_ce     <= shim2ip_wr_ce(19);

  intrpts2reg(31) <= TEMAC_IPIC2GHI_INTR_CROSS;
  intrpts2reg(30) <= EMAC_CLIENT_AUTONEG_INT_CROSS;
  intrpts2reg(29) <= axiclk_frame_received_intrpt; --rx complete
  intrpts2reg(28) <= axiclk_frame_rejected_intrpt; --rx reject
  intrpts2reg(27) <= axiclk_buffer_mem_overflow_intrpt; --rx mem overflow
  intrpts2reg(26) <= tx_cmplt_cross;    --'0'; --tx_cmplt_cross --fix mee - need to implement!!!!!                                       
  intrpts2reg(25) <= EMAC_RX_DCM_LOCKED_CROSS;
  intrpts2reg(24) <= EMAC_RESET_DONE_CROSS;
  intrpts2reg(23) <= phy_reset_cmplte_intr_cross;

  RXCLCLK2AXICLK_INTRPT0 : entity axi_ethernet_v3_01_a.actv_hi_pulse_clk_cross(imp)
  port map    (
    ClkA               => rx_mac_aclk,
    ClkARst            => reset2rx_client,
    ClkASignalIn       => rxclclk_frame_received_intrpt,
    ClkB               => S_AXI_ACLK,
    ClkBRst            => reset2axi,
    ClkBSignalOut      => axiclk_frame_received_intrpt
  );

  RXCLCLK2AXICLK_INTRPT1 : entity axi_ethernet_v3_01_a.actv_hi_pulse_clk_cross(imp)
  port map    (
    ClkA               => rx_mac_aclk,
    ClkARst            => reset2rx_client,
    ClkASignalIn       => rxclclk_frame_rejected_intrpt,
    ClkB               => S_AXI_ACLK,
    ClkBRst            => reset2axi,
    ClkBSignalOut      => axiclk_frame_rejected_intrpt
  );

  RXCLCLK2AXICLK_INTRPT2 : entity axi_ethernet_v3_01_a.actv_hi_pulse_clk_cross(imp)
  port map    (
    ClkA               => rx_mac_aclk,
    ClkARst            => reset2rx_client,
    ClkASignalIn       => rxclclk_buffer_mem_overflow_intrpt,
    ClkB               => S_AXI_ACLK,
    ClkBRst            => reset2axi,
    ClkBSignalOut      => axiclk_buffer_mem_overflow_intrpt
  );
  
 
  COMBINE_RESETS : entity axi_ethernet_v3_01_a.reset_combiner(imp)
  generic map (
    C_SIMULATION       => C_SIMULATION
  )
  port map    (
    S_AXI_ACLK           => S_AXI_ACLK,
    S_AXI_ARESETN        => S_AXI_ARESETN,
    GTX_CLK_125MHZ       => GTX_CLK,
    RX_CLIENT_CLK        => rx_mac_aclk,
    RX_CLIENT_CLK_EN     => '1', --RX_CLIENT_CLK_ENBL,
    TX_CLIENT_CLK        => tx_mac_aclk,
    TX_CLIENT_CLK_EN     => '1', --TX_CLIENT_CLK_ENBL,
    AXI_STR_TXD_ACLK     => AXI_STR_TXD_ACLK,
    AXI_STR_TXD_ARESETN  => AXI_STR_TXD_ARESETN,
    AXI_STR_TXC_ACLK     => AXI_STR_TXC_ACLK,
    AXI_STR_TXC_ARESETN  => AXI_STR_TXC_ARESETN,
    AXI_STR_RXD_ACLK     => AXI_STR_RXD_ACLK,
    AXI_STR_RXD_ARESETN  => AXI_STR_RXD_ARESETN,
    AXI_STR_RXS_ACLK     => AXI_STR_RXS_ACLK,
    AXI_STR_RXS_ARESETN  => AXI_STR_RXS_ARESETN,
    PHY_RESET_N          => PHY_RST_N, -- >= 10mS as req'd by PHY spec
    PHY_RESET_CMPLTE     => phy_reset_cmplte_intr, -- >= 15mS as req'd by PHY spec
    RESET2AXI            => reset2axi,
    RESET2RX_CLIENT      => reset2rx_client,
    RESET2TX_CLIENT      => reset2tx_client,
    RESET2AXI_STR_TXD    => reset2axi_str_txd,
    RESET2AXI_STR_TXC    => reset2axi_str_txc,
    RESET2AXI_STR_RXD    => reset2axi_str_rxd,
    RESET2AXI_STR_RXS    => reset2axi_str_rxs,
    reset2gtx_clk        => reset2gtx_clk
  );
  
  reset2axi_n      <= not(reset2axi);
--  RESET2STATISTICS <= reset2axi;
  RESET2TEMAC      <= reset2axi;
  --------------------------------------------------------------------------
  -- REG_RD_WR_DATA_PROCESS
  --------------------------------------------------------------------------
  REG_RD_WR_DATA_PROCESS : process (bus2ip_clk_i)
  begin
    if (bus2ip_clk_i'event and bus2ip_clk_i = '1') then
      if (bus2ip_reset_i = '1') then
        ip2shim_data   <= (others => '0');
        ip2shim_rd_ack <= '0';
        ip2shim_wr_ack <= '0';
        ip2shim_error  <= '0';
      else
        --ip2shim_data   <= TEMAC2BUS_data   or reg_ip2bus_data   or avb2bus_data;
        --ip2shim_data   <= TEMAC2BUS_data   or reg_ip2bus_data   or avb2bus_data;
       -- ip2shim_rd_ack <= TEMAC2BUS_rd_ack or reg_ip2bus_rd_ack or avb2bus_rd_ack;
       -- ip2shim_wr_ack <= TEMAC2BUS_wr_ack or reg_ip2bus_wr_ack or avb2bus_wr_ack;
      --  ip2shim_error  <= TEMAC2BUS_error  or avb2bus_error;
        ip2shim_data   <= TEMAC2BUS_data   or reg_ip2bus_data   ;
        ip2shim_rd_ack <= TEMAC2BUS_rd_ack or reg_ip2bus_rd_ack ;
        ip2shim_wr_ack <= TEMAC2BUS_wr_ack or reg_ip2bus_wr_ack ;
        ip2shim_error  <= TEMAC2BUS_error  ;
      end if;
    end if;
  end process;
  
  I_REGISTERS : entity axi_ethernet_v3_01_a.registers(imp)
  generic map (
    C_FAMILY       => C_FAMILY,
    C_TXVLAN_TRAN  => C_TXVLAN_TRAN,
    C_TXVLAN_TAG   => C_TXVLAN_TAG,
    C_TXVLAN_STRP  => C_TXVLAN_STRP,
    C_STATS        => C_STATS,
    C_RXVLAN_TRAN  => C_RXVLAN_TRAN,
    C_RXVLAN_TAG   => C_RXVLAN_TAG,
    C_RXVLAN_STRP  => C_RXVLAN_STRP,
    C_MCAST_EXTEND => C_MCAST_EXTEND,
    C_TXVLAN_WIDTH => C_TXVLAN_WIDTH,
    C_RXVLAN_WIDTH => C_RXVLAN_WIDTH
  )
  port map    (
    AxiClk                    => bus2ip_clk_i,      -- in
    Stats_clk                 => GTX_CLK,         --: in
    Host_clk                  => bus2ip_clk_i,       --: in
    AXI_STR_TXD_ACLK          => AXI_STR_TXD_ACLK,
    TxClClk                   => tx_mac_aclk,   --: in 
    RxClClk                   => rx_mac_aclk,   --: in                 
    AxiReset                  => bus2ip_reset_i,     -- in  from top level system
    IP2Bus_Data               => reg_ip2bus_data, -- out to shim
    IP2Bus_WrAck              => reg_ip2bus_wr_ack,-- out to shim
    IP2Bus_RdAck              => reg_ip2bus_rd_ack,-- out to shim
    Bus2IP_Addr               => shim2ip_addr_i,    -- in  from shim
    Bus2IP_Data               => shim2ip_data_i,    -- in  from shim
    Bus2IP_RNW                => shim2ip_r_nw_i,    -- in  from shim
    Bus2IP_CS                 => shim2ip_cs  ,    -- in  from shim
    Bus2IP_RdCE               => shim2ip_rd_ce,    -- in  from shim
    Bus2IP_WrCE               => shim2ip_wr_ce,    -- in  from shim
    IntrptsIn                 => intrpts2reg,    -- in
    TPReq                     => tx_pause_request,           -- out
    CrRegData                 => cr_reg_data,       -- out
    TpRegData                 => tx_pause_reg_data_i,       -- out
    IfgpRegData               => tx_ifg_delay_i,     -- out 
    IsRegData                 => is_reg_data,       -- out
    IpRegData                 => ip_reg_data,       -- out
    IeRegData                 => ie_reg_data,       -- out
    IntrptOut                 => INTERRUPT,       -- out
    TtagRegData               => ttag_reg_data,     -- out
    RtagRegData               => rtag_reg_data,     -- out
    Tpid0RegData              => tpid0_reg_data,    -- out
    Tpid1RegData              => tpid1_reg_data,    -- out
    pcspma_status_cross       => pcspma_status_cross,
    UawLRegData               => uawl_reg_data,           -- out
    UawURegData               => uawu_reg_data,           -- out
    RxClClkMcastAddr          => rx_cl_clk_mcast_addr,      -- in
    RxClClkMcastEn            => rx_cl_clk_mcast_en,        -- in
    RxClClkMcastRdData        => rx_cl_clk_mcast_rd_data,    -- out
    AxiStrTxDClkTxVlanAddr    => axiStrTxDClk_vlan_addr,   -- in
    AxiStrTxDClkTxVlanRdData  => axiStrTxDClk_vlan_rd_data, -- out
    RxClClkRxVlanAddr         => rx_cl_clk_vlan_addr,   -- in
    RxClClkRXVlanRdData       => rx_cl_clk_vlan_rd_data, -- out
    AxiStrTxDClkTxVlanBramEnA => axiStrTxDClk_vlan_bram_en_a,-- in
    RxClClkRxVlanBramEnA      => rx_cl_clk_vlan_bram_en_a -- in
  );

  --------------------------------------------------------------------------
  -- Instantiate AXI lite IPIF
  --------------------------------------------------------------------------
  AXI_LITE_IPIF_I : entity axi_lite_ipif_v1_01_a.axi_lite_ipif
  generic map (
    C_FAMILY                  => C_FAMILY,
    C_S_AXI_ADDR_WIDTH        => C_S_AXI_ADDR_WIDTH,
    C_S_AXI_DATA_WIDTH        => C_S_AXI_DATA_WIDTH,
    C_S_AXI_MIN_SIZE          => C_S_AXI_MIN_SIZE,
    C_USE_WSTRB               => C_USE_WSTRB,
    C_DPHASE_TIMEOUT          => C_DPHASE_TIMEOUT,
    C_ARD_ADDR_RANGE_ARRAY    => C_ARD_ADDR_RANGE_ARRAY,
    C_ARD_NUM_CE_ARRAY        => C_ARD_NUM_CE_ARRAY
  )
  port map (
    S_AXI_ACLK     =>  S_AXI_ACLK,
    S_AXI_ARESETN  =>  reset2axi_n,
    S_AXI_AWADDR   =>  S_AXI_AWADDR,
    S_AXI_AWVALID  =>  S_AXI_AWVALID,
    S_AXI_AWREADY  =>  S_AXI_AWREADY,
    S_AXI_WDATA    =>  S_AXI_WDATA,
    S_AXI_WSTRB    =>  S_AXI_WSTRB,
    S_AXI_WVALID   =>  S_AXI_WVALID,
    S_AXI_WREADY   =>  S_AXI_WREADY,
    S_AXI_BRESP    =>  S_AXI_BRESP,
    S_AXI_BVALID   =>  S_AXI_BVALID,
    S_AXI_BREADY   =>  S_AXI_BREADY,
    S_AXI_ARADDR   =>  S_AXI_ARADDR,
    S_AXI_ARVALID  =>  S_AXI_ARVALID,
    S_AXI_ARREADY  =>  S_AXI_ARREADY,
    S_AXI_RDATA    =>  S_AXI_RDATA,
    S_AXI_RRESP    =>  S_AXI_RRESP,
    S_AXI_RVALID   =>  S_AXI_RVALID,
    S_AXI_RREADY   =>  S_AXI_RREADY,

    -- IP Interconnect (IPIC) port signals
    BUS2IP_CLK     => bus2ip_clk_i,
    BUS2IP_RESETN  => bus2ip_reset_n_i,
    IP2BUS_DATA    => shim2bus_data ,
    IP2BUS_WRACK   => shim2bus_wr_ack,
    IP2BUS_RDACK   => shim2bus_rd_ack,
    IP2BUS_ERROR   => ip2shim_error,
    BUS2IP_ADDR    => bus2shim_addr,
    BUS2IP_DATA    => bus2shim_data,
    BUS2IP_RNW     => bus2shim_r_nw ,
    BUS2IP_BE      => open,
    BUS2IP_CS      => bus2shim_cs  ,
    BUS2IP_RDCE    => bus2shim_rd_ce,
    BUS2IP_WRCE    => bus2shim_wr_ce
  );

  bus2ip_reset_i <= not(bus2ip_reset_n_i);

  -- Instantiate the Address response shim for invalid addresses
  I_ADDR_SHIM : entity axi_ethernet_v3_01_a.addr_response_shim(rtl)
  generic map(
    C_BUS2CORE_CLK_RATIO      => 1,
    C_S_AXI_ADDR_WIDTH        => C_S_AXI_ADDR_WIDTH,
    C_S_AXI_DATA_WIDTH        => C_S_AXI_DATA_WIDTH,
    C_SIPIF_DWIDTH            => 32,
    C_NUM_CS                  => C_NUM_CS,
    C_NUM_CE                  => C_NUM_CE,
    C_FAMILY                  => C_FAMILY
  )
  port map(
    -- clock and reset
    S_AXI_ACLK                => bus2ip_clk_i,
    S_AXI_ARESET              => bus2ip_reset_i,

    -- slave AXI bus interface with shim
    BUS2SHIM_ADDR             => bus2shim_addr,
    BUS2SHIM_DATA             => bus2shim_data,
    BUS2SHIM_RNW              => bus2shim_r_nw ,
    BUS2SHIM_CS               => bus2shim_cs  ,
    BUS2SHIM_RDCE             => bus2shim_rd_ce,
    BUS2SHIM_WRCE             => bus2shim_wr_ce,

    SHIM2BUS_DATA             => shim2bus_data ,
    SHIM2BUS_WRACK            => shim2bus_wr_ack,
    SHIM2BUS_RDACK            => shim2bus_rd_ack,

    -- internal interface with shim
    SHIM2IP_ADDR              => shim2ip_addr_i,
    SHIM2IP_DATA              => shim2ip_data_i,
    SHIM2IP_RNW               => shim2ip_r_nw_i,
    SHIM2IP_CS                => shim2ip_cs  ,
    SHIM2IP_RDCE              => shim2ip_rd_ce,
    SHIM2IP_WRCE              => shim2ip_wr_ce,

    IP2SHIM_DATA              => ip2shim_data,
    IP2SHIM_WRACK             => ip2shim_wr_ack,
    IP2SHIM_RDACK             => ip2shim_rd_ack
  );

  TAG_REG_CROSS_I : entity axi_ethernet_v3_01_a.bus_clk_cross(imp)
  generic map (
    C_BUS_WIDTH  => 32
  )
  port map(
    Clk_A_BUS_IN    =>  rtag_reg_data,
    Clk_B           =>  rx_mac_aclk,
    Clk_B_Rst       =>  reset2rx_client,
    Clk_B_BUS_OUT   =>  rx_cl_clk_rx_tag_reg_data
  );

  TPID0_REG_CROSS_I : entity axi_ethernet_v3_01_a.bus_clk_cross(imp)
  generic map (
    C_BUS_WIDTH  => 32
  )
  port map(
    Clk_A_BUS_IN    =>  tpid0_reg_data,
    Clk_B           =>  rx_mac_aclk,
    Clk_B_Rst       =>  reset2rx_client,
    Clk_B_BUS_OUT   =>  rx_cl_clk_tpid0_reg_data
  );

  TPID1_REG_CROSS_I : entity axi_ethernet_v3_01_a.bus_clk_cross(imp)
  generic map (
    C_BUS_WIDTH  => 32
  )
  port map(
    Clk_A_BUS_IN    =>  tpid1_reg_data,
    Clk_B           =>  rx_mac_aclk,
    Clk_B_Rst       =>  reset2rx_client,
    Clk_B_BUS_OUT   =>  rx_cl_clk_tpid1_reg_data
  );

  UAWL_REG_CROSS_I : entity axi_ethernet_v3_01_a.bus_clk_cross(imp)
  generic map (
    C_BUS_WIDTH  => 32
  )
  port map(
    Clk_A_BUS_IN    =>  uawl_reg_data,
    Clk_B           =>  rx_mac_aclk,
    Clk_B_Rst       =>  reset2rx_client,
    Clk_B_BUS_OUT   =>  rx_cl_clk_uawl_reg_data
  );

  UAWU_REG_CROSS_I : entity axi_ethernet_v3_01_a.bus_clk_cross(imp)
  generic map (
    C_BUS_WIDTH  => 16
  )
  port map(
    Clk_A_BUS_IN    =>  uawu_reg_data,
    Clk_B           =>  rx_mac_aclk,
    Clk_B_Rst       =>  reset2rx_client,
    Clk_B_BUS_OUT   =>  rx_cl_clk_uawu_reg_data
  );

  RAF_REG_CROSS_I : entity axi_ethernet_v3_01_a.bus_clk_cross(imp)
  generic map (
    C_BUS_WIDTH  => 15
  )
  port map(
    Clk_A_BUS_IN    =>  cr_reg_data,
    Clk_B           =>  rx_mac_aclk,
    Clk_B_Rst       =>  reset2rx_client,
    Clk_B_BUS_OUT   =>  rx_cl_clk_raf_reg_data
  );
  
  
  
  
  PCSPMA_STATUS_CROSS_I : entity axi_ethernet_v3_01_a.bus_clk_cross(imp)
  generic map (
    C_BUS_WIDTH  => 16
  )
  port map(
    Clk_A_BUS_IN    =>  pcspma_status_vector,
    Clk_B           =>  S_AXI_ACLK,
    Clk_B_Rst       =>  reset2axi,
    Clk_B_BUS_OUT   =>  pcspma_status_cross
  );  
  
  
  
  
----------------------------------------------------------------------------
--  Tx Interface Clock Crossing - Start
----------------------------------------------------------------------------

  GEN_TX_VLAN_NEWFNCEN_CROSS : if C_TXVLAN_STRP = 1 or C_TXVLAN_TAG = 1 or C_TXVLAN_TRAN = 1 generate
    signal tx_NewFncEnbl : std_logic;
  begin
  
    --  RAF Register Clock crossing
    tx_NewFncEnbl <= cr_reg_data(20) and enable_newFncEn;          --  NewFncEnbl
    
    NEWFNCENBL_AXILITE_2_AXITXDSTRM : entity axi_ethernet_v3_01_a.actv_hi_pulse_clk_cross(imp)
    port map    (
      ClkA               => S_AXI_ACLK,
      ClkARst            => reset2axi,
      ClkASignalIn       => tx_NewFncEnbl,
      ClkB               => AXI_STR_TXD_ACLK,
      ClkBRst            => reset2axi_str_txd,
      ClkBSignalOut      => newFncEn_cross
    );   
  end generate;
  
  GEN_NO_TX_VLAN_NEWFNCEN_CROSS : if not(C_TXVLAN_STRP = 1 or C_TXVLAN_TAG = 1 or C_TXVLAN_TRAN = 1) generate
  begin
  
    newFncEn_cross <= '0';  
  end generate;
    
  
  GEN_TX_VLAN_TRANS_ENABLE : if C_TXVLAN_TRAN = 1 generate
  begin
  
    transMode_cross <= newFncEn_cross;
  end generate;

  GEN_NO_TX_VLAN_TRANS_ENABLE : if C_TXVLAN_TRAN = 0 generate
  begin

    transMode_cross <= '0';
  end generate;  
  
  
    

  GEN_TX_VLAN_STRP_CROSS : if C_TXVLAN_STRP = 1 generate
    signal tx_StripMode : std_logic_vector(1 downto 0);
    signal reset_strp   : std_logic;
  begin
  
    tx_StripMode  <= cr_reg_data(23 to 24);    --  TxVStripMode
    reset_strp    <= reset2axi_str_txd or not newFncEn_cross;
    
    TX_STRP_CROSS_I : entity axi_ethernet_v3_01_a.bus_clk_cross(imp)
    generic map (
      C_BUS_WIDTH  => 2
    )
    port map(
      Clk_A_BUS_IN    =>  tx_StripMode,
      Clk_B           =>  AXI_STR_TXD_ACLK,
      Clk_B_Rst       =>  reset_strp,
      Clk_B_BUS_OUT   =>  strpMode_cross 
    ); 
  end generate;
        
  GEN_NO_TX_VLAN_STRP_CROSS : if C_TXVLAN_STRP = 0 generate
  begin
    strpMode_cross <= (others => '0'); 
  end generate;        
        
    
  GEN_TX_VLAN_TAG_CROSS : if C_TXVLAN_TAG = 1 generate
    signal tx_TagMode : std_logic_vector(1 downto 0);
    signal reset_tag  : std_logic;
  begin
  
    tx_TagMode   <= cr_reg_data(27 to 28);    --  TxVTagMode  
    reset_tag    <= reset2axi_str_txd or not newFncEn_cross;
    
    TX_STRP_CROSS_I : entity axi_ethernet_v3_01_a.bus_clk_cross(imp)
    generic map (
      C_BUS_WIDTH  => 2
    )
    port map(
      Clk_A_BUS_IN    =>  tx_TagMode,
      Clk_B           =>  AXI_STR_TXD_ACLK,
      Clk_B_Rst       =>  reset_tag,
      Clk_B_BUS_OUT   =>  tagMode_cross 
    ); 
  end generate;
        
  GEN_NO_TX_VLAN_TAG_CROSS : if C_TXVLAN_TAG = 0 generate
  begin
    tagMode_cross <= (others => '0'); 
  end generate;   
  
  
  
--  TX_PAUSE_REG_DATA     <= tx_pause_reg_data_i;
--  pause_req <= tx_pause_request;
  --  Transmit Pause Frame Clock crossing
  --    Data must to stay in sync with request
  TX_PAUSE_FRAME_CROSS_I : entity axi_ethernet_v3_01_a.bus_and_enable_clk_cross(imp)
  generic map (
    C_BUS_WIDTH  => 16
  )
  port map(
    ClkA          => S_AXI_ACLK,            
    ClkA_EN       => '1',                   
    ClkARst       => reset2axi,             
    ClkASignalIn  => tx_pause_request,       
    ClkABusIn     => tx_pause_reg_data_i,          
    ClkB          => tx_mac_aclk,          
    ClkB_EN       => tx_avb_en, --TX_CLIENT_CLK_ENBL,           
    ClkBRst       => reset2tx_client,              
    ClkBSignalOut => pause_req,  
    ClkBBusOut    => pause_val 
  );   
  
--  tx_ifg_delay         <= tx_ifg_delay_i;  
  TX_IFGP_CROSS_I : entity axi_ethernet_v3_01_a.bus_clk_cross(imp)
  generic map (
    C_BUS_WIDTH  => 8
  )
  port map(
    Clk_A_BUS_IN    =>  tx_ifg_delay_i,
    Clk_B           =>  tx_mac_aclk,
    Clk_B_Rst       =>  reset2tx_client,
    Clk_B_BUS_OUT   =>  tx_ifg_delay
  );  
  
  
  HOSTCLCLK2AXICLK_ISR_0 : entity axi_ethernet_v3_01_a.actv_hi_pulse_clk_cross(imp)
  port map    (
    ClkA               => bus2ip_clk_i,
    ClkARst            => bus2ip_reset_i,
    ClkASignalIn       => TEMAC_IPIC2GHI_INTR,
    ClkB               => S_AXI_ACLK,
    ClkBRst            => reset2axi,
    ClkBSignalOut      => TEMAC_IPIC2GHI_INTR_CROSS
  );  
  
  
  TXCLCLK2AXICLK_ISR_1 : entity axi_ethernet_v3_01_a.actv_hi_pulse_clk_cross(imp)
  port map    (
    ClkA               => tx_mac_aclk,
    ClkARst            => reset2tx_client,
    ClkASignalIn       => EMAC_CLIENT_AUTONEG_INT,
    ClkB               => S_AXI_ACLK,
    ClkBRst            => reset2axi,
    ClkBSignalOut      => EMAC_CLIENT_AUTONEG_INT_TXCROSS
  );    
 
  
  RXCLCLK2AXICLK_ISR_1 : entity axi_ethernet_v3_01_a.actv_hi_pulse_clk_cross(imp)
  port map    (
    ClkA               => rx_mac_aclk,
    ClkARst            => reset2rx_client,
    ClkASignalIn       => EMAC_CLIENT_AUTONEG_INT,
    ClkB               => S_AXI_ACLK,
    ClkBRst            => reset2axi,
    ClkBSignalOut      => EMAC_CLIENT_AUTONEG_INT_RXCROSS
  );     
    
  EMAC_CLIENT_AUTONEG_INT_CROSS <= EMAC_CLIENT_AUTONEG_INT_TXCROSS or EMAC_CLIENT_AUTONEG_INT_RXCROSS;  
  
  
  TXCLCLK2AXICLK_ISR_5 : entity axi_ethernet_v3_01_a.actv_hi_pulse_clk_cross(imp)
  port map    (
    ClkA               => tx_mac_aclk,
    ClkARst            => reset2tx_client,
    ClkASignalIn       => tx_cmplt,
    ClkB               => S_AXI_ACLK,
    ClkBRst            => reset2axi,
    ClkBSignalOut      => tx_cmplt_cross
  );     
  
  
  RXCLCLK2AXICLK_ISR_6 : entity axi_ethernet_v3_01_a.actv_hi_pulse_clk_cross(imp)
  port map    (
    ClkA               => rx_mac_aclk,
    ClkARst            => reset2rx_client,
    ClkASignalIn       => EMAC_RX_DCM_LOCKED_INT,
    ClkB               => S_AXI_ACLK,
    ClkBRst            => reset2axi,
    ClkBSignalOut      => EMAC_RX_DCM_LOCKED_CROSS
  );     
  

  TXCLCLK2AXICLK_ISR_7 : entity axi_ethernet_v3_01_a.actv_hi_pulse_clk_cross(imp)
  port map    (
    ClkA               => tx_mac_aclk,
    ClkARst            => reset2tx_client,
    ClkASignalIn       => EMAC_RESET_DONE_INT,
    ClkB               => S_AXI_ACLK,
    ClkBRst            => reset2axi,
    ClkBSignalOut      => EMAC_RESET_DONE_TXCROSS
  );

          
  RXCLCLK2AXICLK_ISR_7 : entity axi_ethernet_v3_01_a.actv_hi_pulse_clk_cross(imp)
  port map    (
    ClkA               => rx_mac_aclk,
    ClkARst            => reset2rx_client,
    ClkASignalIn       => EMAC_RESET_DONE_INT,
    ClkB               => S_AXI_ACLK,
    ClkBRst            => reset2axi,
    ClkBSignalOut      => EMAC_RESET_DONE_RXCROSS    
  );     
   
  EMAC_RESET_DONE_CROSS <=  EMAC_RESET_DONE_TXCROSS or EMAC_RESET_DONE_RXCROSS;
  

  TXCLCLK2AXICLK_ISR_8 : entity axi_ethernet_v3_01_a.actv_hi_pulse_clk_cross(imp)
  port map    (
    ClkA               => GTX_CLK,
    ClkARst            => reset2gtx_clk,
    ClkASignalIn       => phy_reset_cmplte_intr,
    ClkB               => S_AXI_ACLK,
    ClkBRst            => reset2axi,
    ClkBSignalOut      => phy_reset_cmplte_intr_cross
  );  
  
  GEN_TX_VLAN_TAG_BUS_CROSS : if C_TXVLAN_TAG = 1 generate
  begin
    TX_VLAN_TAG_CROSS_I : entity axi_ethernet_v3_01_a.bus_clk_cross(imp)
    generic map (                                                                       
      C_BUS_WIDTH  => 32                                                                
    )                                                                                   
    port map(
      Clk_A_BUS_IN    =>  ttag_reg_data,
      Clk_B           =>  AXI_STR_TXD_ACLK,
      Clk_B_Rst       =>  reset2axi_str_txd,
      Clk_B_BUS_OUT   =>  newTagData_cross 
    );    
  end generate;
  
  GEN_NO_TX_VLAN_TAG_BUS_CROSS : if C_TXVLAN_TAG /= 1 generate
  begin
    newTagData_cross <= (others => '0');
  end generate;  
  
  GEN_TX_VLAN_TPID_CROSS : if C_TXVLAN_STRP = 1 or C_TXVLAN_TAG = 1 or C_TXVLAN_TRAN = 1 generate
  begin
    TX_VLAN_TPID0_CROSS_I : entity axi_ethernet_v3_01_a.bus_clk_cross(imp)
    generic map (
      C_BUS_WIDTH  => 16
    )
    port map(
      Clk_A_BUS_IN    =>  tpid0_reg_data(16 to 31),
      Clk_B           =>  AXI_STR_TXD_ACLK,
      Clk_B_Rst       =>  reset2axi_str_txd,
      Clk_B_BUS_OUT   =>  tpid0_cross 
    );     
  
    TX_VLAN_TPID1_CROSS_I : entity axi_ethernet_v3_01_a.bus_clk_cross(imp)
    generic map (
      C_BUS_WIDTH  => 16
    )
    port map(
      Clk_A_BUS_IN    =>  tpid0_reg_data(0 to 15),
      Clk_B           =>  AXI_STR_TXD_ACLK,
      Clk_B_Rst       =>  reset2axi_str_txd,
      Clk_B_BUS_OUT   =>  tpid1_cross 
    );    
    
    TX_VLAN_TPID2_CROSS_I : entity axi_ethernet_v3_01_a.bus_clk_cross(imp)
    generic map (
      C_BUS_WIDTH  => 16
    )
    port map(
      Clk_A_BUS_IN    =>  tpid1_reg_data(16 to 31),
      Clk_B           =>  AXI_STR_TXD_ACLK,
      Clk_B_Rst       =>  reset2axi_str_txd,
      Clk_B_BUS_OUT   =>  tpid2_cross 
    );     
    
    TX_VLAN_TPID3_CROSS_I : entity axi_ethernet_v3_01_a.bus_clk_cross(imp)
    generic map (
      C_BUS_WIDTH  => 16
    )
    port map(
      Clk_A_BUS_IN    =>  tpid1_reg_data(0 to 15),
      Clk_B           =>  AXI_STR_TXD_ACLK,
      Clk_B_Rst       =>  reset2axi_str_txd,
      Clk_B_BUS_OUT   =>  tpid3_cross 
    );   
  end generate; 
  
  GEN_NO_TX_VLAN_TPID_CROSS : if not (C_TXVLAN_STRP = 1 or C_TXVLAN_TAG = 1 or C_TXVLAN_TRAN = 1) generate
  begin
    tpid0_cross <= (others => '0');
    tpid1_cross <= (others => '0');
    tpid2_cross <= (others => '0');
    tpid3_cross <= (others => '0');
  end generate;

  AXITX_2_TXCLIENT_FSM_GO : entity axi_ethernet_v3_01_a.actv_hi_reset_clk_cross(imp)
  port map    (
    ClkA               => AXI_STR_TXC_ACLK,     --: in  std_logic;
    ClkAEN             => '1',                  --: in  std_logic;
    ClkARst            => tx_init_in_prog,      --: in  std_logic;
    ClkAOutOfClkBRst   => open,                 --: out std_logic;
    ClkACombinedRstOut => open,                 --: out std_logic;
    ClkB               => tx_mac_aclk,        --: in  std_logic;
    ClkBEN             => '1', --TX_CLIENT_CLK_ENBL,   --: in  std_logic;
    ClkBRst            => reset2tx_client,      --: in  std_logic;             
    ClkBOutOfClkARst   => open,                 --: out std_logic;
    ClkBCombinedRstOut => tx_init_in_prog_cross --: out std_logic    
  ); 
  
    
    
----------------------------------------------------------------------------
--  Tx Interface Clock Crossing - End
----------------------------------------------------------------------------  
  
  --------------------------------------------------------------------------
  -- Instantiate receive interface
  --------------------------------------------------------------------------
  RCV_INTFCE_I : entity axi_ethernet_v3_01_a.rx_if(rtl)
  generic map (
    C_FAMILY                  => C_FAMILY,
    C_TYPE                    => C_TYPE,
    C_PHY_TYPE                => C_PHY_TYPE,
    C_RXCSUM                  => C_RXCSUM,
    C_RXMEM                   => C_RXMEM,
    C_RXVLAN_TRAN             => C_RXVLAN_TRAN,
    C_RXVLAN_TAG              => C_RXVLAN_TAG,
    C_RXVLAN_STRP             => C_RXVLAN_STRP,
    C_MCAST_EXTEND            => C_MCAST_EXTEND,
    C_AVB                     => C_AVB,
    C_STATS                   => C_STATS
  )
  port map(
    RX_FRAME_RECEIVED_INTRPT        => rxclclk_frame_received_intrpt,
    RX_FRAME_REJECTED_INTRPT        => rxclclk_frame_rejected_intrpt,
    RX_BUFFER_MEM_OVERFLOW_INTRPT   => rxclclk_buffer_mem_overflow_intrpt,

    AXI_STR_RXD_ACLK                =>  AXI_STR_RXD_ACLK,
    AXI_STR_RXD_VALID               =>  AXI_STR_RXD_VALID,
    AXI_STR_RXD_READY               =>  AXI_STR_RXD_READY,
    AXI_STR_RXD_LAST                =>  AXI_STR_RXD_LAST,
    AXI_STR_RXD_STRB                =>  AXI_STR_RXD_STRB,
    AXI_STR_RXD_DATA                =>  AXI_STR_RXD_DATA,
    RESET2AXI_STR_RXD               =>  reset2axi_str_rxd,
   
    AXI_STR_RXS_ACLK                =>  AXI_STR_RXS_ACLK,
    AXI_STR_RXS_VALID               =>  AXI_STR_RXS_VALID,
    AXI_STR_RXS_READY               =>  AXI_STR_RXS_READY,
    AXI_STR_RXS_LAST                =>  AXI_STR_RXS_LAST,
    AXI_STR_RXS_STRB                =>  AXI_STR_RXS_STRB,
    AXI_STR_RXS_DATA                =>  AXI_STR_RXS_DATA,
    RESET2AXI_STR_RXS               =>  reset2axi_str_rxs,


    RX_CLK_ENABLE_IN                =>  RX_CLK_ENABLE_IN,
    rx_statistics_vector            =>  rx_statistics_vector,  
    rx_statistics_valid             =>  rx_statistics_valid,   
    rxspeedis10100                  =>  speed_is_10_100,
                                                          
    rx_mac_aclk                     =>  rx_mac_aclk,           
    rx_reset                        =>  rx_reset,              
    rx_axis_mac_tdata               =>  rx_axis_mac_tdata,     
    rx_axis_mac_tvalid              =>  rx_axis_mac_tvalid,    
    rx_axis_mac_tlast               =>  rx_axis_mac_tlast,     
    rx_axis_mac_tuser               =>  rx_axis_mac_tuser,     
    
    RX_CL_CLK_RX_TAG_REG_DATA       =>  rx_cl_clk_rx_tag_reg_data,  
    RX_CL_CLK_TPID0_REG_DATA        =>  rx_cl_clk_tpid0_reg_data,   
    RX_CL_CLK_TPID1_REG_DATA        =>  rx_cl_clk_tpid1_reg_data,   
    RX_CL_CLK_UAWL_REG_DATA         =>  rx_cl_clk_uawl_reg_data,    
    RX_CL_CLK_UAWU_REG_DATA         =>  rx_cl_clk_uawu_reg_data,    
    
    RX_CL_CLK_MCAST_ADDR            =>  rx_cl_clk_mcast_addr,       
    RX_CL_CLK_MCAST_EN              =>  rx_cl_clk_mcast_en,         
    RX_CL_CLK_MCAST_RD_DATA         =>  rx_cl_clk_mcast_rd_data,    
 
    RX_CL_CLK_VLAN_ADDR             =>  rx_cl_clk_vlan_addr,        
    RX_CL_CLK_VLAN_RD_DATA          =>  rx_cl_clk_vlan_rd_data,     
    RX_CL_CLK_VLAN_BRAM_EN_A        =>  rx_cl_clk_vlan_bram_en_a,   

    RX_CL_CLK_BAD_FRAME_ENBL        =>  rx_cl_clk_bad_frame_enbl,
    RX_CL_CLK_EMULTI_FLTR_ENBL      =>  rx_cl_clk_emulti_fltr_enbl, 
    RX_CL_CLK_NEW_FNC_ENBL          =>  rx_cl_clk_new_fnc_enbl,     
    RX_CL_CLK_BRDCAST_REJ           =>  rx_cl_clk_brdcast_rej,
    RX_CL_CLK_MULCAST_REJ           =>  rx_cl_clk_mulcast_rej,
    RX_CL_CLK_VSTRP_MODE            =>  rx_cl_clk_vstrp_mode,       
    RX_CL_CLK_VTAG_MODE             =>  rx_cl_clk_vtag_mode        
  );
      
  
  --------------------------------------------------------------------------
  -- Instantiate receive interface
  --------------------------------------------------------------------------
  TX_INTFCE_I : entity axi_ethernet_v3_01_a.tx_if(imp)
  generic map (
    C_FAMILY                  => C_FAMILY,
    C_TYPE                    => C_TYPE,
    C_PHY_TYPE                => C_PHY_TYPE,
    C_HALFDUP                 => C_HALFDUP,
    C_TXCSUM                  => C_TXCSUM,
    C_TXMEM                   => C_TXMEM,
    C_TXVLAN_TRAN             => C_TXVLAN_TRAN,
    C_TXVLAN_TAG              => C_TXVLAN_TAG,
    C_TXVLAN_STRP             => C_TXVLAN_STRP,
    C_STATS                   => C_STATS,
    C_AVB                     => C_AVB,
    C_S_AXI_ADDR_WIDTH        => C_S_AXI_ADDR_WIDTH,
    C_S_AXI_DATA_WIDTH        => C_S_AXI_DATA_WIDTH,
    C_CLIENT_WIDTH            => C_CLIENT_WIDTH
  )
  port map(
    -- AXI Stream Data signals
    AXI_STR_TXD_ACLK                 => AXI_STR_TXD_ACLK,    
    reset2axi_str_txd                => reset2axi_str_txd, -- from reset_combiner
    AXI_STR_TXD_TVALID               => AXI_STR_TXD_TVALID,   
    AXI_STR_TXD_TREADY               => AXI_STR_TXD_TREADY,   
    AXI_STR_TXD_TLAST                => AXI_STR_TXD_TLAST,    
    AXI_STR_TXD_TSTRB                => AXI_STR_TXD_TSTRB,    
    AXI_STR_TXD_TDATA                => AXI_STR_TXD_TDATA,    
    -- AXI Stream Control signals    
    AXI_STR_TXC_ACLK                 => AXI_STR_TXC_ACLK,    
    reset2axi_str_txc                => reset2axi_str_txc, -- from reset_combiner
    AXI_STR_TXC_TVALID               => AXI_STR_TXC_TVALID,   
    AXI_STR_TXC_TREADY               => AXI_STR_TXC_TREADY,   
    AXI_STR_TXC_TLAST                => AXI_STR_TXC_TLAST,    
    AXI_STR_TXC_TSTRB                => AXI_STR_TXC_TSTRB,    
    AXI_STR_TXC_TDATA                => AXI_STR_TXC_TDATA,
    
    tx_vlan_bram_addr                => axiStrTxDClk_vlan_addr,         -- : out std_logic_vector(11 downto 0);    
    tx_vlan_bram_din                 => axiStrTxDClk_vlan_rd_data,      -- : in  std_logic_vector(13 downto 0);    
    tx_vlan_bram_en                  => axiStrTxDClk_vlan_bram_en_a,    -- : out std_logic;                        
    
    enable_newFncEn                  => enable_newFncEn,             -- : out std_logic; --Only perform VLAN when the FLAG = 0xA    
    transMode_cross                  => transMode_cross,              -- : in  std_logic;                        
    tagMode_cross                    => tagMode_cross,               -- : in  std_logic_vector( 1 downto 0);                        
    strpMode_cross                   => strpMode_cross,              -- : in  std_logic_vector( 1 downto 0);                        
                                                                     --                                                             
    tpid0_cross                      => tpid0_cross,                 -- : in  std_logic_vector(15 downto 0);                        
    tpid1_cross                      => tpid1_cross,                 -- : in  std_logic_vector(15 downto 0);                        
    tpid2_cross                      => tpid2_cross,                 -- : in  std_logic_vector(15 downto 0);                        
    tpid3_cross                      => tpid3_cross,                 -- : in  std_logic_vector(15 downto 0);                        
                                                                     --                                                             
    newTagData_cross                 => newTagData_cross,            -- : in  std_logic_vector(31 downto 0)  
    
    tx_init_in_prog                  => tx_init_in_prog,
    tx_init_in_prog_cross            => tx_init_in_prog_cross,                              
    
    -- Transmit Client Interface Signals

    tx_mac_aclk                      => tx_mac_aclk,          --: in  std_logic;                            
    tx_reset                         => tx_reset,             --: in  std_logic;                            
    tx_axis_mac_tdata                => tx_axis_mac_tdata,    --: out std_logic_vector(7 downto 0);         
    tx_axis_mac_tvalid               => tx_axis_mac_tvalid,   --: out std_logic;                            
    tx_axis_mac_tlast                => tx_axis_mac_tlast,    --: out std_logic;                            
    tx_axis_mac_tuser                => tx_axis_mac_tuser,    --: out std_logic;                            
    tx_axis_mac_tready               => tx_axis_mac_tready,   --: in  std_logic;                            
    tx_collision                     => tx_collision,         --: in  std_logic;                            
    tx_retransmit                    => tx_retransmit,        --: in  std_logic;                            

    tx_client_10_100                 => speed_is_10_100,     --: in  std_logic;                            
    tx_cmplt                         => tx_cmplt,
    
    tx_avb_en                        => tx_avb_en,           -- added for avb connection 03/21/2011 ;
    
  -- Legacy transmitter interface
    legacy_tx_data                   => legacy_tx_data,      
    legacy_tx_data_valid             => legacy_tx_data_valid,
    legacy_tx_underrun               => legacy_tx_underrun,  
    legacy_tx_ack                    => legacy_tx_ack       
  );
      
end imp;
