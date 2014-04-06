-------------------------------------------------------------------------------
-- $Revision: 1.1 $ $Date: 2010/07/13 10:53:36 $
-------------------------------------------------------------------------------
-- Title      : Top level for the Ethernet Statistics core.
-- Project    : Ethernet Statistics core
-------------------------------------------------------------------------------
-- File       : ethernet_statistics_gen.vhd
-- Author     : Xilinx
-------------------------------------------------------------------------------
-- (c) Copyright 2005-2008 Xilinx, Inc. All rights reserved.
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
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ethernet_statistics_gen is
   generic (
            C_FAMILY      : string  := "virtex4"; -- Specified architecture
            C_NUM_STATS   : integer := 42;
            C_STATS_WIDTH : integer := 64;
            C_CNTR_RST    : boolean := true;
            RESET_VALUE   : unsigned := "00000000000000000000000000000000"
            );

   port (
      ref_clk            : in std_logic;
      ref_reset          : in std_logic;

      ------------------------------------------------------------------
      -- IPIC interface 
      ------------------------------------------------------------------
      bus2ip_clk         : in std_logic;     
      bus2ip_reset       : in std_logic;     
  
      bus2ip_ce          : in std_logic;      
      bus2ip_rdce        : in std_logic;     
      bus2ip_wrce        : in std_logic;    
      ip2bus_wrack       : out std_logic;   
      ip2bus_rdack       : out std_logic; 
  
      bus2ip_addr        : in std_logic_vector(10 downto 0);       
      bus2ip_data        : in std_logic_vector(31 downto 0);       
      ip2bus_data        : out std_logic_vector(31 downto 0);     
      ip2bus_error       : out std_logic; 
      
      ------------------------------------------------------------------
      -- "Fast" Statistic Increment signals
      ------------------------------------------------------------------

      -- MAC Transmitter Inputs
      tx_clk             : in std_logic;  -- MAC transmitter clock
      tx_reset           : in std_logic;  -- Synchronous reset
      tx_byte            : in std_logic;  -- Count transmitted bytes

      -- MAC Receiver Inputs
      rx_clk             : in std_logic;  -- MAC receiver clock
      rx_reset           : in std_logic;  -- Synchronous reset
      rx_byte            : in std_logic;  -- Count received bytes 
      rx_small           : in std_logic;  -- Count undersized frames
      rx_frag            : in std_logic;  -- Count fragment frames

      ------------------------------------------------------------------
      -- General Statistic Increment signals
      ------------------------------------------------------------------

      -- A toggle on each bit of this vector will trigger an increment 
      -- the relevent statistic counter.

      increment_vector   : in std_logic_vector(4 to C_NUM_STATS-1)

    );


end ethernet_statistics_gen;



architecture rtl of ethernet_statistics_gen is

   component statistics_core
   generic (
      C_NUM_STATS    : in integer := 42;
      C_CNTR_RST     : in boolean  := true;
      C_STATS_WIDTH  : in integer := 64);

   port (
      ref_clk            : in std_logic;
      ref_reset          : in std_logic;

      bus2ip_clk         : in std_logic;     
      bus2ip_reset       : in std_logic;     
      bus2ip_ce          : in std_logic;      
      bus2ip_rdce        : in std_logic;     
      bus2ip_wrce        : in std_logic;    
      ip2bus_wrack       : out std_logic;   
      ip2bus_rdack       : out std_logic; 
      bus2ip_addr        : in std_logic_vector(10 downto 0);       
      bus2ip_data        : in std_logic_vector(31 downto 0);       
      ip2bus_data        : out std_logic_vector(31 downto 0);     
      ip2bus_error       : out std_logic; 
      
      tx_clk             : in std_logic; 
      tx_reset           : in std_logic; 
      tx_byte            : in std_logic; 
      rx_clk             : in std_logic; 
      rx_reset           : in std_logic; 
      rx_byte            : in std_logic; 
      rx_small           : in std_logic; 
      rx_frag            : in std_logic; 
      increment_vector   : in std_logic_vector(4 to C_NUM_STATS-1)
   );
   end component;


begin



   arch : statistics_core
   generic map (
     C_NUM_STATS        => C_NUM_STATS,
     C_CNTR_RST         => C_CNTR_RST,
     C_STATS_WIDTH      => C_STATS_WIDTH)
   port map (
     ref_clk            => ref_clk,  
     ref_reset          => ref_reset,

     bus2ip_clk         => bus2ip_clk,
     bus2ip_reset       => bus2ip_reset,
  
     bus2ip_ce          => bus2ip_ce,
     bus2ip_rdce        => bus2ip_rdce,
     bus2ip_wrce        => bus2ip_wrce,
     ip2bus_wrack       => ip2bus_wrack,
     ip2bus_rdack       => ip2bus_rdack,
  
     bus2ip_addr        => bus2ip_addr,
     bus2ip_data        => bus2ip_data,
     ip2bus_data        => ip2bus_data,
     ip2bus_error       => ip2bus_error,
      
     tx_clk             => tx_clk,  
     tx_reset           => tx_reset,
     tx_byte            => tx_byte, 
     rx_clk             => rx_clk,  
     rx_reset           => rx_reset,
     rx_byte            => rx_byte, 
     rx_small           => rx_small,
     rx_frag            => rx_frag, 
     increment_vector   => increment_vector
     );





end rtl;
