-------------------------------------------------------------------------------
-- tx_basic_if - entity/architecture pair
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
-- Filename:        tx_basic_if.vhd
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
--                    tx_axistream_if.vhd
--          ->          tx_basic_if.vhd
--                      tx_csum_if.vhd
--                        tx_csum_partial_if.vhd
--                          tx_csum_partial_calc_if.vhd
--                        tx_full_csum_if.vhd
--                      tx_vlan_if.vhd
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

library proc_common_v3_00_a;
use proc_common_v3_00_a.blk_mem_gen_wrapper;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

-------------------------------------------------------------------------------
--                  Entity Section
-------------------------------------------------------------------------------

entity tx_basic_if is
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

end tx_basic_if;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of tx_basic_if is

-------------------------------------------------------------------------------
--  Start Basic Design - No CSUM,  No Extended VLAN
-------------------------------------------------------------------------------

  constant zeroes_txc    : std_logic_vector(c_TxC_write_width_b -1 downto c_TxC_addrb_width) := (others => '0');
  constant zeroes_txd    : std_logic_vector(c_TxC_write_width_b -1 downto c_TxD_addrb_width) := (others => '0');
  constant zeroes_txd_2  : std_logic_vector(c_TxC_write_width_b -1 downto c_TxD_addrb_width + 2 ) := (others => '0');

  type TXC_WR_FSM_TYPE is (
                       TXC_ADDR2_WR,
                       TXC_ADDR0_WR,
                       WAIT_WR_CMPLT,
                       TXC_WD0,
--                       WAIT_TXD_FULL,
                       TXC_WD1,
                       WAIT_ADDR2_COMPARE_CMPLT,--added for BRAM async clocks
                       TXC_WD2,
                       TXC_WD3,
                       TXC_WD4,
                       WAIT_ADDR0_COMPARE_CMPLT,--added for BRAM async clocks
                       TXC_WD5,
                       WAIT_TXD_CMPLT,
                       WAIT_TXD_MEM,
                       WR_TXC_PNTR,
                       WR_TXD_END_PNTR
                      );
  signal txc_wr_cs, txc_wr_ns             : TXC_WR_FSM_TYPE;

  type TXD_WR_FSM_TYPE is (
                       IDLE,
                       TXD_PRM,
                       TXD_WRT,
                       MEM_FULL,
                       CLR_FULL,
                       WAIT_WR1,
                       WAIT_WR2,
                       WAIT_COMPARE_CMPLT
                      );
  signal txd_wr_cs, txd_wr_ns             : TXD_WR_FSM_TYPE;

  signal txc_min_wr_addr                  : std_logic_vector(c_TxC_addrb_width -1 downto 0);
  signal txc_rsvd_wr_addr                 : std_logic_vector(c_TxC_addrb_width -1 downto 0);
  signal txc_max_wr_addr                  : std_logic_vector(c_TxC_addrb_width -1 downto 0);

  signal txc_wr_addr0                     : std_logic_vector(c_TxC_addrb_width -1 downto 0);
  signal txc_wr_addr1                     : std_logic_vector(c_TxC_addrb_width -1 downto 0);
  signal txc_wr_addr2                     : std_logic_vector(c_TxC_addrb_width -1 downto 0);
  signal txc_wr_addr3                     : std_logic_vector(c_TxC_addrb_width -1 downto 0);
  signal txc_wr_addr5                     : std_logic_vector(c_TxC_addrb_width -1 downto 0);
  signal txc_wr_addr6                     : std_logic_vector(c_TxC_addrb_width -1 downto 0);

  signal axi_str_txc_tready_int           : std_logic;
  signal axi_str_txc_tready_int_dly       : std_logic;
  signal axi_str_txc_tvalid_dly0          : std_logic;
  signal axi_str_txc_tlast_dly0           : std_logic;
--  signal axi_str_txc_tstrb_dly0           : std_logic_vector(3 downto 0);
  signal axi_str_txc_tdata_dly0           : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal clr_txc_trdy                     : std_logic;

  signal axi_str_txd_tready_int           : std_logic;
  signal axi_str_txd_tready_int_dly       : std_logic;
  signal axi_str_txd_tvalid_dly0          : std_logic;
  signal axi_str_txd_tlast_dly0           : std_logic;
  signal axi_str_txd_tstrb_dly0           : std_logic_vector(3 downto 0);
  signal axi_str_txd_tdata_dly0           : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal axi_str_txd_tdata_dly1           : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal clr_txd_trdy                     : std_logic;

  signal set_txc_addr_0                   : std_logic;
  signal txc_addr_0_dly1                  : std_logic;
  signal txc_addr_0_dly2                  : std_logic;
  signal set_txc_addr_1                   : std_logic;
  signal txc_addr_1                       : std_logic;
  signal set_txc_addr_2                   : std_logic;
  signal txc_addr_2                       : std_logic;
  signal set_txc_addr_4_n                 : std_logic;
  signal set_txc_addr_3                   : std_logic;
  signal clr_txc_addr_3                   : std_logic;
  signal txc_addr_3_dly                   : std_logic;
  signal txc_addr_3_dly2                  : std_logic;
  signal txc_addr_3_dly3                  : std_logic;
  signal inc_txd_addr_one                 : std_logic;
  signal set_txc_trdy                     : std_logic;
  signal set_txc_trdy2                    : std_logic;
  signal clr_txc_trdy2                    : std_logic;
  signal set_txcwr_rd_addr                : std_logic;
  signal set_txcwr_wr_end                 : std_logic;
  signal set_txc_en                       : std_logic;
  signal set_txc_we                       : std_logic;
  signal txc_we                           : std_logic;
  signal txc_we_dly1                      : std_logic;
  signal txc_we_dly2                      : std_logic;
  signal addr_2_en                        : std_logic;
  signal addr_2_en_dly1                   : std_logic;
  signal addr_2_en_dly2                   : std_logic;

  signal txc_mem_full                     : std_logic;
  signal txc_mem_not_full                 : std_logic;
  signal txc_mem_afull                    : std_logic;
  signal txc_mem_wr_addr                  : std_logic_vector(c_TxC_addrb_width   -1 downto 0);
  signal txc_mem_wr_addr_0                : std_logic_vector(c_TxC_addrb_width   -1 downto 0);
  signal txc_mem_wr_addr_1                : std_logic_vector(c_TxC_addrb_width   -1 downto 0);
  signal txc_mem_wr_addr_last             : std_logic_vector(c_TxC_addrb_width   -1 downto 0);

  signal Axi_Str_TxC_2_Mem_Addr_int       : std_logic_vector(c_TxC_addrb_width   -1 downto 0);
  signal Axi_Str_TxC_2_Mem_We_int         : std_logic_vector(0 downto 0);
  signal txc_mem_wr_addr_plus1            : std_logic_vector(c_TxC_addrb_width   -1 downto 0);
  signal txc_mem_wr_addr_plus2            : std_logic_vector(c_TxC_addrb_width   -1 downto 0);
  signal txc_rd_addr2_pntr                : std_logic_vector(c_TxC_addrb_width   -1 downto 0);
  signal txc_rd_addr2_pntr_1              : std_logic_vector(c_TxC_addrb_width   -1 downto 0);


  -- Set to the full width of the write data bus
  signal Axi_Str_TxC_2_Mem_Din_int        : std_logic_vector(c_TxC_write_width_b -1 downto 0);

  signal set_axi_flag                     : std_logic;
  signal set_csum_cntrl                   : std_logic;
  signal set_csum_begin_insert            : std_logic;
  signal set_csum_rsvd_init               : std_logic;
  signal axi_flag                         : std_logic_vector( 3 downto 0);
  signal csum_cntrl                       : std_logic_vector( 1 downto 0);

  signal set_first_packet                 : std_logic;
  signal wrote_first_packet               : std_logic;
  signal inc_txd_wr_addr                  : std_logic;
  signal set_txd_we                       : std_logic_vector( 3 downto 0);
  signal set_txd_en                       : std_logic;
  signal set_txd_rdy                      : std_logic;
  signal clr_txd_rdy                      : std_logic;
  signal clr_full_pntr                    : std_logic;
  signal halt_pntr_update                 : std_logic;
  signal disable_txd_trdy                 : std_logic;
  signal disable_txd_trdy_dly             : std_logic;
  signal disable_txc_trdy                 : std_logic;
  signal disable_txc_trdy_dly             : std_logic;

  signal txd_rdy                          : std_logic;
  signal axi_str_txd_2_mem_addr_int       : std_logic_vector(c_TxD_addrb_width   -1 downto 0);
  signal axi_str_txd_2_mem_addr_int_plus1 : std_logic_vector(c_TxD_addrb_width   -1 downto 0);
  signal axi_str_txd_2_mem_addr_int_plus2 : std_logic_vector(c_TxD_addrb_width   -1 downto 0);
  signal axi_str_txd_2_mem_addr_int_plus3 : std_logic_vector(c_TxD_addrb_width   -1 downto 0);
  signal axi_str_txd_2_mem_addr_int_plus4 : std_logic_vector(c_TxD_addrb_width   -1 downto 0);
  signal txd_mem_full                     : std_logic;
  signal txd_mem_not_full                 : std_logic;
  signal txd_mem_afull                    : std_logic;
  signal axi_str_txd_2_mem_we_int         : std_logic_vector( 3 downto 0);
  signal axi_str_txd_2_mem_en_int         : std_logic;

  signal txd_rd_pntr                      : std_logic_vector(c_TxD_addrb_width -1 downto 0);
  signal txd_rd_pntr_1                    : std_logic_vector(c_TxD_addrb_width -1 downto 0);
  signal txd_rd_pntr_reg                  : std_logic_vector(c_TxD_addrb_width -1 downto 0);
  signal txd_min_wr_addr                  : std_logic_vector(c_TxD_addrb_width -1 downto 0);
  signal txd_max_wr_addr                  : std_logic_vector(c_TxD_addrb_width -1 downto 0);
  signal txd_max_wr_addr_minus4           : std_logic_vector(c_TxD_addrb_width -1 downto 0);
  signal txd_rd_pntr_hold_plus3           : std_logic_vector(c_TxD_addrb_width -1 downto 0);
  signal txd_rd_pntr_hold                 : std_logic_vector(c_TxD_addrb_width -1 downto 0);

  signal tx_init_in_prog_int              : std_logic;
  signal init_bram                        : std_logic;

  signal txc_rd_addr0                     : std_logic_vector(c_TxD_addrb_width   -1 downto 0);
  signal txc_rd_addr2                     : std_logic_vector(c_TxD_addrb_width   -1 downto 0);
  signal txc_rd_addr3                     : std_logic_vector(c_TxD_addrb_width   -1 downto 0);


  signal compare_addr0                    : std_logic;
  signal compare_addr0_cmplt              : std_logic;

  signal compare_addr2                    : std_logic;
  signal compare_addr2_cmplt              : std_logic;
  signal compare_addr2_cmplt_dly          : std_logic;

  signal update_bram_cnt                  : std_logic_vector(7 downto 0);

  signal enable_compare_addr0_cmplt       : std_logic;
  signal end_addr_byte_offset             : std_logic_vector(1 downto 0);
  signal check_full                       : std_logic;
  signal update_rd_pntrs                  : std_logic;

  begin

    -----------------------------------------------------------------------------
    --  The TxC BRAM is set up to to always store the current TxD Read and Write
    --    pointers in the first two locations (0x0 and 0x1) of the Memory
    --    respectivively.  The current TxC Read and write pointer are always
    --    stored in the the next two locations (0x2 and 0x3) of the Memory
    --    respectively.  The End addresses for each packet are then stored
    --    in the remaing Memory locations starting at address 0x4.  After
    --    the end pointer to the maximum address has been written, if the
    --    memory is not full, the address pointer will loop back to address
    --    0x4 and write the end pointer for the next packet.
    --
    --                                   BRAM
    --                             Write       Read
    --                           _____________________
    --                          |__________|_________| <-- TxD Rd Pointer
    --      TxD Wr Pointer -->  |__________|_________|
    --                          |__________|_________| <-- TxC Rd Pointer
    --      TxC Wr Pointer -->  |__________|_________|
    --      Packet 0 End   -->  |__________|_________|  --> Packet 0 End
    --      Packet 1 End   -->  |__________|_________|  --> Packet 1 End
    --      Packet 2 End   -->  |__________|_________|  --> Packet 2 End
    --         .                |__________|_________|         .
    --         .                |__________|_________|         .
    --         .                |__________|_________|         .
    --      Packet n End   -->  |__________|_________|  --> Packet n End
    --
    -----------------------------------------------------------------------------

    -----------------------------------------------------------------------------
    --  Create the full and empty comparison values for the S6 and V6 since
    --  1 S6 BRAM = 1/2 V6 BRAM
    -----------------------------------------------------------------------------
    GEN_TXC_MIN_MAX_WR_FLAG : for i in (c_TxC_addrb_width-1) downto 0 generate
      txc_min_wr_addr(i)  <= '1' when (i = 2)          else '0'; -- do not loop back to 0x0; loop to 0x4
      txc_max_wr_addr(i)  <= '0' when (i = 0 or i = 1) else '1';
      txc_wr_addr0(i)     <= '0';
      txc_wr_addr1(i)     <= '1' when (i = 0)          else '0';
      txc_wr_addr2(i)     <= '1' when (i = 1)          else '0';
      txc_wr_addr3(i)     <= '1' when (i = 0 or i = 1) else '0';
      txc_wr_addr5(i)     <= '1' when (i = 0 or i = 2) else '0';
      txc_wr_addr6(i)     <= '1' when (i = 1 or i = 2) else '0';
    end generate GEN_TXC_MIN_MAX_WR_FLAG;

    GEN_TXD_MIN_MAX_WR_FLAG : for i in (c_TxD_addrb_width-1) downto 0 generate
      txd_min_wr_addr(i)        <= '1' when (i = 0) else '0';
      txd_max_wr_addr_minus4(i) <= '0' when (i = 2) else '1';
      txd_max_wr_addr(i)        <= '1';
    end generate GEN_TXD_MIN_MAX_WR_FLAG;


    GEN_TXC_MIN_MAX_RD_FLAG : for i in (c_TxD_addrb_width-1) downto 0 generate
      txc_rd_addr0(i)     <= '0';
      txc_rd_addr2(i)     <= '1' when (i = 1)          else '0';
      txc_rd_addr3(i)     <= '1' when (i = 0 or i = 1) else '0';
    end generate GEN_TXC_MIN_MAX_RD_FLAG;




    -----------------------------------------------------------------------------
    -- Register the incoming AXI Stream Control Bus and control signals
    -----------------------------------------------------------------------------
    REG_TXC_CONTROL : process(AXI_STR_TXC_ACLK)
    begin
      if rising_edge(AXI_STR_TXC_ACLK) then
        if reset2axi_str_txc = '1' then
          axi_str_txc_tvalid_dly0 <= '0';
          axi_str_txc_tlast_dly0  <= '0';
          clr_txc_trdy           <= '0';
        else
          axi_str_txc_tvalid_dly0 <= axi_str_txc_tvalid;
          axi_str_txc_tlast_dly0  <= axi_str_txc_tlast;
          if axi_str_txc_tvalid = '1' and axi_str_txc_tlast = '1' and axi_str_txc_tready_int = '1' then
            clr_txc_trdy <= '1';
          else
            clr_txc_trdy <= '0';
          end if;
        end if;
      end if;
    end process;

    AXI_STR_TXC_TREADY <= axi_str_txc_tready_int;  --fix me  need to look at all txc control and TDX tlast

    -----------------------------------------------------------------------------
    -- Register the incoming AXI Stream Control Data Bus
    -----------------------------------------------------------------------------
    REG_TXC_IN : process(AXI_STR_TXC_ACLK)
    begin
      if rising_edge(AXI_STR_TXC_ACLK) then
