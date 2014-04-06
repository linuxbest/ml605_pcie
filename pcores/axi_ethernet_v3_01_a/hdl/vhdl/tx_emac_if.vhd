-------------------------------------------------------------------------------
-- tx_emac_if - entity/architecture pair
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
-- Filename:        tx_emac_if.vhd
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
--                    tx_mem_if
--          ->        tx_emac_if.vhd
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

entity tx_emac_if is
  generic (
    C_FAMILY                  : string                      := "virtex6";
    C_TYPE                    : integer range 0 to 2        := 0;
    C_PHY_TYPE                : integer range 0 to 7        := 1;
    C_HALFDUP                 : integer range 0 to 1        := 0;
    C_TXMEM                   : integer                     := 4096;
    C_TXCSUM                  : integer range 0 to 2        := 0;

    -- Read Port - AXI Stream TxData
    c_TxD_write_width_a       : integer range   0 to 18     := 9;
    c_TxD_read_width_a        : integer range   0 to 18     := 9;
    c_TxD_write_depth_a       : integer range   0 to 32768  := 4096;
    c_TxD_read_depth_a        : integer range   0 to 32768  := 4096;
    c_TxD_addra_width         : integer range   0 to 15     := 10;
    c_TxD_wea_width           : integer range   0 to 2      := 2;

    -- Read Port - AXI Stream TxControl
    c_TxC_write_width_a       : integer range  36 to 36     := 36;
    c_TxC_read_width_a        : integer range  36 to 36     := 36;
    c_TxC_write_depth_a       : integer range   0 to 1024   := 1024;
    c_TxC_read_depth_a        : integer range   0 to 1024   := 1024;
    c_TxC_addra_width         : integer range   0 to 10     := 10;
    c_TxC_wea_width           : integer range   0 to 1      := 1;

    c_TxD_addrb_width         : integer range   0 to 13     := 10;

    C_CLIENT_WIDTH            : integer                     := 8
  );
  port (
    --Transmit Memory Read Interface
    tx_client_10_100          : in  std_logic;                                        --  Tx Client CE Toggles Indicator
      -- ** WARNING ** WARNING ** WARNING **
      --  For MII,GMII, RGMI, 1000Base-X and pcs/pma SGMII this is an accurate indicator
      --  However for V6 Hard SGMII it is always tied to '0' for all speeds


    -- Read Port - AXI Stream TxData
    reset2tx_client           : in  std_logic;                                        --  reset
    Tx_Client_TxD_2_Mem_Din   : out std_logic_vector(c_TxD_write_width_a-1 downto 0); --  Tx AXI-Stream Data to Memory Wr Din
    Tx_Client_TxD_2_Mem_Addr  : out std_logic_vector(c_TxD_addra_width-1   downto 0); --  Tx AXI-Stream Data to Memory Wr Addr
    Tx_Client_TxD_2_Mem_En    : out std_logic;                                        --  Tx AXI-Stream Data to Memory Enable
    Tx_Client_TxD_2_Mem_We    : out std_logic_vector(c_TxD_wea_width-1     downto 0); --  Tx AXI-Stream Data to Memory Wr En
    Tx_Client_TxD_2_Mem_Dout  : in  std_logic_vector(c_TxD_read_width_a-1  downto 0); --  Tx AXI-Stream Data to Memory Not Used

    -- Read Port - AXI Stream TxControl
    reset2axi_str_txd         : in  std_logic;                                        --  reset
    Tx_Client_TxC_2_Mem_Din   : out std_logic_vector(c_TxC_write_width_a-1 downto 0); --  Tx AXI-Stream Control to Memory Wr Din
    Tx_Client_TxC_2_Mem_Addr  : out std_logic_vector(c_TxC_addra_width-1   downto 0); --  Tx AXI-Stream Control to Memory Wr Addr
    Tx_Client_TxC_2_Mem_En    : out std_logic;                                        --  Tx AXI-Stream Control to Memory Enable
    Tx_Client_TxC_2_Mem_We    : out std_logic_vector(c_TxC_wea_width-1     downto 0); --  Tx AXI-Stream Control to Memory Wr En
    Tx_Client_TxC_2_Mem_Dout  : in  std_logic_vector(c_TxC_read_width_a-1  downto 0); --  Tx AXI-Stream Control to Memory Full Flag

    --  Tx AXI-S Interface
    tx_axi_clk                : in  std_logic;                                        --  Tx AXI-Stream clock in
    tx_reset_out              : in  std_logic;                                        --  take to reset combiner
    tx_axis_mac_tdata         : out std_logic_vector(C_CLIENT_WIDTH - 1 downto 0);    --  Tx AXI-Stream data
    tx_axis_mac_tvalid        : out std_logic;                                        --  Tx AXI-Stream valid
    tx_axis_mac_tlast         : out std_logic;                                        --  Tx AXI-Stream last
    tx_axis_mac_tuser         : out std_logic;                         -- this is always driven low since an underflow cannot occur
    tx_axis_mac_tready        : in  std_logic;                                        --  Tx AXI-Stream ready in from TEMAC
    tx_collision              : in  std_logic;                                        --  collision not used
    tx_retransmit             : in  std_logic;                                        -- retransmit not used
     

    tx_cmplt                  : out std_logic;                                        -- transmit is complete indicator

    tx_init_in_prog_cross     : in  std_logic                                         --  Tx is Initializing after a reset
  );

