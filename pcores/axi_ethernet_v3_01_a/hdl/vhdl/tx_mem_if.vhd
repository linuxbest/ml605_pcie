-------------------------------------------------------------------------------
-- tx_mem_if - entity/architecture pair
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
-- Filename:        tx_mem_if.vhd
-- Version:         v1.00a
-- Description:     embedded ip transmit interface AXI Stream memory
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
--          ->        tx_mem_if
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

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;



-------------------------------------------------------------------------------
--                  Entity Section
-------------------------------------------------------------------------------

entity tx_mem_if is
  generic (
    C_FAMILY               : string                      := "virtex6";

    -- Read Port - AXI Stream TxData
    c_TxD_write_width_a      : integer range   0 to 18     := 9;
    c_TxD_read_width_a       : integer range   0 to 18     := 9;
    c_TxD_write_depth_a      : integer range   0 to 32768  := 4096;
    c_TxD_read_depth_a       : integer range   0 to 32768  := 4096;
    c_TxD_addra_width        : integer range   0 to 15     := 10;
    c_TxD_wea_width          : integer range   0 to 2      := 2;
    -- Write Port - AXI Stream TxData
    c_TxD_write_width_b      : integer range  36 to 36     := 36;
    c_TxD_read_width_b       : integer range  36 to 36     := 36;
    c_TxD_write_depth_b      : integer range   0 to 8192   := 1024;
    c_TxD_read_depth_b       : integer range   0 to 8192   := 1024;
    c_TxD_addrb_width        : integer range   0 to 13     := 10;
    c_TxD_web_width          : integer range   0 to 4      := 4;

    -- Read Port - AXI Stream TxControl
    c_TxC_write_width_a      : integer range  36 to 36     := 36;
    c_TxC_read_width_a       : integer range  36 to 36     := 36;
    c_TxC_write_depth_a      : integer range   0 to 1024   := 1024;
    c_TxC_read_depth_a       : integer range   0 to 1024   := 1024;
    c_TxC_addra_width        : integer range   0 to 10     := 10;
    c_TxC_wea_width          : integer range   0 to 1      := 1;
    -- Write Port - AXI Stream TxControl
    c_TxC_write_width_b      : integer range   36 to 36    := 36;
    c_TxC_read_width_b       : integer range   36 to 36    := 36;
    c_TxC_write_depth_b      : integer range    0 to 1024  := 1024;
    c_TxC_read_depth_b       : integer range    0 to 1024  := 1024;
    c_TxC_addrb_width        : integer range    0 to 10    := 10;
    c_TxC_web_width          : integer range    0 to 1     := 1

  );
  port (
    -- Read Port - AXI Stream TxData
    TX_CLIENT_CLK             : in  std_logic;                                          --  Tx Client Clock
    reset2tx_client           : in  std_logic;                                          --  Reset
    Tx_Client_TxD_2_Mem_Din   : in  std_logic_vector(c_TxD_write_width_a-1 downto 0);   --  Tx Client Data Memory Wr Data
    Tx_Client_TxD_2_Mem_Addr  : in  std_logic_vector(c_TxD_addra_width-1   downto 0);   --  Tx Client Data Memory Address
    Tx_Client_TxD_2_Mem_En    : in  std_logic;                                          --  Tx Client Data Memory Enable
    Tx_Client_TxD_2_Mem_We    : in  std_logic_vector(c_TxD_wea_width-1     downto 0);   --  Tx Client Data Memory Wr Enable
    Tx_Client_TxD_2_Mem_Dout  : out std_logic_vector(c_TxD_read_width_a-1  downto 0);   --  Tx Client Data Memory Rd Data
    -- Write Port - AXI Stream TxData
    AXI_STR_TXD_ACLK          : in  std_logic;                                          --  AXI-Stream Tx Data Clock
    reset2axi_str_txd         : in  std_logic;                                          --  Reset
    Axi_Str_TxD_2_Mem_Din     : in  std_logic_vector(c_TxD_write_width_b-1 downto 0);   --  AXI-Stream Tx Data Memory Wr Data
    Axi_Str_TxD_2_Mem_Addr    : in  std_logic_vector(c_TxD_addrb_width-1   downto 0);   --  AXI-Stream Tx Data Memory Address
    Axi_Str_TxD_2_Mem_En      : in  std_logic;                                          --  AXI-Stream Tx Data Memory Enable
    Axi_Str_TxD_2_Mem_We      : in  std_logic_vector(c_TxD_web_width-1     downto 0);   --  AXI-Stream Tx Data Memory Wr Enable
    Axi_Str_TxD_2_Mem_Dout    : out std_logic_vector(c_TxD_read_width_b-1  downto 0);   --  AXI-Stream Tx Data Memory Rd Data

    -- Read Port - AXI Stream TxControl
    Tx_Client_TxC_2_Mem_Din   : in  std_logic_vector(c_TxC_write_width_a-1 downto 0);   --  Tx Client Control Memory Wr Data
    Tx_Client_TxC_2_Mem_Addr  : in  std_logic_vector(c_TxC_addra_width-1   downto 0);   --  Tx Client Control Memory Address
    Tx_Client_TxC_2_Mem_En    : in  std_logic;                                          --  Tx Client Control Memory Enable
    Tx_Client_TxC_2_Mem_We    : in  std_logic_vector(c_TxC_wea_width-1     downto 0);   --  Tx Client Control Memory Wr Enable
    Tx_Client_TxC_2_Mem_Dout  : out std_logic_vector(c_TxC_read_width_a-1  downto 0);   --  Tx Client Control Memory Rd Data
    -- Write Port - AXI Stream TxControl
    AXI_STR_TXC_ACLK          : in  std_logic;                                          --  AXI-Stream Tx Control Clock
    reset2axi_str_txc         : in  std_logic;                                          --  Reset
    Axi_Str_TxC_2_Mem_Din     : in  std_logic_vector(c_TxC_write_width_b-1 downto 0);   --  AXI-Stream Tx Control Memory Wr Data
    Axi_Str_TxC_2_Mem_Addr    : in  std_logic_vector(c_TxC_addrb_width-1   downto 0);   --  AXI-Stream Tx Control Memory Address
    Axi_Str_TxC_2_Mem_En      : in  std_logic;                                          --  AXI-Stream Tx Control Memory Enable
    Axi_Str_TxC_2_Mem_We      : in  std_logic_vector(c_TxC_web_width-1     downto 0);   --  AXI-Stream Tx Control Memory Wr Enable
    Axi_Str_TxC_2_Mem_Dout    : out std_logic_vector(c_TxC_read_width_b-1  downto 0)    --  AXI-Stream Tx Control Memory Rd Data
  );