--          axi_str_txc_tstrb_dly0  <= axi_str_txc_tstrb;
          axi_str_txc_tdata_dly0  <= axi_str_txc_tdata;
      end if;
    end process;    
    
    -----------------------------------------------------------------------------
    --  AXI Stream TX Control State Machine - combinational/combinatorial
    --    Used to register the incoming control and checksum information
    --    This state machine will throttle the Transmit AXI Stream Data state
    --      machine until after the control information has been received.
    -----------------------------------------------------------------------------
    FSM_AXISTRM_TXC_CMB : process (txc_wr_cs,axi_str_txc_tvalid_dly0,
      axi_str_txc_tlast_dly0,axi_str_txd_tlast_dly0,
      axi_str_txd_tvalid_dly0,txc_addr_3_dly,
      wrote_first_packet,axi_str_txc_tready_int_dly,axi_str_txd_tready_int_dly,
      disable_txd_trdy_dly,disable_txc_trdy_dly,
      compare_addr2_cmplt,compare_addr2_cmplt_dly,compare_addr0_cmplt,
      update_bram_cnt,txc_mem_full)
      
    begin


      set_axi_flag           <= '0';
      set_csum_cntrl         <= '0';
      set_csum_begin_insert  <= '0';
      set_csum_rsvd_init     <= '0';
      set_txc_addr_0         <= '0';
      set_txc_addr_1         <= '0';
      set_txc_addr_2         <= '0';
      set_txc_addr_3         <= '0';
      set_txc_addr_4_n       <= '0';
      clr_txc_addr_3         <= '0';
      set_txcwr_rd_addr      <= '0';  --  sets the write side, read address to 0x0
      set_txcwr_wr_end       <= '0';  --  writes the end address to the memory in the next available location
      set_txc_en             <= '0';  --  the enable bit to the write side of the memory
      set_txc_we             <= '0';  --  the write enable bit to the write side of the memory
      inc_txd_addr_one       <= '0';
      set_txc_trdy           <= '0';
      init_bram              <= '0';
      compare_addr2          <= '0';
      compare_addr0          <= '0';
      set_txc_trdy2          <= '0';
      clr_txc_trdy2          <= '0';
      enable_compare_addr0_cmplt <= '0';

      case txc_wr_cs is
        when TXC_ADDR2_WR =>
          set_txc_addr_2         <= '1';
          set_txc_en             <= '1';
          set_txc_we             <= '1';
          init_bram              <= '1';
          txc_wr_ns              <= TXC_ADDR0_WR;
        when TXC_ADDR0_WR =>
          set_txc_addr_0         <= '1';
          set_txc_en             <= '1';
          set_txc_we             <= '1';
          init_bram              <= '1';
          txc_wr_ns              <= WAIT_WR_CMPLT;
        when WAIT_WR_CMPLT =>
          set_txc_addr_0         <= '1';
          set_txc_en             <= '1';
          set_txc_we             <= '1';
          init_bram              <= '1';
          set_txc_trdy2          <= '1';
          txc_wr_ns              <= TXC_WD0;
        when TXC_WD0 =>
          if axi_str_txc_tvalid_dly0 = '1' and axi_str_txc_tready_int_dly = '1' and
             (wrote_first_packet = '0' or txc_addr_3_dly = '1') then
            set_txc_addr_2         <= '1';  --Set the address to get the TxC Rd Address Pointer
            set_txc_en             <= '1';
            set_axi_flag           <= '1';
            clr_txc_addr_3         <= '1';
            compare_addr2          <= '1';
            txc_wr_ns              <= TXC_WD1;
          else
            set_txc_addr_2         <= '0';  --Set the address to get the TxC Rd Address Pointer
            set_txc_en             <= '0';
            set_axi_flag           <= '0';
            clr_txc_addr_3         <= '0';
            compare_addr2          <= '0';
            txc_wr_ns              <= TXC_WD0;
          end if;

        when TXC_WD1 =>
          if axi_str_txc_tvalid_dly0 = '1' and axi_str_txc_tready_int_dly = '1' then
            set_txc_trdy2          <= '0';
            set_csum_cntrl         <= '1';
            set_txc_addr_2         <= '1';
            set_txc_en             <= '1';
            compare_addr2          <= '1';
            txc_wr_ns              <= TXC_WD2;--WAIT_ADDR2_COMPARE_CMPLT;
          elsif axi_str_txc_tvalid_dly0 = '1' and axi_str_txc_tready_int_dly = '0' then
          -- need to force txc trdy HIGH since TVALID throttled
            set_txc_trdy2          <= '1';
            set_csum_cntrl         <= '0';
            set_txc_addr_2         <= '1';
            set_txc_en             <= '1';
            compare_addr2          <= '1';
            txc_wr_ns              <= WAIT_ADDR2_COMPARE_CMPLT;
          else
            set_txc_trdy2          <= '0';
            set_csum_cntrl         <= '0';
            set_txc_addr_2         <= '1';
            set_txc_en             <= '1';
            compare_addr2          <= '1';
            txc_wr_ns              <= TXC_WD1;
          end if;

        when WAIT_ADDR2_COMPARE_CMPLT =>
        -- now clear txc trdy to only allow a one clock pulse HIGH
          clr_txc_trdy2          <= '1';
          set_txc_addr_2         <= '1';
          set_txc_en             <= '1';
          compare_addr2          <= '1';
          txc_wr_ns              <= TXC_WD1;

        when TXC_WD2 =>
        -- Txc Tready has already been disabled
        --  wait for compare_addr2_cmplt, then
        --  set_txc_trdy2 will force axi_str_txc_tready_int_dly HIGH
          if axi_str_txc_tvalid_dly0 = '1' and axi_str_txc_tready_int_dly = '1' then
            set_csum_begin_insert      <= '1';
            set_txc_addr_2         <= '0';
            set_txc_en             <= '0';
            compare_addr2          <= '0';
            set_txc_trdy2          <= '0';
            txc_wr_ns                  <= TXC_WD3;
          else
            if axi_str_txc_tvalid_dly0 = '0'  or
               (txc_mem_full = '1' and axi_str_txc_tvalid_dly0 = '1') then
            --  If full wait for FULL and TVALID
            --  This will allow next elsif to be hit properly
              set_csum_begin_insert  <= '0';
              set_txc_addr_2         <= '1';
              set_txc_en             <= '1';
              compare_addr2          <= '1';
              set_txc_trdy2          <= '0';
              txc_wr_ns              <= TXC_WD2;


            elsif axi_str_txc_tvalid_dly0 = '1' and
              (compare_addr2_cmplt = '1' or compare_addr2_cmplt_dly = '1') then
              --  when full is '0', only need compare_addr2_cmplt to set set_txc_trdy2
              --    which will then allow this state to be exited to TXD_WD3
              --  when full is '1', then will need compare_addr2_cmplt_dly to to set set_txc_trdy2
              --    which will then allow this state to be exited to TXD_WD3
              set_csum_begin_insert  <= '0';
              set_txc_addr_2         <= '0';
              set_txc_en             <= '0';
              compare_addr2          <= '0';
              set_txc_trdy2          <= '1';
              txc_wr_ns                  <= TXC_WD2;
            else
              set_csum_begin_insert  <= '0';
              set_txc_addr_2         <= '1';
              set_txc_en             <= '1';
              compare_addr2          <= '1';
              set_txc_trdy2          <= '0';
              txc_wr_ns                  <= TXC_WD2;
            end if;
          end if;
        when TXC_WD3 =>
          if axi_str_txc_tvalid_dly0 = '1' and axi_str_txc_tready_int_dly = '1' then
          --  This is the earliest state to check for TxC FULL from TXC_WD0 state addr_2
          --  Register data, then assert full = 2 clks from rd
          --    Not FULL so write TxC Write Pointer to addr 0x3
            set_csum_rsvd_init         <= '1';
            txc_wr_ns                  <= TXC_WD4;
          else
            set_csum_rsvd_init         <= '0';
            txc_wr_ns                  <= TXC_WD3;
          end if;
        when TXC_WD4 =>
          if axi_str_txc_tvalid_dly0 = '1' and axi_str_txc_tready_int_dly = '1' then
            set_txc_addr_0             <= '1';  --Set the address to get the TxD Rd Address Pointer
            set_txc_en                 <= '1';
            compare_addr0              <= '1';
            txc_wr_ns                  <= TXC_WD5;
          else
            set_txc_addr_0             <= '0';  --Set the address to get the TxD Rd Address Pointer
            set_txc_en                 <= '0';
            compare_addr0              <= '0';
            txc_wr_ns                  <= TXC_WD4;
          end if;
        when TXC_WD5 =>
          if axi_str_txc_tvalid_dly0 = '1' and axi_str_txc_tready_int_dly = '1' and axi_str_txc_tlast_dly0 = '1' then
            set_txc_addr_0             <= '1';
            set_txc_en                 <= '1';
            compare_addr0              <= '1';
            enable_compare_addr0_cmplt <= '1';
            txc_wr_ns                  <= WAIT_ADDR0_COMPARE_CMPLT;
          else
            set_txc_addr_0             <= '1';
            set_txc_en                 <= '1';
            compare_addr0              <= '1';
            enable_compare_addr0_cmplt <= '0';
            txc_wr_ns                  <= TXC_WD5;
          end if;
        when WAIT_ADDR0_COMPARE_CMPLT =>
          if compare_addr0_cmplt = '1' then
            set_txc_addr_1             <= '1'; -- this is one clock early, so do not set the we enable yet
            set_txc_en                 <= '1';
            set_txc_we                 <= '1';

            set_txc_addr_0             <= '0';
            set_txc_en                 <= '0';
            compare_addr0              <= '0';
            enable_compare_addr0_cmplt <= '0';
            txc_wr_ns                  <= WAIT_TXD_CMPLT;
          else
            set_txc_addr_1             <= '0';
            set_txc_en                 <= '0';
            set_txc_we                 <= '0';

            set_txc_addr_0             <= '1';
            set_txc_en                 <= '1';
            compare_addr0              <= '1';
            enable_compare_addr0_cmplt <= '1';
            txc_wr_ns                  <= WAIT_ADDR0_COMPARE_CMPLT;
          end if;



        when WAIT_TXD_CMPLT =>
          if axi_str_txd_tvalid_dly0 = '1' and axi_str_txd_tready_int_dly = '1'  and
             axi_str_txd_tlast_dly0 = '1' then
            set_txc_addr_0        <= '0';
            set_txc_addr_1        <= '1';
            set_txc_addr_2        <= '0';
            set_txc_en            <= '1';
            set_txc_we            <= '1';
            txc_wr_ns             <= WR_TXD_END_PNTR;
          elsif disable_txd_trdy_dly = '1' then
          -- Txd mem is full so get the current read pointer
          --  This can occure after tlast so check it in the following states
            set_txc_addr_0        <= '1';  --Set the address to get the TxD Rd Address Pointer
            set_txc_addr_1        <= '0';
            set_txc_addr_2        <= '0';
            set_txc_en            <= '1';
            set_txc_we            <= '0';
            txc_wr_ns             <= WAIT_TXD_MEM;
          elsif update_bram_cnt(7) = '1'  then
          --Writing the current TxC write pointer so the read side can monitor it
            set_txc_addr_1        <= '1';
            set_txc_addr_2        <= '0';
            set_txc_en            <= '1';
            set_txc_we            <= '1';
            txc_wr_ns             <= WAIT_TXD_CMPLT;
          else
            set_txc_addr_1        <= '0'; --Writing the current TxC write pointer so the read side can monitor it
            set_txc_addr_2        <= '0';
            set_txc_en            <= '0';
            set_txc_we            <= '0';
            txc_wr_ns             <= WAIT_TXD_CMPLT;
          end if;
        when WAIT_TXD_MEM =>
          if disable_txd_trdy_dly = '1' then
            -- Txd mem is full so get the current read pointer
            set_txc_addr_0        <= '1';  --Set the address to get the TxD Rd Address Pointer
            set_txc_addr_1        <= '0';
            set_txc_en            <= '1';
            set_txc_we            <= '0';
            txc_wr_ns             <= WAIT_TXD_MEM;
          else
            set_txc_addr_0        <= '0';
            set_txc_addr_1        <= '1'; -- this is one clock early, so do not set the we enable yet
            set_txc_en            <= '1';
            set_txc_we            <= '1';
            txc_wr_ns             <= WAIT_TXD_CMPLT;
          end if;
        when WR_TXD_END_PNTR =>
            inc_txd_addr_one      <= '1';
            set_txc_addr_4_n      <= '1'; -- Write the TxC End Value to address 0x4 - 0xn
            set_txc_en            <= '1';
            set_txc_we            <= '1';
            txc_wr_ns             <= WR_TXC_PNTR;

        when WR_TXC_PNTR =>
          if disable_txc_trdy_dly = '1' then
            set_txc_addr_0        <= '1';
            set_txc_addr_3        <= '0';
            set_txc_en            <= '1';
            set_txc_we            <= '0';  
            set_txc_trdy          <= '0';
            txc_wr_ns             <= WR_TXC_PNTR;
          else          
            set_txc_addr_0        <= '0'; -- Write the TxC end pointer value to start the tx clint FSM
            set_txc_addr_3        <= '1';
            set_txc_en            <= '1';
            set_txc_we            <= '1';            
            set_txc_trdy          <= '1';
            txc_wr_ns             <= TXC_WD0;
          end if;          
          
