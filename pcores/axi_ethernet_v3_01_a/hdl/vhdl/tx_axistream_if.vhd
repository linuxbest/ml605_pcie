-------------------------------------------------------------------------------
-- tx_axistream_if - entity/architecture pair
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
-- Filename:        tx_axistream_if.vhd
-- Version:         v1.00a
-- Description:     embedded ip AXI Stream transmit interface
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
--          ->        tx_axistream_if.vhd
--                      tx_basic_if.vhd
--                      tx_csum_if.vhd
--                        tx_csum_partial_if.vhd
--                          tx_csum_partial_calc_if.vhd
--                        tx_full_csum_if.vhd
--                      tx_vlan_if.vhd
--                    tx_mem_if
--                    tx_emac_if.vhd
--
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

library proc_common_v3_00_a;
use proc_common_v3_00_a.blk_mem_gen_wrapper;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

-------------------------------------------------------------------------------
--                  Entity Section
-------------------------------------------------------------------------------

entity tx_axistream_if is
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

    -- AXI Stream Data signals
    AXI_STR_TXD_ACLK       : in  std_logic;                                           --  AXI-Stream Transmit Data Clk
    reset2axi_str_txd      : in  std_logic;                                           --  AXI-Stream Transmit Data Reset
    AXI_STR_TXD_TVALID     : in  std_logic;                                           --  AXI-Stream Transmit Data Valid
    AXI_STR_TXD_TREADY     : out std_logic;                                           --  AXI-Stream Transmit Data Ready
    AXI_STR_TXD_TLAST      : in  std_logic;                                           --  AXI-Stream Transmit Data Last
    AXI_STR_TXD_TSTRB      : in  std_logic_vector(3 downto 0);                        --  AXI-Stream Transmit Data Keep
    AXI_STR_TXD_TDATA      : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);     --  AXI-Stream Transmit Data Data
    -- AXI Stream Control signals
    AXI_STR_TXC_ACLK       : in  std_logic;                                           --  AXI-Stream Transmit Control Clk
    reset2axi_str_txc      : in  std_logic;                                           --  AXI-Stream Transmit Control Reset
    AXI_STR_TXC_TVALID     : in  std_logic;                                           --  AXI-Stream Transmit Control Valid
    AXI_STR_TXC_TREADY     : out std_logic;                                           --  AXI-Stream Transmit Control Ready
    AXI_STR_TXC_TLAST      : in  std_logic;                                           --  AXI-Stream Transmit Control Last
    AXI_STR_TXC_TSTRB      : in  std_logic_vector(3 downto 0);                        --  AXI-Stream Transmit Control Keep
    AXI_STR_TXC_TDATA      : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);     --  AXI-Stream Transmit Control Data


    -- Write Port - AXI Stream TxData
    Axi_Str_TxD_2_Mem_Din  : out std_logic_vector(c_TxD_write_width_b-1 downto 0);    --  Tx AXI-Stream Data to Memory Wr Din
    Axi_Str_TxD_2_Mem_Addr : out std_logic_vector(c_TxD_addrb_width-1   downto 0);    --  Tx AXI-Stream Data to Memory Wr Addr
    Axi_Str_TxD_2_Mem_En   : out std_logic;                                           --  Tx AXI-Stream Data to Memory Enable
    Axi_Str_TxD_2_Mem_We   : out std_logic_vector(c_TxD_web_width-1     downto 0);    --  Tx AXI-Stream Data to Memory Wr En
    Axi_Str_TxD_2_Mem_Dout : in  std_logic_vector(c_TxD_read_width_b-1  downto 0);    --  Tx AXI-Stream Data to Memory Not Used

    -- Write Port - AXI Stream TxControl
    Axi_Str_TxC_2_Mem_Din  : out std_logic_vector(c_TxC_write_width_b-1 downto 0);    --  Tx AXI-Stream Control to Memory Wr Din
    Axi_Str_TxC_2_Mem_Addr : out std_logic_vector(c_TxC_addrb_width-1   downto 0);    --  Tx AXI-Stream Control to Memory Wr Addr
    Axi_Str_TxC_2_Mem_En   : out std_logic;                                           --  Tx AXI-Stream Control to Memory Enable
    Axi_Str_TxC_2_Mem_We   : out std_logic_vector(c_TxC_web_width-1     downto 0);    --  Tx AXI-Stream Control to Memory Wr En
    Axi_Str_TxC_2_Mem_Dout : in  std_logic_vector(c_TxC_read_width_b-1  downto 0);    --  Tx AXI-Stream Control to Memory Full Flag

    -- VLAN Signals
    tx_vlan_bram_addr      : out std_logic_vector(11 downto 0);                       --  Transmit VLAN BRAM Addr
    tx_vlan_bram_din       : in  std_logic_vector(13 downto 0);                       --  Transmit VLAN BRAM Rd Data
    tx_vlan_bram_en        : out std_logic;                                           --  Transmit VLAN BRAM Enable

    enable_newFncEn        : out std_logic; --Only perform VLAN when the FLAG = 0xA   --  Enable Extended VLAN Functions
    transMode_cross        : in  std_logic;                                           --  VLAN Translation Mode Control Bit
    tagMode_cross          : in  std_logic_vector( 1 downto 0);                       --  VLAN TAG Mode Control Bits
    strpMode_cross         : in  std_logic_vector( 1 downto 0);                       --  VLAN Strip Mode Control Bits

    tpid0_cross            : in  std_logic_vector(15 downto 0);                       --  VLAN TPID
    tpid1_cross            : in  std_logic_vector(15 downto 0);                       --  VLAN TPID
    tpid2_cross            : in  std_logic_vector(15 downto 0);                       --  VLAN TPID
    tpid3_cross            : in  std_logic_vector(15 downto 0);                       --  VLAN TPID

    newTagData_cross       : in  std_logic_vector(31 downto 0);                       --  VLAN Tag Data

    tx_init_in_prog        : out std_logic                                            --  Tx is Initializing after a reset

  );

