------------------------------------------------------------------------
-- Title      : 64-bit Statistic Counter block RAM based implementation
------------------------------------------------------------------------
-- File       : statistics_core.vhd  
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
-- Description: 
--
-- This file implements the statisitics block using lut6 based Distributed
-- RAM. 
--
-- Port A is used for the read-increment-write process of the "round-
-- robin" sequence which cycles through each statistic counter in
-- turn and increments each statistic when required.

-- Port B is primarily reserved for a 64-bit read via the Management
-- Interface.  Additionally, Port B is also used to cycle through the
-- statistics in turn by writing zero's after the statistic counter 
-- zero (or counter reset) function has been requested. 

-- Please read comments in line for further explanation!!!
--
-- The new memory map provides a separate address for each 32 bit value
-- when the lower 32 bit value is read the upper is sampled and output when the upper
-- 32 bit location is read.  NOTE: if the upper 32 bits are read without first reading the
-- associated lower 32 bits it will NOT return the correct value.
-- The stats will respond to address range 0x200-0x3FC - outwith this range it will
-- IGNORE accesses (is this the correct thing to do?)



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

--library work;
--use work.ETHERNET_STATISTICS_PACK.all;
--use work.COMMON_PACK.all;

entity statistics_core is
   generic (
      C_NUM_STATS        : in integer := 42;
      C_CNTR_RST         : in boolean := true;     
      C_STATS_WIDTH      : in integer := 64);

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
end statistics_core;



architecture rtl of statistics_core is

 component axi_ethernet_v3_01_a_sync_block is
   port (
     clk         : in  std_logic;         
     data_in     : in  std_logic;         
     data_out    : out std_logic          
   );
   end component;
   ---------------------------------------------------------------------
   -- Signals for the 4 "fast" statistic counters
   ---------------------------------------------------------------------

   -- ref-clk domain
   signal tx_byte_accum         : std_logic_vector(7 downto 0);          -- Transmitted bytes pre-accumulator.
   signal rx_byte_accum         : std_logic_vector(7 downto 0);          -- Received bytes pre-accumulator.
   signal rx_small_accum        : std_logic_vector(7 downto 0);          -- Undersized frame pre-accumulator.
   signal rx_frag_accum         : std_logic_vector(7 downto 0);          -- Fragment frame pre-accumulator.

   signal fast_increment_vector : std_logic_vector(0 to 3);              -- Increment vector for the "fast" statistic counters.
   signal dipa                  : std_logic_vector(7 downto 0);          -- pre-accumulators are written into block RAM port A parity bits for storage.



   ---------------------------------------------------------------------
   -- Signals for Block RAM port A read-increment-write pipeline
   ---------------------------------------------------------------------

   -- ref-clk domain
   signal count_read            : unsigned(6 downto 0);                  -- Block RAM port A read counter.  used as master control for the read-increment-write pipeline. 
   signal next_count_read       : unsigned(6 downto 1);                  -- Block RAM port A read counter.  used as master control for the read-increment-write pipeline. 
   signal count_read_srl16      : std_logic_vector(6 downto 0);          -- count_read delayed by 4 clock cycles in SRL16's.
   signal count_write           : std_logic_vector(6 downto 0);          -- write_count is count_read delayed by 5 clock cycles.
   signal addra                 : std_logic_vector(8 downto 0);          -- Block RAM port A address (alternates between count_read and write_count). 
   signal wea                   : std_logic;                             -- Block RAM port A write enable (logic 1 when write_count muxed onto addra). 
   signal doa                   : std_logic_vector(63 downto 0);         -- data read out of port A of Block RAM. 
   signal doa_sample            : std_logic_vector(63 downto 0);         -- doa is sampled and held stable for the accumulators.  
   signal accum_lower           : unsigned(32 downto 0);                 -- Output of accumulator for lower 32 bits of the 64-bit statistic value.
   signal accum_upper           : unsigned(31 downto 0);                 -- Output of accumulator for upper 32 bits of the 64-bit statistic value. 
   signal dia                   : std_logic_vector(63 downto 0);         -- the updated 64-bit statistic, valid when wea is logic 1, to be stored. 

   signal done                  : std_logic;                             -- "done" asserted when count_read reaches maximum value.
   signal round_robin_sequence  : std_logic_vector(0 to C_NUM_STATS-13); -- cycle through the statistics in turn, incrementing them if required. 
   signal inc_reg2              : std_logic;                             -- "inc" delayed by 2 clock cycle. 
   signal inc_reg3              : std_logic;                             -- "inc" delayed by 3 clock cycle. 
   signal increment_reset       : std_logic_vector(0 to C_NUM_STATS-13); -- Reset signals for each statistic following round-robin update.
   signal increment_control     : std_logic_vector(0 to C_NUM_STATS-1);  -- Each bit holds a 1 if waiting for an increment of that statistic.



   ---------------------------------------------------------------------
   -- Signals for the statistics read via Managament Interface
   ---------------------------------------------------------------------

   -- bus2ip_clk domain
   signal bus2ip_cs_reg         : std_logic;                             -- registered ipic chip select
   signal bus2ip_cs_int         : std_logic;                             -- first level decode
   signal capture_address       : std_logic_vector(5 downto 0);          -- captured access address
   signal return_high_word      : std_logic;                             -- return pre-captured data
   signal return_error          : std_logic;                             -- return error if high address not correctly matched to last low addr
   signal request_toggle        : std_logic;                             -- Toggle this signal for every management read request.
   signal response_tog_sync     : std_logic;                             -- register response in bus2ip_clk domain. 
   signal response_reg          : std_logic;                             -- response delayed by 1 clock cycle. 

   -- ref-clk domain
   signal request_tog_sync      : std_logic;                             -- register request_toggle in ref_clk domain. 
   signal request_reg           : std_logic;                             -- request delayed by 1 clock cycle. 
   signal request_reg2          : std_logic;                             -- request delayed by 2 clock cycles.  
   signal addrb                 : std_logic_vector(5 downto 0);          -- Block RAM port B address.  
   signal enb                   : std_logic;                             -- Set to high when a read occurs.
   signal enb_loc                   : std_logic;                             -- Set to high when a read occurs.
   signal enb_loc1                   : std_logic;                             -- Set to high when a read occurs.
   signal enb_loc2                   : std_logic;                             -- Set to high when a read occurs.
   signal enb_reg                   : std_logic;                             -- Set to high when a read occurs.
   signal enb_reg1                   : std_logic;                             -- Set to high when a read occurs.
   signal count_read_neg                   : std_logic;                             -- Set to high when a read occurs.
   signal dob                   : std_logic_vector(63 downto 0);         -- data read out of port B of Block RAM.
   signal dopb                  : std_logic_vector(7 downto 0);          -- data read out of port B of Block RAM (parity bits).
   signal rd_data_ref           : std_logic_vector(71 downto 0);         -- captured data read out of port B
   signal response_toggle       : std_logic;                             -- toggle this signal after data captured


   ---------------------------------------------------------------------
   -- Signals used to reset all statistic counters to zero
   ---------------------------------------------------------------------

   -- ref-clk domain

   signal counter_reset         : std_logic_vector(0 to C_NUM_STATS-1); 
   signal clear_read_pipe       : std_logic;
   signal clear_read_next       : std_logic;
   signal ipic_rd_clear         : std_logic;
   
   -- this function will calculate the required width of inc_reg assuming we split the terms into blocks of 3
   -- the mod function will return 0,1 or 2 (the remainder after dividing by 3)
   -- the function therefore has to add one to the initial value if this is non zero
   -- to soak up the remainder registers
   function num_stats_mod3 (num_stats : integer) return integer is
      variable mod_value : integer;
   begin
      mod_value := ((num_stats-18) - ((num_stats-18) mod 3)) /3;
      if (((num_stats-18) mod 3) /= 0) then
         mod_value := mod_value + 1;
      end if;
      return mod_value;
   end num_stats_mod3;

   constant reg_width            : integer := num_stats_mod3(C_NUM_STATS);
   
   -- declare inc arithmetic pipelining
   signal inc_fast               : std_logic;
   signal inc_tx_bin             : std_logic;
   signal inc_rx_bin             : std_logic;
   signal inc_other              : std_logic_vector(reg_width-1 downto 0);
   signal inc_reg                : std_logic_vector(2 downto 0);
   signal wepa                   : std_logic;
   signal local_ref_reset        : std_logic;

