--------------------------------------------------------------------------------
-- v6_emac_v2_2.vhd
-- Author     : Xilinx Inc.
--------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------
-- This is based on Coregen Wrappers from ISE O.40d (13.1)
-- Wrapper version 2.1
-------------------------------------------------------------------------------
-- Structure:   
--              v6_emac_v2_2.vhd
--
--
--    ---------------------------------------------------------------------
--    | axi_ethernet                                                      |
--    |           --------------------------------------------------------|
--    |           |v6_temac_wrap                                          |
--    |           |                                                       |
--    |           |                                                       |
--    |           |              -----------------------------------------|
--    |           |              | v6_emac_block_xxxx                     |
--    |           |              | xxxx = mii, gmii, rgmii, sgmii, 1000bx |
--    |           |              |                                        |
--    |         --|--------------|--------------|                         |
--    |           |     ipic     |              |                         |
--    |           |     intf     |              |                         |
--    |         <-|--------------|---------|    |                         |
--    |           |              |         |    |                         |
--    |           |              |         |    v                         |
--    |           |              |    ---------------------               |
--    |           |              |    |   v6_emac_v2_2    |               |
--    |           |              |    |                   |               |
--    |           |              |    |                   |               |
--    |           |              |    |                   |               |
--    |           |              |    |                   |               |
--    |           |              |    |                   |               |
--    |           |              |    |      ---------    |  ---------    |
--    |         ->|--------------|--->| Tx   |       |Tx  |--|       |--->|
--    |           |              |    | AXI-S|       |PHY |  |       |    |
--    |           |              |    | I/F  |       |I/F |  |       |    |
--    |           |     AXI-S    |    |      |emac_  |    |  | PHY   |    |
--    |           |              |    |      |wrapper|    |  | I/F   |    |
--    |           |              |    |      |       |    |  |if reqd|    |
--    |           |              |    | Rx   |       |Rx  |  | mii   |    |
--    |           |              |    | AX)-S|       |PHY |  | gmii  |    |
--    |         <-|<-------------|----| I/F  |       |I/F |<-| rgmii |<---|
--    |           |              |    |      ---------    |  ---------    |
--    |           |              |    ---------------------               |
--    |           |              |           |     |                      |
--    |           |              |        --------------                  |
--    |           |              |        |  STATS     |                  |
--    |           |              |        |    DECODE  |                  |
--    |           |              |        |            |                  |
--    |           |              |        --------------                  |
--    |           |              |                                        |
--    |           |              -----------------------------------------|
--    |           --------------------------------------------------------|
--    ---------------------------------------------------------------------
--
------------------------------------------------------------------------------
-- Author:      
-- History:
--
------------------------------------------------------------------------------
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
-- Description:
--  This is a wrapper around the top-level entity for the Gigabit Ethernet MAC.
--  This file will be synthesized by XST
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Library Declarations
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