end tx_axistream_if;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of tx_axistream_if is

begin

-------------------------------------------------------------------------------
--  Start Basic Design - No CSUM,  No Extended VLAN
-------------------------------------------------------------------------------
GEN_BASIC : if ( (C_TXCSUM  = 0 and (C_TXVLAN_TRAN = 0 and C_TXVLAN_TAG = 0 and C_TXVLAN_STRP = 0)) or
                 (C_TXCSUM /= 0 and (C_TXVLAN_TRAN = 1  or C_TXVLAN_TAG = 1  or C_TXVLAN_STRP = 1))) generate
begin


  tx_vlan_bram_addr <= (others => '0');
  tx_vlan_bram_en   <= '0';
  enable_newFncEn   <= '0';

  TX_BASIC_INTERFACE : entity axi_ethernet_v3_01_a.tx_basic_if(rtl)
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

    tx_init_in_prog        => tx_init_in_prog,             --  Tx is Initializing after a reset         
                                                                                                        
    -- AXI Stream Data signals                                                                          
    AXI_STR_TXD_ACLK       => AXI_STR_TXD_ACLK,            --  AXI-Stream Transmit Data Clk             
    reset2axi_str_txd      => reset2axi_str_txd,           --  AXI-Stream Transmit Data Reset           
    AXI_STR_TXD_TVALID     => AXI_STR_TXD_TVALID,          --  AXI-Stream Transmit Data Valid           
    AXI_STR_TXD_TREADY     => AXI_STR_TXD_TREADY,          --  AXI-Stream Transmit Data Ready           
    AXI_STR_TXD_TLAST      => AXI_STR_TXD_TLAST,           --  AXI-Stream Transmit Data Last            
    AXI_STR_TXD_TSTRB      => AXI_STR_TXD_TSTRB,           --  AXI-Stream Transmit Data Keep            
    AXI_STR_TXD_TDATA      => AXI_STR_TXD_TDATA,           --  AXI-Stream Transmit Data Data            
    -- AXI Stream Control signals                                                                       
    AXI_STR_TXC_ACLK       => AXI_STR_TXC_ACLK,            --  AXI-Stream Transmit Control Clk          
    reset2axi_str_txc      => reset2axi_str_txc,           --  AXI-Stream Transmit Control Reset        
    AXI_STR_TXC_TVALID     => AXI_STR_TXC_TVALID,          --  AXI-Stream Transmit Control Valid        
    AXI_STR_TXC_TREADY     => AXI_STR_TXC_TREADY,          --  AXI-Stream Transmit Control Ready        
    AXI_STR_TXC_TLAST      => AXI_STR_TXC_TLAST,           --  AXI-Stream Transmit Control Last         
    AXI_STR_TXC_TSTRB      => AXI_STR_TXC_TSTRB,           --  AXI-Stream Transmit Control Keep         
    AXI_STR_TXC_TDATA      => AXI_STR_TXC_TDATA,           --  AXI-Stream Transmit Control Data         
                                                                                                        
    -- Write Port - AXI Stream TxData                                                                   
    Axi_Str_TxD_2_Mem_Din  => Axi_Str_TxD_2_Mem_Din,       --  Tx AXI-Stream Data to Memory Wr Din      
    Axi_Str_TxD_2_Mem_Addr => Axi_Str_TxD_2_Mem_Addr,      --  Tx AXI-Stream Data to Memory Wr Addr     
    Axi_Str_TxD_2_Mem_En   => Axi_Str_TxD_2_Mem_En,        --  Tx AXI-Stream Data to Memory Enable      
    Axi_Str_TxD_2_Mem_We   => Axi_Str_TxD_2_Mem_We,        --  Tx AXI-Stream Data to Memory Wr En       
    Axi_Str_TxD_2_Mem_Dout => Axi_Str_TxD_2_Mem_Dout,      --  Tx AXI-Stream Data to Memory Not Used    
                                                                                                        
    -- Write Port - AXI Stream TxControl                                                                
    Axi_Str_TxC_2_Mem_Din  => Axi_Str_TxC_2_Mem_Din,       --  Tx AXI-Stream Control to Memory Wr Din   
    Axi_Str_TxC_2_Mem_Addr => Axi_Str_TxC_2_Mem_Addr,      --  Tx AXI-Stream Control to Memory Wr Addr  
    Axi_Str_TxC_2_Mem_En   => Axi_Str_TxC_2_Mem_En,        --  Tx AXI-Stream Control to Memory Enable   
    Axi_Str_TxC_2_Mem_We   => Axi_Str_TxC_2_Mem_We,        --  Tx AXI-Stream Control to Memory Wr En    
    Axi_Str_TxC_2_Mem_Dout => Axi_Str_TxC_2_Mem_Dout       --  Tx AXI-Stream Control to Memory Full Flag

  );

