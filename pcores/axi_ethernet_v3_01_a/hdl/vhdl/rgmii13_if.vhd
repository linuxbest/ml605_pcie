------------------------------------------------------------------------
-- Title      : Reduced Gigabit Media Independent Interface (RGMII) v1.3
-- Project    : Virtex-6 Ethernet MAC Wrappers
------------------------------------------------------------------------
-- File       : rgmii13_if.vhd
------------------------------------------------------------------------
--
-- (c) Copyright 2009-2010 Xilinx, Inc. All rights reserved.
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
------------------------------------------------------------------------
-- Description:  This module creates a version 1.3 Reduced Gigabit Media
--               Independent Interface (RGMII v1.3) by instantiating
--               Input/Output buffers and Input/Output double data rate
--               (DDR) flip-flops as required.
--
--               This interface is used to connect the Ethernet MAC to
--               an external 1000Mb/s (or Tri-speed) Ethernet PHY.
--
--               This is based on Coregen Wrappers from ISE M (12.1i)
--               Wrapper version 1.4
------------------------------------------------------------------------

library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;

------------------------------------------------------------------------------
-- Entity declaration for the physical interface
------------------------------------------------------------------------------
entity rgmii13_if is
  generic (
           C_INCLUDE_IO               : integer          := 1
          );
   port(
      RESET                    : in  std_logic;
      -- RGMII Interface
      RGMII_TXD                : out std_logic_vector(3 downto 0);
      RGMII_TX_CTL             : out std_logic;
      RGMII_TXC                : out std_logic;
      RGMII_RXD                : in  std_logic_vector(3 downto 0);
      RGMII_RX_CTL             : in  std_logic;
      -- MAC Interface
      TXD_RISING_FROM_MAC      : in  std_logic_vector(3 downto 0);
      TXD_FALLING_FROM_MAC     : in  std_logic_vector(3 downto 0);
      TX_CTL_RISING_FROM_MAC   : in  std_logic;
      TX_CTL_FALLING_FROM_MAC  : in  std_logic;
      TX_CLK                   : in  std_logic;
      RXD_RISING_TO_MAC        : out std_logic_vector(3 downto 0);
      RXD_FALLING_TO_MAC       : out std_logic_vector(3 downto 0);
      RX_CTL_RISING_TO_MAC     : out std_logic;
      RX_CTL_FALLING_TO_MAC    : out std_logic;
      RX_CLK                   : in  std_logic
  );
end rgmii13_if;

architecture PHY_IF of rgmii13_if is

  signal vcc_i            : std_logic;
  signal gnd_i            : std_logic;

  signal txd_rising_i     : std_logic_vector(3 downto 0);
  signal txd_falling_i    : std_logic_vector(3 downto 0);
  signal tx_ctl_rising_i  : std_logic;
  signal tx_ctl_falling_i : std_logic;

  signal rgmii_rxd_delay  : std_logic_vector(3 downto 0);
  signal rgmii_ctl_delay  : std_logic;