begin



   ---------------------------------------------------------------------
   -- Instantiate Virtex-II Block RAMs to store the statistic values
   ---------------------------------------------------------------------


   -- The address and Control signals of these 2 Block RAMs are wired up
   -- identically.  The lower 32 bits of the statistic values are stored
   -- in the 1st block RAM; the upper 32 bits are stored in the 2nd.
   -- Full 64-bit read and writes therefore occur.
   
   -- Port A is used for the read-increment-write process of the "round-
   -- robin" sequence which cycles through each statistic counter in
   -- turn.

   -- Port B is primarily reserved for a 64-bit read via the Management
   -- Interface.  Additionally, Port B is also used to cycle through the
   -- statistics in turn by writing zero's after the statistic counter 
   -- zero (or counter reset) function has been requested. 


   gen_distributed_mem:    
   for i in (C_STATS_WIDTH-1) downto 0 generate
     RAM64X1D_inst : RAM64X1D
       port map 
       (
         DPO   => dob(i), 
         SPO   => doa(i), 
         A0    => addra(0),
         A1    => addra(1),
         A2    => addra(2),
         A3    => addra(3),
         A4    => addra(4),
         A5    => addra(5),
         D     => dia(i), 
         DPRA0 => addrb(0), 
         DPRA1 => addrb(1), 
         DPRA2 => addrb(2), 
         DPRA3 => addrb(3), 
         DPRA4 => addrb(4), 
         DPRA5 => addrb(5), 
         WCLK  => ref_clk,
         WE    => wea
       );
   end generate;


   zero_unused_bits: if (C_STATS_WIDTH < 64) generate
     doa(63 downto (C_STATS_WIDTH)) <= (others => '0');
     dob(63 downto (C_STATS_WIDTH)) <= (others => '0');
   end generate;


   gen_distributed_parity:    
   for i in 7 downto 0 generate
     RAM64X1D_inst : RAM64X1D
       generic map (
         INIT  => X"0000000000000000"
       )
       port map 
       (
         DPO   => dopb(i), 
         SPO   => open, 
         A0    => addra(0),
         A1    => addra(1),
         A2    => addra(2),
         A3    => addra(3),
         A4    => addra(4),
         A5    => addra(5),
         D     => dipa(i), 
         DPRA0 => addrb(0), 
         DPRA1 => addrb(1), 
         DPRA2 => addrb(2), 
         DPRA3 => addrb(3), 
         DPRA4 => addrb(4), 
         DPRA5 => addrb(5), 
         WCLK  => ref_clk,
         WE    => wepa
       );
   end generate;


   accum_reset_gen : if (C_CNTR_RST) generate
      -- if counter reset is enabled then we want to reset the accumulator each time
      -- a reset is hit
      local_ref_reset <= ref_reset;
   end generate;
   
   not_accum_reset_gen : if (not C_CNTR_RST) generate
      -- if no counter reset then the accumulators should be left alone
      -- they are still initialised to 0.
      -- may still get a discrepancy if there is a reset during a frame
      --- but that cannot be helped..
      local_ref_reset <= '0';
   end generate;

   ---------------------------------------------------------------------
   -- Instantiate the Received Bytes pre-accumulator
   ---------------------------------------------------------------------

   rx_byte_counter : entity axi_ethernet_v3_01_a.pre_accumulator
   port map (
      ref_clk          => ref_clk  ,
      ref_reset        => local_ref_reset,
      stat_clk         => rx_clk,
      increment_pulse  => rx_byte,
      stat_data        => rx_byte_accum
   );


   -- Request an increment whenever bit 7 of the accumulator toggles
   fast_increment_vector(0) <= rx_byte_accum(7);


   ---------------------------------------------------------------------
   -- Instantiate the Transmitter Bytes pre-accumulator
   ---------------------------------------------------------------------

   tx_byte_counter : entity axi_ethernet_v3_01_a.pre_accumulator
   port map (
      ref_clk          => ref_clk,
      ref_reset        => local_ref_reset,
      stat_clk         => tx_clk,
      increment_pulse  => tx_byte,
      stat_data        => tx_byte_accum
   );


   -- Request an increment whenever bit 7 of the accumulator toggles
   fast_increment_vector(1) <= tx_byte_accum(7);




   ---------------------------------------------------------------------
   -- Instantiate the Undersized Frame pre-accumulator
   ---------------------------------------------------------------------

   rx_undersized_counter : entity axi_ethernet_v3_01_a.pre_accumulator
   port map (
      ref_clk          => ref_clk  ,
      ref_reset        => local_ref_reset,
      stat_clk         => rx_clk,
      increment_pulse  => rx_small,
      stat_data        => rx_small_accum
   );


   -- Request an increment whenever bit 7 of the accumulator toggles
   fast_increment_vector(2) <= rx_small_accum(7);



   ---------------------------------------------------------------------
   -- Instantiate the Fragment Frame pre-accumulator
   ---------------------------------------------------------------------

   rx_fragment_counter : entity axi_ethernet_v3_01_a.pre_accumulator
   port map (
      ref_clk          => ref_clk,
      ref_reset        => local_ref_reset,
      stat_clk         => rx_clk,
      increment_pulse  => rx_frag,
      stat_data        => rx_frag_accum
   );


   -- Request an increment whenever bit 7 of the accumulator toggles
   fast_increment_vector(3) <= rx_frag_accum(7);



   ---------------------------------------------------------------------
   -- Store the lower 7-bits of the "fast" statistic pre-accumulators in
   -- the block RAMs.
   ---------------------------------------------------------------------


   -- The 2 Block RAMs used in this implementation gives us a total of 8
   -- parity bits.  The lower 7 parity bits are used to store the lower
   -- 7 bits of the "fast" statistic counter pre-accumulator bits.  The
   -- upper parity bit is written as logic 1 whenever a pre-accumulator
   -- value is stored for the "fast" statistics.  This indicates to the
   -- Management read logic that a shift is required to reassemble the 
   -- complete "fast" counter value out of the upper bits (stored in the
   -- block RAM normal data field) and the pre-accumulators (stored in
   -- the parity bits).

   store_pre_accumulators : process(ref_clk)
   begin
	  if (ref_clk'event and ref_clk = '1') then
            -- Store the appropriate pre-accumulator value at the 
            -- appropriate point in the round-robin pipeline.
            if count_read(0) = '1' and (round_robin_sequence(1) = '1' or round_robin_sequence(2) = '1' or 
               round_robin_sequence(3) = '1' or round_robin_sequence(4) = '1') then
               wepa <= '1';
            else
               wepa <= '0';
            end if;

            if round_robin_sequence(1) = '1' then
               dipa <= '1' & rx_byte_accum(6 downto 0);
            elsif round_robin_sequence(2) = '1' then
               dipa <= '1' & tx_byte_accum(6 downto 0);
            elsif round_robin_sequence(3) = '1' then
               dipa <= '1' & rx_small_accum(6 downto 0);
            else --round_robin_sequence(4) = '1' then
               dipa <= '1' & rx_frag_accum(6 downto 0);
            end if;
	  end if;
   end process store_pre_accumulators;



   ---------------------------------------------------------------------
   -- Create a shift register to indicate the round-robin sequence
   ---------------------------------------------------------------------
   
   -- A logic 1 is passed through this shift register to indicate 
   -- where we are in the pipeline.

   --   * round_robin_sequence(0 to 3) corresponds to the 4 "fast" 
   --     counters.

   --   * round_robin_sequence(4) corresponds to the 1st group of
   --     counters reserved for frame size bins (Statistics 4 to 10),
   --     only 1 of which will updated per round-robin sequence.

   --   * round_robin_sequence(5) corresponds to the 2nd group of
   --     counters reserved for frame size bins (Statistics 11 to 17),
   --     only 1 of which will updated per round-robin sequence.

   --   * round_robin_sequence(6) and upwards corresponds to the  
   --     remainder of the statistic counters starting at counter 18.

   gen_round_robin_sequence : process(ref_clk)
   begin
      if (ref_clk'event and ref_clk = '1') then
         if (ref_reset = '1') then
            round_robin_sequence(1 to C_NUM_STATS-13) <= (others => '0');
            round_robin_sequence(0) <= '1';
         else
            -- The round-robin shift register is synchronised to count_read  
            -- once per cycle.  This is the counter used to generate the  
            -- block RAM ADDRA (port A address logic).
            if (done = '1') then
               round_robin_sequence(1 to C_NUM_STATS-13) <=(others => '0');
               round_robin_sequence(0) <= '1';

            -- Round-robin shift for every 2 increments of	count_read.
            elsif (count_read(0) = '1') then
               round_robin_sequence(1 to C_NUM_STATS-13) 
                              <= round_robin_sequence(0 to C_NUM_STATS-14);

               round_robin_sequence(0) <= '0';
            end if;
         end if;
      end if;
   end process gen_round_robin_sequence;

   

   ---------------------------------------------------------------------
   -- Create the Increment Control Vector
   ---------------------------------------------------------------------

   -- An "increment_control" bit is created for every statistic in turn.
   -- When a bit is logic 1, the corresponding statistic counter will be
   -- incremented when the round-robin sequence next passes that 
   -- counter.

   -- The "increment_control" bit will be reset following this requested
   -- increment.
   
                                                 
      ------------------------------------------------------------------
      -- The 1st four Statistic Counters are reserved for the 4 "fast"
      -- statistics (byte counters, undersized and fragment frames).
      -- These can increment more frequently than 1 round robin pass.             
      ------------------------------------------------------------------


      -- Reset the increment_control[0:3] registers in turn at the   
      -- correct stage in the round-robin pipeline. 
      increment_reset(0) <= round_robin_sequence(C_NUM_STATS-13) 
                            and (count_read(0));

      fast_stat_increment_reset : for i in 1 to 3 generate
         increment_reset(i) <= round_robin_sequence(i-1) 
                               and (count_read(0));
      end generate fast_stat_increment_reset;


      -- Create the increment_control[0:3] registers. 
      fast_statistic_control : for i in 0 to 3 generate
         fast_statistics : entity axi_ethernet_v3_01_a.increment_controller
            port map (
               ref_clk           => ref_clk,
               ref_reset         => ref_reset,
               increment_vector  => fast_increment_vector(i),
               increment_reset   => increment_reset(i),
               increment_control => increment_control(i)
            );
      end generate fast_statistic_control;



      ------------------------------------------------------------------
      -- Statistic Counters 4 to 10 are reserved for the 1st of the
      -- group of counters reserved for frame size bins.  Only 1 of 
      -- these counters can be incremented in 1 round-robin pass.              
      ------------------------------------------------------------------


      -- Reset the increment_control[4:10] registers at the correct   
      -- stage in the round-robin pipeline.  Since only 1 of these 
      -- counters can increment per round-robin period, these are all
      -- reset together.             
      increment_reset(4) <= round_robin_sequence(3) and (count_read(0));


      -- Create the increment_control[4:10] registers. 
      frame_size_bin_control1 : for i in 4 to 10 generate
         frame_size_stats1 : entity axi_ethernet_v3_01_a.increment_controller
            port map (
               ref_clk           => ref_clk,
               ref_reset         => ref_reset,
               increment_vector  => increment_vector(i),
               increment_reset   => increment_reset(4),
               increment_control => increment_control(i)
            );
      end generate frame_size_bin_control1;




      ------------------------------------------------------------------
      -- Statistic Counters 11 to 17 are reserved for the 2nd of the
      -- group of counters reserved for frame size bins.  Only 1 of 
      -- these counters can be incremented in 1 round-robin pass.              
      ------------------------------------------------------------------


      -- Reset the increment_control[11:17] registers at the correct   
      -- stage in the round-robin pipeline.  Since only 1 of these 
      -- counters can increment per round-robin period, these are all
      -- reset together.             
      increment_reset(5) <= round_robin_sequence(4) and (count_read(0));


      -- Create the increment_control[11:17] registers. 
      frame_size_bin_control2 : for i in 11 to 17 generate
         frame_size_stats2 : entity axi_ethernet_v3_01_a.increment_controller
            port map (
               ref_clk           => ref_clk,
               ref_reset         => ref_reset,
               increment_vector  => increment_vector(i),
               increment_reset   => increment_reset(5),
               increment_control => increment_control(i)
            );
      end generate frame_size_bin_control2;



      ------------------------------------------------------------------
      -- Statistic Counters 18 and upwards are general purpose statistic
      -- counters: these can all be incremented once per round-robin 
      -- pass.              
      ------------------------------------------------------------------


      general_statisic_control : for i in 18 to C_NUM_STATS-1 generate

        -- Reset the increment_control[12:upwards] registers in turn at    
        -- the correct stage in the round-robin pipeline. 
        increment_reset(i-12) <= round_robin_sequence(i-13) 
                                 and (count_read(0));
         

        -- Create the increment_control[12:upwards] registers. 
        general_statisics : entity axi_ethernet_v3_01_a.increment_controller
           port map (
              ref_clk           => ref_clk,
              ref_reset         => ref_reset,
              increment_vector  => increment_vector(i),
              increment_reset   => increment_reset(i-12),
              increment_control => increment_control(i)
           );
      end generate general_statisic_control;


   
   
   ---------------------------------------------------------------------
   -- Create Increment Pulse
   ---------------------------------------------------------------------
   
   -- increment_control[0:C_NUM_STATS-1] indicates whether a particular
   -- statistic counter requires incrementing.  If so, an increment
   -- pulse "inc" is asserted by ANDing the particular increment_control
   -- bit with the appropriate round-robin increment_reset pulse.  In 
   -- this way increment_control is reset immediately after the 
   -- increment decision.  "inc" is registered 3 times to compensate for  
   -- the pipeline of the block RAM read control.
   -- We have up to 116 terms feeding into this process (worst case of 64 counters)
   -- This block is specific for 6 lut families so a 2 stage process can combine up to 36 terms? (using 7 lut)
   -- suggests the whole comparator should use three logic levels and ~20 lut.
   -- split the logic to no more than 12 terms (max of two levels and 3 lut)

      -- single lut to flop
      inc_fast_gen : process(ref_clk)
      begin
         if (ref_clk'event and ref_clk = '1') then
            -- fast increment vectors
            inc_fast  <= (increment_control(0) and increment_reset(0)) or
                         (increment_control(1) and increment_reset(1)) or
                         (increment_control(2) and increment_reset(2)) or
                         (increment_control(3) and increment_reset(3)); 
         end if;
      end process;
       
      -- combine 10 terms - 3 luts
      inc_tx_bin_gen : process(ref_clk)
      begin
         if (ref_clk'event and ref_clk = '1') then
            -- bits 4-10 are frame size bins and only one will be incremented at a time
            inc_tx_bin <= ((increment_control(4) or
                            increment_control(5) or
                            increment_control(6) or
                            increment_control(7) or
                            increment_control(8) or
                            increment_control(9) or
                            increment_control(10)) and increment_reset(4));  
         end if;
      end process;

      -- combine 8 terms - 3 luts
      inc_rx_bin_gen : process(ref_clk)
      begin
         if (ref_clk'event and ref_clk = '1') then
            -- bits 11-17 are frame size bins and only one will be incremented at a time
            inc_rx_bin <= (increment_control(11) or
                           increment_control(12) or
                           increment_control(13) or
                           increment_control(14) or
                           increment_control(15) or
                           increment_control(16) or
                           increment_control(17)) and increment_reset(5);  
         end if;
      end process;

      -- chop the final bits into blocks of 6?  worst case of 64 counters would give
      -- 16 blocks -can we use generates?
      -- one lut/flop per loop
      gen_loop : for i in 0 to (reg_width-2) generate
         inc_other_gen : process(ref_clk)
         begin
            if (ref_clk'event and ref_clk = '1') then
               -- all remaining bits have a dedicated reset bit
               inc_other(i) <= (increment_control(i*3+18) and increment_reset(i*3+6)) or
                               (increment_control(i*3+19) and increment_reset(i*3+7)) or
                               (increment_control(i*3+20) and increment_reset(i*3+8));
            end if;
         end process;
      end generate gen_loop;
      
      -- have to combine final bits manually..
      -- just repeat last bits - probably stripped out but minimal effect on size/timing
      -- need to do 3 bits as above generate doesn't do the last iteration
      -- one lut/flop
      inc_other1_gen : process(ref_clk)
      begin
         if (ref_clk'event and ref_clk = '1') then
            -- all remaining bits have a dedicated reset bit
            inc_other(reg_width-1) <= (increment_control(C_NUM_STATS-3) and increment_reset(C_NUM_STATS-15)) or
                                       (increment_control(C_NUM_STATS-2) and increment_reset(C_NUM_STATS-14)) or 
                                       (increment_control(C_NUM_STATS-1) and increment_reset(C_NUM_STATS-13));
         end if;
      end process;
      
      -- 3 bit combination : bit 0 has 3 terms (1 slice/flop)
      -- bits 1 and 2 have from 3 to 8 terms (3 slice/1 flop)
      inc_reg_gen : process(ref_clk)
         variable a, b : std_logic;
      begin
         if (ref_clk'event and ref_clk = '1') then
            a := '0';
            b := '0';
            -- bit 0
            for i in 0 to (reg_width/2)-1 loop
               a := a or inc_other(i);
            end loop;
            -- bit 1
            for i in reg_width/2 to reg_width-1 loop
               b := b or inc_other(i);
            end loop;
            inc_reg  <= b & a & (inc_fast or inc_tx_bin or inc_rx_bin);
         end if;
      end process;
      -- want generate above to round down - then have to combine final bits manually..
      
      

      -- now recombine the registers above over the next three stages (they're there
      -- so we may as well use them.)
      inc_gen : process(ref_clk)
      begin
         if (ref_clk'event and ref_clk = '1') then
            inc_reg2 <= inc_reg(0) or inc_reg(1) or inc_reg(2);
            inc_reg3 <= inc_reg2;
         end if;
      end process;

   ---------------------------------------------------------------------
   -- block RAM port A read counter creation
   ---------------------------------------------------------------------
   


   -- "done" signals to indicate end of statistic set update.  The 
   -- maximum counter value is dependent on the number of statisitic 
   -- counters present.
   done_gen : process(ref_clk)
   begin
      if (ref_clk'event and ref_clk = '1') then
         if (ref_reset = '1') then
            done <= '0';
         else
            if (to_integer(count_read) = ((C_NUM_STATS*2)-2)) then
               done <= '1';
            else
               done <= '0';
            end if;
         end if;
      end if;
   end process done_gen;


   -- Create the read addres "counter".  This is the master control for 
   -- the round-robin sequence.  The round_robin_sequence shift register
   -- is effectively slaved to this counter since "done" is asserted 
   -- from a comparator of this counters value.

   -- The counter is discontinuous - it must jump to the correct
   -- statistic counter number for the frame size bins since only one
   -- statistic from each frame counter bin will be increment per round
   -- robin sequence.

   -- NOTE: two values of the counter are used per statistic 
   -- (count_read(0) is logic 0 and then logic 1).  This allows time to
   -- multiplex between a read and a write of Port A of the block RAM on 
   -- consecutive clock cycles.

   read_counter : process(ref_clk)
   begin
      if (ref_clk'event and ref_clk = '1') then
         if (ref_reset = '1') then
            count_read <= (others => '0');
         else

            -- reset counter at the end of the sequence
            if (done = '1') then
               count_read <= (others => '0');
            else
               -- the least significant bit cinstantly toggles
               count_read(0) <= not count_read(0);

               if count_read(0) = '1' then  

                  -- 1st frame size bin decision point.  Jump to the 
                  -- appropriate statistic counter address   
                  -- check each bit separately as  only one should be set and
                  -- this should give faster logic than the full case logic equivalent                 
                  if round_robin_sequence(3) = '1' then
                     if increment_control(4) = '1' then
                        count_read(6 downto 1) <= "000100";
                     elsif increment_control(5) = '1' then
                        count_read(6 downto 1) <= "000101";
                     elsif increment_control(6) = '1' then
                        count_read(6 downto 1) <= "000110";
                     elsif increment_control(7) = '1' then
                        count_read(6 downto 1) <= "000111";
                     elsif increment_control(8) = '1' then
                        count_read(6 downto 1) <= "001000";
                     elsif increment_control(9) = '1' then
                        count_read(6 downto 1) <= "001001";
                     else 
                        count_read(6 downto 1) <= "001010";
                     end if;

                  -- 2nd frame size bin decision point.  Jump to the 
                  -- appropriate statistic counter address                    
                  elsif round_robin_sequence(4) = '1' then
                     if increment_control(11) = '1' then
                        count_read(6 downto 1) <= "001011";
                     elsif increment_control(12) = '1' then
                        count_read(6 downto 1) <= "001100";
                     elsif increment_control(13) = '1' then
                        count_read(6 downto 1) <= "001101";
                     elsif increment_control(14) = '1' then
                        count_read(6 downto 1) <= "001110";
                     elsif increment_control(15) = '1' then
                        count_read(6 downto 1) <= "001111";
                     elsif increment_control(16) = '1' then
                        count_read(6 downto 1) <= "010000";
                     else 
                        count_read(6 downto 1) <= "010001";
                     end if;

                  else
                     count_read(6 downto 1) <= next_count_read(6 downto 1);
                  end if;
               end if;
            end if;
         end if;
      end if;
   end process read_counter;
   
   -- since round robin sequence and count read (upper 6 bits) are stable for 2 cycles
   -- use one cycle to do +1 and fixed value calc and reduce logic in above process
   next_read_counter : process(ref_clk)
   begin
      if (ref_clk'event and ref_clk = '1') then
         if count_read(0) = '0' then
            -- After the frame size bins, set counter to the 1st
            -- of the "general" purpose counter positions                
            if round_robin_sequence(5) = '1' then
               next_count_read(6 downto 1) <= "010010";
            -- else increment freely for all counters other than the
            -- frame size bin groups
            else
               next_count_read(6 downto 1) <= count_read(6 downto 1) 
                                              + "000001";
            end if;
         end if;
      end if;
   end process next_read_counter;



   ---------------------------------------------------------------------
   -- block RAM port A write counter creation
   ---------------------------------------------------------------------

   -- Delay the complicated read counter by a fixed delay to form the 
   -- write counter.  In this way, the write counter always follows the
   -- read counter by 5 clock cycles.  This allows time for the read-
   -- increment-write pipeline.  This odd delay is also required to
   -- alternate between read and writes of Port A of the block RAM.
          
   -- SRL16 creates a delay of 4 clock cycles
   shift_ram_count_gen : for I in 0 to 6 generate
      shift_ram_count_i :  SRL16E
   port map (D   => count_read(I),
         CE  => '1',
         CLK => ref_clk,
         A0  => '0',
         A1  => '0',
         A2  => '0',
         A3  => '0',
         Q   => count_read_srl16(I)); 
   end generate;


   -- The 5th clock cycle delay is formed with a standard register
   process(ref_clk)
   begin
      if (ref_clk'event and ref_clk = '1') then
         if (ref_reset = '1') then
            count_write    <= (others => '0');
         else
            count_write    <= count_read_srl16;
         end if;
      end if;
   end process;



   ---------------------------------------------------------------------
   -- Block RAM Port A Control
   ---------------------------------------------------------------------


   -- count_read is the master control: the write enable for block RAM
   -- Port A is driven from count_read(0) and is therefore asserted once
   -- every alternate clock cycle.  When wea is asserted, count_write is
   -- muxed onto the address port: when not assered, count_read is muxed
   -- onto the address bus, thereby alternating between read and write. 
                 
   process(ref_clk)
   begin
      if (ref_clk'event and ref_clk = '1') then
         if (ref_reset = '1') then
            addra <= (others => '0');
            wea    <= '0';
         else
            -- only write if we have something to change (lower power..)
            wea    <= count_read(0) and (clear_read_next or inc_reg3);

            if count_read(0) = '1' then
               addra <= "000" & count_write(6 downto 1);
            else
               addra <= "000" & std_logic_vector(count_read(6 downto 1));
            end if;

         end if;
      end if;
   end process;

      
   
   ---------------------------------------------------------------------
   -- Accumulator pipeline
   ---------------------------------------------------------------------
   
   -- Remember that the write address into block RAM port A lags behind
   -- the read address by 5 clock cycles.  So we have a 5 clock read-
   -- increment-write for each statistic counter as follows:

   -- (1) read statistic counter from port A of block RAM.
   -- (2) sample the 64-bit value read out.
   -- (3) increment the lower 32 bits if required.
   -- (4) increment the upper 32 bits if lower addition created a carry      
   -- (5) write back the updated statistic into Port A.

   process(ref_clk)
   begin
      if (ref_clk'event and ref_clk = '1') then
         if (ref_reset = '1') then
            doa_sample      <= (others => '0');
            accum_lower     <= (others => '0');
            accum_upper     <= (others => '0');

         else
            -- (2) sample the 64-bit value read out.
            if count_read(0) = '1' then
               doa_sample <= doa;
            end if;

            -- (3) increment the lower 32 bits if required.
            if count_read(0) = '0' then
               if (clear_read_pipe = '1') then
                  accum_lower <= "00000000000000000000000000000000" & inc_reg2;
               else
                  accum_lower <= unsigned(doa_sample(31 downto 0)) + 
                              ("00000000000000000000000000000000" & inc_reg2);
               end if;
            end if;

            -- (4) increment the upper 32 bits if lower addition 
            --     created a carry      
            if count_read(0) = '1' then
               if (clear_read_next = '1') then
                  accum_upper <= "00000000000000000000000000000000";
               else
                  accum_upper <= unsigned(doa_sample(63 downto 32)) + 
                        ("0000000000000000000000000000000" & accum_lower(32));
               end if;
            end if;

         end if;
      end if;
   end process;

   -- (5) write back the updated statistic into Port A.
   -- dia (block RAM port A data)  is valid when wea(count_read(0) is set to logic 1.
   dia <= std_logic_vector(accum_upper & accum_lower(31 downto 0));



   
   ---------------------------------------------------------------------
   -- Mangement Read logic (Block RAM port B)
   ---------------------------------------------------------------------
   
   -- A read request arrives via the IPIC in the 
   -- bus2ip_clk domain.  This request must be translated into the ref_clk
   -- domain and the correct 64-bit statistic read.  The upper 32 bits are sampled
   -- and held and the lower 32 bits are output onto the IPIC port, ip2bus_data
   -- along with the required ack.  If the upper 32 bits are accessed no
   -- request is made to the refclk domain and the previously sampled value is output


   ---------------------------------
   -- bus2ip_clk domain
   ---------------------------------


   request_pulse_gen : process(bus2ip_clk)
   begin
      if (bus2ip_clk'event and bus2ip_clk = '1') then
         if (bus2ip_reset = '1') then
            bus2ip_cs_reg <= '0';
         else
            bus2ip_cs_reg <= bus2ip_ce;     
         end if;
      end if;
   end process request_pulse_gen;
   
   -- generate a pulse on active reads
   silly_typing : process(bus2ip_ce, bus2ip_cs_reg, bus2ip_addr)
   begin
      if ((bus2ip_ce = '1' and bus2ip_cs_reg = '0')) then
         bus2ip_cs_int <= '1';
      else
         bus2ip_cs_int <= '0';     
      end if;
   end process silly_typing;

   
   -- Decode if a ref_clk access is required and generate toggle
   toggle_req_gen : process(bus2ip_clk)
   begin
      if (bus2ip_clk'event and bus2ip_clk = '1') then
         if (bus2ip_reset = '1') then
            request_toggle   <= '0';
            return_error     <= '0';
            return_high_word <= '0';
            capture_address  <= "111111";  -- no stats at this address
         elsif (bus2ip_cs_int = '1' and bus2ip_rdce = '1') then  
            if (bus2ip_addr(2) = '1') then
               if (bus2ip_addr(8 downto 3) = capture_address) then
                  return_high_word <= '1';
               else
                  return_error <= '1';
               end if;
            else
               capture_address  <= bus2ip_addr(8 downto 3);
               -- toggle this signal (used for clock domain crossing).
               request_toggle   <= not request_toggle;
            end if;
         else
            return_error     <= '0';
            return_high_word <= '0';
         end if;
      end if;
   end process toggle_req_gen;

   ---------------------------------
   -- Now continue in ref_clk domain
   ---------------------------------
   
   -- Reclock the request twice on ref_clk.
   sync_request : axi_ethernet_v3_01_a_sync_block
   port map(
     clk         => ref_clk,      
     data_in     => request_toggle,
     data_out    => request_tog_sync
   );
   
   
   -- reclock the request_toggle signal in the ref_clk domain
   reclock_request : process(ref_clk)
   begin
    if (ref_clk'event and ref_clk = '1') then
       if (ref_reset = '1') then
            request_reg  <= '0';
            request_reg2 <= '0';
       else
            request_reg  <= request_tog_sync;           
            request_reg2 <= request_reg;
       end if;
    end if;
   end process;
   


   -- Most of the time addrb is taken from the Management read request
   -- address.  The exception to this is when the "zero-ing" function is
   -- running.
   gen_portb_address : process(ref_clk)
   variable address_vector : integer;
   begin
      if (ref_clk'event and ref_clk = '1') then
         if (ref_reset = '1') then
            ipic_rd_clear <= '0';
            address_vector := 0;

         else
            -- After the toggle is detected, address is stable
            -- ************* check constraints **************
            if (request_tog_sync xor request_reg) = '1' then
               address_vector := TO_INTEGER(unsigned(bus2ip_addr(8 downto 3)));
               if (counter_reset(address_vector) = '1') then
                  ipic_rd_clear <= '1';
               else
                  ipic_rd_clear <= '0';
               end if;

            end if;
         end if;
      end if;
   end process gen_portb_address;

   addrb <= bus2ip_addr(8 downto 3);


   -- create a signal to identify when the bus is safe to sample - we have
   -- to use a combination of wepa and wea to do this (or count_read(0) = 1)
   gen_read_enable : process(ref_clk)
   begin
     enb <= enb_reg1;
   end process gen_read_enable;

   en_local1: process(request_tog_sync,request_reg,count_read,request_reg2) begin
     if (( ((request_reg xor request_reg2) = '1') )) then      -- OR here
       enb_loc1 <= '1';
     else
       enb_loc1 <= '0';
     end if;
   end process en_local1;

   en_local2: process(request_tog_sync,request_reg,count_read,request_reg2) begin
     if (((request_tog_sync xor request_reg) = '1' )  ) then      -- OR here
       enb_loc2 <= '1';
     else
       enb_loc2 <= '0';
     end if;
   end process en_local2;

   en_local3: process(enb_loc2,enb_loc1) begin
     enb_loc <= enb_loc1 or enb_loc2;
   end process en_local3;

   count_neg: process(count_read) begin
     count_read_neg  <= not count_read(0) ;
   end process count_neg;

   reg_enable1: process(ref_clk) begin
     if (ref_clk'event and ref_clk = '1') then
       if (ref_reset = '1') then
         enb_reg1 <= '0';
       else
         enb_reg1 <=  enb_loc and count_read_neg;
       end if;
     end if;

   end process reg_enable1;
   -- capture full 64 bits (72?)
   capture_rd_data : process(ref_clk)
   begin
      if (ref_clk'event and ref_clk = '1') then
         if (ref_reset = '1') then
            rd_data_ref <= (others => '0');
         else
            if (ipic_rd_clear = '1') then
               rd_data_ref <= (others => '0');       
            elsif (enb = '1') then
               rd_data_ref <= dopb(7) & dob & dopb(6 downto 0);            
            end if;
         end if;
      end if;
   end process capture_rd_data;


   gen_toggle : process(ref_clk)
   begin
      if (ref_clk'event and ref_clk = '1') then
         if (ref_reset = '1') then
            response_toggle <= '0';
         elsif (enb = '1') then
            response_toggle <= not response_toggle;
         end if;
      end if;
   end process gen_toggle;

   ---------------------------------
   -- Now back to bus2ip_clk domain
   ---------------------------------

   -- Reclock  on bus2ip_clk.
   sync_response : axi_ethernet_v3_01_a_sync_block
   port map(
     clk         => bus2ip_clk,      
     data_in     => response_toggle,
     data_out    => response_tog_sync
   );
   
   -- reclock the response_toggle signal in the bus2ip_clk domain
   reclock_response : process(bus2ip_clk)
   begin
      if (bus2ip_clk'event and bus2ip_clk = '1') then
         if (bus2ip_reset = '1') then
            response_reg  <= '0';
         else
            response_reg  <= response_tog_sync;                                   
         end if;
      end if;
   end process;
   
   
   
   gen_stat_read_data : process(bus2ip_clk)
   begin
      if (bus2ip_clk'event and bus2ip_clk = '1') then
         if (bus2ip_reset = '1') then
            ip2bus_data <= (others => '0');

         else
            -- We are reading the lower 32-bit word
            if bus2ip_addr(2) = '0' then
               if rd_data_ref(71) = '1' then
                  -- if bit 7 of the parity is '1' then this is a "fast"
                  -- counter in which the lower 7 bits are stored in parity             
                  ip2bus_data <= rd_data_ref(31 downto 0);
               else
                  -- All other counters are simply stored in normal data
                  ip2bus_data <= rd_data_ref(38 downto 7);
               end if;

            -- We are reading the upper 32-bit word
            else
               if rd_data_ref(71) = '1' then
                  -- if bit 7 of the parity is '1' then this is a "fast"
                  -- counter in which the lower 7 bits are stored in parity             
                  ip2bus_data <= rd_data_ref(63 downto 32);
               else
                  -- All other counters are simply stored in normal data
                  ip2bus_data <= rd_data_ref(70 downto 39);
               end if;
            end if;
         end if;
      end if;
   end process gen_stat_read_data;

   -- generate the ack
   gen_ack : process(bus2ip_clk)
   begin
      if (bus2ip_clk'event and bus2ip_clk = '1') then
         if (bus2ip_reset = '1') then
            ip2bus_rdack  <= '0';
            ip2bus_wrack  <= '0';
         else
            if ((response_reg  xor response_tog_sync) = '1' or 
                return_high_word = '1' or return_error = '1') then
               ip2bus_rdack  <= '1';
               ip2bus_wrack  <= '0';
            elsif (bus2ip_cs_int = '1' and bus2ip_wrce = '1') then
               ip2bus_rdack  <= '0';
               ip2bus_wrack  <= '1';
            else
               ip2bus_rdack  <= '0';
               ip2bus_wrack  <= '0';
            end if;
         end if;
      end if;
   end process gen_ack;
   
   -- generate the error if a write is attempted
   gen_error : process(bus2ip_clk)
   begin
      if (bus2ip_clk'event and bus2ip_clk = '1') then
         if (bus2ip_reset = '1') then
            ip2bus_error  <= '0';
         else
            if (bus2ip_cs_int = '1' and bus2ip_wrce = '1') or return_error = '1' then
               ip2bus_error  <= '1';
            else
               ip2bus_error  <= '0';
            end if;
         end if;
      end if;
   end process gen_error;
   

   ---------------------------------------------------------------------
   -- NEW Statistic counter "zero-ing" function.
   ---------------------------------------------------------------------
   
   -- this reset function will use a reg bit per counter. at reset this is set to all
   -- ones and each subsequenct access of the stats will change the modify stage to 
   -- assume a zero read  - if the bit is set on a host access then the read will return zero
   
   counter_reset_gen : if (C_CNTR_RST) generate

      gen_counter_reset : process(ref_clk)
      variable address_vector : integer;
      begin
         if (ref_clk'event and ref_clk = '1') then
            if (ref_reset = '1') then
               counter_reset <= (others => '1');
            else
               address_vector := TO_INTEGER(unsigned(count_read(6 downto 1)));
               if (count_read(0) = '1') then
                  counter_reset(address_vector) <= '0';
               end if;
            end if;
         end if;
      end process gen_counter_reset;

      gen_clear_read : process(ref_clk)
      variable address_vector : integer;
      begin
         if (ref_clk'event and ref_clk = '1') then
            if (ref_reset = '1') then
               clear_read_pipe <='0';
               clear_read_next <='0';
            else
               clear_read_next <= clear_read_pipe;
               address_vector := TO_INTEGER(unsigned(count_read(6 downto 1)));
               if (count_read(0) = '1' and counter_reset(address_vector) = '1') then
                  clear_read_pipe <='1';
               else
                  clear_read_pipe <='0';
               end if;
            end if;
         end if;
      end process gen_clear_read;

   end generate counter_reset_gen;
   
   no_counter_reset_gen : if not(C_CNTR_RST) generate
   
      counter_reset <= (others => '0');
      clear_read_pipe <='0';
      clear_read_next <='0';
   
   end generate no_counter_reset_gen;
   
   

end rtl;
         
         

       
