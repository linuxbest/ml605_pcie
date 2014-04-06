--------------------------------------------------------------------------------
-- File       : v6_emac_block_gmii.vhd
-- Author     : Xilinx Inc.
-- ------------------------------------------------------------------------------
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
-- Description: This is the block level Verilog design for the  Virtex-6
--               Embedded Tri-Mode Ethernet MAC Example Design.
--
--              This block level:
--
--              * instantiates the statistics counter decode logic for all user definable
--                counters
--
--              * instantiates the axi_ipif module to convert to the core IPIC
--                interface
--
--              * instantiates appropriate PHY interface module (GMII/MII/RGMII)
--                as required based on the user configuration;
--
--              Please refer to the Datasheet, Getting Started Guide, and
--              the Virtex-6 Embedded Tri-Mode Ethernet MAC User Gude for further information.
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
-------------------------------------------------------------------------------
-- This is based on Coregen Wrappers from ISE O.40d (13.1)
-- Wrapper version 2.1
-------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

--------------------------------------------------------------------------------
-- The entity declaration for the block level example design.
--------------------------------------------------------------------------------

entity v6_emac_block_gmii is
   generic (
      C_HAS_MII     : boolean := false;
      C_HAS_GMII    : boolean := true;
      C_HAS_RGMII   : boolean := false;
      C_HAS_SGMII   : boolean := false;
      C_HAS_GPCS    : boolean := false;
      C_PHY_WIDTH   : integer := 8;
      C_HALF_DUPLEX : boolean := true;
      C_HAS_HOST    : boolean := true;
      C_ADD_FILTER  : boolean := true;
      C_AT_ENTRIES  : integer := 4;
      C_FAMILY      : string  := "virtex6";
      C_SPEED_10_100: boolean := false;
      C_SPEED_1000  : boolean := false;
      C_TRI_SPEED   : boolean := true;
      C_HAS_STATS   : boolean := true;
      C_NUM_STATS   : integer := 44;      -- allow for max 42 standard counters plus two user defined
      C_CNTR_RST    : boolean := true;
      C_STATS_WIDTH : integer := 64;
      C_INTERNAL_INT: boolean := false;
      C_INCLUDE_IO  : integer range 0 to 1  := 1;
      C_HALFDUP     : integer range 0 to 1  := 0;
      C_TYPE        : integer range 0 to 2  := 0;
      C_PHY_TYPE    : integer range 0 to 7  := 1
   );

   port(
      gtx_clk                    : in  std_logic;
      -- asynchronous reset
      glbl_rstn                  : in  std_logic;
      rx_axi_rstn                : in  std_logic;
      tx_axi_rstn                : in  std_logic;

      -- Receiver Interface
      ----------------------------

      -- added 05/5/2011     
      RX_CLK_ENABLE_OUT           : out std_logic;

      rx_statistics_vector       : out std_logic_vector(27 downto 0);
      rx_statistics_valid        : out std_logic;
      rx_axis_filter_tuser       : out std_logic_vector(C_AT_ENTRIES downto 0);

      rx_mac_aclk                : out std_logic;
      rx_reset                   : out std_logic;
      rx_axis_mac_tdata          : out std_logic_vector(7 downto 0);
      rx_axis_mac_tvalid         : out std_logic;
      rx_axis_mac_tlast          : out std_logic;
      rx_axis_mac_tuser          : out std_logic;

      -- Transmitter Interface
      -------------------------------
      tx_ifg_delay               : in  std_logic_vector(7 downto 0);
      tx_statistics_vector       : out std_logic_vector(31 downto 0);
      tx_statistics_valid        : out std_logic;
      
      -- added for avb connection 03/21/2011     
      tx_avb_en                  : out std_logic;       

      tx_mac_aclk                : out std_logic;
      tx_reset                   : out std_logic;
      tx_axis_mac_tdata          : in  std_logic_vector(7 downto 0);
      tx_axis_mac_tvalid         : in  std_logic;
      tx_axis_mac_tlast          : in  std_logic;
      tx_axis_mac_tuser          : in  std_logic;
      tx_axis_mac_tready         : out std_logic;
      tx_collision               : out std_logic;
      tx_retransmit              : out std_logic;

      -- MAC Control Interface
      ------------------------
      pause_req                  : in  std_logic;
      pause_val                  : in  std_logic_vector(15 downto 0);

      -- Reference clock for IDELAYCTRL's
      refclk                     : in  std_logic;

      -- GMII Interface
      -----------------
      gmii_txd                   : out std_logic_vector(7 downto 0);
      gmii_tx_en                 : out std_logic;
      gmii_tx_er                 : out std_logic;
      gmii_tx_clk                : out std_logic;
      gmii_rxd                   : in  std_logic_vector(7 downto 0);
      gmii_rx_dv                 : in  std_logic;
      gmii_rx_er                 : in  std_logic;
      gmii_rx_clk                : in  std_logic;
      gmii_col                   : in  std_logic;
      gmii_crs                   : in  std_logic;
      mii_tx_clk                 : in  std_logic;


      -- Initial Unicast Address Value
--      unicast_address               : in std_logic_vector(47 downto 0);


      -- MDIO Interface
      -----------------
      mdio_i                     : in  std_logic;
      mdio_o                     : out std_logic;
      mdio_t                     : out std_logic;
      mdc                        : out std_logic;

      -- IPIC Interface
      -----------------
      Bus2IP_Clk                 : in  std_logic;
      Bus2IP_Reset               : in  std_logic;
      Bus2IP_Addr                : in  std_logic_vector(31 downto 0);
      Bus2IP_CS                  : in  std_logic;
      Bus2IP_RdCE                : in  std_logic;
      Bus2IP_WrCE                : in  std_logic;
      Bus2IP_Data                : in  std_logic_vector(31 downto 0);
      IP2Bus_Data                : out std_logic_vector(31 downto 0);
      IP2Bus_WrAck               : out std_logic;
      IP2Bus_RdAck               : out std_logic;
      IP2Bus_Error               : out std_logic;
      
      -- Speed Indicator
      mac_irq                    : out std_logic;
      speed_is_10_100            : out std_logic
   );
