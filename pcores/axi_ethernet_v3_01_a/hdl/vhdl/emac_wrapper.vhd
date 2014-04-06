------------------------------------------------------------------------
-- emac_wrapper.vhd
-- Author     : Xilinx Inc.
-- ------------------------------------------------------------------------------
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
-- This is based on Coregen Wrappers from ISE O.40d (13.1) plus a patch
-- Wrapper version 2.1
-------------------------------------------------------------------------------
-- Structure:
--              emac_wrapper.vhd
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
--    |           |              |    |   v6_emac_v2_1    |               |
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
library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

entity EMAC_WRAPPER is
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

      C_PHY_WIDTH                 : integer := 8;
      C_AT_ENTRIES                : integer := 4;
      C_HAS_STATS                 : boolean := true;
      C_NUM_STATS                 : integer := 44;
      C_CNTR_RST                  : boolean := true;
      C_STATS_WIDTH               : integer := 64;
      C_INTERNAL_INT              : boolean := false
    );
    port(
    ---------------------------------------------------------------------------
    -- RESET signals
    ---------------------------------------------------------------------------
    GLBL_RSTN            : in  std_logic;
    RX_AXI_RSTN          : in  std_logic;
    TX_AXI_RSTN          : in  std_logic;

    ---------------------------------------------------------------------------
    -- Clock signals - used in rgmii and serial modes
    ---------------------------------------------------------------------------
    GTX_CLK              : in  std_logic;
    GTX_CLK_DIV2         : in  std_logic;
    TX_AXI_CLK_OUT       : out std_logic;

    ---------------------------------------------------------------------------
    -- Receiver Interface.
    ---------------------------------------------------------------------------
    RX_AXI_CLK           : in std_logic;
    RX_RESET_OUT         : out std_logic;
    RX_AXIS_MAC_TDATA    : out std_logic_vector(7 downto 0);
    RX_AXIS_MAC_TKEEP    : out std_logic_vector(1 downto 0);
    RX_AXIS_MAC_TVALID   : out std_logic;
    RX_AXIS_MAC_TLAST    : out std_logic;
    RX_AXIS_MAC_TUSER    : out std_logic;

    -- RX sideband signals

    -- added 05/5/2011     
    RX_CLK_ENABLE_OUT    : out std_logic;

    RX_STATISTICS_VECTOR : out std_logic_vector(27 downto 0);
    RX_STATISTICS_VALID  : out std_logic;
    RX_AXIS_FILTER_TUSER : out std_logic_vector(C_AT_ENTRIES downto 0);
    ---------------------------------------------------------------------------
    -- Transmitter Interface
    ---------------------------------------------------------------------------
    TX_AXI_CLK           : in std_logic;
    TX_RESET_OUT         : out std_logic;
    TX_AXIS_MAC_TDATA    : in  std_logic_vector(7 downto 0);
    TX_AXIS_MAC_TKEEP    : in  std_logic_vector(1 downto 0);
    TX_AXIS_MAC_TVALID   : in  std_logic;
    TX_AXIS_MAC_TLAST    : in  std_logic;
    TX_AXIS_MAC_TUSER    : in  std_logic;
    TX_AXIS_MAC_TREADY   : out std_logic;

    -- TX sideband signals
    TX_RETRANSMIT        : out std_logic;
    TX_COLLISION         : out std_logic;
    TX_IFG_DELAY         : in  std_logic_vector(7 downto 0);
    TX_STATISTICS_VECTOR : out std_logic_vector(31 downto 0);
    TX_STATISTICS_VALID  : out std_logic;
    
    -- added for avb connection 03/21/2011     
    tx_avb_en            : out std_logic;
    
    ---------------------------------------------------------------------------
    -- Statistics Interface
    ---------------------------------------------------------------------------
    STATS_REF_CLK        : in std_logic;
    INCREMENT_VECTOR     : in std_logic_vector(4 to C_NUM_STATS-1);

    ---------------------------------------------------------------------------
    -- Flow Control
    ---------------------------------------------------------------------------
    PAUSE_REQ            : in  std_logic;
    PAUSE_VAL            : in  std_logic_vector(15 downto 0);

    ---------------------------------------------------------------------------
    -- Speed interface
    ---------------------------------------------------------------------------
    SPEED_IS_100         : out std_logic;
    SPEED_IS_10_100      : out std_logic;

    ---------------------------------------------------------------------------
    -- GMII/MII Interface
    ---------------------------------------------------------------------------
    GMII_COL             : in  std_logic;
    GMII_CRS             : in  std_logic;
    GMII_TXD             : out std_logic_vector(7 downto 0);
    GMII_TX_EN           : out std_logic;
    GMII_TX_ER           : out std_logic;
    GMII_RXD             : in  std_logic_vector(7 downto 0);
    GMII_RX_DV           : in  std_logic;
    GMII_RX_ER           : in  std_logic;

    ---------------------------------------------------------------------------
    -- Serial Phy interface
    ---------------------------------------------------------------------------
    DCMLOCKED            : in  std_logic;
    ANINTERRUPT          : out std_logic;
    SIGNALDET            : in  std_logic;
    PHYAD                : in  std_logic_vector(4 downto 0);
    ENCOMMAALIGN         : out std_logic;
    LOOPBACKMSB          : out std_logic;
    MGTRXRESET           : out std_logic;
    MGTTXRESET           : out std_logic;
    POWERDOWN            : out std_logic;
    SYNCACQSTATUS        : out std_logic;
    RXCLKCORCNT          : in  std_logic_vector(2 downto 0);
    RXBUFSTATUS          : in  std_logic;
    RXCHARISCOMMA        : in  std_logic;
    RXCHARISK            : in  std_logic;
    RXDISPERR            : in  std_logic;
    RXNOTINTABLE         : in  std_logic;
    RXRUNDISP            : in  std_logic;
    TXBUFERR             : in  std_logic;
    TXCHARDISPMODE       : out std_logic;
    TXCHARDISPVAL        : out std_logic;
    TXCHARISK            : out std_logic;

    ---------------------------------------------------------------------------
    -- MDIO Interface
    ---------------------------------------------------------------------------
    MDIO_IN              : in    std_logic;
    MDIO_OUT             : out   std_logic;
    MDIO_TRI             : out   std_logic;
    MDC_OUT              : out   std_logic;                    -- Whenever Host I/F is present, MDC is an output.
    MDC_IN               : in    std_logic;
    ---------------------------------------------------------------------------
    -- IPIC Interface
    ---------------------------------------------------------------------------
    -- JK 19 Feb 2010: Replaced host interface ports with IPIC interface.
    BUS2IP_CLK           : in    std_logic;
    BUS2IP_RESET         : in    std_logic;
    BUS2IP_ADDR          : in    std_logic_vector(31 downto 0);
    BUS2IP_CS            : in    std_logic;
    BUS2IP_RDCE          : in    std_logic;
    BUS2IP_WRCE          : in    std_logic;
    BUS2IP_DATA          : in    std_logic_vector(31 downto 0);
    IP2BUS_DATA          : out   std_logic_vector(31 downto 0);
    IP2BUS_WRACK         : out   std_logic;
    IP2BUS_RDACK         : out   std_logic;
    IP2BUS_ERROR         : out   std_logic;

    MAC_IRQ              : out   std_logic;

    --TIEEMACUNICASTADDR   : in std_logic_vector(47 downto 0);
    BASE_X_SWITCH        : in std_logic

    );



end EMAC_WRAPPER;



