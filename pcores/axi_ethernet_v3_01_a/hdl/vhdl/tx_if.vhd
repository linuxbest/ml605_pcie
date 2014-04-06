-------------------------------------------------------------------------------
-- tx_if - entity/architecture pair
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
-- Filename:        tx_if.vhd
-- Version:         v1.00a
-- Description:     top level of embedded ip AXI Stream Transmit interface
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   This section shows the hierarchical structure of axi_ethernet.
--
--              axi_ethernet.vhd
--                axi_ethernt_soft_temac_wrap.vhd
--                axi_lite_ipif.vhd
--                embedded_top.vhd
--          ->      tx_if.vhd
--                    tx_axistream_if.vhd
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

library proc_common_v3_00_a;
use proc_common_v3_00_a.blk_mem_gen_wrapper;
use proc_common_v3_00_a.proc_common_pkg.log2;
use proc_common_v3_00_a.family_support.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;



-------------------------------------------------------------------------------
--                  Entity Section
-------------------------------------------------------------------------------

entity tx_if is
  generic (
    C_FAMILY               : string                        := "virtex6";
    C_TYPE                 : integer range 0 to 2          := 0;
    C_PHY_TYPE             : integer range 0 to 7          := 1;
    C_HALFDUP              : integer range 0 to 1          := 0;
    C_TXCSUM               : integer range 0 to 2          := 0;
    C_TXMEM                : integer                       := 4096;
    C_TXVLAN_TRAN          : integer range 0 to 1          := 0;
    C_TXVLAN_TAG           : integer range 0 to 1          := 0;
    C_TXVLAN_STRP          : integer range 0 to 1          := 0;
    C_STATS                : integer range 0 to 1          := 0;    
    C_AVB                  : integer range 0 to 1          := 0;    
    C_S_AXI_ADDR_WIDTH     : integer range 32 to 32        := 32;
    C_S_AXI_DATA_WIDTH     : integer range 32 to 32        := 32;
    C_CLIENT_WIDTH         : integer                       := 8
  );
  port (

    -- AXI Stream Data signals
    AXI_STR_TXD_ACLK                 : in  std_logic;                                     --  AXI-Stream Transmit Data Clk
    reset2axi_str_txd                : in  std_logic;                                     --  AXI-Stream Transmit Data Reset
    AXI_STR_TXD_TVALID               : in  std_logic;                                     --  AXI-Stream Transmit Data Valid
    AXI_STR_TXD_TREADY               : out std_logic;                                     --  AXI-Stream Transmit Data Ready
    AXI_STR_TXD_TLAST                : in  std_logic;                                     --  AXI-Stream Transmit Data Last
    AXI_STR_TXD_TSTRB                : in  std_logic_vector(3 downto 0);                  --  AXI-Stream Transmit Data Keep
    AXI_STR_TXD_TDATA                : in  std_logic_vector(31 downto 0);                 --  AXI-Stream Transmit Data Data
    -- AXI Stream Control signals
    AXI_STR_TXC_ACLK                 : in  std_logic;                                     --  AXI-Stream Transmit Control Clk
    reset2axi_str_txc                : in  std_logic;                                     --  AXI-Stream Transmit Control Reset
    AXI_STR_TXC_TVALID               : in  std_logic;                                     --  AXI-Stream Transmit Control Valid
    AXI_STR_TXC_TREADY               : out std_logic;                                     --  AXI-Stream Transmit Control Ready
    AXI_STR_TXC_TLAST                : in  std_logic;                                     --  AXI-Stream Transmit Control Last
    AXI_STR_TXC_TSTRB                : in  std_logic_vector(3 downto 0);                  --  AXI-Stream Transmit Control Keep
    AXI_STR_TXC_TDATA                : in  std_logic_vector(31 downto 0);                 --  AXI-Stream Transmit Control Data

    -- VLAN Interface
    tx_vlan_bram_addr                : out std_logic_vector(11 downto 0);                 --  Transmit VLAN BRAM Addr
    tx_vlan_bram_din                 : in  std_logic_vector(13 downto 0);                 --  Transmit VLAN BRAM Rd Data
    tx_vlan_bram_en                  : out std_logic;                                     --  Transmit VLAN BRAM Enable

    enable_newFncEn                  : out std_logic; --Only perform VLAN when FLAG = 0xA --  Enable Extended VLAN Functions
    transMode_cross                  : in  std_logic;                                     --  VLAN Translation Mode Control Bit
    tagMode_cross                    : in  std_logic_vector( 1 downto 0);                 --  VLAN TAG Mode Control Bits
    strpMode_cross                   : in  std_logic_vector( 1 downto 0);                 --  VLAN Strip Mode Control Bits

    tpid0_cross                      : in  std_logic_vector(15 downto 0);                 --  VLAN TPID
    tpid1_cross                      : in  std_logic_vector(15 downto 0);                 --  VLAN TPID
    tpid2_cross                      : in  std_logic_vector(15 downto 0);                 --  VLAN TPID
    tpid3_cross                      : in  std_logic_vector(15 downto 0);                 --  VLAN TPID

    newTagData_cross                 : in  std_logic_vector(31 downto 0);                 --  VLAN Tag Data

    tx_init_in_prog                  : out std_logic;                                     --  Tx is Initializing after a reset
    tx_init_in_prog_cross            : in  std_logic;                                     --  Tx is Initializing after a reset



    tx_mac_aclk                      : in  std_logic;                                 --  Tx AXI-Stream clock in
    tx_reset                         : in  std_logic;                                 --  take to reset combiner
    tx_axis_mac_tdata                : out std_logic_vector(7 downto 0);              --  Tx AXI-Stream data
    tx_axis_mac_tvalid               : out std_logic;                                 --  Tx AXI-Stream valid
    tx_axis_mac_tlast                : out std_logic;                                 --  Tx AXI-Stream last
    tx_axis_mac_tuser                : out std_logic;                  -- this is always driven low since an underflow cannot occur
    tx_axis_mac_tready               : in  std_logic;                                 --  Tx AXI-Stream ready in from TEMAC
    tx_collision                     : in  std_logic;                                 --  collision not used
    tx_retransmit                    : in  std_logic;                                 -- retransmit not used
                                                                        
    tx_client_10_100                 : in  std_logic;                                 --  Tx Client CE Toggles Indicator
    tx_cmplt                         : out std_logic;                                 -- transmit is complete indicator
    
    tx_avb_en                        : in  std_logic;                                 -- added for avb connection 03/21/2011 
    
  -- Legacy transmitter interface
    legacy_tx_data                   : out std_logic_vector(7 downto 0);              -- legacy tx data
    legacy_tx_data_valid             : out std_logic;                                 -- legacy tx data valid
    legacy_tx_underrun               : out std_logic;                                 -- legacy tx underrun
    legacy_tx_ack                    : in  std_logic                                  -- legacy tx ack
  );

