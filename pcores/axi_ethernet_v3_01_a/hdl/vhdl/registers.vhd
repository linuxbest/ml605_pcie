------------------------------------------------------------------------------
-- registers - entity and arch
------------------------------------------------------------------------------
--
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
-- Copyright 2000, 2001, 2002, 2003, 2004, 2005, 2008 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
--

------------------------------------------------------------------------------
-- Filename:        registers.vhd
-- Version:         v2.00a
-- Description:     Include a meaningful description of your file. Multi-line
--                  descriptions should align with each other
--
--  Addr   REG    Chipselect #
-- offset
-- 0x000   RAF   Bus2IP_Wr/RdCE(0) Bus2IP_CS(0)
-- 0x004   TPF   Bus2IP_Wr/RdCE(1) Bus2IP_CS(0)
-- 0x008   IFGP  Bus2IP_Wr/RdCE(2) Bus2IP_CS(0)
-- 0x00C   IS    Bus2IP_Wr/RdCE(3) Bus2IP_CS(0)
-- 0x010   IP    Bus2IP_Wr/RdCE(4) Bus2IP_CS(0)
-- 0x014   IE    Bus2IP_Wr/RdCE(5) Bus2IP_CS(0)
-- 0x018   TTAG  Bus2IP_Wr/RdCE(6) Bus2IP_CS(0)
-- 0x01C   RTAG  Bus2IP_Wr/RdCE(7) Bus2IP_CS(0)
-- 0x020   UAWL  Bus2IP_Wr/RdCE(8)  Bus2IP_CS(0)
-- 0x024   UAWU  Bus2IP_Wr/RdCE(9)  Bus2IP_CS(0)
-- 0x028   TPID0 Bus2IP_Wr/RdCE(10) Bus2IP_CS(0)
-- 0x02C   TPID1 Bus2IP_Wr/RdCE(11) Bus2IP_CS(0)
--
-- 0x0000200 - 0x00007FC stats & temac regs  Bus2IP_Wr/RdCE(16) Bus2IP_CS(1)
-- 0x0004000 - 0x0007FFC TX VLAN TRANS  BRAM Bus2IP_Wr/RdCE(17) Bus2IP_CS(2)
-- 0x0008000 - 0x000BFFC RX VLAN TRANS  BRAM Bus2IP_Wr/RdCE(18) Bus2IP_CS(3)
-- 0x0010000 - 0x0013FFC AVB                 Bus2IP_Wr/RdCE(19) Bus2IP_CS(4)
-- 0x0020000 - 0x003FFFC Multicast ADDR BRAM Bus2IP_Wr/RdCE(20) Bus2IP_CS(5)
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to improve
--              readability.
--
--              top_level.vhd
--                  -- second_level_file1.vhd
--                      -- third_level_file1.vhd
--                          -- fourth_level_file.vhd
--                      -- third_level_file2.vhd
--                  -- second_level_file2.vhd
--                  -- second_level_file3.vhd
--
--              This section is optional for common/shared modules but should
--              contain a statement stating it is a common/shared module.
------------------------------------------------------------------------------
-- Author:
-- History:
--
--
------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      AxiReset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_bit.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.all;

library unisim;
use unisim.vcomponents.all;

library axi_ethernet_v3_01_a;

entity registers is
  generic
  (
    C_FAMILY       : string   := "virtex5";
    C_TXVLAN_TRAN  : integer  := 1;
    C_TXVLAN_TAG   : integer  := 1;
    C_TXVLAN_STRP  : integer  := 1;
    C_STATS        : integer  := 1;
    C_RXVLAN_TRAN  : integer  := 1;
    C_RXVLAN_TAG   : integer  := 1;
    C_RXVLAN_STRP  : integer  := 1;
    C_MCAST_EXTEND : integer  := 1;
    C_TXVLAN_WIDTH : integer  := 1;
    C_RXVLAN_WIDTH : integer  := 1
  );
  port
  (
    AxiClk                    : in  std_logic;                    --  AXI4-Lite Clock
    Stats_clk                 : in  std_logic;                    --  Statistics Clock
    Host_clk                  : in  std_logic;                    --  Host Clock
    AXI_STR_TXD_ACLK          : in  std_logic;                    --  AXI-Stream Transmit Data Clock
    TxClClk                   : in  std_logic;                    --  Transmit Client Clock
    RxClClk                   : in  std_logic;                    --  Receive Client Clock
    AxiReset                  : in  std_logic;                    --  AXI4-Lite Reset
    IP2Bus_Data               : out std_logic_vector(0 to 31);    --  AXI Ethernet to AXI4-Lite Data
    IP2Bus_WrAck              : out std_logic;                    --  AXI Ethernet to AXI4-Lite Write Ack
    IP2Bus_RdAck              : out std_logic;                    --  AXI Ethernet to AXI4-Lite Read Ack
    Bus2IP_Addr               : in  std_logic_vector(0 to 31);    --  AXI4-Lite to AXI Ethernet Addr
    Bus2IP_Data               : in  std_logic_vector(0 to 31);    --  AXI4-Lite to AXI Ethernet Data
    Bus2IP_RNW                : in  std_logic;                    --  AXI4-Lite to AXI Ethernet RNW
    Bus2IP_CS                 : in  std_logic_vector(0 to 10);    --  AXI4-Lite to AXI Ethernet CS
    Bus2IP_RdCE               : in  std_logic_vector(0 to 41);    --  AXI4-Lite to AXI Ethernet RdCE
    Bus2IP_WrCE               : in  std_logic_vector(0 to 41);    --  AXI4-Lite to AXI Ethernet WrCE
    IntrptsIn                 : in  std_logic_vector(23 to 31);   --  Interrupts in
    TPReq                     : out std_logic;                    --  Transmit Pause Request
    CrRegData                 : out std_logic_vector(17 to 31);   --  RAF Register
    TpRegData                 : out std_logic_vector(16 to 31);   --  Transmit Pause Data
    IfgpRegData               : out std_logic_vector(24 to 31);   --  Inter Frame Gap Data
    IsRegData                 : out std_logic_vector(23 to 31);   --  Interrupt Status Register
    IpRegData                 : out std_logic_vector(23 to 31);   --  Interrupt Pending Register
    IeRegData                 : out std_logic_vector(23 to 31);   --  Interrupt Enable Register
    IntrptOut                 : out std_logic;                    --  Interrupt Out
    TtagRegData               : out std_logic_vector(0 to 31);    --  Transmit Tag Register
    RtagRegData               : out std_logic_vector(0 to 31);    --  Receive Tag Register
    Tpid0RegData              : out std_logic_vector(0 to 31);    --  VLAN TPID Reg 0
    Tpid1RegData              : out std_logic_vector(0 to 31);    --  VLAN TPID Reg 1
    pcspma_status_cross       : in  std_logic_vector(16 to 31);   --  PCS PMA Link Status Vector
    UawLRegData               : out std_logic_vector(0 to 31);    --  Unicast Address Word Lower
    UawURegData               : out std_logic_vector(16 to 31);   --  Unicast Address Word Upper
    RxClClkMcastAddr          : in  std_logic_vector(0 to 14);    --  Receive Extended Multicast Address
    RxClClkMcastEn            : in  std_logic;                    --  Receive Extended Multicast Enable
    RxClClkMcastRdData        : out std_logic_vector(0 to 0);     --  Receive Extended Multicast Data
    AxiStrTxDClkTxVlanAddr    : in  std_logic_vector(0 to 11);    --  Transmit VLAN BRAM Addr
    AxiStrTxDClkTxVlanRdData  : out std_logic_vector(18 to 31);   --  Transmit VLAN BRAM Read Data
    RxClClkRxVlanAddr         : in  std_logic_vector(0 to 11);    --  Receive VLAN BRAM Addr
    RxClClkRXVlanRdData       : out std_logic_vector(18 to 31);   --  Receive VLAN BRAM Read Data
    AxiStrTxDClkTxVlanBramEnA : in  std_logic;                    --  Transmit VLAN BRAM Enable
    RxClClkRxVlanBramEnA      : in  std_logic                     --  Receive VLAN BRAM Enable
  );