--------------------------------------------------------------------------------
-- Entity Declaration
--------------------------------------------------------------------------------
  entity v6_emac_v2_2 is
    generic (
      C_EMAC_PAUSEADDR            : bit_vector(47 downto 0) := x"FFEEDDCCBBAA";
      C_EMAC_UNICASTADDR          : bit_vector(47 downto 0) := x"FFEEDDCCBBAA";
      C_EMAC_LINKTIMERVAL         : bit_vector(11 downto 0) := x"13D";
      C_HAS_MII                   : boolean := false;
      C_HAS_GMII                  : boolean := true;
      C_HAS_RGMII_V1_3            : boolean := false;
      C_HAS_RGMII_V2_0            : boolean := false;
      C_HAS_SGMII                 : boolean := false;
      C_HAS_GPCS                  : boolean := false;
      C_TRI_SPEED                 : boolean := false;
      C_SPEED_10                  : boolean := false;
      C_SPEED_100                 : boolean := false;
      C_SPEED_1000                : boolean := true;
      C_HAS_HOST                  : boolean := false;
      C_HAS_DCR                   : boolean := false;
      C_HAS_MDIO                  : boolean := false;
      C_CLIENT_16                 : boolean := false;
      C_OVERCLOCKING_RATE_2000MBPS: boolean := false;
      C_OVERCLOCKING_RATE_2500MBPS: boolean := false;
      C_HAS_CLOCK_ENABLE          : boolean := false;
      C_BYTE_PHY                  : boolean := false;
      C_ADD_FILTER                : boolean := false;
      C_UNICAST_PAUSE_ADDRESS     : string  := "000000000000";
      C_PHY_RESET                 : boolean := false;
      C_PHY_AN                    : boolean := false;
      C_PHY_ISOLATE               : boolean := false;
      C_PHY_POWERDOWN             : boolean := false;
      C_PHY_LOOPBACK_MSB          : boolean := false;
      C_LT_CHECK_DIS              : boolean := false;
      C_CTRL_LENCHECK_DISABLE     : boolean := false;
      C_RX_FLOW_CONTROL           : boolean := false;
      C_TX_FLOW_CONTROL           : boolean := false;
      C_TX_RESET                  : boolean := false;
      C_TX_JUMBO                  : boolean := false;
      C_TX_FCS                    : boolean := false;
      C_TX                        : boolean := true;
      C_TX_VLAN                   : boolean := false;
      C_TX_HALF_DUPLEX            : boolean := false;
      C_TX_IFG                    : boolean := false;
      C_RX_RESET                  : boolean := false;
      C_RX_JUMBO                  : boolean := false;
      C_RX_FCS                    : boolean := false;
      C_RX                        : boolean := true;
      C_RX_VLAN                   : boolean := false;
      C_RX_HALF_DUPLEX            : boolean := false;
      C_DCR_BASE_ADDRESS          : string  := x"00";
      C_LINK_TIMER_VALUE          : string  := x"13d";
      C_PHY_GTLOOPBACK            : boolean := false;
      C_PHY_IGNORE_ADZERO         : boolean := false;
      C_PHY_UNIDIRECTION_ENABLE   : boolean := false;
      SGMII_FABRIC_BUFFER         : boolean := false;
      C_SERIAL_MODE_SWITCH_EN     : boolean := false;
      C_ADD_BUFGS                 : boolean := false;
      
      C_CLIENT_WIDTH              : integer := 8;
      C_PHY_WIDTH                 : integer := 8;
      C_AT_ENTRIES                : integer := 4;
      C_HAS_STATS                 : boolean := true;
      C_NUM_STATS                 : integer := 44;   
      C_CNTR_RST                  : boolean := true;     
      C_STATS_WIDTH               : integer := 64;
      C_INTERNAL_INT              : boolean := false;
      C_AXI_IPIF                  : boolean := true
    );
    port(
      glbl_rstn                   : in std_logic;
      rx_axi_rstn                 : in std_logic;
      tx_axi_rstn                 : in std_logic;

      ---------------------------------------------------------------------------
      -- Clock signals - used in rgmii and serial modes
      ---------------------------------------------------------------------------
      gtx_clk                     : in  std_logic;
      gtx_clk_div2                : in  std_logic;
      tx_axi_clk_out              : out std_logic;
    
      ---------------------------------------------------------------------------
      -- Receiver Interface.
      ---------------------------------------------------------------------------
      rx_axi_clk                  : in std_logic;
      rx_reset_out                : out std_logic;
      rx_axis_mac_tdata           : out std_logic_vector(7 downto 0);
      rx_axis_mac_tkeep           : out std_logic_vector(1 downto 0);
      rx_axis_mac_tvalid          : out std_logic;
      rx_axis_mac_tlast           : out std_logic;
      rx_axis_mac_tuser           : out std_logic;

      -- RX sideband signals

      -- added 05/5/2011     
      RX_CLK_ENABLE_OUT           : out std_logic;

      rx_statistics_vector        : out std_logic_vector(27 downto 0);
      rx_statistics_valid         : out std_logic;
      rx_axis_filter_tuser        : out std_logic_vector(C_AT_ENTRIES downto 0);
      
      ---------------------------------------------------------------------------
      -- Transmitter Interface
      ---------------------------------------------------------------------------
      tx_axi_clk                  : in std_logic;
      tx_reset_out                : out std_logic;
      tx_axis_mac_tdata           : in  std_logic_vector(7 downto 0);
      tx_axis_mac_tkeep           : in  std_logic_vector(1 downto 0);
      tx_axis_mac_tvalid          : in  std_logic;
      tx_axis_mac_tlast           : in  std_logic;
      tx_axis_mac_tuser           : in  std_logic;
      tx_axis_mac_tready          : out std_logic;

      -- TX sideband signals
      tx_retransmit               : out std_logic;
      tx_collision                : out std_logic;
      tx_ifg_delay                : in  std_logic_vector(7 downto 0);
      tx_statistics_vector        : out std_logic_vector(31 downto 0);
      tx_statistics_valid         : out std_logic;
      
      -- added for avb connection 03/21/2011     
      tx_avb_en                   : out std_logic;      

      ---------------------------------------------------------------------------
      -- Statistics Interface
      ---------------------------------------------------------------------------
      stats_ref_clk               : in std_logic;
      increment_vector            : in std_logic_vector(4 to C_NUM_STATS-1);
    
      ---------------------------------------------------------------------------
      -- Flow Control
      ---------------------------------------------------------------------------
      pause_req                   : in  std_logic;
      pause_val                   : in  std_logic_vector(15 downto 0);

      ---------------------------------------------------------------------------
      -- Speed interface
      ---------------------------------------------------------------------------
      speed_is_10_100             : out std_logic;

      ---------------------------------------------------------------------------
      -- GMII/MII Interface
      ---------------------------------------------------------------------------
      gmii_col                    : in  std_logic;
      gmii_crs                    : in  std_logic;
      gmii_txd                    : out std_logic_vector(C_PHY_WIDTH-1 downto 0);
      gmii_tx_en                  : out std_logic;
      gmii_tx_er                  : out std_logic;
      gmii_rxd                    : in  std_logic_vector(C_PHY_WIDTH-1 downto 0);
      gmii_rx_dv                  : in  std_logic;
      gmii_rx_er                  : in  std_logic;

      ---------------------------------------------------------------------------
      -- Serial Phy interface
      ---------------------------------------------------------------------------
      dcm_locked                  : in  std_logic;
      an_interrupt                : out std_logic;
      signal_det                  : in  std_logic;
      phy_ad                      : in  std_logic_vector(4 downto 0);
      en_comma_align              : out std_logic;
      loopback_msb                : out std_logic;
      mgt_rx_reset                : out std_logic;
      mgt_tx_reset                : out std_logic;
      powerdown                   : out std_logic;
      sync_acq_status             : out std_logic;
      rx_clk_cor_cnt              : in  std_logic_vector(2 downto 0);
      rx_buf_status               : in  std_logic;
      rx_char_is_comma            : in  std_logic;
      rx_char_is_k                : in  std_logic;
      rx_disp_err                 : in  std_logic;
      rx_not_in_table             : in  std_logic;
      rx_run_disp                 : in  std_logic;
      tx_buf_err                  : in  std_logic;
      tx_char_disp_mode           : out std_logic;
      tx_char_disp_val            : out std_logic;
      tx_char_is_k                : out std_logic;

      ---------------------------------------------------------------------------
      -- MDIO Interface
      ---------------------------------------------------------------------------
      mdc_out                     : out   std_logic; 
      mdc_in                      : in    std_logic; 
      mdio_in                     : in    std_logic;
      mdio_out                    : out   std_logic;
      mdio_tri                    : out   std_logic;
       
      ---------------------------------------------------------------------------
      -- IPIC Interface
      ---------------------------------------------------------------------------
      
      bus2ip_clk                  : in    std_logic;
      bus2ip_reset                : in    std_logic;
      bus2ip_addr                 : in    std_logic_vector(31 downto 0);
      bus2ip_cs                   : in    std_logic; 
      bus2ip_rdce                 : in    std_logic; 
      bus2ip_wrce                 : in    std_logic; 
      bus2ip_data                 : in    std_logic_vector(31 downto 0);
      ip2bus_data                 : out   std_logic_vector(31 downto 0);
      ip2bus_wrack                : out   std_logic;
      ip2bus_rdack                : out   std_logic;
      ip2bus_error                : out   std_logic;

      mac_irq                     : out std_logic;
      
    --  unicast_address             : in std_logic_vector(47 downto 0);
      base_x_switch               : in std_logic

   );

