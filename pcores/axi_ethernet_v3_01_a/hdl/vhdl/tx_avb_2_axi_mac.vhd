-------------------------------------------------------------------------------
-- tx_avb_2_axi_mac - entity/architecture pair
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
-- Filename:        tx_avb_2_axi_mac.vhd
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
--                    tx_emac_if.vhd
--          ->    tx_avb_2_axi_mac.vhd (only instantiated when C_AVB = 1)
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

library proc_common_v3_00_a;
use proc_common_v3_00_a.all;

-------------------------------------------------------------------------------
--                  Entity Section
-------------------------------------------------------------------------------

entity tx_avb_2_axi_mac is
  generic (
    C_FAMILY                  : string                        := "virtex6";
    C_TYPE                    : integer range 0 to 2          := 0;
    C_PHY_TYPE                : integer range 0 to 5          := 1
    );
  port (
    --  Add Shim instantiation here
    tx_reset                  : in  std_logic;                    --  Reset 
    tx_client_10_100          : in  std_logic;                    --  1000/100 Mbps indicator
    
    tx_clk                    : in  std_logic;                    --  Tx Client Clock = TX AXI MAC ACLK
    tx_clk_en                 : in  std_logic;                    --  Tx Client Clock enable
    tx_avb_client_data        : in  std_logic_vector(7 downto 0); --  Tx Client Data coming from AVB core
    tx_avb_client_data_valid  : in  std_logic;                    --  Tx Client Data Valid coming from AVB   
    tx_avb_client_underrun    : in  std_logic;                    --  Tx Client Underrun coming from AVB 
    tx_avb_client_ack         : out std_logic;                    --  Tx Client Acknowledge going to AVB
                                     
    tx_axis_mac_tdata         : out std_logic_vector(7 downto 0); --  AXIS MAC data going to MAC Core   
    tx_axis_mac_tvalid        : out std_logic;                    --  AXIS MAC data Valid going to MAC Core           
    tx_axis_mac_tlast         : out std_logic;                    --  AXIS MAC Last going to MAC Core     
    tx_axis_mac_tuser         : out std_logic;                    --  AXIS MAC User going to MAC Core     
    tx_axis_mac_tready        : in  std_logic                     --  AXIS MAC Ready coming from MAC Core            
  
  );