end registers;

architecture imp of registers is

signal crRdData      : std_logic_vector(17 to 31);
signal tpRdData      : std_logic_vector(16 to 31);
signal ifgpRdData    : std_logic_vector(24 to 31);
signal isRdData      : std_logic_vector(23 to 31);
signal ieRdData      : std_logic_vector(23 to 31);
signal ipRdData      : std_logic_vector(23 to 31);
signal ttagRdData    : std_logic_vector(0 to 31);
signal rtagRdData    : std_logic_vector(0 to 31);
signal tpid0RdData   : std_logic_vector(0 to 31);
signal tpid1RdData   : std_logic_vector(0 to 31);
signal pcspma_status : std_logic_vector(16 to 31);
signal uawLRdData    : std_logic_vector(0 to 31);
signal uawURdData    : std_logic_vector(16 to 31);

signal isRegData_i   : std_logic_vector(23 to 31);
signal ieRegData_i   : std_logic_vector(23 to 31);
signal ttagRegData_i : std_logic_vector(0 to 31);
signal rtagRegData_i : std_logic_vector(0 to 31);
signal tpid0RegData_i: std_logic_vector(0 to 31);
signal tpid1RegData_i: std_logic_vector(0 to 31);
signal uawLRegData_i : std_logic_vector(0 to 31);
signal uawURegData_i : std_logic_vector(16 to 31);
signal axiClkMcastRdData    : std_logic_vector(0 to 0);
signal axiClkMcastRdData_i  : std_logic_vector(0 to 0);
signal axiClkTxVlanRdData   : std_logic_vector(18 to 31);
signal axiClkTxVlanRdData_i : std_logic_vector(((31-C_TXVLAN_WIDTH)+1) to 31);
signal axiClkTxVlanWrData_i : std_logic_vector(((31-C_TXVLAN_WIDTH)+1) to 31);
signal axiClkRxVlanRdData   : std_logic_vector(18 to 31);
signal axiClkRxVlanRdData_i : std_logic_vector(((31-C_RXVLAN_WIDTH)+1) to 31);
signal axiClkRxVlanWrData_i : std_logic_vector(((31-C_RXVLAN_WIDTH)+1) to 31);
signal AxiStrTxDClkTxRdData_i   : std_logic_vector(((31-C_TXVLAN_WIDTH)+1) to 31);
signal rxClClkRxRdData_i   : std_logic_vector(((31-C_RXVLAN_WIDTH)+1) to 31);
signal txvlan_dina    : std_logic_vector(((31-C_TXVLAN_WIDTH)+1) to 31);
signal rxvlan_dina    : std_logic_vector(((31-C_RXVLAN_WIDTH)+1) to 31);
signal rdData          : std_logic_vector(0 to 31);
signal softRead        : std_logic;
signal softWrite       : std_logic;
signal temacDcr_DBus_i : std_logic_vector(0 to 31);
signal softRead_d1     : std_logic;
signal softWrite_d1    : std_logic;

signal iP2Bus_WrAck_i  : std_logic;
signal iP2Bus_RdAck_i  : std_logic;

signal rdAckBlocker    : std_logic;
signal wrAckBlocker    : std_logic;

signal bus2IP_WrCE_17_d1 : std_logic;
signal bus2IP_WrCE_17_en : std_logic;

signal bus2IP_WrCE_18_d1 : std_logic;
signal bus2IP_WrCE_18_en : std_logic;

signal bus2IP_WrCE_20_d1 : std_logic;
signal bus2IP_WrCE_20_en : std_logic;

signal zeroes            : std_logic_vector(23 downto 0);

