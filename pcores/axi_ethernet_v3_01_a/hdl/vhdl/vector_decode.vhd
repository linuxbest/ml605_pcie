------------------------------------------------------------------------
-- File       : vector_decode.vhd
-- Author     : Xilinx Inc.
-- File       : vector_decode.vhd
-------------------------------------------------------------------------------
--
-- *************************************************************************
--
-- (c) Copyright 2004-2008 Xilinx, Inc. All rights reserved.
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
-- Description: This is the Statistic Vector Decoder block.
-- 
--              Input statistic vectors are decoded into increment 
--              signals.  Since this block is provided in HDL, it can be
--              edited and tailored to specific statistical gathering
--              applications.
--
--  			ie. by editing this file, you can change the statistics
--              that are to be counted. 

  
  
library ieee;
use ieee.std_logic_1164.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

library unisim;
use unisim.vcomponents.all;

------------------------------------------------------------------------
-- The entity declaration for the Statistic Vector Decoder block.
------------------------------------------------------------------------

entity vector_decode is
    generic(
      C_HALFDUP              : integer range  0 to 1  :=  0;
      C_NUM_STATS            : integer range 33 to 43 := 33
      );

   port (

      -- Transmitter Statistic Vector inputs from ethernet MAC
      tx_clk                           : in std_logic;  
      tx_reset                         : in std_logic;  
      tx_statistics_vector             : in std_logic_vector(31 downto 0);
      tx_statistics_valid              : in std_logic;

      -- Receiver Statistic Vector inputs from ethernet MAC
      rx_clk                           : in std_logic;  
      rx_reset                         : in std_logic;  
      rx_statistics_vector             : in std_logic_vector(27 downto 0);
      rx_statistics_valid              : in std_logic;

      -- Increment update signals for Statistic Counters 4 upwards
      increment_vector                 : out std_logic_vector(4 to C_NUM_STATS - 1)

   );
end vector_decode;