end tx_avb_2_axi_mac;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of tx_avb_2_axi_mac is

  type INPUT_FSM_TYPE is (
                       IDLE,
                       WAIT_STATE_1,
                       B1,
                       B2,
                       WAIT_STATE_2,
                       WR_DATA
                      );
                      
  signal fifo_wr_cs, fifo_wr_ns       : INPUT_FSM_TYPE;
                                      
  type OUTPUT_FSM_TYPE is (
                       IDLE,
                       MUX_B3,
                       RD_DATA
                      );
                      
  signal fifo_rd_cs, fifo_rd_ns       : OUTPUT_FSM_TYPE;                
  
  --  INPUT FSM Signals                     
  signal set_ack                      : std_logic;
  signal set_byte0                    : std_logic;
  signal set_byte1                    : std_logic;
  signal byte1                        : std_logic_vector(8 downto 0);  
  signal set_byte1_reg                : std_logic;  
  signal set_byte2                    : std_logic;
  signal byte2                        : std_logic_vector(8 downto 0);  
  signal set_byte2_reg                : std_logic;
  signal set_fifo_wren                : std_logic;
  
  --  FIFO Interface  
  signal fifo_din                     : std_logic_vector(8 downto 0);
  signal fifo_rden                    : std_logic;                                                                                 
  signal fifo_wren                    : std_logic;                   
  signal fifo_dcount                  : std_logic_vector(8 downto 0);
  signal fifo_dcount_reg              : std_logic_vector(8 downto 0);
  signal fifo_dout                    : std_logic_vector(8 downto 0);
  signal fifo_empty                   : std_logic;                   
  signal fifo_full                    : std_logic;                                                                                  
  signal fifo_empty_reg               : std_logic;                   
  
  --  OUTPUT FSM Signals                     
  signal set_fifo_rden                : std_logic;
  signal set_byte3                    : std_logic;
  signal mux_byte3                    : std_logic; 
  signal byte3                        : std_logic_vector(8 downto 0); 
   
  --  AXI MAC Signals
  signal tx_axis_mac_tdata_int        : std_logic_vector(7 downto 0);
  signal tx_axis_mac_tuser_int        : std_logic;                   
  signal tx_axis_mac_tvalid_int       : std_logic;                   
  signal tx_axis_mac_tlast_int        : std_logic;   
  
  -- ACK for legacy client interface
  signal tx_avb_client_ack_int        : std_logic;  
  signal tx_clk_en_reg                : std_logic;
  signal tx_axis_mac_tready_reg       : std_logic; 
  signal late_tready                  : std_logic;
  signal late_tready_reg              : std_logic;  
  
  signal set_rgmii_sgmii_10_100       : std_logic; 
  signal rgmii_sgmii_10_100           : std_logic;
  
  signal phy_mode_enable              : std_logic;
  
  signal gen_ack                      : std_logic;
  signal tx_avb_client_data_valid_dly1: std_logic;
  
  begin
  
  
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
    --  Input Finite State Machine Sequencer
    -----------------------------------------------------------------------------
    CLOCK_EN_DLY : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        tx_clk_en_reg <= tx_clk_en;
      end if;
    end process; 
    
    -----------------------------------------------------------------------------
    --  Input Finite State Machine Sequencer
    -----------------------------------------------------------------------------
    TREADY_REG : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        tx_axis_mac_tready_reg <= tx_axis_mac_tready;
      end if;
    end process;   
    
    -----------------------------------------------------------------------------
    --  Input Finite State Machine Sequencer
    -----------------------------------------------------------------------------
    LATE_TREADY_REGISTER : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        if fifo_empty = '0' and fifo_empty_reg = '1' then
        --  clear when fifo is not empty
        --    this occurs after the first two bytes have been accepted byt TREADY and 
        --    before the next assertion of TREADY for bytes 3 - n
          late_tready_reg <= '0';
        elsif late_tready = '1' then
          late_tready_reg <= late_tready;
        else
          late_tready_reg <= late_tready_reg;
        end if;
      end if;
    end process;       
    
    
    -----------------------------------------------------------------------------
    --  Input Finite State Machine Sequencer
    -----------------------------------------------------------------------------
    VALID_DLY_FSM_GO : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        if tx_avb_client_data_valid = '1' then
        --  wait a couple of clocks to set gen_ack otherwise it 
        --  will not be recognized in tx_axi_intf.v
          tx_avb_client_data_valid_dly1 <= tx_avb_client_data_valid;       
          gen_ack                       <= tx_avb_client_data_valid_dly1;         
        else
        --  reset 
          tx_avb_client_data_valid_dly1 <= '0';
          gen_ack                       <= '0';                   
        end if;
      end if;
    end process;      
  
    -------------------------------------------------------------------------------------------------------
    --  tx_avb_client_data_valid is asserted with the first byte of a packet.  The first byte is not updated 
    --  until the tx_avb_client_ack_int is asserted.  When this occurs, the packet data is updated on each 
    --  clock cycle until tx_avb_client_data_valid is de-asserted.  The stream of data cannot be throttled.
    --  
    --  To bridge form the Tx Client Interface to the Tx AXIS MAC interface, this FSM Always presents the 
    --  first 3 bytes of a packet to the AXIS MAC Inteface.  The data on the AXIS mac interface cannot update 
    --  until TVALID and TREADY are both HIGH.  The first 3 bytes are directly presented to satisfy the 
    --  throttling on the AXIS MAC interface.  It always accepts the first 2 bytes then throttles until it 
    --  can transmit data.  
    --  The remaing bytes (4 - n) are written to a FIFO and read out at the appropriate time to minimize latency 
    --  The FIFO IO are registered to increas Fmax.  
    --------------------------------------------------------------------------------------------------------
    INPUT_FSM_TYPE_CMB : process (fifo_wr_cs,tx_avb_client_data_valid,phy_mode_enable,set_byte1_reg,
                                  tx_clk_en,tx_clk_en_reg,tx_axis_mac_tready,tx_avb_client_ack_int,
                                  fifo_dcount_reg,fifo_empty_reg,rgmii_sgmii_10_100,gen_ack)
    begin
    
      set_ack        <= '0';
      set_byte0      <= '0';
      set_byte1      <= '0';
      set_byte2      <= '0';
      set_fifo_wren  <= '0';
      late_tready    <= '0';
      set_rgmii_sgmii_10_100 <= '0';
      
      case fifo_wr_cs is
        when IDLE =>
          if gen_ack = '1' and tx_clk_en = '1' and fifo_empty_reg = '1' then
            set_ack     <= '1';          
            set_byte0   <= '1';
            fifo_wr_ns  <= WAIT_STATE_1;
          else
            set_ack     <= '0';
            set_byte0   <= '0';
            fifo_wr_ns  <= IDLE;
          end if;
        when WAIT_STATE_1 =>
          fifo_wr_ns  <= B1; 
          
          
                    
        when B1 =>
          if tx_axis_mac_tready = '0' then
            late_tready <= '1';
          else
            late_tready <= '0';
          end if; 
        
          if phy_mode_enable = '0' then
            if tx_avb_client_data_valid = '1' then
            -- one clock between VALID and READY
              set_byte1   <= '1'; 
              fifo_wr_ns  <= B2;  
            else
              set_byte1   <= '0';
              fifo_wr_ns  <= B1;          
            end if;              
          else  --  phy_mode_enable = '1' 
            if tx_avb_client_data_valid = '1' and tx_avb_client_ack_int = '0' then
              set_byte1   <= '0';  
              fifo_wr_ns  <= B2;
            else
              set_byte1   <= '0';
              fifo_wr_ns  <= B1;          
            end if;  
          end if;

