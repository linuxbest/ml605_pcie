-------------------------------------------------------------------------------
-- tx_csum_if - entity/architecture pair
-------------------------------------------------------------------------------
--
-- (c) Copyright 2010 - 2010 Xilinx, Inc. All rights reserved.
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
-------------------------------------------------------------------------------
-- Filename:        tx_csum_if.vhd
-- Version:         v1.00a
-- Description:     top level of embedded ip Ethernet MAC interface
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   This section shows the hierarchical structure of axi_ethernet.
--
--              axi_ethernet.vhd
--                axi_ethernt_soft_temac_wrap.vhd
--                axi_lite_ipif.vhd
--                embedded_top.vhd
--                  tx_if.vhd
--                    tx_axistream_if.vhd
--          ->          tx_csum_if.vhd
--                    tx_mem_if
--                    tx_emac_if.vhd

--
-------------------------------------------------------------------------------
-- Author:          MW
--
--  MW     07/01/10
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
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;



-------------------------------------------------------------------------------
--                  Entity Section
-------------------------------------------------------------------------------

entity tx_csum_if is
  generic (
    C_FAMILY               : string                       := "virtex6";
    C_TYPE                 : integer range 0 to 2         := 0;
    C_PHY_TYPE             : integer range 0 to 7         := 1;
    C_HALFDUP              : integer range 0 to 1         := 0;
    C_TXCSUM               : integer range 0 to 2         := 0;
    C_TXMEM                : integer                      := 4096;
    C_TXVLAN_TRAN          : integer range 0 to 1         := 0;
    C_TXVLAN_TAG           : integer range 0 to 1         := 0;
    C_TXVLAN_STRP          : integer range 0 to 1         := 0;
    C_S_AXI_ADDR_WIDTH     : integer range 32 to 32       := 32;
    C_S_AXI_DATA_WIDTH     : integer range 32 to 32       := 32;

    -- Write Port - AXI Stream TxData
    c_TxD_write_width_b    : integer range  36 to 36     := 36;
    c_TxD_read_width_b     : integer range  36 to 36     := 36;
    c_TxD_write_depth_b    : integer range   0 to 8192   := 4096;
    c_TxD_read_depth_b     : integer range   0 to 8192   := 4096;
    c_TxD_addrb_width      : integer range   0 to 13     := 10;
    c_TxD_web_width        : integer range   0 to 4      := 4;

    -- Write Port - AXI Stream TxControl
    c_TxC_write_width_b    : integer range   36 to 36    := 36;
    c_TxC_read_width_b     : integer range   36 to 36    := 36;
    c_TxC_write_depth_b    : integer range    0 to 1024  := 1024;
    c_TxC_read_depth_b     : integer range    0 to 1024  := 1024;
    c_TxC_addrb_width      : integer range    0 to 10    := 10;
    c_TxC_web_width        : integer range    0 to 1     := 1
  );
  port (

    tx_init_in_prog        : out std_logic;                                         --  Tx is Initializing after a reset

    -- AXI Stream Data signals
    AXI_STR_TXD_ACLK       : in  std_logic;                                         --  AXI-Stream Transmit Data Clk
    reset2axi_str_txd      : in  std_logic;                                         --  AXI-Stream Transmit Data Reset
    AXI_STR_TXD_TVALID     : in  std_logic;                                         --  AXI-Stream Transmit Data Valid
    AXI_STR_TXD_TREADY     : out std_logic;                                         --  AXI-Stream Transmit Data Ready
    AXI_STR_TXD_TLAST      : in  std_logic;                                         --  AXI-Stream Transmit Data Last
    AXI_STR_TXD_TSTRB      : in  std_logic_vector(3 downto 0);                      --  AXI-Stream Transmit Data Keep
    AXI_STR_TXD_TDATA      : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);   --  AXI-Stream Transmit Data Data
    -- AXI Stream Control signals
    AXI_STR_TXC_ACLK       : in  std_logic;                                         --  AXI-Stream Transmit Control Clk
    reset2axi_str_txc      : in  std_logic;                                         --  AXI-Stream Transmit Control Reset
    AXI_STR_TXC_TVALID     : in  std_logic;                                         --  AXI-Stream Transmit Control Valid
    AXI_STR_TXC_TREADY     : out std_logic;                                         --  AXI-Stream Transmit Control Ready
    AXI_STR_TXC_TLAST      : in  std_logic;                                         --  AXI-Stream Transmit Control Last
    AXI_STR_TXC_TSTRB      : in  std_logic_vector(3 downto 0);                      --  AXI-Stream Transmit Control Keep
    AXI_STR_TXC_TDATA      : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);   --  AXI-Stream Transmit Control Data

    -- Write Port - AXI Stream TxData
    Axi_Str_TxD_2_Mem_Din  : out std_logic_vector(c_TxD_write_width_b-1 downto 0);  --  Tx AXI-Stream Data to Memory Wr Din
    Axi_Str_TxD_2_Mem_Addr : out std_logic_vector(c_TxD_addrb_width-1   downto 0);  --  Tx AXI-Stream Data to Memory Wr Addr
    Axi_Str_TxD_2_Mem_En   : out std_logic;                                         --  Tx AXI-Stream Data to Memory Enable
    Axi_Str_TxD_2_Mem_We   : out std_logic_vector(c_TxD_web_width-1     downto 0);  --  Tx AXI-Stream Data to Memory Wr En
    Axi_Str_TxD_2_Mem_Dout : in  std_logic_vector(c_TxD_read_width_b-1  downto 0);  --  Tx AXI-Stream Data to Memory Not Used

    -- Write Port - AXI Stream TxControl
    Axi_Str_TxC_2_Mem_Din  : out std_logic_vector(c_TxC_write_width_b-1 downto 0);  --  Tx AXI-Stream Control to Memory Wr Din
    Axi_Str_TxC_2_Mem_Addr : out std_logic_vector(c_TxC_addrb_width-1   downto 0);  --  Tx AXI-Stream Control to Memory Wr Addr
    Axi_Str_TxC_2_Mem_En   : out std_logic;                                         --  Tx AXI-Stream Control to Memory Enable
    Axi_Str_TxC_2_Mem_We   : out std_logic_vector(c_TxC_web_width-1     downto 0);  --  Tx AXI-Stream Control to Memory Wr En
    Axi_Str_TxC_2_Mem_Dout : in  std_logic_vector(c_TxC_read_width_b-1  downto 0)   --  Tx AXI-Stream Control to Memory Full Flag

  );