architecture rtl of vector_decode is



   -- Signals to rename the tx_statistics_vector for readability!
   signal tx_pause_frame               : std_logic;                                                                   
   signal tx_attemps                   : std_logic_vector(3 downto 0);
   signal tx_excessive_collision       : std_logic;
   signal tx_late_collision            : std_logic;
   signal tx_excessive_deferral        : std_logic;
   signal tx_deferred                  : std_logic;                                                                                           
   signal tx_vlan_frame                : std_logic;                                                                   
   signal tx_vlan_frame_reg            : std_logic;                                                                   
   signal tx_frame_length              : std_logic_vector(13 downto 0);
   signal tx_control_frame             : std_logic;                                                                   
   signal tx_underrun_frame            : std_logic;                                                                   
   signal tx_multicast_frame           : std_logic;                                                                   
   signal tx_broadcast_frame           : std_logic;                                                                   
   signal tx_good_frame                : std_logic;
   signal tx_byte_valid                : std_logic;

   -- Reclocked for pipelining
   signal tx_good_frame_reg            : std_logic;
   signal tx_control_frame_reg         : std_logic;
   								    
   
   									    
   -- Signals to rename the rx_statistics_vector for readability!
   signal rx_address_match             : std_logic;
   signal rx_alignment_error           : std_logic;
   signal rx_length_type_error         : std_logic;
   signal rx_bad_pause_opcode          : std_logic;
   signal rx_flow_control_frame        : std_logic;                                                                                                
   signal rx_vlan_frame                : std_logic;                                                                                                
   signal rx_vlan_frame_reg            : std_logic;                                                                                                
   signal rx_out_of_bounds_error       : std_logic;                                                                                                
   signal rx_control_frame             : std_logic;                                                                                                
   signal rx_frame_length              : std_logic_vector(13 downto 0);
   signal rx_multicast_frame           : std_logic;                                                                                                
   signal rx_broadcast_frame           : std_logic;                                                                                                
   signal rx_fcs_error                 : std_logic;                                                                                                
   signal rx_bad_frame                 : std_logic;                                                                                                
   signal rx_good_frame                : std_logic;                                                                                                
   signal rx_byte_valid                : std_logic;

   -- Reclocked for pipelining
   signal    rx_statistics_vector_reg  : std_logic_vector(27 downto 0);
   signal rx_good_frame_reg            : std_logic;
   signal rx_bad_frame_reg             : std_logic;                                             						    
   signal rx_fcs_error_reg             : std_logic;                                             						    
   signal rx_control_frame_reg         : std_logic;
   signal rx_length_type_error_reg     : std_logic;
   signal rx_flow_control_frame_reg    : std_logic;                                             					    
   signal rx_bad_pause_opcode_reg      : std_logic;
   signal rx_alignment_error_reg       : std_logic;
   				                                                               
   												    

   -- New Statistic Valid Signals also taking into account the
   -- clock enables (if applicable).
   signal rx_stats_valid               : std_logic;   
   signal tx_stats_valid               : std_logic;

   -- Reclocked for pipelining
   signal rx_statistics_valid_reg      : std_logic;
   signal rx_stats_valid_pipe          : std_logic;    
   signal rx_stats_valid_reg           : std_logic;    
   signal tx_statistics_valid_reg      : std_logic;
   signal tx_stats_valid_pipe          : std_logic;
   signal tx_stats_valid_reg           : std_logic;



   -- Rx Frame size interpretation.
   signal rx_0_63                      : std_logic;  
   signal rx_64                        : std_logic;   
   signal rx_65_127                    : std_logic;
   signal rx_128_255                   : std_logic;
   signal rx_256_511                   : std_logic;
   signal rx_512_1023                  : std_logic;
   signal rx_1024_max                  : std_logic;
   signal rx_oversize                  : std_logic;

   -- Tx Frame size interpretation.
   signal tx_0_64                      : std_logic;   
   signal tx_65_127                    : std_logic;
   signal tx_128_255                   : std_logic;
   signal tx_256_511                   : std_logic;
   signal tx_512_1023                  : std_logic;
   signal tx_1024_max                  : std_logic;
   signal tx_oversize                  : std_logic;


   -- Half Duplex retransmit interpretation.
   signal single_attempt               : std_logic;
   signal multiple_attempt             : std_logic;

   signal tx_statistics_vector_reg     : std_logic_vector(31 downto 0);

   -- internal increment request bits which will later be routed to the 
   -- Statistic core.
   signal inc_vector                   : std_logic_vector(4 to C_NUM_STATS - 1);

   -- Signals to allow pipelining of the longest logical path 
   signal rx_oversize_frame            : std_logic;
   signal rx_frame_length_reg          : std_logic_vector(13 downto 0);
   signal rx_mult_64                   : std_logic;
   signal tx_oversize_frame            : std_logic;
   signal tx_frame_length_reg          : std_logic_vector(13 downto 0);
   signal tx_mult_64                   : std_logic;
   
   

