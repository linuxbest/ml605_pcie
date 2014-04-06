-------------------------------------------------------------------------------
-- reset_combiner - entity/architecture pair
-------------------------------------------------------------------------------
--
-- ***************************************************************************
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2009 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
-- ***************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        reset_combiner.vhd
-- Version:         v1.00a
-- Description:     combine all resets and capture on proper clock domains
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   This section shows the hierarchical structure of axi_uartlite.
--
--              axi_ethernet.vhd
--                reset_combiner.vhd
-------------------------------------------------------------------------------
-- Author:          MSH & MW
--
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

-------------------------------------------------------------------------------
-- Definition of Generics :
-------------------------------------------------------------------------------
--
--
-------------------------------------------------------------------------------
-- Definition of Ports :
-------------------------------------------------------------------------------
--Inputs
-- S_AXI_ACLK            -- AXI Clock
-- S_AXI_ARESETN         -- AXI Reset
-- Axi_Str_TxD_AClk     --
-- Axi_Str_TxD_AReset   --
-- Axi_Str_TxC_AClk     --
-- Axi_Str_TxC_AReset   --
-- Axi_Str_RxD_AClk     --
-- Axi_Str_rxD_AReset   --
-- Axi_Str_RxS_AClk     --
-- Axi_Str_RxS_AReset   --
--Outputs
-- RESET2AXI
-- saxiResetToAxiStrTxD     --
-- saxiResetToAxiStrTxC     --
-- saxiResetToAxiStrRxD     --
-- saxiResetToAxiStrRxS     --
-------------------------------------------------------------------------------

entity reset_combiner is
  generic (
    C_SIMULATION         : integer range 0 to 1 := 0
  );
  port (
    S_AXI_ACLK           : in  std_logic;   --  AXI4-Lite Clock
    S_AXI_ARESETN        : in  std_logic;   --  AXI4-Lite Reset
    GTX_CLK_125MHZ       : in  std_logic;   --  GTX CLK
    RX_CLIENT_CLK        : in  std_logic;   --  Receive Client Clock
    RX_CLIENT_CLK_EN     : in  std_logic;   --  Receive Client Clock Enable
    TX_CLIENT_CLK        : in  std_logic;   --  Transmit Client Clock
    TX_CLIENT_CLK_EN     : in  std_logic;   --  Transmit Client Clock Enable
    AXI_STR_TXD_ACLK     : in  std_logic;   --  AXI-Stream Transmit Clock
    AXI_STR_TXD_ARESETN  : in  std_logic;   --  AXI-Stream Transmit Reset
    AXI_STR_TXC_ACLK     : in  std_logic;   --  AXI-Stream Transmit Clock
    AXI_STR_TXC_ARESETN  : in  std_logic;   --  AXI-Stream Transmit Reset
    AXI_STR_RXD_ACLK     : in  std_logic;   --  AXI-Stream Receive Clock
    AXI_STR_RXD_ARESETN  : in  std_logic;   --  AXI-Stream Receive Reset
    AXI_STR_RXS_ACLK     : in  std_logic;   --  AXI-Stream Receive Clock
    AXI_STR_RXS_ARESETN  : in  std_logic;   --  AXI-Stream Receive Reset
    PHY_RESET_N          : out std_logic;   --  PHY Reset
    PHY_RESET_CMPLTE     : out std_logic;   --  PHY Reset Complete
    RESET2AXI            : out std_logic;   --  Reset going to AXI
    RESET2RX_CLIENT      : out std_logic;   --  Reset going to Receive Client Interface
    RESET2TX_CLIENT      : out std_logic;   --  Reset going to Transmit Client Interface
    RESET2AXI_STR_TXD    : out std_logic;   --  Reset going to AXI-Stream Transmit Data Interface
    RESET2AXI_STR_TXC    : out std_logic;   --  Reset going to AXI-Stream Transmit Control Interface
    RESET2AXI_STR_RXD    : out std_logic;   --  Reset going to AXI-Stream Receive Data Interface
    RESET2AXI_STR_RXS    : out std_logic;   --  Reset going to AXI-Stream Receive Status Interface
    RESET2GTX_CLK        : out std_logic    --  Reset going to GTX Clock signals
  );
end reset_combiner;