end tx_mem_if;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture imp of tx_mem_if is

begin


  TXD_MEM : entity proc_common_v3_00_a.blk_mem_gen_wrapper(implementation)
  --BRAM between AXI Stream Interface and Tx Client Interface
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
    c_byte_size              => 9,   -- 8 or 9

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

    -- Port A Specific Configurations - 8bit bus
    c_has_mem_output_regs_a  => 0,   -- 0, 1
    c_has_mux_output_regs_a  => 0,   -- 0, 1
    c_write_width_a          => c_TxD_write_width_a,  -- 1 to 1152
    c_read_width_a           => c_TxD_read_width_a,  -- 1 to 1152
    c_write_depth_a          => c_TxD_write_depth_a,  -- 2 to 9011200
    c_read_depth_a           => c_TxD_read_depth_a,  -- 2 to 9011200
    c_addra_width            => c_TxD_addra_width,   -- 1 to 24
    c_write_mode_a           => "WRITE_FIRST",  -- Need to use "WRITE_FIRST" instead of "NO CHANGE" to use byte write enable
       -- "Write_First"
       -- "Read_first"
       -- "No_Change"
    c_has_ena                => 1,   -- 0, 1
    c_has_regcea             => 0,   -- 0, 1
    c_has_ssra               => 1,   -- 0, 1
    c_sinita_val             => "0", --"..."
    c_use_byte_wea           => 1,   -- 0, 1
    c_wea_width              => c_TxD_wea_width,   -- 1 to 128

    -- Port B Specific Configurations - 32bit bus
    c_has_mem_output_regs_b  => 0,   -- 0, 1
    c_has_mux_output_regs_b  => 0,   -- 0, 1
    c_write_width_b          => c_TxD_write_width_b,  -- 1 to 1152
    c_read_width_b           => c_TxD_read_width_b,  -- 1 to 1152
    c_write_depth_b          => c_TxD_write_depth_b,  -- 2 to 9011200
    c_read_depth_b           => c_TxD_read_depth_b,   -- 2 to 9011200
    c_addrb_width            => c_TxD_addrb_width,   -- 1 to 24
    c_write_mode_b           => "WRITE_FIRST",  -- Need to use "WRITE_FIRST" instead of "NO CHANGE" to use byte write enable
       -- "Write_First"
       -- "Read_first"
       -- "No_Change"
    c_has_enb                => 1,   -- 0, 1
    c_has_regceb             => 0,   -- 0, 1
    c_has_ssrb               => 1,   -- 0, 1
    c_sinitb_val             => "0", -- "..."
    c_use_byte_web           => 1,   -- 0, 1
    c_web_width              => c_TxD_web_width,   -- 1 to 128

    -- Other Miscellaneous Configurations
    c_mux_pipeline_stages    => 0,   -- 0, 1, 2, 3
       -- The number of pipeline stages within the MUX
       --    for both Port A and Port B
    c_use_ecc                => 0,
       -- See DS512 for the limited core option selections for ECC support
    c_use_ramb16bwer_rst_bhv => 0    --0, 1
  )
  port map  (
    -- Read Port
    clka    => TX_CLIENT_CLK,            --: in  std_logic;
    ssra    => reset2tx_client,          --: in  std_logic := '0';
    dina    => Tx_Client_TxD_2_Mem_Din,  --: in  std_logic_vector(c_write_width_a-1 downto 0) := (OTHERS => '0');
    addra   => Tx_Client_TxD_2_Mem_Addr, --: in  std_logic_vector(c_addra_width-1   downto 0);
    ena     => Tx_Client_TxD_2_Mem_En,   --: in  std_logic := '1';
    regcea  => '0',                      --: in  std_logic := '1';
    wea     => Tx_Client_TxD_2_Mem_We,   --: in  std_logic_vector(c_wea_width-1     downto 0) := (OTHERS => '0');
    douta   => Tx_Client_TxD_2_Mem_Dout, --: out std_logic_vector(c_read_width_a-1  downto 0);
    --  Write Port
    clkb    => AXI_STR_TXD_ACLK,         --: in  std_logic := '0';
    ssrb    => reset2axi_str_txd,        --: in  std_logic := '0';
    dinb    => Axi_Str_TxD_2_Mem_Din,    --: in  std_logic_vector(c_write_width_b-1 downto 0) := (OTHERS => '0');
    addrb   => Axi_Str_TxD_2_Mem_Addr,   --: in  std_logic_vector(c_addrb_width-1   downto 0) := (OTHERS => '0');
    enb     => Axi_Str_TxD_2_Mem_En,     --: in  std_logic := '1';
    regceb  => '0',                      --: in  std_logic := '1';
    web     => Axi_Str_TxD_2_Mem_We,     --: in  std_logic_vector(c_web_width-1     downto 0) := (OTHERS => '0');
    doutb   => Axi_Str_TxD_2_Mem_Dout,                 --: out std_logic_vector(c_read_width_b-1  downto 0);

    dbiterr => open,                 --: out std_logic;
                                     -- Double bit error that that cannot be auto corrected by ECC
    sbiterr => open                  --: out std_logic

  );



  TXC_MEM : entity proc_common_v3_00_a.blk_mem_gen_wrapper(implementation)
  --BRAM between AXI Stream Interface and Tx Client Interface
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
    c_byte_size              => 9,   -- 8 or 9

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
    c_use_default_data       => 1,   -- 0, 1
    c_default_data           => "0", -- "..."

    -- Port A Specific Configurations - 8bit bus
    c_has_mem_output_regs_a  => 0,   -- 0, 1
    c_has_mux_output_regs_a  => 0,   -- 0, 1
    c_write_width_a          => c_TxC_write_width_a,  -- 1 to 1152
    c_read_width_a           => c_TxC_read_width_a,  -- 1 to 1152
    c_write_depth_a          => c_TxC_write_depth_a,  -- 2 to 9011200
    c_read_depth_a           => c_TxC_read_depth_a,  -- 2 to 9011200
    c_addra_width            => c_TxC_addra_width,   -- 1 to 24
    c_write_mode_a           => "NO_CHANGE",
       -- "Write_First"
       -- "Read_first"
       -- "No_Change"
    c_has_ena                => 1,   -- 0, 1
    c_has_regcea             => 0,   -- 0, 1
    c_has_ssra               => 1,   -- 0, 1
    c_sinita_val             => "0", --"..."
    c_use_byte_wea           => 0,   -- 0, 1
    c_wea_width              => c_TxC_wea_width,   -- 1 to 128

    -- Port B Specific Configurations - 32bit bus
    c_has_mem_output_regs_b  => 0,   -- 0, 1
    c_has_mux_output_regs_b  => 0,   -- 0, 1
    c_write_width_b          => c_TxC_write_width_b,  -- 1 to 1152
    c_read_width_b           => c_TxC_read_width_b,  -- 1 to 1152
    c_write_depth_b          => c_TxC_write_depth_b,  -- 2 to 9011200
    c_read_depth_b           => c_TxC_read_depth_b,   -- 2 to 9011200
    c_addrb_width            => c_TxC_addrb_width,   -- 1 to 24
    c_write_mode_b           => "NO_CHANGE",
       -- "Write_First"
       -- "Read_first"
       -- "No_Change"
    c_has_enb                => 1,   -- 0, 1
    c_has_regceb             => 0,   -- 0, 1
    c_has_ssrb               => 1,   -- 0, 1
    c_sinitb_val             => "0", -- "..."
    c_use_byte_web           => 0,   -- 0, 1
    c_web_width              => c_TxC_web_width,   -- 1 to 128

    -- Other Miscellaneous Configurations
    c_mux_pipeline_stages    => 0,   -- 0, 1, 2, 3
       -- The number of pipeline stages within the MUX
       --    for both Port A and Port B
    c_use_ecc                => 0,
       -- See DS512 for the limited core option selections for ECC support
    c_use_ramb16bwer_rst_bhv => 0    --0, 1
  )
  port map  (
    -- Read Port
    clka    => TX_CLIENT_CLK,            --: in  std_logic;
    ssra    => reset2tx_client,          --: in  std_logic := '0';
    dina    => Tx_Client_TxC_2_Mem_Din,  --: in  std_logic_vector(c_write_width_a-1 downto 0) := (OTHERS => '0');
    addra   => Tx_Client_TxC_2_Mem_Addr, --: in  std_logic_vector(c_addra_width-1   downto 0);
    ena     => Tx_Client_TxC_2_Mem_En,   --: in  std_logic := '1';
    regcea  => '0',                      --: in  std_logic := '1';
    wea     => Tx_Client_TxC_2_Mem_We,   --: in  std_logic_vector(c_wea_width-1     downto 0) := (OTHERS => '0');
    douta   => Tx_Client_TxC_2_Mem_Dout, --: out std_logic_vector(c_read_width_a-1  downto 0);
    --  Write Port
    clkb    => AXI_STR_TXC_ACLK,         --: in  std_logic := '0';
    ssrb    => reset2axi_str_txc,        --: in  std_logic := '0';
    dinb    => Axi_Str_TxC_2_Mem_Din,    --: in  std_logic_vector(c_write_width_b-1 downto 0) := (OTHERS => '0');
    addrb   => Axi_Str_TxC_2_Mem_Addr,   --: in  std_logic_vector(c_addrb_width-1   downto 0) := (OTHERS => '0');
    enb     => Axi_Str_TxC_2_Mem_En,     --: in  std_logic := '1';
    regceb  => '0',                      --: in  std_logic := '1';
    web     => Axi_Str_TxC_2_Mem_We,     --: in  std_logic_vector(c_web_width-1     downto 0) := (OTHERS => '0');
    doutb   => Axi_Str_TxC_2_Mem_Dout,   --: out std_logic_vector(c_read_width_b-1  downto 0);

    dbiterr => open,                 --: out std_logic;
                                     -- Double bit error that that cannot be auto corrected by ECC
    sbiterr => open                  --: out std_logic

  );

end imp;
