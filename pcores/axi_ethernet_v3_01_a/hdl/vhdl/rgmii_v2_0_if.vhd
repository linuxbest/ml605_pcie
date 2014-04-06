--------------------------------------------------------------------------------
-- File       : rgmii_v2_0_if.vhd
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
-- This is based on Coregen Wrappers from ISE O.40d (13.1)
-- Wrapper version 2.1
-------------------------------------------------------------------------------
-- Description:  This module creates a version 2.0 Reduced Gigabit Media
--               Independent Interface (RGMII v2.0) by instantiating
--               Input/Output buffers and Input/Output double data rate
--               (DDR) flip-flops as required.
--
--               This interface is used to connect the Ethernet MAC to
--               an external Ethernet PHY.
--               This module routes the rgmii_rxc from the phy chip
--               (via a bufg) onto the rx_clk line.
--               A BUFIO/BUFR combination is used for the input clock to allow
--               the use of IODELAYs on the DATA.
--------------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- The entity declaration for the PHY IF design.
--------------------------------------------------------------------------------
entity rgmii_v2_0_if is
    port(
      -- Synchronous resets
      tx_reset                      : in  std_logic;
      rx_reset                      : in  std_logic;

      -- Current operating speed is 10/100
      speedis10100                  : in  std_logic;

      -- The following ports are the RGMII physical interface: these will be at
      -- pins on the FPGA
      rgmii_txd                     : out std_logic_vector(3 downto 0);
      rgmii_tx_ctl                  : out std_logic;
      rgmii_txc                     : out std_logic;
      rgmii_rxd                     : in  std_logic_vector(3 downto 0);
      rgmii_rx_ctl                  : in  std_logic;
      rgmii_rxc                     : in  std_logic;

      -- The following ports are the internal GMII connections from IOB logic
      -- to the TEMAC core
      txd_from_mac                  : in  std_logic_vector(7 downto 0);
      tx_en_from_mac                : in  std_logic;
      tx_er_from_mac                : in  std_logic;
      tx_clk                        : in  std_logic;

      rxd_to_mac                    : out std_logic_vector(7 downto 0);
      rx_dv_to_mac                  : out std_logic;
      rx_er_to_mac                  : out std_logic;

      -- Receiver clock for the MAC and Client Logic
      rx_clk                        : out std_logic
      );

end rgmii_v2_0_if;


architecture PHY_IF of rgmii_v2_0_if is


  ------------------------------------------------------------------------------
  -- internal signals
  ------------------------------------------------------------------------------
  signal not_tx_clk           : std_logic;                        -- Inverted version of tx_clk.

  signal gmii_txd_falling     : std_logic_vector(3 downto 0);     -- gmii_txd signal registered on the falling edge of tx_clk.
  signal rgmii_txc_odelay     : std_logic;                        -- RGMII receiver clock ODDR output.
  signal rgmii_tx_ctl_odelay  : std_logic;                        -- RGMII control signal ODDR output.
  signal rgmii_txd_odelay     : std_logic_vector(3 downto 0);     -- RGMII data ODDR output.
  signal rgmii_tx_ctl_int     : std_logic;                        -- Internal RGMII transmit control signal.

  signal rgmii_rxd_delay      : std_logic_vector(7 downto 0);
  signal rgmii_rx_ctl_delay   : std_logic;
  signal rgmii_rx_clk_bufio   : std_logic;

  signal rgmii_rx_ctl_reg     : std_logic;                        -- Internal RGMII receiver control signal.

  signal gmii_rx_dv_reg       : std_logic;                        -- gmii_rx_dv registered in IOBs.
  signal gmii_rx_er_reg       : std_logic;                        -- gmii_rx_er registered in IOBs.
  signal gmii_rxd_reg         : std_logic_vector(7 downto 0);     -- gmii_rxd registered in IOBs.

  signal inband_ce            : std_logic;                        -- RGMII inband status registers clock enable

  signal rx_clk_int           : std_logic;

  signal txd_rising_i         : std_logic_vector(3 downto 0);
  signal txd_falling_i        : std_logic_vector(3 downto 0);
  signal tx_ctl_rising_i      : std_logic;
  signal tx_ctl_falling_i     : std_logic;