end generate GEN_BASIC;
-------------------------------------------------------------------------------
--  End Basic Design
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--  Start CSUM
-------------------------------------------------------------------------------
GEN_CSUM : if (C_TXCSUM  = 1 and (C_TXVLAN_TRAN = 0 and C_TXVLAN_TAG = 0 and C_TXVLAN_STRP = 0)) or
              (C_TXCSUM  = 2 and (C_TXVLAN_TRAN = 0 and C_TXVLAN_TAG = 0 and C_TXVLAN_STRP = 0)) generate
begin


  tx_vlan_bram_addr <= (others => '0');
  tx_vlan_bram_en   <= '0';
  enable_newFncEn   <= '0';

  TX_CSUM_INTERFACE : entity axi_ethernet_v3_01_a.tx_csum_if(rtl)
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

    tx_init_in_prog        => tx_init_in_prog,             --  Tx is Initializing after a reset         
                                                                                                        
    -- AXI Stream Data signals                                                                          
    AXI_STR_TXD_ACLK       => AXI_STR_TXD_ACLK,            --  AXI-Stream Transmit Data Clk             
    reset2axi_str_txd      => reset2axi_str_txd,           --  AXI-Stream Transmit Data Reset           
    AXI_STR_TXD_TVALID     => AXI_STR_TXD_TVALID,          --  AXI-Stream Transmit Data Valid           
    AXI_STR_TXD_TREADY     => AXI_STR_TXD_TREADY,          --  AXI-Stream Transmit Data Ready           
    AXI_STR_TXD_TLAST      => AXI_STR_TXD_TLAST,           --  AXI-Stream Transmit Data Last            
    AXI_STR_TXD_TSTRB      => AXI_STR_TXD_TSTRB,           --  AXI-Stream Transmit Data Keep            
    AXI_STR_TXD_TDATA      => AXI_STR_TXD_TDATA,           --  AXI-Stream Transmit Data Data            
    -- AXI Stream Control signals                                                                       
    AXI_STR_TXC_ACLK       => AXI_STR_TXC_ACLK,            --  AXI-Stream Transmit Control Clk          
    reset2axi_str_txc      => reset2axi_str_txc,           --  AXI-Stream Transmit Control Reset        
    AXI_STR_TXC_TVALID     => AXI_STR_TXC_TVALID,          --  AXI-Stream Transmit Control Valid        
    AXI_STR_TXC_TREADY     => AXI_STR_TXC_TREADY,          --  AXI-Stream Transmit Control Ready        
    AXI_STR_TXC_TLAST      => AXI_STR_TXC_TLAST,           --  AXI-Stream Transmit Control Last         
    AXI_STR_TXC_TSTRB      => AXI_STR_TXC_TSTRB,           --  AXI-Stream Transmit Control Keep         
    AXI_STR_TXC_TDATA      => AXI_STR_TXC_TDATA,           --  AXI-Stream Transmit Control Data         
                                                                                                        
    -- Write Port - AXI Stream TxData                                                                   
    Axi_Str_TxD_2_Mem_Din  => Axi_Str_TxD_2_Mem_Din,                                                    
    Axi_Str_TxD_2_Mem_Addr => Axi_Str_TxD_2_Mem_Addr,      --  Tx AXI-Stream Data to Memory Wr Din      
    Axi_Str_TxD_2_Mem_En   => Axi_Str_TxD_2_Mem_En,        --  Tx AXI-Stream Data to Memory Wr Addr     
    Axi_Str_TxD_2_Mem_We   => Axi_Str_TxD_2_Mem_We,        --  Tx AXI-Stream Data to Memory Enable      
    Axi_Str_TxD_2_Mem_Dout => Axi_Str_TxD_2_Mem_Dout,      --  Tx AXI-Stream Data to Memory Wr En       
                                                           --  Tx AXI-Stream Data to Memory Not Used    
    -- Write Port - AXI Stream TxControl                                                                
    Axi_Str_TxC_2_Mem_Din  => Axi_Str_TxC_2_Mem_Din,                                                    
    Axi_Str_TxC_2_Mem_Addr => Axi_Str_TxC_2_Mem_Addr,      --  Tx AXI-Stream Control to Memory Wr Din   
    Axi_Str_TxC_2_Mem_En   => Axi_Str_TxC_2_Mem_En,        --  Tx AXI-Stream Control to Memory Wr Addr  
    Axi_Str_TxC_2_Mem_We   => Axi_Str_TxC_2_Mem_We,        --  Tx AXI-Stream Control to Memory Enable   
    Axi_Str_TxC_2_Mem_Dout => Axi_Str_TxC_2_Mem_Dout       --  Tx AXI-Stream Control to Memory Wr En    
                                                           --  Tx AXI-Stream Control to Memory Full Flag
  );