end v6_emac_block_gmii;


architecture wrapper of v6_emac_block_gmii is

   -----------------------------------------------------------------------------
   -- Component Declaration for V6 Hard EMAC Core.
   -----------------------------------------------------------------------------
   component v6_emac_v2_2
    port(
      glbl_rstn                   : in  std_logic;
      rx_axi_rstn                 : in  std_logic;
      tx_axi_rstn                 : in  std_logic;

      -- Clock signals
      ----------------------------
      gtx_clk                     : in  std_logic;
      tx_axi_clk_out              : out std_logic;
      
      ---------------------------------------------------------------------------
      -- Receiver Interface
      ---------------------------------------------------------------------------
      rx_axi_clk                  : in  std_logic;
      rx_reset_out                : out std_logic;
      rx_axis_mac_tdata           : out std_logic_vector(7 downto 0);
      rx_axis_mac_tvalid          : out std_logic;
      rx_axis_mac_tlast           : out std_logic;
      rx_axis_mac_tuser           : out std_logic;

      -- RX sideband signals
      rx_statistics_vector        : out std_logic_vector(27 downto 0);
      rx_statistics_valid         : out std_logic;
      rx_axis_filter_tuser        : out std_logic_vector(C_AT_ENTRIES -1 downto 0);

      ---------------------------------------------------------------------------
      -- Transmitter Interface
      ---------------------------------------------------------------------------
      tx_axi_clk                  : in  std_logic;
      tx_reset_out                : out std_logic;
      tx_axis_mac_tdata           : in  std_logic_vector(7 downto 0);
      tx_axis_mac_tvalid          : in  std_logic;
      tx_axis_mac_tlast           : in  std_logic;
      tx_axis_mac_tuser           : in  std_logic;
      tx_axis_mac_tready          : out std_logic;
              
      -- added for avb connection 03/21/2011     
      tx_avb_en                   : out std_logic;              

      -- TX sideband signals
      tx_retransmit               : out std_logic;
      tx_collision                : out std_logic;
      tx_ifg_delay                : in  std_logic_vector(7 downto 0);
      tx_statistics_vector        : out std_logic_vector(31 downto 0);
      tx_statistics_valid         : out std_logic;

      ---------------------------------------------------------------------------
      -- Statistics Interface
      ---------------------------------------------------------------------------
      stats_ref_clk               : in  std_logic;
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

      -- SGMII interface 1000BASE-X PCS/PMA interface
      --------------------------------
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
      mdc_out                     : out std_logic;
      mdio_in                     : in  std_logic;
      mdio_out                    : out std_logic;
      mdio_tri                    : out std_logic;

      ---------------------------------------------------------------------------
      -- IPIC Interface
      ---------------------------------------------------------------------------

      bus2ip_clk                  : in  std_logic;
      bus2ip_reset                : in  std_logic;
      bus2ip_addr                 : in  std_logic_vector(31 downto 0);
      bus2ip_cs                   : in  std_logic;
      bus2ip_rdce                 : in  std_logic;
      bus2ip_wrce                 : in  std_logic;
      bus2ip_data                 : in  std_logic_vector(31 downto 0);
      ip2bus_data                 : out std_logic_vector(31 downto 0);
      ip2bus_wrack                : out std_logic;
      ip2bus_rdack                : out std_logic;
      ip2bus_error                : out std_logic;

      mac_irq                     : out std_logic);
      --unicast_address             : in  std_logic_vector(47 downto 0)
   end component;


   -----------------------------------------------------------------------------
   -- Component Declaration for the GMII IOB logic
   -----------------------------------------------------------------------------
   component gmii_if
    generic (
        C_INCLUDE_IO      : integer range 0 to 1  := 1;
        C_HALFDUP         : integer range 0 to 1  := 0
    );
   port(
      -- Synchronous resets
      tx_reset             : in  std_logic;
      rx_reset             : in  std_logic;

      -- Current operating speed is 10/100
      speed_is_10_100      : in  std_logic;

      -- The following ports are the GMII physical interface: these will be at
      -- pins on the FPGA
      gmii_txd             : out std_logic_vector(7 downto 0);
      gmii_tx_en           : out std_logic;
      gmii_tx_er           : out std_logic;
      gmii_tx_clk          : out std_logic;
      gmii_crs             : in  std_logic;
      gmii_col             : in  std_logic;
      gmii_rxd             : in  std_logic_vector(7 downto 0);
      gmii_rx_dv           : in  std_logic;
      gmii_rx_er           : in  std_logic;
      gmii_rx_clk          : in  std_logic;

      -- The following ports are the internal GMII connections from IOB logic
      -- to the TEMAC core
      txd_from_mac         : in  std_logic_vector(7 downto 0);
      tx_en_from_mac       : in  std_logic;
      tx_er_from_mac       : in  std_logic;
      tx_clk               : in  std_logic;
      crs_to_mac           : out std_logic;
      col_to_mac           : out std_logic;
      rxd_to_mac           : out std_logic_vector(7 downto 0);
      rx_dv_to_mac         : out std_logic;
      rx_er_to_mac         : out std_logic;

      -- Receiver clock for the MAC and Client Logic
      rx_clk               : out  std_logic

   );
   end component;


  component vector_decode is
    generic(
      C_HALFDUP              : integer range  0 to 1  :=  0;
      C_NUM_STATS            : integer range 33 to 43 := 33
      );
   port (

      -- Transmitter Statistic Vector inputs from ethernet MAC
      tx_clk                           : in std_logic;  
      tx_reset                         : in std_logic;  
      tx_statistics_vector             : in std_logic_vector(31 downto 0);
      tx_statistics_valid              : in std_logic;

      -- Receiver Statistic Vector inputs from ethernet MAC
      rx_clk                           : in std_logic;  
      rx_reset                         : in std_logic;  
      rx_statistics_vector             : in std_logic_vector(27 downto 0);
      rx_statistics_valid              : in std_logic;

      -- Increment update signals for Statistic Counters 4 upwards
      increment_vector                 : out std_logic_vector(4 to C_NUM_STATS - 1)

   );
  end component;

  ------------------------------------------------------------------------------
  -- Component declaration for the synchronisation flip-flop pair
  ------------------------------------------------------------------------------
  component axi_ethernet_v3_01_a_sync_block
  port (
    clk                    : in  std_logic;    -- clock to be sync'ed to
    data_in                : in  std_logic;    -- Data to be 'synced'
    data_out               : out std_logic     -- synced data
    );
  end component;


  ------------------------------------------------------------------------------
  -- Component declaration for the reset synchroniser
  ------------------------------------------------------------------------------
  component reset_sync
  port (
    reset_in               : in  std_logic;    -- Active high asynchronous reset
    enable                 : in  std_logic;
    clk                    : in  std_logic;    -- clock to be sync'ed to
    reset_out              : out std_logic     -- "Synchronised" reset signal
    );
  end component;


  ------------------------------------------------------------------------------
  -- internal signals used in this block level wrapper.
  ------------------------------------------------------------------------------

  attribute keep : string;

   signal glbl_rst                        : std_logic;
   signal gtx_resetn                      : std_logic := '0';
  -- Signals used for the IDELAYCTRL reset circuitry
   signal idelayctrl_reset_sync           : std_logic;                    -- Used to create a reset pulse in the IDELAYCTRL refclk domain.
   signal idelay_reset_cnt                : std_logic_vector(3 downto 0); -- Counter to create a long IDELAYCTRL reset pulse.
   signal idelayctrl_reset                : std_logic;                    -- The reset pulse for the IDELAYCTRL.

   signal gmii_tx_en_int                  : std_logic;                    -- Internal gmii_tx_en signal.
   signal gmii_tx_er_int                  : std_logic;                    -- Internal gmii_tx_er signal.
   signal gmii_txd_int                    : std_logic_vector(7 downto 0); -- Internal gmii_txd signal.
   signal gmii_rx_dv_int                  : std_logic;                    -- gmii_rx_dv registered in IOBs.
   signal gmii_rx_er_int                  : std_logic;                    -- gmii_rx_er registered in IOBs.
   signal gmii_rxd_int                    : std_logic_vector(7 downto 0); -- gmii_rxd registered in IOBs.
   signal gmii_col_int                    : std_logic;                    -- Collision signal from the PHY module
   signal gmii_crs_int                    : std_logic;                    -- Carrier Sense signal from the PHY module



   signal speedis10100                : std_logic;                    -- Asserted when speed is 10Mb/s or 100Mb/s.

   signal tx_axi_clk_out                  : std_logic;
   signal rx_mac_aclk_int                 : std_logic;                    -- Internal receive gmii/mii clock signal.
   signal tx_mac_aclk_int                 : std_logic;                    -- Internal transmit gmii/mii clock signal.

   signal tx_reset_int                    : std_logic;                    -- Synchronous reset in the MAC and gmii Tx domain
   signal rx_reset_int                    : std_logic;                    -- Synchronous reset in the MAC and gmii Rx domain

   signal rx_statistics_vector_int        : std_logic_vector(27 downto 0);
   signal rx_statistics_valid_int         : std_logic;
   signal tx_statistics_vector_int        : std_logic_vector(31 downto 0);
   signal tx_statistics_valid_int         : std_logic;
  signal increment_vector         : std_logic_vector(4 to C_NUM_STATS - 1);
  signal gmii_rx_clk_in          : std_logic;
  signal rx_axis_mac_tkeep_int : std_logic_vector(1 downto 0);

  attribute keep of tx_mac_aclk_int    : signal is "true";
  attribute keep of rx_mac_aclk_int    : signal is "true";

  -----------------------------------------------------------------------------
  -- Function bool2int
  --
  -- This function is used to convert a boolean value TRUE and FALSE to
  -- an integer 1 or 0 respectively.
  -----------------------------------------------------------------------------
  function bool2int(inval: boolean) return integer is
    variable outval : integer := 0;
    begin
      if (inval = TRUE) then
        outval:=1;
      else
        outval:=0;
      end if;
      return outval;
  end bool2int;
  
  constant C_HALF_DUPLEX_INT : integer := bool2int(C_HALF_DUPLEX);

  -- Configure the EMAC addressing
  -- Set the PAUSE address default
  constant C_EMAC_PAUSEADDR : bit_vector := x"FFEEDDCCBBAA";
  -- Set the unicast address
  constant C_EMAC_UNICASTADDR : bit_vector := x"FFEEDDCCBBAA";
  constant C_EMAC_LINKTIMERVAL : bit_vector := x"13D";