--  below code did not work for 10000bps with 2 clocks beten TVALID and TREADY            
--          if tx_avb_client_data_valid = '1' and tx_axis_mac_tready = '1' and 
--              phy_mode_enable = '0' then
--            set_byte1   <= '1';  
--            fifo_wr_ns  <= B2;
--          elsif tx_avb_client_data_valid = '1' and tx_avb_client_ack_int = '0' and phy_mode_enable = '1' then
--            set_byte1   <= '0';  
--            fifo_wr_ns  <= B2; 
--          else
--            set_byte1   <= '0';
--            fifo_wr_ns  <= B1;          
--          end if;   
            
        when B2 =>
          if tx_avb_client_data_valid = '1' and tx_axis_mac_tready = '1' and tx_clk_en = '1' and
             phy_mode_enable = '0' then
            set_byte1   <= '0'; -- set in previous state            
            fifo_wr_ns  <= WR_DATA;
          elsif tx_avb_client_data_valid = '1' and tx_clk_en = '1' and 
                tx_avb_client_ack_int = '0' and phy_mode_enable = '1' then
            -- in sim tx_axis_mac_tready does not assert in time (asserts on 2nd clk after VALID) 
            set_byte1   <= '1'; 
            fifo_wr_ns  <= WAIT_STATE_2;             
          else
            set_byte1   <= '0';
            fifo_wr_ns  <= B2;          
          end if;   
          
          -- If 1000Mbps this will be set by  the registered output of set_byte1 in the B1 state
          set_byte2 <= set_byte1_reg;
          
        when WAIT_STATE_2 =>
          --  RGMII and SGMII 10/100 chip enable toglle is not very other clock cycle so set a signal 
          --  to allow transition out of the state on the next chip enabled clock cycle
          --    With MII and GMII 10/100 this condition should never get hit
          --      tx_axis_mac_tready will be asserted with tx_clk_en then exit this state before this occurs
          if tx_avb_client_data_valid = '1' and tx_axis_mac_tready = '0' and tx_clk_en = '0' then
            set_rgmii_sgmii_10_100 <= '1';
          else
            set_rgmii_sgmii_10_100 <= '0';
          end if;
        
          -- only here if 100Mbps
          if tx_avb_client_data_valid = '1' and (tx_axis_mac_tready = '1' or rgmii_sgmii_10_100 = '1')  and tx_clk_en = '1' then