end tx_emac_if;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of tx_emac_if is

  type TXC_RD_FSM_TYPE is (
                      GET_TXC_WR_PNTR,
                      GET_END_PNTR,
                      SET_TXCRD_PNTR,
                      GET_TXDWR_PNTR,
                      SET_TXDRD_PNTR,
                      WAIT_TXD_DONE,
                      GET_ADDR3,
                      WAIT_ADDR3_PNTR
                    );
  signal txc_rd_cs, txc_rd_ns        : TXC_RD_FSM_TYPE;

  type TXD_RD_FSM_TYPE is (
                       IDLE,
                       GET_B1,
                       GET_B2,
                       GET_B3,
                       GET_B4,                       
                       WAIT_TRDY2,
                       WAIT_TRDY3,
                       PRM_DATA,
                       CHECK_DONE,
                       WAIT_LAST
                      );
  signal txd_rd_cs, txd_rd_ns        : TXD_RD_FSM_TYPE;

  signal set_txc_addr0               : std_logic;
  signal set_txc_addr1               : std_logic;
  signal set_txc_addr2               : std_logic;
  signal set_txc_addr3               : std_logic;
  signal txc_addr3_en                : std_logic;
  signal set_txc_addr4_n             : std_logic;
  signal set_txc_wr                  : std_logic;
  signal set_txc_en                  : std_logic;
  signal txc_wr_pntr_en              : std_logic;
  signal set_start_txd_fsm           : std_logic;
  signal start_txd_fsm               : std_logic;
  signal inc_txc_rd_addr             : std_logic;
  signal first_rd                    : std_logic;
  signal txc_wr_pntr_1               : std_logic_vector(c_TxC_addra_width -1 downto 0);
  signal txc_wr_pntr                 : std_logic_vector(c_TxC_addra_width -1 downto 0);
  signal compare_addr3_cmplt         : std_logic;

  signal Tx_Client_TxC_2_Mem_Addr_int: std_logic_vector(c_TxC_addra_width -1 downto 0);
  signal txc_mem_rd_addr             : std_logic_vector(c_TxC_addra_width -1 downto 0);
  signal txc_rd_addr_cmp             : std_logic_vector(c_TxC_addra_width -1 downto 0);

  signal end_addr                    : std_logic_vector(c_TxD_addra_width -1 downto 0);
  signal txc_rd_end                  : std_logic;
  signal txc_rd_end_dly1             : std_logic;
  signal Tx_Client_TxC_2_Mem_En_int  : std_logic;
  signal Tx_Client_TxC_2_Mem_We_int  : std_logic_vector(c_TxC_wea_width-1     downto 0);
  signal Tx_Client_TxC_2_Mem_Din_int : std_logic_vector(c_TxC_write_width_a -1 downto 0);

  signal set_txd_vld                 : std_logic;
  signal clr_txd_vld                 : std_logic;
  signal set_txd_en                  : std_logic;
  signal inc_txd_rd_addr             : std_logic;
  signal txd_rd_addr                 : std_logic_vector(c_TxD_addra_width -1 downto 0);
  signal txd_rd_addr_1_0             : std_logic_vector(1 downto 0);
  signal txd_rd_addr_aligned         : std_logic_vector(c_TxD_addra_width -1 downto 0);
  signal txd_wr_pntr_en              : std_logic;

  signal align_start_addr            : std_logic;
  signal set_txd_done                : std_logic;
  signal Tx_Client_TxD_2_Mem_En_int  : std_logic;
  signal txd                         : std_logic_vector(C_CLIENT_WIDTH-1 downto 0);
  signal txd_vld                     : std_logic;

  signal txc_min_rd_addr             : std_logic_vector(c_TxC_addra_width -1 downto 0);
  signal txc_max_rd_addr             : std_logic_vector(c_TxC_addra_width -1 downto 0);

  signal txc_rd_addr0                : std_logic_vector(c_TxC_addra_width -1 downto 0);
  signal txc_rd_addr1                : std_logic_vector(c_TxC_addra_width -1 downto 0);
  signal txc_rd_addr2                : std_logic_vector(c_TxC_addra_width -1 downto 0);
  signal txc_rd_addr3                : std_logic_vector(c_TxC_addra_width -1 downto 0);
  signal txc_rd_addr5                : std_logic_vector(c_TxC_addra_width -1 downto 0);
  signal txc_rd_addr6                : std_logic_vector(c_TxC_addra_width -1 downto 0);
  signal txc_rd_addr7                : std_logic_vector(c_TxC_addra_width -1 downto 0);

  signal txc_mem_rd_addr_0           : std_logic_vector(c_TxC_addra_width -1 downto 0);
  signal txc_mem_rd_addr_1           : std_logic_vector(c_TxC_addra_width -1 downto 0);

  signal txd_1                       : std_logic_vector(C_CLIENT_WIDTH-1 downto 0);
  signal txd_2                       : std_logic_vector(C_CLIENT_WIDTH-1 downto 0);  
  signal txd_3                       : std_logic_vector(C_CLIENT_WIDTH-1 downto 0);
  
  constant zeroes_txc                : std_logic_vector(c_TxC_read_width_a -1 downto c_TxC_addra_width)    := (others => '0');
  constant zeroes_txd                : std_logic_vector(c_TxC_read_width_a -1 downto c_TxD_addra_width -2) := (others => '0');
  
  signal txcl_init_in_prog_dly1      : std_logic;
  signal txcl_init_in_prog_dly2      : std_logic;
  signal txcl_init_in_prog_dly3      : std_logic;
  signal txcl_init_in_prog_dly4      : std_logic;
  
  signal update_bram_cnt             : std_logic_vector(9 downto 0);
   
  signal tx_axis_mac_tready_dly      : std_logic;
  signal mux_b3                      : std_logic;
  
  signal tx_axis_mac_tlast_int       : std_logic;
  
  signal set_byte_en                 : std_logic;
  signal set_byte_en_pipe            : std_logic_vector(1 downto 0);   
  signal set_first_bytes             : std_logic;
  signal first_bytes                 : std_logic;  
  
  signal phy_mode_enable             : std_logic;
  
  begin

    tx_axis_mac_tuser   <= '0';

    Tx_Client_TxD_2_Mem_Din <= (others => '0');
    
    
    GEN_PHY_MODE_NOT_SGMII : if (C_PHY_TYPE /= 4) generate
    begin
      
      phy_mode_enable <= tx_client_10_100;
      
    end generate GEN_PHY_MODE_NOT_SGMII;
    
    GEN_V6_HARD_PHY_MODE_SGMII : if (C_TYPE = 2 and C_PHY_TYPE = 4) generate
    begin
      -- even when 10/100 Mbps tie low as timing in tx_emac.vhd and tx_avb_2_axi_mac will not be correct
      --  otherwise incorrect setting results in data not being primed properly
      
      --  In this mode the Hard temac core can operate at 10000/100/10Mbps.
      --    At 1000Mbps tx_client_10_100 is LOW and tx_clk_en is HIGH
      --    HOWEVER at 100/10Mbps BOTH tx_client_10_100 and tx_clk_en are HIGH
      --      This is different from all other TEMAC configurations in which  
      --      tx_client_10_100 is HIGH and tx_clk_en toggles.
      --      So force the logic to think the core is operating at 1000Mbps
      phy_mode_enable <= '0';
      
    end generate GEN_V6_HARD_PHY_MODE_SGMII;    
    
    GEN_SOFT_PHY_MODE_SGMII : if (C_TYPE /= 2 and C_PHY_TYPE = 4) generate
    begin
      -- even when 10/100 Mbps tie low as timing in tx_emac.vhd will not be correct otherwise 
      --  incorrect setting results in 5th byte being duplicated once
      phy_mode_enable <= tx_client_10_100;
      
    end generate GEN_SOFT_PHY_MODE_SGMII;    
          
    -----------------------------------------------------------------------------
    --  Create the full and empty comparison values for the S6 and V6 since
    --  1 S6 BRAM = 1/2 V6 BRAM
    -----------------------------------------------------------------------------
    GEN_TXC_MIN_MAX_RD_FLAG : for i in (c_TxC_addra_width - 1) downto 0 generate
      txc_min_rd_addr(i)  <= '1' when (i = 2)          else '0';
      txc_max_rd_addr(i)  <= '0' when (i = 0 or i = 1) else '1';
      txc_rd_addr0(i)     <= '0';
      txc_rd_addr1(i)     <= '1' when (i = 0)          else '0';
      txc_rd_addr2(i)     <= '1' when (i = 1)          else '0';
      txc_rd_addr3(i)     <= '1' when (i = 0 or i = 1) else '0';
      txc_rd_addr5(i)     <= '1' when (i = 0 or i = 2) else '0';
      txc_rd_addr6(i)     <= '1' when (i = 1 or i = 2) else '0';
      txc_rd_addr7(i)     <= '1' when (i = 0 or i = 1 or i = 2) else '0';

    end generate GEN_TXC_MIN_MAX_RD_FLAG;

    -----------------------------------------------------------------------------
    --  Transmit Client TX Control State Machine Combinatorial Logic
    -----------------------------------------------------------------------------
    FSM_TXCLIENT_TXC_CMB : process (txc_rd_cs,tx_axis_mac_tready,
      clr_txd_vld,txc_rd_addr_cmp,--Tx_Client_TxC_2_Mem_Dout,
      txcl_init_in_prog_dly4,compare_addr3_cmplt,txc_wr_pntr,
      update_bram_cnt)
    begin

      set_txc_addr0     <= '0';
      set_txc_addr1     <= '0';
      set_txc_addr2     <= '0';
      set_txc_addr3     <= '0';
      set_txc_addr4_n   <= '0';
      set_txc_wr        <= '0';
      set_txc_en        <= '0';
      set_start_txd_fsm <= '0';
      inc_txc_rd_addr   <= '0';

      case txc_rd_cs is
        when GET_TXC_WR_PNTR =>
          if txcl_init_in_prog_dly4 = '0' and compare_addr3_cmplt = '1' and 
             txc_rd_addr_cmp /= txc_wr_pntr then        
            set_txc_addr3     <= '0';
            set_txc_addr4_n   <= '1';        -- Read TxC Addr 0x4 - 0xn
            set_txc_en        <= '1';
            inc_txc_rd_addr   <= '1';
            txc_rd_ns         <= GET_END_PNTR;
          else
            set_txc_addr3     <= '1';        -- Read TxC Addr 0x3 (TxC Empty)
            set_txc_addr4_n   <= '0';
            set_txc_en        <= '1';
            inc_txc_rd_addr   <= '0';
            txc_rd_ns         <= GET_TXC_WR_PNTR;
          end if;
        when GET_END_PNTR =>
            set_txc_addr2     <= '1';        -- Write TxC Addr 0x2
            set_txc_wr        <= '1';
            set_txc_en        <= '1';
            txc_rd_ns         <= SET_TXCRD_PNTR;
        when SET_TXCRD_PNTR =>
            set_txc_addr1     <= '1';        -- Read TxC Addr 0x1
            set_txc_en        <= '1';
            txc_rd_ns         <= GET_TXDWR_PNTR;
        when GET_TXDWR_PNTR =>
            set_txc_addr0     <= '1';        -- Write TxC Addr 0x0
            set_txc_wr        <= '1';
            set_txc_en        <= '1';
            txc_rd_ns         <= SET_TXDRD_PNTR;
        when SET_TXDRD_PNTR =>
            set_txc_addr0     <= '0';        
            set_txc_wr        <= '0';
            set_txc_en        <= '0';
            set_start_txd_fsm <= '1';
            txc_rd_ns         <= WAIT_TXD_DONE;
        when WAIT_TXD_DONE =>
          if tx_axis_mac_tready = '1' and clr_txd_vld = '0' then
            if update_bram_cnt(9) = '1' then  --Update the TxC BRAM with the current rd_addr_addr
              set_txc_addr0   <= '1';          -- Write TxC Addr 0x0
              set_txc_addr3   <= '0';
              set_txc_wr      <= '1';
              set_txc_en      <= '1';
              inc_txc_rd_addr <= '0';
              txc_rd_ns       <= WAIT_TXD_DONE;
            else
              set_txc_addr0   <= '0';          -- Write TxC Addr 0x0
              set_txc_addr3   <= '0';
              set_txc_wr      <= '0';
              set_txc_en      <= '0';
              inc_txc_rd_addr <= '0';
              txc_rd_ns       <= WAIT_TXD_DONE;
            end if;              
          elsif tx_axis_mac_tready = '1' and clr_txd_vld = '1' then
            set_txc_addr0   <= '1';
            set_txc_addr3   <= '0';
            set_txc_wr      <= '1';
            set_txc_en      <= '1'; --write the last rd_rntr_addr for this packet
            inc_txc_rd_addr <= '0';
            txc_rd_ns       <= GET_ADDR3;
          else
            set_txc_addr0   <= '0';
            set_txc_addr3   <= '0'; --do nothing
            set_txc_wr      <= '0';
            set_txc_en      <= '0';
            inc_txc_rd_addr <= '0';
            txc_rd_ns       <= WAIT_TXD_DONE;
          end if;
        when GET_ADDR3 =>
          if tx_axis_mac_tready = '1' then
            set_txc_addr0   <= '0';
            set_txc_addr3   <= '1';
            set_txc_wr      <= '0';
            set_txc_en      <= '1'; --get ready for the next packet - addr0x4-0xn
            inc_txc_rd_addr <= '0';
            txc_rd_ns       <= WAIT_ADDR3_PNTR;
          else
            set_txc_addr0   <= '0';
            set_txc_addr3   <= '0';
            set_txc_wr      <= '0';
            set_txc_en      <= '0';
            inc_txc_rd_addr <= '0';
            txc_rd_ns       <= GET_ADDR3;          
          end if;              
        when WAIT_ADDR3_PNTR =>
          set_txc_addr0   <= '0';
          set_txc_addr3   <= '1';
          set_txc_wr      <= '0';
          set_txc_en      <= '1'; 
          inc_txc_rd_addr <= '0';
          txc_rd_ns       <= GET_TXC_WR_PNTR;
        when others =>
          txc_rd_ns      <= GET_TXC_WR_PNTR;
      end case;
    end process;

    -----------------------------------------------------------------------------
    --  Transmit Client TX Control State Machine Sequencer
    -----------------------------------------------------------------------------
    FSM_TXCLIENT_TXC_SEQ : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' then
          txc_rd_cs <= GET_TXC_WR_PNTR;
        else
          txc_rd_cs <= txc_rd_ns;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Delay the indicator to ensure the memory has had enough time to update
    ---------------------------------------------------------------------------
    TXCL_INIT_INDICATOR_DLY : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' then
          txcl_init_in_prog_dly1 <= '1';
          txcl_init_in_prog_dly2 <= '1';
          txcl_init_in_prog_dly3 <= '1';
          txcl_init_in_prog_dly4 <= '1';
        else
          txcl_init_in_prog_dly1 <= tx_init_in_prog_cross;
          txcl_init_in_prog_dly2 <= txcl_init_in_prog_dly1;
          txcl_init_in_prog_dly3 <= txcl_init_in_prog_dly2;
          txcl_init_in_prog_dly4 <= txcl_init_in_prog_dly3;
        end if;
      end if;
    end process;


    -----------------------------------------------------------------------------
    --  Start the TXD FSM
    ----------------------------------------------------------------------------- 
    START_TX_DATA_FSM : process(tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if set_start_txd_fsm = '1' then
          start_txd_fsm <= '1';
        else
          start_txd_fsm <= '0';
        end if;
      end if;  
    end process;
    
    -----------------------------------------------------------------------------
    --  Delay the Enable for getting the End address
    -----------------------------------------------------------------------------
    TXC_RD_END_ADDR_EN : process(tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if set_txc_addr4_n = '1' then
          txc_rd_end <= '1';
        else
          txc_rd_end <= '0';
        end if;
        
        txc_rd_end_dly1 <= txc_rd_end;
        
      end if;
    end process;

    -----------------------------------------------------------------------------
    --  Store the end address
    --    It will be used in Half Duplex mode to drop a packet if necessary
    -----------------------------------------------------------------------------
    TXC_RD_END_ADDR : process(tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' then
          end_addr <= (others => '0');
        else
          if  txc_rd_end_dly1 = '1' then
            end_addr <= Tx_Client_TxC_2_Mem_Dout(c_TxD_addra_width -1 downto 0);
          else                                      
            end_addr <= end_addr;
          end if;
        end if;
      end if;
    end process;


    -----------------------------------------------------------------------------
    --  Enable the memory
    -----------------------------------------------------------------------------
    TXC_EN : process(tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if set_txc_en = '1' then
          Tx_Client_TxC_2_Mem_En_int <= '1';
        else
          Tx_Client_TxC_2_Mem_En_int <= '0';
        end if;
      end if;
    end process;

    Tx_Client_TxC_2_Mem_En <= Tx_Client_TxC_2_Mem_En_int;

    -----------------------------------------------------------------------------
    --  Set the Write enable for memory writes
    -----------------------------------------------------------------------------
    TXC_WR_EN : process(tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if set_txc_wr = '1' then
          Tx_Client_TxC_2_Mem_We_int(0) <= '1';
        else
          Tx_Client_TxC_2_Mem_We_int(0) <= '0';
        end if;
      end if;
    end process;

    Tx_Client_TxC_2_Mem_We <= Tx_Client_TxC_2_Mem_We_int;

    -----------------------------------------------------------------------------
    --  Register the enable to align it with the Memory data
    -----------------------------------------------------------------------------
    TXC_RD_EN : process(tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        txc_wr_pntr_en     <= set_txc_addr3;
      end if;
    end process;
          

    FIRST_RD_CMPLT : process(tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' then
          first_rd <= '0';
        else
          if inc_txc_rd_addr = '1' then
            first_rd <= '1';
          else
            first_rd <= first_rd;
          end if;
        end if;
      end if;
    end process;


    -----------------------------------------------------------------------------
    --  TxC FIFO EMPTY Indicator
    --    Compare the current TxC Rd Addr to the current TxC Wr Addr
    -----------------------------------------------------------------------------
    TXC_WRITE_POINTER : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' then
          txc_wr_pntr_1       <= (others => '0');
          txc_wr_pntr         <= (others => '0');
          compare_addr3_cmplt <= '0';
        else
          if set_txc_addr3 = '1' and txc_wr_pntr_en = '1' then
            txc_wr_pntr_1     <= Tx_Client_TxC_2_Mem_Dout(c_TxC_addra_width -1 downto 0);
            
            if txc_wr_pntr_1 = Tx_Client_TxC_2_Mem_Dout(c_TxC_addra_width -1 downto 0) and 
               compare_addr3_cmplt = '0' then
              txc_wr_pntr         <= txc_wr_pntr_1; 
              compare_addr3_cmplt <= '1';
            else
              txc_wr_pntr         <= txc_wr_pntr;
              compare_addr3_cmplt <= '0';
            end if;  
            
          else
            txc_wr_pntr_1       <= txc_wr_pntr_1;
            txc_wr_pntr         <= txc_wr_pntr;
            compare_addr3_cmplt <= '0';
          end if;        
        end if;
      end if;
    end process;


    -----------------------------------------------------------------------------
    --  Generate address that will get the End Address
    -----------------------------------------------------------------------------
    TXC_RD_ADDR : process(tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' then
          txc_mem_rd_addr   <= txc_min_rd_addr;

          txc_mem_rd_addr_0 <= txc_rd_addr5;
          txc_mem_rd_addr_1 <= txc_rd_addr6;
          --  txc_rd_addr_cmp needs to lag one cnt because 
          --  it is incremented before the data is actually read
          txc_rd_addr_cmp   <= (others => '0');
        else
          if inc_txc_rd_addr = '1' and first_rd = '0' then
          --  Initialize to start values
            txc_mem_rd_addr   <= txc_rd_addr5;

            txc_mem_rd_addr_0 <= txc_rd_addr6;
            txc_mem_rd_addr_1 <= txc_rd_addr7;
           
            --  txc_rd_addr_cmp needs to lag one cnt because 
            --  it is incremented before the data is actually read
            txc_rd_addr_cmp   <= txc_min_rd_addr;
          elsif inc_txc_rd_addr = '1' and first_rd = '1' then
          --  increment the address for the next packet
            if txc_mem_rd_addr = txc_max_rd_addr then
            --  if the max address is reached, loop to address 0x4
              txc_mem_rd_addr   <= txc_mem_rd_addr_0;

              txc_mem_rd_addr_0 <= txc_mem_rd_addr_1;
              txc_mem_rd_addr_1 <= txc_rd_addr6;
              txc_rd_addr_cmp   <= txc_mem_rd_addr;

            else
            --  otherwise just increment it
              txc_mem_rd_addr   <= txc_mem_rd_addr_0;

              txc_mem_rd_addr_0 <= txc_mem_rd_addr_1;
              txc_mem_rd_addr_1 <= txc_mem_rd_addr_1 + 1;
              txc_rd_addr_cmp   <= txc_mem_rd_addr;

            end if;

          else -- Hold the current address until something changes
            txc_mem_rd_addr   <= txc_mem_rd_addr;

            txc_mem_rd_addr_0 <= txc_mem_rd_addr_0;
            txc_mem_rd_addr_1 <= txc_mem_rd_addr_1;
            txc_rd_addr_cmp   <= txc_rd_addr_cmp;

          end if;
        end if;
      end if;
    end process;


    -----------------------------------------------------------------------------
    --  Generate address mux fo memory
    -----------------------------------------------------------------------------
    MEM_TXC_RD_ADDR : process(tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if set_txc_addr4_n= '1' and first_rd = '0' and set_txc_wr = '0' then
        -- Provide the address for the End of packet address
          Tx_Client_TxC_2_Mem_Addr_int <= txc_min_rd_addr;
        elsif set_txc_addr4_n= '1' and first_rd = '1' and set_txc_wr = '0' then
        -- Provide the address for the End of packet address
          Tx_Client_TxC_2_Mem_Addr_int <= txc_mem_rd_addr;
        elsif set_txc_addr2 = '1' and set_txc_wr = '1' then
        --Write the txc rd pointer
          Tx_Client_TxC_2_Mem_Addr_int <= txc_rd_addr2;
        elsif set_txc_addr3 = '1' and set_txc_wr = '0' then
        --Read the txc wr pointer
          Tx_Client_TxC_2_Mem_Addr_int <= txc_rd_addr3;
        elsif set_txc_addr1 = '1' and set_txc_wr = '0' then
        --  Read the TxD write pointer to monitor for an empty condition
          Tx_Client_TxC_2_Mem_Addr_int <= txc_rd_addr1;
        elsif set_txc_addr0 = '1' and set_txc_wr = '1' then
        --  Write the current TxD Read Pointer while transmitting data
          Tx_Client_TxC_2_Mem_Addr_int <= txc_rd_addr0;
        else
          Tx_Client_TxC_2_Mem_Addr_int <= Tx_Client_TxC_2_Mem_Addr_int;
        end if;
      end if;
    end process;

    Tx_Client_TxC_2_Mem_Addr <= Tx_Client_TxC_2_Mem_Addr_int;

    ---------------------------------------------------------------------------
    --  Write the TxC Rd Pointer to address 2 or
    --    write the TxD Rd Pointer to address 0
    --    Remove the lower 2 bits to align to a 32 bit word instead of a byte
    ---------------------------------------------------------------------------
    TXC_MEM_ADDR_PNTR : process(tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if set_txc_addr2 = '1' then
        --Address for data that is currently being transmitted
          Tx_Client_TxC_2_Mem_Din_int <= zeroes_txc & txc_rd_addr_cmp(c_TxC_addra_width -1 downto 0);
        elsif set_txc_addr0 = '1' then
          Tx_Client_TxC_2_Mem_Din_int <= zeroes_txd & txd_rd_addr(c_TxD_addra_width -1 downto 2);
        else
          Tx_Client_TxC_2_Mem_Din_int <= (others => '0');
        end if;
      end if;
    end process;

    Tx_Client_TxC_2_Mem_Din <= Tx_Client_TxC_2_Mem_Din_int;

    -----------------------------------------------------------------------------
    --  Transmit Client TX Control State Machine Combinatorial Logic
    -----------------------------------------------------------------------------
    FSM_TXCLIENT_TXD_CMB : process (txd_rd_cs,tx_axis_mac_tready,
      start_txd_fsm, 
      Tx_Client_TxD_2_Mem_Dout,txd_rd_addr,txc_rd_end,
      end_addr,phy_mode_enable,
      tx_axis_mac_tready_dly,first_bytes)

    begin

      set_txd_vld     <= '0';
      clr_txd_vld     <= '0';
      set_txd_en      <= '0';
      inc_txd_rd_addr <= '0';
      align_start_addr<= '0';
      set_txd_done    <= '0';
      mux_b3          <= '0';
      set_byte_en     <= '0';
      set_first_bytes <= '0';
      
      case txd_rd_cs is
        when IDLE => 
          if start_txd_fsm = '1' then  
            inc_txd_rd_addr <= '1';
            set_txd_en      <= '1';
            set_first_bytes <= '1';
            txd_rd_ns       <= GET_B1; 
          else
            inc_txd_rd_addr <= '0';                                                  
            set_txd_en      <= txc_rd_end;      
            txd_rd_ns       <= IDLE; 
         end if;
        when GET_B1 => 
          inc_txd_rd_addr <= '1';  
          set_txd_vld     <= '1'; --Start sending first data of payload
          set_txd_en      <= '1'; 
          txd_rd_ns       <= GET_B2;
        when GET_B2 =>
          inc_txd_rd_addr <= '1';                         
          set_txd_en      <= '1';
          set_byte_en     <= '1'; 
          txd_rd_ns       <= GET_B3;
        when GET_B3 =>                       
          inc_txd_rd_addr <= '1';            
          set_txd_en      <= '1';  
          txd_rd_ns       <= GET_B4;         
        when GET_B4 =>                
         txd_rd_ns       <= WAIT_TRDY2;                             
        when WAIT_TRDY2 => 
          if tx_axis_mac_tready = '1' and first_bytes = '0' and phy_mode_enable = '0' then  
            inc_txd_rd_addr <= '1'; --Continue reading payload data
            set_txd_en      <= '1';
            mux_b3          <= '1';
            txd_rd_ns       <= WAIT_TRDY3;
            
          elsif tx_axis_mac_tready = '1' and first_bytes = '0' and phy_mode_enable = '1' then  
            inc_txd_rd_addr <= '0'; --Continue reading payload data
            set_txd_en      <= '0';
            mux_b3          <= '1';
            txd_rd_ns       <= WAIT_TRDY3;
                                
          else
            inc_txd_rd_addr <= '0'; 
            set_txd_en      <= '0';
            mux_b3          <= '0';
            txd_rd_ns       <= WAIT_TRDY2;
          end if;          
    
        when WAIT_TRDY3 => 
          if tx_axis_mac_tready = '1' then  
            inc_txd_rd_addr <= '1'; --Continue reading payload data
            set_txd_en      <= '1';
            txd_rd_ns       <= CHECK_DONE;        
          else
            inc_txd_rd_addr <= '0'; 
            set_txd_en      <= '0';
            txd_rd_ns       <= WAIT_TRDY3;
          end if;          
        
        
                  
          
        when CHECK_DONE =>
          if tx_axis_mac_tready = '1' then
          --  The end addreess read from the memory is always one byte before 
          --  the actual end of the packet to allow tlast to be asserted correctly
          
          --  On the write side of the BRAM, the end_addr has been set such that the 
          --  at strobes at TLAST reflect the last byte of data minus 1
          --    case axi_str_txd_tstrb_dly0 is
          --      when "1111" => end_addr_byte_offset <= "11";
          --      when "0111" => end_addr_byte_offset <= "10";
          --      when "0011" => end_addr_byte_offset <= "01";
          --      when others => end_addr_byte_offset <= "00";
          --    end case;
          --
          --  The BRAM parity bits are not used with AXI-S CORE Gen
          --         
            if end_addr = txd_rd_addr then
            --Last byte of payload data is one byte after end_address
              if txd_rd_addr(1) = '1' and txd_rd_addr (0) = '1' then
              --  By incrementing the address one, it will be 32 bit aligned
              --  which is the starting address of the next packet 
                align_start_addr <= '0';
                inc_txd_rd_addr  <= '1'; 
              else
              --  Align address to 32 bits because it ended non aligned
              --    The next 32 bit aligned address will be the start
              --    of the next payload data
              --  Do not increment the address since it is getting aligned
                align_start_addr <= '1';
                inc_txd_rd_addr  <= '0'; 
              end if;
              
              if phy_mode_enable = '0' then   
                clr_txd_vld     <= '0'; 
                set_txd_en      <= '0';             
                set_txd_done    <= '0';             
                txd_rd_ns       <= WAIT_LAST;  
              elsif phy_mode_enable = '1' then   
                clr_txd_vld     <= '1';            
                set_txd_en      <= '0';             
                set_txd_done    <= '1';             
                txd_rd_ns       <= IDLE;                                         
              end if;
              
            else
              inc_txd_rd_addr <= '1'; --set addr to get next data
              set_txd_en      <= '1';
              set_txd_done    <= '0';
              align_start_addr<= '0';
              txd_rd_ns       <= CHECK_DONE;
            end if;
          else
            inc_txd_rd_addr <= '0';
            set_txd_en      <= '0';
            set_txd_done    <= '0';
            align_start_addr<= '0';
            txd_rd_ns       <= CHECK_DONE;
          end if;
        when WAIT_LAST =>
        --  Need to wait one tready clock cycle before transitioning to IDLE
        --    This will allow the last Tx Byte through and set TLAST accordingly
            clr_txd_vld     <= '1'; 
            inc_txd_rd_addr <= '0';             
            set_txd_en      <= '0';             
            set_txd_done    <= '1'; 
            txd_rd_ns       <= IDLE;           
                       
        when others =>
          txd_rd_ns <= IDLE;
      end case;
    end process;

    -----------------------------------------------------------------------------
    --  Transmit Client TX Control State Machine Sequencer
    -----------------------------------------------------------------------------
    FSM_TXCLIENT_TXD_SEQ : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' then
          txd_rd_cs <= IDLE;
        else
          txd_rd_cs <= txd_rd_ns;
        end if;
      end if;
    end process;
    

    -----------------------------------------------------------------------------
    --  Transmit Client TX Complete Signal
    -----------------------------------------------------------------------------
    TX_COMPLETE_INDICATOR : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if set_txd_done = '1' then
          tx_cmplt <= '1';
        else
          tx_cmplt <= '0';
        end if;
      end if;
    end process;    
    
    -----------------------------------------------------------------------------
    --  Set byte enable pipeline to use individual bits to store the BRAM data 
    --  as it is read.  Then use the stored data to send to the MAC when 
    --  appropriate.
    -----------------------------------------------------------------------------
    BX_EN_PIPE : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then       
        if set_byte_en = '1' then
          set_byte_en_pipe(0) <= '1';
        else
          set_byte_en_pipe(0) <= '0';
        end if;
        set_byte_en_pipe(1) <= set_byte_en_pipe(0);          
      end if;
    end process;
    
    
    -----------------------------------------------------------------------------
    --  Store Byte 1 data so it can be muxed to txd on each packets first 
    --  tx_axis_mac_tready assertion   
    -----------------------------------------------------------------------------    
    TXD_BYTE1 : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' then
          txd_1 <= (others => '0');
        else
          if set_byte_en = '1' then
            txd_1 <= Tx_Client_TxD_2_Mem_Dout(C_CLIENT_WIDTH-1 downto 0);
          else
            txd_1 <= txd_1;
          end if;          
        end if;
      end if;
    end process;   
    
         
    -----------------------------------------------------------------------------
    --  Store Byte 2 data so it can be muxed to txd on each packets second
    --  tx_axis_mac_tready assertion   
    -----------------------------------------------------------------------------        
    TXD_BYTE2 : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' then
          txd_2 <= (others => '0');
        else
          if set_byte_en_pipe(0) = '1' then
            txd_2 <= Tx_Client_TxD_2_Mem_Dout(C_CLIENT_WIDTH-1 downto 0);
          else
            txd_2 <= txd_2;
          end if;          
          
        end if;
      end if;
    end process;       
    
    
    -----------------------------------------------------------------------------
    --  Store Byte 3 data so it can be muxed to txd on each packets third
    --  tx_axis_mac_tready assertion   
    -----------------------------------------------------------------------------            
    TXD_BYTE3 : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' then
          txd_3 <= (others => '0');
        else
          if set_byte_en_pipe(1) = '1' then
            txd_3 <= Tx_Client_TxD_2_Mem_Dout(C_CLIENT_WIDTH-1 downto 0);
          else
            txd_3 <= txd_3;
          end if;          
          
        end if;
      end if;
    end process;    
       
    
    -----------------------------------------------------------------------------
    --  Use this delay to mux in the stored first bytes of data for each packet 
    -----------------------------------------------------------------------------    
    TX_ACK_DELAY : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
       
        if tx_axis_mac_tready = '1' then
          tx_axis_mac_tready_dly <= '1';
        else
          tx_axis_mac_tready_dly <= '0';
        end if;
      end if;

    end process;

    -----------------------------------------------------------------------------
    --  TxD Read Memory Enable - only enable memory when needed
    -----------------------------------------------------------------------------
    TXD_MEM_EN : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if set_txd_en = '1' then
          Tx_Client_TxD_2_Mem_En_int <= '1';
        else
          Tx_Client_TxD_2_Mem_En_int <= '0';
        end if;
      end if;
    end process;

    Tx_Client_TxD_2_Mem_En <= Tx_Client_TxD_2_Mem_En_int;

    -----------------------------------------------------------------------------
    --  TxD Memory Write Enable bit is never written to
    -----------------------------------------------------------------------------
    Tx_Client_TxD_2_Mem_We(0) <= '0';

    -----------------------------------------------------------------------------
    --  Get Lower 2 bits for case statement below
    -----------------------------------------------------------------------------
    txd_rd_addr_1_0     <= txd_rd_addr(1 downto 0); -- for case statement below

    -----------------------------------------------------------------------------
    --  Set the address to be 32 bit aligned for readjustment at the end of
    --    the packet
    -----------------------------------------------------------------------------
    txd_rd_addr_aligned <= txd_rd_addr(c_TxD_addra_width -1 downto 2) & "00";

    -----------------------------------------------------------------------------
    --  Generate the TxD Memory Read Address
    -----------------------------------------------------------------------------
    TXD_MEM_RD_ADDR : process(tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' then
          txd_rd_addr     <= (others => '0');
        else
        --  the end of the packet was reached, so adjust the Rd Addr
        --    to be 32bit aligned if needed
          if align_start_addr = '1' then
            case txd_rd_addr_1_0 is
              when "00" | "01" | "10" => --  | "11" =>
              -- packet ended on a non 32bit aligned address, so adjust it
                txd_rd_addr <=txd_rd_addr_aligned + 4;
              when  others =>
              -- packet ended on a 32bit aligned address, so do not change
                txd_rd_addr <= txd_rd_addr;
            end case;
          else
          --  increment to next address
            if inc_txd_rd_addr = '1' then
              txd_rd_addr <= txd_rd_addr + 1;
            else
              txd_rd_addr <= txd_rd_addr;
            end if;
          end if;
        end if;
      end if;
    end process;

    Tx_Client_TxD_2_Mem_Addr <= txd_rd_addr;
    
    
    ---------------------------------------------------------------------------
    --  Force and update the BRAM with the rd_pntr_addr every ~512 bytes
    ---------------------------------------------------------------------------
    BRAM_UPDATE : process(tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' or set_txd_done = '1' then
          update_bram_cnt     <= (others => '0');
        else
          if update_bram_cnt(9) = '1' and inc_txd_rd_addr = '1' then
            update_bram_cnt <= ('0' & update_bram_cnt(8 downto 0)) + 1;    
          elsif inc_txd_rd_addr = '1' then
            update_bram_cnt <= update_bram_cnt + 1;
          else
            update_bram_cnt <= update_bram_cnt;               
          end if;
        end if;
      end if;
    end process;    
    
    
    ---------------------------------------------------------------------------
    --  Use this signal to dis-allow a transition to the WAIT_TRDY3 state of 
    --  the FSM_TXCLIENT_TXD_CMB FSM when in the WAIT_TRDY2 state
    ---------------------------------------------------------------------------        
    SET_FIRST_BYTE_FILTER : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' or (tx_axis_mac_tready = '0' and tx_axis_mac_tready_dly = '1') then 
          first_bytes <= '0';
        else
          if set_first_bytes = '1' then
            first_bytes <= '1';
          else
            first_bytes <= first_bytes;
          end if;
        end if;
      end if;
    end process;    
    
    
    -----------------------------------------------------------------------------
    --  Mux the Memory data to the Tx Client Interface when appropriate
    --    1. Mux the first byte
    --    2. Mux the second byte at the rising edge of the first tready of the packet
    --    3. Mux the third byte at the second tready of the packet
    --    4. Mux the fourth byte at the third tready of the packet    
    --    5. Mux the remaining bytes
    -----------------------------------------------------------------------------
    TXD_MEM_DATA : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' then
          txd <= (others => '0');
        else
          if set_txd_vld = '1' then
            txd <= Tx_Client_TxD_2_Mem_Dout(C_CLIENT_WIDTH-1 downto 0);  --load first byte and hold until ack
          elsif tx_axis_mac_tready = '1' and  tx_axis_mac_tready_dly = '0' and first_bytes = '1' then 
            txd <= txd_1;
          elsif tx_axis_mac_tready = '1' and  tx_axis_mac_tready_dly = '1' and first_bytes = '1' then 
            txd <= txd_2;
          elsif mux_b3 = '1' then
            txd <= txd_3;    
          elsif  tx_axis_mac_tready = '1' then
            txd <= Tx_Client_TxD_2_Mem_Dout(C_CLIENT_WIDTH -1 downto 0);  --remaining bytes
          else
            txd <= txd;
          end if;
        end if;
      end if;
    end process;

    tx_axis_mac_tdata <= txd;

    -----------------------------------------------------------------------------
    --  Assert Transmit Data Valid for the duration of a transmitted packet
    -----------------------------------------------------------------------------
    SET_TX_DATA_VALID : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' then
          txd_vld <= '0';
        else
          if tx_axis_mac_tready = '1' and tx_axis_mac_tlast_int = '1' then
            txd_vld <= '0';
          elsif set_txd_vld = '1' then
            txd_vld <= '1';
          else
            txd_vld <= txd_vld;
          end if;
        end if;
      end if;
    end process;

    tx_axis_mac_tvalid <= txd_vld;
    
    -----------------------------------------------------------------------------
    --  Assert Transmit Data LAST to end the packet
    -----------------------------------------------------------------------------
    SET_TLAST : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' then
          tx_axis_mac_tlast_int <= '0';
        elsif tx_axis_mac_tready = '1' then
          if clr_txd_vld = '1' then
            tx_axis_mac_tlast_int <= '1';
          else
            tx_axis_mac_tlast_int <= '0';
          end if;
        else
          tx_axis_mac_tlast_int <= tx_axis_mac_tlast_int;
        end if;
      end if;
    end process;    

    tx_axis_mac_tlast <= tx_axis_mac_tlast_int;

    -----------------------------------------------------------------------------
    --  Register the Enable to align it with the TxC Memory Dout Write pointer
    --    Hold the enable from the start of the packet to the end of the packet
    -----------------------------------------------------------------------------
    TXD_WR_POINTER_EN : process (tx_axi_clk)
    begin

      if rising_edge(tx_axi_clk) then
        if reset2tx_client = '1' or (txd_wr_pntr_en = '1' and tx_axis_mac_tready = '1') then
          txd_wr_pntr_en <= '0';      
        elsif set_txc_addr0 = '1' then
          txd_wr_pntr_en <= '1';
        else
          txd_wr_pntr_en <= txd_wr_pntr_en;
        end if;
      end if;
    end process;


end rtl;