begin

    gnd_i <= '0';
    vcc_i <= '1';

    --------------------------------------------------------------------------
    -- RGMII Transmitter Clock Management
    --------------------------------------------------------------------------
    -- Instantiate a DDR output register.  This is a good way to drive
    -- RGMII_TXC since the clock-to-PAD delay will be the same as that for
    -- data driven from IOB Ouput flip-flops, eg. RGMII_TXD[3:0].
    rgmii_txc_oddr : ODDR
    generic map (SRTYPE => "ASYNC")
    port map(
       Q => RGMII_TXC,
       C => TX_CLK,
       CE => vcc_i,
       D1 => vcc_i,
       D2 => gnd_i,
       R => RESET,
       S => gnd_i
    );

    regrgmiirtx : process(TX_CLK, RESET)
    begin
      if RESET = '1' then
        txd_rising_i    <= (others => '0');
        tx_ctl_rising_i <= '0';
      elsif TX_CLK'event and TX_CLK = '1' then
        txd_rising_i    <= TXD_RISING_FROM_MAC;
        tx_ctl_rising_i <= TX_CTL_RISING_FROM_MAC;
      end if;
    end process regrgmiirtx;

    regrgmiiftx : process(TX_CLK, RESET)
    begin
      if RESET = '1' then
        txd_falling_i    <= (others => '0');
        tx_ctl_falling_i <= '0';
      elsif TX_CLK'event and TX_CLK = '0' then
        txd_falling_i    <= TXD_FALLING_FROM_MAC;
        tx_ctl_falling_i <= TX_CTL_FALLING_FROM_MAC;
      end if;
    end process regrgmiiftx;

    --------------------------------------------------------------------------
    -- RGMII Transmitter Logic
    --------------------------------------------------------------------------
    -- Use DDR Flip-Flops to clock the TX data on both the positive edge and
    -- negative edge which is then transmitted to the PHY
    rgmii_tx_ctl_oddr : ODDR
    generic map (SRTYPE => "ASYNC")
    port map (
       Q  => RGMII_TX_CTL,
       C  => TX_CLK,
       CE => vcc_i,
       D1 => tx_ctl_rising_i,
       D2 => tx_ctl_falling_i,
       R  => RESET,
       S  => gnd_i
    );

    rgmii_txd_ddr_regs : for I in 0 to 3 generate
       rgmii_txd_oddr : ODDR
       generic map (SRTYPE => "ASYNC")
       port map (
          Q  => RGMII_TXD(I),
          C  => TX_CLK,
          CE => vcc_i,
          D1 => txd_rising_i(I),
          D2 => txd_falling_i(I),
          R  => RESET,
          S  => gnd_i
       );
    end generate rgmii_txd_ddr_regs;

    --------------------------------------------------------------------------
    -- RGMII Receiver Logic
    --------------------------------------------------------------------------
    -- Use IODELAY blocks with IDELAY function to align the data to the clock.
    -- The IODELAY is configured in Fixed Tap Delay Mode. IDELAYCTRL primitives
    -- need to be instantiated for the Fixed Tap Delay mode of the IODELAY.

    -- Please modify the value of the IODELAYs according to your design.
    -- For more information on IDELAYCTRL and IODELAY, please refer to the
    -- Virtex-6 User Guide.

    rgmii_rx_ctl_delay : IODELAY
    generic map (
      IDELAY_TYPE           => "FIXED",
      IDELAY_VALUE          => 0,
      HIGH_PERFORMANCE_MODE => TRUE
    )
    port map (
      IDATAIN => RGMII_RX_CTL,
      DATAOUT => rgmii_ctl_delay,
      DATAIN  => gnd_i,
      ODATAIN => gnd_i,
      C       => gnd_i,
      CE      => gnd_i,
      INC     => gnd_i,
      T       => gnd_i,
      RST     => gnd_i
    );

    rgmii_rx_d0_delay : IODELAY
    generic map (
      IDELAY_TYPE           => "FIXED",
      IDELAY_VALUE          => 0,
      HIGH_PERFORMANCE_MODE => TRUE
    )
    port map (
      IDATAIN => RGMII_RXD(0),
      DATAOUT => rgmii_rxd_delay(0),
      DATAIN  => gnd_i,
      ODATAIN => gnd_i,
      C       => gnd_i,
      CE      => gnd_i,
      INC     => gnd_i,
      T       => gnd_i,
      RST     => gnd_i
    );

    rgmii_rx_d1_delay : IODELAY
    generic map (
      IDELAY_TYPE           => "FIXED",
      IDELAY_VALUE          => 0,
      HIGH_PERFORMANCE_MODE => TRUE
    )
    port map (
      IDATAIN => RGMII_RXD(1),
      DATAOUT => rgmii_rxd_delay(1),
      DATAIN  => gnd_i,
      ODATAIN => gnd_i,
      C       => gnd_i,
      CE      => gnd_i,
      INC     => gnd_i,
      T       => gnd_i,
      RST     => gnd_i
    );

    rgmii_rx_d2_delay : IODELAY
    generic map (
      IDELAY_TYPE           => "FIXED",
      IDELAY_VALUE          => 0,
      HIGH_PERFORMANCE_MODE => TRUE
    )
    port map (
      IDATAIN => RGMII_RXD(2),
      DATAOUT => rgmii_rxd_delay(2),
      DATAIN  => gnd_i,
      ODATAIN => gnd_i,
      C       => gnd_i,
      CE      => gnd_i,
      INC     => gnd_i,
      T       => gnd_i,
      RST     => gnd_i
    );

    rgmii_rx_d3_delay : IODELAY
    generic map (
      IDELAY_TYPE           => "FIXED",
      IDELAY_VALUE          => 0,
      HIGH_PERFORMANCE_MODE => TRUE
    )
    port map (
      IDATAIN => RGMII_RXD(3),
      DATAOUT => rgmii_rxd_delay(3),
      DATAIN  => gnd_i,
      ODATAIN => gnd_i,
      C       => gnd_i,
      CE      => gnd_i,
      INC     => gnd_i,
      T       => gnd_i,
      RST     => gnd_i
    );

    -------------------------------------------------------------------------
    -- Use DDR flip-flops to clock the RX data from the
    -- PHY on both the positive edge and negative edge
    --------------------------------------------------------------------------
    rgmii_rx_ctl_iddr : IDDR
    port map (
       Q1 => RX_CTL_RISING_TO_MAC,
       Q2 => RX_CTL_FALLING_TO_MAC,
       C  => RX_CLK,
       CE => vcc_i,
       D  => rgmii_ctl_delay,
       R  => gnd_i,
       S  => gnd_i
    );

    rgmii_rxd_ddr_regs : for I in 0 to 3 generate
       rgmii_rxd_iddr : IDDR
       port map (
          Q1 => RXD_RISING_TO_MAC(I),
          Q2 => RXD_FALLING_TO_MAC(I),
          C  => RX_CLK,
          CE => vcc_i,
          D  => rgmii_rxd_delay(I),
          R  => gnd_i,
          S  => gnd_i
       );
    end generate rgmii_rxd_ddr_regs;

end PHY_IF;