--          and phy_mode_enable = '1' then          
            fifo_wr_ns    <= WR_DATA;
          else
            fifo_wr_ns    <= WAIT_STATE_2; 
          end if;
          
          -- 100Mbps so this will be set by the registered output of set_byte1 in the B2 state
          set_byte2 <= set_byte1_reg;      
             
        when WR_DATA =>
          if tx_avb_client_data_valid = '0' then
            set_fifo_wren <= '0';
            fifo_wr_ns    <= IDLE;           
          elsif tx_avb_client_data_valid = '1' and tx_clk_en = '1' then
            set_fifo_wren <= '1';
            fifo_wr_ns    <= WR_DATA;
          else
            set_fifo_wren <= '0';
            fifo_wr_ns    <= WR_DATA;          
          end if;              
                    
        when others =>
          fifo_wr_ns    <= IDLE;
      end case;
    end process;

    -----------------------------------------------------------------------------
    --  Input Finite State Machine Sequencer
    -----------------------------------------------------------------------------
    INPUT_FSM_TYPE_SEQ : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        if tx_reset = '1' then
          fifo_wr_cs <= IDLE;
        else
          fifo_wr_cs <= fifo_wr_ns;
        end if;
      end if;
    end process;  
    
    -----------------------------------------------------------------------------
    --  Anytime set_byte1 is set, register it and send it back to the Input FSM
    --  which will use it to set byte 2 on the next clock
    -----------------------------------------------------------------------------
    SET_BYTE1_REGISTER : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        set_byte1_reg <= set_byte1;
        set_byte2_reg <= set_byte2;
      end if;
    end process;    
    
    
    -----------------------------------------------------------------------------
    --  Anytime set_byte1 is set, register it and send it back to the Input FSM
    --  which will use it to set byte 2 on the next clock
    -----------------------------------------------------------------------------
    BYTE1_REGISTER : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        if set_byte1 = '1' then
          byte1(7 downto 0) <= tx_avb_client_data;
          byte1(8)          <= tx_avb_client_underrun;
        else
          byte1             <= byte1;
        end if;
      end if;
    end process;   
    
    
    -----------------------------------------------------------------------------
    --  Only need to set this if TREADY occured 2 clocks after TVALID
    -----------------------------------------------------------------------------
    BYTE2_REGISTER : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        if set_byte2 = '1' and late_tready_reg = '1' then
          byte2(7 downto 0) <= tx_avb_client_data;
          byte2(8)          <= tx_avb_client_underrun;
        else
          byte2             <= byte2;
        end if;
      end if;
    end process;       
     
          
    
    -----------------------------------------------------------------------------
    --  Register the write enable signal going to the FIFO
    -----------------------------------------------------------------------------
    FIFO_WR_ENABLE : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        fifo_wren <= set_fifo_wren;
      end if;
    end process;   
        
    -----------------------------------------------------------------------------
    --  Register the Data being Written to the FIFO
    -----------------------------------------------------------------------------
    FIFO_WR_DATA : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        if set_fifo_wren = '1' then
          fifo_din(7 downto 0) <= tx_avb_client_data;
          fifo_din(8)          <= tx_avb_client_underrun;
        else
          fifo_din <= fifo_din;
        end if;
      end if;
    end process;       
    
    -----------------------------------------------------------------------------
    --  Generate a Registered Acknowledge signal
    -----------------------------------------------------------------------------
    TXD_ACK : process(tx_clk)
    begin

      if rising_edge(tx_clk) then
        if set_ack = '1' then
          tx_avb_client_ack_int <= '1';
        elsif tx_clk_en = '1' then
          tx_avb_client_ack_int <= '0';
        else
          tx_avb_client_ack_int <= tx_avb_client_ack_int;
        end if;
      end if;
    end process;
    tx_avb_client_ack <= tx_avb_client_ack_int;
    
    -----------------------------------------------------------------------------
    --  Generate a Registered Acknowledge signal
    -----------------------------------------------------------------------------
    FORCE_WAIT_STATE_2_EXIT : process(tx_clk)
    begin

      if rising_edge(tx_clk) then
        if tx_reset = '1' or (tx_clk_en = '1' and rgmii_sgmii_10_100 = '1') then
          rgmii_sgmii_10_100 <= '0'; 
        elsif set_rgmii_sgmii_10_100 = '1' then
          rgmii_sgmii_10_100 <= '1';
        else
          rgmii_sgmii_10_100 <= rgmii_sgmii_10_100;
        end if;

      end if;
    end process;  
  
    -----------------------------------------------------------------------------
    --  Instantiate the Common Clock FWFT FIFO (9 bits wide X 512 Deep)
    -----------------------------------------------------------------------------
    ELASTIC_FIFO : entity proc_common_v3_00_a.basic_sfifo_fg
    generic map(
      C_DWIDTH                      => 9,
        -- FIFO data Width (Read and write data ports are symetric)
      C_DEPTH                       => 512,
        -- FIFO Depth (set to power of 2)
      C_HAS_DATA_COUNT              => 1,
        -- 0 = DataCount not used
        -- 1 = Data Count used 
      C_DATA_COUNT_WIDTH            => 9,
      -- Data Count bit width (Max value is log2(C_DEPTH))
      C_IMPLEMENTATION_TYPE         => 0, 
        --  0 = Common Clock BRAM / Distributed RAM (Synchronous FIFO)
        --  1 = Common Clock Shift Register (Synchronous FIFO)
      C_MEMORY_TYPE                 => 1,
        --   0 = Any
        --   1 = BRAM
        --   2 = Distributed Memory  
        --   3 = Shift Registers
      C_PRELOAD_REGS                => 1, 
        -- 0 = normal            
        -- 1 for FWFT
      C_PRELOAD_LATENCY             => 0,              
        -- 0 for FWFT
        -- 1 = normal            
      C_USE_FWFT_DATA_COUNT         => 1, 
        -- 0 = normal            
        -- 1 for FWFT
      C_FAMILY                      =>  C_FAMILY
    
      )
    port map(
      CLK                           =>  tx_clk,
      DIN                           =>  fifo_din,                   
      RD_EN                         =>  fifo_rden,                  
      SRST                          =>  tx_reset,            
      WR_EN                         =>  fifo_wren,                  
      DATA_COUNT                    =>  fifo_dcount,                
      DOUT                          =>  fifo_dout,                  
      EMPTY                         =>  fifo_empty,                 
      FULL                          =>  fifo_full                   
      );    
                                                                  
    -----------------------------------------------------------------------------
    --  Register the empty signal before using it in the FSM
    -----------------------------------------------------------------------------   
    FIFO_EMPTY_REGISTER : process (tx_clk)
    begin                                                                  
                                                                           
      if rising_edge(tx_clk) then                                          
        fifo_empty_reg <= fifo_empty;
      end if;
    end process;      
    
    -----------------------------------------------------------------------------
    --  Register the empty signal before using it in the FSM
    -----------------------------------------------------------------------------   
    FIFO_DCOUNT_REGISTER : process (tx_clk)
    begin                                                                  
                                                                           
      if rising_edge(tx_clk) then                                          
        fifo_dcount_reg <= fifo_dcount;
      end if;
    end process;           
    
    
    -----------------------------------------------------------------------------
    --  This FSM starts reading data when the FIFO is no longer empty
    --  All signals to and from the FSM have been registered for Fmax
    --  This FSM will read the First Word Fall Through (FWFT) FIFO until
    --    the Empty Flag asserts.  The FWFT FIFO does not assert Empty 
    --    until after the last word has been read.  This occurs with the 
    --    de-assertion of tx_axis_mac_tready.  As a result, an Underrun 
    --    codition will occur.  This has no effect on the data as this 
    --    condition is non-destructive to the FIFO contents. 
    --    This FIFO onlt store bytes 4-n of eack packet.
    --      See the INPUT_FSM_TYPE_CMB comment for reason why 
    -----------------------------------------------------------------------------
    OUTPUT_FSM_TYPE_CMB : process (fifo_rd_cs,fifo_empty_reg,phy_mode_enable,
                                   tx_axis_mac_tready)
    begin
    
      set_fifo_rden  <= '0';
      set_byte3      <= '0';
      mux_byte3      <= '0';
      
      case fifo_rd_cs is
        when IDLE =>
          if fifo_empty_reg = '0' then
            if phy_mode_enable = '0' then
            --  Need to prime the data for 1000Mbps
              set_byte3     <= '1';
              set_fifo_rden <= '1';
              fifo_rd_ns    <= MUX_B3; 
            else
              set_byte3     <= '0';
              set_fifo_rden <= '0';  
              fifo_rd_ns    <= RD_DATA;           
            end if;
          else
            set_byte3     <= '0';
            set_fifo_rden <= '0';  
            fifo_rd_ns    <= IDLE;
          end if;
        when MUX_B3 =>
          if tx_axis_mac_tready = '1' then
            --  Now set the Mux enable to swith in the fifo data when 1000Mbps
            mux_byte3     <= '1';
            set_fifo_rden <= '1';   
            fifo_rd_ns    <= RD_DATA;
          else
            mux_byte3     <= '0';
            set_fifo_rden <= '0';   
            fifo_rd_ns    <= MUX_B3;          
          end if;     
        when RD_DATA =>
          if fifo_empty_reg = '1' then
            set_fifo_rden <= '0';
            fifo_rd_ns    <= IDLE;          
          elsif tx_axis_mac_tready = '1' then
            set_fifo_rden <= '1';
            fifo_rd_ns    <= RD_DATA;
          else
            set_fifo_rden <= '0';
            fifo_rd_ns    <= RD_DATA;          
          end if;           

        when others =>
          fifo_rd_ns    <= IDLE;
      end case;
    end process;

    -----------------------------------------------------------------------------
    -- Output Finite State Machine Sequencer
    -----------------------------------------------------------------------------
    OUTPUT_FSM_TYPE_SEQ : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        if tx_reset = '1' then
          fifo_rd_cs <= IDLE;
        else
          fifo_rd_cs <= fifo_rd_ns;
        end if;
      end if;
    end process;      
    
    -----------------------------------------------------------------------------
    -- Register the FIFO Read signal 
    -----------------------------------------------------------------------------
    FIFO_RDEN_REGISTER : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        fifo_rden <= set_fifo_rden;
      end if;
    end process;         
    
    -----------------------------------------------------------------------------
    --  When 1000Mbps, the 4th byte must be read early and muxed into the tx_axis_mac_tdata
    --  on the second rising egde of tx_axis_mac_tready signal 
    --    set_byte3 will always be low when operating at 100Mbps
    -----------------------------------------------------------------------------
    HOLD_B3 : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        if set_byte3 = '1' then
          byte3 <= fifo_dout;
        else
          byte3 <= byte3;
        end if;
      end if;
    end process;     
    
    -----------------------------------------------------------------------------
    --  This is the output data mux that drives tx_axis_mac_tdata and tx_axis_mac_tuser
    --    set_byte0 = '1' or set_byte1 = '1' or set_byte2 = '1' are used to mux the first 3 bytes
    --    When 1000Mbps mux_byte3 will set the 4th byte
    --      mux_byte3 occurs with the rising edge of tx_axis_mac_tready
    --    tx_axis_mac_tready muxes all the remaining bytes of the packet from the read from the fifo
    -----------------------------------------------------------------------------
    TX_AXI_MAC_TDATA_MUX : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        if set_byte0 = '1' or        
        (phy_mode_enable = '0' and set_byte1 = '1'     and tx_axis_mac_tready  = '1') or     -- TREADY occured 1clk after TVALID
        (phy_mode_enable = '0' and set_byte2 = '1'     and tx_axis_mac_tready_reg  = '1') or -- TREADY occured 1clk after TVALID       
        (phy_mode_enable = '1' and set_byte2_reg = '1' and tx_axis_mac_tready = '1') then
        --  output the first and third bytes then wait for tx_axis_mac_tready
          tx_axis_mac_tdata_int <= tx_avb_client_data;
          tx_axis_mac_tuser_int <= tx_avb_client_underrun;
        elsif (phy_mode_enable = '0' and late_tready_reg = '1' and                    --  rising edge detect 
               tx_axis_mac_tready = '1' and tx_axis_mac_tready_reg = '0' and           --  put byte 1 on the bus when TREADY
               fifo_empty_reg = '1') then                                              --  occurs 2 clocks after TVALID 
          --  output the second byte then wait for tx_axis_mac_tready
          tx_axis_mac_tdata_int <= byte1(7 downto 0);
          tx_axis_mac_tuser_int <= byte1(8);  
        elsif (phy_mode_enable = '0' and late_tready_reg = '1' and                    --  rising edge detect               
               tx_axis_mac_tready = '1' and tx_axis_mac_tready_reg = '1' and           --  put byte 2 on the bus when TREADY
               fifo_empty_reg = '1') then                                              --  occurs 2 clocks after TVALID     
          --  output the second byte then wait for tx_axis_mac_tready
          tx_axis_mac_tdata_int <= byte2(7 downto 0);
          tx_axis_mac_tuser_int <= byte2(8);            
        elsif phy_mode_enable = '1' and set_byte1_reg = '1' and tx_axis_mac_tready = '1' then
          --  output the second byte then wait for tx_axis_mac_tready
          tx_axis_mac_tdata_int <= byte1(7 downto 0);
          tx_axis_mac_tuser_int <= byte1(8);         
        elsif mux_byte3 = '1' then
          --  output the 4th then wait for tx_axis_mac_tready
          --  set_byte3 overlaps tx_axis_mac_tready        
          tx_axis_mac_tdata_int <= byte3(7 downto 0);
          tx_axis_mac_tuser_int <= byte3(8);                                                                                 
        elsif tx_axis_mac_tready = '1' then                                      
          tx_axis_mac_tdata_int <= fifo_dout(7 downto 0);                        
          tx_axis_mac_tuser_int <= fifo_dout(8);                                 
        else
          tx_axis_mac_tdata_int <= tx_axis_mac_tdata_int;
          tx_axis_mac_tuser_int <= tx_axis_mac_tuser_int;
        end if;
      end if;
    end process;   
    
    
    