architecture imp of reset_combiner is

  constant C_10MS : std_logic_vector(11 downto 0) := "100000000000"; -- 0x0800
  constant C_15MS : std_logic_vector(11 downto 0) := "110000000000"; -- 0x0C00
  constant C_10US : std_logic_vector(11 downto 0) := "000000000000"; -- 0x01
  constant C_15US : std_logic_vector(11 downto 0) := "000000000001"; -- 0x02

  signal axiStrTxdResetSaxiDomain      : std_logic;
  signal axiStrTxcResetSaxiDomain      : std_logic;
  signal axiStrRxdResetSaxiDomain      : std_logic;
  signal axiStrRxSResetSaxiDomain      : std_logic;

  signal saxiResetAxiStrTxdDomain      : std_logic;
  signal axiStrTxcResetAxiStrTxdDomain : std_logic;
  signal axiStrRxdResetAxiStrTxdDomain : std_logic;
  signal axiStrRxsResetAxiStrTxdDomain : std_logic;

  signal saxiResetAxiStrTxcDomain      : std_logic;
  signal axiStrTxdResetAxiStrTxcDomain : std_logic;
  signal axiStrRxdResetAxiStrTxcDomain : std_logic;
  signal axiStrRxsResetAxiStrTxcDomain : std_logic;

  signal saxiResetAxiStrRxdDomain      : std_logic;
  signal axiStrTxdResetAxiStrRxdDomain : std_logic;
  signal axiStrTxcResetAxiStrRxdDomain : std_logic;
  signal axiStrRxsResetAxiStrRxdDomain : std_logic;

  signal saxiResetAxiStrRxsDomain      : std_logic;
  signal axiStrTxdResetAxiStrRxsDomain : std_logic;
  signal axiStrTxcResetAxiStrRxsDomain : std_logic;
  signal axiStrRxdResetAxiStrRxsDomain : std_logic;

  signal saxiResetGtxDomain            : std_logic;
  signal saxiResetGtxDomain_d1         : std_logic;
  signal saxiResetGtxDomain_pulse      : std_logic;
  signal reset2gtx                     : std_logic;

  signal phy_reset_count               : std_logic_vector(11 downto 0);
  signal reset_delay                   : std_logic_vector(11 downto 0);
  signal reset_done_delay              : std_logic_vector(11 downto 0);

  signal reset2axi_i                   : std_logic;
  signal s_axi_areset                  : std_logic;
  signal axi_str_txd_areset            : std_logic;
  signal axi_str_txc_areset            : std_logic;
  signal axi_str_rxd_areset            : std_logic;
  signal axi_str_rxs_areset            : std_logic;

  signal srl32_1_output                : std_logic;
  signal srl32_2_output                : std_logic;
  signal srl32_2_output_d1             : std_logic;
  signal phyResetCntEnable             : std_logic;