architecture rtl of EMAC_WRAPPER is

  -- reset synchroniser component declarations
  -- could be put into a library at some point
  component SYNC_RESET
    port (
      RESET_IN    : in  std_logic;
      CLK         : in  std_logic;
      RESET_OUT   : out std_logic
      );
  end component;

   component axi_ethernet_v3_01_a_sync_block
    port (
      clk    : in  std_logic;
      data_in    : in  std_logic;
      data_out   : out std_logic
      );
  end component;

  function Bool2Int (Bool : Boolean) return integer is
    begin
        if Bool then
           return 1;
        else
           return 0;
        end if;
  end function Bool2Int;

  function Str2bit (Str : string) return bit_vector is
     variable vector : bit_vector(((Str'high * 4)-1) downto 0);
    begin
        vector := (others => '0');
        for i in 1 to (Str'high) loop
           case Str(i) is
              when '0'    => vector((i*4)-1 downto (i*4)-4) := X"0";
              when '1'    => vector((i*4)-1 downto (i*4)-4) := X"1";
              when '2'    => vector((i*4)-1 downto (i*4)-4) := X"2";
              when '3'    => vector((i*4)-1 downto (i*4)-4) := X"3";
              when '4'    => vector((i*4)-1 downto (i*4)-4) := X"4";
              when '5'    => vector((i*4)-1 downto (i*4)-4) := X"5";
              when '6'    => vector((i*4)-1 downto (i*4)-4) := X"6";
              when '7'    => vector((i*4)-1 downto (i*4)-4) := X"7";
              when '8'    => vector((i*4)-1 downto (i*4)-4) := X"8";
              when '9'    => vector((i*4)-1 downto (i*4)-4) := X"9";
              when 'a'    => vector((i*4)-1 downto (i*4)-4) := X"a";
              when 'b'    => vector((i*4)-1 downto (i*4)-4) := X"b";
              when 'c'    => vector((i*4)-1 downto (i*4)-4) := X"c";
              when 'd'    => vector((i*4)-1 downto (i*4)-4) := X"d";
              when 'e'    => vector((i*4)-1 downto (i*4)-4) := X"e";
              when 'f'    => vector((i*4)-1 downto (i*4)-4) := X"f";
              when others => vector((i*4)-1 downto (i*4)-4) := X"0";
           end case;
        end loop;
        return vector;
  end function Str2bit;

  constant DLY                      : time := 1 ps;

  ------------------------------------------------
  -- Adjust constants as necessary to make sense..
  -- Assumption here is that the generic defines the RESET value for the related register/bit
  -- ensure default is not reset if no host
  constant EMAC_TX_RESET            : boolean := C_HAS_HOST and C_TX_RESET;
  constant EMAC_RX_RESET            : boolean := C_HAS_HOST and C_RX_RESET;

   -- Configure the EMAC operating mode
  constant EMAC_MDIO_ENABLE         : boolean := C_HAS_MDIO or C_HAS_SGMII or C_HAS_GPCS;

   -- Speed is defaulted to 10Mb/s, 100 Mb/s or 1`000 Mb/s depending upon parameters
  constant EMAC_SPEED_LSB           : boolean := C_SPEED_100;
  constant EMAC_SPEED_MSB           : boolean := C_SPEED_1000 or C_TRI_SPEED;

  -- 16 bit client only makes sense with serial interfaces??
  --constant EMAC_CLIENT_16           : boolean := C_CLIENT_16 and (C_HAS_GPCS or c_HAS_SGMII);
  constant EMAC_CLIENT_16           : boolean := C_CLIENT_16 and C_HAS_GPCS;

 
 
  -- half-duplex mode is enabled under very specific settings
  constant EMAC_TXHALFDUPLEX        : boolean := C_HAS_HOST and C_TX_HALF_DUPLEX and not (C_HAS_GPCS or C_SPEED_1000 or C_CLIENT_16 or C_HAS_SGMII);
  constant EMAC_RXHALFDUPLEX        : boolean := C_HAS_HOST and C_RX_HALF_DUPLEX and not (C_HAS_GPCS or C_SPEED_1000 or C_CLIENT_16 or C_HAS_SGMII);

  -- Configure the EMAC addressing
  -- Set the PAUSE address default
  constant EMAC_PAUSEADDR           : bit_vector := Str2bit(C_UNICAST_PAUSE_ADDRESS);
  
  
  constant emac_pauseaddr_std_logic : std_logic_vector(47 downto 0) := (to_stdlogicvector(C_EMAC_PAUSEADDR));
    -- simulator was assigning High Z to  tie_pause_addr (below) with to_stdlogicvector(C_EMAC_PAUSEADDR)

  -- Do not set the unicast address (address filter is unused)
  constant link_timer_value         : std_logic_vector(0 to 11) := to_stdlogicvector(C_EMAC_LINKTIMERVAL);
--  constant EMAC_UNICASTADDR         : bit_vector := Str2bit(C_UNICAST_PAUSE_ADDRESS);
  constant EMAC_LTV_VEC             : bit_vector := Str2bit(C_LINK_TIMER_VALUE);
  constant EMAC_LINK_TIMER_VALUE    : bit_vector(0 to 11) := EMAC_LTV_VEC(11) & EMAC_LTV_VEC(10) & EMAC_LTV_VEC(9) & EMAC_LTV_VEC(8) &
                                                             EMAC_LTV_VEC(7) & EMAC_LTV_VEC(6) & EMAC_LTV_VEC(5) & EMAC_LTV_VEC(4) &
                                                             EMAC_LTV_VEC(3) & EMAC_LTV_VEC(2) & EMAC_LTV_VEC(1) & EMAC_LTV_VEC(0);

  -- do not want clock enables set when in 1G only
  constant C_CLOCK_ENABLE           : boolean := C_HAS_CLOCK_ENABLE and not C_SPEED_1000;

  -- JK 20 May 2010: Added constant assignments for VHDL-to-Verilog param translation,
  -- since VHDL uses Boolean type and Verilog uses integer.
  constant C_HAS_HOST_VLOG          : integer := Bool2Int(C_HAS_HOST);
  constant C_ADD_FILTER_VLOG        : integer := Bool2Int(C_ADD_FILTER);
  constant C_TRI_SPEED_VLOG         : integer := Bool2Int(C_TRI_SPEED);
  constant C_SPEED_10_VLOG          : integer := Bool2Int(C_SPEED_10);
  constant C_SPEED_100_VLOG         : integer := Bool2Int(C_SPEED_100);
  constant C_SPEED_1000_VLOG        : integer := Bool2Int(C_SPEED_1000);
  constant C_HAS_STATS_VLOG         : integer := Bool2Int(C_HAS_STATS);
  constant C_HAS_SGMII_VLOG         : integer := Bool2Int(C_HAS_SGMII); 
  constant C_HAS_MII_VLOG           : integer := Bool2Int(C_HAS_MII);  
  constant C_HAS_GMII_VLOG          : integer := Bool2Int(C_HAS_GMII);   
  constant C_HAS_RGMII_V2_0_VLOG    : integer := Bool2Int(C_HAS_RGMII_V2_0);   
  constant C_CLIENT_16_VLOG         : integer := Bool2Int(EMAC_CLIENT_16);
  
  

  -- host - IPIF conversion signals
  signal HOSTCLK                    : std_logic;
  signal HOSTOPCODE                 : std_logic_vector(1 downto 0);
  signal HOSTADDR                   : std_logic_vector(9 downto 0);
  signal HOSTWRDATA                 : std_logic_vector(31 downto 0);
  signal HOSTREQ                    : std_logic;
  signal HOSTMIIMSEL                : std_logic;
  signal HOSTRDDATA                 : std_logic_vector(31 downto 0);
  signal HOSTMIIMRDY                : std_logic;

  signal BUS2IP_CS_INT              : std_logic_vector(3 downto 0);
  signal BUS2IP_RDCE_INT            : std_logic_vector(3 downto 0);
  signal BUS2IP_WRCE_INT            : std_logic_vector(3 downto 0);
  signal IP2BUS_RDACK_CONFIG_INT    : std_logic;
  signal IP2BUS_WRACK_CONFIG_INT    : std_logic;
  signal IP2BUS_ERROR_CONFIG_INT    : std_logic;
  signal IP2BUS_DATA_CONFIG_INT     : std_logic_vector(31 downto 0);
  signal IP2BUS_RDACK_STATS_INT     : std_logic;
  signal IP2BUS_WRACK_STATS_INT     : std_logic;
  signal IP2BUS_ERROR_STATS_INT     : std_logic;
  signal IP2BUS_DATA_STATS_INT      : std_logic_vector(31 downto 0);
  signal IP2BUS_RDACK_INTR_INT      : std_logic;
  signal IP2BUS_WRACK_INTR_INT      : std_logic;
  signal IP2BUS_ERROR_INTR_INT      : std_logic;
  signal IP2BUS_DATA_INTR_INT       : std_logic_vector(31 downto 0);
  signal IP2BUS_RDACK_AF_INT        : std_logic;
  signal IP2BUS_WRACK_AF_INT        : std_logic;
  signal IP2BUS_ERROR_AF_INT        : std_logic;
  signal IP2BUS_DATA_AF_INT         : std_logic_vector(31 downto 0);

  signal RX_CE_SAMPLE               : std_logic;
  signal RX_DATA                    : std_logic_vector(15 downto 0);
  signal RX_DATA_VALID              : std_logic;
  signal RX_DATA_VALID_MSW          : std_logic;
  signal RX_GOOD_FRAME              : std_logic;
  signal RX_BAD_FRAME               : std_logic;
  signal RX_FILTER_MATCH            : std_logic_vector(C_AT_ENTRIES downto 0);
  signal RX_FILTER_MATCH_COMB      : std_logic;

  signal RX_STATS_SHIFT             : std_logic_vector(6 downto 0);
  signal RX_STATS_SHIFT_VLD         : std_logic;
  signal RX_STATS_BYTEVLD           : std_logic;
  signal rxstatsaddressmatch        : std_logic;
  signal rxstatsaddressmatch_int    : std_logic;

  signal TX_CE_SAMPLE               : std_logic;
  signal TX_DATA                    : std_logic_vector(15 downto 0);
  signal TX_DATA_VALID              : std_logic;
  signal TX_DATA_VALID_MSW          : std_logic;
  signal TX_ACK                     : std_logic;
  signal TX_UNDERRUN                : std_logic;

  signal TX_STATS_SHIFT             : std_logic;
  signal TX_STATS_SHIFT_VLD         : std_logic;
  signal TX_STATS_BYTEVLD           : std_logic;

  signal INT_UPDATE_PAUSE_AD        : std_logic;
  signal INT_MGMT_HOST_RESET_INPUT  : std_logic;
  signal INT_MGMT_HOST_RESET        : std_logic;
  signal INT_TX_RST_ASYNCH          : std_logic;
  signal INT_RX_RST_ASYNCH          : std_logic;
  signal INT_TX_RST_MGMT            : std_logic;
  signal INT_RX_RST_MGMT            : std_logic;
  signal INT_RST                    : std_logic;
  signal STATS_RESET                : std_logic;
  signal TX_RESET                   : std_logic;
  signal RX_RESET                   : std_logic;
  signal TX_RESET_STAT              : std_logic;
  signal RX_RESET_STAT              : std_logic;
  signal INT_GLBL_RST               : std_logic;

  signal TX_BYTE                    : std_logic;
  signal RX_PIPE_BYTEVLD            : std_logic_vector(15 downto 0);
  signal RX_BYTE                    : std_logic;
  signal RX_FRAG_INT                : std_logic;
  signal RX_SMALL_INT               : std_logic;
  signal RX_FRAG                    : std_logic;
  signal RX_SMALL                   : std_logic;

  signal INT_RX_STATISTICS_VECTOR   : std_logic_vector(27 downto 0);
  signal INT_RX_STATISTICS_VALID    : std_logic;
  signal INT_TX_STATISTICS_VECTOR   : std_logic_vector(31 downto 0);
  signal INT_TX_STATISTICS_VALID    : std_logic;

  signal PAUSEADDRESSMATCH          : std_logic;
  signal SPECIALPAUSEADDRESSMATCH   : std_logic;
  signal BROADCASTADDRESSMATCH      : std_logic;
  signal UNICASTADDRESSMATCH        : std_logic;
  signal RX_DATA_VALID_OUT          : std_logic;
  signal RX_DATA_VALID_MSW_OUT      : std_logic;
  signal RX_DATA_OUT                : std_logic_vector(15 downto 0);
  signal MATCH_FRAME_INT            : std_logic;
  signal PAUSE_ADDR                 : std_logic_vector(47 downto 0);
  signal TX_SOFT_RESET              : std_logic;
  signal RX_SOFT_RESET              : std_logic;

  -- Internal clocks used to tie off/redirect according to generics
  signal MII_TX_CLK                 : std_logic;
  signal TX_AXI_CLK_INT             : std_logic;
  signal TX_AXI_CLK_OUT_INT1        : std_logic;
  signal TX_AXI_CLK_OUT_INT2        : std_logic;
  signal RX_AXI_CLK_INT             : std_logic;
  signal RX_CLIENT_CE               : std_logic;
  signal rx_axi_clk_phy             : std_logic;
  signal TX_AXI_CLK_PHY             : std_logic;
  signal RX_AXI_CLK_STAT            : std_logic;
  signal TX_AXI_CLK_STAT            : std_logic;
  signal GTX_CLK_INT                : std_logic;
  signal RXBUFSTATUS_INT            : std_logic_vector(1 downto 0);

  signal PAUSE_REQ_INT              : std_logic;
  signal PAUSE_VAL_INT              : std_logic_vector(15 downto 0);


  signal SPEED_IS_10_100_INT        : std_logic;
  signal GMII_TXD_INT               : std_logic_vector(7 downto 0);
  signal GMII_TX_EN_INT             : std_logic;
  signal GMII_TX_ER_INT             : std_logic;
  signal TX_COLLISION_INT           : std_logic;
  signal TX_RETRANSMIT_INT          : std_logic;
  signal tie_to_pwr                 : std_logic;
  signal tie_to_gnd                 : std_logic;
  signal tie_to_gnd_32              : std_logic_vector(31 downto 0);

   
   component axi_ethernet_v3_01_a_v6_ipic_host_if is
   generic (
      REG_MAPPED           : integer := 1;
      ASYNC                : integer := 0;
      C_TRI_SPEED          : integer := 0;
      C_SPEED_10           : integer := 0;
      C_SPEED_100          : integer := 0;
      C_SPEED_1000         : integer := 1;
      C_HAS_MII            : integer := 0;
      C_HAS_GMII           : integer := 1;
      C_HAS_RGMII_V2_0     : integer := 0;
      C_HAS_STATS          : integer := 1;
      C_ADD_FILTER         : integer := 0
   );
   port (
      link_timer_value     : in  std_logic_vector(11 downto 0);
      ----------------------------------------------------------------------
      -- IPIC Interface
      ----------------------------------------------------------------------

      bus2ip_clk           : in  std_logic;
      bus2ip_reset         : in  std_logic;

      bus2ip_addrvalid     : in  std_logic;
      bus2ip_cs            : in  std_logic;
      bus2ip_rnw           : in  std_logic;
      ip2bus_ack           : out std_logic;
      bus2ip_ce            : in  std_logic;
      bus2ip_rdce          : in  std_logic;
      bus2ip_wrce          : in  std_logic;
      ip2bus_wrack         : out std_logic;
      ip2bus_rdack         : out std_logic;

      bus2ip_addr          : in  std_logic_vector(31 downto 0);
      bus2ip_data          : in  std_logic_vector(31 downto 0);
      ip2bus_data          : out std_logic_vector(31 downto 0);
      ip2bus_error         : out std_logic;
      ip2bus_tousup        : out std_logic;

      ----------------------------------------------------------------------
      -- mode control
      ----------------------------------------------------------------------

      base_x_switch        : in  std_logic;

      ----------------------------------------------------------------------
      -- local registers
      ----------------------------------------------------------------------

      tie_pause_addr       : in  std_logic_vector(47 downto 0);
      pause_addr           : out std_logic_vector(47 downto 0);
      update_pause_addr    : out std_logic;
      tx_soft_reset        : out std_logic;
      rx_soft_reset        : out std_logic;

      ----------------------------------------------------------------------
      -- Ethernet MAC Host Interface
      ----------------------------------------------------------------------

      host_clk             : in  std_logic;
      host_reset           : in  std_logic;
      host_opcode          : out std_logic_vector(1 downto 0);
      host_addr            : out std_logic_vector(9 downto 0);
      host_wr_data         : out std_logic_vector(31 downto 0);
      host_req             : out std_logic;
      host_miim_sel        : out std_logic;
      host_rd_data_mac     : in  std_logic_vector(31 downto 0);
      host_miim_rdy        : in  std_logic;

      temac_intr           : out std_logic

   );
   end component;


   component axi_ethernet_v3_01_a_v6_rx_axi_intf
   generic (
      C_AT_ENTRIES               : integer := 8;
      C_CLIENT_16                : integer := 0
   );
   port (
      rx_clk                     : in  std_logic;
      rx_reset                   : in  std_logic;
      rx_enable                  : in  std_logic;

      rx_data                    : in  std_logic_vector((8+(C_CLIENT_16*8))-1 downto 0);
      rx_data_valid              : in  std_logic;
      rx_data_valid_msw          : in  std_logic;      
      rx_good_frame              : in  std_logic;
      rx_bad_frame               : in  std_logic;
      rx_frame_match             : in  std_logic;

      rx_filter_match            : in  std_logic_vector(C_AT_ENTRIES downto 0);
      rx_filter_tuser            : out std_logic_vector(C_AT_ENTRIES downto 0);

      rx_clk_enable_out          : out std_logic;
	  rx_mac_tdata               : out std_logic_vector((8+(C_CLIENT_16*8))-1 downto 0);
      rx_mac_tkeep               : out std_logic_vector(1 downto 0);      
      rx_mac_tvalid              : out std_logic;
      rx_mac_tlast               : out std_logic;
      rx_mac_tuser               : out std_logic
   );
   end component;

   
   
   component axi_ethernet_v3_01_a_pausereq_shim
port (

  reset            : in std_logic;
  client_clk       : in std_logic;
  client_clk_en    : in std_logic;

  tx_stats_bytevld : in std_logic;

  pause_req        : in std_logic;
  pause_val        : in std_logic_vector(15 downto 0);

  pause_req_out    : out std_logic;
  pause_val_out    : out std_logic_vector(15 downto 0)
);
   end component;

   component axi_ethernet_v3_01_a_v6_tx_axi_intf
   generic (
      c_has_sgmii                : integer := 0;
      c_client_16                : integer := 0
   );
  port (
      tx_clk                     : in  std_logic;
      tx_reset                   : in  std_logic;
      tx_enable                  : in  std_logic;
      speed_is_10_100            : in  std_logic;

      tx_mac_tdata               : in  std_logic_vector((8+(C_CLIENT_16*8))-1 downto 0);
      tx_mac_tkeep               : in  std_logic_vector(1 downto 0);
      tx_mac_tvalid              : in  std_logic;
      tx_mac_tlast               : in  std_logic;
      tx_mac_tuser               : in  std_logic;
      tx_mac_tready              : out std_logic;

      tx_enable_out              : out std_logic;
      tx_continuation            : out std_logic;
      tx_data                    : out std_logic_vector((8+(C_CLIENT_16*8))-1 downto 0);
      tx_data_valid              : out std_logic;
      tx_data_valid_msw          : out std_logic;
      tx_underrun                : out std_logic;
      tx_ack                     : in  std_logic;
      tx_retransmit              : in  std_logic
   );
   end component;

   
   component axi_ethernet_v3_01_a_v6_ipic_mux
   port (
      bus2ip_clk           : in  std_logic;
      bus2ip_reset         : in  std_logic;

      bus2ip_addr          : in  std_logic_vector(10 downto 8);
      bus2ip_cs            : in  std_logic;
      bus2ip_rdce          : in  std_logic;
      bus2ip_wrce          : in  std_logic;

      bus2ip_cs_int        : out std_logic_vector(3 downto 0);
      bus2ip_rdce_int      : out std_logic_vector(3 downto 0);
      bus2ip_wrce_int      : out std_logic_vector(3 downto 0);

      ip2bus_rdack         : out std_logic;
      ip2bus_wrack         : out std_logic;
      ip2bus_error         : out std_logic;
      ip2bus_data          : out std_logic_vector(31 downto 0);


      ip2bus_rdack_stats   : in  std_logic;
      ip2bus_rdack_config  : in  std_logic;
      ip2bus_rdack_intr    : in  std_logic;
      ip2bus_rdack_af      : in  std_logic;

      ip2bus_wrack_stats   : in  std_logic;
      ip2bus_wrack_config  : in  std_logic;
      ip2bus_wrack_intr    : in  std_logic;
      ip2bus_wrack_af      : in  std_logic;

      ip2bus_error_stats   : in  std_logic;
      ip2bus_error_config  : in  std_logic;
      ip2bus_error_intr    : in  std_logic;
      ip2bus_error_af      : in  std_logic;

      ip2bus_data_stats    : in  std_logic_vector(31 downto 0);
      ip2bus_data_config   : in  std_logic_vector(31 downto 0);
      ip2bus_data_intr     : in  std_logic_vector(31 downto 0);
      ip2bus_data_af       : in  std_logic_vector(31 downto 0)
   );
   end component;


   component axi_ethernet_v3_01_a_v6_address_filter_wrap
   generic (
      C_AT_ENTRIES               : integer := 8;
      C_HAS_HOST                 : integer := 1;
      C_ADD_FILTER               : integer := 1
   );
   port (
      rxcoreclk                  : in  std_logic;
      rx_sync_reset              : in  std_logic;
      rxclk_ce                   : in  std_logic;

      data_early                 : in  std_logic_vector(7 downto 0);
      data_valid_early           : in  std_logic;

      rx_pause_addr              : in  std_logic_vector(47 downto 0);
      update_pause_ad            : in  std_logic;
      promiscuous_mode_init      : in  std_logic;

      rx_filtered_data           : out std_logic_vector(7 downto 0);
      rx_filtered_data_valid     : out std_logic;

      unicastaddressmatch        : out std_logic;
      broadcastaddressmatch      : out std_logic;
      pauseaddressmatch          : out std_logic;
      specialpauseaddressmatch   : out std_logic;
      rxstatsaddressmatch        : out std_logic;
      rx_filter_match            : out std_logic_vector(C_AT_ENTRIES downto 0);

      bus2ip_clk                 : in  std_logic;
      bus2ip_reset               : in  std_logic;
      bus2ip_ce                  : in  std_logic;
      bus2ip_rdce                : in  std_logic;
      bus2ip_wrce                : in  std_logic;
      ip2bus_rdack               : out std_logic;
      ip2bus_wrack               : out std_logic;
      bus2ip_addr                : in  std_logic_vector(31 downto 0);
      bus2ip_data                : in  std_logic_vector(31 downto 0);
      ip2bus_data                : out std_logic_vector(31 downto 0);
      ip2bus_error               : out std_logic
   );
   end component;


   component axi_ethernet_v3_01_a_v6_address_filter_wrap_16
   generic (
      C_AT_ENTRIES               : integer := 8;
      C_HAS_HOST                 : integer := 1;
      C_ADD_FILTER               : integer := 1
   );
   port (
      rxcoreclk                  : in  std_logic;
      rx_sync_reset              : in  std_logic;
      rxclk_ce                   : in  std_logic;

      data_early                 : in  std_logic_vector(15 downto 0);
      data_valid_early           : in  std_logic;
      data_valid_msw_early       : in  std_logic;

      rx_pause_addr              : in  std_logic_vector(47 downto 0);
      update_pause_ad            : in  std_logic;
      promiscuous_mode_init      : in  std_logic;

      rx_filtered_data           : out std_logic_vector(15 downto 0);
      rx_filtered_data_valid     : out std_logic;
      rx_filtered_data_valid_msw : out std_logic;
      
      unicastaddressmatch        : out std_logic;
      broadcastaddressmatch      : out std_logic;
      pauseaddressmatch          : out std_logic;
      specialpauseaddressmatch   : out std_logic;
      rxstatsaddressmatch        : out std_logic;
      rx_filter_match            : out std_logic_vector(C_AT_ENTRIES downto 0);

      bus2ip_clk                 : in  std_logic;
      bus2ip_reset               : in  std_logic;
      bus2ip_ce                  : in  std_logic;
      bus2ip_rdce                : in  std_logic;
      bus2ip_wrce                : in  std_logic;
      ip2bus_rdack               : out std_logic;
      ip2bus_wrack               : out std_logic;
      bus2ip_addr                : in  std_logic_vector(31 downto 0);
      bus2ip_data                : in  std_logic_vector(31 downto 0);
      ip2bus_data                : out std_logic_vector(31 downto 0);
      ip2bus_error               : out std_logic
   );
   end component;

   
begin
  
   tx_avb_en     <= TX_CE_SAMPLE;   -- added for avb connection 03/21/2011  

   tie_to_pwr    <= '1';
   tie_to_gnd    <= '0';
   tie_to_gnd_32 <= (others =>'0');

   TX_STATISTICS_VECTOR <= INT_TX_STATISTICS_VECTOR;
   TX_STATISTICS_VALID  <= INT_TX_STATISTICS_VALID;

  VECTORGEN : if (C_HAS_HOST) generate
   RX_STATISTICS_VECTOR <= rxstatsaddressmatch & INT_RX_STATISTICS_VECTOR(26 downto 0);
  end generate VECTORGEN;
  INTVECTORGEN : if (not C_HAS_HOST) generate
   RX_STATISTICS_VECTOR <= INT_RX_STATISTICS_VECTOR(27 downto 0);
  end generate INTVECTORGEN;
   RX_STATISTICS_VALID  <= INT_RX_STATISTICS_VALID;

   TX_RESET_OUT <= TX_RESET;
   RX_RESET_OUT <= RX_RESET;

   SPEED_IS_10_100 <= SPEED_IS_10_100_INT;
   TX_COLLISION <= TX_COLLISION_INT;
   TX_RETRANSMIT <= TX_RETRANSMIT_INT;

   PAUSESHIM_16_GEN : if (EMAC_CLIENT_16) generate

     pausereq_shim_inst : axi_ethernet_v3_01_a_pausereq_shim
     port map (
        reset                => TX_RESET,
        client_clk           => TX_AXI_CLK_PHY,
        client_clk_en        => TX_CE_SAMPLE,
        tx_stats_bytevld     => TX_STATS_BYTEVLD,
        pause_req            => PAUSE_REQ,
        pause_val            => PAUSE_VAL,
        pause_req_out        => PAUSE_REQ_INT,
        pause_val_out        => PAUSE_VAL_INT
     );

    end generate PAUSESHIM_16_GEN;
    PAUSESHIM_8_GEN : if (not EMAC_CLIENT_16) generate

     pausereq_shim_inst2 : axi_ethernet_v3_01_a_pausereq_shim
     port map (
        reset                => TX_RESET,
        client_clk           => TX_AXI_CLK,
        client_clk_en        => TX_CE_SAMPLE,
        tx_stats_bytevld     => TX_STATS_BYTEVLD,
        pause_req            => PAUSE_REQ,
        pause_val            => PAUSE_VAL,
        pause_req_out        => PAUSE_REQ_INT,
        pause_val_out        => PAUSE_VAL_INT
     );

   end generate PAUSESHIM_8_GEN;

  FCSBLKGEN : if (not C_HAS_SGMII and not C_HAS_GPCS) generate
   -----------------------------------------------------------------------------
   -- FCS Shim logic
   -----------------------------------------------------------------------------
   -- Instantiate the FCS block to correct possible duplicate
   -- transmission of the final FCS byte
   fcs_blk_inst : entity axi_ethernet_v3_01_a.fcs_blk
   generic map (
      rgmii_enable         => c_has_rgmii_v2_0
   )
   port map (
      reset                => TX_RESET,
      tx_phy_clk           => TX_AXI_CLK,
      txd_from_mac         => GMII_TXD_INT,
      tx_en_from_mac       => GMII_TX_EN_INT,
      tx_er_from_mac       => GMII_TX_ER_INT,
      tx_client_clk        => TX_AXI_CLK,
      tx_stats_byte_valid  => TX_STATS_BYTEVLD,
      tx_collision         => TX_COLLISION_INT,
      speed_is_10_100      => SPEED_IS_10_100_INT,
      txd                  => GMII_TXD,
      tx_en                => GMII_TX_EN,
      tx_er                => GMII_TX_ER
   );
  end generate FCSBLKGEN;

  NOFCSBLKGEN : if (C_HAS_SGMII or C_HAS_GPCS) generate

      GMII_TXD    <= GMII_TXD_INT;
      GMII_TX_EN  <= GMII_TX_EN_INT;
      GMII_TX_ER  <= GMII_TX_ER_INT;

  end generate NOFCSBLKGEN;

   -----------------------------------------------------------------------------
   -- AXI Stream Shim logic
   -----------------------------------------------------------------------------
   rx_axi_shim : axi_ethernet_v3_01_a_v6_rx_axi_intf
   generic map (
      c_at_entries         => c_at_entries,
      c_client_16          => C_CLIENT_16_VLOG

   )
   port map (
      rx_clk               => RX_AXI_CLK,
      rx_reset             => RX_RESET,
      rx_enable            => RX_CE_SAMPLE,

      rx_data              => RX_DATA_OUT(7 downto 0),
      rx_data_valid        => RX_DATA_VALID_OUT,
      rx_data_valid_msw    => RX_DATA_VALID_MSW_OUT,
      rx_good_frame        => RX_GOOD_FRAME,
      rx_bad_frame         => RX_BAD_FRAME,
      rx_frame_match       => MATCH_FRAME_INT,

      rx_filter_match      => RX_FILTER_MATCH,
      rx_filter_tuser      => RX_AXIS_FILTER_TUSER,

      rx_mac_tdata         => RX_AXIS_MAC_TDATA,
      rx_mac_tkeep         => RX_AXIS_MAC_TKEEP,
      rx_mac_tvalid        => RX_AXIS_MAC_TVALID,
      rx_clk_enable_out    => RX_CLK_ENABLE_OUT,
      rx_mac_tlast         => RX_AXIS_MAC_TLAST,
      rx_mac_tuser         => RX_AXIS_MAC_TUSER
   );

   tx_axi_shim : axi_ethernet_v3_01_a_v6_tx_axi_intf
   generic map (
      c_has_sgmii          => c_has_sgmii_vlog,
      c_client_16          => C_CLIENT_16_VLOG
   )
   port map (
      tx_clk               => TX_AXI_CLK,
      tx_reset             => TX_RESET,
      tx_enable            => TX_CE_SAMPLE,
      speed_is_10_100      => SPEED_IS_10_100_INT,

      tx_mac_tdata         => TX_AXIS_MAC_TDATA,
      tx_mac_tkeep         => TX_AXIS_MAC_TKEEP,
      tx_mac_tvalid        => TX_AXIS_MAC_TVALID,
      tx_mac_tlast         => TX_AXIS_MAC_TLAST,
      tx_mac_tuser         => TX_AXIS_MAC_TUSER,
      tx_mac_tready        => TX_AXIS_MAC_TREADY,

      tx_enable_out        => open,
      tx_continuation      => open,
      tx_data              => TX_DATA(7 downto 0),
      tx_data_valid        => TX_DATA_VALID,
      tx_data_valid_msw    => TX_DATA_VALID_MSW,
      tx_underrun          => TX_UNDERRUN,
      tx_ack               => TX_ACK,
      tx_retransmit        => TX_RETRANSMIT_INT
   );

  NO16BIT : if (not EMAC_CLIENT_16) generate
   TX_DATA(15 downto 8) <= (others => '0');
   end generate NO16BIT;


  ----------------------------------------------------------------------------
  -- The resets for the various MAC sub-components. These are the
  -- global reset OR'ed with the software resets from the configuration
  -- block. They are then passed through synchroniser components so that the
  -- falling edge occurs at a controllable time w.r.t. the relevant clock edge.
  ----------------------------------------------------------------------------

   INT_RST <= not GLBL_RSTN;

   SYNC_STATS_RESET: entity axi_ethernet_v3_01_a.SYNC_RESET
   port map (
      RESET_IN             => INT_RST,
      CLK                  => STATS_REF_CLK,
      RESET_OUT            => STATS_RESET
   );

   INT_TX_RST_ASYNCH <= not GLBL_RSTN or not TX_AXI_RSTN or TX_SOFT_RESET;


   SYNC_TX_RESET_I: entity axi_ethernet_v3_01_a.SYNC_RESET
   port map (
      RESET_IN             => INT_TX_RST_ASYNCH,
      CLK                  => TX_AXI_CLK,
      RESET_OUT            => TX_RESET
   );


   INT_RX_RST_ASYNCH <= not GLBL_RSTN or not RX_AXI_RSTN or RX_SOFT_RESET;

   SYNC_RX_RESET_I: entity axi_ethernet_v3_01_a.SYNC_RESET
   port map (
      RESET_IN             => INT_RX_RST_ASYNCH,
      CLK                  => RX_AXI_CLK,
      RESET_OUT            => RX_RESET
   );

   G_HAS_NO_IPIF : if (not C_HAS_HOST) generate
      INT_GLBL_RST <= not GLBL_RSTN;
   end generate G_HAS_NO_IPIF;

   G_HAS_IPIF : if (C_HAS_HOST) generate

      -- JK 19 Feb 2010: Input to host reset synchronizer is an OR of RESET, BUS2IP_RESET.
      INT_MGMT_HOST_RESET_INPUT <= not GLBL_RSTN or BUS2IP_RESET;
      INT_GLBL_RST <= not GLBL_RSTN; -- or BUS2IP_RESET;

      -- JK 19 Feb 2010: Changed input from global async RESET to new INT_MGMT_HOST_RESET_INPUT.
      SYNC_MGMT_RESET_HOST_I : entity axi_ethernet_v3_01_a.SYNC_RESET
      port map (
         RESET_IN             => INT_MGMT_HOST_RESET_INPUT,
         CLK                  => BUS2IP_CLK,
         RESET_OUT            => INT_MGMT_HOST_RESET
      );


      ipic_host_shim : axi_ethernet_v3_01_a_v6_ipic_host_if
      generic map (
         reg_mapped       => 1,              
         async            => 0,              
         c_tri_speed      => c_tri_speed_vlog,              
         c_speed_10       => c_speed_10_vlog,              
         c_speed_100      => c_speed_100_vlog,              
         c_speed_1000     => c_speed_1000_vlog,              
         c_has_mii        => c_has_mii_vlog,         
         c_has_gmii       => c_has_gmii_vlog,         
         c_has_rgmii_v2_0 => c_has_rgmii_v2_0_vlog,         
         c_has_stats      => c_has_stats_vlog,         
         c_add_filter     => c_add_filter_vlog          
      )
      port map (
         ----------------------------------------------------------------------
         -- IPIC Interface
         ----------------------------------------------------------------------

         link_timer_value     => link_timer_value,
         bus2ip_clk           => BUS2IP_CLK,
         bus2ip_reset         => INT_MGMT_HOST_RESET,
         -- unused memory mapped input/outputs
         bus2ip_addrvalid     => tie_to_gnd,
         bus2ip_cs            => tie_to_gnd,
         bus2ip_rnw           => tie_to_gnd,
         ip2bus_ack           => open,
         -- register mapped input/outputs
         bus2ip_ce            => BUS2IP_CS_INT(1),
         bus2ip_rdce          => BUS2IP_RDCE_INT(1),
         bus2ip_wrce          => BUS2IP_WRCE_INT(1),
         ip2bus_wrack         => IP2BUS_WRACK_CONFIG_INT,
         ip2bus_rdack         => IP2BUS_RDACK_CONFIG_INT,

         bus2ip_addr          => BUS2IP_ADDR,
         bus2ip_data          => BUS2IP_DATA,
         ip2bus_data          => IP2BUS_DATA_CONFIG_INT,
         ip2bus_error         => IP2BUS_ERROR_CONFIG_INT,
         ip2bus_tousup        => open,

         base_x_switch        => BASE_X_SWITCH,

         ----------------------------------------------------------------------
         -- local registers
         ----------------------------------------------------------------------

         tie_pause_addr       => emac_pauseaddr_std_logic,--to_stdlogicvector(C_EMAC_PAUSEADDR),--to_stdlogicvector(EMAC_PAUSEADDR),
                   -- simulator was assigning High Z to  tie_pause_addr with to_stdlogicvector(C_EMAC_PAUSEADDR)
         pause_addr           => PAUSE_ADDR,
         update_pause_addr    => INT_UPDATE_PAUSE_AD,
         tx_soft_reset        => TX_SOFT_RESET,
         rx_soft_reset        => RX_SOFT_RESET,

         ----------------------------------------------------------------------
         -- Ethernet MAC Host Interface
         ----------------------------------------------------------------------

         host_clk             => BUS2IP_CLK,
         host_reset           => INT_MGMT_HOST_RESET,
         host_opcode          => HOSTOPCODE,
         host_addr            => HOSTADDR,
         host_wr_data         => HOSTWRDATA,
         host_req             => HOSTREQ,
         host_miim_sel        => HOSTMIIMSEL,
         host_rd_data_mac     => HOSTRDDATA,
         host_miim_rdy        => HOSTMIIMRDY,

         temac_intr           => MAC_IRQ

      );

      -----------------------------------------------------------------------------
      -- Multiplex IPIC RdAck, WrAck, Error, Data response signals onto IP2BUS
      -- JK 19 Feb 2010: Added as part of the transition from host to IPIC.
      -----------------------------------------------------------------------------

      ipic_mux_inst : axi_ethernet_v3_01_a_v6_ipic_mux
      port map (
         bus2ip_clk           => BUS2IP_CLK,
         bus2ip_reset         => INT_MGMT_HOST_RESET,
         bus2ip_addr          => BUS2IP_ADDR(10 downto 8),
         bus2ip_cs            => BUS2IP_CS,
         bus2ip_rdce          => BUS2IP_RDCE,
         bus2ip_wrce          => BUS2IP_WRCE,
         bus2ip_cs_int        => BUS2IP_CS_INT,
         bus2ip_rdce_int      => BUS2IP_RDCE_INT,
         bus2ip_wrce_int      => BUS2IP_WRCE_INT,
         ip2bus_rdack         => IP2BUS_RDACK,
         ip2bus_wrack         => IP2BUS_WRACK,
         ip2bus_error         => IP2BUS_ERROR,
         ip2bus_data          => IP2BUS_DATA,
         ip2bus_rdack_stats   => IP2BUS_RDACK_STATS_INT,
         ip2bus_rdack_config  => IP2BUS_RDACK_CONFIG_INT,
         ip2bus_rdack_intr    => tie_to_gnd,
         ip2bus_rdack_af      => IP2BUS_RDACK_AF_INT,
         ip2bus_wrack_stats   => IP2BUS_WRACK_STATS_INT,
         ip2bus_wrack_config  => IP2BUS_WRACK_CONFIG_INT,
         ip2bus_wrack_intr    => tie_to_gnd,
         ip2bus_wrack_af      => IP2BUS_WRACK_AF_INT,
         ip2bus_error_stats   => IP2BUS_ERROR_STATS_INT,
         ip2bus_error_config  => IP2BUS_ERROR_CONFIG_INT,
         ip2bus_error_intr    => tie_to_gnd,
         ip2bus_error_af      => IP2BUS_ERROR_AF_INT,
         ip2bus_data_stats    => IP2BUS_DATA_STATS_INT,
         ip2bus_data_config   => IP2BUS_DATA_CONFIG_INT,
         ip2bus_data_intr     => tie_to_gnd_32,
         ip2bus_data_af       => IP2BUS_DATA_AF_INT
      );

   end generate G_HAS_IPIF;

 
  -----------------------------------------------------------------------------
  -- Statistics
  -----------------------------------------------------------------------------

  -- MN 8 April 2010: instance of the statistics counter
  -- if no CPU or stats then do not generate
  -- in the hard mac case also need the decode logic to calculate rx_byte, tx_byte, rx_frag and rx_small
  -- as these are no longer in the netlist io..

  -- push the following logic into a local decode block
  ---------------------------------------------------------------------
  -- Statistic update inputs for the 4 fast statistics
  ---------------------------------------------------------------------

 


    STATGEN_8 : if (C_HAS_HOST and C_HAS_STATS and not EMAC_CLIENT_16) generate

  -- Counter 1: "Received bytes" increment request
  --------------
  -- need to delays the rx_stats_bytevld to prevent it being cut off at the start
  RX_PIPE_BYTEVLD_GEN: process (RX_AXI_CLK_STAT)
  begin
     if RX_AXI_CLK_STAT'event and RX_AXI_CLK_STAT = '1' then
       if RX_CE_SAMPLE = '1' then
          RX_PIPE_BYTEVLD(0) <= RX_STATS_BYTEVLD;
          RX_PIPE_BYTEVLD(1) <= RX_PIPE_BYTEVLD(0);
          RX_PIPE_BYTEVLD(2) <= RX_PIPE_BYTEVLD(1);
          RX_PIPE_BYTEVLD(3) <= RX_PIPE_BYTEVLD(2);
          RX_PIPE_BYTEVLD(4) <= RX_PIPE_BYTEVLD(3);
          RX_PIPE_BYTEVLD(5) <= RX_PIPE_BYTEVLD(4);
          RX_PIPE_BYTEVLD(6) <= RX_PIPE_BYTEVLD(5);
          RX_PIPE_BYTEVLD(7) <= RX_PIPE_BYTEVLD(6);
          RX_PIPE_BYTEVLD(8) <= RX_PIPE_BYTEVLD(7);
          RX_PIPE_BYTEVLD(9) <= RX_PIPE_BYTEVLD(8);
          RX_PIPE_BYTEVLD(10) <= RX_PIPE_BYTEVLD(9);
          RX_PIPE_BYTEVLD(11) <= RX_PIPE_BYTEVLD(10);
          RX_PIPE_BYTEVLD(12) <= RX_PIPE_BYTEVLD(11);
          RX_PIPE_BYTEVLD(13) <= RX_PIPE_BYTEVLD(12);
        end if;
     end if;
  end process RX_PIPE_BYTEVLD_GEN;

  
  RX_BYTE <= RX_CE_SAMPLE and RX_PIPE_BYTEVLD(13) and rxstatsaddressmatch;

  end generate STATGEN_8;

  STATGEN_16 : if (C_HAS_HOST and C_HAS_STATS and EMAC_CLIENT_16) generate
    
  -- Counter 1: "Received bytes" increment request
  --------------
  -- need to delays the rx_stats_bytevld to prevent it being cut off at the start
  RX_PIPE_BYTEVLD_GEN: process (RX_AXI_CLK_STAT)
  begin
     if RX_AXI_CLK_STAT'event and RX_AXI_CLK_STAT = '1' then
       if RX_CE_SAMPLE = '1' then
          RX_PIPE_BYTEVLD(0) <= RX_STATS_BYTEVLD;
          RX_PIPE_BYTEVLD(1) <= RX_PIPE_BYTEVLD(0);
          RX_PIPE_BYTEVLD(2) <= RX_PIPE_BYTEVLD(1);
          RX_PIPE_BYTEVLD(3) <= RX_PIPE_BYTEVLD(2);
          RX_PIPE_BYTEVLD(4) <= RX_PIPE_BYTEVLD(3);
          RX_PIPE_BYTEVLD(5) <= RX_PIPE_BYTEVLD(4);
          RX_PIPE_BYTEVLD(6) <= RX_PIPE_BYTEVLD(5);
          RX_PIPE_BYTEVLD(7) <= RX_PIPE_BYTEVLD(6);
          RX_PIPE_BYTEVLD(8) <= RX_PIPE_BYTEVLD(7);
          RX_PIPE_BYTEVLD(9) <= RX_PIPE_BYTEVLD(8);
          RX_PIPE_BYTEVLD(10) <= RX_PIPE_BYTEVLD(9);
          RX_PIPE_BYTEVLD(11) <= RX_PIPE_BYTEVLD(10);
          RX_PIPE_BYTEVLD(12) <= RX_PIPE_BYTEVLD(11);
          RX_PIPE_BYTEVLD(13) <= RX_PIPE_BYTEVLD(12);
          RX_PIPE_BYTEVLD(14) <= RX_PIPE_BYTEVLD(13);
          RX_PIPE_BYTEVLD(15) <= RX_PIPE_BYTEVLD(14);
        end if;
     end if;
  end process RX_PIPE_BYTEVLD_GEN;


  RX_BYTE <= RX_CE_SAMPLE and RX_PIPE_BYTEVLD(15) and rxstatsaddressmatch;

  end generate STATGEN_16;

  STATGEN : if (C_HAS_HOST and C_HAS_STATS) generate

   -- Counter 0: "Transmitted bytes" increment request
  --------------
  TX_BYTE <= TX_STATS_BYTEVLD and TX_CE_SAMPLE;

  -- Counter 2: "Undersize frames received" increment request
  --------------
  RX_SMALL_GEN: process (RX_AXI_CLK_STAT)
  begin
     if RX_AXI_CLK_STAT'event and RX_AXI_CLK_STAT = '1' then
       if RX_RESET_STAT = '1' then
          RX_SMALL_INT      <= '0';
       elsif RX_CE_SAMPLE = '1' then
          if INT_RX_STATISTICS_VECTOR(18 downto 11) = "00000000" and 
             INT_RX_STATISTICS_VALID = '1'  and
             INT_RX_STATISTICS_VECTOR(26) = '0' and INT_RX_STATISTICS_VECTOR(2) = '0' then
             RX_SMALL_INT   <= '1';
          else
             RX_SMALL_INT   <= '0';
          end if;
       end if;
     end if;
  end process RX_SMALL_GEN;
  
  RX_SMALL <= RX_CE_SAMPLE and RX_SMALL_INT;

  -- Counter 3: "Fragment frames received" increment request
  --------------
  RX_FRAG_GEN: process (RX_AXI_CLK_STAT)
  begin
     if RX_AXI_CLK_STAT'event and RX_AXI_CLK_STAT = '1' then
       if RX_RESET_STAT = '1' then
          RX_FRAG_INT      <= '0';
       elsif RX_CE_SAMPLE = '1' then
          if INT_RX_STATISTICS_VECTOR(18 downto 11) = "00000000" and 
             INT_RX_STATISTICS_VALID = '1' and 
             (INT_RX_STATISTICS_VECTOR(26) = '1' or INT_RX_STATISTICS_VECTOR(2) = '1')  then
             RX_FRAG_INT   <= '1';
          else
             RX_FRAG_INT   <= '0';
          end if;
       end if;
     end if;
  end process RX_FRAG_GEN;

  RX_FRAG <=  RX_CE_SAMPLE and RX_FRAG_INT;
  
   statistics_counters : entity axi_ethernet_v3_01_a.statistics_core
   generic map (
     c_num_stats              => c_num_stats,  -- allow two counters miniumu for user defined counters
     c_cntr_rst               => c_cntr_rst,
     c_stats_width            => c_stats_width)
   port map (
      ref_clk                 => STATS_REF_CLK,
      ref_reset               => STATS_RESET,

      bus2ip_clk              => BUS2IP_CLK,
      bus2ip_reset            => INT_MGMT_HOST_RESET,

      bus2ip_ce               => BUS2IP_CS_INT(0),    -- Bit 0 from IPIF corresponds to Stats address range
      bus2ip_rdce             => BUS2IP_RDCE_INT(0),  -- Bit 0 from IPIF corresponds to Stats address range
      bus2ip_wrce             => BUS2IP_WRCE_INT(0),  -- Bit 0 from IPIF corresponds to Stats address range
      ip2bus_wrack            => IP2BUS_WRACK_STATS_INT,
      ip2bus_rdack            => IP2BUS_RDACK_STATS_INT,

      bus2ip_addr             => BUS2IP_ADDR(10 downto 0),
      bus2ip_data             => BUS2IP_DATA,
      ip2bus_data             => IP2BUS_DATA_STATS_INT,
      ip2bus_error            => IP2BUS_ERROR_STATS_INT,

      tx_clk                  => TX_AXI_CLK_STAT,
      tx_reset                => TX_RESET,
      tx_byte                 => TX_BYTE,
      rx_clk                  => RX_AXI_CLK_STAT,
      rx_reset                => RX_RESET,
      rx_byte                 => RX_BYTE,
      rx_small                => RX_SMALL,
      rx_frag                 => RX_FRAG,
      increment_vector        => INCREMENT_VECTOR
   );
  end generate STATGEN;

  NOSTATGEN : if (C_HAS_HOST and not C_HAS_STATS) generate

     IP2BUS_WRACK_STATS_INT <= BUS2IP_WRCE_INT(0);
     IP2BUS_RDACK_STATS_INT <= BUS2IP_RDCE_INT(0);
     IP2BUS_DATA_STATS_INT <= (others => '0');
     IP2BUS_ERROR_STATS_INT <= '0';

  end generate NOSTATGEN;

  ADDRGEN : if (C_HAS_HOST) generate

     -----------------------------------------------------------------------------
     -- Address Filtering
     -----------------------------------------------------------------------------

    FILTERGEN8: if (not EMAC_CLIENT_16) generate

     -- JK 26 Feb 2010: This is an instance of the new address filter, which is a
     -- Verilog module that is based on the extended pattern matching of Eth.AVB.
     addr_filter_top : axi_ethernet_v3_01_a_v6_address_filter_wrap
        -- JK 26 Feb 2010: For simplicity of first-pass integration, the address
        -- filter is assumed to be always on and with an IPIC interface. The
        -- C_HAS_HOST and C_ADDR_FILTER generic will be re-introduced as
        -- verification proceeds.
        generic map (
         c_at_entries                => c_at_entries,
         c_has_host                  => c_has_host_vlog,
         c_add_filter                => c_add_filter_vlog
         --c_unicast_pause_address     => to_stdlogicvector(emac_unicastaddr)
        )
        port map (
         rxcoreclk                   => RX_AXI_CLK,
         rx_sync_reset               => RX_RESET,
         rxclk_ce                    => RX_CE_SAMPLE,
         data_early                  => RX_DATA(7 downto 0),
         data_valid_early            => RX_DATA_VALID,
         rx_pause_addr               => PAUSE_ADDR,
         update_pause_ad             => INT_UPDATE_PAUSE_AD,
         promiscuous_mode_init       => tie_to_pwr,     -- was '0', but simulator was assigning High Z to  promiscuous_mode_init
                                                        -- changed to power to match soft temac core
         rx_filtered_data            => RX_DATA_OUT(7 downto 0),
         rx_filtered_data_valid      => RX_DATA_VALID_OUT,
         unicastaddressmatch         => UNICASTADDRESSMATCH,
         broadcastaddressmatch       => BROADCASTADDRESSMATCH,
         pauseaddressmatch           => PAUSEADDRESSMATCH,
         specialpauseaddressmatch    => SPECIALPAUSEADDRESSMATCH,
         rxstatsaddressmatch         => rxstatsaddressmatch,
         rx_filter_match             => RX_FILTER_MATCH,
         bus2ip_clk                  => BUS2IP_CLK,
         bus2ip_reset                => INT_MGMT_HOST_RESET,
         bus2ip_ce                   => BUS2IP_CS_INT(3),    -- Bit 3 from IPIF corresponds to AF address range
         bus2ip_rdce                 => BUS2IP_RDCE_INT(3),  -- Bit 3 from IPIF corresponds to AF address range
         bus2ip_wrce                 => BUS2IP_WRCE_INT(3),  -- Bit 3 from IPIF corresponds to AF address range
         ip2bus_rdack                => IP2BUS_RDACK_AF_INT,
         ip2bus_wrack                => IP2BUS_WRACK_AF_INT,
         bus2ip_addr                 => BUS2IP_ADDR,
         bus2ip_data                 => BUS2IP_DATA,
         ip2bus_data                 => IP2BUS_DATA_AF_INT,
         ip2bus_error                => IP2BUS_ERROR_AF_INT
      );
       end generate FILTERGEN8;

        FILTERGEN16: if (EMAC_CLIENT_16) generate
     -- KL 22 June 2011: This is an instance of the 16-bit data path address filter, which is a
     -- Verilog module that is based on the extended pattern matching of Eth.AVB.
     addr_filter_top : axi_ethernet_v3_01_a_v6_address_filter_wrap_16
        generic map (
         c_at_entries                => c_at_entries,
         c_has_host                  => c_has_host_vlog,
         c_add_filter                => c_add_filter_vlog
        )
        port map (
         rxcoreclk                   => RX_AXI_CLK,
         rx_sync_reset               => RX_RESET,
         rxclk_ce                    => RX_CE_SAMPLE,
         data_early                  => RX_DATA,
         data_valid_early            => RX_DATA_VALID,
         data_valid_msw_early        => RX_DATA_VALID_MSW,
         rx_pause_addr               => PAUSE_ADDR,
         update_pause_ad             => INT_UPDATE_PAUSE_AD,
         promiscuous_mode_init       => tie_to_gnd,
         rx_filtered_data            => RX_DATA_OUT,
         rx_filtered_data_valid      => RX_DATA_VALID_OUT,
         rx_filtered_data_valid_msw  => RX_DATA_VALID_MSW_OUT,
         unicastaddressmatch         => UNICASTADDRESSMATCH,
         broadcastaddressmatch       => BROADCASTADDRESSMATCH,
         pauseaddressmatch           => PAUSEADDRESSMATCH,
         specialpauseaddressmatch    => SPECIALPAUSEADDRESSMATCH,
         rxstatsaddressmatch         => rxstatsaddressmatch_int,
         rx_filter_match             => RX_FILTER_MATCH,
         bus2ip_clk                  => BUS2IP_CLK,
         bus2ip_reset                => INT_MGMT_HOST_RESET,
         bus2ip_ce                   => BUS2IP_CS_INT(3),    -- Bit 3 from IPIF corresponds to AF address range
         bus2ip_rdce                 => BUS2IP_RDCE_INT(3),  -- Bit 3 from IPIF corresponds to AF address range
         bus2ip_wrce                 => BUS2IP_WRCE_INT(3),  -- Bit 3 from IPIF corresponds to AF address range
         ip2bus_rdack                => IP2BUS_RDACK_AF_INT,
         ip2bus_wrack                => IP2BUS_WRACK_AF_INT,
         bus2ip_addr                 => BUS2IP_ADDR,
         bus2ip_data                 => BUS2IP_DATA,
         ip2bus_data                 => IP2BUS_DATA_AF_INT,
         ip2bus_error                => IP2BUS_ERROR_AF_INT
      );

     -- Synchronize rxstatsaddressmatch to 2x clock to match rest of stats vector
      sync_statsmatch :  axi_ethernet_v3_01_a_sync_block
        port map (
         clk      => rx_axi_clk_phy,
         data_in  => rxstatsaddressmatch_int,
         data_out => rxstatsaddressmatch
         );
       
    end generate FILTERGEN16;


     -- have to do a lop to generate an OR of the bits in a unknown width bus
     RX_FILTER_COMB : process(RX_FILTER_MATCH)
       variable a : std_logic;
     begin
       a := '0';
       for i in 0 to (C_AT_ENTRIES) loop
          a := a or RX_FILTER_MATCH(i);
       end loop;
       RX_FILTER_MATCH_COMB <= a;
     end process RX_FILTER_COMB;

     -- capture the filter results to force frame drop if required
     MATCH_RESULTS: process (RX_AXI_CLK)
     begin
        if RX_AXI_CLK'event and RX_AXI_CLK = '1' then
          if RX_RESET = '1' then
             MATCH_FRAME_INT     <= '0';

          elsif RX_CE_SAMPLE = '1' then

             if RX_GOOD_FRAME = '1' or RX_BAD_FRAME = '1' then
                -- NOTE: if no address filter/promiscuous mode then rx_filter_match WILL be 1 otherwise
                -- one of the filters has to match to get a good indication
                if (RX_FILTER_MATCH_COMB = '1' or PAUSEADDRESSMATCH = '1' or
                   SPECIALPAUSEADDRESSMATCH = '1' or BROADCASTADDRESSMATCH = '1' or
                   UNICASTADDRESSMATCH = '1') and RX_GOOD_FRAME = '1' then
                   MATCH_FRAME_INT    <= '1';
                else
                   MATCH_FRAME_INT    <= '0';
                end if;
             end if;
          end if;
        end if;
     end process MATCH_RESULTS;

  end generate ADDRGEN;

  NOADDRGEN : if (not C_HAS_HOST) generate

     RX_DATA_OUT(7 downto 0) <= RX_DATA(7 downto 0);
     RX_DATA_VALID_OUT <= RX_DATA_VALID;
     RX_DATA_VALID_MSW_OUT <= RX_DATA_VALID_MSW;

     MATCH_RESULTS: process (RX_AXI_CLK)
     begin
        if RX_AXI_CLK'event and RX_AXI_CLK = '1' then
          if RX_RESET = '1' then
             MATCH_FRAME_INT     <= '0';

          elsif RX_CE_SAMPLE = '1' then

             if RX_GOOD_FRAME = '1' then
                MATCH_FRAME_INT    <= '1';
             elsif RX_BAD_FRAME = '1' then
                MATCH_FRAME_INT    <= '0';
             end if;
          end if;
        end if;
     end process MATCH_RESULTS;

  end generate NOADDRGEN;

   -- de-serialise the stats vectors so it looks the same as the soft mac
   -- the address match bit and byte_valid will be retimined to match up with the new frame filter

   -- don't look at address match bit as emac has to be in promiscuous mode
   -- with the frame filter performing generating the match (with the same timing as the soft mac
   RX_STATS_GEN: process (RX_AXI_CLK_STAT)
   begin
      if RX_AXI_CLK_STAT'event and RX_AXI_CLK_STAT = '1' then
         if RX_RESET_STAT = '1' then
            INT_RX_STATISTICS_VECTOR(27)               <= '1';
            INT_RX_STATISTICS_VECTOR(26 downto 0)      <= (others => '0');
            INT_RX_STATISTICS_VALID                    <= '0';
         elsif RX_CE_SAMPLE = '1' then
            if RX_STATS_SHIFT_VLD = '0' then
               INT_RX_STATISTICS_VECTOR(27)            <= '1';
               INT_RX_STATISTICS_VECTOR(26 downto 0)   <= (others => '0');
               INT_RX_STATISTICS_VALID                 <= '0';
            else
               INT_RX_STATISTICS_VECTOR(27 downto 21)  <= RX_STATS_SHIFT;
               INT_RX_STATISTICS_VECTOR(20 downto 14)  <= INT_RX_STATISTICS_VECTOR(27 downto 21);
               INT_RX_STATISTICS_VECTOR(13 downto 7)   <= INT_RX_STATISTICS_VECTOR(20 downto 14);
               INT_RX_STATISTICS_VECTOR(6 downto 0)    <= INT_RX_STATISTICS_VECTOR(13 downto 7);
               INT_RX_STATISTICS_VALID                 <= INT_RX_STATISTICS_VECTOR(6);
            end if;
         end if;
      end if;
   end process RX_STATS_GEN;

   TX_STATS_GEN: process (TX_AXI_CLK_STAT)
   begin
      if TX_AXI_CLK_STAT'event and TX_AXI_CLK_STAT = '1' then
         if TX_RESET_STAT = '1' then
            INT_TX_STATISTICS_VECTOR(31)               <= '1';
            INT_TX_STATISTICS_VECTOR(30 downto 0)      <= (others => '0');
            INT_TX_STATISTICS_VALID                    <= '0';
         elsif TX_CE_SAMPLE = '1' then
            if TX_STATS_SHIFT_VLD = '0' then
               INT_TX_STATISTICS_VECTOR(31)            <= '1';
               INT_TX_STATISTICS_VECTOR(30 downto 0)   <= (others => '0');
               INT_TX_STATISTICS_VALID                 <= '0';
            else
               INT_TX_STATISTICS_VECTOR(31)            <= TX_STATS_SHIFT;
               INT_TX_STATISTICS_VECTOR(30 downto 0)   <= INT_TX_STATISTICS_VECTOR(31 downto 1);
               INT_TX_STATISTICS_VALID                 <= INT_TX_STATISTICS_VECTOR(0);
            end if;
         end if;
      end if;
   end process TX_STATS_GEN;

  ------------------------------------------------------------------
  -- NEED TO MANAGE THE CLOCK CONNECTIVITY BASED ON THE PHY TYPE
  -- if gpcs or sgmii then phyclkin/out are not used and gtx_clk input is either full speed
  -- or half depending upon client mode
  PHYCLKGEN : if ((C_HAS_SGMII or C_HAS_GPCS) and not EMAC_CLIENT_16) generate
     TX_AXI_CLK_INT <= '0';
     TX_CE_SAMPLE   <= '1';
     RX_CE_SAMPLE   <= '1';
     TX_AXI_CLK_OUT <= TX_AXI_CLK_OUT_INT2;
     RX_AXI_CLK_INT <= '0';
  end generate PHYCLKGEN;
  -- need to drive differnt clock for 16 bit mode
  PHYCLKGEN16 : if ((C_HAS_SGMII or C_HAS_GPCS) and EMAC_CLIENT_16) generate
     TX_AXI_CLK_INT <= '0';
     TX_CE_SAMPLE   <= '1';
     RX_CE_SAMPLE   <= '1';
     TX_AXI_CLK_OUT <= TX_AXI_CLK_OUT_INT2;
     RX_AXI_CLK_INT <= GTX_CLK_DIV2;
  end generate PHYCLKGEN16;

  STATS_CLK_GEN_16 : if (EMAC_CLIENT_16) generate
    TX_AXI_CLK_STAT <= TX_AXI_CLK_PHY;
    RX_AXI_CLK_STAT <= rx_axi_clk_phy;
    TX_RESET_STAT   <= STATS_RESET;
    RX_RESET_STAT   <= STATS_RESET;
  end generate STATS_CLK_GEN_16;
   
  STATS_CLK_GEN_8 : if (not EMAC_CLIENT_16) generate
    TX_AXI_CLK_STAT <= TX_AXI_CLK;
    RX_AXI_CLK_STAT <= RX_AXI_CLK;
    TX_RESET_STAT   <= TX_RESET;
    RX_RESET_STAT   <= RX_RESET;
  end generate STATS_CLK_GEN_8;

  -- if a parallel interface is used then phyclkin/out are used and gtxclk may bee
  PARCLKGEN : if (not C_HAS_SGMII and not C_HAS_GPCS and not C_SPEED_1000) generate
     TX_AXI_CLK_INT <= TX_AXI_CLK;
     TX_CE_SAMPLE   <= TX_AXI_CLK_OUT_INT2;
     RX_CE_SAMPLE   <= RX_CLIENT_CE;
     TX_AXI_CLK_OUT <= TX_AXI_CLK_OUT_INT1;
     RX_AXI_CLK_INT <= RX_AXI_CLK;
     rx_axi_clk_phy <= '0';
     TX_AXI_CLK_PHY <= '0';
  end generate PARCLKGEN;
  GIGCLKGEN : if ((C_HAS_GMII or C_HAS_RGMII_V2_0) and C_SPEED_1000) generate
     TX_AXI_CLK_INT <= TX_AXI_CLK;
     TX_CE_SAMPLE   <= '1';
     RX_CE_SAMPLE   <= '1';
     TX_AXI_CLK_OUT <= TX_AXI_CLK_OUT_INT1;
     RX_AXI_CLK_INT <= RX_AXI_CLK;
     rx_axi_clk_phy <= RX_AXI_CLK;
     TX_AXI_CLK_PHY <= TX_AXI_CLK;
  end generate GIGCLKGEN;
  SGMIICLKGEN : if (C_HAS_SGMII) generate
     rx_axi_clk_phy <= TX_AXI_CLK;
     TX_AXI_CLK_PHY <= TX_AXI_CLK;
  end generate SGMIICLKGEN;
  PCSCLKGEN : if (C_HAS_GPCS) generate
     rx_axi_clk_phy <= GTX_CLK;
     TX_AXI_CLK_PHY <= GTX_CLK;
  end generate PCSCLKGEN;

  -- need to tie tx_mii_clk to either axi clock OR GND
  MIICLKGEN : if ((C_HAS_GMII and not C_SPEED_1000) or C_HAS_MII) generate
     MII_TX_CLK <= TX_AXI_CLK;
  end generate MIICLKGEN;
  NOTMIICLKGEN : if ((not C_HAS_GMII and not C_HAS_MII and not EMAC_CLIENT_16) or (C_HAS_GMII and C_SPEED_1000)) generate
     MII_TX_CLK <= '0';
  end generate NOTMIICLKGEN;
  C16CLKGEN : if (not C_HAS_GMII and not C_HAS_MII and EMAC_CLIENT_16) generate
     MII_TX_CLK <= GTX_CLK_DIV2;
  end generate C16CLKGEN;

  NOTGTXCLKGEN : if (C_HAS_GMII or C_HAS_MII or (C_HAS_RGMII_V2_0 and C_SPEED_1000)) generate
     GTX_CLK_INT <= '0';
  end generate NOTGTXCLKGEN;
  GTXCLKGEN : if (not C_HAS_GMII and not C_HAS_MII and not (C_HAS_RGMII_V2_0 and C_SPEED_1000)) generate
     GTX_CLK_INT <= GTX_CLK;
  end generate GTXCLKGEN;
  ------------------------------------------------------------------
  RXBUFSTATUS_INT <= RXBUFSTATUS & '0';

   -- Instantiate the Virtex-6 Embedded Tri-Mode Ethernet MAC
   v6_emac : TEMAC_SINGLE
   generic map (
      EMAC_1000BASEX_ENABLE         => C_HAS_GPCS,
      EMAC_ADDRFILTER_ENABLE        => FALSE,
      EMAC_BYTEPHY                  => C_BYTE_PHY,
      EMAC_DCRBASEADDR              => X"00",
      EMAC_GTLOOPBACK               => C_PHY_GTLOOPBACK,
      EMAC_HOST_ENABLE              => C_HAS_HOST,
      EMAC_LINKTIMERVAL             => C_EMAC_LINKTIMERVAL(8 downto 0), --EMAC_LINK_TIMER_VALUE(3 to 11),
      EMAC_LTCHECK_DISABLE          => C_LT_CHECK_DIS,
      EMAC_PHYINITAUTONEG_ENABLE    => C_PHY_AN,
      EMAC_PHYISOLATE               => C_PHY_ISOLATE,
      EMAC_PHYLOOPBACKMSB           => C_PHY_LOOPBACK_MSB,
      EMAC_PHYPOWERDOWN             => C_PHY_POWERDOWN,
      EMAC_PHYRESET                 => C_PHY_RESET,
      EMAC_RGMII_ENABLE             => C_HAS_RGMII_V2_0,
      EMAC_RX16BITCLIENT_ENABLE     => EMAC_CLIENT_16,
      EMAC_RXFLOWCTRL_ENABLE        => C_RX_FLOW_CONTROL,
      EMAC_RXINBANDFCS_ENABLE       => C_RX_FCS,
      EMAC_RXJUMBOFRAME_ENABLE      => C_RX_JUMBO,
      EMAC_RXVLAN_ENABLE            => C_RX_VLAN,
      EMAC_RX_ENABLE                => C_RX,
      EMAC_SGMII_ENABLE             => C_HAS_SGMII,
      EMAC_TX16BITCLIENT_ENABLE     => EMAC_CLIENT_16,
      EMAC_TXFLOWCTRL_ENABLE        => C_TX_FLOW_CONTROL,
      EMAC_TXIFGADJUST_ENABLE       => C_TX_IFG,
      EMAC_TXINBANDFCS_ENABLE       => C_TX_FCS,
      EMAC_TXJUMBOFRAME_ENABLE      => C_TX_JUMBO,
      EMAC_TXVLAN_ENABLE            => C_TX_VLAN,
      EMAC_TX_ENABLE                => C_TX,
      EMAC_UNIDIRECTION_ENABLE      => C_PHY_UNIDIRECTION_ENABLE,
      EMAC_USECLKEN                 => C_CLOCK_ENABLE,
      EMAC_MDIO_IGNORE_PHYADZERO    => C_PHY_IGNORE_ADZERO,
      EMAC_CTRLLENCHECK_DISABLE     => C_CTRL_LENCHECK_DISABLE,

      EMAC_RXRESET                  => EMAC_RX_RESET,
      EMAC_TXRESET                  => EMAC_TX_RESET,
      EMAC_MDIO_ENABLE              => EMAC_MDIO_ENABLE,
      EMAC_PAUSEADDR                => C_EMAC_PAUSEADDR, --EMAC_PAUSEADDR,
      EMAC_RXHALFDUPLEX             => EMAC_RXHALFDUPLEX,
      EMAC_SPEED_LSB                => EMAC_SPEED_LSB,
      EMAC_SPEED_MSB                => EMAC_SPEED_MSB,
      EMAC_TXHALFDUPLEX             => EMAC_TXHALFDUPLEX,
      EMAC_UNICASTADDR              => C_EMAC_UNICASTADDR --X"000000000000"
   )
   port map (
      RESET                         => INT_GLBL_RST,

      -- CLOCKS --------------------------------------
      -- Parallel interfaces: only used in RGMII
      PHYEMACGTXCLK                 => GTX_CLK_INT,
      PHYEMACTXGMIIMIICLKIN         => TX_AXI_CLK_INT,
      EMACPHYTXGMIIMIICLKOUT        => TX_AXI_CLK_OUT_INT1,

      -- Rx Client interface
      EMACCLIENTRXCLIENTCLKOUT      => RX_CLIENT_CE,
      CLIENTEMACRXCLIENTCLKIN       => rx_axi_clk_phy,

      -- Tx Client interface
      EMACCLIENTTXCLIENTCLKOUT      => TX_AXI_CLK_OUT_INT2,
      CLIENTEMACTXCLIENTCLKIN       => TX_AXI_CLK_PHY,

      -- Parallel phy interface
      PHYEMACRXCLK                  => RX_AXI_CLK_INT,
      EMACPHYTXCLK                  => open,
      PHYEMACMIITXCLK               => MII_TX_CLK,
      -------------------------------------------------

      -- CLIENT RX
      EMACCLIENTRXD                 => RX_DATA,
      EMACCLIENTRXDVLD              => RX_DATA_VALID,
      EMACCLIENTRXDVLDMSW           => open,
      EMACCLIENTRXGOODFRAME         => RX_GOOD_FRAME,
      EMACCLIENTRXBADFRAME          => RX_BAD_FRAME,

      -- RX stats
      EMACCLIENTRXFRAMEDROP         => open,
      EMACCLIENTRXSTATS             => RX_STATS_SHIFT,
      EMACCLIENTRXSTATSVLD          => RX_STATS_SHIFT_VLD,
      EMACCLIENTRXSTATSBYTEVLD      => RX_STATS_BYTEVLD,

      -- CLIENT TX
      CLIENTEMACTXD                 => TX_DATA,
      CLIENTEMACTXDVLD              => TX_DATA_VALID,
      CLIENTEMACTXDVLDMSW           => tie_to_gnd,
      EMACCLIENTTXACK               => TX_ACK,
      CLIENTEMACTXFIRSTBYTE         => tie_to_gnd,

      CLIENTEMACTXUNDERRUN          => TX_UNDERRUN,
      EMACCLIENTTXCOLLISION         => TX_COLLISION_INT,
      EMACCLIENTTXRETRANSMIT        => TX_RETRANSMIT_INT,
      CLIENTEMACTXIFGDELAY          => TX_IFG_DELAY,

      -- TX Stats
      EMACCLIENTTXSTATS             => TX_STATS_SHIFT,
      EMACCLIENTTXSTATSVLD          => TX_STATS_SHIFT_VLD,
      EMACCLIENTTXSTATSBYTEVLD      => TX_STATS_BYTEVLD,

      -- Pause control interface
      CLIENTEMACPAUSEREQ            => PAUSE_REQ_INT,
      CLIENTEMACPAUSEVAL            => PAUSE_VAL_INT,


      -- Parallel phy interface
      PHYEMACRXD                    => GMII_RXD,
      PHYEMACRXDV                   => GMII_RX_DV,
      PHYEMACRXER                   => GMII_RX_ER,

      EMACPHYTXD                    => GMII_TXD_INT,
      EMACPHYTXEN                   => GMII_TX_EN_INT,
      EMACPHYTXER                   => GMII_TX_ER_INT,
      PHYEMACCOL                    => GMII_COL,
      PHYEMACCRS                    => GMII_CRS,

      -- Serial Phy interface
      CLIENTEMACDCMLOCKED           => DCMLOCKED,
      EMACCLIENTANINTERRUPT         => ANINTERRUPT,
      PHYEMACSIGNALDET              => SIGNALDET,
      PHYEMACPHYAD                  => PHYAD,
      EMACPHYENCOMMAALIGN           => ENCOMMAALIGN,
      EMACPHYLOOPBACKMSB            => LOOPBACKMSB,
      EMACPHYMGTRXRESET             => MGTRXRESET,
      EMACPHYMGTTXRESET             => MGTTXRESET,
      EMACPHYPOWERDOWN              => POWERDOWN,
      EMACPHYSYNCACQSTATUS          => SYNCACQSTATUS,
      PHYEMACRXCLKCORCNT            => RXCLKCORCNT,
      PHYEMACRXBUFSTATUS            => RXBUFSTATUS_INT,
      PHYEMACRXCHARISCOMMA          => RXCHARISCOMMA,
      PHYEMACRXCHARISK              => RXCHARISK,
      PHYEMACRXDISPERR              => RXDISPERR,
      PHYEMACRXNOTINTABLE           => RXNOTINTABLE,
      PHYEMACRXRUNDISP              => RXRUNDISP,
      PHYEMACTXBUFERR               => TXBUFERR,
      EMACPHYTXCHARDISPMODE         => TXCHARDISPMODE,
      EMACPHYTXCHARDISPVAL          => TXCHARDISPVAL,
      EMACPHYTXCHARISK              => TXCHARISK,

      -- MDIO
      EMACPHYMCLKOUT                => MDC_OUT,
      PHYEMACMCLKIN                 => MDC_IN,
      PHYEMACMDIN                   => MDIO_IN,
      EMACPHYMDOUT                  => MDIO_OUT,
      EMACPHYMDTRI                  => MDIO_TRI,

      EMACSPEEDIS10100              => SPEED_IS_10_100_INT,

      -- Host interface
      HOSTCLK                       => BUS2IP_CLK,
      HOSTOPCODE                    => HOSTOPCODE,
      HOSTREQ                       => HOSTREQ,
      HOSTMIIMSEL                   => HOSTMIIMSEL,
      HOSTADDR                      => HOSTADDR,
      HOSTWRDATA                    => HOSTWRDATA,
      HOSTMIIMRDY                   => HOSTMIIMRDY,
      HOSTRDDATA                    => HOSTRDDATA,

      -- DCR interface (NOT USED)
      DCREMACCLK                    => tie_to_gnd,
      DCREMACABUS                   => "0000000000",
      DCREMACREAD                   => tie_to_gnd,
      DCREMACWRITE                  => tie_to_gnd,
      DCREMACDBUS                   => X"00000000",
      EMACDCRACK                    => open,
      EMACDCRDBUS                   => open,
      DCREMACENABLE                 => tie_to_gnd,
      DCRHOSTDONEIR                 => open
   );

end rtl;
