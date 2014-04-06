-------------------------------------------------------------------------------
-- Title      : Top-level GTX wrapper for Ethernet MAC
-- File       : v6_gtxwizard_top_sgmii.vhd
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
-- This is based on Coregen Wrappers from ISE O.40d (13.1)
-- Wrapper version 2.1
------------------------------------------------------------------------
-- Description:  This is the top-level GTX wrapper. It
--               instantiates the lower-level wrappers produced by
--               the Virtex-6 FPGA GTX Wrapper Wizard.
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

library unisim;
use unisim.vcomponents.all;


entity v6_gtxwizard_top_sgmii is
   port (
      RESETDONE           : out   std_logic;
      ENMCOMMAALIGN       : in    std_logic;
      ENPCOMMAALIGN       : in    std_logic;
      LOOPBACK            : in    std_logic;
      POWERDOWN           : in    std_logic;
      RXUSRCLK2           : in    std_logic;
      RXRESET             : in    std_logic;
      TXCHARDISPMODE      : in    std_logic;
      TXCHARDISPVAL       : in    std_logic;
      TXCHARISK           : in    std_logic;
      TXDATA              : in    std_logic_vector (7 downto 0);
      TXUSRCLK2           : in    std_logic;
      TXRESET             : in    std_logic;
      RXCHARISCOMMA       : out   std_logic;
      RXCHARISK           : out   std_logic;
      RXCLKCORCNT         : out   std_logic_vector (2 downto 0);
      RXDATA              : out   std_logic_vector (7 downto 0);
      RXDISPERR           : out   std_logic;
      RXNOTINTABLE        : out   std_logic;
      RXRUNDISP           : out   std_logic;
      RXBUFERR            : out   std_logic;
      TXBUFERR            : out   std_logic;
      PLLLKDET            : out   std_logic;
      TXOUTCLK            : out   std_logic;
      RXELECIDLE          : out   std_logic;
      TXN                 : out   std_logic;
      TXP                 : out   std_logic;
      RXN                 : in    std_logic;
      RXP                 : in    std_logic;
      CLK_DS              : in    std_logic;
      PMARESET            : in    std_logic
   );
end v6_gtxwizard_top_sgmii;


