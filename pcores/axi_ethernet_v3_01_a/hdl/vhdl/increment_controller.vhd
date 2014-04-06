------------------------------------------------------------------------
-- Title      : Increment Control Register for Statistic Counters
------------------------------------------------------------------------
-- File       : increment_controller.vhd  
-- Author     : Xilinx Inc.
------------------------------------------------------------------------
-- (c) Copyright 1998 - 2011 Xilinx, Inc. All rights reserved.
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
------------------------------------------------------------------------
-- Description: This is the Increment Control Register for a single 
--              Statistic Counter.  
--
--              A toggle on the relevent bit of the increment_vector bus
--              will be detected here.  When a toggle occurs, the 
--              Increment Control Register is set to logic 1.  The 
--              statistics logic will service each counter in round 
--              robin sequence: after the round-robin sequence has 
--              passed, a logic 1 on an Increment Control Register will    
--              have caused the relevent statistic counter to increment: 
--              the increment control register will then reset to
--              logic 0.


library unisim;
use unisim.vcomponents.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

library ieee;
use ieee.std_logic_1164.all;


entity increment_controller is
   port (
      ref_clk              : in std_logic;  -- Reference clock for the main statistic counter logic.
      ref_reset            : in std_logic;  -- Synchronous reset for the ref_clk domain.
      increment_vector     : in std_logic;  -- This bit will be toggled to indicate a statistic increment.
      increment_reset      : in std_logic;  -- This bit will be driven to reset the register in the round robin update sequence.
      increment_control    : out std_logic  -- Will cause a statistic increment on appropriate statistic counter.
   );
end increment_controller;



architecture rtl of increment_controller is

   ---------------------------------------------------------------------
   -- Component: synchroniser block
   ---------------------------------------------------------------------
   component axi_ethernet_v3_01_a_sync_block is
   port (
     clk         : in  std_logic;         
     data_in     : in  std_logic;         
     data_out    : out std_logic          
   );
   end component;



  signal increment_vector_sync     : std_logic;            
  signal increment_vector_sync_reg : std_logic;            


begin


    
   -- Reclock the increment_vector bit twice on ref_clk.
   sync_inc_vector : axi_ethernet_v3_01_a_sync_block
   port map(
     clk         => ref_clk,      
     data_in     => increment_vector,
     data_out    => increment_vector_sync
   );
   
   reclock : process(ref_clk)
   begin
      if (ref_clk'event and ref_clk = '1') then
         if (ref_reset = '1') then
            increment_vector_sync_reg <= '0';
         else
            increment_vector_sync_reg <= increment_vector_sync;
         end if;
      end if;

   end process reclock;



   -- Detect the toggle of increment_vector and indicate a statistic 
   -- update of the appropriate counter.
   detect_toggle : process(ref_clk)
   begin
      if (ref_clk'event and ref_clk = '1') then
         if (ref_reset = '1') then
            increment_control   <= '0';
         else
            if (increment_vector_sync_reg xor increment_vector_sync) = '1' then -- edge detector
               increment_control <= '1';
            elsif increment_reset = '1' then 
               increment_control <= '0';
            end if;
         end if;
      end if;
   end process detect_toggle;



end rtl;
         
         

       