end v6_emac_v2_2;

architecture xilinx of v6_emac_v2_2 is
 
 signal RX_AXIS_MAC_TKEEP_INT    : std_logic_vector(1 downto 0);
 signal TX_AXIS_MAC_TKEEP_INT    : std_logic_vector(1 downto 0);

 signal GTX_CLK_INT              : std_logic;
 signal GTX_CLK_DIV2_INT         : std_logic;
 
 signal GMII_TXD_INT             : std_logic_vector(7 downto 0);
 signal GMII_RXD_INT             : std_logic_vector(7 downto 0);
 signal GMII_CRS_INT             : std_logic;
 signal GMII_COL_INT             : std_logic;
 signal GMII_RX_ER_INT           : std_logic;

 signal MDIO_IN_INT              : std_logic;
 signal MDC_IN_INT               : std_logic;
 signal BUS2IP_CLK_INT           : std_logic;
 signal BUS2IP_RESET_INT         : std_logic;
 signal BUS2IP_ADDR_INT          : std_logic_vector(31 downto 0);
 signal BUS2IP_CS_INT            : std_logic;
 signal BUS2IP_RDCE_INT          : std_logic;
 signal BUS2IP_WRCE_INT          : std_logic;
 signal BUS2IP_DATA_INT          : std_logic_vector(31 downto 0);
 signal UNICAST_ADD_INT          : std_logic_vector(47 downto 0);
 signal BASE_X_SWITCH_INT        : std_logic;

 signal INCREMENT_VECTOR_INT     : std_logic_vector(4 to C_NUM_STATS-1);
 signal STATS_REF_CLK_INT        : std_logic;
 
 signal DCM_LOCKED_INT           : std_logic;
 signal SIGNAL_DET_INT           : std_logic;    
 signal PHY_AD_INT               : std_logic_vector(4 downto 0);    
 signal RX_CLK_COR_CNT_INT       : std_logic_vector(2 downto 0); 
 signal RX_BUF_STATUS_INT        : std_logic; 
 signal RX_CHAR_IS_COMMA_INT     : std_logic;
 signal RX_CHAR_IS_K_INT         : std_logic;
 signal RX_DISP_ERR_INT          : std_logic;
 signal RX_NOT_IN_TABLE_INT      : std_logic;
 signal RX_RUN_DISP_INT          : std_logic;
 signal TX_BUF_ERR_INT           : std_logic;