begin


   -----------------------------------------------------------------------------
   -- Route internal signals to output ports :
   -----------------------------------------------------------------------------

   rxd_to_mac      <= gmii_rxd_reg;
   rx_dv_to_mac    <= gmii_rx_dv_reg;
   rx_er_to_mac    <= rgmii_rx_ctl_reg;


   -----------------------------------------------------------------------------
   -- RGMII Transmitter Clock Management :
   -----------------------------------------------------------------------------

   -- Delay the transmitter clock relative to the data.
   -- For 1 gig operation this delay is set to produce a 90 degree phase
   -- shifted clock w.r.t. gtx_clk_bufg so that the clock edges are
   -- centralised within the rgmii_txd[3:0] valid window.

   -- Instantiate the Output DDR primitive
   rgmii_txc_ddr : ODDR
   generic map (
      DDR_CLK_EDGE      => "SAME_EDGE"
   )
    port map (
       Q             => rgmii_txc_odelay,
       C             => tx_clk,
       CE            => '1',
       D1            => '1',
       D2            => '0',
       R             => tx_reset,
       S             => '0'
    );


   -- Instantiate the Output Delay primitive (delay output by 2 ns)
   delay_rgmii_tx_clk : IODELAYE1
   generic map (
      ODELAY_VALUE   => 12,
      DELAY_SRC      => "O"
   )
   port map (
      IDATAIN        => '0',
      ODATAIN        => rgmii_txc_odelay,
      DATAOUT        => rgmii_txc,
      DATAIN         => '0',
      C              => '0',
      T              => '0',
      CE             => '0',
      INC            => '0',
      CINVCTRL       => '0',
      CLKIN          => '0',
      CNTVALUEIN     => "00000",
      RST            => '0'
   );


   -----------------------------------------------------------------------------
   -- RGMII Transmitter Logic :
   -- drive TX signals through IOBs onto RGMII interface
   -----------------------------------------------------------------------------

   rising_p : process(tx_clk)
   begin
      if tx_clk'event and tx_clk = '1' then
         if tx_reset = '1' then
            txd_rising_i    <= X"0";
            tx_ctl_rising_i <= '0';
         else
            txd_rising_i    <= txd_from_mac(3 downto 0);
            tx_ctl_rising_i <= tx_en_from_mac;
         end if;
      end if;
   end process rising_p;

   falling_p : process(tx_clk)
   begin
      if tx_clk'event and tx_clk = '0' then
         if tx_reset = '1' then
            txd_falling_i    <= X"0";
            tx_ctl_falling_i <= '0';
         else
            txd_falling_i    <= txd_from_mac(7 downto 4);
            tx_ctl_falling_i <= tx_er_from_mac;
         end if;
      end if;
   end process falling_p;

   txdata_out_bus: for I in 3 downto 0 generate
   -- DDR_CLK_EDGE attribute specifies expected input data alignment to ODDR.
   begin
      rgmii_txd_out : ODDR
      port map (
         Q              => rgmii_txd_odelay(I),
         C              => tx_clk,
         CE             => '1',
         D1             => txd_rising_i(I),
         D2             => txd_falling_i(I),
         R              => tx_reset,
         S              => '0'
      );

      delay_rgmii_txd : IODELAYE1
      generic map (
         ODELAY_VALUE   => 0,
         DELAY_SRC      => "O"
      )
      port map (
         IDATAIN        => '0',
         ODATAIN        => rgmii_txd_odelay(I),
         DATAOUT        => rgmii_txd(I),
         DATAIN         => '0',
         C              => '0',
         T              => '0',
         CE             => '0',
         INC            => '0',
         CINVCTRL       => '0',
         CLKIN          => '0',
         CNTVALUEIN     => "00000",
         RST            => '0'
      );
   end generate;

   rgmii_tx_ctl_out : ODDR
   port map (
      Q                 => rgmii_tx_ctl_odelay,
      C                 => tx_clk,
      CE                => '1',
      D1                => tx_ctl_rising_i,
      D2                => tx_ctl_falling_i,
      R                 => tx_reset,
      S                 => '0'
   );

   delay_rgmii_tx_ctl : IODELAYE1
   generic map (
      ODELAY_VALUE      => 0,
      DELAY_SRC         => "O"
   )
   port map (
      IDATAIN           => '0',
      ODATAIN           => rgmii_tx_ctl_odelay,
      DATAOUT           => rgmii_tx_ctl,
      DATAIN            => '0',
      C                 => '0',
      T                 => '0',
      CE                => '0',
      INC               => '0',
      CINVCTRL       => '0',
      CLKIN          => '0',
      CNTVALUEIN     => "00000",
      RST               => '0'
   );


   -----------------------------------------------------------------------------
   -- RGMII Receiver Clock Logic
   -----------------------------------------------------------------------------

   -- Route rgmii_rxc through a BUFIO/BUFR and onto regional clock routing
   bufio_rgmii_rx_clk  : BUFIO
   port map (
      I              => rgmii_rxc,
      O              => rgmii_rx_clk_bufio
   );

   -- Route rx_clk through a BUFR onto regional clock routing
   bufr_rgmii_rx_clk : BUFR
   port map  (
      I              => rgmii_rxc,
      CE             => '1',
      CLR            => '0',
      O              => rx_clk_int
   );


   -- Assign the internal clock signal to the output port
   rx_clk <= rx_clk_int;


   -----------------------------------------------------------------------------
   -- RGMII Receiver Logic : receive signals through IOBs from RGMII interface
   -----------------------------------------------------------------------------


   -- Drive input RGMII Rx signals from PADS through IODELAYS.

   -- Please modify the IODELAY_VALUE according to your design.
   -- For more information on IDELAYCTRL and IODELAY, please refer to
   -- the User Guide.
   delay_rgmii_rx_ctl : IODELAYE1
   generic map (
      IDELAY_TYPE    => "FIXED",
      DELAY_SRC      => "I"
   )
   port map (
      IDATAIN        => rgmii_rx_ctl,
      ODATAIN        => '0',
      DATAOUT        => rgmii_rx_ctl_delay,
      DATAIN         => '0',
      C              => '0',
      T              => '1',
      CE             => '0',
      INC            => '0',
      CINVCTRL       => '0',
      CLKIN          => '0',
      CNTVALUEIN     => "00000",
      RST            => '0'
   );

   rxdata_bus: for I in 3 downto 0 generate
      delay_rgmii_rxd : IODELAYE1
      generic map (
         IDELAY_TYPE    => "FIXED",
         DELAY_SRC      => "I"
      )
      port map (
         IDATAIN        => rgmii_rxd(I),
         ODATAIN        => '0',
         DATAOUT        => rgmii_rxd_delay(I),
         DATAIN         => '0',
         C              => '0',
         T              => '1',
         CE             => '0',
         INC            => '0',
         CINVCTRL       => '0',
         CLKIN          => '0',
         CNTVALUEIN     => "00000",
         RST            => '0'
      );

   end generate;

   -- Instantiate Double Data Rate Input flip-flops.
   rxdata_in_bus: for I in 3 downto 0 generate
   -- DDR_CLK_EDGE attribute specifies output data alignment from IDDR component
   begin
      rgmii_rx_data_in : IDDR
      port map (
         Q1             => gmii_rxd_reg(I),
         Q2             => gmii_rxd_reg(I+4),
         C              => rgmii_rx_clk_bufio,
         CE             => '1',
         D              => rgmii_rxd_delay(I),
         R              => '0',
         S              => '0'
      );
   end generate;


   rgmii_rx_ctl_in : IDDR
   port map (
      Q1                => gmii_rx_dv_reg,
      Q2                => rgmii_rx_ctl_reg,
      C                 => rgmii_rx_clk_bufio,
      CE                => '1',
      D                 => rgmii_rx_ctl_delay,
      R                 => '0',
      S                 => '0'
   );


end PHY_IF;