--    TX_AXI_MAC_TDATA_MUX : process (tx_clk)
--    begin
--
--      if rising_edge(tx_clk) then
--        if phy_mode_enable = '1' then
--          if set_byte0 = '1' or 
--             (set_byte2_reg = '1' and tx_axis_mac_tready = '1') then
--          --  output the first byte then wait for tx_axis_mac_tready
--            tx_axis_mac_tdata_int <= tx_avb_client_data;
--            tx_axis_mac_tuser_int <= tx_avb_client_underrun;              
--          elsif set_byte1_reg = '1' and tx_axis_mac_tready = '1' then
--          --  output the second byte then wait for tx_axis_mac_tready
--            tx_axis_mac_tdata_int <= byte1(7 downto 0);
--            tx_axis_mac_tuser_int <= byte1(8);                                                                                           
--          elsif tx_axis_mac_tready = '1' then                                      
--            tx_axis_mac_tdata_int <= fifo_dout(7 downto 0);                        
--            tx_axis_mac_tuser_int <= fifo_dout(8);                                 
--          else
--            tx_axis_mac_tdata_int <= tx_axis_mac_tdata_int;
--            tx_axis_mac_tuser_int <= tx_axis_mac_tuser_int;
--          end if;      
--        else
--          if set_byte0 = '1' or 
--             (set_byte1 = '1' and tx_axis_mac_tready  = '1') or       -- TREADY occured 1clk after TVALID
--             (set_byte2 = '1' and tx_axis_mac_tready_reg  = '1') then -- TREADY occured 1clk after TVALID    
--            tx_axis_mac_tdata_int <= tx_avb_client_data;
--            tx_axis_mac_tuser_int <= tx_avb_client_underrun;
--          elsif ((tx_axis_mac_tready = '1' and tx_axis_mac_tready_reg = '0')  and  --  rising edge detect 
--                 late_tready_reg = '1' and fifo_empty_reg = '1') then              --  put byte 1 on the bus when TREADY
--                                                                                   --  occurs 2 clocks after TVALID 
--           --  output the second byte then wait for tx_axis_mac_tready
--             tx_axis_mac_tdata_int <= byte1(7 downto 0);
--             tx_axis_mac_tuser_int <= byte1(8);  
--          elsif ((tx_axis_mac_tready = '1' and tx_axis_mac_tready_reg = '1')  and  --  rising edge detect               
--                 late_tready_reg = '1' and fifo_empty_reg = '1') then              --  put byte 2 on the bus when TREADY
--                                                                                   --  occurs 2 clocks after TVALID     
--           --  output the second byte then wait for tx_axis_mac_tready
--             tx_axis_mac_tdata_int <= byte2(7 downto 0);
--             tx_axis_mac_tuser_int <= byte2(8);            
--          elsif mux_byte3 = '1' then
--          --  output the 4th then wait for tx_axis_mac_tready
--              --  set_byte3 overlaps tx_axis_mac_tready        
--            tx_axis_mac_tdata_int <= byte3(7 downto 0);
--            tx_axis_mac_tuser_int <= byte3(8);
--                                                                                   
--          elsif tx_axis_mac_tready = '1' then                                      
--            tx_axis_mac_tdata_int <= fifo_dout(7 downto 0);                        
--            tx_axis_mac_tuser_int <= fifo_dout(8);                                 
--          else
--            tx_axis_mac_tdata_int <= tx_axis_mac_tdata_int;
--            tx_axis_mac_tuser_int <= tx_axis_mac_tuser_int;
--          end if;
--        end if;
--      end if;
--    end process;       
    
    tx_axis_mac_tdata <= tx_axis_mac_tdata_int;
    tx_axis_mac_tuser <= tx_axis_mac_tuser_int;
    
    -----------------------------------------------------------------------------
    --  Setting TVALID may be different for when operating at 1000Mbps and 100Mbps
    --    This process sets it appropriately for the two different modes
    --      For 1000Mbps is can be set immediately with set_byte0
    --      For 100Mbps it must be delayed until ACK has transitioned LOW to 
    --        allow new data to be preset
    -----------------------------------------------------------------------------
    TX_AXI_MAC_TVALID_REG : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        if tx_reset = '1' or (tx_axis_mac_tlast_int = '1' and tx_axis_mac_tready = '1') then
          --  Count should only equal twice for every packet
              --  1st time when data is initially written to the FIFO
              --  2nd at the end of the packet 
              --  So use set_fifo_rden to filter out the 1st condition  
              --    and only set at the end of the packet
          tx_axis_mac_tvalid_int <= '0';        
        elsif set_byte0 = '1' and phy_mode_enable = '0' then
          tx_axis_mac_tvalid_int <= '1';
        elsif tx_clk_en = '1' and tx_avb_client_ack_int = '1' and phy_mode_enable = '1' then
        --use reg delay to allow tx_axis_mac_tvalid_int to be set early which will allow proper tx_axis_mac_tready to assert at correct time
          tx_axis_mac_tvalid_int <= '1';          
        else
          tx_axis_mac_tvalid_int <= tx_axis_mac_tvalid_int;
        end if;
      end if;
    end process;    
       
    tx_axis_mac_tvalid <= tx_axis_mac_tvalid_int;
    
    -----------------------------------------------------------------------------
    --  Use the FIFO DATA_COUNT to determine when to assert TLAST
    --    When the count is 1 and set_fifo_rden is asserted, then set TLAST
    -----------------------------------------------------------------------------
    TX_AXI_MAC_TLAST_REG : process (tx_clk)
    begin

      if rising_edge(tx_clk) then
        if (fifo_dcount =  "000000000" and set_fifo_rden = '1' and tx_axis_mac_tlast_int = '0') then
          --  Count should only equal twice for every packet
              --  1st time when data is initially written to the FIFO
              --  2nd at the end of the packet 
              --  So use set_fifo_rden to filter out the 1st condition  
              --    and only set at the end of the packet
          tx_axis_mac_tlast_int <= '1';        
        elsif tx_reset = '1' or tx_axis_mac_tready = '1' then  
           tx_axis_mac_tlast_int <= '0';   
        else
          tx_axis_mac_tlast_int <= tx_axis_mac_tlast_int;
        end if;
      end if;
    end process;    
       
    tx_axis_mac_tlast <= tx_axis_mac_tlast_int;

   
end rtl;