begin

  -- Set the bus width of the PHY port (4 bits MII or 8 bits GMII)
  MII_GEN : if (C_HAS_MII = true) generate
         GMII_RXD_INT(7 downto C_PHY_WIDTH)     <= "0000";
         GMII_RXD_INT(C_PHY_WIDTH-1 downto 0)   <= gmii_rxd;
         gmii_txd                               <= GMII_TXD_INT(C_PHY_WIDTH-1 downto 0);
  end generate;
  GMII_GEN : if (C_HAS_MII = false) generate
         GMII_RXD_INT                           <= gmii_rxd;
         gmii_txd                               <= GMII_TXD_INT;
  end generate;

  -- Tie-off unused ports for C_HAS_HOST generic
  HOST_GEN : if (C_HAS_HOST = true) generate
         BUS2IP_CLK_INT                         <= bus2ip_clk;   
         BUS2IP_RESET_INT                       <= bus2ip_reset; 
         BUS2IP_ADDR_INT                        <= bus2ip_addr;  
         BUS2IP_CS_INT                          <= bus2ip_cs;    
         BUS2IP_RDCE_INT                        <= bus2ip_rdce;  
         BUS2IP_WRCE_INT                        <= bus2ip_wrce;  
         BUS2IP_DATA_INT                        <= bus2ip_data;  
  end generate;
  NOT_HOST_GEN : if (C_HAS_HOST = false) generate
         BUS2IP_CLK_INT                         <= '0';   
         BUS2IP_RESET_INT                       <= '0'; 
         BUS2IP_CS_INT                          <= '0';    
         BUS2IP_RDCE_INT                        <= '0';  
         BUS2IP_WRCE_INT                        <= '0';  
         BUS2IP_ADDR_INT                        <= (others => '0');  
         BUS2IP_DATA_INT                        <= (others => '0');  
  end generate;

  MDIOOUT_GEN : if (C_HAS_MDIO and C_HAS_HOST) generate
         MDIO_IN_INT                            <= mdio_in;
         MDC_IN_INT                             <= '0';
  end generate;
  MDIOIN_GEN : if (C_HAS_MDIO and not C_HAS_HOST) generate
         MDIO_IN_INT                            <= mdio_in;
         MDC_IN_INT                             <= mdc_in;
  end generate;
  NOMDIO_GEN : if (not C_HAS_MDIO) generate
         MDIO_IN_INT                            <= '0';
         MDC_IN_INT                             <= '0';
  end generate;
  
  -- Connect or tie off the stats increment signals
  ENABLESTATS : if (C_HAS_STATS = true) generate
     INCREMENT_VECTOR_INT                       <= increment_vector;
     STATS_REF_CLK_INT                          <= stats_ref_clk;
  end generate;
  NOTENABLESTATS : if (C_HAS_STATS = false) generate
     INCREMENT_VECTOR_INT                       <= (others => '0');
     STATS_REF_CLK_INT                          <= '0';
  end generate;

  MIIGMII_GEN : if (C_HAS_MII or C_HAS_GMII) generate
     -- tie low in gmii/mii
     GTX_CLK_INT                                <= '0';
  end generate;
  NOTMIIGMII_GEN : if (not C_HAS_MII and not C_HAS_GMII) generate
     GTX_CLK_INT                                <= gtx_clk;
  end generate;
  
  CLIENT16_GEN : if (C_CLIENT_16) generate
     GTX_CLK_DIV2_INT                           <= gtx_clk_div2;
     rx_axis_mac_tkeep                          <= RX_AXIS_MAC_TKEEP_INT;
     TX_AXIS_MAC_TKEEP_INT                      <= tx_axis_mac_tkeep;
  end generate;
  NOTCLIENT16_GEN : if (not C_CLIENT_16) generate
     GTX_CLK_DIV2_INT                           <= '0';
     rx_axis_mac_tkeep                          <= "00";
     TX_AXIS_MAC_TKEEP_INT                      <= "00";
  end generate;
  
  PARALLEL_GEN : if (C_HAS_MII or C_HAS_GMII or C_HAS_RGMII_V2_0) generate
     -- tie high in parallel
     DCM_LOCKED_INT                             <= '1';
     -- tie low in parallel
     SIGNAL_DET_INT                             <= '0';
     PHY_AD_INT                                 <= (others => '0');
     RX_CLK_COR_CNT_INT                         <= (others => '0');
     RX_BUF_STATUS_INT                          <= '0';
     RX_CHAR_IS_COMMA_INT                       <= '0';
     RX_CHAR_IS_K_INT                           <= '0';
     RX_DISP_ERR_INT                            <= '0';
     RX_NOT_IN_TABLE_INT                        <= '0';
     RX_RUN_DISP_INT                            <= '0';
     TX_BUF_ERR_INT                             <= '0';
     GMII_RX_ER_INT                             <= gmii_rx_er;
  end generate;
  NOTPARALLEL_GEN : if (NOT C_HAS_MII and not C_HAS_GMII and not C_HAS_RGMII_V2_0) generate
     DCM_LOCKED_INT                             <= dcm_locked;
     SIGNAL_DET_INT                             <= signal_det;
     PHY_AD_INT                                 <= phy_ad;
     RX_CLK_COR_CNT_INT                         <= rx_clk_cor_cnt;
     RX_BUF_STATUS_INT                          <= rx_buf_status;
     RX_CHAR_IS_COMMA_INT                       <= rx_char_is_comma;
     RX_CHAR_IS_K_INT                           <= rx_char_is_k;
     RX_DISP_ERR_INT                            <= rx_disp_err;
     RX_NOT_IN_TABLE_INT                        <= rx_not_in_table;
     RX_RUN_DISP_INT                            <= rx_run_disp;
     TX_BUF_ERR_INT                             <= tx_buf_err;
     GMII_RX_ER_INT                             <= '0';
  end generate;
  
  COLL_GEN : if (C_HAS_MII or (C_HAS_GMII and C_TRI_SPEED)) generate
     GMII_CRS_INT                               <= gmii_crs;
     GMII_COL_INT                               <= gmii_col;
  end generate;
  NOCOLL_GEN : if (C_HAS_SGMII or C_HAS_GPCS or C_HAS_RGMII_V2_0 or (C_HAS_GMII and NOT C_TRI_SPEED)) generate
     GMII_CRS_INT                               <= '0';
     GMII_COL_INT                               <= '0';
  end generate;
  
  BASE_SW_GEN : if (C_HAS_SGMII and C_SERIAL_MODE_SWITCH_EN and C_HAS_HOST and C_TRI_SPEED) generate
     BASE_X_SWITCH_INT                          <= base_x_switch;
  end generate;
  NOBASE_SW_GEN : if (not C_HAS_SGMII or not C_SERIAL_MODE_SWITCH_EN or not C_HAS_HOST or not C_TRI_SPEED) generate
     BASE_X_SWITCH_INT                          <= '0';
  end generate;
  ------------------------------------------------------------------------------
  -- gmac_gen component instantiation.
  ------------------------------------------------------------------------------

  EMAC_TOP : entity axi_ethernet_v3_01_a.EMAC_WRAPPER
   generic map (
      C_EMAC_PAUSEADDR            => C_EMAC_PAUSEADDR,    
      C_EMAC_UNICASTADDR          => C_EMAC_UNICASTADDR,  
      C_EMAC_LINKTIMERVAL         => C_EMAC_LINKTIMERVAL, 
      C_HAS_MII                   => C_HAS_MII,
      C_HAS_GMII                  => C_HAS_GMII,
      C_HAS_RGMII_V1_3            => C_HAS_RGMII_V1_3,
      C_HAS_RGMII_V2_0            => C_HAS_RGMII_V2_0,
      C_HAS_SGMII                 => C_HAS_SGMII,
      C_HAS_GPCS                  => C_HAS_GPCS,
      C_TRI_SPEED                 => C_TRI_SPEED,
      C_SPEED_10                  => C_SPEED_10,
      C_SPEED_100                 => C_SPEED_100,
      C_SPEED_1000                => C_SPEED_1000,
      C_HAS_HOST                  => C_HAS_HOST,
      C_HAS_DCR                   => C_HAS_DCR,
      C_HAS_MDIO                  => C_HAS_MDIO,
      C_CLIENT_16                 => C_CLIENT_16,
      C_OVERCLOCKING_RATE_2000MBPS=> C_OVERCLOCKING_RATE_2000MBPS,
      C_OVERCLOCKING_RATE_2500MBPS=> C_OVERCLOCKING_RATE_2500MBPS,
      C_HAS_CLOCK_ENABLE          => C_HAS_CLOCK_ENABLE,
      C_BYTE_PHY                  => C_BYTE_PHY,
      C_ADD_FILTER                => C_ADD_FILTER,
      C_UNICAST_PAUSE_ADDRESS     => C_UNICAST_PAUSE_ADDRESS,
      C_PHY_RESET                 => C_PHY_RESET,
      C_PHY_AN                    => C_PHY_AN,
      C_PHY_ISOLATE               => C_PHY_ISOLATE,
      C_PHY_POWERDOWN             => C_PHY_POWERDOWN,
      C_PHY_LOOPBACK_MSB          => C_PHY_LOOPBACK_MSB,
      C_LT_CHECK_DIS              => C_LT_CHECK_DIS,
      C_CTRL_LENCHECK_DISABLE     => C_CTRL_LENCHECK_DISABLE,
      C_RX_FLOW_CONTROL           => C_RX_FLOW_CONTROL,
      C_TX_FLOW_CONTROL           => C_TX_FLOW_CONTROL,
      C_TX_RESET                  => C_TX_RESET,
      C_TX_JUMBO                  => C_TX_JUMBO,
      C_TX_FCS                    => C_TX_FCS,
      C_TX                        => C_TX,
      C_TX_VLAN                   => C_TX_VLAN,
      C_TX_HALF_DUPLEX            => C_TX_HALF_DUPLEX,
      C_TX_IFG                    => C_TX_IFG,
      C_RX_RESET                  => C_RX_RESET,
      C_RX_JUMBO                  => C_RX_JUMBO,
      C_RX_FCS                    => C_RX_FCS,
      C_RX                        => C_RX,
      C_RX_VLAN                   => C_RX_VLAN,
      C_RX_HALF_DUPLEX            => C_RX_HALF_DUPLEX,
      C_DCR_BASE_ADDRESS          => C_DCR_BASE_ADDRESS,
      C_PHY_GTLOOPBACK            => C_PHY_GTLOOPBACK,
      C_PHY_IGNORE_ADZERO         => C_PHY_IGNORE_ADZERO,
      C_PHY_UNIDIRECTION_ENABLE   => C_PHY_UNIDIRECTION_ENABLE,
      SGMII_FABRIC_BUFFER         => SGMII_FABRIC_BUFFER,
      C_SERIAL_MODE_SWITCH_EN     => C_SERIAL_MODE_SWITCH_EN,
      C_ADD_BUFGS                 => C_ADD_BUFGS,

      C_PHY_WIDTH                 => C_PHY_WIDTH,
      C_AT_ENTRIES                => C_AT_ENTRIES,
      C_HAS_STATS                 => C_HAS_STATS,
      C_NUM_STATS                 => C_NUM_STATS,
      C_CNTR_RST                  => C_CNTR_RST,
      C_STATS_WIDTH               => C_STATS_WIDTH,
      C_INTERNAL_INT              => C_INTERNAL_INT
      )
   port map (
      GLBL_RSTN                   => glbl_rstn,
      RX_AXI_RSTN                 => rx_axi_rstn,
      TX_AXI_RSTN                 => tx_axi_rstn,

      GTX_CLK                     => GTX_CLK_INT,
      GTX_CLK_DIV2                => GTX_CLK_DIV2_INT,
      TX_AXI_CLK_OUT              => tx_axi_clk_out,
    
      GMII_TXD                    => GMII_TXD_INT,
      GMII_TX_EN                  => gmii_tx_en,
      GMII_TX_ER                  => gmii_tx_er,

      GMII_CRS                    => GMII_CRS_INT,
      GMII_COL                    => GMII_COL_INT,
      GMII_RXD                    => GMII_RXD_INT,
      GMII_RX_DV                  => gmii_rx_dv,
      GMII_RX_ER                  => GMII_RX_ER_INT,

      DCMLOCKED                   => DCM_LOCKED_INT,
      ANINTERRUPT                 => an_interrupt,
      SIGNALDET                   => SIGNAL_DET_INT,
      PHYAD                       => PHY_AD_INT,
      ENCOMMAALIGN                => en_comma_align,
      LOOPBACKMSB                 => loopback_msb,
      MGTRXRESET                  => mgt_rx_reset,
      MGTTXRESET                  => mgt_tx_reset,
      POWERDOWN                   => powerdown,
      SYNCACQSTATUS               => sync_acq_status,
      RXCLKCORCNT                 => RX_CLK_COR_CNT_INT,
      RXBUFSTATUS                 => RX_BUF_STATUS_INT,
      RXCHARISCOMMA               => RX_CHAR_IS_COMMA_INT,
      RXCHARISK                   => RX_CHAR_IS_K_INT,
      RXDISPERR                   => RX_DISP_ERR_INT,
      RXNOTINTABLE                => RX_NOT_IN_TABLE_INT,
      RXRUNDISP                   => RX_RUN_DISP_INT,
      TXBUFERR                    => TX_BUF_ERR_INT,
      TXCHARDISPMODE              => tx_char_disp_mode,
      TXCHARDISPVAL               => tx_char_disp_val,
      TXCHARISK                   => tx_char_is_k,

      MDC_OUT                     => mdc_out,
      MDC_IN                      => MDC_IN_INT,
      MDIO_TRI                    => mdio_tri, 
      MDIO_OUT                    => mdio_out,
      MDIO_IN                     => MDIO_IN_INT,

      TX_AXI_CLK                  => tx_axi_clk, 
      TX_RESET_OUT                => tx_reset_out,
      TX_AXIS_MAC_TDATA           => tx_axis_mac_tdata, 
      TX_AXIS_MAC_TKEEP           => TX_AXIS_MAC_TKEEP_INT,
      TX_AXIS_MAC_TVALID          => tx_axis_mac_tvalid,
      TX_AXIS_MAC_TLAST           => tx_axis_mac_tlast, 
      TX_AXIS_MAC_TUSER           => tx_axis_mac_tuser,
      TX_AXIS_MAC_TREADY          => tx_axis_mac_tready,
      
      TX_COLLISION                => tx_collision,
      TX_RETRANSMIT               => tx_retransmit, 
      TX_IFG_DELAY                => tx_ifg_delay,
      PAUSE_REQ                   => pause_req,
      PAUSE_VAL                   => pause_val,

      RX_AXI_CLK                  => rx_axi_clk, 
      RX_RESET_OUT                => rx_reset_out,
      RX_AXIS_MAC_TDATA           => rx_axis_mac_tdata, 
      RX_AXIS_MAC_TKEEP           => RX_AXIS_MAC_TKEEP_INT,
      RX_AXIS_MAC_TVALID          => rx_axis_mac_tvalid,
      RX_AXIS_MAC_TLAST           => rx_axis_mac_tlast, 
      RX_AXIS_MAC_TUSER           => rx_axis_mac_tuser,
      RX_AXIS_FILTER_TUSER        => rx_axis_filter_tuser,
      
      STATS_REF_CLK               => STATS_REF_CLK_INT,
      INCREMENT_VECTOR            => INCREMENT_VECTOR_INT,

      TX_STATISTICS_VECTOR        => tx_statistics_vector,
      TX_STATISTICS_VALID         => tx_statistics_valid,
      
      -- added for avb connection 03/21/2011     
      tx_avb_en                   => tx_avb_en,

      -- added 05/5/2011     
      RX_CLK_ENABLE_OUT           => RX_CLK_ENABLE_OUT,
      RX_STATISTICS_VECTOR        => rx_statistics_vector,
      RX_STATISTICS_VALID         => rx_statistics_valid, 
   --   TIEEMACUNICASTADDR          => UNICAST_ADD_INT,

      SPEED_IS_10_100             => speed_is_10_100,

      BUS2IP_CLK                  => BUS2IP_CLK_INT,
      BUS2IP_RESET                => BUS2IP_RESET_INT,
      BUS2IP_ADDR                 => BUS2IP_ADDR_INT,
      BUS2IP_CS                   => BUS2IP_CS_INT,
      BUS2IP_RDCE                 => BUS2IP_RDCE_INT,
      BUS2IP_WRCE                 => BUS2IP_WRCE_INT,
      BUS2IP_DATA                 => BUS2IP_DATA_INT,
      IP2BUS_DATA                 => ip2bus_data,
      IP2BUS_WRACK                => ip2bus_wrack,
      IP2BUS_RDACK                => ip2bus_rdack,
      IP2BUS_ERROR                => ip2bus_error,
      
      MAC_IRQ                     => mac_irq,
      BASE_X_SWITCH               => BASE_X_SWITCH_INT
   );

end xilinx;