end tx_csum_if;
------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of tx_csum_if is
begin

-------------------------------------------------------------------------------
--  Start Partial CSUM
-------------------------------------------------------------------------------
GEN_CSUM_PARTIAL : if (C_TXCSUM  = 1 and (C_TXVLAN_TRAN = 0 and C_TXVLAN_TAG = 0 and C_TXVLAN_STRP = 0)) generate
begin

  TX_CSUM_PARTIAL_INTERFACE : entity axi_ethernet_v3_01_a.tx_csum_partial_if(rtl)
  --  Interface for Transmit AxiStream Data and Control; and Tx Memory
  generic map (
    C_FAMILY               => C_FAMILY,
    C_TYPE                 => C_TYPE,
    C_PHY_TYPE             => C_PHY_TYPE,
    C_HALFDUP              => C_HALFDUP,
    C_TXCSUM               => C_TXCSUM,
    C_TXMEM                => C_TXMEM,
    C_TXVLAN_TRAN          => C_TXVLAN_TRAN,
    C_TXVLAN_TAG           => C_TXVLAN_TAG,
    C_TXVLAN_STRP          => C_TXVLAN_STRP,
    C_S_AXI_ADDR_WIDTH     => C_S_AXI_ADDR_WIDTH,
    C_S_AXI_DATA_WIDTH     => C_S_AXI_DATA_WIDTH,

    -- Write Port - AXI Stream TxData
    c_TxD_write_width_b    => c_TxD_write_width_b,
    c_TxD_read_width_b     => c_TxD_read_width_b,
    c_TxD_write_depth_b    => c_TxD_write_depth_b,
    c_TxD_read_depth_b     => c_TxD_read_depth_b,
    c_TxD_addrb_width      => c_TxD_addrb_width,
    c_TxD_web_width        => c_TxD_web_width,

    -- Write Port - AXI Stream TxControl
    c_TxC_write_width_b    => c_TxC_write_width_b,
    c_TxC_read_width_b     => c_TxC_read_width_b,
    c_TxC_write_depth_b    => c_TxC_write_depth_b,
    c_TxC_read_depth_b     => c_TxC_read_depth_b,
    c_TxC_addrb_width      => c_TxC_addrb_width,
    c_TxC_web_width        => c_TxC_web_width

  )
  port map  (

    tx_init_in_prog        => tx_init_in_prog,

    -- AXI Stream Data signals
    AXI_STR_TXD_ACLK       => AXI_STR_TXD_ACLK,
    reset2axi_str_txd      => reset2axi_str_txd,
    AXI_STR_TXD_TVALID     => AXI_STR_TXD_TVALID,
    AXI_STR_TXD_TREADY     => AXI_STR_TXD_TREADY,
    AXI_STR_TXD_TLAST      => AXI_STR_TXD_TLAST,
    AXI_STR_TXD_TSTRB      => AXI_STR_TXD_TSTRB,
    AXI_STR_TXD_TDATA      => AXI_STR_TXD_TDATA,
    -- AXI Stream Control signals
    AXI_STR_TXC_ACLK       => AXI_STR_TXC_ACLK,
    reset2axi_str_txc      => reset2axi_str_txc,
    AXI_STR_TXC_TVALID     => AXI_STR_TXC_TVALID,
    AXI_STR_TXC_TREADY     => AXI_STR_TXC_TREADY,
    AXI_STR_TXC_TLAST      => AXI_STR_TXC_TLAST,
    AXI_STR_TXC_TSTRB      => AXI_STR_TXC_TSTRB,
    AXI_STR_TXC_TDATA      => AXI_STR_TXC_TDATA,

    -- Write Port - AXI Stream TxData
    Axi_Str_TxD_2_Mem_Din  => Axi_Str_TxD_2_Mem_Din,       --: out std_logic_vector(c_TxD_write_width_b-1 downto 0);
    Axi_Str_TxD_2_Mem_Addr => Axi_Str_TxD_2_Mem_Addr,      --: out std_logic_vector(c_TxD_addrb_width-1   downto 0);
    Axi_Str_TxD_2_Mem_En   => Axi_Str_TxD_2_Mem_En,        --: out std_logic := '1';
    Axi_Str_TxD_2_Mem_We   => Axi_Str_TxD_2_Mem_We,        --: out std_logic_vector(c_TxD_web_width-1     downto 0);
    Axi_Str_TxD_2_Mem_Dout => Axi_Str_TxD_2_Mem_Dout,      --: in  std_logic_vector(c_TxD_read_width_b-1  downto 0);

    -- Write Port - AXI Stream TxControl
    Axi_Str_TxC_2_Mem_Din  => Axi_Str_TxC_2_Mem_Din,       --: out std_logic_vector(c_TxD_write_width_b-1 downto 0);
    Axi_Str_TxC_2_Mem_Addr => Axi_Str_TxC_2_Mem_Addr,      --: out std_logic_vector(c_TxD_addrb_width-1   downto 0);
    Axi_Str_TxC_2_Mem_En   => Axi_Str_TxC_2_Mem_En,        --: out std_logic := '1';
    Axi_Str_TxC_2_Mem_We   => Axi_Str_TxC_2_Mem_We,        --: out std_logic_vector(c_TxD_web_width-1     downto 0);
    Axi_Str_TxC_2_Mem_Dout => Axi_Str_TxC_2_Mem_Dout       --: in  std_logic_vector(c_TxD_read_width_b-1  downto 0);

  );