--        when WR_TXC_PNTR =>
--            set_txc_addr_3        <= '1'; -- Write the TxC end pointer value to start the tx clint FSM
--            set_txc_addr_0        <= '0';
--            set_txc_en            <= '1';
--            set_txc_we            <= '1';
--            txc_wr_ns             <= TXC_WD0;
                    
        when others =>
          txc_wr_ns                <= TXC_ADDR2_WR;
      end case;
    end process;

    -----------------------------------------------------------------------------
    -- AXI Stream TX Control State Machine Sequencer
    -----------------------------------------------------------------------------
    FSM_AXISTRM_TXC_SEQ : process (AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        if reset2axi_str_txc = '1' then
          txc_wr_cs <= TXC_ADDR2_WR;
        else
          txc_wr_cs <= txc_wr_ns;
        end if;
      end if;
    end process;


    -----------------------------------------------------------------------------
    -- Delay the last write to TxC memory of the first packet after reset
    -----------------------------------------------------------------------------
    TX_INIT_INDICATOR_DLYS : process (AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        if reset2axi_str_txc = '1' then
          txc_addr_3_dly2 <= '0';
          txc_addr_3_dly3 <= '0';
        else
          txc_addr_3_dly2 <= txc_addr_3_dly;
          txc_addr_3_dly3 <= txc_addr_3_dly2;
        end if;
      end if;

    end process;


    -----------------------------------------------------------------------------
    -- Use above delay to hold off Tx Client FSM from starting until all
    --    TxD and TxC pointer information has been written to memory
    --
    --    This signal goes through a clock crossing circuit before it is
    --      registered in the Tx Client clock domain and used to start the
    --      Tx Client Read FSM
    -----------------------------------------------------------------------------
    TX_INIT_INDICATOR : process (AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        if reset2axi_str_txc = '1' then
          tx_init_in_prog_int <= '1';
        else
          if txc_addr_3_dly3 = '1' then
            tx_init_in_prog_int <= '0';
          else
            tx_init_in_prog_int <= tx_init_in_prog_int;
          end if;
        end if;
      end if;
    end process;

    tx_init_in_prog <= tx_init_in_prog_int;

    -----------------------------------------------------------------------------
    -- Delay the enable to align with the Memory address
    -----------------------------------------------------------------------------
    TXC_ADDR_1_TXD_WR_PNTR : process (AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        if set_txc_addr_1 = '1' then
          txc_addr_1 <= '1';
        else
          txc_addr_1 <= '0';
        end if;
      end if;

    end process;


    -----------------------------------------------------------------------------
    -- Delay the enable to align with the Memory address
    -----------------------------------------------------------------------------
    TXC_ADDR_3_DELAY : process (AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        if reset2axi_str_txc = '1' or clr_txc_addr_3 = '1' then
          txc_addr_3_dly  <= '0';
        elsif set_txc_addr_3 = '1' then
          txc_addr_3_dly <= '1';
        else
          txc_addr_3_dly <= txc_addr_3_dly;
        end if;
      end if;

    end process;


    -----------------------------------------------------------------------------
    --  Generate address that will hold the End Address
    -----------------------------------------------------------------------------
    TXC_WR_ADDR : process(AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        if reset2axi_str_txc = '1' then
          txc_mem_wr_addr      <= txc_min_wr_addr;
          txc_mem_wr_addr_last <= txc_wr_addr3;
          txc_mem_wr_addr_0    <= txc_wr_addr5;
          txc_mem_wr_addr_1    <= txc_wr_addr6;
        else
          if set_txc_addr_3 = '1' then
            --  increment the address for the next packet
            --  use the delayed signal to increment after the current address
            --  can be written
            if txc_mem_wr_addr = txc_max_wr_addr then
              --  if the max address is reached, loop to address 0x4
              txc_mem_wr_addr      <= txc_mem_wr_addr_0;
              txc_mem_wr_addr_last <= txc_wr_addr3;
              txc_mem_wr_addr_0    <= txc_mem_wr_addr_1;  --plus1
              txc_mem_wr_addr_1    <= txc_wr_addr6;       --plus2
            else
              --  otherwise just increment it
              txc_mem_wr_addr      <= txc_mem_wr_addr_0;
              txc_mem_wr_addr_last <= txc_mem_wr_addr;
              txc_mem_wr_addr_0    <= txc_mem_wr_addr_1;
              txc_mem_wr_addr_1    <= txc_mem_wr_addr_1 + 1;
            end if;
          else -- Hold the current address until something changes
            txc_mem_wr_addr      <= txc_mem_wr_addr;
            txc_mem_wr_addr_last <= txc_mem_wr_addr_last;
            txc_mem_wr_addr_0    <= txc_mem_wr_addr_0;
            txc_mem_wr_addr_1    <= txc_mem_wr_addr_1;
          end if;
        end if;
      end if;
    end process;




    -----------------------------------------------------------------------------
    -- Delay the enable to align with the Memory address
    -----------------------------------------------------------------------------
    TXC_ADDR_0_DELAY : process (AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        txc_addr_0_dly1 <= set_txc_addr_0;
        txc_addr_0_dly2 <= txc_addr_0_dly1;
      end if;

    end process;


    -----------------------------------------------------------------------------
    --  Generate address that will hold the End Address
    -----------------------------------------------------------------------------
    MEM_TXC_WR_ADDR : process(AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then

        if set_txc_addr_4_n = '1' and set_txc_we = '1' then
          -- Provide the address for the End of packet address
          Axi_Str_TxC_2_Mem_Addr_int <= txc_mem_wr_addr;
        elsif set_txc_addr_3 = '1' and set_txc_we = '1' then
          Axi_Str_TxC_2_Mem_Addr_int <= txc_wr_addr3; --set txc wr pointer
        elsif txc_addr_2 = '1' and  (txc_we = '0' or init_bram = '1') then
          Axi_Str_TxC_2_Mem_Addr_int <= txc_wr_addr2; --get txc rd pointer
        elsif set_txc_addr_0 = '1' and (set_txc_we = '0' or init_bram = '1') then
          --  Monitor the read pointer for a full
          --  condition in the TxD Memory
          Axi_Str_TxC_2_Mem_Addr_int <= txc_wr_addr0;
        elsif set_txc_addr_1 = '1' then
          --  Set the TxD write pointer to
          Axi_Str_TxC_2_Mem_Addr_int <= txc_wr_addr1;
        else
          Axi_Str_TxC_2_Mem_Addr_int <= (others => '0');
        end if;
      end if;
    end process;

    Axi_Str_TxC_2_Mem_Addr <= Axi_Str_TxC_2_Mem_Addr_int;
    txc_mem_wr_addr_plus1  <= txc_mem_wr_addr_0;
    txc_mem_wr_addr_plus2  <= txc_mem_wr_addr_1;

    -----------------------------------------------------------------------------
    --  This process remaps the strobe signal to the byte address offset minus
    --  one byte.
    -----------------------------------------------------------------------------
    END_ADDRESS_BYTE_OFFSET : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txD = '1' then
          end_addr_byte_offset <= (others => '0');
        elsif axi_str_txd_tlast_dly0 = '1' and axi_str_txd_tvalid_dly0 = '1' and 
              axi_str_txd_tready_int_dly = '1' then
          case axi_str_txd_tstrb_dly0 is
            when "1111" => end_addr_byte_offset <= "11";
            when "0111" => end_addr_byte_offset <= "10";
            when "0011" => end_addr_byte_offset <= "01";
            when others => end_addr_byte_offset <= "00";
          end case;
        else
          end_addr_byte_offset <= end_addr_byte_offset;
        end if;
      end if;
    end process;


    -----------------------------------------------------------------------------
    --  Address to AXI Stream Data Memory
    -----------------------------------------------------------------------------
    MEM_TXC_WR_ADDR_VALUE : process(AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        if reset2axi_str_txc = '1' or init_bram = '1' then
          Axi_Str_TxC_2_Mem_Din_int <= (others => '0');
        elsif set_txc_addr_4_n = '1' then
        --write the ending address of the packet to memory minus one byte
          Axi_Str_TxC_2_Mem_Din_int <= zeroes_txd_2 & axi_str_txd_2_mem_addr_int & end_addr_byte_offset;
        elsif set_txc_addr_3 = '1' then
          Axi_Str_TxC_2_Mem_Din_int <= zeroes_txc & txc_mem_wr_addr;
        else
          Axi_Str_TxC_2_Mem_Din_int <= zeroes_txd & axi_str_txd_2_mem_addr_int_plus1;
        end if;
      end if;
    end process;

    Axi_Str_TxC_2_Mem_Din <= Axi_Str_TxC_2_Mem_Din_int;

  --  Axi_Str_TxC_2_Mem_En  <= '1';
    -----------------------------------------------------------------------------
    --  Address to AXI Stream Data Memory
    -----------------------------------------------------------------------------
    MEM_TXC_EN : process(AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        if (set_txc_en = '1' and set_txc_addr_2 = '0') or
           addr_2_en = '1' or init_bram = '1' then
          Axi_Str_TxC_2_Mem_En <= '1';
        else
          Axi_Str_TxC_2_Mem_En <= '0';
        end if;
      end if;
    end process;

    -----------------------------------------------------------------------------
    --  Address to AXI Stream Data Memory
    -----------------------------------------------------------------------------
    MEM_TXC_WR_EN : process(AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        if set_txc_we = '1' then
          Axi_Str_TxC_2_Mem_We_int(0) <= '1';
        else
          Axi_Str_TxC_2_Mem_We_int(0) <= '0';
        end if;
      end if;
    end process;

    Axi_Str_TxC_2_Mem_We <= Axi_Str_TxC_2_Mem_We_int;


    -----------------------------------------------------------------------------
    --  Delay set_txc_addr_2 to align with data
    -----------------------------------------------------------------------------
    TXC_ADDR2_DLY : process(AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        if set_txc_addr_2 = '1' then
          txc_addr_2  <= set_txc_addr_2;
        else
          txc_addr_2  <= '0';
        end if;
      end if;
    end process;

    -----------------------------------------------------------------------------
    --  Delay set_txc_we to align with address
    -----------------------------------------------------------------------------
    TXC_WE_DLY : process(AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        if set_txc_we = '1' then
          txc_we  <= set_txc_we;
        else
          txc_we  <= '0';
        end if;
        txc_we_dly1 <= txc_we;
        txc_we_dly2 <= txc_we_dly1;

      end if;
    end process;

    -----------------------------------------------------------------------------
    --  Delay set_txc_we to align with address
    -----------------------------------------------------------------------------
    ADDR2_MEM_EN : process(AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        if set_txc_addr_2 = '1' and  set_txc_en = '1' then
          addr_2_en  <= set_txc_en;
        else
          addr_2_en  <= '0';
        end if;
        addr_2_en_dly1 <= addr_2_en;
        addr_2_en_dly2 <= addr_2_en_dly1;
      end if;
    end process;

    -----------------------------------------------------------------------------
    --  Get the read pointer to check for FULL
    --  With ASYNC BRAM clock cannot read/write same address in memory at same
    --  time unless timing is met, so read until data matches
    -----------------------------------------------------------------------------
    MEM_TXC_RD_ADDR_PNTR : process(AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        if reset2axi_str_txc = '1' then
          txc_rd_addr2_pntr_1 <= (others => '0');
          txc_rd_addr2_pntr   <= txc_min_wr_addr;
          compare_addr2_cmplt <= '0';
          compare_addr2_cmplt_dly <= '0';
        else

          if set_txc_addr_2 = '1' and addr_2_en_dly2 = '1' and txc_we_dly2 = '0' then
            txc_rd_addr2_pntr_1 <= Axi_Str_TxC_2_Mem_Dout(c_TxC_addrb_width -1 downto 0);

            if Axi_Str_TxC_2_Mem_Dout(c_TxC_addrb_width -1 downto 0) = txc_rd_addr2_pntr_1  and
               compare_addr2_cmplt = '0' then
              txc_rd_addr2_pntr   <= txc_rd_addr2_pntr_1;
              compare_addr2_cmplt <= '1';
            else
              txc_rd_addr2_pntr   <= txc_rd_addr2_pntr;
              compare_addr2_cmplt <= '0';
            end if;

          else
            txc_rd_addr2_pntr_1 <= txc_rd_addr2_pntr_1;
            txc_rd_addr2_pntr   <= txc_rd_addr2_pntr;
            compare_addr2_cmplt <= '0';
          end if;
          compare_addr2_cmplt_dly <= compare_addr2_cmplt;

        end if;
      end if;
    end process;

    -----------------------------------------------------------------------------
    --  Full flag indicator
    --    Does not begin comparison until 1st packet is written to memory
    -----------------------------------------------------------------------------
    TXC_FULL_FLAG : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txc = '1' then
            txc_mem_full     <= '0';
            txc_mem_not_full <= '1';
        elsif txc_mem_full = '1' and
           compare_addr2_cmplt = '1' and compare_addr2_cmplt_dly = '0' then
           --increments after it goes full, so use txc_mem_wr_addr for compare
          if txc_mem_wr_addr /= txc_rd_addr2_pntr then
            txc_mem_full     <= '0';
            txc_mem_not_full <= '1';
          else
            txc_mem_full     <= txc_mem_full;
            txc_mem_not_full <= txc_mem_not_full;
          end if;
        elsif set_txc_addr_3 = '1' and set_txc_we = '1' then
          if txc_mem_wr_addr_plus1 = txc_rd_addr2_pntr then
            txc_mem_full     <= '1';
            txc_mem_not_full <= '0';
          else
            txc_mem_full     <= '0';
            txc_mem_not_full <= '1';
          end if;
        else
          txc_mem_full     <= txc_mem_full;
          txc_mem_not_full <= txc_mem_not_full;
        end if;
      end if;
    end process;

    TXC_AFULL_FLAG : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if txc_mem_wr_addr_plus2 = txc_rd_addr2_pntr then
          txc_mem_afull     <= '1';
        else
          txc_mem_afull     <= '0';
        end if;
      end if;
    end process;

    -----------------------------------------------------------------------------
    --  Throttle AXI Stream TxC
    --    Do not assert unless TxD is not in progress and the memory can
    --    accept data
    -----------------------------------------------------------------------------
    TXC_READY : process(AXI_STR_TXD_ACLK)
    begin



      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txc = '1' or clr_txc_trdy = '1' or clr_txc_trdy2 = '1' or
             set_txd_rdy = '1' or (txd_rdy = '1' and clr_txd_rdy = '0') or disable_txc_trdy = '1' or
             (AXI_STR_TXC_TLAST = '1' and AXI_STR_TXC_TVALID = '1' and axi_str_txc_tready_int = '1') or
             (compare_addr2 = '1' and axi_str_txc_tvalid_dly0 = '1' and axi_str_txc_tready_int_dly = '1') then
             --do not need compare_addr0 because will clr at TLAST
          axi_str_txc_tready_int <= '0';
        else

          if txc_addr_3_dly = '1' then
            if (txc_mem_wr_addr = txc_rd_addr2_pntr and txc_mem_full = '1') then
              axi_str_txc_tready_int <= '0';
            elsif txc_mem_wr_addr = txc_rd_addr2_pntr and
                Axi_Str_TxC_2_Mem_We_int(0) = '1' then
              axi_str_txc_tready_int <= '0';
            else
              axi_str_txc_tready_int <= axi_str_txc_tready_int;
            end if;
          elsif set_txc_trdy = '1' then
            axi_str_txc_tready_int <= '1';
          elsif set_txc_trdy2 = '1' then
          --  need to force it high after address compare and after reset
            axi_str_txc_tready_int <= '1';
          else
            axi_str_txc_tready_int <= axi_str_txc_tready_int;
          end if;
        end if;
        axi_str_txc_tready_int_dly <= axi_str_txc_tready_int;
      end if;
    end process;

    AXI_STR_TXC_TREADY <= axi_str_txc_tready_int;

    -----------------------------------------------------------------------------
    --  Register and hold the axi_flag information and CSUM Control information
    --    axi_flag
    --      0x5 = Status control
    --      0xA = Normal control
    --      0xF = Null Control
    --    CSUM
    --      00 = No CSUM will be performed
    --      01 = Partial Checksum will be performed
    --      10 = Full checksum offloading will be performed
    -----------------------------------------------------------------------------
    CNTRL_WD0 : process(AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        if reset2axi_str_txc = '1' then
          axi_flag   <= (others => '0');
        elsif set_axi_flag = '1' then
          axi_flag   <= axi_str_txc_tdata_dly0(31 downto 28);
        else
          axi_flag   <= axi_flag;
        end if;
      end if;
    end process;

    CNTRL_WD1 : process(AXI_STR_TXC_ACLK)
    begin

      if rising_edge(AXI_STR_TXC_ACLK) then
        if reset2axi_str_txc = '1' then
          csum_cntrl <= (others => '0');
        elsif set_csum_cntrl = '1' then
          csum_cntrl <= axi_str_txc_tdata_dly0 (1 downto  0);
        else
          csum_cntrl <= csum_cntrl;
        end if;
      end if;
    end process;

      ---------------------------------------------------------------------------
      --  Delay signal to load csum value in csum calculation
      ---------------------------------------------------------------------------
      CHECK_FULL_SIG : process(AXI_STR_TXC_ACLK)
      begin

        if rising_edge(AXI_STR_TXC_ACLK) then
          check_full <= set_txc_addr_4_n;
        end if;
      end process;



    -----------------------------------------------------------------------------
    -- Register the incoming AXI Stream Data Bus and control signals
    -----------------------------------------------------------------------------
    REG_TXD_CONTROL : process(AXI_STR_TXD_ACLK)
    begin
      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' then
          axi_str_txd_tvalid_dly0 <= '0';
          axi_str_txd_tlast_dly0  <= '0';
          clr_txd_trdy            <= '0';
        else
          axi_str_txd_tvalid_dly0 <= AXI_STR_TXD_TVALID;
          axi_str_txd_tlast_dly0  <= AXI_STR_TXD_TLAST;
          if axi_str_txd_tvalid = '1' and axi_str_txd_tlast = '1' and axi_str_txd_tready_int = '1' then
            clr_txd_trdy <= '1';
          else
            clr_txd_trdy <= '0';
          end if;
        end if;
      end if;
    end process;

    AXI_STR_TXD_TREADY <= axi_str_txd_tready_int;  --fix me  need to look at all txd control and TXC tlast

    -----------------------------------------------------------------------------
    -- Register the incoming AXI Stream Data Bus and control signals
    -----------------------------------------------------------------------------
    REG_TXD_IN : process(AXI_STR_TXD_ACLK)
    begin
      if rising_edge(AXI_STR_TXD_ACLK) then
        axi_str_txd_tstrb_dly0  <= AXI_STR_TXD_TSTRB;
        axi_str_txd_tdata_dly0  <= AXI_STR_TXD_TDATA;
      end if;
    end process;
    
    
    -----------------------------------------------------------------------------
    --  Delay the data one more clock for BRAM
    -----------------------------------------------------------------------------
    REG_TXD_DLY0 : process(AXI_STR_TXD_ACLK)
    begin
      if rising_edge(AXI_STR_TXD_ACLK) then
        if axi_str_txd_tvalid_dly0 = '1' and axi_str_txd_tready_int_dly = '1' then
          axi_str_txd_tdata_dly1  <= axi_str_txd_tdata_dly0;
        else
          axi_str_txd_tdata_dly1  <= axi_str_txd_tdata_dly1;
        end if;
      end if;
    end process;


    -----------------------------------------------------------------------------
    --  AXI Stream TX Data State Machine - combinational/combinatorial
    --    Used to provide the control to write the data to the BRAM
    --    This state machine will throttle the Transmit AXI Stream Control state
    --      machine until after the data information has been received.
    -----------------------------------------------------------------------------
    FSM_AXISTRM_TXD_CMB : process (txd_wr_cs,axi_str_txd_tvalid_dly0,
      axi_str_txd_tlast_dly0,
      axi_str_txd_tstrb_dly0,wrote_first_packet,axi_str_txd_tready_int_dly,
      txd_rd_pntr,txd_mem_full,txd_min_wr_addr,
      txd_rd_pntr_hold,txd_mem_afull,txd_rd_pntr_hold_plus3,
      compare_addr0_cmplt,
      axi_str_txd_2_mem_addr_int,txd_max_wr_addr,
      check_full,txd_max_wr_addr_minus4)
    begin

      inc_txd_wr_addr     <= '0';
      set_txd_we          <= "0000";
      set_txd_en          <= '0';
      set_first_packet    <= '0';
      set_txd_rdy         <= '0';
      clr_txd_rdy         <= '0';
      clr_full_pntr       <= '0';
      disable_txd_trdy    <= '0';
      disable_txc_trdy    <= '0';
      halt_pntr_update    <= '0';
      update_rd_pntrs     <= '0';

      case txd_wr_cs is
        when IDLE =>
          if compare_addr0_cmplt = '1' then
          --  Requirement is that the TXD and TXC interfaces use the same clock
          --    so it is OK to used the TXC signals in the TXD state machine
            set_txd_rdy <= '1';
            txd_wr_ns   <= TXD_PRM;
          else
            set_txd_rdy <= '0';
            txd_wr_ns   <= IDLE;
          end if;
        when TXD_PRM =>
--      Made change to ensure TxD Memory is never full here.
--      The memory can always accept data at the start of a transfer
          if axi_str_txd_tvalid_dly0 = '1' and axi_str_txd_tready_int_dly = '1' then
          --  delay incrementing pointer until next data
          --    Ethernet has to send 14bytes as a bare minimum, so it is
          --    guaranteed to get through this state with all of the strobes set
          --    and TLAST = '0'
            set_txd_we          <= axi_str_txd_tstrb_dly0;
            set_txd_en          <= '1';
            disable_txd_trdy      <= '0';
            txd_wr_ns           <= TXD_WRT;
          else
            set_txd_we          <= "0000";
            set_txd_en          <= '0';
            disable_txd_trdy      <= '0';
            txd_wr_ns           <= TXD_PRM;
          end if;
        when  TXD_WRT =>
          if txd_mem_full = '1' and axi_str_txd_tready_int_dly = '0' then
          --memory is full when axi_str_txd_tready_int_dly = '0'
            inc_txd_wr_addr     <= '0';
            set_txd_we          <= "0000";
            set_txd_en          <= '0';
            set_first_packet    <= '0';
            clr_txd_rdy         <= '0';
            disable_txd_trdy    <= '1';
            txd_wr_ns           <= MEM_FULL;
          elsif axi_str_txd_tvalid_dly0 = '1' and axi_str_txd_tready_int_dly = '1' then
            inc_txd_wr_addr     <= '1';
            set_txd_we          <= axi_str_txd_tstrb_dly0;
            set_txd_en          <= '1';
            if axi_str_txd_tlast_dly0 = '1' then
              if wrote_first_packet = '0' then
                set_first_packet <= '1';
              else
                set_first_packet <= '0';
              end if;

              clr_txd_rdy         <= '1';
              disable_txc_trdy    <= '1';
              disable_txd_trdy    <= '0';
              txd_wr_ns           <= WAIT_WR1;
            else
            --  received data (normal receive), so continue receiving data
              set_first_packet    <= '0';
              clr_txd_rdy         <= '0';
              disable_txd_trdy    <= '0';
              txd_wr_ns           <= TXD_WRT;
            end if;
          else
            inc_txd_wr_addr     <= '0';
            set_txd_we          <= "0000";
            set_txd_en          <= '0';
            set_first_packet    <= '0';
            clr_txd_rdy         <= '0';
            disable_txd_trdy    <= '0';
            txd_wr_ns           <= TXD_WRT;
          end if;
       when MEM_FULL =>
          --  stay here until the read pointer updates by 4 words or more.  The read side operates on bytes,
          --  the write side operates on words.
          --    The read pointer updates every 512 bytes (128 words) and at the end of a packet.
          --      The samallest packet the can be sent is 15bytes, but since the BRAM is 32 bit aligned,
          --      the read side will usually update the read pointer by a minimum of 16 bytes (4 words).  However,
          --      it can update by by less than 16 bytes (4 words).  This can occure if a packet started at read
          --      address 0x1A4 (write address 0x69), and the packet is 516 bytes in length (129 words).  Here the read pointer
          --      will update at 0x3A4 (write address 0xE9 - 128 words) then again at the end of the packet at 0x3A8
          --      (write address 0xEA).
          --        If this occures the below logic will detect it and update the read pointer, but stay in this
          --        state until the next update occurs.  The next update is guaranteed to be greater than 4 words,
          --        which will allow the full pointers to be cleared for the next packet.
          inc_txd_wr_addr     <= '0';
          set_txd_we          <= "0000";
          set_txd_en          <= '0';
          set_first_packet    <= '0';
          clr_txd_rdy         <= '0';
          if txd_rd_pntr = txd_rd_pntr_hold then
          --  stay here until an update occurs
            update_rd_pntrs  <= '0';
            disable_txd_trdy <= '1';
            clr_full_pntr    <= '0';
            txd_wr_ns        <= MEM_FULL;
          else
          --  The read pointer was updated to determine if it was updated by 4 words or more
          --    If not, update the hold pointers, but stay in this state
            if txd_rd_pntr_hold <= txd_max_wr_addr_minus4 then
            --  for 2048 mem this covers from txd_rd_pntr_hold = 0x0 - 0x1FB
              if txd_rd_pntr > txd_rd_pntr_hold_plus3 then
              -- an update of 4 words or greater occured so exit this state
                update_rd_pntrs  <= '0';
                disable_txd_trdy <= '0';
                clr_full_pntr    <= '1';
                txd_wr_ns        <= TXD_WRT;
              else
              --  the update was less than 4 words
              --    (txd_rd_pntr <= txd_rd_pntr_hold_plus3)
                if txd_rd_pntr < txd_rd_pntr_hold then
                --  the read pointer wrapped, so exit because the update was > 4 words
                  update_rd_pntrs  <= '0';
                  disable_txd_trdy <= '0';
                  clr_full_pntr    <= '1';
                  txd_wr_ns        <= TXD_WRT;
                else
                --  the update was less than 4 words, so update the read hold pointers and stay here until the next update
                --    txd_rd_pntr >= txd_rd_pntr_hold
                  update_rd_pntrs  <= '1';
                  disable_txd_trdy <= '1';
                  clr_full_pntr    <= '0';
                  txd_wr_ns        <= MEM_FULL;
                end if;
              end if;
            else
            --  for 2048 mem this covers from txd_rd_pntr_hold = 0x1FC- 0x1FF
              if txd_rd_pntr_hold_plus3 = txd_max_wr_addr then
              --  txd_rd_pntr = 0x1FC for 2048 byte memory, so txd_rd_pntr_hold_plus3 = max memory size
                if (txd_rd_pntr <= txd_rd_pntr_hold) then
                --  the update was >= 4 words so exit
                --    for a 2048 memory, txd_rd_pntr_hold = 0x1FC
                --      if txd_rd_pntr is between 0x0 and 0x1FB then an update of 4 or more words occurred
                  update_rd_pntrs  <= '0';
                  disable_txd_trdy <= '0';
                  clr_full_pntr    <= '1';
                  txd_wr_ns        <= TXD_WRT;
                else
                --  the update was less than 4 words, so update the read hold pointers and stay here until the next update
                --    txd_rd_pntr >= txd_rd_pntr_hold
                  update_rd_pntrs  <= '1';
                  disable_txd_trdy <= '1';
                  clr_full_pntr    <= '0';
                  txd_wr_ns        <= MEM_FULL;
                end if;
              else
              --  txd_rd_pntr = 0x1FD, 0x1FE, or 0x1FF for 2048 byte memory,
              --  so the minimum txd_rd_pntr_hold_plus3 can be is 0, 1, or 2
                if (txd_rd_pntr > txd_rd_pntr_hold_plus3) and (txd_rd_pntr < txd_rd_pntr_hold) then
                --  txd_rd_pntr_hold will be either 0x1FD, 0x1FE, or 0x1FF for a 2048 byte memory
                --    if txd_rd_pntr >  txd_rd_pntr_hold and  txd_rd_pntr <  txd_rd_pntr_hold
                --      then the update was >= 4 words and the state can be exited
                --          if  txd_rd_pntr_hold = 0x1FD then  txd_rd_pntr_hold_plus3 = 0
                --            txd_rd_pntr has to be tween 0x1 and 0x1FC to exit this state
                --          if  txd_rd_pntr_hold = 0x1FE then  txd_rd_pntr_hold_plus3 = 1
                --            txd_rd_pntr has to be tween 0x2 and 0x1FD to exit this state
                --          if  txd_rd_pntr_hold = 0x1FF then  txd_rd_pntr_hold_plus3 = 2
                --            txd_rd_pntr has to be tween 0x3 and 0x1FE to exit this state
                  update_rd_pntrs  <= '0';
                  disable_txd_trdy <= '0';
                  clr_full_pntr    <= '1';
                  txd_wr_ns        <= TXD_WRT;
                else
                --  txd_rd_pntr did not update by 4 or more words, so update hold poointers and stay in this state
                --  txd_rd_pntr_hold will be either 0x1FD, 0x1FE, or 0x1FF for a 2048 byte memory
                --    if txd_rd_pntr >  txd_rd_pntr_hold and  txd_rd_pntr <  txd_rd_pntr_hold
                --      then the update was >= 4 words and the state can be exited BUT
                --          if  txd_rd_pntr_hold = 0x1FD then  txd_rd_pntr_hold_plus3 = 0
                --            txd_rd_pntr was only updated 1-3 words to 0x1FE, 0x1FF, or 0x0, so stay here
                --          if  txd_rd_pntr_hold = 0x1FE then  txd_rd_pntr_hold_plus3 = 1
                --            txd_rd_pntr was only updated 1-3 words to 0x1FF, 0x0, or 0x1, so stay here
                --          if  txd_rd_pntr_hold = 0x1FF then  txd_rd_pntr_hold_plus3 = 2
                --            txd_rd_pntr was only updated 1-3 words to 0x0, 0x1, or 0x2, so stay here
                  update_rd_pntrs  <= '1';
                  disable_txd_trdy <= '1';
                  clr_full_pntr    <= '0';
                  txd_wr_ns        <= MEM_FULL;
                end if;
              end if;
            end if;
          end if;

        when WAIT_WR1 =>
          disable_txc_trdy  <= '1';
          disable_txd_trdy  <= '0';

          if check_full = '1' then
            txd_wr_ns         <= WAIT_WR2;
          else
            txd_wr_ns         <= WAIT_WR1;
          end if;
        when WAIT_WR2 =>
          if txd_mem_full = '1' or txd_mem_afull = '1' then
            disable_txc_trdy  <= '1';
            disable_txd_trdy  <= '1';
            txd_wr_ns         <= CLR_FULL;
          else
            if wrote_first_packet = '0' then
              set_first_packet <= '1';
            else
              set_first_packet <= '0';
            end if;

            disable_txc_trdy  <= '0';
            disable_txd_trdy  <= '0';
            txd_wr_ns         <= IDLE;
          end if;

        when CLR_FULL =>
          --  stay here until the read pointer updates by 4 words or more.  The read side operates on bytes,
          --  the write side operates on words.
          --    The read pointer updates every 512 bytes (128 words) and at the end of a packet.
          --      The samallest packet the can be sent is 15bytes, but since the BRAM is 32 bit aligned,
          --      the read side will usually update the read pointer by a minimum of 16 bytes (4 words).  However,
          --      it can update by by less than 16 bytes (4 words).  This can occure if a packet started at read
          --      address 0x1A4 (write address 0x69), and the packet is 516 bytes in length (129 words).  Here the read pointer
          --      will update at 0x3A4 (write address 0xE9 - 128 words) then again at the end of the packet at 0x3A8
          --      (write address 0xEA).
          --        If this occures the below logic will detect it and update the read pointer, but stay in this
          --        state until the next update occurs.  The next update is guaranteed to be greater than 4 words,
          --        which will allow the full pointers to be cleared for the next packet.
          inc_txd_wr_addr     <= '0';
          set_txd_we          <= "0000";
          set_txd_en          <= '0';
          set_first_packet    <= '0';
          clr_txd_rdy         <= '0';
          if txd_rd_pntr = txd_rd_pntr_hold then
          --  stay here until an update occurs
            update_rd_pntrs  <= '0';
            halt_pntr_update <= '1';
            disable_txc_trdy <= '1';
            disable_txd_trdy <= '1';
            clr_full_pntr    <= '0';
            txd_wr_ns        <= CLR_FULL;
          else
          --  The read pointer was updated to determine if it was updated by 4 words or more
          --    If not, update the hold pointers, but stay in this state
            if txd_rd_pntr_hold <= txd_max_wr_addr_minus4 then
            --  for 2048 mem this covers from txd_rd_pntr_hold = 0x0 - 0x1FB
              if txd_rd_pntr > txd_rd_pntr_hold_plus3 then
              -- an update of 4 words or greater occured so exit this state
                if wrote_first_packet = '0' then
                  set_first_packet <= '1';
                else
                  set_first_packet <= '0';
                end if;
                update_rd_pntrs  <= '0';
                halt_pntr_update <= '0';
                disable_txd_trdy <= '0';
                clr_full_pntr    <= '1';
                clr_txd_rdy      <= '0';
                txd_wr_ns        <= WAIT_COMPARE_CMPLT;
              else
              --  the update was less than 4 words
              --    (txd_rd_pntr <= txd_rd_pntr_hold_plus3)
                if txd_rd_pntr < txd_rd_pntr_hold then
                --  the read pointer wrapped, so exit because the update was > 4 words
                  if wrote_first_packet = '0' then
                    set_first_packet <= '1';
                  else
                    set_first_packet <= '0';
                  end if;
                  update_rd_pntrs  <= '0';
                  halt_pntr_update <= '0';
                  disable_txd_trdy <= '0';
                  clr_full_pntr    <= '1';
                  clr_txd_rdy      <= '0';
                  txd_wr_ns        <= WAIT_COMPARE_CMPLT;
                else
                --  the update was less than 4 words, so update the read hold pointers and stay here until the next update
                --    txd_rd_pntr >= txd_rd_pntr_hold
                  update_rd_pntrs  <= '1';
                  halt_pntr_update <= '1';
                  disable_txc_trdy <= '1';
                  disable_txd_trdy <= '1';
                  clr_full_pntr    <= '0';
                  txd_wr_ns        <= CLR_FULL;
                end if;
              end if;
            else
            --  for 2048 mem this covers from txd_rd_pntr_hold = 0x1FC- 0x1FF
              if txd_rd_pntr_hold_plus3 = txd_max_wr_addr then
              --  txd_rd_pntr = 0x1FC for 2048 byte memory, so txd_rd_pntr_hold_plus3 = max memory size
                if (txd_rd_pntr <= txd_rd_pntr_hold) then
                --  the update was >= 4 words so exit
                --    for a 2048 memory, txd_rd_pntr_hold = 0x1FC
                --      if txd_rd_pntr is between 0x0 and 0x1FB then an update of 4 or more words occurred
                  if wrote_first_packet = '0' then
                    set_first_packet <= '1';
                  else
                    set_first_packet <= '0';
                  end if;
                  update_rd_pntrs  <= '0';
                  halt_pntr_update <= '0';
                  disable_txd_trdy <= '0';
                  clr_full_pntr    <= '1';
                  clr_txd_rdy      <= '0';
                  txd_wr_ns        <= WAIT_COMPARE_CMPLT;
                else
                --  the update was less than 4 words, so update the read hold pointers and stay here until the next update
                --    txd_rd_pntr >= txd_rd_pntr_hold
                  update_rd_pntrs  <= '1';
                  halt_pntr_update <= '1';
                  disable_txc_trdy <= '1';
                  disable_txd_trdy <= '1';
                  clr_full_pntr    <= '0';
                  txd_wr_ns        <= CLR_FULL;
                end if;
              else
              --  txd_rd_pntr = 0x1FD, 0x1FE, or 0x1FF for 2048 byte memory,
              --  so the minimum txd_rd_pntr_hold_plus3 can be is 0, 1, or 2
                if (txd_rd_pntr > txd_rd_pntr_hold_plus3) and (txd_rd_pntr < txd_rd_pntr_hold) then
                --  txd_rd_pntr_hold will be either 0x1FD, 0x1FE, or 0x1FF for a 2048 byte memory
                --    if txd_rd_pntr >  txd_rd_pntr_hold and  txd_rd_pntr <  txd_rd_pntr_hold
                --      then the update was >= 4 words and the state can be exited
                --          if  txd_rd_pntr_hold = 0x1FD then  txd_rd_pntr_hold_plus3 = 0
                --            txd_rd_pntr has to be tween 0x1 and 0x1FC to exit this state
                --          if  txd_rd_pntr_hold = 0x1FE then  txd_rd_pntr_hold_plus3 = 1
                --            txd_rd_pntr has to be tween 0x2 and 0x1FD to exit this state
                --          if  txd_rd_pntr_hold = 0x1FF then  txd_rd_pntr_hold_plus3 = 2
                --            txd_rd_pntr has to be tween 0x3 and 0x1FE to exit this state
                  if wrote_first_packet = '0' then
                    set_first_packet <= '1';
                  else
                    set_first_packet <= '0';
                  end if;
                  update_rd_pntrs  <= '0';
                  halt_pntr_update <= '0';
                  disable_txd_trdy <= '0';
                  clr_full_pntr    <= '1';
                  clr_txd_rdy      <= '0';
                  txd_wr_ns        <= WAIT_COMPARE_CMPLT;
                else
                --  txd_rd_pntr did not update by 4 or more words, so update hold poointers and stay in this state
                --  txd_rd_pntr_hold will be either 0x1FD, 0x1FE, or 0x1FF for a 2048 byte memory
                --    if txd_rd_pntr >  txd_rd_pntr_hold and  txd_rd_pntr <  txd_rd_pntr_hold
                --      then the update was >= 4 words and the state can be exited BUT
                --          if  txd_rd_pntr_hold = 0x1FD then  txd_rd_pntr_hold_plus3 = 0
                --            txd_rd_pntr was only updated 1-3 words to 0x1FE, 0x1FF, or 0x0, so stay here
                --          if  txd_rd_pntr_hold = 0x1FE then  txd_rd_pntr_hold_plus3 = 1
                --            txd_rd_pntr was only updated 1-3 words to 0x1FF, 0x0, or 0x1, so stay here
                --          if  txd_rd_pntr_hold = 0x1FF then  txd_rd_pntr_hold_plus3 = 2
                --            txd_rd_pntr was only updated 1-3 words to 0x0, 0x1, or 0x2, so stay here
                  update_rd_pntrs  <= '1';
                  halt_pntr_update <= '1';
                  disable_txc_trdy <= '1';
                  disable_txd_trdy <= '1';
                  clr_full_pntr    <= '0';
                  txd_wr_ns        <= CLR_FULL;
                end if;
              end if;
            end if;
          end if;          
          
        when WAIT_COMPARE_CMPLT =>
          txd_wr_ns        <= IDLE;
        when others =>
          txd_wr_ns <= IDLE;
      end case;
    end process;

    -----------------------------------------------------------------------------
    -- AXI Stream TX Control State Machine Sequencer
    -----------------------------------------------------------------------------
    FSM_AXISTRM_TXD_SEQ : process (AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' then
          txd_wr_cs <= IDLE;
        else
          txd_wr_cs <= txd_wr_ns;
        end if;
      end if;
    end process;


    -----------------------------------------------------------------------------
    -- Indicator when performing a write to TxD Memory
    --  clear on axi_str_txd_tlast_dly0 = '1'
    -----------------------------------------------------------------------------
    TXD_RDY_INDICATOR : process (AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' then
          txd_rdy <= '0';
        else
          if clr_txd_rdy = '1' then
            txd_rdy <= '0';
          elsif set_txd_rdy = '1' then
            txd_rdy <= '1';
          else
            txd_rdy <= txd_rdy;
          end if;
        end if;
      end if;
    end process;

    -----------------------------------------------------------------------------
    --  Filter to indicate first packet was written
    --    Needed for full flag
    -----------------------------------------------------------------------------
    FIRST_PACKET_WROTE : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' then
          wrote_first_packet <= '0';
        elsif set_first_packet = '1' then
          wrote_first_packet <= '1';
        else
          wrote_first_packet <= wrote_first_packet;
        end if;
      end if;
    end process;


    axi_str_txd_2_mem_addr_int_plus1 <= axi_str_txd_2_mem_addr_int + 1;
    axi_str_txd_2_mem_addr_int_plus2 <= axi_str_txd_2_mem_addr_int + 2;
    axi_str_txd_2_mem_addr_int_plus3 <= axi_str_txd_2_mem_addr_int + 3;
    axi_str_txd_2_mem_addr_int_plus4 <= axi_str_txd_2_mem_addr_int + 4;


    ---------------------------------------------------------------------------
    --  Register to help fmax
    --  With ASYNC BRAM clock cannot read/write same address in memory at same
    --  time unless timing is met, so read until data matches
    ---------------------------------------------------------------------------
    RD_PNTR : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' then
          txd_rd_pntr_1 <= (others => '0');
          txd_rd_pntr   <= (others => '0');
          compare_addr0_cmplt <= '0';
        else
          if set_txc_addr_0 = '1' and txc_addr_0_dly2 = '1' and
             txc_we_dly2 = '0'  then
          --  txc_addr_0_dly2 is when data is first avaliable from memory

          --  use set_txc_addr_0 to disable compare_addr0_cmplt once pointers update
          --  once state machine advances, set_txc_addr_0 will go low so use it to disable any more
          --  any more data from memory
            txd_rd_pntr_1      <= Axi_Str_TxC_2_Mem_Dout(c_TxD_addrb_width -1 downto 0);

            if Axi_Str_TxC_2_Mem_Dout(c_TxD_addrb_width -1 downto 0) = txd_rd_pntr_1 and
              compare_addr0_cmplt = '0' then
              txd_rd_pntr         <= txd_rd_pntr_1;
              if enable_compare_addr0_cmplt = '1' then
                compare_addr0_cmplt <= '1';
              else
                compare_addr0_cmplt <= '0';
              end if;
            else
              txd_rd_pntr         <= txd_rd_pntr;
              compare_addr0_cmplt <= '0';
            end if;
          else
            txd_rd_pntr_1      <= txd_rd_pntr_1;
            txd_rd_pntr        <= txd_rd_pntr;
            compare_addr0_cmplt<= '0';
          end if;
        end if;
      end if;
    end process;


    ---------------------------------------------------------------------------
    --  Update the read pointer locations until the memory goes FULL
    --    Then use the stored values to compare against real time read pointer
    --    and throttle appropriately
    ---------------------------------------------------------------------------
    RD_PNTRS : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' then
          txd_rd_pntr_hold_plus3 <= txc_rd_addr3;
          txd_rd_pntr_hold       <= txc_rd_addr0;
        else
          if (txd_mem_full = '0' and txc_addr_0_dly2 = '1' and halt_pntr_update = '0') or update_rd_pntrs = '1'then -- wait on this as it might not be needed  or update_hold_pntrs = '1' then --and
          --  halt_pntr_update is for the special case when memory is almost full/full and
          --  the Txd FSM needs to wait for a few reads before the next packet starts
          --  The TxD FSM will assert it HIGH to prevent the poiners from being updated
            txd_rd_pntr_hold_plus3 <= txd_rd_pntr+3;
            txd_rd_pntr_hold       <= txd_rd_pntr;
          else
            txd_rd_pntr_hold_plus3 <= txd_rd_pntr_hold_plus3;
            txd_rd_pntr_hold       <= txd_rd_pntr_hold;
          end if;
        end if;
      end if;
    end process;


    -----------------------------------------------------------------------------
    --  Full flag indicator
    --    Does not begin comparison until 1st packet is written to memory
    -----------------------------------------------------------------------------
    TXD_FULL_FLAG : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_full_pntr = '1' then
            txd_mem_full     <= '0';
            txd_mem_not_full <= '1';
        else
            if (axi_str_txd_2_mem_addr_int_plus3 = txd_rd_pntr and
              (inc_txd_wr_addr = '1'  or inc_txd_addr_one = '1')) then
              txd_mem_full     <= '1';
              txd_mem_not_full <= '0';
            else
              txd_mem_full     <= txd_mem_full;
              txd_mem_not_full <= txd_mem_not_full;
            end if;
        end if;
      end if;
    end process;

    TXD_AFULL_FLAG : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_full_pntr = '1' then
            txd_mem_afull     <= '0';
        else

          if (axi_str_txd_2_mem_addr_int_plus4 = txd_rd_pntr and
              (inc_txd_wr_addr = '1'  or inc_txd_addr_one = '1')) then
            txd_mem_afull     <= '1';
          else
            txd_mem_afull     <= txd_mem_afull;
          end if;
        end if;
      end if;
    end process;

    DELAY_TXD_TREADY_DISABLE : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        disable_txd_trdy_dly <= disable_txd_trdy;
      end if;
    end process;

    DELAY_TREADY_DISABLE : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        disable_txc_trdy_dly <= disable_txc_trdy;
      end if;
    end process;

    -----------------------------------------------------------------------------
    --  TxD Ready
    --    Only assert when FIFO is not full and TxC is not in process
    -----------------------------------------------------------------------------
    TXD_READY : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        axi_str_txd_tready_int_dly <= axi_str_txd_tready_int;
        if (AXI_STR_TXD_TLAST = '1' and AXI_STR_TXD_TVALID = '1' and axi_str_txd_tready_int = '1') or
           (clr_txd_trdy = '1' and disable_txd_trdy_dly = '0') or
           disable_txd_trdy = '1' then
          axi_str_txd_tready_int <= '0';
        elsif set_txd_rdy = '1' or (txd_rdy = '1' and clr_txd_rdy = '0') then
            if (axi_str_txd_2_mem_addr_int_plus3 = txd_rd_pntr and
               inc_txd_wr_addr = '1') or
               (clr_full_pntr = '0' and txd_mem_full = '1') then
            --  txd_rd_pntr is where the the current read is occuring, so
            --    to account for register pipelines, this needs to stop at
            --    3 counts before the current write address
              axi_str_txd_tready_int <= '0';
            else
              axi_str_txd_tready_int <= '1';
            end if;
        else
          axi_str_txd_tready_int <= '0';
        end if;
      end if;
    end process;

    AXI_STR_TXD_TREADY     <= axi_str_txd_tready_int;


    -----------------------------------------------------------------------------
    --  Address to AXI Stream Data Memory
    -----------------------------------------------------------------------------
    MEM_TXD_WR_ADDR : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' then
          axi_str_txd_2_mem_addr_int <= (others => '0');
        elsif (inc_txd_wr_addr = '1' or inc_txd_addr_one = '1') then
        --  the address ready for the next transaction
          axi_str_txd_2_mem_addr_int <= axi_str_txd_2_mem_addr_int + 1;
        else
          axi_str_txd_2_mem_addr_int <= axi_str_txd_2_mem_addr_int;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Force and update the BRAM with the axi_str_txd_2_mem_addr_int
    --  every ~128 writes (~512 bytes)
    ---------------------------------------------------------------------------
    BRAM_UPDATE : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_txd_rdy = '1' then
          update_bram_cnt     <= (others => '0');
        else
          if update_bram_cnt(7) = '1' and inc_txd_wr_addr = '1' then
            update_bram_cnt <= ('0' & update_bram_cnt(6 downto 0)) + 1;
          elsif inc_txd_wr_addr = '1' then
            update_bram_cnt <= update_bram_cnt + 1;
          else
            update_bram_cnt <= update_bram_cnt;
          end if;
        end if;
      end if;
    end process;


    axi_str_txd_2_mem_addr               <= axi_str_txd_2_mem_addr_int;


    Axi_Str_TxD_2_Mem_Din(35)           <= axi_str_txd_2_mem_we_int(3);
    Axi_Str_TxD_2_Mem_Din(26)           <= axi_str_txd_2_mem_we_int(2);
    Axi_Str_TxD_2_Mem_Din(17)           <= axi_str_txd_2_mem_we_int(1);
    Axi_Str_TxD_2_Mem_Din(8)            <= axi_str_txd_2_mem_we_int(0);

    Axi_Str_TxD_2_Mem_Din(34 downto 27) <= axi_str_txd_tdata_dly1(31 downto 24);
    Axi_Str_TxD_2_Mem_Din(25 downto 18) <= axi_str_txd_tdata_dly1(23 downto 16);
    Axi_Str_TxD_2_Mem_Din(16 downto  9) <= axi_str_txd_tdata_dly1(15 downto  8);
    Axi_Str_TxD_2_Mem_Din(7  downto  0) <= axi_str_txd_tdata_dly1( 7 downto  0);

    -----------------------------------------------------------------------------
    --  Write Parity bits to the AXI Stream Data Memory
    --    The parity bit always should be the AXI_STR_TXD_TSTRB bits delayed
    -----------------------------------------------------------------------------
    MEM_TXD_PARITY : process(AXI_STR_TXD_ACLK)
    begin
      if rising_edge(AXI_STR_TXD_ACLK) then
        axi_str_txd_2_mem_we_int <= set_txd_we;
      end if;
    end process;

    -----------------------------------------------------------------------------
    --  Write Enable bits to the AXI Stream Data Memory
    --    All of the write enables bits should be forced HIGH any time a write to
    --    memory is being performed.  This will allow the parity bits to be
    --    cleared which in turn prevents too much data being read on the Txd
    --    client interface.
    -----------------------------------------------------------------------------
    MEM_TXD_WR_EN : process(AXI_STR_TXD_ACLK)
    begin
      if rising_edge(AXI_STR_TXD_ACLK) then
        case set_txd_we is
          when "0000" => Axi_Str_TxD_2_Mem_We <= "0000";
          when others => Axi_Str_TxD_2_Mem_We <= "1111";
        end case;
      end if;
    end process;

--    Axi_Str_TxD_2_Mem_We <= axi_str_txd_2_mem_we_int;

    -----------------------------------------------------------------------------
    --  Enable bit to the AXI Stream Data Memory
    -----------------------------------------------------------------------------
    MEM_TXD_EN : process(AXI_STR_TXD_ACLK)
    begin
      if rising_edge(AXI_STR_TXD_ACLK) then
        if set_txd_en = '1' then
          axi_str_txd_2_mem_en_int <= '1';
        else
          axi_str_txd_2_mem_en_int <= '0';
        end if;
      end if;
    end process;

    Axi_Str_TxD_2_Mem_En <= axi_str_txd_2_mem_en_int;

-------------------------------------------------------------------------------
--  End Basic Design
-------------------------------------------------------------------------------

end rtl;
