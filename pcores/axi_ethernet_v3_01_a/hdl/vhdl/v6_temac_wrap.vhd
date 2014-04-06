--------------------------------------------------------------------------------
-- v6_temac_wrap.vhd
-- Author     : Xilinx Inc.
-- ------------------------------------------------------------------------------
--
-- *************************************************************************
--
-- (c) Copyright 2004-2011 Xilinx, Inc. All rights reserved.
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
-- *************************************************************************
--
-------------------------------------------------------------------------------
-- This is based on Coregen Wrappers from ISE O.40d (13.1)
-- Wrapper version 2.1
-------------------------------------------------------------------------------
-- Structure:   
--              v6_temac_wrap.vhd
--
--
--    ---------------------------------------------------------------------
--    | axi_ethernet                                                      |
--    |           --------------------------------------------------------|
--    |           |v6_temac_wrap                                          |
--    |           |                                                       |
--    |           |                                                       |
--    |           |              -----------------------------------------|
--    |           |              | v6_emac_block_xxxx                     |
--    |           |              | xxxx = mii, gmii, rgmii, sgmii, 1000bx |
--    |           |              |                                        |
--    |         --|--------------|--------------|                         |
--    |           |     ipic     |              |                         |
--    |           |     intf     |              |                         |
--    |         <-|--------------|---------|    |                         |
--    |           |              |         |    |                         |
--    |           |              |         |    v                         |
--    |           |              |    ---------------------               |
--    |           |              |    |   v6_emac_v2_2    |               |
--    |           |              |    |                   |               |
--    |           |              |    |                   |               |
--    |           |              |    |                   |               |
--    |           |              |    |                   |               |
--    |           |              |    |                   |               |
--    |           |              |    |      ---------    |  ---------    |
--    |         ->|--------------|--->| Tx   |       |Tx  |--|       |--->|
--    |           |              |    | AXI-S|       |PHY |  |       |    |
--    |           |              |    | I/F  |       |I/F |  |       |    |
--    |           |     AXI-S    |    |      |emac_  |    |  | PHY   |    |
--    |           |              |    |      |wrapper|    |  | I/F   |    |
--    |           |              |    |      |       |    |  |if reqd|    |
--    |           |              |    | Rx   |       |Rx  |  | mii   |    |
--    |           |              |    | AX)-S|       |PHY |  | gmii  |    |
--    |         <-|<-------------|----| I/F  |       |I/F |<-| rgmii |<---|
--    |           |              |    |      ---------    |  ---------    |
--    |           |              |    ---------------------               |
--    |           |              |           |     |                      |
--    |           |              |        --------------                  |
--    |           |              |        |  STATS     |                  |
--    |           |              |        |    DECODE  |                  |
--    |           |              |        |            |                  |
--    |           |              |        --------------                  |
--    |           |              |                                        |
--    |           |              -----------------------------------------|
--    |           --------------------------------------------------------|
--    ---------------------------------------------------------------------
--
------------------------------------------------------------------------------
-- Author:      
-- History:
--
------------------------------------------------------------------------------
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
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.family_support.all;


library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

library unisim;
use unisim.vcomponents.all;