end generate GEN_CSUM_PARTIAL;
-------------------------------------------------------------------------------
--  End Partial CSUM
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
--  Start FULL CSUM
-------------------------------------------------------------------------------
GEN_CSUM_FULL : if (C_TXCSUM  = 2 and (C_TXVLAN_TRAN = 0 and C_TXVLAN_TAG = 0 and C_TXVLAN_STRP = 0)) generate
begin

  TX_CSUM_FULL_INTERFACE : entity axi_ethernet_v3_01_a.tx_csum_full_if(rtl)
  --  Interface for Transmit AxiStream Data and Control; and Tx Memory
  generic map (
    C_FAMILY               => C_FAMILY,
    C_TYPE                 => C_TYPE,
    C_PHY_TYPE             => C_PHY_TYPE,
    C_HALFDUP              => C_HALFDUP,
    C_TXCSUM               => C_TXCSUM,
    C_TXMEM                => C_TXMEM,
    C_TXVLAN_TRAN          => C_TXVLAN_TRAN,
    C_TXVLAN_TAG           => C_TXVLAN_TAG,
    C_TXVLAN_STRP          => C_TXVLAN_STRP,
    C_S_AXI_ADDR_WIDTH     => C_S_AXI_ADDR_WIDTH,
    C_S_AXI_DATA_WIDTH     => C_S_AXI_DATA_WIDTH,

    -- Write Port - AXI Stream TxData
    c_TxD_write_width_b    => c_TxD_write_width_b,
    c_TxD_read_width_b     => c_TxD_read_width_b,
    c_TxD_write_depth_b    => c_TxD_write_depth_b,
    c_TxD_read_depth_b     => c_TxD_read_depth_b,
    c_TxD_addrb_width      => c_TxD_addrb_width,
    c_TxD_web_width        => c_TxD_web_width,

    -- Write Port - AXI Stream TxControl
    c_TxC_write_width_b    => c_TxC_write_width_b,
    c_TxC_read_width_b     => c_TxC_read_width_b,
    c_TxC_write_depth_b    => c_TxC_write_depth_b,
    c_TxC_read_depth_b     => c_TxC_read_depth_b,
    c_TxC_addrb_width      => c_TxC_addrb_width,
    c_TxC_web_width        => c_TxC_web_width

  )
  port map  (

    tx_init_in_prog        => tx_init_in_prog,

    -- AXI Stream Data signals
    AXI_STR_TXD_ACLK       => AXI_STR_TXD_ACLK,
    reset2axi_str_txd      => reset2axi_str_txd,
    AXI_STR_TXD_TVALID     => AXI_STR_TXD_TVALID,
    AXI_STR_TXD_TREADY     => AXI_STR_TXD_TREADY,
    AXI_STR_TXD_TLAST      => AXI_STR_TXD_TLAST,
    AXI_STR_TXD_TSTRB      => AXI_STR_TXD_TSTRB,
    AXI_STR_TXD_TDATA      => AXI_STR_TXD_TDATA,
    -- AXI Stream Control signals
    AXI_STR_TXC_ACLK       => AXI_STR_TXC_ACLK,
    reset2axi_str_txc      => reset2axi_str_txc,
    AXI_STR_TXC_TVALID     => AXI_STR_TXC_TVALID,
    AXI_STR_TXC_TREADY     => AXI_STR_TXC_TREADY,
    AXI_STR_TXC_TLAST      => AXI_STR_TXC_TLAST,
    AXI_STR_TXC_TSTRB      => AXI_STR_TXC_TSTRB,
    AXI_STR_TXC_TDATA      => AXI_STR_TXC_TDATA,

    -- Write Port - AXI Stream TxData
    Axi_Str_TxD_2_Mem_Din  => Axi_Str_TxD_2_Mem_Din,       --: out std_logic_vector(c_TxD_write_width_b-1 downto 0);
    Axi_Str_TxD_2_Mem_Addr => Axi_Str_TxD_2_Mem_Addr,      --: out std_logic_vector(c_TxD_addrb_width-1   downto 0);
    Axi_Str_TxD_2_Mem_En   => Axi_Str_TxD_2_Mem_En,        --: out std_logic := '1';
    Axi_Str_TxD_2_Mem_We   => Axi_Str_TxD_2_Mem_We,        --: out std_logic_vector(c_TxD_web_width-1     downto 0);
    Axi_Str_TxD_2_Mem_Dout => Axi_Str_TxD_2_Mem_Dout,      --: in  std_logic_vector(c_TxD_read_width_b-1  downto 0);

    -- Write Port - AXI Stream TxControl
    Axi_Str_TxC_2_Mem_Din  => Axi_Str_TxC_2_Mem_Din,       --: out std_logic_vector(c_TxD_write_width_b-1 downto 0);
    Axi_Str_TxC_2_Mem_Addr => Axi_Str_TxC_2_Mem_Addr,      --: out std_logic_vector(c_TxD_addrb_width-1   downto 0);
    Axi_Str_TxC_2_Mem_En   => Axi_Str_TxC_2_Mem_En,        --: out std_logic := '1';
    Axi_Str_TxC_2_Mem_We   => Axi_Str_TxC_2_Mem_We,        --: out std_logic_vector(c_TxD_web_width-1     downto 0);
    Axi_Str_TxC_2_Mem_Dout => Axi_Str_TxC_2_Mem_Dout       --: in  std_logic_vector(c_TxD_read_width_b-1  downto 0);

  );
end generate GEN_CSUM_FULL;
-------------------------------------------------------------------------------
--  End FULL CSUM
-------------------------------------------------------------------------------


end rtl;