begin



  ----------------------------------------------------------------------
  -- Transmitter Statistics Vector Interpretation
  ----------------------------------------------------------------------


  -- The tx_statistics_vector is renamed for readability!
  tx_pause_frame         <= tx_statistics_vector_reg(31);
  tx_byte_valid          <= tx_statistics_vector_reg(30);
  tx_attemps             <= tx_statistics_vector_reg(28 downto 25);
  tx_excessive_collision <= tx_statistics_vector_reg(23);
  tx_late_collision      <= tx_statistics_vector_reg(22);
  tx_excessive_deferral  <= tx_statistics_vector_reg(21);
  tx_deferred            <= tx_statistics_vector_reg(20);  												    
  tx_vlan_frame          <= tx_statistics_vector(19);												    
  tx_vlan_frame_reg      <= tx_statistics_vector_reg(19);												    
  tx_frame_length        <= tx_statistics_vector(18 downto 5); --already pipelined
  tx_control_frame       <= tx_statistics_vector_reg(4);												    
  tx_underrun_frame      <= tx_statistics_vector_reg(3);												    
  tx_multicast_frame     <= tx_statistics_vector_reg(2);												    
  tx_broadcast_frame     <= tx_statistics_vector_reg(1);												    
  tx_good_frame          <= tx_statistics_vector_reg(0);												    


  -- The tx_statistics_valid signal is only valid when clock enabled
  tx_stats_valid         <= tx_statistics_valid and not tx_statistics_valid_reg;



  ----------------------------------------------------------------------
  -- Receiver Statistics Vector Interpretation
  ----------------------------------------------------------------------


  -- The rx_statistics_vector is renamed for readability!
  rx_address_match       <= rx_statistics_vector(27);
  rx_alignment_error     <= rx_statistics_vector_reg(26);
  rx_length_type_error   <= rx_statistics_vector_reg(25);
  rx_bad_pause_opcode    <= rx_statistics_vector_reg(24);
  rx_flow_control_frame  <= rx_statistics_vector_reg(23);												    
  rx_byte_valid          <= rx_statistics_vector_reg(22);
  rx_vlan_frame          <= rx_statistics_vector(21);												    
  rx_vlan_frame_reg      <= rx_statistics_vector_reg(21);												    
  rx_out_of_bounds_error <= rx_statistics_vector_reg(20);												    
  rx_control_frame       <= rx_statistics_vector_reg(19);												    
  rx_multicast_frame     <= rx_statistics_vector_reg(4);												    
  rx_broadcast_frame     <= rx_statistics_vector_reg(3);												    
  rx_fcs_error           <= rx_statistics_vector_reg(2);												    
  rx_bad_frame           <= rx_statistics_vector_reg(1);												    
  rx_good_frame          <= rx_statistics_vector_reg(0);												    

   -- decode the following directly from the vector
  rx_frame_length        <= rx_statistics_vector(18 downto 5);

  -- The rx_statistics_valid signal is only valid when clock enabled
  rx_stats_valid         <= rx_statistics_valid and not rx_statistics_valid_reg

                            -- and only when the address match is set!
                            and rx_address_match;

   rx_vector_reclock : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then
         if (rx_reset = '1') then
                rx_statistics_valid_reg          <= '0';
   	        rx_statistics_vector_reg         <= (others => '0');
         else
                rx_statistics_valid_reg          <= rx_statistics_valid;
                if rx_stats_valid = '1' then
   	           rx_statistics_vector_reg      <= rx_statistics_vector;
                end if;
         end if;
      end if;
   end process rx_vector_reclock;



   tx_vector_reclock : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then
         if (tx_reset = '1') then
                tx_statistics_valid_reg          <= '0';
   	        tx_statistics_vector_reg         <= (others => '0');
         else
                tx_statistics_valid_reg          <= tx_statistics_valid;
                if tx_stats_valid = '1' then
   	           tx_statistics_vector_reg         <= tx_statistics_vector;
                end if;
         end if;
      end if;
   end process tx_vector_reclock;


  ----------------------------------------------------------------------
  -- Pipelining to compensate for the Statistic Vector Decoding Logic
  ----------------------------------------------------------------------


   -- Pipeline receiver vector bits
   rx_statistics_reclock : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then
         if (rx_reset = '1') then
   	    rx_stats_valid_pipe       <= '0';
   	    rx_stats_valid_reg        <= '0';
            rx_good_frame_reg         <= '0';
            rx_bad_frame_reg          <= '0';
            rx_fcs_error_reg          <= '0';
            rx_control_frame_reg      <= '0';
            rx_length_type_error_reg  <= '0';
            rx_flow_control_frame_reg <= '0';
            rx_bad_pause_opcode_reg   <= '0';
            rx_alignment_error_reg    <= '0'; 
         else
   	    rx_stats_valid_pipe       <= rx_stats_valid;
   	    rx_stats_valid_reg        <= rx_stats_valid_pipe;
            rx_good_frame_reg         <= rx_good_frame;
            rx_bad_frame_reg          <= rx_bad_frame;
            rx_fcs_error_reg          <= rx_fcs_error;
            rx_control_frame_reg      <= rx_control_frame;
            rx_length_type_error_reg  <= rx_length_type_error;
            rx_flow_control_frame_reg <= rx_flow_control_frame;
            rx_bad_pause_opcode_reg   <= rx_bad_pause_opcode;
            rx_alignment_error_reg    <= rx_alignment_error; 
         end if;
      end if;
   end process rx_statistics_reclock;

                                                  

   -- Pipeline transmitter vector bits
   tx_statistics_reclock : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then
         if (tx_reset = '1') then
   	    tx_stats_valid_pipe  <= '0';
   	    tx_stats_valid_reg   <= '0';
            tx_good_frame_reg    <= '0';
            tx_control_frame_reg <= '0';
          else
   	    tx_stats_valid_pipe  <= tx_stats_valid;
   	    tx_stats_valid_reg   <= tx_stats_valid_pipe;
            tx_good_frame_reg    <= tx_good_frame;
            tx_control_frame_reg <= tx_control_frame;
         end if;
      end if;
   end process tx_statistics_reclock;

   -- add pipelining to simplify the size decode
   rx_frame_size_precalc : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then
         if (rx_reset = '1') then
            rx_oversize_frame <= '0';
            rx_frame_length_reg <= (others => '0');
            rx_mult_64 <= '0';
          else
            rx_frame_length_reg <= rx_frame_length;
            if ((rx_vlan_frame = '0' and
            	  rx_frame_length > "00010111101110") or   --1518 (non VLAN)
            	  rx_frame_length > "00010111110010") then --1522 (VLAN)
               rx_oversize_frame <= '1';
            else
               rx_oversize_frame <= '0';
            end if;
            if (rx_frame_length(5 downto 0) = "000000") then
               rx_mult_64 <= '1';
            else
               rx_mult_64 <= '0';
            end if;
         end if;
      end if;
   end process rx_frame_size_precalc;

   tx_frame_size_precalc : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then
         if (tx_reset = '1') then
            tx_oversize_frame <= '0';
            tx_frame_length_reg <= (others => '0');
            tx_mult_64 <= '0';
          else
            tx_frame_length_reg <= tx_frame_length;
            if ((tx_vlan_frame = '0' and
            	  tx_frame_length > "00010111101110") or   --1518 (non VLAN)
            	  tx_frame_length > "00010111110010") then --1522 (VLAN)
               tx_oversize_frame <= '1';
            else
               tx_oversize_frame <= '0';
            end if;
            if (tx_frame_length(5 downto 0) = "000000") then
               tx_mult_64 <= '1';
            else
               tx_mult_64 <= '0';
            end if;
         end if;
      end if;
   end process tx_frame_size_precalc;



   ---------------------------------------------------------------------
   -- Statistic Vector Decoding Logic
   ---------------------------------------------------------------------

   

   -- Decode the received frames length field to obtain frame size
   -- ranges.
   rx_compare : process(rx_clk)
   begin
	  if (rx_clk'event and rx_clk = '1') then
	     if rx_reset = '1' then
            rx_0_63     <= '0';
            rx_64       <= '0';
            rx_65_127   <= '0';
            rx_128_255  <= '0';
            rx_256_511  <= '0';
            rx_512_1023 <= '0';
            rx_1024_max <= '0';
            rx_oversize <= '0';
         else
            if (rx_oversize_frame = '1') then
               rx_0_63     <= '0';
               rx_64       <= '0';
               rx_65_127   <= '0';
               rx_128_255  <= '0';
               rx_256_511  <= '0';
               rx_512_1023 <= '0';
               rx_1024_max <= '0';
               rx_oversize <= '1';
            elsif (rx_frame_length_reg(10) = '1') then -- 1024 bytes or greater
               rx_0_63     <= '0';
               rx_64       <= '0';
               rx_65_127   <= '0';
               rx_128_255  <= '0';
               rx_256_511  <= '0';
               rx_512_1023 <= '0';
               rx_1024_max <= '1';
               rx_oversize <= '0';
            elsif (rx_frame_length_reg(9) = '1') then  -- 512 bytes or greater
               rx_0_63     <= '0';
               rx_64       <= '0';
               rx_65_127   <= '0';
               rx_128_255  <= '0';
               rx_256_511  <= '0';
               rx_512_1023 <= '1';
               rx_1024_max <= '0';
               rx_oversize <= '0';
            elsif (rx_frame_length_reg(8) = '1') then  -- 256 bytes or greater
               rx_0_63     <= '0';
               rx_64       <= '0';
               rx_65_127   <= '0';
               rx_128_255  <= '0';
               rx_256_511  <= '1';
               rx_512_1023 <= '0';
               rx_1024_max <= '0';
               rx_oversize <= '0';
            elsif (rx_frame_length_reg(7) = '1') then  -- 128 bytes or greater
               rx_0_63     <= '0';
               rx_64       <= '0';
               rx_65_127   <= '0';
               rx_128_255  <= '1';
               rx_256_511  <= '0';
               rx_512_1023 <= '0';
               rx_1024_max <= '0';
               rx_oversize <= '0';
            elsif rx_frame_length_reg(6) = '1' then    -- 64 bytes or greater
               if rx_mult_64 = '0' then
                  rx_0_63     <= '0';
                  rx_64       <= '0';
                  rx_65_127   <= '1';              -- greater than 64 bytes
                  rx_128_255  <= '0';
                  rx_256_511  <= '0';
                  rx_512_1023 <= '0';
                  rx_1024_max <= '0';
                  rx_oversize <= '0';
               else                                -- exactly 64 bytes
                  rx_0_63     <= '0';
                  rx_64       <= '1';
                  rx_65_127   <= '0';
                  rx_128_255  <= '0';
                  rx_256_511  <= '0';
                  rx_512_1023 <= '0';
                  rx_1024_max <= '0';
                  rx_oversize <= '0';
               end if;
            else                                   -- less then 64 bytes
               rx_0_63     <= '1';
               rx_64       <= '0';
               rx_65_127   <= '0';
               rx_128_255  <= '0';
               rx_256_511  <= '0';
               rx_512_1023 <= '0';
               rx_1024_max <= '0';
               rx_oversize <= '0';
            end if;
         end if;
      end if;
   end process rx_compare;


   
   -- Decode the transmitter frames length field to obtain frame size
   -- ranges.
   tx_compare : process (tx_clk)
   begin
	  if (tx_clk'event and tx_clk = '1') then
	     if (tx_reset = '1') then
            tx_0_64     <= '0';
            tx_65_127   <= '0';
            tx_128_255  <= '0';
            tx_256_511  <= '0';
            tx_512_1023 <= '0';
            tx_1024_max <= '0';
            tx_oversize <= '0';
         else
            if (tx_oversize_frame = '1') then 
               tx_0_64     <= '0';
               tx_65_127   <= '0';
               tx_128_255  <= '0';
               tx_256_511  <= '0';
               tx_512_1023 <= '0';
               tx_1024_max <= '0';
               tx_oversize <= '1';
            elsif (tx_frame_length_reg(10) = '1') then -- 1024 bytes or greater
               tx_0_64     <= '0';
               tx_65_127   <= '0';
               tx_128_255  <= '0';
               tx_256_511  <= '0';
               tx_512_1023 <= '0';
               tx_1024_max <= '1';
               tx_oversize <= '0';
            elsif (tx_frame_length_reg(9) = '1') then  -- 512 bytes or greater
               tx_0_64     <= '0';
               tx_65_127   <= '0';
               tx_128_255  <= '0';
               tx_256_511  <= '0';
               tx_512_1023 <= '1';
               tx_1024_max <= '0';
               tx_oversize <= '0';
            elsif (tx_frame_length_reg(8) = '1') then  -- 256 bytes or greater
               tx_0_64     <= '0';
               tx_65_127   <= '0';
               tx_128_255  <= '0';
               tx_256_511  <= '1';
               tx_512_1023 <= '0';
               tx_1024_max <= '0';
               tx_oversize <= '0';
            elsif (tx_frame_length_reg(7) = '1') then  -- 128 bytes or greater
               tx_0_64     <= '0';
               tx_65_127   <= '0';
               tx_128_255  <= '1';
               tx_256_511  <= '0';
               tx_512_1023 <= '0';
               tx_1024_max <= '0';
               tx_oversize <= '0';
            elsif (tx_frame_length_reg(6) = '1'        -- 65 bytes or greater 
            and tx_mult_64 = '0') then
               tx_0_64     <= '0';
               tx_65_127   <= '1';
               tx_128_255  <= '0';
               tx_256_511  <= '0';
               tx_512_1023 <= '0';
               tx_1024_max <= '0';
               tx_oversize <= '0';
            else                                   -- 64 bytes or less
               tx_0_64     <= '1';
               tx_65_127   <= '0';
               tx_128_255  <= '0';
               tx_256_511  <= '0';
               tx_512_1023 <= '0';
               tx_1024_max <= '0';
               tx_oversize <= '0';
            end if;
         end if;
      end if;
   end process tx_compare;



   -- For Collision handling: detect when multiple attempts were made
   -- to transmit a frame.
   multiple_attempt <= tx_attemps(3) or tx_attemps(2) or tx_attemps(1);


   -- For Collision handling: detect when only a single attempt was
   -- required to transmit a frame.
   single_attempt   <= tx_attemps(0) and (not multiple_attempt);



   ---------------------------------------------------------------------
   -- Statistic Counters 4 to 10 are the 1st set of counters reserved 
   -- for frame size bins.
   --
   -- Only 1 counter in this set is updated per statistic_valid pulse.
   ---------------------------------------------------------------------
   


   -- Counter 4: "64 byte frames received OK" increment request 
   --------------
   counter4 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(4) <= '0';

         elsif rx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if (rx_good_frame_reg and rx_64) = '1' then
             inc_vector(4) <= not inc_vector(4);
           end if;

         end if;
      end if;
   end process counter4;



   -- Counter 5: "65-127 byte frames received OK" increment request 
   --------------
   counter5 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(5) <= '0';

         elsif rx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if (rx_good_frame_reg and rx_65_127) = '1' then
             inc_vector(5) <= not inc_vector(5);
           end if;

         end if;
      end if;
   end process counter5;



   -- Counter 6: "128-255 byte frames received OK" increment request 
   --------------
   counter6 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(6) <= '0';

         elsif rx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if (rx_good_frame_reg and rx_128_255) = '1' then
             inc_vector(6) <= not inc_vector(6);
           end if;

         end if;
      end if;
   end process counter6;



   -- Counter 7: "256-511 byte frames received OK" increment request 
   --------------
   counter7 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(7) <= '0';

         elsif rx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if (rx_good_frame_reg and rx_256_511) = '1' then
             inc_vector(7) <= not inc_vector(7);
           end if;

         end if;
      end if;
   end process counter7;



   -- Counter 8: "512-1023 byte frames received OK" increment request 
   --------------
   counter8 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(8) <= '0';

         elsif rx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if (rx_good_frame_reg and rx_512_1023) = '1' then
             inc_vector(8) <= not inc_vector(8);
           end if;

         end if;
      end if;
   end process counter8;



   -- Counter 9: "1024-MaxFrameSize byte frames received OK" increment  
   -------------- request
   counter9 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(9) <= '0';

         elsif rx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if (rx_good_frame_reg and rx_1024_max) = '1' then
             inc_vector(9) <= not inc_vector(9);
           end if;

         end if;
      end if;
   end process counter9;



   -- Counter 10: "Oversized frames received OK" increment request 
   --------------
   counter10 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(10) <= '0';

         elsif rx_stats_valid_reg = '1' then

           if (rx_oversize and 

           -- Oversized but no other errors
           (not rx_fcs_error_reg) and (not rx_length_type_error_reg)
           and (not rx_alignment_error_reg)
           
           -- And not a control frame            
           and (not rx_control_frame_reg)) = '1' then

           -- toggle whenever an update is required
             inc_vector(10) <= not inc_vector(10);
           end if;

         end if;
      end if;
   end process counter10;



   ---------------------------------------------------------------------
   -- Statistic Counters 11 to 17 are the 2nd set of counters reserved 
   -- for frame size bins.
   --
   -- Only 1 counter in this set is updated per statistic_valid pulse.
   ---------------------------------------------------------------------
   


   -- Counter 11: "64-byte frames transmitted OK" increment request 
   --------------
   counter11 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(11) <= '0';

         elsif tx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if (tx_good_frame_reg and tx_0_64) = '1' then
             inc_vector(11) <= not inc_vector(11);
           end if;

         end if;
      end if;
   end process counter11;



   -- Counter 12: "65-127 byte frames transmitted OK" increment request 
   --------------
   counter12 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(12) <= '0';

         elsif tx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if (tx_good_frame_reg and tx_65_127) = '1' then
             inc_vector(12) <= not inc_vector(12);
           end if;

         end if;
      end if;
   end process counter12;



   -- Counter 13: "128-255 byte frames transmitted OK" increment request 
   --------------
   counter13 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(13) <= '0';

         elsif tx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if (tx_good_frame_reg and tx_128_255) = '1' then
             inc_vector(13) <= not inc_vector(13);
           end if;

         end if;
      end if;
   end process counter13;



   -- Counter 14: "256-511 byte frames transmitted OK" increment request 
   --------------
   counter14 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(14) <= '0';

         elsif tx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if (tx_good_frame_reg and tx_256_511) = '1' then
             inc_vector(14) <= not inc_vector(14);
           end if;

         end if;
      end if;
   end process counter14;



   -- Counter 15: "512-1023 byte frames transmitted OK"  
   -------------- increment request
   counter15 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(15) <= '0';

         elsif tx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if (tx_good_frame_reg and tx_512_1023) = '1' then
             inc_vector(15) <= not inc_vector(15);
           end if;

         end if;
      end if;
   end process counter15;



   -- Counter 16: "1024-MaxFrameSize byte frames transmitted OK"  
   -------------- increment request
   counter16 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(16) <= '0';

         elsif tx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if (tx_good_frame_reg and tx_1024_max) = '1' then
             inc_vector(16) <= not inc_vector(16);
           end if;

         end if;
      end if;
   end process counter16;



   -- Counter 17: "Oversized frames transmitted OK" increment request 
   --------------
   counter17 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(17) <= '0';

         elsif tx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if (tx_good_frame_reg and tx_oversize) = '1' then
             inc_vector(17) <= not inc_vector(17);
           end if;

         end if;
      end if;
   end process counter17;



   ---------------------------------------------------------------------
   -- Statistic update inputs for the standard counters
   ---------------------------------------------------------------------
   


   -- Counter 18: "Frames Received OK" increment request 
   --------------
   counter18 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(18) <= '0';

         elsif rx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if rx_good_frame = '1' then
             inc_vector(18) <= not inc_vector(18);
           end if;

         end if;
      end if;
   end process counter18;



   -- Counter 19: "Frame Check Sequence Errors" increment request 
   --------------
   counter19 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(19) <= '0';

         elsif rx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if rx_fcs_error_reg = '1' and rx_0_63 = '0' then
             inc_vector(19) <= not inc_vector(19);
           end if;

         end if;
      end if;
   end process counter19;



   -- Counter 20: "Broadcast frames received OK" increment request 
   --------------
   counter20 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(20) <= '0';

         elsif rx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if (rx_good_frame and rx_broadcast_frame) = '1' then
             inc_vector(20) <= not inc_vector(20);
           end if;

         end if;
      end if;
   end process counter20;



   -- Counter 21: "Multicast frames received OK" increment request 
   --------------
   counter21 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(21) <= '0';

         elsif rx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if (rx_good_frame and rx_multicast_frame) = '1' then
             inc_vector(21) <= not inc_vector(21);
           end if;

         end if;
      end if;
   end process counter21;



   -- Counter 22: "Control frames received OK" increment request 
   --------------
   counter22 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(22) <= '0';

         elsif rx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if (rx_good_frame and rx_control_frame) = '1' then
             inc_vector(22) <= not inc_vector(22);
           end if;

         end if;
      end if;
   end process counter22;



   -- Counter 23: "Length/Type Out of Range" increment request 
   --------------
   counter23 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(23) <= '0';

         elsif rx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if rx_length_type_error_reg = '1' and rx_0_63 = '0' then
             inc_vector(23) <= not inc_vector(23);
           end if;

         end if;
      end if;
   end process counter23;



   -- Counter 24: "VLAN tagged frames received OK" increment request 
   --------------
   counter24 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(24) <= '0';

         elsif rx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if (rx_good_frame and rx_vlan_frame_reg) = '1' then
             inc_vector(24) <= not inc_vector(24);
           end if;

         end if;
      end if;
   end process counter24;



   -- Counter 25: "Pause frames received OK" increment request 
   --------------
   counter25: process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(25) <= '0';

         elsif rx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if rx_flow_control_frame_reg = '1' and rx_0_63 = '0' then
             inc_vector(25) <= not inc_vector(25);
           end if;

         end if;
      end if;
   end process counter25;



   -- Counter 26: "Control Frames Received with Unsupported Opcode" 
   -------------- increment request 
   counter26 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(26) <= '0';

         elsif rx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if rx_bad_pause_opcode_reg = '1' and rx_0_63 = '0' then
             inc_vector(26) <= not inc_vector(26);
           end if;

         end if;
      end if;
   end process counter26;



   -- Counter 27: "Frames transmitted OK" increment request 
   --------------
   counter27 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(27) <= '0';

         elsif tx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if tx_good_frame = '1' then
             inc_vector(27) <= not inc_vector(27);
           end if;

         end if;
      end if;
   end process counter27;



   -- Counter 28: "Broadcast frames transmitted OK" increment request 
   --------------
   counter28 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(28) <= '0';

         elsif tx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if (tx_good_frame and tx_broadcast_frame) = '1' then
             inc_vector(28) <= not inc_vector(28);
           end if;

         end if;
      end if;
   end process counter28;



   -- Counter 29: "Multicast frames transmitted OK" increment request 
   --------------
   counter29 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(29) <= '0';

         elsif tx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if (tx_good_frame and tx_multicast_frame) = '1' then
             inc_vector(29) <= not inc_vector(29);
           end if;

         end if;
      end if;
   end process counter29;



   -- Counter 30: "Underrun errors" increment request 
   --------------
   counter30 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(30) <= '0';

         elsif tx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if tx_underrun_frame = '1' then
             inc_vector(30) <= not inc_vector(30);
           end if;

         end if;
      end if;
   end process counter30;



   -- Counter 31: "Control frames transmitted OK" increment request 
   --------------
   counter31 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(31) <= '0';

         elsif (tx_stats_valid_reg and tx_good_frame_reg) = '1' then

           -- toggle whenever an update is required
           if (tx_control_frame_reg and tx_0_64) = '1' then
             inc_vector(31) <= not inc_vector(31);
           end if;

         end if;
      end if;
   end process counter31;



   -- Counter 32: "VLAN tagged frames transmitted OK" increment request 
   --------------
   counter32 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(32) <= '0';

         elsif tx_stats_valid_pipe = '1' then

           -- Good VLAN frames
           if (tx_good_frame and tx_vlan_frame_reg) = '1' then
             inc_vector(32) <= not inc_vector(32);
           end if;

         end if;
      end if;
   end process counter32;



   -- Counter 33: "Pause frames transmitted OK" increment request 
   --------------
   counter33 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(33) <= '0';

         elsif tx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if tx_pause_frame = '1' then
             inc_vector(33) <= not inc_vector(33);
           end if;

         end if;
      end if;
   end process counter33;


  GEN_HALF_DUPLEX_COUNTERS : if C_HALFDUP = 1 generate
  begin
   
   -- Counter 34: "Single Collision Frames" increment request 
   --------------
   counter34 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(34) <= '0';

         elsif tx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if (tx_good_frame and single_attempt) = '1' then
             inc_vector(34) <= not inc_vector(34);
           end if;

         end if;
      end if;
   end process counter34;



   -- Counter 35: "Multiple Collision Frames" increment request 
   --------------
   counter35 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(35) <= '0';

         elsif tx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if (tx_good_frame and multiple_attempt) = '1' then
             inc_vector(35) <= not inc_vector(35);
           end if;

         end if;
      end if;
   end process counter35;



   -- Counter 36: "Frames with Deferred Transmissions" increment request 
   --------------
   counter36 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(36) <= '0';

         elsif tx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if (tx_good_frame and tx_deferred) = '1' then
             inc_vector(36) <= not inc_vector(36);
           end if;

         end if;
      end if;
   end process counter36;



   -- Counter 37: "Late Collisions" increment request 
   --------------
   counter37 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(37) <= '0';

         elsif tx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if tx_late_collision = '1' then
             inc_vector(37) <= not inc_vector(37);
           end if;

         end if;
      end if;
   end process counter37;



   -- Counter 38: "Frames Aborted due to Excess collisions"  
   -------------- increment request
   counter38 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(38) <= '0';

         elsif tx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if tx_excessive_collision = '1' then
             inc_vector(38) <= not inc_vector(38);
           end if;

         end if;
      end if;
   end process counter38;



   -- Counter 39: "Frames with Excess Deferral" increment request 
   --------------
   counter39 : process(tx_clk)
   begin
      if (tx_clk'event and tx_clk = '1') then

         if (tx_reset = '1') then
   	        inc_vector(39) <= '0';

         elsif tx_stats_valid_pipe = '1' then

           -- toggle whenever an update is required
           if tx_excessive_deferral = '1' then
             inc_vector(39) <= not inc_vector(39);
           end if;

         end if;
      end if;
   end process counter39;



   -- Counter 40: "Frames recieved with Alignment Errors"  
   -------------- increment request
   counter40 : process(rx_clk)
   begin
      if (rx_clk'event and rx_clk = '1') then

         if (rx_reset = '1') then
   	        inc_vector(40) <= '0';

         elsif rx_stats_valid_reg = '1' then

           -- toggle whenever an update is required
           if rx_alignment_error_reg = '1' and rx_0_63 = '0' then
             inc_vector(40) <= not inc_vector(40);
           end if;

         end if;
      end if;
   end process counter40;



   -- Unused statistics.  Please implement as required. 
     inc_vector(41 to C_NUM_STATS - 1) <= (others => '0');
   
   end generate GEN_HALF_DUPLEX_COUNTERS;

   ---------------------------------------------------------------------
   -- Output the increment request bits (routed to the Statistic core).
   ---------------------------------------------------------------------
   increment_vector <= inc_vector;


   

end rtl;