architecture wrapper of v6_gtxwizard_top_sgmii is

  component axi_ethernet_v3_01_a_sync_block
  port (
     clk                        : in  std_logic;
     data_in                    : in  std_logic;
     data_out                   : out std_logic
  );
  end component;

  component reset_sync
  port (
     reset_in                   : in  std_logic;
     enable                     : in  std_logic;
     clk                        : in  std_logic;
     reset_out                  : out std_logic
  );
  end component;


  component rx_elastic_buffer
   port (
      -- Signals received from the GTX on RXRECCLK.
      rxrecclk                  : in  std_logic;
      rxrecreset                : in  std_logic;
      rxchariscomma_rec         : in  std_logic_vector(1 downto 0);
      rxcharisk_rec             : in  std_logic_vector(1 downto 0);
      rxdisperr_rec             : in  std_logic_vector(1 downto 0);
      rxnotintable_rec          : in  std_logic_vector(1 downto 0);
      rxrundisp_rec             : in  std_logic_vector(1 downto 0);
      rxdata_rec                : in  std_logic_vector(15 downto 0);

      -- Signals reclocked onto RXUSRCLK2.
      rxusrclk2                 : in  std_logic;
      rxreset                   : in  std_logic;
      rxchariscomma_usr         : out std_logic;
      rxcharisk_usr             : out std_logic;
      rxdisperr_usr             : out std_logic;
      rxnotintable_usr          : out std_logic;
      rxrundisp_usr             : out std_logic;
      rxclkcorcnt_usr           : out std_logic_vector(2 downto 0);
      rxbuferr                  : out std_logic;
      rxdata_usr                : out std_logic_vector(7 downto 0)
   );
  end component;

  component V6_GTXWIZARD_sgmii
  generic
  (
    -- Simulation attributes
    WRAPPER_SIM_GTXRESET_SPEEDUP : integer := 1
  );
  port
  (

    GTX0_DOUBLE_RESET_CLK_IN         : in   std_logic;
    ------------------------ Loopback and Powerdown Ports ----------------------
    GTX0_LOOPBACK_IN                 : in   std_logic_vector(2 downto 0);
    GTX0_RXPOWERDOWN_IN              : in   std_logic_vector(1 downto 0);
    GTX0_TXPOWERDOWN_IN              : in   std_logic_vector(1 downto 0);
    ----------------------- Receive Ports - 8b10b Decoder ----------------------
    GTX0_RXCHARISCOMMA_OUT           : out  std_logic_vector(1 downto 0);
    GTX0_RXCHARISK_OUT               : out  std_logic_vector(1 downto 0);
    GTX0_RXDISPERR_OUT               : out  std_logic_vector(1 downto 0);
    GTX0_RXNOTINTABLE_OUT            : out  std_logic_vector(1 downto 0);
    GTX0_RXRUNDISP_OUT               : out  std_logic_vector(1 downto 0);
    ------------------- Receive Ports - Clock Correction Ports -----------------
    GTX0_RXCLKCORCNT_OUT             : out  std_logic_vector(2 downto 0);
    --------------- Receive Ports - Comma Detection and Alignment --------------
    GTX0_RXENMCOMMAALIGN_IN          : in   std_logic;
    GTX0_RXENPCOMMAALIGN_IN          : in   std_logic;
    ------------------- Receive Ports - RX Data Path interface -----------------
    GTX0_RXDATA_OUT                  : out  std_logic_vector(15 downto 0);
    GTX0_RXRECCLK_OUT                : out  std_logic;
    GTX0_RXRESET_IN                  : in   std_logic;
    GTX0_RXUSRCLK2_IN                : in   std_logic;
    -------- Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    GTX0_RXBUFRESET_IN               : in   std_logic;
    GTX0_RXBUFSTATUS_OUT             : out  std_logic_vector(2 downto 0);
    ------- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    GTX0_RXELECIDLE_OUT              : out  std_logic;
    GTX0_RXN_IN                      : in   std_logic;
    GTX0_RXP_IN                      : in   std_logic;
    ------------------------ Receive Ports - RX PLL Ports ----------------------
    GTX0_GTXRXRESET_IN               : in   std_logic;
    GTX0_MGTREFCLKRX_IN              : in   std_logic;
    GTX0_PLLRXRESET_IN               : in   std_logic;
    GTX0_RXPLLLKDET_OUT              : out  std_logic;
    GTX0_RXRESETDONE_OUT             : out  std_logic;
    ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    GTX0_TXCHARDISPMODE_IN           : in   std_logic;
    GTX0_TXCHARDISPVAL_IN            : in   std_logic;
    GTX0_TXCHARISK_IN                : in   std_logic;
    ------------------------- Transmit Ports - GTX Ports -----------------------
    GTX0_GTXTEST_IN                  : in   std_logic_vector(12 downto 0);
    ------------------ Transmit Ports - TX Data Path interface -----------------
    GTX0_TXDATA_IN                   : in   std_logic_vector(7 downto 0);
    GTX0_TXOUTCLK_OUT                : out  std_logic;
    GTX0_TXRESET_IN                  : in   std_logic;
    GTX0_TXUSRCLK2_IN                : in   std_logic;
    --------------- Transmit Ports - TX Driver and OOB signalling --------------
    GTX0_TXN_OUT                     : out  std_logic;
    GTX0_TXP_OUT                     : out  std_logic;
    ------------- Transmit Ports - TX Buffering and Phase Alignment ------------
    GTX0_TXBUFSTATUS_OUT             : out  std_logic_vector(1 downto 0);
    ----------------------- Transmit Ports - TX PLL Ports ----------------------
    GTX0_GTXTXRESET_IN               : in   std_logic;
    GTX0_TXRESETDONE_OUT             : out  std_logic

  );
  end component;

  ----------------------------------------------------------------------
  -- Signal declarations for GTX
  ----------------------------------------------------------------------

   signal GND_BUS           : std_logic_vector (55 downto 0);

   signal RXBUFSTATUS_float : std_logic_vector(1 downto 0);
   signal TXBUFSTATUS_float : std_logic;

   signal RXRECCLK          : std_logic;
   signal RXRECCLK_BUFR     : std_logic;
   signal RXCHARISCOMMA_REC : std_logic_vector(1 downto 0);
   signal RXNOTINTABLE_REC  : std_logic_vector(1 downto 0);
   signal RXCHARISK_REC     : std_logic_vector(1 downto 0);
   signal RXDISPERR_REC     : std_logic_vector(1 downto 0);
   signal RXRUNDISP_REC     : std_logic_vector(1 downto 0);
   signal RXDATA_REC        : std_logic_vector(15 downto 0);

   signal RXRESET_REC       : std_logic;
   signal RXBUFRESET_REC    : std_logic;
   signal RXRESET_USR       : std_logic;
   signal ENPCOMMAALIGN_REG : std_logic;
   signal ENPCOMMAALIGN_REC : std_logic;
   signal ENMCOMMAALIGN_REG : std_logic;
   signal ENMCOMMAALIGN_REC : std_logic;
   signal RXBUFERR_REC      : std_logic;
   signal RXBUFERR_INT      : std_logic;

   attribute KEEP                           : boolean;
   attribute KEEP of RXRECCLK               : signal is TRUE;
   attribute ASYNC_REG                      : string;
   attribute ASYNC_REG of ENPCOMMAALIGN_REG : signal is "TRUE";
   attribute ASYNC_REG of ENMCOMMAALIGN_REG : signal is "TRUE";

   signal rxbuf_reset_i : std_logic;
   signal clk_ds_i      : std_logic;
   signal pma_reset_i   : std_logic;
   signal reset_r       : std_logic_vector(3 downto 0);

   attribute SHREG_EXTRACT            : string;
   attribute SHREG_EXTRACT of reset_r : signal is "NO";
   attribute ASYNC_REG of reset_r : signal is "TRUE";

   signal resetdone_tx_i : std_logic;
   signal resetdone_tx_int : std_logic;
   signal resetdone_tx_r : std_logic;
   signal resetdone_rx_i : std_logic;
   signal resetdone_rx_int : std_logic;
   signal resetdone_rx_r : std_logic;
   signal resetdone_i    : std_logic;

