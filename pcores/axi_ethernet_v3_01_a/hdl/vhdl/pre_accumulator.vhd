------------------------------------------------------------------------
-- Title      : Pre-accumulator for the "Fast" Statistic Counters
------------------------------------------------------------------------
-- File       : pre_accumulator.vhd  
-- Author     : Xilinx Inc.
------------------------------------------------------------------------
-- *************************************************************************
--
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
-- This is based on Coregen Wrappers from ISE O.40d (13.1) plus a patch
-- Wrapper version 2.1
------------------------------------------------------------------------
-- Description: This is the pre-accumulator for the "Fast" statistic
--              counters.
--
--              The statistic block is designed to be able to increment
--              all counters only once per minimum ethernet frame 
--              period.  This is every 73 bytes of an ethernet frame
--              (64 bytes of min frame length + 1 byte of preamble + 8
--              bytes of minimum interframe gap).  This method is OK for
--              most of the statistic counters.  However, we allow 4
--              special counters which can increment more frequently.
--              These are used for:
--
--              * Transmitted bytes
--              * Received bytes
--              * Undersized frame counter
--              * Fragment frame counter
--
--              These are implemented by an 8-bit pre-accumulator.  Only
--              when bit 7 of this accumulator toggles does the main 
--              statistic update occur.  This is every 127 bytes (which
--              exceeds the minimum ethernet frame period).  These lower
--              7 bits become the lower 7 bits of the full 64-bit value
--              and are stored in the parity bits of the block RAMs.
--              The main block RAM statistic implementation therefore
--              stores bits 8 and above for these 4 counters.               

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;


entity pre_accumulator is
   port (

      ------------------------------------------------------------------
      -- Statistic clock domain
      ------------------------------------------------------------------

      stat_clk         : in std_logic;                       -- Clock for the "Fast" Statistic (usually the MAC Tx or Rx clock).
      increment_pulse  : in std_logic;                       -- Increment whenever this is logic '1'.

      ------------------------------------------------------------------
      -- Reference clock domain
      ------------------------------------------------------------------

      ref_clk          : in std_logic;                       -- Reference clock for the main statistic counter logic.
      ref_reset        : in std_logic;                       -- Synchronous reset for the ref_clk domain.
      stat_data        : out std_logic_vector(7 downto 0)    -- 8-bit pre-accumulator output (transfered into ref_clk domain).

   );
end pre_accumulator;



architecture rtl of pre_accumulator is


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

  component SYNC_RESET
    port (
      RESET_IN    : in  std_logic;
      CLK         : in  std_logic;
      RESET_OUT   : out std_logic
      );
  end component;



   signal accumulator        : unsigned(7 downto 0) := (others => '0');         -- 8-bit counter (imcrements when increment_pulse is high on stat_clk)
   signal accumulator_gray   : std_logic_vector(7 downto 0) := (others => '0'); -- accumulator converted into a gray code.
   signal accum_gray_refclk  : std_logic_vector(7 downto 0) := (others => '0'); -- accumulator_gray reclocked into ref_clk domain
   signal local_stats_reset  : std_logic;
   
begin


   SYNC_STATS_RESET: SYNC_RESET
   port map (
      RESET_IN             => ref_reset,
      CLK                  => stat_clk,
      RESET_OUT            => local_stats_reset
   );

   ---------------------------------------------------------------------
   -- Statistic clock domain (stat_clk)
   ---------------------------------------------------------------------


   -- Increment the 8-bit pre-accumulator
   stat_accumulator : process(stat_clk)
   begin
      if (stat_clk'event and stat_clk = '1') then
         if (local_stats_reset = '1') then  
            accumulator <= (others => '0');
         else
            accumulator <= accumulator + ("0000000" & increment_pulse);
         end if;
      end if;
   end process stat_accumulator;



   -- Convert Binary Counter to Gray Code.
   accum_to_gray: process (stat_clk)
   begin
      if stat_clk'event and stat_clk = '1' then
         accumulator_gray(7) <= accumulator(7);
         accumulator_gray(6) <= accumulator(7) xor accumulator(6);
         accumulator_gray(5) <= accumulator(6) xor accumulator(5);
         accumulator_gray(4) <= accumulator(5) xor accumulator(4);
         accumulator_gray(3) <= accumulator(4) xor accumulator(3);
         accumulator_gray(2) <= accumulator(3) xor accumulator(2);
         accumulator_gray(1) <= accumulator(2) xor accumulator(1);
         accumulator_gray(0) <= accumulator(1) xor accumulator(0);
      end if;
   end process accum_to_gray; 



   ---------------------------------------------------------------------
   -- Reference clock domain for the main statistic logic (ref_clk)
   ---------------------------------------------------------------------


   -- Register accumulator_gray on ref_clk.  By reclocking the gray   
   -- code, the worst case senario is that the reclocked value is only  
   -- in error by -1, since only 1 bit at a time changes between each   
   -- gray code increment. 
  accum_gray_resync : for I in 0 to 7 generate
   sync_accum_gray_i : axi_ethernet_v3_01_a_sync_block
   port map(
     clk         => ref_clk,      
     data_in     => accumulator_gray(i),
     data_out    => accum_gray_refclk(i)
   );
   end generate;
   
   
   -- Convert accum_gray_refclk Gray Code value back to binary.  This 
   -- has crossed clock domains from stat_clk to ref_clk. 
   accum_to_binary: process (ref_clk)
   begin
      if ref_clk'event and ref_clk = '1' then
         stat_data(7) <= accum_gray_refclk(7);  

         stat_data(6) <= accum_gray_refclk(7) xor 
                         accum_gray_refclk(6);  

         stat_data(5) <= accum_gray_refclk(7) xor 
                         accum_gray_refclk(6) xor
                         accum_gray_refclk(5);  

         stat_data(4) <= accum_gray_refclk(7) xor 
                         accum_gray_refclk(6) xor
                         accum_gray_refclk(5) xor 
                         accum_gray_refclk(4);  

         stat_data(3) <= accum_gray_refclk(7) xor 
                         accum_gray_refclk(6) xor
                         accum_gray_refclk(5) xor 
                         accum_gray_refclk(4) xor 
                         accum_gray_refclk(3);  

         stat_data(2) <= accum_gray_refclk(7) xor 
                         accum_gray_refclk(6) xor
                         accum_gray_refclk(5) xor 
                         accum_gray_refclk(4) xor 
                         accum_gray_refclk(3) xor  
                         accum_gray_refclk(2);  

         stat_data(1) <= accum_gray_refclk(7) xor 
                         accum_gray_refclk(6) xor
                         accum_gray_refclk(5) xor 
                         accum_gray_refclk(4) xor 
                         accum_gray_refclk(3) xor  
                         accum_gray_refclk(2) xor 
                         accum_gray_refclk(1);  

         stat_data(0) <= accum_gray_refclk(7) xor 
                         accum_gray_refclk(6) xor
                         accum_gray_refclk(5) xor 
                         accum_gray_refclk(4) xor 
                         accum_gray_refclk(3) xor  
                         accum_gray_refclk(2) xor 
                         accum_gray_refclk(1) xor 
                         accum_gray_refclk(0);  

      end if;
   end process accum_to_binary;

      

end rtl;
         
         

       