begin

   -- MW take to Embedded IP 
   speed_is_10_100 <= speedis10100;

   -- assign outputs
   rx_reset <= rx_reset_int;
   tx_reset <= tx_reset_int;
   -- Assign the internal clock signals to output ports.
   tx_mac_aclk <= tx_mac_aclk_int;
   rx_mac_aclk <= rx_mac_aclk_int;

   glbl_rst <= not glbl_rstn;
   gtx_resetn      <= glbl_rstn;
   
   
  IO_YES_01 : if C_INCLUDE_IO = 1 generate
  begin   
   
   -----------------------------------------------------------------------------
   -- An IDELAYCTRL primitive needs to be instantiated for the Fixed Tap Delay
   -- mode of the IDELAY.
   -- All IDELAYs in Fixed Tap Delay mode and the IDELAYCTRL primitives have
   -- to be LOC'ed in the UCF file.
   -----------------------------------------------------------------------------
   -- Instantiate IDELAYCTRL for all IDELAY and ODELAY elements in the design
   dlyctrl : IDELAYCTRL
   port map (
      RDY               => open,
      REFCLK            => refclk,
      RST               => idelayctrl_reset
   );


   -- Create a synchronous reset in the IDELAYCTRL refclk clock domain.
   idelayctrl_reset_gen : reset_sync
   port map(
      clk               => refclk,
      enable            => '1',
      reset_in          => glbl_rst,
      reset_out         => idelayctrl_reset_sync
   );


   -- Reset circuitry for the IDELAYCTRL reset.

   -- The IDELAYCTRL must experience a pulse which is at least 50 ns in
   -- duration.  This is ten clock cycles of the 200MHz refclk.  Here we
   -- drive the reset pulse for 12 clock cycles.
   process (refclk)
   begin
      if refclk'event and refclk = '1' then
         if idelayctrl_reset_sync = '1' then
            idelay_reset_cnt <= "0000";
            idelayctrl_reset <= '1';
         else
            idelayctrl_reset <= '1';
            case idelay_reset_cnt is
            when "0000"  => idelay_reset_cnt <= "0001";
            when "0001"  => idelay_reset_cnt <= "0010";
            when "0010"  => idelay_reset_cnt <= "0011";
            when "0011"  => idelay_reset_cnt <= "0100";
            when "0100"  => idelay_reset_cnt <= "0101";
            when "0101"  => idelay_reset_cnt <= "0110";
            when "0110"  => idelay_reset_cnt <= "0111";
            when "0111"  => idelay_reset_cnt <= "1000";
            when "1000"  => idelay_reset_cnt <= "1001";
            when "1001"  => idelay_reset_cnt <= "1010";
            when "1010"  => idelay_reset_cnt <= "1011";
            when "1011"  => idelay_reset_cnt <= "1100";
            when "1100"  => idelay_reset_cnt <= "1101";
            when "1101"  => idelay_reset_cnt <= "1110";
            when others  => idelay_reset_cnt <= "1110";
                            idelayctrl_reset <= '0';
            end case;
         end if;
      end if;
   end process;

  end generate IO_YES_01;
  
  
   -----------------------------------------------------------------------------
   -- Transmitter Clock generation circuit. These circuits produce the clocks
   -- for 10/100/1000 operation.
   -- this replaces the tx_clk_gen module in the soft temac core
   -- Generate TX_MAC_ACLK_INT.
   -- At 1000Mb/s we select GTX_CLK (CLK) to provide this. At 10/100 we use
   -- the MII interface clock (MII_TX_CLK) sourced by the PHY.
  ------------------------------------------------------------------------------
  
    BUFGMUX_SPEED_CLK : BUFGMUX
    port map (
      O                => tx_mac_aclk_int,
      I0               => gtx_clk,
      I1               => mii_tx_clk,
      S                => speedis10100
   );

      gmii_rx_clk_in <= GMII_RX_CLK;

   -----------------------------------------------------------------------------
   -- Clock Enable circuitry
   -----------------------------------------------------------------------------
  -- clock enable generation not needed in hard temac like it is in soft temac

   -----------------------------------------------------------------------------
   -- Instantiate GMII Interface
   -----------------------------------------------------------------------------

   -- Instantiate the GMII physical interface logic
   gmii_interface : entity axi_ethernet_v3_01_a.gmii_if
    generic map(
      C_INCLUDE_IO => C_INCLUDE_IO,
      C_HALFDUP    => C_HALFDUP
      )
   port map (
      -- Synchronous resets
      tx_reset          => tx_reset_int,
      rx_reset          => rx_reset_int,

      -- Current operating speed is 10/100
      speed_is_10_100   => speedis10100,

      -- The following ports are the GMII physical interface: these will be at
      -- pins on the FPGA
       gmii_txd          => GMII_TXD,        -- out
       gmii_tx_en        => GMII_TX_EN,      -- out
       gmii_tx_er        => GMII_TX_ER,      -- out
       gmii_tx_clk       => GMII_TX_CLK,     -- out
       gmii_col          => GMII_COL,        -- in
       gmii_crs          => GMII_CRS,        -- in
       gmii_rxd          => GMII_RXD,        -- in
       gmii_rx_dv        => GMII_RX_DV,      -- in
       gmii_rx_er        => GMII_RX_ER,      -- in
       gmii_rx_clk       => gmii_rx_clk_in,     -- in

      -- The following ports are the internal GMII connections from IOB logic
      -- to the TEMAC core
       txd_from_mac      => gmii_txd_int,    -- in
       tx_en_from_mac    => gmii_tx_en_int,  -- in
       tx_er_from_mac    => gmii_tx_er_int,  -- in
       tx_clk            => tx_mac_aclk_int, -- in
       col_to_mac        => gmii_col_int,    -- out
       crs_to_mac        => gmii_crs_int,    -- out
       rxd_to_mac        => gmii_rxd_int,    -- out
       rx_dv_to_mac      => gmii_rx_dv_int,  -- out
       rx_er_to_mac      => gmii_rx_er_int,  -- out

      -- Receiver clock for the MAC and Client Logic
      rx_clk            => rx_mac_aclk_int --out
   );


   vector_decode_inst : entity axi_ethernet_v3_01_a.vector_decode
    generic map (
      C_HALFDUP    => C_HALF_DUPLEX_INT,
      C_NUM_STATS  => C_NUM_STATS
      )
   port map (
      -- Transmitter Statistic Vector inputs from ethernet MAC
      tx_clk               => tx_mac_aclk_int,
      tx_reset             => tx_reset_int,
      tx_statistics_vector => tx_statistics_vector_int,
      tx_statistics_valid  => tx_statistics_valid_int,

      -- Receiver Statistic Vector inputs from ethernet MAC
      rx_clk               => rx_mac_aclk_int,
      rx_reset             => rx_reset_int,
      rx_statistics_vector => rx_statistics_vector_int,
      rx_statistics_valid  => rx_statistics_valid_int,

      -- Increment update signals for Statistic Counters 4 upwards
      increment_vector     => increment_vector
   );


   rx_statistics_vector <= rx_statistics_vector_int;
   rx_statistics_valid  <= rx_statistics_valid_int;
   tx_statistics_vector <= tx_statistics_vector_int;
   tx_statistics_valid  <= tx_statistics_valid_int;




   -----------------------------------------------------------------------------
   -- Instantiate the V6 Hard Mac core
   -----------------------------------------------------------------------------
    v6emac_core : entity axi_ethernet_v3_01_a.v6_emac_v2_2
    generic map (
      C_EMAC_PAUSEADDR            => C_EMAC_PAUSEADDR,    
      C_EMAC_UNICASTADDR          => C_EMAC_UNICASTADDR,  
      C_EMAC_LINKTIMERVAL         => C_EMAC_LINKTIMERVAL, 
      C_HAS_MII                   => C_HAS_MII,  
      C_HAS_GMII                  => C_HAS_GMII, 
      C_HAS_RGMII_V1_3            => FALSE,
      C_HAS_RGMII_V2_0            => C_HAS_RGMII,
      C_HAS_SGMII                 => C_HAS_SGMII,
      C_HAS_GPCS                  => C_HAS_GPCS,
      C_TRI_SPEED                 => C_TRI_SPEED,
      C_SPEED_10                  => false,
      C_SPEED_100                 => false,
      C_SPEED_1000                => C_SPEED_1000,
      C_HAS_HOST                  => C_HAS_HOST,
      C_HAS_DCR                   => false,
      C_HAS_MDIO                  => true,
      C_CLIENT_16                 => false,
      C_OVERCLOCKING_RATE_2000MBPS=> false,
      C_OVERCLOCKING_RATE_2500MBPS=> false,
      C_HAS_CLOCK_ENABLE          => true,
      C_BYTE_PHY                  => false,
      C_ADD_FILTER                => C_ADD_FILTER,
      C_UNICAST_PAUSE_ADDRESS     => "AABBCCDDEEFF",
      C_PHY_RESET                 => false,
      C_PHY_AN                    => false,
      C_PHY_ISOLATE               => false,
      C_PHY_POWERDOWN             => false,
      C_PHY_LOOPBACK_MSB          => false,
      C_LT_CHECK_DIS              => false,
      C_CTRL_LENCHECK_DISABLE     => false,
      C_RX_FLOW_CONTROL           => true,
      C_TX_FLOW_CONTROL           => true,
      C_TX_RESET                  => false,
      C_TX_JUMBO                  => true,
      C_TX_FCS                    => false,
      C_TX                        => false,
      C_TX_VLAN                   => true,
      C_TX_HALF_DUPLEX            => C_HALF_DUPLEX,
      C_TX_IFG                    => true,
      C_RX_RESET                  => false,
      C_RX_JUMBO                  => true,
      C_RX_FCS                    => true,
      C_RX                        => false,
      C_RX_VLAN                   => true,
      C_RX_HALF_DUPLEX            => C_HALF_DUPLEX,
      C_DCR_BASE_ADDRESS          => x"00",
      C_LINK_TIMER_VALUE          => x"13d",
      C_PHY_GTLOOPBACK            => false,
      C_PHY_IGNORE_ADZERO         => false,
      C_PHY_UNIDIRECTION_ENABLE   => false,
      SGMII_FABRIC_BUFFER         => true,
      C_SERIAL_MODE_SWITCH_EN     => false,
      C_ADD_BUFGS                 => false,
      C_PHY_WIDTH                 => C_PHY_WIDTH,
      C_AT_ENTRIES                => C_AT_ENTRIES,   
      C_HAS_STATS                 => C_HAS_STATS,
      C_NUM_STATS                 => C_NUM_STATS,
      C_CNTR_RST                  => C_CNTR_RST,     
      C_STATS_WIDTH               => C_STATS_WIDTH,
      C_INTERNAL_INT              => C_INTERNAL_INT, -- not currently used
      C_AXI_IPIF                  => false -- not currently used
      )
   port map (
      -- Resets
      glbl_rstn              => gtx_resetn,
      rx_axi_rstn            => rx_axi_rstn,
      tx_axi_rstn            => tx_axi_rstn,

      -- Clock signals - used in rgmii and serial modes
      gtx_clk                => gtx_clk, 
      gtx_clk_div2           => '0',
      tx_axi_clk_out         => tx_axi_clk_out, -- only in rgmii or sgmii
    
      -- Receiver Interface.
      rx_axi_clk             => rx_mac_aclk_int,
      rx_reset_out           => rx_reset_int,
      rx_axis_mac_tdata      => rx_axis_mac_tdata,
      rx_axis_mac_tvalid     => rx_axis_mac_tvalid,
      rx_axis_mac_tkeep      => rx_axis_mac_tkeep_int,
      rx_axis_mac_tlast      => rx_axis_mac_tlast,
      rx_axis_mac_tuser      => rx_axis_mac_tuser,

      -- Receiver Statistics
      RX_CLK_ENABLE_OUT      => RX_CLK_ENABLE_OUT,
      rx_statistics_vector   => rx_statistics_vector_int,
      rx_statistics_valid    => rx_statistics_valid_int,
      rx_axis_filter_tuser   => rx_axis_filter_tuser,
      
      -- Transmitter Interface
      tx_axi_clk             => tx_mac_aclk_int,
      tx_reset_out           => tx_reset_int,
      tx_axis_mac_tdata      => tx_axis_mac_tdata,
      tx_axis_mac_tvalid     => tx_axis_mac_tvalid,
      tx_axis_mac_tkeep      => ("11"),
      tx_axis_mac_tlast      => tx_axis_mac_tlast,
      tx_axis_mac_tuser      => tx_axis_mac_tuser,
      tx_axis_mac_tready     => tx_axis_mac_tready,

      tx_ifg_delay           => tx_ifg_delay,

      tx_retransmit          => tx_retransmit,
      tx_collision           => tx_collision,
      -- Transmitter Statistics
      tx_statistics_vector   => tx_statistics_vector_int,
      tx_statistics_valid    => tx_statistics_valid_int,
      
      -- added for avb connection 03/21/2011     
      tx_avb_en              => tx_avb_en,      

      -- Statistics Interface
      stats_ref_clk          => gtx_clk, -- may need to be div2 in client16???
      increment_vector       => increment_vector,

      -- MAC Control Interface
      pause_req              => pause_req,
      pause_val              => pause_val,

      -- Current Speed Indication
      speed_is_10_100        => speedis10100,

      -- Physical Interface of the core
      gmii_col               => gmii_col_int,
      gmii_crs               => gmii_crs_int,
      gmii_txd               => gmii_txd_int,
      gmii_tx_en             => gmii_tx_en_int,
      gmii_tx_er             => gmii_tx_er_int,
      gmii_rxd               => gmii_rxd_int,
      gmii_rx_dv             => gmii_rx_dv_int,
      gmii_rx_er             => gmii_rx_er_int,

      -- SGMII interface 1000BASE-X PCS/PMA interface
      --------------------------------
      dcm_locked             => '0',
      signal_det             => '0',
      phy_ad                 => (others => '0'),
      rx_clk_cor_cnt         => (others => '0'),
      rx_buf_status          => '0',
      rx_char_is_comma       => '0',
      rx_char_is_k           => '0',
      rx_disp_err            => '0',
      rx_not_in_table        => '0',
      rx_run_disp            => '0',
      tx_buf_err             => '0',

      -- MDIO Interface
      mdc_out                => mdc,
      mdc_in                 => '0', 
      mdio_in                => mdio_i,
      mdio_out               => mdio_o,
      mdio_tri               => mdio_t,

      -- IPIC Interface
      bus2ip_clk             => bus2ip_clk,  
      bus2ip_reset           => bus2ip_reset,
      bus2ip_addr            => bus2ip_addr, 
      bus2ip_cs              => bus2ip_cs,   
      bus2ip_rdce            => bus2ip_rdce, 
      bus2ip_wrce            => bus2ip_wrce, 
      bus2ip_data            => bus2ip_data, 
      ip2bus_data            => ip2bus_data, 
      ip2bus_wrack           => ip2bus_wrack,
      ip2bus_rdack           => ip2bus_rdack,
      ip2bus_error           => ip2bus_error,

      mac_irq                => mac_irq,

      --unicast_address        => unicast_address,
      base_x_switch          => '0'

      );


end wrapper;