entity v6_temac_wrap is
  generic(
    C_PHY_TYPE            : integer range 0 to 5          := 1;
      -- 0 - MII
      -- 1 - GMII
      -- 2 - RGMII V1.3
      -- 3 - RGMII V2.0
      -- 4 - SGMII
      -- 5 - 1000Base-X PCS/PMA @ 1 Gbps
    C_AT_ENTRIES          : integer                       := 4;
    C_HAS_STATS           : boolean                       := true;
    C_HALFDUP             : integer range 0 to 1          := 0;
    C_FAMILY              : string                        := "virtex6";
    C_INCLUDE_IO          : integer range 0 to 1          := 1;
    C_STATS_WIDTH         : integer range 32 to 64        := 64;
    C_TEMAC_PHYADDR       : std_logic_vector(4 downto 0)  := "00001"

   );

   port(
    -- GTX_CLK 125 MHz clock frequency supplied by the user
      gtx_clk                    : in  std_logic;
      -- asynchronous reset
    RESET                      : in  std_logic;

      -- Initial Unicast Address Value
      --unicast_address               : in std_logic_vector(47 downto 0);

      -- Receiver Interface
      ----------------------------

      -- added 05/5/2011     
      RX_CLK_ENABLE_OUT           : out std_logic;

      rx_statistics_vector       : out std_logic_vector(27 downto 0);
      rx_statistics_valid        : out std_logic;
      rx_axis_filter_tuser       : out std_logic_vector(C_AT_ENTRIES downto 0);
      
      rx_mac_aclk                : out std_logic;
      rx_reset                   : out std_logic;
      rx_axis_mac_tdata          : out std_logic_vector(7 downto 0); 
      rx_axis_mac_tvalid         : out std_logic;
      rx_axis_mac_tlast          : out std_logic; 
      rx_axis_mac_tuser          : out std_logic;

      -- Transmitter Interface
      -------------------------------
      tx_ifg_delay               : in  std_logic_vector(7 downto 0);
      tx_statistics_vector       : out std_logic_vector(31 downto 0);
      tx_statistics_valid        : out std_logic;
      
      -- added for avb connection 03/21/2011     
      tx_avb_en                  : out std_logic;       
      
      tx_mac_aclk                : out std_logic;
      tx_reset                   : out std_logic;
      tx_axis_mac_tdata          : in  std_logic_vector(7 downto 0);
      tx_axis_mac_tvalid         : in  std_logic;
      tx_axis_mac_tlast          : in  std_logic;
      tx_axis_mac_tuser          : in  std_logic;
      tx_axis_mac_tready         : out std_logic;
      tx_collision               : out std_logic;
      tx_retransmit              : out std_logic;

      -- MAC Control Interface
      --------------------------
      pause_req                  : in  std_logic;
      pause_val                  : in  std_logic_vector(15 downto 0);

      -- Reference clock for IDELAYCTRL's
      refclk                     : in  std_logic;
      
      -- MII Interface
      -----------------
      mii_txd                    : out std_logic_vector(3 downto 0);
      mii_tx_en                  : out std_logic;
      mii_tx_er                  : out std_logic;
      mii_rxd                    : in  std_logic_vector(3 downto 0);
      mii_rx_dv                  : in  std_logic;
      mii_rx_er                  : in  std_logic;
      mii_rx_clk                 : in  std_logic;
      mii_col                    : in  std_logic;
      mii_crs                    : in  std_logic;
      mii_tx_clk                 : in  std_logic;      
      
      -- GMII Interface
      -----------------
      gmii_txd                   : out std_logic_vector(7 downto 0);
      gmii_tx_en                 : out std_logic;
      gmii_tx_er                 : out std_logic;
      gmii_rxd                   : in  std_logic_vector(7 downto 0);
      gmii_rx_dv                 : in  std_logic;
      gmii_rx_er                 : in  std_logic;
      gmii_rx_clk                : in  std_logic;
      gmii_col                   : in  std_logic;
      gmii_crs                   : in  std_logic;
      speedis10100               : out std_logic;
      gmii_tx_clk                : out std_logic;         
      
      -- RGMII Interface
      --------------------
      rgmii_txd                  : out std_logic_vector(3 downto 0);
      rgmii_tx_ctl               : out std_logic;
      rgmii_txc                  : out std_logic;
      rgmii_rxd                  : in  std_logic_vector(3 downto 0);
      rgmii_rx_ctl               : in  std_logic;
      rgmii_rxc                  : in  std_logic;


      -- MDIO Interface
      -------------------
      mdio_i                     : in  std_logic;
      mdio_o                     : out std_logic;
      mdio_t                     : out std_logic;
      mdc                        : out std_logic;

      -- IPIC Interface
      -----------------
      Bus2IP_Clk                 : in  std_logic;
      Bus2IP_Reset               : in  std_logic;
      Bus2IP_Addr                : in  std_logic_vector(31 downto 0);
      Bus2IP_CS                  : in  std_logic;
      Bus2IP_RdCE                : in  std_logic;
      Bus2IP_WrCE                : in  std_logic;
      Bus2IP_Data                : in  std_logic_vector(31 downto 0);
      IP2Bus_Data                : out std_logic_vector(31 downto 0);
      IP2Bus_WrAck               : out std_logic;
      IP2Bus_RdAck               : out std_logic;
      IP2Bus_Error               : out std_logic;
      
      mac_irq                    : out std_logic;
      -- Speed Indicator
      speed_is_10_100            : out std_logic;

    -- SGMII Interface
    TXP                      : out std_logic;
    TXN                      : out std_logic;
    RXP                      : in  std_logic;
    RXN                      : in  std_logic;

    EMACCLIENTANINTERRUPT     : out std_logic;
    EMACResetDoneInterrupt    : out std_logic;
    
    -- SGMII MGT Clock buffer inputs 
    MGTCLK_P                   : in  std_logic;
    MGTCLK_N                   : in  std_logic
   );
    
end v6_temac_wrap;




architecture wrapper of v6_temac_wrap is

  -----------------------------------------------------------------------------
  -- Function bool2int
  --
  -- This function is used to convert a boolean value TRUE and FALSE to
  -- an integer 1 or 0 respectively.
  -----------------------------------------------------------------------------
  function bool2int(inval: boolean) return integer is
    variable outval : integer := 0;
    begin
      if (inval = TRUE) then
        outval:=1;
      else
        outval:=0;
      end if;
      return outval;
  end bool2int;
  -----------------------------------------------------------------------------
  -- Function HZ_TO_PS
  --
  -- This function is used to convert a clock frequency in HZ  to
  -- to a clock period in ps.
  -----------------------------------------------------------------------------
  function HZ_TO_PS(CLK_FREQ_HZ : integer) return integer is
    constant C_CLK_IN_PS_BY_2: integer := (1000000 / CLK_FREQ_HZ) / 2;
    constant CLK_IN_PS       : integer := (1000000 / CLK_FREQ_HZ);
    constant REMAINDER       : integer := 1000000 rem (CLK_FREQ_HZ);
    variable outval : integer := 0;
    begin
      if (C_CLK_IN_PS_BY_2 < REMAINDER) then
        outval:=(CLK_IN_PS + 1);
      else
        outval:=CLK_IN_PS;
      end if;
      return outval;
  end function HZ_TO_PS;
  -------------------------------------------------------------------------------
  -- This function sets the data width based upon the parameter C_PHY_TYPE
  -- -  Only PHY types of 0 (MII) and 1 (GMII) are supported in the soft temac
  --    -  0 MII        = 4 bit data bus
  --    -  1 GMII       = 8 bit data bus
  --    -  3 RGMII_v20  = 8 bit data bus
  
  -------------------------------------------------------------------------------
  function getPhyWidth (inputphyType : integer) return integer is
     variable phyWidth : Integer := 0;
  
   begin
  
     if (inputphyType = 0) then -- MII
        phyWidth := 4;
     else
        phyWidth := 8;          -- GMII or RGMII (rgmii uses gmii interface)
     end if;
  
     return(phyWidth);
  end function getPhyWidth;


  -------------------------------------------------------------------------------
  --  This function set the width of the statistics vectors based upon the
  --  C_HALFDUP parameter
  -------------------------------------------------------------------------------
  function numstats(inval: integer) return integer is
    variable outval : integer := 0;
    begin
      if (inval = 1) then
        outval:=44;
      else
        outval:=34;
      end if;
      return outval;
  end numstats;