begin

   GND_BUS(55 downto 0) <= (others => '0');

   --------------------------------------------------------------------
   -- GTX PMA reset circuitry
   --------------------------------------------------------------------

   -- Locally buffer the output of the IBUFDS_GTXE1 for reset logic
   bufr_clk_ds : BUFR port map (
     I   => CLK_DS,
     O   => clk_ds_i,
     CE  => '1',
     CLR => '0'
   );

   process(PMARESET, clk_ds_i)
   begin
     if (PMARESET = '1') then
       reset_r <= "1111";
     elsif clk_ds_i'event and clk_ds_i = '1' then
       reset_r <= reset_r(2 downto 0) & '0';
     end if;
   end process;

   pma_reset_i <= reset_r(3);

   ----------------------------------------------------------------------
   -- Instantiate the Virtex-6 GTX
   ----------------------------------------------------------------------

   -- Direct from the GTX Wizard output
    v6_gtxwizard_inst : V6_GTXWIZARD_sgmii
    generic map (
        WRAPPER_SIM_GTXRESET_SPEEDUP     => 1
    )
    port map (
        GTX0_DOUBLE_RESET_CLK_IN         => clk_ds_i,
        ---------------------- Loopback and Powerdown Ports ----------------------
        GTX0_LOOPBACK_IN(2 downto 1)     => "00",
        GTX0_LOOPBACK_IN(0)              => LOOPBACK,
        GTX0_RXPOWERDOWN_IN(0)           => POWERDOWN,
        GTX0_RXPOWERDOWN_IN(1)           => POWERDOWN,
        GTX0_TXPOWERDOWN_IN(0)           => POWERDOWN,
        GTX0_TXPOWERDOWN_IN(1)           => POWERDOWN,
        --------------------- Receive Ports - 8b10b Decoder ----------------------
        GTX0_RXCHARISCOMMA_OUT           => RXCHARISCOMMA_REC,
        GTX0_RXCHARISK_OUT               => RXCHARISK_REC,
        GTX0_RXDISPERR_OUT               => RXDISPERR_REC,
        GTX0_RXNOTINTABLE_OUT            => RXNOTINTABLE_REC,
        GTX0_RXRUNDISP_OUT               => RXRUNDISP_REC,
        ----------------- Receive Ports - Clock Correction Ports -----------------
        GTX0_RXCLKCORCNT_OUT             => open,
        ------------- Receive Ports - Comma Detection and Alignment --------------
        GTX0_RXENMCOMMAALIGN_IN          => ENMCOMMAALIGN_REC,
        GTX0_RXENPCOMMAALIGN_IN          => ENPCOMMAALIGN_REC,
        ----------------- Receive Ports - RX Data Path interface -----------------
        GTX0_RXDATA_OUT                  => RXDATA_REC,
        GTX0_RXRECCLK_OUT                => RXRECCLK,
        GTX0_RXRESET_IN                  => RXRESET_REC,
        GTX0_RXUSRCLK2_IN                => RXRECCLK_BUFR,
        ------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        GTX0_RXBUFRESET_IN               => RXRESET_REC,
        GTX0_RXBUFSTATUS_OUT(2)          => RXBUFERR_REC,
        GTX0_RXBUFSTATUS_OUT(1 downto 0) => RXBUFSTATUS_float,
        ----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        GTX0_RXELECIDLE_OUT              => RXELECIDLE,
        GTX0_RXN_IN                      => RXN,
        GTX0_RXP_IN                      => RXP,
        -------------------- Receive Ports - RX PLL Ports ------------------------
        GTX0_GTXRXRESET_IN               => pma_reset_i,
        GTX0_MGTREFCLKRX_IN              => CLK_DS,
        GTX0_PLLRXRESET_IN               => pma_reset_i,
        GTX0_RXPLLLKDET_OUT              => PLLLKDET,
        GTX0_RXRESETDONE_OUT             => resetdone_rx_i,
        -------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        GTX0_TXCHARDISPMODE_IN           => TXCHARDISPMODE,
        GTX0_TXCHARDISPVAL_IN            => TXCHARDISPVAL,
        GTX0_TXCHARISK_IN                => TXCHARISK,
        ----------------------- Transmit Ports - GTX Ports -----------------------
        GTX0_GTXTEST_IN                  => "1000000000000",
        ---------------- Transmit Ports - TX Data Path interface -----------------
        GTX0_TXDATA_IN                   => TXDATA,
        GTX0_TXOUTCLK_OUT                => TXOUTCLK,
        GTX0_TXRESET_IN                  => TXRESET,
        GTX0_TXUSRCLK2_IN                => TXUSRCLK2,
        ------------- Transmit Ports - TX Driver and OOB signalling --------------
        GTX0_TXN_OUT                     => TXN,
        GTX0_TXP_OUT                     => TXP,
        ----------- Transmit Ports - TX Buffering and Phase Alignment ------------
        GTX0_TXBUFSTATUS_OUT(1)          => TXBUFERR,
        GTX0_TXBUFSTATUS_OUT(0)          => TXBUFSTATUS_float,
        -------------------- Transmit Ports - TX PLL Ports -----------------------
        GTX0_GTXTXRESET_IN               => pma_reset_i,
        GTX0_TXRESETDONE_OUT             => resetdone_tx_i
   );

   -- Register the Tx and Rx resetdone signals, and AND them to provide a
   -- single RESETDONE output
   resetdone_tx_int <= resetdone_tx_i and (not TXRESET);
   resetdone_tx_sync_block : axi_ethernet_v3_01_a_sync_block port map (
     clk      => TXUSRCLK2,
     data_in  => resetdone_tx_int,
     data_out => resetdone_tx_r
   );
   resetdone_rx_int <= resetdone_rx_i and (not RXRESET);
   resetdone_rx_sync_block : axi_ethernet_v3_01_a_sync_block port map (
     clk      => RXUSRCLK2,
     data_in  => resetdone_rx_int,
     data_out => resetdone_rx_r
   );


   resetdone_i <= resetdone_tx_r and resetdone_rx_r;
   RESETDONE   <= resetdone_i;

   -- Route RXRECLK through a regional clock buffer
   rxrecclkbufr : BUFR port map (
     I   => RXRECCLK,
     O   => RXRECCLK_BUFR,
     CE  => '1',
     CLR => '0'
   );

   -- Instantiate the RX elastic buffer. This performs clock
   -- correction on the incoming data to cope with differences
   -- between the user clock and the clock recovered from the data.
   rx_elastic_buffer_inst : rx_elastic_buffer port map (
     -- Signals from the GTX on RXRECCLK
     rxrecclk          => RXRECCLK_BUFR,
     rxrecreset        => RXBUFRESET_REC,
     rxchariscomma_rec => RXCHARISCOMMA_REC,
     rxcharisk_rec     => RXCHARISK_REC,
     rxdisperr_rec     => RXDISPERR_REC,
     rxnotintable_rec  => RXNOTINTABLE_REC,
     rxrundisp_rec     => RXRUNDISP_REC,
     rxdata_rec        => RXDATA_REC,

     -- Signals reclocked onto USRCLK2
     rxusrclk2         => RXUSRCLK2,
     rxreset           => RXRESET_USR,
     rxchariscomma_usr => RXCHARISCOMMA,
     rxcharisk_usr     => RXCHARISK,
     rxdisperr_usr     => RXDISPERR,
     rxnotintable_usr  => RXNOTINTABLE,
     rxrundisp_usr     => RXRUNDISP,
     rxclkcorcnt_usr   => RXCLKCORCNT,
     rxbuferr          => RXBUFERR_INT,
     rxdata_usr        => RXDATA
   );

  RXBUFERR <= RXBUFERR_INT or RXBUFERR_REC;

  -- Resynchronise the PMARESET onto the RXRECCLK domain
   rxreset_rec_sync : reset_sync port map (
    reset_in  => PMARESET,
    clk       => RXRECCLK_BUFR,
    enable    => '1',
    reset_out => RXRESET_REC
  );

  -- Generate a reset to the rx_elastic_buffer in the RXRECCLK domain
  rxbuf_reset_i <= PMARESET or (not resetdone_i);
  rxbufreset_rec_sync : reset_sync port map (
    reset_in  => rxbuf_reset_i,
    clk       => RXRECCLK_BUFR,
    enable    => '1',
    reset_out => RXBUFRESET_REC
  );

  -- Resynchronise the RXRESET onto the RXUSRCLK2 domain
  rxreset_usr_sync : reset_sync port map (
    reset_in  => RXRESET,
    clk       => RXUSRCLK2,
    enable    => '1',
    reset_out => RXRESET_USR
  );

  
  -- Re-align signals from the USRCLK domain into the RXRECCLK domain
  rxrecclkreclock : process (RXRECCLK_BUFR)
  begin
    if RXRECCLK_BUFR'event and RXRECCLK_BUFR = '1' then
      if RXRESET_REC = '1' then
        ENPCOMMAALIGN_REG <= '0';
        ENPCOMMAALIGN_REC <= '0';
        ENMCOMMAALIGN_REG <= '0';
        ENMCOMMAALIGN_REC <= '0';
      else
        ENPCOMMAALIGN_REG <= ENPCOMMAALIGN;
        ENPCOMMAALIGN_REC <= ENPCOMMAALIGN_REG;
        ENMCOMMAALIGN_REG <= ENMCOMMAALIGN;
        ENMCOMMAALIGN_REC <= ENMCOMMAALIGN_REG;
      end if;
    end if;
  end process rxrecclkreclock;

end wrapper;