begin

  GTX_RESET_PULSE : process (GTX_CLK_125MHZ)
  begin
    if (GTX_CLK_125MHZ'event and GTX_CLK_125MHZ = '1') then
      if (s_axi_areset = '1') then
        saxiResetGtxDomain_d1    <= saxiResetGtxDomain;
        saxiResetGtxDomain_pulse <= '0';
        srl32_2_output_d1        <= '0';
        phyResetCntEnable        <= '0';
      else
        saxiResetGtxDomain_d1    <= saxiResetGtxDomain;

        -- create a reset pulse 1 clock wide as reset is going inactive
        saxiResetGtxDomain_pulse <= saxiResetGtxDomain_d1 and not(saxiResetGtxDomain);
        srl32_2_output_d1        <= srl32_2_output;
        phyResetCntEnable        <= srl32_2_output and not(srl32_2_output_d1);
      end if;
    end if;
  end process;

  -- SRLC32E: 32-bit variable length shift register LUT
  -- with clock enable
  -- Xilinx HDL Libraries Guide, version 12.2

  SRLC32E_1 : SRLC32E
  generic map (
    INIT => X"00000001"
  )
  port map (
    Q   => srl32_1_output, -- SRL data output
    Q31 => open,           -- SRL cascade output pin
    A   => "11110",        -- 5-bit shift depth select input 11111 is 32 00000 is 1
    CE  => '1',            -- Clock enable input
    CLK => GTX_CLK_125MHZ, -- Clock input
    D   => srl32_1_output  -- SRL data input
  );
  -- End of SRLC32E_inst instantiation

  -- SRLC32E: 32-bit variable length shift register LUT
  -- with clock enable
  -- Xilinx HDL Libraries Guide, version 12.2

  SRLC32E_2 : SRLC32E
  generic map (
    INIT => X"00000001"
  )
  port map (
    Q   => srl32_2_output, -- SRL data output
    Q31 => open,           -- SRL cascade output pin
    A   => "10010",        -- 5-bit shift depth select input 11111 is 32 00000 is 1
    CE  => srl32_1_output, -- Clock enable input
    CLK => GTX_CLK_125MHZ, -- Clock input
    D   => srl32_2_output  -- SRL data input (pulse every 5 uS)
  );
  -- End of SRLC32E_inst instantiation

  s_axi_areset       <= not(S_AXI_ARESETN);
  axi_str_txd_areset <= not(AXI_STR_TXD_ARESETN);
  axi_str_txc_areset <= not(AXI_STR_TXC_ARESETN);
  axi_str_rxd_areset <= not(AXI_STR_RXD_ARESETN);
  axi_str_rxs_areset <= not(AXI_STR_RXS_ARESETN);

  NORMAL_DELAY: if(C_SIMULATION = 0) generate
  BEGIN
    reset_delay      <= C_10MS;
    reset_done_delay <= C_15MS;
  end generate NORMAL_DELAY;

  SIMULATION_DELAY: if(C_SIMULATION = 1) generate
  BEGIN
    reset_delay      <= C_10US;
    reset_done_delay <= C_15US;
  end generate SIMULATION_DELAY;

  -----------------------------------------------------------------------------
  -- we must hold the PHY reset active for at least 5mS which we will do by
  -- using the known 125 MHz GTX clock
  -----------------------------------------------------------------------------

  COUNT_GTX : process (GTX_CLK_125MHZ)
  begin
    if (GTX_CLK_125MHZ'event and GTX_CLK_125MHZ = '1') then
      if (reset2gtx = '1') then
        PHY_RESET_N      <= '0';
        PHY_RESET_CMPLTE <= '0';
        phy_reset_count  <= (others => '0');
      elsif (phyResetCntEnable = '1') then -- once every 5 uS
        if (phy_reset_count <= reset_delay) then -- 10mS (10 uS in simulation mode)
          PHY_RESET_N      <= '0';
          PHY_RESET_CMPLTE <= '0';
          phy_reset_count  <= phy_reset_count + 1;
        elsif (phy_reset_count <= reset_done_delay) then -- 15mS (15 uS in simulation mode)
          PHY_RESET_N      <= '1';
          PHY_RESET_CMPLTE <= '0';
          phy_reset_count  <= phy_reset_count + 1;
        else
          PHY_RESET_N  <= '1';
          PHY_RESET_CMPLTE <= '1';
        end if;
      end if;
    end if;
  end process;


  reset2axi_i      <= s_axi_areset                  or axiStrTxdResetSaxiDomain
                   or axiStrTxcResetSaxiDomain      or axiStrRxdResetSaxiDomain
                   or axiStrRxSResetSaxiDomain;

  RESET2AXI        <= reset2axi_i;

  RESET2AXI_STR_TXD <= saxiResetAxiStrTxdDomain      or axi_str_txd_areset
                   or axiStrTxcResetAxiStrTxdDomain or axiStrRxdResetAxiStrTxdDomain
                   or axiStrRxsResetAxiStrTxdDomain;

  RESET2AXI_STR_TXC <= saxiResetAxiStrTxcDomain      or axiStrTxdResetAxiStrTxcDomain
                   or axi_str_txc_areset            or axiStrRxdResetAxiStrTxcDomain
                   or axiStrRxsResetAxiStrTxcDomain;

  RESET2AXI_STR_RXD <= saxiResetAxiStrRxdDomain      or axiStrTxdResetAxiStrRxdDomain
                   or axiStrTxcResetAxiStrRxdDomain or axi_str_rxd_areset
                   or axiStrRxsResetAxiStrRxdDomain;

  RESET2AXI_STR_RXS <= saxiResetAxiStrRxsDomain      or axiStrTxdResetAxiStrRxsDomain
                   or axiStrTxcResetAxiStrRxsDomain or axiStrRxdResetAxiStrRxsDomain
                   or axi_str_rxs_areset;

  reset2gtx         <= saxiResetGtxDomain;
  RESET2GTX_CLK     <= saxiResetGtxDomain;

  AXI_RESET_TO_RXCLIENT : entity axi_ethernet_v3_01_a.actv_hi_reset_clk_cross(imp)
  port map    (
    ClkA               => S_AXI_ACLK,
    ClkAEN             => '1',
    ClkARst            => reset2axi_i,
    ClkAOutOfClkBRst   => open,
    ClkACombinedRstOut => open,
    ClkB               => RX_CLIENT_CLK,
    ClkBEN             => RX_CLIENT_CLK_EN,
    ClkBRst            => '0',
    ClkBOutOfClkARst   => RESET2RX_CLIENT,
    ClkBCombinedRstOut => open
  );

  AXI_RESET_TO_TXCLIENT : entity axi_ethernet_v3_01_a.actv_hi_reset_clk_cross(imp)
  port map    (
    ClkA               => S_AXI_ACLK,
    ClkAEN             => '1',
    ClkARst            => reset2axi_i,
    ClkAOutOfClkBRst   => open,
    ClkACombinedRstOut => open,
    ClkB               => TX_CLIENT_CLK,
    ClkBEN             => TX_CLIENT_CLK_EN,
    ClkBRst            => '0',
    ClkBOutOfClkARst   => RESET2TX_CLIENT,
    ClkBCombinedRstOut => open
  );

  AXI_RESET_TO_GTX : entity axi_ethernet_v3_01_a.actv_hi_reset_clk_cross(imp)
  port map    (
    ClkA               => S_AXI_ACLK,
    ClkAEN             => '1',
    ClkARst            => s_axi_areset,
    ClkAOutOfClkBRst   => open,
    ClkACombinedRstOut => open,
    ClkB               => GTX_CLK_125MHZ,
    ClkBEN             => '1',
    ClkBRst            => '0',
    ClkBOutOfClkARst   => saxiResetGtxDomain,
    ClkBCombinedRstOut => open
  );

  -----------------------------------------------------------------------------
  -- AXI Reset in
  -----------------------------------------------------------------------------
  AXI_RESET_TO_TXD_AXSTREAM : entity axi_ethernet_v3_01_a.actv_hi_reset_clk_cross(imp)
  port map    (
    ClkA               => S_AXI_ACLK,
    ClkAEN             => '1',
    ClkARst            => s_axi_areset,
    ClkAOutOfClkBRst   => axiStrTxdResetSaxiDomain,
    ClkACombinedRstOut => open,
    ClkB               => Axi_Str_TxD_AClk,
    ClkBEN             => '1',
    ClkBRst            => axi_str_txd_areset,
    ClkBOutOfClkARst   => saxiResetAxiStrTxdDomain,
    ClkBCombinedRstOut => open
  );

  AXI_RESET_TO_TXC_AXSTREAM : entity axi_ethernet_v3_01_a.actv_hi_reset_clk_cross(imp)
  port map    (
    ClkA               => S_AXI_ACLK,
    ClkAEN             => '1',
    ClkARst            => s_axi_areset,
    ClkAOutOfClkBRst   => axiStrTxcResetSaxiDomain,
    ClkACombinedRstOut => open,
    ClkB               => Axi_Str_TxC_AClk,
    ClkBEN             => '1',
    ClkBRst            => axi_str_txc_areset,
    ClkBOutOfClkARst   => saxiResetAxiStrTxcDomain,
    ClkBCombinedRstOut => open
  );

  AXI_RESET_TO_RXD_AXSTREAM : entity axi_ethernet_v3_01_a.actv_hi_reset_clk_cross(imp)
  port map    (
    ClkA               => S_AXI_ACLK,
    ClkAEN             => '1',
    ClkARst            => s_axi_areset,
    ClkAOutOfClkBRst   => axiStrRxdResetSaxiDomain,
    ClkACombinedRstOut => open,
    ClkB               => Axi_Str_RxD_AClk,
    ClkBEN             => '1',
    ClkBRst            => axi_str_rxd_areset,
    ClkBOutOfClkARst   => saxiResetAxiStrRxdDomain,
    ClkBCombinedRstOut => open
  );

  AXI_RESET_TO_RXS_AXSTREAM : entity axi_ethernet_v3_01_a.actv_hi_reset_clk_cross(imp)
  port map    (
    ClkA               => S_AXI_ACLK,
    ClkAEN             => '1',
    ClkARst            => s_axi_areset,
    ClkAOutOfClkBRst   => axiStrRxsResetSaxiDomain,
    ClkACombinedRstOut => open,
    ClkB               => Axi_Str_RxS_AClk,
    ClkBEN             => '1',
    ClkBRst            => axi_str_rxs_areset,
    ClkBOutOfClkARst   => saxiResetAxiStrRxsDomain,
    ClkBCombinedRstOut => open
  );

  -----------------------------------------------------------------------------
  -- AXI Stream TxD Reset in
  -----------------------------------------------------------------------------
  TXD_AXSTREAM_TO_TXC_AXSTREAM : entity axi_ethernet_v3_01_a.actv_hi_reset_clk_cross(imp)
  port map    (
    ClkA               => Axi_Str_TxD_AClk,
    ClkAEN             => '1',
    ClkARst            => axi_str_txd_areset,
    ClkAOutOfClkBRst   => axiStrTxcResetAxiStrTxdDomain,
    ClkACombinedRstOut => open,
    ClkB               => Axi_Str_TxC_AClk,
    ClkBEN             => '1',
    ClkBRst            => axi_str_txc_areset,
    ClkBOutOfClkARst   => axiStrTxdResetAxiStrTxcDomain,
    ClkBCombinedRstOut => open
  );
  TXD_AXSTREAM_TO_RXD_AXSTREAM : entity axi_ethernet_v3_01_a.actv_hi_reset_clk_cross(imp)
  port map    (
    ClkA               => Axi_Str_TxD_AClk,
    ClkAEN             => '1',
    ClkARst            => axi_str_txd_areset,
    ClkAOutOfClkBRst   => axiStrRxdResetAxiStrTxdDomain,
    ClkACombinedRstOut => open,
    ClkB               => Axi_Str_RxD_AClk,
    ClkBEN             => '1',
    ClkBRst            => axi_str_rxd_areset,
    ClkBOutOfClkARst   => axiStrTxdResetAxiStrRxdDomain,
    ClkBCombinedRstOut => open
  );
  TXD_AXSTREAM_TO_RXS_AXSTREAM : entity axi_ethernet_v3_01_a.actv_hi_reset_clk_cross(imp)
  port map    (
    ClkA               => Axi_Str_TxD_AClk,
    ClkAEN             => '1',
    ClkARst            => axi_str_txd_areset,
    ClkAOutOfClkBRst   => axiStrRxsResetAxiStrTxdDomain,
    ClkACombinedRstOut => open,
    ClkB               => Axi_Str_RxS_AClk,
    ClkBEN             => '1',
    ClkBRst            => axi_str_rxs_areset,
    ClkBOutOfClkARst   => axiStrTxdResetAxiStrRxsDomain,
    ClkBCombinedRstOut => open
  );
  -----------------------------------------------------------------------------
  -- AXI Stream TxC Reset in
  -----------------------------------------------------------------------------
  TXC_AXSTREAM_TO_RXD_AXSTREAM : entity axi_ethernet_v3_01_a.actv_hi_reset_clk_cross(imp)
  port map    (
    ClkA               => Axi_Str_TxC_AClk,
    ClkAEN             => '1',
    ClkARst            => axi_str_txc_areset,
    ClkAOutOfClkBRst   => axiStrRxdResetAxiStrTxcDomain,
    ClkACombinedRstOut => open,
    ClkB               => Axi_Str_RxD_AClk,
    ClkBEN             => '1',
    ClkBRst            => axi_str_rxd_areset,
    ClkBOutOfClkARst   => axiStrTxcResetAxiStrRxdDomain,
    ClkBCombinedRstOut => open
  );
  TXC_AXSTREAM_TO_RXS_AXSTREAM : entity axi_ethernet_v3_01_a.actv_hi_reset_clk_cross(imp)
  port map    (
    ClkA               => Axi_Str_TxC_AClk,
    ClkAEN             => '1',
    ClkARst            => axi_str_txc_areset,
    ClkAOutOfClkBRst   => axiStrRxsResetAxiStrTxcDomain,
    ClkACombinedRstOut => open,
    ClkB               => Axi_Str_RxS_AClk,
    ClkBEN             => '1',
    ClkBRst            => axi_str_rxs_areset,
    ClkBOutOfClkARst   => axiStrTxcResetAxiStrRxsDomain,
    ClkBCombinedRstOut => open
  );
  -----------------------------------------------------------------------------
  -- AXI Stream RxD Reset in
  -----------------------------------------------------------------------------
  RXD_AXSTREAM_TO_RXS_AXSTREAM : entity axi_ethernet_v3_01_a.actv_hi_reset_clk_cross(imp)
  port map    (
    ClkA               => Axi_Str_RxD_AClk,
    ClkAEN             => '1',
    ClkARst            => axi_str_rxd_areset,
    ClkAOutOfClkBRst   => axiStrRxsResetAxiStrRxdDomain,
    ClkACombinedRstOut => open,
    ClkB               => Axi_Str_RxS_AClk,
    ClkBEN             => '1',
    ClkBRst            => axi_str_rxs_areset,
    ClkBOutOfClkARst   => axiStrRxdResetAxiStrRxsDomain,
    ClkBCombinedRstOut => open
  );
end imp;