-------------------------------------------------------------------------------
-- Constant declarations
-------------------------------------------------------------------------------
constant C_TYPE              : integer :=  2;
      -- 0 - Soft TEMAC capable of 10 or 100 Mbps
      -- 1 - Soft TEMAC capable of 10, 100, or 1000 Mbps
      -- 2 - V6 hard TEMAC
constant C_HAS_MII           : boolean := (C_PHY_TYPE = 0);
constant C_HAS_GMII          : boolean := (C_PHY_TYPE = 1);
constant C_HAS_RGMII         : boolean := (C_PHY_TYPE = 3);
constant C_HAS_SGMII         : boolean := (C_PHY_TYPE = 4);
constant C_HAS_GPCS          : boolean := (C_PHY_TYPE = 5);
constant C_PHY_WIDTH         : integer := (getPhyWidth(C_PHY_TYPE));
constant C_HALF_DUPLEX       : boolean := (C_HALFDUP = 1);
constant C_HAS_HOST          : boolean := true;
constant C_ADD_FILTER        : boolean := true;

constant C_HAS_ENABLES       : boolean := true;
constant C_SPEED_10_100      : boolean := ((C_TYPE = 0) or (C_TYPE = 2 and (C_PHY_TYPE = 0)));
constant C_SPEED_1000        : boolean := false;
constant C_TRI_SPEED         : boolean := ((C_TYPE = 1) or (C_TYPE = 2 and not (C_PHY_TYPE = 0)));    
    
constant C_NUM_STATS         : integer := (numstats(C_HALFDUP));      -- allow for max 42 standard counters plus two user defined
constant C_CNTR_RST          : boolean := true;
constant C_INTERNAL_INT      : boolean := ((C_PHY_TYPE = 1 and C_INCLUDE_IO = 0) or (C_TYPE = 1 and (C_PHY_TYPE = 4 or C_PHY_TYPE = 5))); 
    
signal bus_rst_i         : std_logic;
signal bus_rstn          : std_logic;
signal clk_ds            : std_logic;