begin
  PIPE_RAM_WRITE_PROCESS: process (AxiClk)
  begin
    if (AxiClk'event and AxiClk = '1') then
      if (AxiReset = '1') then
        bus2IP_WrCE_17_d1     <= '0';
        bus2IP_WrCE_17_en     <= '0';
        bus2IP_WrCE_18_d1     <= '0';
        bus2IP_WrCE_18_en     <= '0';
        bus2IP_WrCE_20_d1     <= '0';
        bus2IP_WrCE_20_en     <= '0';
      else
        bus2IP_WrCE_17_d1     <= Bus2IP_WrCE(17);
        bus2IP_WrCE_17_en     <= Bus2IP_WrCE(17) and not(bus2IP_WrCE_17_d1);
        bus2IP_WrCE_18_d1     <= Bus2IP_WrCE(18);
        bus2IP_WrCE_18_en     <= Bus2IP_WrCE(18) and not(bus2IP_WrCE_18_d1);
        bus2IP_WrCE_20_d1     <= Bus2IP_WrCE(20);
        bus2IP_WrCE_20_en     <= Bus2IP_WrCE(20) and not(bus2IP_WrCE_20_d1);
      end if;
    end if;
  end process;

  txvlan_dina <= (others => '0');
  rxvlan_dina <= (others => '0');

  -- TX VLAN --
  TX_VLAN_TRAN_STRP_TAG : if (C_TXVLAN_TRAN = 1 and C_TXVLAN_STRP = 1 and C_TXVLAN_TAG = 1) generate
  begin
    axiClkTxVlanRdData   <= axiClkTxVlanRdData_i when (Bus2IP_RdCE(17) = '1') else (others => '0');
    axiClkTxVlanWrData_i <= Bus2IP_Data(18 to 31);
    AxiStrTxDClkTxVlanRdData  <= AxiStrTxDClkTxRdData_i;
  end generate TX_VLAN_TRAN_STRP_TAG;

  TX_VLAN_TRAN_STRP : if (C_TXVLAN_TRAN = 1 and C_TXVLAN_STRP = 1 and C_TXVLAN_TAG = 0) generate
  begin
    axiClkTxVlanRdData   <= axiClkTxVlanRdData_i & '0' when (Bus2IP_RdCE(17) = '1') else (others => '0');
    axiClkTxVlanWrData_i <= Bus2IP_Data(18 to 30);
    AxiStrTxDClkTxVlanRdData  <= AxiStrTxDClkTxRdData_i & '0';
  end generate TX_VLAN_TRAN_STRP;

  TX_VLAN_TRAN_TAG : if (C_TXVLAN_TRAN = 1 and C_TXVLAN_STRP = 0 and C_TXVLAN_TAG = 1) generate
  begin
    axiClkTxVlanRdData   <= axiClkTxVlanRdData_i(19 to 30) & '0' & axiClkTxVlanRdData_i(31)
                              when (Bus2IP_RdCE(17) = '1') else (others => '0');
    axiClkTxVlanWrData_i <= Bus2IP_Data(18 to 29)& Bus2IP_Data(31);
    AxiStrTxDClkTxVlanRdData  <= AxiStrTxDClkTxRdData_i(19 to 30) & '0' & AxiStrTxDClkTxRdData_i(31);
  end generate TX_VLAN_TRAN_TAG;

  TX_VLAN_TRAN : if (C_TXVLAN_TRAN = 1 and C_TXVLAN_STRP = 0 and C_TXVLAN_TAG = 0) generate
  begin
    axiClkTxVlanRdData   <= axiClkTxVlanRdData_i(20 to 31) & "00" when (Bus2IP_RdCE(17) = '1') else (others => '0');
    axiClkTxVlanWrData_i <= Bus2IP_Data(18 to 29);
    AxiStrTxDClkTxVlanRdData  <= AxiStrTxDClkTxRdData_i(20 to 31) & "00";
  end generate TX_VLAN_TRAN;

  TX_VLAN_STRP_TAG : if (C_TXVLAN_TRAN = 0 and C_TXVLAN_STRP = 1 and C_TXVLAN_TAG = 1) generate
  begin
    axiClkTxVlanRdData   <= "000000000000" & axiClkTxVlanRdData_i when (Bus2IP_RdCE(17) = '1') else (others => '0');
    axiClkTxVlanWrData_i <= Bus2IP_Data(30 to 31);
    AxiStrTxDClkTxVlanRdData  <= "000000000000" & AxiStrTxDClkTxRdData_i;
  end generate TX_VLAN_STRP_TAG;

  TX_VLAN_STRP : if (C_TXVLAN_TRAN = 0 and C_TXVLAN_STRP = 1 and C_TXVLAN_TAG = 0) generate
  begin
    axiClkTxVlanRdData   <= "000000000000" & axiClkTxVlanRdData_i & '0'
                              when (Bus2IP_RdCE(17) = '1') else (others => '0');
    axiClkTxVlanWrData_i <= Bus2IP_Data(30 to 30);
    AxiStrTxDClkTxVlanRdData  <= "000000000000" & AxiStrTxDClkTxRdData_i & '0';
  end generate TX_VLAN_STRP;

  TX_VLAN_TAG : if (C_TXVLAN_TRAN = 0 and C_TXVLAN_STRP = 0 and C_TXVLAN_TAG = 1) generate
  begin
    axiClkTxVlanRdData   <= "000000000000" & '0' & axiClkTxVlanRdData_i
                              when (Bus2IP_RdCE(17) = '1') else (others => '0');
    axiClkTxVlanWrData_i <= Bus2IP_Data(31 to 31);
    AxiStrTxDClkTxVlanRdData  <= "000000000000" & '0' & AxiStrTxDClkTxRdData_i;
  end generate TX_VLAN_TAG;

  TX_VLAN_NONE : if (C_TXVLAN_TRAN = 0 and C_TXVLAN_STRP = 0 and C_TXVLAN_TAG = 0) generate
  begin
    axiClkTxVlanRdData   <= (others => '0');
    AxiStrTxDClkTxVlanRdData  <= (others => '0');
  end generate TX_VLAN_NONE;

  -- RX VLAN --
  RX_VLAN_TRAN_STRP_TAG : if (C_RXVLAN_TRAN = 1 and C_RXVLAN_STRP = 1 and C_RXVLAN_TAG = 1) generate
  begin
    axiClkRXVlanRdData    <= axiClkRXVlanRdData_i when (Bus2IP_RdCE(18) = '1') else (others => '0');
    axiClkRXVlanWrData_i  <= Bus2IP_Data(18 to 31);
    RxClClkRXVlanRdData   <= rxClClkRxRdData_i;
  end generate RX_VLAN_TRAN_STRP_TAG;

  RX_VLAN_TRAN_STRP : if (C_RXVLAN_TRAN = 1 and C_RXVLAN_STRP = 1 and C_RXVLAN_TAG = 0) generate
  begin
    axiClkRXVlanRdData    <= axiClkRXVlanRdData_i & '0' when (Bus2IP_RdCE(18) = '1') else (others => '0');
    axiClkRXVlanWrData_i  <= Bus2IP_Data(18 to 30);
    RxClClkRXVlanRdData   <= rxClClkRxRdData_i & '0';
  end generate RX_VLAN_TRAN_STRP;

  RX_VLAN_TRAN_TAG : if (C_RXVLAN_TRAN = 1 and C_RXVLAN_STRP = 0 and C_RXVLAN_TAG = 1) generate
  begin
    axiClkRXVlanRdData    <= axiClkRXVlanRdData_i(19 to 30) & '0' & axiClkRXVlanRdData_i(31)
                              when (Bus2IP_RdCE(18) = '1') else (others => '0');
    axiClkRXVlanWrData_i  <= Bus2IP_Data(18 to 29)& Bus2IP_Data(31);
    RxClClkRXVlanRdData   <= rxClClkRxRdData_i(19 to 30) & '0' & rxClClkRxRdData_i(31);
  end generate RX_VLAN_TRAN_TAG;

  RX_VLAN_TRAN : if (C_RXVLAN_TRAN = 1 and C_RXVLAN_STRP = 0 and C_RXVLAN_TAG = 0) generate
  begin
    axiClkRXVlanRdData    <= axiClkRXVlanRdData_i(20 to 31) & "00" when (Bus2IP_RdCE(18) = '1') else (others => '0');
    axiClkRXVlanWrData_i  <= Bus2IP_Data(18 to 29);
    RxClClkRXVlanRdData   <= rxClClkRxRdData_i(20 to 31) & "00";
  end generate RX_VLAN_TRAN;

  RX_VLAN_STRP_TAG : if (C_RXVLAN_TRAN = 0 and C_RXVLAN_STRP = 1 and C_RXVLAN_TAG = 1) generate
  begin
    axiClkRXVlanRdData    <= "000000000000" & axiClkRXVlanRdData_i when (Bus2IP_RdCE(18) = '1') else (others => '0');
    axiClkRXVlanWrData_i  <= Bus2IP_Data(30 to 31);
    RxClClkRXVlanRdData   <= "000000000000" & rxClClkRxRdData_i;
  end generate RX_VLAN_STRP_TAG;

  RX_VLAN_STRP : if (C_RXVLAN_TRAN = 0 and C_RXVLAN_STRP = 1 and C_RXVLAN_TAG = 0) generate
  begin
    axiClkRXVlanRdData    <= "000000000000" & axiClkRXVlanRdData_i & '0' when (Bus2IP_RdCE(18) = '1') else (others => '0');
    axiClkRXVlanWrData_i  <= Bus2IP_Data(30 to 30);
    RxClClkRXVlanRdData   <= "000000000000" & rxClClkRxRdData_i & '0';
  end generate RX_VLAN_STRP;

  RX_VLAN_TAG : if (C_RXVLAN_TRAN = 0 and C_RXVLAN_STRP = 0 and C_RXVLAN_TAG = 1) generate
  begin
    axiClkRXVlanRdData    <= "000000000000" & '0' & axiClkRXVlanRdData_i when (Bus2IP_RdCE(18) = '1') else (others => '0');
    axiClkRXVlanWrData_i  <= Bus2IP_Data(31 to 31);
    RxClClkRXVlanRdData   <= "000000000000" & '0' & rxClClkRxRdData_i;
  end generate RX_VLAN_TAG;

  RX_VLAN_NONE : if (C_RXVLAN_TRAN = 0 and C_RXVLAN_STRP = 0 and C_RXVLAN_TAG = 0) generate
  begin
    axiClkRXVlanRdData    <= (others => '0');
    RxClClkRXVlanRdData   <= (others => '0');
  end generate RX_VLAN_NONE;

  IsRegData    <= isRegData_i;
  IeRegData    <= ieRegData_i;
  TtagRegData  <= ttagRegData_i;
  RtagRegData  <= rtagRegData_i;
  Tpid0RegData <= tpid0RegData_i;
  Tpid1RegData <= tpid1RegData_i;
  UawLRegData  <= uawLRegData_i;
  UawURegData  <= uawURegData_i;

  CR_I :  entity axi_ethernet_v3_01_a.reg_cr(imp)
    port map
    (
     Clk      => AxiClk,                -- in

     Stats_clk=> Stats_clk,
     Host_clk => Host_clk,
     TxClClk  => TxClClk,
     RxClClk  => RxClClk,

     RST      => AxiReset,              -- in
     RdCE     => Bus2IP_RdCE(0),        -- in
     WrCE     => Bus2IP_WrCE(0),        -- in
     DataIn   => Bus2IP_Data(17 to 31), -- in
     DataOut  => crRdData,              -- out
     RegData  => CrRegData              -- out
    );

  TP_I :  entity axi_ethernet_v3_01_a.reg_tp(imp)
    port map
    (
     Clk      => AxiClk,                  -- in
     RST      => AxiReset,          -- in
     RdCE     => Bus2IP_RdCE(1),  -- in
     WrCE     => Bus2IP_WrCE(1),  -- in
     DataIn   => Bus2IP_Data(16 to 31), -- in
     DataOut  => tpRdData,          -- out
     RegData  => TpRegData,         -- out
     TPReq    => TPReq            -- out
    );

  IFGP_I :  entity axi_ethernet_v3_01_a.reg_ifgp(imp)
    port map
    (
     Clk      => AxiClk,                  -- in
     RST      => AxiReset,          -- in
     RdCE     => Bus2IP_RdCE(2),  -- in
     WrCE     => Bus2IP_WrCE(2),  -- in
     DataIn   => Bus2IP_Data(24 to 31), -- in
     DataOut  => ifgpRdData,          -- out
     RegData  => IfgpRegData          -- out
    );

  IS_I :  entity axi_ethernet_v3_01_a.reg_is(imp)
    port map
    (
     Clk      => AxiClk,                  -- in
     RST      => AxiReset,          -- in
     RdCE     => Bus2IP_RdCE(3),  -- in
     WrCE     => Bus2IP_WrCE(3),  -- in
     Intrpts  => IntrptsIn,         -- in
     DataIn   => Bus2IP_Data(23 to 31), -- out
     DataOut  => isRdData,          -- out
     RegData  => isRegData_i          -- out
    );

  IP_I :  entity axi_ethernet_v3_01_a.reg_ip(imp)
    port map
    (
     Clk      => AxiClk,              -- in
     RST      => AxiReset,      -- in
     RdCE     => Bus2IP_RdCE(4),    -- in
     IsIn     => isRegData_i,     -- in
     IeIn     => ieRegData_i,     -- in
     DataOut  => ipRdData,      -- out
     RegData  => IpRegData,     -- out
     Intrpt   => IntrptOut      -- out
    );

  IE_I :  entity axi_ethernet_v3_01_a.reg_ie(imp)
    port map
    (
     Clk      => AxiClk,                  -- in
     RST      => AxiReset,          -- in
     RdCE     => Bus2IP_RdCE(5),  -- in
     WrCE     => Bus2IP_WrCE(5),  -- in
     DataIn   => Bus2IP_Data(23 to 31), -- in
     DataOut  => ieRdData,          -- out
     RegData  => ieRegData_i          -- out
    );

  TTAG_I :  entity axi_ethernet_v3_01_a.reg_32b(imp)
    port map
    (
     Clk      => AxiClk,                  -- in
     RST      => AxiReset,          -- in
     RdCE     => Bus2IP_RdCE(6),  -- in
     WrCE     => Bus2IP_WrCE(6),  -- in
     DataIn   => Bus2IP_Data(0 to 31),  -- in
     DataOut  => ttagRdData,          -- out
     RegData  => ttagRegData_i          -- out
    );

  RTAG_I :  entity axi_ethernet_v3_01_a.reg_32b(imp)
    port map
    (
     Clk      => AxiClk,                  -- in
     RST      => AxiReset,          -- in
     RdCE     => Bus2IP_RdCE(7),  -- in
     WrCE     => Bus2IP_WrCE(7),  -- in
     DataIn   => Bus2IP_Data(0 to 31),  -- in
     DataOut  => rtagRdData,          -- out
     RegData  => rtagRegData_i          -- out
    );

  UAWL_I :  entity axi_ethernet_v3_01_a.reg_32b(imp)
    port map
    (
     Clk      => AxiClk,                  -- in
     RST      => AxiReset,          -- in
     RdCE     => Bus2IP_RdCE(8),  -- in
     WrCE     => Bus2IP_WrCE(8),  -- in
     DataIn   => Bus2IP_Data(0 to 31),  -- in
     DataOut  => uawLRdData,          -- out
     RegData  => uawLRegData_i         -- out
    );

  UAWU_I :  entity axi_ethernet_v3_01_a.reg_16bl(imp)
    port map
    (
     Clk      => AxiClk,                  -- in
     RST      => AxiReset,          -- in
     RdCE     => Bus2IP_RdCE(9),  -- in
     WrCE     => Bus2IP_WrCE(9),  -- in
     DataIn   => Bus2IP_Data(16 to 31), -- in
     DataOut  => uawURdData,          -- out
     RegData  => uawURegData_i          -- out
    );

  TPID0_I :  entity axi_ethernet_v3_01_a.reg_32b(imp)
    port map
    (
     Clk      => AxiClk,                  -- in
     RST      => AxiReset,          -- in
     RdCE     => Bus2IP_RdCE(10), -- in
     WrCE     => Bus2IP_WrCE(10), -- in
     DataIn   => Bus2IP_Data(0 to 31),  -- in
     DataOut  => tpid0RdData,         -- out
     RegData  => tpid0RegData_i        -- out
    );

  TPID1_I :  entity axi_ethernet_v3_01_a.reg_32b(imp)
    port map
    (
     Clk      => AxiClk,                  -- in
     RST      => AxiReset,          -- in
     RdCE     => Bus2IP_RdCE(11), -- in
     WrCE     => Bus2IP_WrCE(11), -- in
     DataIn   => Bus2IP_Data(0 to 31),  -- in
     DataOut  => tpid1RdData,         -- out
     RegData  => tpid1RegData_i        -- out
    );


  pcspma_status <= pcspma_status_cross when Bus2IP_RdCE(12) = '1' else (others => '0');


  EXTENDED_MULTICAST : if (C_MCAST_EXTEND = 1) generate
  begin
    I_MULTICAST_MEM : entity proc_common_v3_00_a.blk_mem_gen_wrapper
      generic map(
        c_family                 => C_FAMILY,
        c_xdevicefamily          => C_FAMILY,

        -- Memory Specific Configurations
        c_mem_type               => 2,
           -- This wrapper only supports the True Dual Port RAM
           -- 0: Single Port RAM
           -- 1: Simple Dual Port RAM
           -- 2: True Dual Port RAM
           -- 3: Single Port Rom
           -- 4: Dual Port RAM
        c_algorithm              => 1,
           -- 0: Selectable Primative
           -- 1: Minimum Area
        c_prim_type              => 0,
           -- 0: ( 1-bit wide)
           -- 1: ( 2-bit wide)
           -- 2: ( 4-bit wide)
           -- 3: ( 9-bit wide)
           -- 4: (18-bit wide)
           -- 5: (36-bit wide)
           -- 6: (72-bit wide, single port only)
        c_byte_size              => 8,   -- 8 or 9

        -- Simulation Behavior Options
        c_sim_collision_check    => "NONE",
           -- "None"
           -- "Generate_X"
           -- "All"
           -- "Warnings_only"
        c_common_clk             => 0,   -- 0, 1
        c_disable_warn_bhv_coll  => 0,   -- 0, 1
        c_disable_warn_bhv_range => 0,   -- 0, 1

        -- Initialization Configuration Options
        c_load_init_file         => 0,
        c_init_file_name         => "no_coe_file_loaded",
        c_use_default_data       => 0,   -- 0, 1
        c_default_data           => "0", -- "..."

        -- Port A Specific Configurations
        c_has_mem_output_regs_a  => 0,   -- 0, 1
        c_has_mux_output_regs_a  => 0,   -- 0, 1
        c_write_width_a          => 1,  -- 1 to 1152
        c_read_width_a           => 1,  -- 1 to 1152
        c_write_depth_a          => 32768,  -- 2 to 9011200
        c_read_depth_a           => 32768,  -- 2 to 9011200
        c_addra_width            => 15,   -- 1 to 24
        c_write_mode_a           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_ena                => 1,   -- 0, 1
        c_has_regcea             => 0,   -- 0, 1
        c_has_ssra               => 0,   -- 0, 1
        c_sinita_val             => "0", --"..."
        c_use_byte_wea           => 0,   -- 0, 1
        c_wea_width              => 1,   -- 1 to 128

        -- Port B Specific Configurations
        c_has_mem_output_regs_b  => 0,   -- 0, 1
        c_has_mux_output_regs_b  => 0,   -- 0, 1
        c_write_width_b          => 1,  -- 1 to 1152
        c_read_width_b           => 1,  -- 1 to 1152
        c_write_depth_b          => 32768,  -- 2 to 9011200
        c_read_depth_b           => 32768,   -- 2 to 9011200
        c_addrb_width            => 15,   -- 1 to 24
        c_write_mode_b           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_enb                => 0,   -- 0, 1
        c_has_regceb             => 0,   -- 0, 1
        c_has_ssrb               => 0,   -- 0, 1
        c_sinitb_val             => "0", -- "..."
        c_use_byte_web           => 0,   -- 0, 1
        c_web_width              => 1,   -- 1 to 128

        -- Other Miscellaneous Configurations
        c_mux_pipeline_stages    => 0,   -- 0, 1, 2, 3
           -- The number of pipeline stages within the MUX
           --    for both Port A and Port B
        c_use_ecc                => 0,
           -- See DS512 for the limited core option selections for ECC support
        c_use_ramb16bwer_rst_bhv => 0    --0, 1
        )
      port map
        (
        clka    => RxClClk,       --: in  std_logic;
        ssra    => '0',            --: in  std_logic := '0';
        dina    => "0",            --: in  std_logic_vector(c_write_width_a-1 downto 0) := (OTHERS => '0');
        addra   => RxClClkMcastAddr,   --: in  std_logic_vector(c_addra_width-1   downto 0);
        ena     => RxClClkMcastEn,     --: in  std_logic := '1';
        regcea  => '0',            --: in  std_logic := '1';
        wea     => "0",            --: in  std_logic_vector(c_wea_width-1     downto 0) := (OTHERS => '0');
        douta   => RxClClkMcastRdData, --: out std_logic_vector(c_read_width_a-1  downto 0);

        clkb    => AxiClk,    --: in  std_logic := '0';
        ssrb    => '0',            --: in  std_logic := '0';
        dinb    => Bus2IP_Data(31 to 31),--: in  std_logic_vector(c_write_width_b-1 downto 0) := (OTHERS => '0');
        addrb   => Bus2IP_Addr(15 to 29),--: in  std_logic_vector(c_addrb_width-1   downto 0) := (OTHERS => '0');
        enb     => bus2IP_WrCE_20_en,            --: in  std_logic := '1';
        regceb  => '0',            --: in  std_logic := '1';
        web     => Bus2IP_WrCE(20 to 20),--: in  std_logic_vector(c_web_width-1     downto 0) := (OTHERS => '0');
        doutb   => AxiClkMcastRdData_i,--: out std_logic_vector(c_read_width_b-1  downto 0);

        dbiterr => open,           --: out std_logic;
           -- Double bit error that that cannot be auto corrected by ECC
        sbiterr => open            --: out std_logic
           -- Single Bit Error that has been auto corrected on the output bus
        );
    AxiClkMcastRdData(0) <= AxiClkMcastRdData_i(0) and Bus2IP_RdCE(20);
  end generate EXTENDED_MULTICAST;

  NO_EXTENDED_MULTICAST : if (C_MCAST_EXTEND = 0) generate
  begin
    RxClClkMcastRdData <= (others => '0');
    AxiClkMcastRdData  <= (others => '0');
  end generate NO_EXTENDED_MULTICAST;

  TX_VLAN_BRAM : if (C_TXVLAN_TRAN = 1 or C_TXVLAN_TAG = 1 or C_TXVLAN_STRP = 1) generate
  begin
    I_TX_VLAN_MEM : entity proc_common_v3_00_a.blk_mem_gen_wrapper
      generic map(
        c_family                 => C_FAMILY,
        c_xdevicefamily          => C_FAMILY,

        -- Memory Specific Configurations
        c_mem_type               => 2,
           -- This wrapper only supports the True Dual Port RAM
           -- 0: Single Port RAM
           -- 1: Simple Dual Port RAM
           -- 2: True Dual Port RAM
           -- 3: Single Port Rom
           -- 4: Dual Port RAM
        c_algorithm              => 1,
           -- 0: Selectable Primative
           -- 1: Minimum Area
        c_prim_type              => 3,
           -- 0: ( 1-bit wide)
           -- 1: ( 2-bit wide)
           -- 2: ( 4-bit wide)
           -- 3: ( 9-bit wide)
           -- 4: (18-bit wide)
           -- 5: (36-bit wide)
           -- 6: (72-bit wide, single port only)
        c_byte_size              => 8,   -- 8 or 9

        -- Simulation Behavior Options
        c_sim_collision_check    => "NONE",
           -- "None"
           -- "Generate_X"
           -- "All"
           -- "Warnings_only"
        c_common_clk             => 0,   -- 0, 1
        c_disable_warn_bhv_coll  => 0,   -- 0, 1
        c_disable_warn_bhv_range => 0,   -- 0, 1

        -- Initialization Configuration Options
        c_load_init_file         => 0,
        c_init_file_name         => "no_coe_file_loaded",
        c_use_default_data       => 0,   -- 0, 1
        c_default_data           => "0", -- "..."

        -- Port A Specific Configurations
        c_has_mem_output_regs_a  => 0,   -- 0, 1
        c_has_mux_output_regs_a  => 0,   -- 0, 1
        c_write_width_a          => C_TXVLAN_WIDTH,  -- 1 to 1152
        c_read_width_a           => C_TXVLAN_WIDTH,  -- 1 to 1152
        c_write_depth_a          => 4096,  -- 2 to 9011200
        c_read_depth_a           => 4096,  -- 2 to 9011200
        c_addra_width            => 12,   -- 1 to 24
        c_write_mode_a           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_ena                => 0,   -- 0, 1
        c_has_regcea             => 0,   -- 0, 1
        c_has_ssra               => 0,   -- 0, 1
        c_sinita_val             => "0", --"..."
        c_use_byte_wea           => 0,   -- 0, 1
        c_wea_width              => 1,   -- 1 to 128

        -- Port B Specific Configurations
        c_has_mem_output_regs_b  => 0,   -- 0, 1
        c_has_mux_output_regs_b  => 0,   -- 0, 1
        c_write_width_b          => C_TXVLAN_WIDTH,  -- 1 to 1152
        c_read_width_b           => C_TXVLAN_WIDTH,  -- 1 to 1152
        c_write_depth_b          => 4096,  -- 2 to 9011200
        c_read_depth_b           => 4096,   -- 2 to 9011200
        c_addrb_width            => 12,   -- 1 to 24
        c_write_mode_b           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_enb                => 0,   -- 0, 1
        c_has_regceb             => 0,   -- 0, 1
        c_has_ssrb               => 0,   -- 0, 1
        c_sinitb_val             => "0", -- "..."
        c_use_byte_web           => 0,   -- 0, 1
        c_web_width              => 1,   -- 1 to 128

        -- Other Miscellaneous Configurations
        c_mux_pipeline_stages    => 0,   -- 0, 1, 2, 3
           -- The number of pipeline stages within the MUX
           --    for both Port A and Port B
        c_use_ecc                => 0,
           -- See DS512 for the limited core option selections for ECC support
        c_use_ramb16bwer_rst_bhv => 0    --0, 1
        )
      port map
        (
        clka    => AXI_STR_TXD_ACLK,     --: in  std_logic;
        ssra    => '0',            --: in  std_logic := '0';
        dina    => txvlan_dina, --: in  std_logic_vector(c_write_width_a-1 downto 0) := (OTHERS => '0');
        addra   => AxiStrTxDClkTxVlanAddr,  --: in  std_logic_vector(c_addra_width-1   downto 0);
        ena     => AxiStrTxDClkTxVlanBramEnA,            --: in  std_logic := '1';
        regcea  => '0',            --: in  std_logic := '1';
        wea     => "0",            --: in  std_logic_vector(c_wea_width-1     downto 0) := (OTHERS => '0');
        douta   => AxiStrTxDClkTxRdData_i,--: out std_logic_vector(c_read_width_a-1  downto 0);

        clkb    => AxiClk,    --: in  std_logic := '0';
        ssrb    => '0',            --: in  std_logic := '0';
        dinb    => axiClkTxVlanWrData_i,--: in  std_logic_vector(c_write_width_b-1 downto 0) := (OTHERS => '0');
        addrb   => Bus2IP_Addr(18 to 29),--: in  std_logic_vector(c_addrb_width-1   downto 0) := (OTHERS => '0');
        enb     => bus2IP_WrCE_17_en,            --: in  std_logic := '1';
        regceb  => '0',            --: in  std_logic := '1';
        web     => Bus2IP_WrCE(17 to 17),--: in  std_logic_vector(c_web_width-1     downto 0) := (OTHERS => '0');
        doutb   => axiClkTxVlanRdData_i,--: out std_logic_vector(c_read_width_b-1  downto 0);

        dbiterr => open,           --: out std_logic;
           -- Double bit error that that cannot be auto corrected by ECC
        sbiterr => open            --: out std_logic
           -- Single Bit Error that has been auto corrected on the output bus
        );
  end generate TX_VLAN_BRAM;

  RX_VLAN_BRAM : if (C_RXVLAN_TRAN = 1 or C_RXVLAN_TAG = 1 or C_RXVLAN_STRP = 1) generate
  begin
    I_RX_VLAN_MEM : entity proc_common_v3_00_a.blk_mem_gen_wrapper
      generic map(
        c_family                 => C_FAMILY,
        c_xdevicefamily          => C_FAMILY,

        -- Memory Specific Configurations
        c_mem_type               => 2,
           -- This wrapper only supports the True Dual Port RAM
           -- 0: Single Port RAM
           -- 1: Simple Dual Port RAM
           -- 2: True Dual Port RAM
           -- 3: Single Port Rom
           -- 4: Dual Port RAM
        c_algorithm              => 1,
           -- 0: Selectable Primative
           -- 1: Minimum Area
        c_prim_type              => 3,
           -- 0: ( 1-bit wide)
           -- 1: ( 2-bit wide)
           -- 2: ( 4-bit wide)
           -- 3: ( 9-bit wide)
           -- 4: (18-bit wide)
           -- 5: (36-bit wide)
           -- 6: (72-bit wide, single port only)
        c_byte_size              => 8,   -- 8 or 9

        -- Simulation Behavior Options
        c_sim_collision_check    => "NONE",
           -- "None"
           -- "Generate_X"
           -- "All"
           -- "Warnings_only"
        c_common_clk             => 0,   -- 0, 1
        c_disable_warn_bhv_coll  => 0,   -- 0, 1
        c_disable_warn_bhv_range => 0,   -- 0, 1

        -- Initialization Configuration Options
        c_load_init_file         => 0,
        c_init_file_name         => "no_coe_file_loaded",
        c_use_default_data       => 0,   -- 0, 1
        c_default_data           => "0", -- "..."

        -- Port A Specific Configurations
        c_has_mem_output_regs_a  => 0,   -- 0, 1
        c_has_mux_output_regs_a  => 0,   -- 0, 1
        c_write_width_a          => C_RXVLAN_WIDTH,  -- 1 to 1152
        c_read_width_a           => C_RXVLAN_WIDTH,  -- 1 to 1152
        c_write_depth_a          => 4096,  -- 2 to 9011200
        c_read_depth_a           => 4096,  -- 2 to 9011200
        c_addra_width            => 12,   -- 1 to 24
        c_write_mode_a           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_ena                => 0,   -- 0, 1
        c_has_regcea             => 0,   -- 0, 1
        c_has_ssra               => 0,   -- 0, 1
        c_sinita_val             => "0", --"..."
        c_use_byte_wea           => 0,   -- 0, 1
        c_wea_width              => 1,   -- 1 to 128

        -- Port B Specific Configurations
        c_has_mem_output_regs_b  => 0,   -- 0, 1
        c_has_mux_output_regs_b  => 0,   -- 0, 1
        c_write_width_b          => C_RXVLAN_WIDTH,  -- 1 to 1152
        c_read_width_b           => C_RXVLAN_WIDTH,  -- 1 to 1152
        c_write_depth_b          => 4096,  -- 2 to 9011200
        c_read_depth_b           => 4096,   -- 2 to 9011200
        c_addrb_width            => 12,   -- 1 to 24
        c_write_mode_b           => "NO_CHANGE",
           -- "Write_First"
           -- "Read_first"
           -- "No_Change"
        c_has_enb                => 0,   -- 0, 1
        c_has_regceb             => 0,   -- 0, 1
        c_has_ssrb               => 0,   -- 0, 1
        c_sinitb_val             => "0", -- "..."
        c_use_byte_web           => 0,   -- 0, 1
        c_web_width              => 1,   -- 1 to 128

        -- Other Miscellaneous Configurations
        c_mux_pipeline_stages    => 0,   -- 0, 1, 2, 3
           -- The number of pipeline stages within the MUX
           --    for both Port A and Port B
        c_use_ecc                => 0,
           -- See DS512 for the limited core option selections for ECC support
        c_use_ramb16bwer_rst_bhv => 0    --0, 1
        )
      port map
        (
        clka    => RxClClk,     --: in  std_logic;
        ssra    => '0',            --: in  std_logic := '0';
        dina    => rxvlan_dina, --: in  std_logic_vector(c_write_width_a-1 downto 0) := (OTHERS => '0');
        addra   => RxClClkRxVlanAddr,  --: in  std_logic_vector(c_addra_width-1   downto 0);
        ena     => RxClClkRxVlanBramEnA,            --: in  std_logic := '1';
        regcea  => '0',            --: in  std_logic := '1';
        wea     => "0",            --: in  std_logic_vector(c_wea_width-1     downto 0) := (OTHERS => '0');
        douta   => rxClClkRxRdData_i,--: out std_logic_vector(c_read_width_a-1  downto 0);

        clkb    => AxiClk,    --: in  std_logic := '0';
        ssrb    => '0',            --: in  std_logic := '0';
        dinb    => axiClkRXVlanWrData_i,--: in  std_logic_vector(c_write_width_b-1 downto 0) := (OTHERS => '0');
        addrb   => Bus2IP_Addr(18 to 29),--: in  std_logic_vector(c_addrb_width-1   downto 0) := (OTHERS => '0');
        enb     => bus2IP_WrCE_18_en,            --: in  std_logic := '1';
        regceb  => '0',            --: in  std_logic := '1';
        web     => Bus2IP_WrCE(18 to 18),--: in  std_logic_vector(c_web_width-1     downto 0) := (OTHERS => '0');
        doutb   => axiClkRXVlanRdData_i,--: out std_logic_vector(c_read_width_b-1  downto 0);

        dbiterr => open,           --: out std_logic;
           -- Double bit error that that cannot be auto corrected by ECC
        sbiterr => open            --: out std_logic
           -- Single Bit Error that has been auto corrected on the output bus
        );
  end generate RX_VLAN_BRAM;

  RD_ACK_BLOCKER_PROCESS : process (AxiClk,AxiReset)
  begin
    if (AxiClk'event and AxiClk = '1') then
      if (AxiReset = '1') then
        rdAckBlocker <= '0';
      else
        rdAckBlocker <= (softRead_d1) or  -- set when = '1'
                        (rdAckBlocker and -- hold  when = '1'
                        (softRead_d1));   -- clear when = '0'
      end if;
    end if;
  end process;

  WR_ACK_BLOCKER_PROCESS : process (AxiClk,AxiReset)
  begin
    if (AxiClk'event and AxiClk = '1') then
      if (AxiReset = '1') then
        wrAckBlocker <= '0';
      else
        wrAckBlocker <= (softWrite_d1) or -- set when = '1'
                        (wrAckBlocker and -- hold  when = '1'
                        (softWrite_d1));  -- clear when = '0'
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------
  -- ACK_PROCESS
  --------------------------------------------------------------------------
  ACK_PROCESS : process (AxiReset, AxiClk)
  begin
    if (AxiClk'event and AxiClk = '1') then
      if (AxiReset = '1') then
        softRead_d1  <= '0';
        softWrite_d1 <= '0';
        iP2Bus_WrAck_i  <= '0';
        iP2Bus_RdAck_i  <= '0';
      else
        softRead_d1  <= softRead;
        softWrite_d1 <= softWrite;
        iP2Bus_WrAck_i  <= ( softWrite_d1) and not(wrAckBlocker);
        iP2Bus_RdAck_i  <= ( softRead_d1) and not(rdAckBlocker);
      end if;
    end if;
  end process;

  softRead    <= Bus2IP_RdCE(0) or
                 Bus2IP_RdCE(1) or
                 Bus2IP_RdCE(2) or
                 Bus2IP_RdCE(3) or
                 Bus2IP_RdCE(4) or
                 Bus2IP_RdCE(5) or
                 Bus2IP_RdCE(6) or
                 Bus2IP_RdCE(7) or
                 Bus2IP_RdCE(8) or
                 Bus2IP_RdCE(9) or
                 Bus2IP_RdCE(10) or
                 Bus2IP_RdCE(11) or
                 Bus2IP_RdCE(12) or
                 Bus2IP_RdCE(17) or
                 Bus2IP_RdCE(18) or
                 Bus2IP_RdCE(20);
  softWrite   <= Bus2IP_WrCE(0) or
                 Bus2IP_WrCE(1) or
                 Bus2IP_WrCE(2) or
                 Bus2IP_WrCE(3) or
                 Bus2IP_WrCE(4) or
                 Bus2IP_WrCE(5) or
                 Bus2IP_WrCE(6) or
                 Bus2IP_WrCE(7) or
                 Bus2IP_WrCE(8) or
                 Bus2IP_WrCE(9) or
                 Bus2IP_WrCE(10) or
                 Bus2IP_WrCE(11) or
                 Bus2IP_WrCE(17) or
                 Bus2IP_WrCE(18) or
                 Bus2IP_WrCE(20);

  rdData  <= (
              ("00000000000000000" & crRdData) or
              ("0000000000000000" & tpRdData) or
              ("000000000000000000000000" & ifgpRdData)or
              ("00000000000000000000000" & isRdData) or
              ("00000000000000000000000" & ieRdData) or
              ("00000000000000000000000" & ipRdData) or
              ttagRdData or
              rtagRdData or
              tpid0RdData or
              tpid1RdData or
              ("0000000000000000" & pcspma_status) or
              uawLRdData or
              ("0000000000000000" & uawURdData) or
              ("0000000000000000000000000000000" & AxiClkMcastRdData) or
              ("000000000000000000" & axiClkTxVlanRdData) or
              ("000000000000000000" & axiClkRXVlanRdData)
             );

  --------------------------------------------------------------------------
  -- ACK_RD_DATA_PROCESS
  --------------------------------------------------------------------------
  ACK_RD_DATA_PROCESS : process (AxiReset, AxiClk)
  begin
    if (AxiClk'event and AxiClk = '1') then
      if (AxiReset = '1') then
        IP2Bus_WrAck <= '0';
        IP2Bus_RdAck <= '0';
        IP2Bus_Data  <= (others => '0');
      else
        IP2Bus_WrAck <= iP2Bus_WrAck_i;
        IP2Bus_RdAck <= iP2Bus_RdAck_i;
        IP2Bus_Data  <= rdData;
      end if;
    end if;
  end process;

end imp;