end generate GEN_CSUM;
-------------------------------------------------------------------------------
--  End CSUM
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--  Start Extended VLAN
-------------------------------------------------------------------------------
GEN_EXT_VLAN : if ( C_TXCSUM  = 0 and (C_TXVLAN_TRAN = 1 or C_TXVLAN_TAG = 1 or C_TXVLAN_STRP = 1)) generate
begin

  TX_VLAN_INTERFACE : entity axi_ethernet_v3_01_a.tx_vlan_if(rtl)
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
                                                                 
    tx_init_in_prog        => tx_init_in_prog,        --  Tx is Initializing after a reset                                                
                                                                                                   
    -- AXI Stream Data signals                        --  AXI-Stream Transmit Data Clk             
    AXI_STR_TXD_ACLK       => AXI_STR_TXD_ACLK,       --  AXI-Stream Transmit Data Reset           
    reset2axi_str_txd      => reset2axi_str_txd,      --  AXI-Stream Transmit Data Valid           
    AXI_STR_TXD_TVALID     => AXI_STR_TXD_TVALID,     --  AXI-Stream Transmit Data Ready           
    AXI_STR_TXD_TREADY     => AXI_STR_TXD_TREADY,     --  AXI-Stream Transmit Data Last            
    AXI_STR_TXD_TLAST      => AXI_STR_TXD_TLAST,      --  AXI-Stream Transmit Data Keep            
    AXI_STR_TXD_TSTRB      => AXI_STR_TXD_TSTRB,      --  AXI-Stream Transmit Data Data            
    AXI_STR_TXD_TDATA      => AXI_STR_TXD_TDATA,                                                   
    -- AXI Stream Control signals                           
    AXI_STR_TXC_ACLK       => AXI_STR_TXC_ACLK,       --  AXI-Stream Transmit Control Clk          
    reset2axi_str_txc      => reset2axi_str_txc,      --  AXI-Stream Transmit Control Reset        
    AXI_STR_TXC_TVALID     => AXI_STR_TXC_TVALID,     --  AXI-Stream Transmit Control Valid        
    AXI_STR_TXC_TREADY     => AXI_STR_TXC_TREADY,     --  AXI-Stream Transmit Control Ready        
    AXI_STR_TXC_TLAST      => AXI_STR_TXC_TLAST,      --  AXI-Stream Transmit Control Last         
    AXI_STR_TXC_TSTRB      => AXI_STR_TXC_TSTRB,      --  AXI-Stream Transmit Control Keep         
    AXI_STR_TXC_TDATA      => AXI_STR_TXC_TDATA,      --  AXI-Stream Transmit Control Data                                                
                                                                                                   
    -- Write Port - AXI Stream TxData                                                              
    Axi_Str_TxD_2_Mem_Din  => Axi_Str_TxD_2_Mem_Din,  --  Tx AXI-Stream Data to Memory Wr Din                                                   
    Axi_Str_TxD_2_Mem_Addr => Axi_Str_TxD_2_Mem_Addr, --  Tx AXI-Stream Data to Memory Wr Addr     
    Axi_Str_TxD_2_Mem_En   => Axi_Str_TxD_2_Mem_En,   --  Tx AXI-Stream Data to Memory Enable      
    Axi_Str_TxD_2_Mem_We   => Axi_Str_TxD_2_Mem_We,   --  Tx AXI-Stream Data to Memory Wr En       
    Axi_Str_TxD_2_Mem_Dout => Axi_Str_TxD_2_Mem_Dout, --  Tx AXI-Stream Data to Memory Not Used    
                                                                                                   
    -- Write Port - AXI Stream TxControl                                                           
    Axi_Str_TxC_2_Mem_Din  => Axi_Str_TxC_2_Mem_Din,  --  Tx AXI-Stream Control to Memory Wr Din   
    Axi_Str_TxC_2_Mem_Addr => Axi_Str_TxC_2_Mem_Addr, --  Tx AXI-Stream Control to Memory Wr Addr  
    Axi_Str_TxC_2_Mem_En   => Axi_Str_TxC_2_Mem_En,   --  Tx AXI-Stream Control to Memory Enable   
    Axi_Str_TxC_2_Mem_We   => Axi_Str_TxC_2_Mem_We,   --  Tx AXI-Stream Control to Memory Wr En    
    Axi_Str_TxC_2_Mem_Dout => Axi_Str_TxC_2_Mem_Dout, --  Tx AXI-Stream Control to Memory Full Flag
                                                                                                   
    tx_vlan_bram_addr      => tx_vlan_bram_addr,      --  Transmit VLAN BRAM Addr                  
    tx_vlan_bram_din       => tx_vlan_bram_din,       --  Transmit VLAN BRAM Rd Data               
    tx_vlan_bram_en        => tx_vlan_bram_en,        --  Transmit VLAN BRAM Enable                
                                                                                                   
    enable_newFncEn        => enable_newFncEn,        --  Enable Extended VLAN Functions           
    transMode_cross        => transMode_cross,        --  VLAN Translation Mode Control Bit        
    tagMode_cross          => tagMode_cross,          --  VLAN TAG Mode Control Bits               
    strpMode_cross         => strpMode_cross,         --  VLAN Strip Mode Control Bits             
                                                                                                   
    tpid0_cross            => tpid0_cross,            --  VLAN TPID                                
    tpid1_cross            => tpid1_cross,            --  VLAN TPID                                
    tpid2_cross            => tpid2_cross,            --  VLAN TPID                                
    tpid3_cross            => tpid3_cross,            --  VLAN TPID                                
                                                                                                   
    newTagData_cross       => newTagData_cross        --  VLAN Tag Data                            
    );                                                     
                                                                                                        
end generate GEN_EXT_VLAN;
-------------------------------------------------------------------------------
--  Start Extended VLAN
-------------------------------------------------------------------------------
end rtl;