begin -- architecture body

  bus_rst_i <= Bus2IP_Reset;

  bus_rstn     <= not bus_rst_i;

  -----------------------------------------------------------------------------
  --  GMII
  -----------------------------------------------------------------------------
  GEN_GMII : if C_PHY_TYPE = 1 generate
  begin
  
    --  Signals used in other AXI Ethernet PHY configurations that need tied off here
    EMACResetDoneInterrupt <= '1';
    EMACCLIENTANINTERRUPT  <= '0';  
  
    I_GMII : entity axi_ethernet_v3_01_a.v6_emac_block_gmii 
    generic map (
        C_HAS_MII      => C_HAS_MII,      
        C_HAS_GMII     => C_HAS_GMII,     
        C_HAS_RGMII    => C_HAS_RGMII,    
        C_HAS_SGMII    => C_HAS_SGMII,     
        C_HAS_GPCS     => C_HAS_GPCS,     
        C_PHY_WIDTH    => C_PHY_WIDTH,    
        C_HALF_DUPLEX  => C_HALF_DUPLEX,  
        C_HAS_HOST     => C_HAS_HOST,     
        C_ADD_FILTER   => C_ADD_FILTER,   
        C_AT_ENTRIES   => C_AT_ENTRIES,   
        C_FAMILY       => C_FAMILY,       
        C_SPEED_10_100 => C_SPEED_10_100, 
        C_SPEED_1000   => C_SPEED_1000,   
        C_TRI_SPEED    => C_TRI_SPEED,    
        C_HAS_STATS    => C_HAS_STATS,    
        C_NUM_STATS    => C_NUM_STATS,    
        C_CNTR_RST     => C_CNTR_RST,     
        C_STATS_WIDTH  => C_STATS_WIDTH,  
        C_INTERNAL_INT => C_INTERNAL_INT,
        C_INCLUDE_IO   => C_INCLUDE_IO, 
        C_HALFDUP      => C_HALFDUP,
        C_TYPE         => C_TYPE,    
        C_PHY_TYPE     => C_PHY_TYPE
     )
  
     port map(
        gtx_clk                    =>  gtx_clk,                    
        -- asynchronous reset          
        glbl_rstn                  =>  bus_rstn,                  
        rx_axi_rstn                =>  '1',   -- tie HIGH per CORE Gen             
        tx_axi_rstn                =>  '1',   -- tie HIGH per CORE Gen              
                                                                
        -- Receiver Interface        
        ---------------------------  
        RX_CLK_ENABLE_OUT          =>  RX_CLK_ENABLE_OUT,
        rx_statistics_vector       =>  rx_statistics_vector,       
        rx_statistics_valid        =>  rx_statistics_valid,        
        rx_axis_filter_tuser       =>  rx_axis_filter_tuser,
                                                                
        rx_mac_aclk                =>  rx_mac_aclk,                
        rx_reset                   =>  rx_reset,                   
        rx_axis_mac_tdata          =>  rx_axis_mac_tdata,          
        rx_axis_mac_tvalid         =>  rx_axis_mac_tvalid,         
        rx_axis_mac_tlast          =>  rx_axis_mac_tlast,          
        rx_axis_mac_tuser          =>  rx_axis_mac_tuser,          
                                     
        -- Transmitter Interface     
        ---------------------------  
        tx_ifg_delay               =>  tx_ifg_delay,               
        tx_statistics_vector       =>  tx_statistics_vector,       
        tx_statistics_valid        =>  tx_statistics_valid,    
        
       -- added for avb connection 03/21/2011     
        tx_avb_en                  =>  tx_avb_en,
                                                                
        tx_mac_aclk                =>  tx_mac_aclk,                
        tx_reset                   =>  tx_reset,                   
        tx_axis_mac_tdata          =>  tx_axis_mac_tdata,          
        tx_axis_mac_tvalid         =>  tx_axis_mac_tvalid,         
        tx_axis_mac_tlast          =>  tx_axis_mac_tlast,          
        tx_axis_mac_tuser          =>  tx_axis_mac_tuser,          
        tx_axis_mac_tready         =>  tx_axis_mac_tready,         
        tx_collision               =>  tx_collision,               
        tx_retransmit              =>  tx_retransmit,              
                                                                
        -- MAC Control Interface    
        ------------------------    
        pause_req                  =>  pause_req,                  
        pause_val                  =>  pause_val,                  

        -- Reference clock for IDELAY    
        refclk                    =>   refclk,                  
                                                                
      -- GMII Interface
        -----------------              
        gmii_txd                    =>  gmii_txd,                    
        gmii_tx_en                  =>  gmii_tx_en,                  
        gmii_tx_er                  =>  gmii_tx_er,                  
        gmii_tx_clk                 =>  gmii_tx_clk,
        gmii_rxd                    =>  gmii_rxd,                    
        gmii_rx_dv                  =>  gmii_rx_dv,                  
        gmii_rx_er                  =>  gmii_rx_er,                  
        gmii_rx_clk                 =>  gmii_rx_clk,                 
        gmii_col                    =>  gmii_col,                    
        gmii_crs                    =>  gmii_crs,                    
        mii_tx_clk                  =>  mii_tx_clk,                 


      -- Initial Unicast Address Value
     -- unicast_address               => unicast_address,


        -- MDIO Interface              
        -----------------              
        mdio_i                     =>  mdio_i,                     
        mdio_o                     =>  mdio_o,                     
        mdio_t                     =>  mdio_t,                     
        mdc                        =>  mdc,                        
                                                                
        -- IPIC Interface               
        -----------------               
        Bus2IP_Clk                 =>  Bus2IP_Clk,                 
        Bus2IP_Reset               =>  bus_rst_i,               
        Bus2IP_Addr                =>  Bus2IP_Addr,                
        Bus2IP_CS                  =>  Bus2IP_CS,                  
        Bus2IP_RdCE                =>  Bus2IP_RdCE,                
        Bus2IP_WrCE                =>  Bus2IP_WrCE,                
        Bus2IP_Data                =>  Bus2IP_Data,                
        IP2Bus_Data                =>  IP2Bus_Data,                
        IP2Bus_WrAck               =>  IP2Bus_WrAck,               
        IP2Bus_RdAck               =>  IP2Bus_RdAck,               
        IP2Bus_Error               =>  IP2Bus_Error,
      
        -- Speed Indicator
        mac_irq                    => mac_irq,
        speed_is_10_100            =>  speed_is_10_100
   );               
  
  end generate GEN_GMII;
  
  -----------------------------------------------------------------------------
  --  MII
  -----------------------------------------------------------------------------
  GEN_MII : if C_PHY_TYPE = 0 generate
  begin
  
    --  Signals used in other AXI Ethernet PHY configurations that need tied off here
    EMACResetDoneInterrupt <= '1';
    EMACCLIENTANINTERRUPT  <= '0';

    I_MII : entity axi_ethernet_v3_01_a.v6_emac_block_mii 
    generic map (
        C_HAS_MII      => C_HAS_MII,      
        C_HAS_GMII     => C_HAS_GMII,     
        C_HAS_RGMII    => C_HAS_RGMII,    
        C_HAS_SGMII    => C_HAS_SGMII,     
        C_HAS_GPCS     => C_HAS_GPCS,     
        C_PHY_WIDTH    => C_PHY_WIDTH,    
        C_HALF_DUPLEX  => C_HALF_DUPLEX,  
        C_HAS_HOST     => C_HAS_HOST,     
        C_ADD_FILTER   => C_ADD_FILTER,   
        C_AT_ENTRIES   => C_AT_ENTRIES,   
        C_FAMILY       => C_FAMILY,       
        C_SPEED_10_100 => C_SPEED_10_100, 
        C_SPEED_1000   => C_SPEED_1000,   
        C_TRI_SPEED    => C_TRI_SPEED,    
        C_HAS_STATS    => C_HAS_STATS,    
        C_NUM_STATS    => C_NUM_STATS,    
        C_CNTR_RST     => C_CNTR_RST,     
        C_STATS_WIDTH  => C_STATS_WIDTH,  
        C_INTERNAL_INT => C_INTERNAL_INT,
        C_INCLUDE_IO   => C_INCLUDE_IO, 
        C_HALFDUP      => C_HALFDUP
     )
  
     port map(
        gtx_clk                    =>  gtx_clk,                    
        -- asynchronous reset          
        glbl_rstn                  =>  bus_rstn,                  
        rx_axi_rstn                =>  '1',   -- tie HIGH per CORE Gen             
        tx_axi_rstn                =>  '1',   -- tie HIGH per CORE Gen              
                                                                
        -- Receiver Interface        
        ---------------------------  
        RX_CLK_ENABLE_OUT          =>  RX_CLK_ENABLE_OUT,
        rx_statistics_vector       =>  rx_statistics_vector,       
        rx_statistics_valid        =>  rx_statistics_valid,        
        rx_axis_filter_tuser       =>  rx_axis_filter_tuser,
                                                                
        rx_mac_aclk                =>  rx_mac_aclk,                
        rx_reset                   =>  rx_reset,                   
        rx_axis_mac_tdata          =>  rx_axis_mac_tdata,          
        rx_axis_mac_tvalid         =>  rx_axis_mac_tvalid,         
        rx_axis_mac_tlast          =>  rx_axis_mac_tlast,          
        rx_axis_mac_tuser          =>  rx_axis_mac_tuser,          
                                     
        -- Transmitter Interface     
        ---------------------------  
        tx_ifg_delay               =>  tx_ifg_delay,               
        tx_statistics_vector       =>  tx_statistics_vector,       
        tx_statistics_valid        =>  tx_statistics_valid,  
        
        -- added for avb connection 03/21/2011     
        tx_avb_en                  =>  tx_avb_en,              
                                                                
        tx_mac_aclk                =>  tx_mac_aclk,                
        tx_reset                   =>  tx_reset,                   
        tx_axis_mac_tdata          =>  tx_axis_mac_tdata,          
        tx_axis_mac_tvalid         =>  tx_axis_mac_tvalid,         
        tx_axis_mac_tlast          =>  tx_axis_mac_tlast,          
        tx_axis_mac_tuser          =>  tx_axis_mac_tuser,          
        tx_axis_mac_tready         =>  tx_axis_mac_tready,         
        tx_collision               =>  tx_collision,               
        tx_retransmit              =>  tx_retransmit,              
                                                                
        -- MAC Control Interface    
        ------------------------    
        pause_req                  =>  pause_req,                  
        pause_val                  =>  pause_val,                  
                                                                
        -- MII Interface               
        -----------------              
        mii_txd                    =>  mii_txd,                    
        mii_tx_en                  =>  mii_tx_en,                  
        mii_tx_er                  =>  mii_tx_er,                  
        mii_rxd                    =>  mii_rxd,                    
        mii_rx_dv                  =>  mii_rx_dv,                  
        mii_rx_er                  =>  mii_rx_er,                  
        mii_rx_clk                 =>  mii_rx_clk,                 
        mii_col                    =>  mii_col,                    
        mii_crs                    =>  mii_crs,                    
        mii_tx_clk                 =>  mii_tx_clk,                 


      -- Initial Unicast Address Value
      --unicast_address              => unicast_address,


        -- MDIO Interface              
        -----------------              
        mdio_i                     =>  mdio_i,                     
        mdio_o                     =>  mdio_o,                     
        mdio_t                     =>  mdio_t,                     
        mdc                        =>  mdc,                        
                                                                
        -- IPIC Interface               
        -----------------               
        Bus2IP_Clk                 =>  Bus2IP_Clk,                 
        Bus2IP_Reset               =>  bus_rst_i,               
        Bus2IP_Addr                =>  Bus2IP_Addr,                
        Bus2IP_CS                  =>  Bus2IP_CS,                  
        Bus2IP_RdCE                =>  Bus2IP_RdCE,                
        Bus2IP_WrCE                =>  Bus2IP_WrCE,                
        Bus2IP_Data                =>  Bus2IP_Data,                
        IP2Bus_Data                =>  IP2Bus_Data,                
        IP2Bus_WrAck               =>  IP2Bus_WrAck,               
        IP2Bus_RdAck               =>  IP2Bus_RdAck,               
        IP2Bus_Error               =>  IP2Bus_Error,
      
        -- Speed Indicator
        mac_irq                    => mac_irq,
        speed_is_10_100            =>  speed_is_10_100
   );               
  
  end generate GEN_MII;
  
  -----------------------------------------------------------------------------  
  --  RGMII                                                                        
  -----------------------------------------------------------------------------
  GEN_RGMII : if C_PHY_TYPE = 3 generate
  begin
  
    --  Signals used in other AXI Ethernet PHY configurations that need tied off here
    EMACResetDoneInterrupt <= '1';
    EMACCLIENTANINTERRUPT  <= '0';  
  
    I_RGMII : entity axi_ethernet_v3_01_a.v6_emac_block_rgmii 
    generic map (
        C_HAS_MII      => C_HAS_MII,      
        C_HAS_GMII     => C_HAS_GMII,     
        C_HAS_RGMII    => C_HAS_RGMII,    
        C_HAS_SGMII    => C_HAS_SGMII,     
        C_HAS_GPCS     => C_HAS_GPCS,     
        C_PHY_WIDTH    => C_PHY_WIDTH,    
        C_HALF_DUPLEX  => C_HALF_DUPLEX,  
        C_HAS_HOST     => C_HAS_HOST,     
        C_ADD_FILTER   => C_ADD_FILTER,   
        C_AT_ENTRIES   => C_AT_ENTRIES,   
        C_FAMILY       => C_FAMILY,       
        C_SPEED_10_100 => C_SPEED_10_100, 
        C_SPEED_1000   => C_SPEED_1000,   
        C_TRI_SPEED    => C_TRI_SPEED,    
        C_HAS_STATS    => C_HAS_STATS,    
        C_NUM_STATS    => C_NUM_STATS,    
        C_CNTR_RST     => C_CNTR_RST,     
        C_STATS_WIDTH  => C_STATS_WIDTH,  
        C_INTERNAL_INT => C_INTERNAL_INT,
        C_INCLUDE_IO   => C_INCLUDE_IO, 
        C_HALFDUP      => C_HALFDUP
     )
  
     port map(
        gtx_clk                    =>  gtx_clk,                    
        -- asynchronous reset          
        glbl_rstn                  =>  bus_rstn,                  
        rx_axi_rstn                =>  '1',   -- tie HIGH per CORE Gen                 
        tx_axi_rstn                =>  '1',   -- tie HIGH per CORE Gen                 
                                                                
        -- Receiver Interface        
        ---------------------------  
        RX_CLK_ENABLE_OUT          =>  RX_CLK_ENABLE_OUT,
        rx_statistics_vector       =>  rx_statistics_vector,       
        rx_statistics_valid        =>  rx_statistics_valid,        
        rx_axis_filter_tuser       =>  rx_axis_filter_tuser,
                                                                
        rx_mac_aclk                =>  rx_mac_aclk,                
        rx_reset                   =>  rx_reset,                   
        rx_axis_mac_tdata          =>  rx_axis_mac_tdata,          
        rx_axis_mac_tvalid         =>  rx_axis_mac_tvalid,         
        rx_axis_mac_tlast          =>  rx_axis_mac_tlast,          
        rx_axis_mac_tuser          =>  rx_axis_mac_tuser,          
                                     
        -- Transmitter Interface     
        ---------------------------  
        tx_ifg_delay               =>  tx_ifg_delay,               
        tx_statistics_vector       =>  tx_statistics_vector,       
        tx_statistics_valid        =>  tx_statistics_valid,        
        
        -- added for avb connection 03/21/2011     
        tx_avb_en                  =>  tx_avb_en,              
                                                                
        tx_mac_aclk                =>  tx_mac_aclk,                
        tx_reset                   =>  tx_reset,                   
        tx_axis_mac_tdata          =>  tx_axis_mac_tdata,          
        tx_axis_mac_tvalid         =>  tx_axis_mac_tvalid,         
        tx_axis_mac_tlast          =>  tx_axis_mac_tlast,         
        tx_axis_mac_tuser          =>  tx_axis_mac_tuser,          
        tx_axis_mac_tready         =>  tx_axis_mac_tready,         
        tx_collision               =>  tx_collision,               
        tx_retransmit              =>  tx_retransmit,              
                                                                
        -- MAC Control Interface    
        --------------------------  
        pause_req                  =>  pause_req,                  
        pause_val                  =>  pause_val,                  
                                                                
        -- Reference clock for IDELAY    
        refclk                    =>   refclk,                  
                                                                          
        -- RGMII Interface                           
        --------------------           --------------------               
        rgmii_txd                 =>   rgmii_txd,                            
        rgmii_tx_ctl              =>   rgmii_tx_ctl,                         
        rgmii_txc                 =>   rgmii_txc,                            
        rgmii_rxd                 =>   rgmii_rxd,                            
        rgmii_rx_ctl              =>   rgmii_rx_ctl,                         
        rgmii_rxc                 =>   rgmii_rxc,                            


      -- Initial Unicast Address Value
      --unicast_address              => unicast_address,


                                                       
        -- MDIO Interface                              
        -------------------                            
        mdio_i                     =>  mdio_i,                              
        mdio_o                     =>  mdio_o,      
        mdio_t                     =>  mdio_t,      
        mdc                        =>  mdc,                  
                                                 
        -- IPIC Interface                        
        -----------------                        
        Bus2IP_Clk                 =>  Bus2IP_Clk,                 
        Bus2IP_Reset               =>  bus_rst_i,               
        Bus2IP_Addr                =>  Bus2IP_Addr,                
        Bus2IP_CS                  =>  Bus2IP_CS,                  
        Bus2IP_RdCE                =>  Bus2IP_RdCE,                
        Bus2IP_WrCE                =>  Bus2IP_WrCE,                
        Bus2IP_Data                =>  Bus2IP_Data,                
        IP2Bus_Data                =>  IP2Bus_Data,  
        IP2Bus_WrAck               =>  IP2Bus_WrAck, 
        IP2Bus_RdAck               =>  IP2Bus_RdAck, 
        IP2Bus_Error               =>  IP2Bus_Error,
      
        -- Speed Indicator
        mac_irq                    => mac_irq,
        speed_is_10_100            => speed_is_10_100
   );                              
   end generate GEN_RGMII;

  -----------------------------------------------------------------------------  
  --  SGMII                                                                 
  -----------------------------------------------------------------------------
  GEN_SGMII: if (C_PHY_TYPE = 4) generate
  
  signal clk125_out               : std_logic;  
  signal gtx_clk_bufg             : std_logic;  
  signal user_mac_aclk            : std_logic;

                                                                      
  attribute keep                  : string;                                
  attribute keep of gtx_clk_bufg  : signal is "true";    
  attribute keep of clk125_out    : signal is "true";  
  
  begin
  

      -- Generate the clock input to the transceiver
      -- (clk_ds can be shared between multiple EMAC instances, including
      --  multiple instantiations of the EMAC wrappers)
      clkingen : IBUFDS_GTXE1 port map (
        I     => MGTCLK_P,
        IB    => MGTCLK_N,
        CEB   => '0',
        O     => clk_ds,
        ODIV2 => open
      );
  
      
   -- The 125MHz clock from the transceiver is routed through a BUFG and
   -- input to the MAC wrappers
   -- (clk125 can be shared between multiple EMAC instances, including
   --  multiple instantiations of the EMAC wrappers)
   bufg_clk125 : BUFG
   port map (
      I                => clk125_out,
      O                => gtx_clk_bufg
   );      
      
    tx_mac_aclk <=  user_mac_aclk;
    rx_mac_aclk <=  user_mac_aclk;  
      
  
    I_SGMII : entity axi_ethernet_v3_01_a.v6_emac_block_sgmii
    generic map (
        C_HAS_MII      => C_HAS_MII,      
        C_HAS_GMII     => C_HAS_GMII,     
        C_HAS_RGMII    => C_HAS_RGMII,    
        C_HAS_SGMII    => C_HAS_SGMII,     
        C_HAS_GPCS     => C_HAS_GPCS,     
        C_PHY_WIDTH    => C_PHY_WIDTH,   
        C_HALF_DUPLEX  => C_HALF_DUPLEX, 
        C_HAS_HOST     => C_HAS_HOST,    
        C_ADD_FILTER   => C_ADD_FILTER,  
        C_AT_ENTRIES   => C_AT_ENTRIES,  
        C_FAMILY       => C_FAMILY,      
        C_SPEED_10_100 => C_SPEED_10_100,
        C_SPEED_1000   => C_SPEED_1000,  
        C_TRI_SPEED    => C_TRI_SPEED,   
        C_HAS_STATS    => C_HAS_STATS,   
        C_NUM_STATS    => C_NUM_STATS,   
        C_CNTR_RST     => C_CNTR_RST,    
        C_STATS_WIDTH  => C_STATS_WIDTH, 
  
        C_INTERNAL_INT => C_INTERNAL_INT,
        C_INCLUDE_IO   => C_INCLUDE_IO, 
        C_HALFDUP      => C_HALFDUP,
        C_TYPE         => C_TYPE,    
        C_PHY_TYPE     => C_PHY_TYPE
     )
  
     port map(
        gtx_clk                    => gtx_clk_bufg,                               
        clk125_out                 => clk125_out,
        -- asynchronous reset                                                
        glbl_rstn                  => bus_rstn,                              
        rx_axi_rstn                => '1',   -- tie HIGH per CORE Gen        
        tx_axi_rstn                => '1',   -- tie HIGH per CORE Gen        
                                                                             
        -- Receiver Interface                                                
        ---------------------------                                          
        RX_CLK_ENABLE_OUT          => RX_CLK_ENABLE_OUT,
        rx_statistics_vector       => rx_statistics_vector,                  
        rx_statistics_valid        => rx_statistics_valid,                   
        rx_axis_filter_tuser       => rx_axis_filter_tuser,
                                      
        user_mac_aclk              => user_mac_aclk,
        rx_reset                   => rx_reset,          
        rx_axis_mac_tdata          => rx_axis_mac_tdata, 
        rx_axis_mac_tvalid         => rx_axis_mac_tvalid,
        rx_axis_mac_tlast          => rx_axis_mac_tlast, 
        rx_axis_mac_tuser          =>  rx_axis_mac_tuser,          
  
        -- Transmitter Interface
        -------------------------------
        tx_ifg_delay               => tx_ifg_delay,              
        tx_statistics_vector       => tx_statistics_vector,  
        tx_statistics_valid        => tx_statistics_valid,   
        
        -- added for avb connection 03/21/2011     
        tx_avb_en                  => tx_avb_en,              
                                                                
        tx_reset                   => tx_reset,      
        tx_axis_mac_tdata          => tx_axis_mac_tdata, 
        tx_axis_mac_tvalid         => tx_axis_mac_tvalid,
        tx_axis_mac_tlast          => tx_axis_mac_tlast, 
        tx_axis_mac_tuser          => tx_axis_mac_tuser, 
        tx_axis_mac_tready         => tx_axis_mac_tready,
        tx_collision               =>  tx_collision,               
        tx_retransmit              =>  tx_retransmit,              
  
        -- MAC Control Interface
        ------------------------
        pause_req                  => pause_req,
        pause_val                  => pause_val,

    -- SGMII interface
      txp                          => txp,
      txn                          => txn,
      rxp                          => rxp,
      rxn                          => rxn,
      phyad                        => C_TEMAC_PHYADDR,
      resetdone                    => EMACResetDoneInterrupt,
      syncacqstatus                => EMACCLIENTANINTERRUPT,
    -- SGMII transceiver clock buffer input
      clk_ds                       => clk_ds,

      -- Initial Unicast Address Value
      --unicast_address              => unicast_address,


        -- MDIO Interface
        -----------------
        mdc                        => mdc,         
        mdio_i                     => mdio_i,      
        mdio_o                     => mdio_o,                 
        mdio_t                     => mdio_t,              
                                                        
        -- IPIC Interface                          
        -----------------          
        Bus2IP_Clk                 => bus2ip_clk,  
        Bus2IP_Reset               => bus2ip_reset,
        Bus2IP_Addr                => bus2ip_addr, 
        Bus2IP_CS                  => bus2ip_cs,   
        Bus2IP_RdCE                => bus2ip_rdce, 
        Bus2IP_WrCE                => bus2ip_wrce, 
        Bus2IP_Data                => bus2ip_data, 
        IP2Bus_Data                => ip2bus_data, 
        IP2Bus_WrAck               => ip2bus_wrack,
        IP2Bus_RdAck               => ip2bus_rdack,
        IP2Bus_Error               => ip2bus_error,
        
        -- Speed Indicator
        mac_irq                    => mac_irq,
        speed_is_10_100            => speed_is_10_100
   );               
   end generate GEN_SGMII;
   
   

  -----------------------------------------------------------------------------  
  --  1000BASE-X
  -----------------------------------------------------------------------------
  GEN_1000BX: if (C_PHY_TYPE = 5) generate  
  
  signal clk125_out               : std_logic;  
  signal gtx_clk_bufg             : std_logic;  
  signal user_mac_aclk            : std_logic;

                                                                      
  attribute keep                  : string;                                
  attribute keep of gtx_clk_bufg  : signal is "true";    
  attribute keep of clk125_out    : signal is "true";     
    
  begin
  

    -- Generate the clock input to the transceiver
    -- (clk_ds can be shared between multiple EMAC instances, including
    --  multiple instantiations of the EMAC wrappers)
    clkingen : IBUFDS_GTXE1 port map (
      I     => MGTCLK_P,
      IB    => MGTCLK_N,
      CEB   => '0',
      O     => clk_ds,
      ODIV2 => open
    );
  
   -- The 125MHz clock from the transceiver is routed through a BUFG and
   -- input to the MAC wrappers
   -- (clk125 can be shared between multiple EMAC instances, including
   --  multiple instantiations of the EMAC wrappers)
    bufg_clk125 : BUFG
    port map (
      I                => clk125_out,
      O                => gtx_clk_bufg
    );      
    
    tx_mac_aclk <=  user_mac_aclk;
    rx_mac_aclk <=  user_mac_aclk;  
       
    I_1000BX : entity axi_ethernet_v3_01_a.v6_emac_block_1000bx
    generic map (
        C_HAS_MII      => C_HAS_MII,      
        C_HAS_GMII     => C_HAS_GMII,     
        C_HAS_RGMII    => C_HAS_RGMII,    
        C_HAS_SGMII    => C_HAS_SGMII,     
        C_HAS_GPCS     => C_HAS_GPCS,     
        C_PHY_WIDTH    => C_PHY_WIDTH,   
        C_HALF_DUPLEX  => C_HALF_DUPLEX, 
        C_HAS_HOST     => C_HAS_HOST,    
        C_ADD_FILTER   => C_ADD_FILTER,  
        C_AT_ENTRIES   => C_AT_ENTRIES,  
        C_FAMILY       => C_FAMILY,      
        C_SPEED_10_100 => C_SPEED_10_100,
        C_SPEED_1000   => C_SPEED_1000,  
        C_TRI_SPEED    => C_TRI_SPEED,   
        C_HAS_STATS    => C_HAS_STATS,   
        C_NUM_STATS    => C_NUM_STATS,   
        C_CNTR_RST     => C_CNTR_RST,    
        C_STATS_WIDTH  => C_STATS_WIDTH, 
  
        C_INTERNAL_INT => C_INTERNAL_INT,
        C_INCLUDE_IO   => C_INCLUDE_IO, 
        C_HALFDUP      => C_HALFDUP,
        C_TYPE         => C_TYPE,    
        C_PHY_TYPE     => C_PHY_TYPE
     )
  
     port map(
        gtx_clk                    => gtx_clk_bufg,                               
        clk125_out                 => clk125_out,

        -- asynchronous reset                                                
        glbl_rstn                  => bus_rstn,                              
        rx_axi_rstn                => '1',   -- tie HIGH per CORE Gen        
        tx_axi_rstn                => '1',   -- tie HIGH per CORE Gen        

        -- Receiver Interface                                                
        ---------------------------                                          
        RX_CLK_ENABLE_OUT          => RX_CLK_ENABLE_OUT,
        rx_statistics_vector       => rx_statistics_vector,                  
        rx_statistics_valid        => rx_statistics_valid,                   
        rx_axis_filter_tuser       => rx_axis_filter_tuser,
      
        user_mac_aclk              => user_mac_aclk,
        rx_reset                   => rx_reset,          
        rx_axis_mac_tdata          => rx_axis_mac_tdata, 
        rx_axis_mac_tvalid         => rx_axis_mac_tvalid,
        rx_axis_mac_tlast          => rx_axis_mac_tlast, 
        rx_axis_mac_tuser          =>  rx_axis_mac_tuser,          

        -- Transmitter Interface
        -------------------------------
        tx_ifg_delay               => tx_ifg_delay,              
        tx_statistics_vector       => tx_statistics_vector,  
        tx_statistics_valid        => tx_statistics_valid,  
        
        -- added for avb connection 03/21/2011     
        tx_avb_en                  => tx_avb_en,              
                                                                
        tx_reset                   => tx_reset,      
        tx_axis_mac_tdata          => tx_axis_mac_tdata, 
        tx_axis_mac_tvalid         => tx_axis_mac_tvalid,
        tx_axis_mac_tlast          => tx_axis_mac_tlast, 
        tx_axis_mac_tuser          => tx_axis_mac_tuser, 
        tx_axis_mac_tready         => tx_axis_mac_tready,
        tx_collision               =>  tx_collision,               
        tx_retransmit              =>  tx_retransmit,              

        -- MAC Control Interface
        ------------------------
        pause_req                  => pause_req,
        pause_val                  => pause_val,

    -- 1000BASE-X PCS/PMA interface
      txp                          => txp,
      txn                          => txn,
      rxp                          => rxp,
      rxn                          => rxn,
      phyad                        => C_TEMAC_PHYADDR,
      resetdone                    => EMACResetDoneInterrupt,
      syncacqstatus                => EMACCLIENTANINTERRUPT,
    -- 1000BASE-X PCS/PMA clock buffer input
      clk_ds                       => clk_ds,

      -- Initial Unicast Address Value
      --unicast_address               => unicast_address,


        -- MDIO Interface
        -----------------
        mdc                        => mdc,         
        mdio_i                     => mdio_i,      
        mdio_o                     => mdio_o,                 
        mdio_t                     => mdio_t,              
                                                        
        -- IPIC Interface                          
        -----------------          
        Bus2IP_Clk                 => bus2ip_clk,  
        Bus2IP_Reset               => bus2ip_reset,
        Bus2IP_Addr                => bus2ip_addr, 
        Bus2IP_CS                  => bus2ip_cs,   
        Bus2IP_RdCE                => bus2ip_rdce, 
        Bus2IP_WrCE                => bus2ip_wrce, 
        Bus2IP_Data                => bus2ip_data, 
        IP2Bus_Data                => ip2bus_data, 
        IP2Bus_WrAck               => ip2bus_wrack,
        IP2Bus_RdAck               => ip2bus_rdack,
        IP2Bus_Error               => ip2bus_error,
        
        -- Speed Indicator
        mac_irq                    => mac_irq,       
        speed_is_10_100            => speed_is_10_100
   );               
   end generate GEN_1000BX;
   

end wrapper;