end tx_if;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture imp of tx_if is

  component axi_ethernet_v3_01_a_tx_axi_intf
    port (
      tx_clk          : in  std_logic;                        --  Transmit Clk
      tx_reset        : in  std_logic;                        --  Transmit reset
      tx_enable       : in  std_logic;                        --  Transmit enable
      --------------------------------------------------------------------
      -- AXI Interface
      --------------------------------------------------------------------
      tx_mac_tdata    : in  std_logic_vector(7 downto 0);     --  Transmit Data from AXI-Stream
      tx_mac_tvalid   : in  std_logic;                        --  Transmit VALID from AXI-Stream
      tx_mac_tlast    : in  std_logic;                        --  Transmit Last from AXI-Stream
      tx_mac_tuser    : in  std_logic;                        --  Transmit User from AXI-Stream
      tx_mac_tready   : out std_logic;                        --  Transmit Ready to AXI-Stream
      --------------------------------------------------------------------
      -- Ethernet MAC TX Client Interface
      --------------------------------------------------------------------
      tx_enable_out   : out std_logic;                        --  Transmit Enable Out
      tx_continuation : out std_logic;                        --  Transmit Continuation
      tx_data         : out std_logic_vector(7 downto 0);     --  Transmit Data
      tx_data_valid   : out std_logic;                        --  Transmit Data Valid
      tx_underrun     : out std_logic;                        --  Transmit Underrun
      tx_ack          : in  std_logic                         --  Transmit Acknowledge
    );
  end component;
  
  signal tx_axis_mac_tdata_int   : std_logic_vector(7 downto 0);
  signal tx_axis_mac_tvalid_int  : std_logic;                   
  signal tx_axis_mac_tlast_int   : std_logic;                   
  signal tx_axis_mac_tuser_int   : std_logic;                   
  signal tx_axis_mac_tready_int  : std_logic;                   
  signal tx_collision_int        : std_logic;                   
  signal tx_retransmit_int       : std_logic;  
   
  signal tx_avb_en_out           : std_logic;            



begin

  GEN_TXDIF_MEM_PARAM_S6CLIENT8: if (
                                     (equalIgnoringCase(get_root_family(C_FAMILY), "spartan6")=TRUE) and
                                     (C_PHY_TYPE = 0 or C_PHY_TYPE = 1 or
                                      C_PHY_TYPE = 2 or C_PHY_TYPE = 3 or
                                      C_PHY_TYPE = 4 or C_PHY_TYPE = 5 )
                                                                        ) generate

      -- Read Port - AXI Stream Data
    constant c_TxD_write_width_a     : integer range  0 to 18       := (C_S_AXI_DATA_WIDTH + 4)/4;
    constant c_TxD_read_width_a      : integer range  0 to 18       := (C_S_AXI_DATA_WIDTH + 4)/4;
    constant c_TxD_write_depth_a     : integer range  0 to 32768    := C_TXMEM;
    constant c_TxD_read_depth_a      : integer range  0 to 32768    := C_TXMEM;
    constant c_TxD_addra_width       : integer range  0 to 15       := log2(C_TXMEM);
    constant c_TxD_wea_width         : integer range  0 to 2        := 1;
    --Write Port - AXI Stream Data
    constant c_TxD_write_width_b     : integer range 36 to 36       := C_S_AXI_DATA_WIDTH + 4;
    constant c_TxD_read_width_b      : integer range 36 to 36       := C_S_AXI_DATA_WIDTH + 4;
    constant c_TxD_write_depth_b     : integer range  0 to 8192     := C_TXMEM/4;
    constant c_TxD_read_depth_b      : integer range  0 to 8192     := C_TXMEM/4;
    constant c_TxD_addrb_width       : integer range  0 to 13       := log2(C_TXMEM/4);
    constant c_TxD_web_width         : integer range  0 to 4        := 4;

    --Read Port - AXI Stream Data
    signal Tx_Client_TxD_2_Mem_Din   : std_logic_vector(c_TxD_write_width_a -1 downto 0);
    signal Tx_Client_TxD_2_Mem_Addr  : std_logic_vector(c_TxD_addra_width   -1 downto 0);
    signal Tx_Client_TxD_2_Mem_Dout  : std_logic_vector(c_TxD_read_width_a  -1 downto 0);
    signal Tx_Client_TxD_2_Mem_En    : std_logic;
    signal Tx_Client_TxD_2_Mem_We    : std_logic_vector(c_TxD_wea_width     -1 downto 0);
    --Write Port - AXI Stream Data
    signal Axi_Str_TxD_2_Mem_Din     : std_logic_vector(c_TxD_write_width_b -1 downto 0);
    signal Axi_Str_TxD_2_Mem_Addr    : std_logic_vector(c_TxD_addrb_width   -1 downto 0);
    signal Axi_Str_TxD_2_Mem_Dout    : std_logic_vector(c_TxD_read_width_b  -1 downto 0);
    signal Axi_Str_TxD_2_Mem_En      : std_logic;
    signal Axi_Str_TxD_2_Mem_We      : std_logic_vector(c_TxD_web_width     -1 downto 0);
    

    begin

      GEN_TXCIF_MEM_PARAM_S6: if (equalIgnoringCase(get_root_family(C_FAMILY), "spartan6")=TRUE) generate
      --  Force to use only 1 BRAM for the device families
        --  S6 = 18k (36 x 512)
        --  V6 = 36K (36 x 1024)

      -- Read Port - AXI Stream Control
      constant c_TxC_write_width_a     : integer range 36 to 36       := C_S_AXI_DATA_WIDTH + 4;
      constant c_TxC_read_width_a      : integer range 36 to 36       := C_S_AXI_DATA_WIDTH + 4;
      constant c_TxC_write_depth_a     : integer range  0 to 1024     := 512;
      constant c_TxC_read_depth_a      : integer range  0 to 1024     := 512;
      constant c_TxC_addra_width       : integer range  0 to 10       := 9;
      constant c_TxC_wea_width         : integer range  0 to 1        := 1;
      --Write Port - AXI Stream Control
      constant c_TxC_write_width_b     : integer range 36 to 36       := C_S_AXI_DATA_WIDTH + 4;
      constant c_TxC_read_width_b      : integer range 36 to 36       := C_S_AXI_DATA_WIDTH + 4;
      constant c_TxC_write_depth_b     : integer range  0 to 1024     := 512;
      constant c_TxC_read_depth_b      : integer range  0 to 1024     := 512;
      constant c_TxC_addrb_width       : integer range  0 to 10       := 9;
      constant c_TxC_web_width         : integer range  0 to 1        := 1;

      --Read Port - AXI Stream Control
      signal Tx_Client_TxC_2_Mem_Din   : std_logic_vector(c_TxC_write_width_a -1 downto 0);
      signal Tx_Client_TxC_2_Mem_Addr  : std_logic_vector(c_TxC_addra_width   -1 downto 0);
      signal Tx_Client_TxC_2_Mem_Dout  : std_logic_vector(c_TxC_read_width_a  -1 downto 0);
      signal Tx_Client_TxC_2_Mem_En    : std_logic;
      signal Tx_Client_TxC_2_Mem_We    : std_logic_vector(c_TxC_wea_width     -1 downto 0);
      --Write Port - AXI Stream Control
      signal Axi_Str_TxC_2_Mem_Din     : std_logic_vector(c_TxC_write_width_b -1 downto 0);
      signal Axi_Str_TxC_2_Mem_Addr    : std_logic_vector(c_TxC_addrb_width   -1 downto 0);
      signal Axi_Str_TxC_2_Mem_Dout    : std_logic_vector(c_TxC_read_width_b  -1 downto 0);
      signal Axi_Str_TxC_2_Mem_En      : std_logic;
      signal Axi_Str_TxC_2_Mem_We      : std_logic_vector(c_TxC_web_width     -1 downto 0);

      begin


        TX_AXISTREAM_INTERFACE : entity axi_ethernet_v3_01_a.tx_axistream_if(rtl)
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
          Axi_Str_TxC_2_Mem_Dout => Axi_Str_TxC_2_Mem_Dout,      --: in  std_logic_vector(c_TxD_read_width_b-1  downto 0);

          tx_vlan_bram_addr      => tx_vlan_bram_addr,
          tx_vlan_bram_din       => tx_vlan_bram_din,
          tx_vlan_bram_en        => tx_vlan_bram_en,

          enable_newFncEn        => enable_newFncEn,
          transMode_cross        => transMode_cross,
          tagMode_cross          => tagMode_cross,
          strpMode_cross         => strpMode_cross,

          tpid0_cross            => tpid0_cross,
          tpid1_cross            => tpid1_cross,
          tpid2_cross            => tpid2_cross,
          tpid3_cross            => tpid3_cross,

          newTagData_cross       => newTagData_cross,

          tx_init_in_prog        => tx_init_in_prog

        );


       TX_MEM_INTERFACE : entity axi_ethernet_v3_01_a.tx_mem_if(imp)
       --BRAM between AXI Stream Interface and Tx Client Interface
       generic map(
          C_FAMILY                 => C_FAMILY,

          -- Read Port - AXI Stream TxData
          c_TxD_write_width_a      => c_TxD_write_width_a,
          c_TxD_read_width_a       => c_TxD_read_width_a,
          c_TxD_write_depth_a      => c_TxD_write_depth_a,
          c_TxD_read_depth_a       => c_TxD_read_depth_a,
          c_TxD_addra_width        => c_TxD_addra_width,
          c_TxD_wea_width          => c_TxD_wea_width,
          -- Write Port - AXI Stream TxData
          c_TxD_write_width_b      => c_TxD_write_width_b,
          c_TxD_read_width_b       => c_TxD_read_width_b,
          c_TxD_write_depth_b      => c_TxD_write_depth_b,
          c_TxD_read_depth_b       => c_TxD_read_depth_b,
          c_TxD_addrb_width        => c_TxD_addrb_width,
          c_TxD_web_width          => c_TxD_web_width,

          -- Read Port - AXI Stream TxControl
          c_TxC_write_width_a      => c_TxC_write_width_a,
          c_TxC_read_width_a       => c_TxC_read_width_a,
          c_TxC_write_depth_a      => c_TxC_write_depth_a,
          c_TxC_read_depth_a       => c_TxC_read_depth_a,
          c_TxC_addra_width        => c_TxC_addra_width,
          c_TxC_wea_width          => c_TxC_wea_width,
          -- Write Port - AXI Stream TxControl
          c_TxC_write_width_b      => c_TxC_write_width_b,
          c_TxC_read_width_b       => c_TxC_read_width_b,
          c_TxC_write_depth_b      => c_TxC_write_depth_b,
          c_TxC_read_depth_b       => c_TxC_read_depth_b,
          c_TxC_addrb_width        => c_TxC_addrb_width,
          c_TxC_web_width          => c_TxC_web_width

        )
        port map  (
          -- Read Port - AXI Stream TxData
          TX_CLIENT_CLK             => tx_mac_aclk,            --: in  std_logic;
          reset2tx_client           => tx_reset,          --: in  std_logic;
          Tx_Client_TxD_2_Mem_Din   => Tx_Client_TxD_2_Mem_Din,  --: in  std_logic_vector(c_TxD_write_width_a-1 downto 0);
          Tx_Client_TxD_2_Mem_Addr  => Tx_Client_TxD_2_Mem_Addr, --: in  std_logic_vector(c_TxD_addra_width-1   downto 0);
          Tx_Client_TxD_2_Mem_En    => Tx_Client_TxD_2_Mem_En,   --: in  std_logic := '1';
          Tx_Client_TxD_2_Mem_We    => Tx_Client_TxD_2_Mem_We,   --: in  std_logic_vector(c_TxD_wea_width-1     downto 0);
          Tx_Client_TxD_2_Mem_Dout  => Tx_Client_TxD_2_Mem_Dout, --: out std_logic_vector(c_TxD_read_width_a-1  downto 0);
          -- Write Port - AXI Stream TxData
          AXI_STR_TXD_ACLK          => AXI_STR_TXD_ACLK,         --: in  std_logic := '0';
          reset2axi_str_txd         => reset2axi_str_txd,        --: in  std_logic;
          Axi_Str_TxD_2_Mem_Din     => Axi_Str_TxD_2_Mem_Din,    --: in  std_logic_vector(c_TxD_write_width_b-1 downto 0);
          Axi_Str_TxD_2_Mem_Addr    => Axi_Str_TxD_2_Mem_Addr,   --: in  std_logic_vector(c_TxD_addrb_width-1   downto 0);
          Axi_Str_TxD_2_Mem_En      => Axi_Str_TxD_2_Mem_En,     --: in  std_logic := '1';
          Axi_Str_TxD_2_Mem_We      => Axi_Str_TxD_2_Mem_We,     --: in  std_logic_vector(c_TxD_web_width-1     downto 0);
          Axi_Str_TxD_2_Mem_Dout    => Axi_Str_TxD_2_Mem_Dout,   --: out std_logic_vector(c_TxD_read_width_b-1  downto 0);

          -- Read Port - AXI Stream TxControl
          Tx_Client_TxC_2_Mem_Din   => Tx_Client_TxC_2_Mem_Din,  --: in  std_logic_vector(c_TxD_write_width_a-1 downto 0);
          Tx_Client_TxC_2_Mem_Addr  => Tx_Client_TxC_2_Mem_Addr, --: in  std_logic_vector(c_TxD_addra_width-1   downto 0);
          Tx_Client_TxC_2_Mem_En    => Tx_Client_TxC_2_Mem_En,   --: in  std_logic := '1';
          Tx_Client_TxC_2_Mem_We    => Tx_Client_TxC_2_Mem_We,   --: in  std_logic_vector(c_TxD_wea_width-1     downto 0);
          Tx_Client_TxC_2_Mem_Dout  => Tx_Client_TxC_2_Mem_Dout, --: out std_logic_vector(c_TxD_read_width_a-1  downto 0);
          -- Write Port - AXI Stream TxControl
          AXI_STR_TXC_ACLK          => AXI_STR_TXC_ACLK,         --: in  std_logic := '0';
          reset2axi_str_txc         => reset2axi_str_txc,        --: in  std_logic;
          Axi_Str_TxC_2_Mem_Din     => Axi_Str_TxC_2_Mem_Din,    --: in  std_logic_vector(c_TxD_write_width_b-1 downto 0);
          Axi_Str_TxC_2_Mem_Addr    => Axi_Str_TxC_2_Mem_Addr,   --: in  std_logic_vector(c_TxD_addrb_width-1   downto 0);
          Axi_Str_TxC_2_Mem_En      => Axi_Str_TxC_2_Mem_En,     --: in  std_logic := '1';
          Axi_Str_TxC_2_Mem_We      => Axi_Str_TxC_2_Mem_We,     --: in  std_logic_vector(c_TxD_web_width-1     downto 0);
          Axi_Str_TxC_2_Mem_Dout    => Axi_Str_TxC_2_Mem_Dout    --: out std_logic_vector(c_TxD_read_width_b-1  downto 0);
        );


        TX_EMAC_INTERFACE : entity axi_ethernet_v3_01_a.tx_emac_if(rtl)
        --  Interface for Transmit AxiStream Data and Control; and Tx Memory
        generic map (
          C_FAMILY                  => C_FAMILY,                 --: string                        := "virtex6";
          C_TYPE                    => C_TYPE,                   --: integer range 0 to 2          := 0;
          C_PHY_TYPE                => C_PHY_TYPE,               --: integer range 0 to 7          := 1;
          C_HALFDUP                 => C_HALFDUP,                --: integer range 0 to 1          := 0;
          C_TXMEM                   => C_TXMEM,                  --: integer                       := 4096;
          C_TXCSUM                  => C_TXCSUM,                 --: integer range 0 to 2          := 0;

          -- Read Port - AXI Stream TxData
          c_TxD_write_width_a       => c_TxD_write_width_a,
          c_TxD_read_width_a        => c_TxD_read_width_a,
          c_TxD_write_depth_a       => c_TxD_write_depth_a,
          c_TxD_read_depth_a        => c_TxD_read_depth_a,
          c_TxD_addra_width         => c_TxD_addra_width,
          c_TxD_wea_width           => c_TxD_wea_width,

          -- Read Port - AXI Stream TxControl
          c_TxC_write_width_a       => c_TxC_write_width_a,
          c_TxC_read_width_a        => c_TxC_read_width_a,
          c_TxC_write_depth_a       => c_TxC_write_depth_a,
          c_TxC_read_depth_a        => c_TxC_read_depth_a,
          c_TxC_addra_width         => c_TxC_addra_width,
          c_TxC_wea_width           => c_TxC_wea_width,

          c_TxD_addrb_width         => c_TxD_addrb_width,

          C_CLIENT_WIDTH            => C_CLIENT_WIDTH
        )
        port map  (
          tx_client_10_100          => tx_client_10_100,  

          -- Read Port - AXI Stream TxData
          reset2tx_client           => tx_reset,          --: in  std_logic;
          Tx_Client_TxD_2_Mem_Din   => Tx_Client_TxD_2_Mem_Din,  --: out std_logic_vector(c_TxD_write_width_a-1 downto 0);
          Tx_Client_TxD_2_Mem_Addr  => Tx_Client_TxD_2_Mem_Addr, --: out std_logic_vector(c_TxD_addra_width-1   downto 0);
          Tx_Client_TxD_2_Mem_En    => Tx_Client_TxD_2_Mem_En,   --: out std_logic := '1';
          Tx_Client_TxD_2_Mem_We    => Tx_Client_TxD_2_Mem_We,   --: out std_logic_vector(c_TxD_wea_width-1     downto 0);
          Tx_Client_TxD_2_Mem_Dout  => Tx_Client_TxD_2_Mem_Dout, --: in  std_logic_vector(c_TxD_read_width_a-1  downto 0);

          -- Read Port - AXI Stream TxControl
          reset2axi_str_txd         => reset2axi_str_txd,        --: in  std_logic;
          Tx_Client_TxC_2_Mem_Din   => Tx_Client_TxC_2_Mem_Din,  --: out std_logic_vector(c_TxD_write_width_a-1 downto 0);
          Tx_Client_TxC_2_Mem_Addr  => Tx_Client_TxC_2_Mem_Addr, --: out std_logic_vector(c_TxD_addra_width-1   downto 0);
          Tx_Client_TxC_2_Mem_En    => Tx_Client_TxC_2_Mem_En,   --: out std_logic := '1';
          Tx_Client_TxC_2_Mem_We    => Tx_Client_TxC_2_Mem_We,   --: out std_logic_vector(c_TxD_wea_width-1     downto 0);
          Tx_Client_TxC_2_Mem_Dout  => Tx_Client_TxC_2_Mem_Dout, --: in  std_logic_vector(c_TxD_read_width_a-1  downto 0);


          tx_axi_clk                => tx_mac_aclk,       
          tx_reset_out              => tx_reset,          
          tx_axis_mac_tdata         => tx_axis_mac_tdata_int,    --tx_axis_mac_tdata, 
          tx_axis_mac_tvalid        => tx_axis_mac_tvalid_int,   --tx_axis_mac_tvalid,
          tx_axis_mac_tlast         => tx_axis_mac_tlast_int,    --tx_axis_mac_tlast, 
          tx_axis_mac_tuser         => tx_axis_mac_tuser_int,    --tx_axis_mac_tuser, 
          tx_axis_mac_tready        => tx_axis_mac_tready_int,   --tx_axis_mac_tready,
          tx_collision              => tx_collision_int,         --tx_collision,      
          tx_retransmit             => tx_retransmit_int,        --tx_retransmit,     

          tx_cmplt                  => tx_cmplt,
          
          tx_init_in_prog_cross     => tx_init_in_prog_cross          
        );
           
         tx_axis_mac_tdata      <= tx_axis_mac_tdata_int;
          tx_axis_mac_tvalid     <= tx_axis_mac_tvalid_int;
          tx_axis_mac_tlast      <= tx_axis_mac_tlast_int; 
          tx_axis_mac_tuser      <= tx_axis_mac_tuser_int; 
          tx_axis_mac_tready_int <= tx_axis_mac_tready;

        NOT_TX_AVB : if C_AVB = 0 generate
        begin
        
         tx_collision_int       <= tx_collision;      
          tx_retransmit_int      <= tx_retransmit;  
          
          legacy_tx_data         <= "00000000";
          legacy_tx_data_valid   <= '0';
          legacy_tx_underrun     <= '0';
          
        end generate NOT_TX_AVB;    
        
        
        TX_AVB : if C_AVB = 1 generate
        signal tx_continuation : std_logic;
        begin
        
          TX_EMAC_IF_2_AVB : axi_ethernet_v3_01_a_tx_axi_intf
          port map
          (
            tx_clk          => tx_mac_aclk,           --: in  std_logic;                    
            tx_reset        => tx_reset,              --: in  std_logic;                    
            tx_enable       => tx_avb_en,             -- added for avb connection 03/21/2011                    
            ----------------------------------------------------
            -- AXI Interface                                    
            ----------------------------------------------------
            tx_mac_tdata    => tx_axis_mac_tdata_int, --: in  std_logic_vector(7 downto 0); 
            tx_mac_tvalid   => tx_axis_mac_tvalid_int,--: in  std_logic;                    
            tx_mac_tlast    => tx_axis_mac_tlast_int, --: in  std_logic;                    
            tx_mac_tuser    => tx_axis_mac_tuser_int, --: in  std_logic;                    
            tx_mac_tready   => open,--: out std_logic;                    
            ----------------------------------------------------
            -- Ethernet MAC TX Client Interface                 
            ----------------------------------------------------
            tx_enable_out   => tx_avb_en_out,         --: out std_logic;                    
            tx_continuation => tx_continuation,       --: out std_logic;                    
            tx_data         => legacy_tx_data,        --: out std_logic_vector(7 downto 0); 
            tx_data_valid   => legacy_tx_data_valid,  --: out std_logic;                    
            tx_underrun     => legacy_tx_underrun,    --: out std_logic;                    
            tx_ack          => legacy_tx_ack          --: in  std_logic                     
          
          );
          
        end generate TX_AVB;          
    end generate     GEN_TXCIF_MEM_PARAM_S6;
  end generate GEN_TXDIF_MEM_PARAM_S6CLIENT8;

  GEN_TXDIF_MEM_PARAM_V6V7A7K7CLIENT8: if (
                                     (((equalIgnoringCase(get_root_family(C_FAMILY), "virtex6")= TRUE)) or 
                                      ((equalIgnoringCase(get_root_family(C_FAMILY), "virtex7")= TRUE)) or 
                                      ((equalIgnoringCase(get_root_family(C_FAMILY), "artix7") = TRUE)) or 
                                      ((equalIgnoringCase(get_root_family(C_FAMILY), "kintex7")= TRUE)) or
                                      ((equalIgnoringCase(get_root_family(C_FAMILY), "zynq")= TRUE))) and
                                     (C_PHY_TYPE = 0 or C_PHY_TYPE = 1 or
                                      C_PHY_TYPE = 2 or C_PHY_TYPE = 3 or
                                      C_PHY_TYPE = 4 or C_PHY_TYPE = 5 )
                                                                        ) generate

      -- Read Port - AXI Stream Data
    constant c_TxD_write_width_a     : integer range  0 to 18       := (C_S_AXI_DATA_WIDTH + 4)/4;
    constant c_TxD_read_width_a      : integer range  0 to 18       := (C_S_AXI_DATA_WIDTH + 4)/4;
    constant c_TxD_write_depth_a     : integer range  0 to 32768    := C_TXMEM;
    constant c_TxD_read_depth_a      : integer range  0 to 32768    := C_TXMEM;
    constant c_TxD_addra_width       : integer range  0 to 15       := log2(C_TXMEM);
    constant c_TxD_wea_width         : integer range  0 to 2        := 1;
    --Write Port - AXI Stream Data
    constant c_TxD_write_width_b     : integer range 36 to 36       := C_S_AXI_DATA_WIDTH + 4;
    constant c_TxD_read_width_b      : integer range 36 to 36       := C_S_AXI_DATA_WIDTH + 4;
    constant c_TxD_write_depth_b     : integer range  0 to 8192     := C_TXMEM/4;
    constant c_TxD_read_depth_b      : integer range  0 to 8192     := C_TXMEM/4;
    constant c_TxD_addrb_width       : integer range  0 to 13       := log2(C_TXMEM/4);
    constant c_TxD_web_width         : integer range  0 to 4        := 4;

    --Read Port - AXI Stream Data
    signal Tx_Client_TxD_2_Mem_Din   : std_logic_vector(c_TxD_write_width_a -1 downto 0);
    signal Tx_Client_TxD_2_Mem_Addr  : std_logic_vector(c_TxD_addra_width   -1 downto 0);
    signal Tx_Client_TxD_2_Mem_Dout  : std_logic_vector(c_TxD_read_width_a  -1 downto 0);
    signal Tx_Client_TxD_2_Mem_En    : std_logic;
    signal Tx_Client_TxD_2_Mem_We    : std_logic_vector(c_TxD_wea_width     -1 downto 0);
    --Write Port - AXI Stream Data
    signal Axi_Str_TxD_2_Mem_Din     : std_logic_vector(c_TxD_write_width_b -1 downto 0);
    signal Axi_Str_TxD_2_Mem_Addr    : std_logic_vector(c_TxD_addrb_width   -1 downto 0);
    signal Axi_Str_TxD_2_Mem_Dout    : std_logic_vector(c_TxD_read_width_b  -1 downto 0);
    signal Axi_Str_TxD_2_Mem_En      : std_logic;
    signal Axi_Str_TxD_2_Mem_We      : std_logic_vector(c_TxD_web_width     -1 downto 0);

    begin

    GEN_TXCIF_MEM_PARAM_V6V7A7K7: if (
                                ((equalIgnoringCase(get_root_family(C_FAMILY), "virtex6")= TRUE)) or 
                                ((equalIgnoringCase(get_root_family(C_FAMILY), "virtex7")= TRUE)) or 
                                ((equalIgnoringCase(get_root_family(C_FAMILY), "artix7") = TRUE)) or 
                                ((equalIgnoringCase(get_root_family(C_FAMILY), "kintex7")= TRUE)) or
                                ((equalIgnoringCase(get_root_family(C_FAMILY), "zynq")= TRUE))
                                                                                     )generate
      --  Force to use only 1 BRAM for the device families
        --  S6 = 18k (36 x 512)
        --  V6 = 36K (36 x 1024)

      -- Read Port - AXI Stream Control
      constant c_TxC_write_width_a     : integer range 36 to 36       := C_S_AXI_DATA_WIDTH + 4;
      constant c_TxC_read_width_a      : integer range 36 to 36       := C_S_AXI_DATA_WIDTH + 4;
      constant c_TxC_write_depth_a     : integer range  0 to 1024     := 1024;
      constant c_TxC_read_depth_a      : integer range  0 to 1024     := 1024;
      constant c_TxC_addra_width       : integer range  0 to 10       := 10;
      constant c_TxC_wea_width         : integer range  0 to 1        := 1;
      --Write Port - AXI Stream Control
      constant c_TxC_write_width_b     : integer range 36 to 36       := C_S_AXI_DATA_WIDTH + 4;
      constant c_TxC_read_width_b      : integer range 36 to 36       := C_S_AXI_DATA_WIDTH + 4;
      constant c_TxC_write_depth_b     : integer range  0 to 1024     := 1024;
      constant c_TxC_read_depth_b      : integer range  0 to 1024     := 1024;
      constant c_TxC_addrb_width       : integer range  0 to 10       := 10;
      constant c_TxC_web_width         : integer range  0 to 1        := 1;

      --Read Port - AXI Stream Control
      signal Tx_Client_TxC_2_Mem_Din   : std_logic_vector(c_TxC_write_width_a -1 downto 0);
      signal Tx_Client_TxC_2_Mem_Addr  : std_logic_vector(c_TxC_addra_width   -1 downto 0);
      signal Tx_Client_TxC_2_Mem_Dout  : std_logic_vector(c_TxC_read_width_a  -1 downto 0);
      signal Tx_Client_TxC_2_Mem_En    : std_logic;
      signal Tx_Client_TxC_2_Mem_We    : std_logic_vector(c_TxC_wea_width     -1 downto 0);
      --Write Port - AXI Stream Control
      signal Axi_Str_TxC_2_Mem_Din     : std_logic_vector(c_TxC_write_width_b -1 downto 0);
      signal Axi_Str_TxC_2_Mem_Addr    : std_logic_vector(c_TxC_addrb_width   -1 downto 0);
      signal Axi_Str_TxC_2_Mem_Dout    : std_logic_vector(c_TxC_read_width_b  -1 downto 0);
      signal Axi_Str_TxC_2_Mem_En      : std_logic;
      signal Axi_Str_TxC_2_Mem_We      : std_logic_vector(c_TxC_web_width     -1 downto 0);

      begin


        TX_AXISTREAM_INTERFACE : entity axi_ethernet_v3_01_a.tx_axistream_if(rtl)
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
          Axi_Str_TxC_2_Mem_Dout => Axi_Str_TxC_2_Mem_Dout,      --: in  std_logic_vector(c_TxD_read_width_b-1  downto 0);

          tx_vlan_bram_addr      => tx_vlan_bram_addr,
          tx_vlan_bram_din       => tx_vlan_bram_din,
          tx_vlan_bram_en        => tx_vlan_bram_en,

          enable_newFncEn        => enable_newFncEn,
          transMode_cross        => transMode_cross,
          tagMode_cross          => tagMode_cross,
          strpMode_cross         => strpMode_cross,

          tpid0_cross            => tpid0_cross,
          tpid1_cross            => tpid1_cross,
          tpid2_cross            => tpid2_cross,
          tpid3_cross            => tpid3_cross,

          newTagData_cross       => newTagData_cross,

          tx_init_in_prog        => tx_init_in_prog

        );


       TX_MEM_INTERFACE : entity axi_ethernet_v3_01_a.tx_mem_if(imp)
       --BRAM between AXI Stream Interface and Tx Client Interface
       generic map(
          C_FAMILY                 => C_FAMILY,

          -- Read Port - AXI Stream TxData
          c_TxD_write_width_a      => c_TxD_write_width_a,
          c_TxD_read_width_a       => c_TxD_read_width_a,
          c_TxD_write_depth_a      => c_TxD_write_depth_a,
          c_TxD_read_depth_a       => c_TxD_read_depth_a,
          c_TxD_addra_width        => c_TxD_addra_width,
          c_TxD_wea_width          => c_TxD_wea_width,
          -- Write Port - AXI Stream TxData
          c_TxD_write_width_b      => c_TxD_write_width_b,
          c_TxD_read_width_b       => c_TxD_read_width_b,
          c_TxD_write_depth_b      => c_TxD_write_depth_b,
          c_TxD_read_depth_b       => c_TxD_read_depth_b,
          c_TxD_addrb_width        => c_TxD_addrb_width,
          c_TxD_web_width          => c_TxD_web_width,

          -- Read Port - AXI Stream TxControl
          c_TxC_write_width_a      => c_TxC_write_width_a,
          c_TxC_read_width_a       => c_TxC_read_width_a,
          c_TxC_write_depth_a      => c_TxC_write_depth_a,
          c_TxC_read_depth_a       => c_TxC_read_depth_a,
          c_TxC_addra_width        => c_TxC_addra_width,
          c_TxC_wea_width          => c_TxC_wea_width,
          -- Write Port - AXI Stream TxControl
          c_TxC_write_width_b      => c_TxC_write_width_b,
          c_TxC_read_width_b       => c_TxC_read_width_b,
          c_TxC_write_depth_b      => c_TxC_write_depth_b,
          c_TxC_read_depth_b       => c_TxC_read_depth_b,
          c_TxC_addrb_width        => c_TxC_addrb_width,
          c_TxC_web_width          => c_TxC_web_width

        )
        port map  (
          -- Read Port - AXI Stream TxData
          TX_CLIENT_CLK             => tx_mac_aclk,            --: in  std_logic;
          reset2tx_client           => tx_reset,          --: in  std_logic;
          Tx_Client_TxD_2_Mem_Din   => Tx_Client_TxD_2_Mem_Din,  --: in  std_logic_vector(c_TxD_write_width_a-1 downto 0);
          Tx_Client_TxD_2_Mem_Addr  => Tx_Client_TxD_2_Mem_Addr, --: in  std_logic_vector(c_TxD_addra_width-1   downto 0);
          Tx_Client_TxD_2_Mem_En    => Tx_Client_TxD_2_Mem_En,   --: in  std_logic := '1';
          Tx_Client_TxD_2_Mem_We    => Tx_Client_TxD_2_Mem_We,   --: in  std_logic_vector(c_TxD_wea_width-1     downto 0);
          Tx_Client_TxD_2_Mem_Dout  => Tx_Client_TxD_2_Mem_Dout, --: out std_logic_vector(c_TxD_read_width_a-1  downto 0);
          -- Write Port - AXI Stream TxData
          AXI_STR_TXD_ACLK          => AXI_STR_TXD_ACLK,         --: in  std_logic := '0';
          reset2axi_str_txd         => reset2axi_str_txd,        --: in  std_logic;
          Axi_Str_TxD_2_Mem_Din     => Axi_Str_TxD_2_Mem_Din,    --: in  std_logic_vector(c_TxD_write_width_b-1 downto 0);
          Axi_Str_TxD_2_Mem_Addr    => Axi_Str_TxD_2_Mem_Addr,   --: in  std_logic_vector(c_TxD_addrb_width-1   downto 0);
          Axi_Str_TxD_2_Mem_En      => Axi_Str_TxD_2_Mem_En,     --: in  std_logic := '1';
          Axi_Str_TxD_2_Mem_We      => Axi_Str_TxD_2_Mem_We,     --: in  std_logic_vector(c_TxD_web_width-1     downto 0);
          Axi_Str_TxD_2_Mem_Dout    => Axi_Str_TxD_2_Mem_Dout,   --: out std_logic_vector(c_TxD_read_width_b-1  downto 0);

          -- Read Port - AXI Stream TxControl
          Tx_Client_TxC_2_Mem_Din   => Tx_Client_TxC_2_Mem_Din,  --: in  std_logic_vector(c_TxD_write_width_a-1 downto 0);
          Tx_Client_TxC_2_Mem_Addr  => Tx_Client_TxC_2_Mem_Addr, --: in  std_logic_vector(c_TxD_addra_width-1   downto 0);
          Tx_Client_TxC_2_Mem_En    => Tx_Client_TxC_2_Mem_En,   --: in  std_logic := '1';
          Tx_Client_TxC_2_Mem_We    => Tx_Client_TxC_2_Mem_We,   --: in  std_logic_vector(c_TxD_wea_width-1     downto 0);
          Tx_Client_TxC_2_Mem_Dout  => Tx_Client_TxC_2_Mem_Dout, --: out std_logic_vector(c_TxD_read_width_a-1  downto 0);
          -- Write Port - AXI Stream TxControl
          AXI_STR_TXC_ACLK          => AXI_STR_TXC_ACLK,         --: in  std_logic := '0';
          reset2axi_str_txc         => reset2axi_str_txc,        --: in  std_logic;
          Axi_Str_TxC_2_Mem_Din     => Axi_Str_TxC_2_Mem_Din,    --: in  std_logic_vector(c_TxD_write_width_b-1 downto 0);
          Axi_Str_TxC_2_Mem_Addr    => Axi_Str_TxC_2_Mem_Addr,   --: in  std_logic_vector(c_TxD_addrb_width-1   downto 0);
          Axi_Str_TxC_2_Mem_En      => Axi_Str_TxC_2_Mem_En,     --: in  std_logic := '1';
          Axi_Str_TxC_2_Mem_We      => Axi_Str_TxC_2_Mem_We,     --: in  std_logic_vector(c_TxD_web_width-1     downto 0);
          Axi_Str_TxC_2_Mem_Dout    => Axi_Str_TxC_2_Mem_Dout    --: out std_logic_vector(c_TxD_read_width_b-1  downto 0);
        );


        TX_EMAC_INTERFACE : entity axi_ethernet_v3_01_a.tx_emac_if(rtl)
        --  Interface for Transmit AxiStream Data and Control; and Tx Memory
        generic map (
          C_FAMILY                  => C_FAMILY,                 --: string                        := "virtex6";
          C_TYPE                    => C_TYPE,                   --: integer range 0 to 2          := 0;
          C_PHY_TYPE                => C_PHY_TYPE,               --: integer range 0 to 7          := 1;
          C_HALFDUP                 => C_HALFDUP,                --: integer range 0 to 1          := 0;
          C_TXMEM                   => C_TXMEM,                  --: integer                       := 4096;
          C_TXCSUM                  => C_TXCSUM,                 --: integer range 0 to 2          := 0;

          -- Read Port - AXI Stream TxData
          c_TxD_write_width_a       => c_TxD_write_width_a,
          c_TxD_read_width_a        => c_TxD_read_width_a,
          c_TxD_write_depth_a       => c_TxD_write_depth_a,
          c_TxD_read_depth_a        => c_TxD_read_depth_a,
          c_TxD_addra_width         => c_TxD_addra_width,
          c_TxD_wea_width           => c_TxD_wea_width,

          -- Read Port - AXI Stream TxControl
          c_TxC_write_width_a       => c_TxC_write_width_a,
          c_TxC_read_width_a        => c_TxC_read_width_a,
          c_TxC_write_depth_a       => c_TxC_write_depth_a,
          c_TxC_read_depth_a        => c_TxC_read_depth_a,
          c_TxC_addra_width         => c_TxC_addra_width,
          c_TxC_wea_width           => c_TxC_wea_width,

          c_TxD_addrb_width         => c_TxD_addrb_width,

          C_CLIENT_WIDTH            => C_CLIENT_WIDTH
        )
        port map  (
          tx_client_10_100          => tx_client_10_100,

          -- Read Port - AXI Stream TxData
          reset2tx_client           => tx_reset,          --: in  std_logic;
          Tx_Client_TxD_2_Mem_Din   => Tx_Client_TxD_2_Mem_Din,  --: out std_logic_vector(c_TxD_write_width_a-1 downto 0);
          Tx_Client_TxD_2_Mem_Addr  => Tx_Client_TxD_2_Mem_Addr, --: out std_logic_vector(c_TxD_addra_width-1   downto 0);
          Tx_Client_TxD_2_Mem_En    => Tx_Client_TxD_2_Mem_En,   --: out std_logic := '1';
          Tx_Client_TxD_2_Mem_We    => Tx_Client_TxD_2_Mem_We,   --: out std_logic_vector(c_TxD_wea_width-1     downto 0);
          Tx_Client_TxD_2_Mem_Dout  => Tx_Client_TxD_2_Mem_Dout, --: in  std_logic_vector(c_TxD_read_width_a-1  downto 0);

          -- Read Port - AXI Stream TxControl
          reset2axi_str_txd         => reset2axi_str_txd,        --: in  std_logic;
          Tx_Client_TxC_2_Mem_Din   => Tx_Client_TxC_2_Mem_Din,  --: out std_logic_vector(c_TxD_write_width_a-1 downto 0);
          Tx_Client_TxC_2_Mem_Addr  => Tx_Client_TxC_2_Mem_Addr, --: out std_logic_vector(c_TxD_addra_width-1   downto 0);
          Tx_Client_TxC_2_Mem_En    => Tx_Client_TxC_2_Mem_En,   --: out std_logic := '1';
          Tx_Client_TxC_2_Mem_We    => Tx_Client_TxC_2_Mem_We,   --: out std_logic_vector(c_TxD_wea_width-1     downto 0);
          Tx_Client_TxC_2_Mem_Dout  => Tx_Client_TxC_2_Mem_Dout, --: in  std_logic_vector(c_TxD_read_width_a-1  downto 0);


          tx_axi_clk                => tx_mac_aclk,       
          tx_reset_out              => tx_reset,          
          tx_axis_mac_tdata         => tx_axis_mac_tdata_int , --tx_axis_mac_tdata, 
          tx_axis_mac_tvalid        => tx_axis_mac_tvalid_int, --tx_axis_mac_tvalid,
          tx_axis_mac_tlast         => tx_axis_mac_tlast_int , --tx_axis_mac_tlast, 
          tx_axis_mac_tuser         => tx_axis_mac_tuser_int , --tx_axis_mac_tuser, 
          tx_axis_mac_tready        => tx_axis_mac_tready_int, --tx_axis_mac_tready,
          tx_collision              => tx_collision_int      , --tx_collision,      
          tx_retransmit             => tx_retransmit_int     , --tx_retransmit,     

          tx_cmplt                  => tx_cmplt,
          
          tx_init_in_prog_cross     => tx_init_in_prog_cross  
        );
        
          tx_axis_mac_tvalid     <= tx_axis_mac_tvalid_int;
          tx_axis_mac_tlast      <= tx_axis_mac_tlast_int; 
          tx_axis_mac_tuser      <= tx_axis_mac_tuser_int; 
          tx_axis_mac_tready_int <= tx_axis_mac_tready;
          tx_axis_mac_tdata      <= tx_axis_mac_tdata_int;


        NOT_TX_AVB : if C_AVB = 0 generate
        begin
        
          tx_collision_int       <= tx_collision;      
          tx_retransmit_int      <= tx_retransmit;  
          
          legacy_tx_data         <= "00000000";
          legacy_tx_data_valid   <= '0';
          legacy_tx_underrun     <= '0';         
          
        end generate NOT_TX_AVB;    
        
        
        TX_AVB : if C_AVB = 1 generate
        signal tx_continuation : std_logic;
        begin
          
          TX_EMAC_IF_2_AVB : axi_ethernet_v3_01_a_tx_axi_intf
          port map
          (
            tx_clk          => tx_mac_aclk,           --: in  std_logic;                    
            tx_reset        => tx_reset,              --: in  std_logic;                    
            tx_enable       => tx_avb_en,             -- added for avb connection 03/21/2011                     
            ----------------------------------------------------
            -- AXI Interface                                    
            ----------------------------------------------------
            tx_mac_tdata    => tx_axis_mac_tdata_int, --: in  std_logic_vector(7 downto 0); 
            tx_mac_tvalid   => tx_axis_mac_tvalid_int,--: in  std_logic;                    
            tx_mac_tlast    => tx_axis_mac_tlast_int, --: in  std_logic;                    
            tx_mac_tuser    => tx_axis_mac_tuser_int, --: in  std_logic;                    
            tx_mac_tready   => open,--: out std_logic;                    
            ----------------------------------------------------
            -- Ethernet MAC TX Client Interface                 
            ----------------------------------------------------
            tx_enable_out   => tx_avb_en_out,         --: out std_logic;                    
            tx_continuation => tx_continuation,       --: out std_logic;                    
            tx_data         => legacy_tx_data,        --: out std_logic_vector(7 downto 0); 
            tx_data_valid   => legacy_tx_data_valid,  --: out std_logic;                    
            tx_underrun     => legacy_tx_underrun,    --: out std_logic;                    
            tx_ack          => legacy_tx_ack          --: in  std_logic                     
          
          );        
        end generate TX_AVB; 
    end generate     GEN_TXCIF_MEM_PARAM_V6V7A7K7;
  end generate GEN_TXDIF_MEM_PARAM_V6V7A7K7CLIENT8;


end imp;
