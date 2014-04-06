//----------------------------------------------------------------------
// $Revision: 1.4 $
// $Date: 2010/09/15 14:20:34 $
//----------------------------------------------------------------------
// Title      : Configurable Address and Frame Filter
// Project    : Tri-Mode Ethernet MAC
//----------------------------------------------------------------------
// File       : axi_ethernet_v3_01_a_v6_address_filter.v
// Author     : Xilinx, Inc.
//----------------------------------------------------------------------
// Description: This describes the Address and Frame Filter for the
//              MAC receive path: a hard coded address (the Broadcast
//              Address) is included. Up to 64 bytes of the frame can be
//              compared for each filter, but the default mode of operation
//              is Destination Address comparison. In addition, a
//              parameratisable number of configurable individual filter
//              units are instantiated (currently set to eight).
//----------------------------------------------------------------------
// (c) Copyright 2007, 2008 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//----------------------------------------------------------------------

`timescale 1ps/1ps


module axi_ethernet_v3_01_a_v6_address_filter #
(
  // Number of Addresses for Address Filter
  parameter c_at_entries = 8,
  parameter c_has_host   = 1,
  parameter c_add_filter = 1,
  parameter c_unicast_pause_address = 0
)(
  // Clocks, clock enable and reset
  input                             rx_clk,
  input                             rx_clk_en,
  input                             rx_sync_reset,

  // Input packets (before address filter)
  input [7:0]                       rx_data,
  input                             rx_data_valid,
//input                             rx_frame_good,          // (Currently unused)
//input                             rx_frame_bad,           // (Currently unused)

  // Input addresses
  input                             promiscuous_mode,
  input [47:0]                      pause_addr,
  input                             update_pause_ad,

  // Output packets (only packets with a maching address)
  output wire [7:0]                 rx_filtered_data,   
  output reg                        rx_filtered_data_valid,
//output reg                        rx_filtered_frame_good, // (Currently unused)
//output reg                        rx_filtered_frame_bad,  // (Currently unused)

  // Address match signals
  output reg                        unicastaddressmatch,
  output reg                        broadcastaddressmatch,
  output reg                        pauseaddressmatch,
  output reg                        specialpauseaddressmatch,
  output reg                        rxstatsaddressmatch,
  input      [c_at_entries:0]       rx_filter_enable,
  output reg [c_at_entries:0]       rx_filter_match,

  // IPIC Interrface
  input                             bus2ip_clk,
  input                             bus2ip_reset,
  input                             bus2ip_sel_uc,
  input                             bus2ip_ce,
  input                             bus2ip_rdce,
  input                             bus2ip_wrce,
  output reg                        ip2bus_rdack,
  output reg                        ip2bus_wrack,
  input      [31:0]                 bus2ip_addr,
  input      [31:0]                 bus2ip_data,
  output reg [31:0]                 ip2bus_data,
  output                            ip2bus_error

);



  //--------------------------------------------------------------------
  // Internal signals used in this module
  //--------------------------------------------------------------------

  // Internal parameters
  localparam SPECIAL_PAUSE_ADDR = 48'h0180c2000001;

  integer            l;
  
  // Address recognition signals
  reg                rx_data_valid_reg1;
  reg                rx_data_valid_reg2;
  reg  [5:0]         counter;
  reg                counter_sat;
  reg                broadcast_byte_match;
  reg                broadcast_match;
  reg                broadcastaddressmatch_int;
  reg  [47:0]        pause_addr_shift;
  wire               pause_match_comb;
  reg                pause_match_reg;
  reg                pause_match;
  reg                pauseaddressmatch_int;
  wire [7:0]         special_pause_addr_lut;
  wire               special_pause_match_comb;
  reg                special_pause_match_reg;
  reg                special_pause_match;
  reg                specialpauseaddressmatch_int;
  wire [c_at_entries:0] configurable_match;
  reg  [c_at_entries:0] configurable_match_cap;
  reg                address_match;

  // RX client pipeline delay signals
  wire [7:0]         rx_data_srl16;           
  wire               rx_data_valid_srl16;
  wire [c_at_entries:0] rx_filter_match_srl16;
  reg                rx_data_valid_srl16_reg1;
  reg                rx_data_valid_srl16_reg2;

  // CPU access signals
  wire               promiscuous_mode_resync;
  reg                promiscuous_mode_sample;
  reg  [31:0]        cpu_data_shift;
  reg  [5:0]         ram_addr;
  reg  [c_at_entries:0] ram_field_wr;
  reg  [c_at_entries:0] ram_compare_wr;
  reg                ram_rd;
  reg                ram_rd_reg;
  reg                ram_access;
  reg                ram_access_reg;
  wire [7:0]         ram_rd_field_data [c_at_entries:0];
  wire [7:0]         ram_rd_compare_data [c_at_entries:0];
  reg  [7:0]         ram_rd_byte;
  wire               default_match;
  
  reg                ram_field_wr_uc;
  wire [7:0]         uc_ram_data;
  wire               unicast_match;
  reg                unicast_match_cap;

  reg [2:0] load_count;
  reg [2:0] load_count_pipe;
  reg       load_wr;
  reg [7:0] load_wr_data;
  wire [7:0] expected_pause_data;
  reg       update_pause_ad_sync_reg;
  wire      update_pause_ad_sync;




  // code to handle case where AF_entries is 0..
  // all the configurable width registers/wires are 1 bigger than required 
  // (to make the parameters easier) so need to handle the other bit - this
  // has the benefit of also handling the case where no filters are expected
  generate
  if (c_add_filter == 0) begin
     assign default_match = 1;
  end 
  else begin
     assign default_match = promiscuous_mode_sample;
  end
  endgenerate

  assign rx_filtered_data = rx_data_srl16;
  
  //--------------------------------------------------------------------
  // Counter for MAC header field recognition
  //--------------------------------------------------------------------


  // Create a counter which counts up at the start of frame reception.
  // This can be used to identify the MAC header fields.

  always @(posedge rx_clk)
  begin
    if (rx_sync_reset) begin
      rx_data_valid_reg1 <= 1'b0;
      rx_data_valid_reg2 <= 1'b0;
      counter            <= 6'b0;
      counter_sat        <= 1'b0;
    end

    else if (rx_clk_en) begin

      rx_data_valid_reg1 <= rx_data_valid;
      rx_data_valid_reg2 <= rx_data_valid_reg1;

      // Clear counter at the end of each frame
      if (!rx_data_valid & rx_data_valid_reg1) begin
        counter     <= 6'b0;
        counter_sat <= 1'b0;
      end

      // During the frame, increment counter until it counts 64 bytes.
      // Once it has saturated, set a flag which is used for edge detect.
      else if (rx_data_valid) begin
        if (counter != 6'b111111)
          counter <= counter + 1'b1;
        else
          counter_sat <= 1'b1;
      end
    end
  end



  //--------------------------------------------------------------------
  // Broadcast Address recognition
  //--------------------------------------------------------------------


  // Create an 8-bit combinatorial comparator to compare the received
  // byte with 0xFF. This comparison will only be used during the DA.

  always @(posedge rx_clk)
  begin
    if (rx_sync_reset) begin
      broadcast_byte_match <= 1'b0;
    end

    else if (rx_clk_en) begin

      if (rx_data == 8'hFF) begin
        broadcast_byte_match <= 1'b1;
      end

      else begin
        broadcast_byte_match <= 1'b0;
      end

    end
  end


  // Continue Broadcast Address match. If 1st byte matches, set broadcast_match
  // signal to 1. Set to 0 if any successive byte does not match.

  always @(posedge rx_clk)
  begin
    if (rx_sync_reset) begin
      broadcast_match <= 1'b0;
    end

    else if (rx_clk_en) begin

      // The current byte of the frame matches the Broadcast Address
      if (broadcast_byte_match) begin

        // 1st byte of DA: set to 1 if there is a match
        if (rx_data_valid_reg1 & !rx_data_valid_reg2) begin
          broadcast_match <= 1'b1;
        end
      end

      // If no match, set to 0
      else begin
        broadcast_match <= 1'b0;
      end

    end
  end


  // Complete the Broadcast Address match logic by sampling the
  // broadcast_match signal at the end of the DA field. This will be
  // held for the entire frame.

  always @(posedge rx_clk)
  begin
    if (rx_sync_reset) begin
      broadcastaddressmatch_int <= 1'b0;
      broadcastaddressmatch     <= 1'b0;
    end

    else if (rx_clk_en) begin

      // Reset at beginning of frame
      if (rx_data_valid_reg1 & !rx_data_valid_reg2) begin
        broadcastaddressmatch_int <= 1'b0;
      end

      // Sample after reception of DA field
      else if (counter == 6'b000111) begin
        broadcastaddressmatch_int <= broadcast_match;
      end

      // Extra pipeline stage for alignment
      broadcastaddressmatch <= broadcastaddressmatch_int;

    end
  end



  //--------------------------------------------------------------------
  // Unicast Address recognition
  //--------------------------------------------------------------------

  generate
  if (c_has_host == 1) begin : addr_regs

     axi_ethernet_v3_01_a_v6_address_compare unicast_address_compare
     (
       .cpu_clk             (bus2ip_clk),
       .cpu_reset           (bus2ip_reset),
       .cpu_field_wr        (ram_field_wr_uc),
       .cpu_compare_wr      (1'b0),
       .cpu_addr            ({2'b00, ram_addr[3:0]}),
       .cpu_wr_data         (cpu_data_shift[7:0]),
       .cpu_rd_field_data   (uc_ram_data),
       .cpu_rd_compare_data (),

       .rx_clk              (rx_clk),
       .rx_reset            (rx_sync_reset),
       .rx_clk_en           (rx_clk_en),
       .rx_data             (rx_data),
       .rx_data_valid_reg1  (rx_data_valid_reg1),
       .rx_data_valid_reg2  (rx_data_valid_reg2),
       .rx_addr             (counter),

       .enable_comparison   (1'b1),
       .match               (unicast_match)
     );

     // Because the filters are 64 bytes, capture their match bit on
     // the 64th frame byte and retain it for the rest of the frame.
     always @(posedge rx_clk)
     begin
       if (rx_sync_reset) begin
         unicastaddressmatch <= 1'b0;
         unicast_match_cap <= 1'b0;
       end

       else if (rx_clk_en) begin

         // Reset at beginning of frame
         if (rx_data_valid_reg1 & !rx_data_valid_reg2) begin
           unicast_match_cap <= 1'b0;
         end

         // Capture the unicast_match bit until the counter
         // has saturated, then retain this value until the frame ends.
         else if (rx_data_valid) begin
           if (counter == 6'b000111) begin
             unicast_match_cap <= unicast_match;
           end
         end

         // Extra pipeline stage for alignment
         unicastaddressmatch <= unicast_match_cap;

       end
     end

  end
  else begin
     
     // when no management interface the unicast and rx_pause source are
     // tied to the same value therefore the filter outputs are the same
     always @(pause_match or pauseaddressmatch)
     begin
        unicastaddressmatch = pauseaddressmatch;
     end
     
     assign unicast_match = pause_match;
     
  end
  endgenerate

  //--------------------------------------------------------------------
  // Pause Address recognition
  //--------------------------------------------------------------------

  axi_ethernet_v3_01_a_sync_block sync_update (
    .clk             (rx_clk),
    .data_in         (update_pause_ad),
    .data_out        (update_pause_ad_sync)
  );

  always @(posedge rx_clk)
  begin
     if (!rx_data_valid)
        update_pause_ad_sync_reg <= update_pause_ad_sync;
  end
  
  // generate a count to 6 starting upon 
  always @(posedge rx_clk)
  begin
     if (rx_sync_reset) begin
        load_count       <= 0;
        load_count_pipe  <= 0;
        load_wr          <= 0;
     end
     else if ((update_pause_ad_sync_reg ^ update_pause_ad_sync) & !rx_data_valid) begin
        load_count       <= 0;
        load_count_pipe  <= 0;
        load_wr          <= 0;
     end
     else begin
        if (load_count < 5) begin
           load_count    <= load_count + 1;
        end
        else begin
           load_count    <= load_count;
        end
        load_count_pipe  <= load_count;
        load_wr          <= (load_count_pipe < 5);
     end
  end

  // select the appropriate byte from the pause address
  // with the 6LUT this should be done in 8 luts 
  always @(posedge rx_clk)
  begin
     case (load_count)
        0 : load_wr_data <= pause_addr[7:0];
        1 : load_wr_data <= pause_addr[15:8];
        2 : load_wr_data <= pause_addr[23:16];
        3 : load_wr_data <= pause_addr[31:24];
        4 : load_wr_data <= pause_addr[39:32];
        5 : load_wr_data <= pause_addr[47:40];
        default :load_wr_data <= pause_addr[7:0];
     endcase
  end

  genvar g;
  generate for (g=0; g<8; g=g+1)
    begin : byte_wide_ram

      RAM64X1D header_field_dist_ram (
        .D          (load_wr_data[g]),
        .WE         (load_wr),
        .WCLK       (rx_clk),

        .A0         (load_count_pipe[0]),
        .A1         (load_count_pipe[1]),
        .A2         (load_count_pipe[2]),
        .A3         (1'b0),
        .A4         (1'b0),
        .A5         (1'b0),
        .SPO        (),

        .DPRA0      (counter[0]),
        .DPRA1      (counter[1]),
        .DPRA2      (counter[2]),
        .DPRA3      (counter[3]),
        .DPRA4      (counter[4]),
        .DPRA5      (counter[5]),
        .DPO        (expected_pause_data[g])
      );

    end
  endgenerate

  always @(posedge rx_clk)
  begin
    if (rx_sync_reset) begin
      pause_match_reg <= 1'b0;
      pause_match     <= 1'b0;
    end

    else if (rx_clk_en) begin

      // Register the combinatorial comparator for pipeline alignment
      pause_match_reg <= (rx_data == expected_pause_data[7:0]);

      // The current byte of DA matches the Pause Address
      if (pause_match_reg) begin

        // 1st byte of DA: set to 1 if there is a match
        if (rx_data_valid_reg1 & !rx_data_valid_reg2) begin
          pause_match <= 1'b1;
        end
      end

      // If no match, set to 0
      else begin
        pause_match <= 1'b0;
      end

    end
  end

  // Complete the Pause Address match logic by sampling the
  // pause_match signal at the end of the DA field. This will be
  // held for the entire frame.

  always @(posedge rx_clk)
  begin
    if (rx_sync_reset) begin
      pauseaddressmatch_int <= 1'b0;
      pauseaddressmatch     <= 1'b0;
    end

    else if (rx_clk_en) begin

      // Reset at beginning of frame
      if (rx_data_valid_reg1 & !rx_data_valid_reg2) begin
        pauseaddressmatch_int <= 1'b0;
      end

      // Sample after reception of DA field
      else if (counter == 6'b000111) begin
        pauseaddressmatch_int <= pause_match;
      end

      // Extra pipeline stage for alignment
      pauseaddressmatch <= pauseaddressmatch_int;

    end
  end



  //--------------------------------------------------------------------
  // Special Multicast Pause Address recognition
  //--------------------------------------------------------------------


  // Since the Special Pause Address is a static value, use LUT memory to
  // store and read it out according to the counter value.

  genvar y;
  generate
  for (y=0; y<=7; y=y+1) begin : special_pause_address

    LUT3 #(
      .INIT ({2'b00,
              SPECIAL_PAUSE_ADDR[y],
              SPECIAL_PAUSE_ADDR[y+8],
              SPECIAL_PAUSE_ADDR[y+16],
              SPECIAL_PAUSE_ADDR[y+24],
              SPECIAL_PAUSE_ADDR[y+32],
              SPECIAL_PAUSE_ADDR[y+40]})
    ) LUT3_special_pause_inst (
       .O     (special_pause_addr_lut[y]),
       .I0    (counter[0]),
       .I1    (counter[1]),
       .I2    (counter[2])
    );

  end
  endgenerate


  // Create an 8-bit combinatorial comparator to compare the received
  // byte from the DA field with shifted special pause address byte.

  assign special_pause_match_comb = (rx_data == special_pause_addr_lut[7:0]);


  // Continue Special Pause Address match. If 1st byte matches, set
  // special_pause_match signal to 1. Set to 0 if any successive byte
  // does not match.

  always @(posedge rx_clk)
  begin
    if (rx_sync_reset) begin
      special_pause_match_reg <= 1'b0;
      special_pause_match     <= 1'b0;
    end

    else if (rx_clk_en) begin

      // Register the combinatorial comparator for pipeline alignment
      special_pause_match_reg <= special_pause_match_comb;

      // The current byte of DA matches the Special Pause Address
      if (special_pause_match_reg) begin

        // 1st byte of DA: set to 1 if there is a match
        if (rx_data_valid_reg1 & !rx_data_valid_reg2) begin
          special_pause_match <= 1'b1;
        end
      end

      // If no match, set to 0
      else begin
        special_pause_match <= 1'b0;
      end

    end
  end


  // Complete the Special Pause Address match logic by sampling the
  // special_pause_match signal at the end of the DA field. This will be
  // held for the entire frame.

  always @(posedge rx_clk)
  begin
    if (rx_sync_reset) begin
      specialpauseaddressmatch_int <= 1'b0;
      specialpauseaddressmatch     <= 1'b0;
    end

    else if (rx_clk_en) begin

      // Reset at beginning of frame
      if (rx_data_valid_reg1 & !rx_data_valid_reg2) begin
        specialpauseaddressmatch_int <= 1'b0;
      end

      // Sample after reception of DA field
      else if (counter == 6'b000111) begin
        specialpauseaddressmatch_int <= special_pause_match;
      end

      // Extra pipeline stage for alignment
      specialpauseaddressmatch <= specialpauseaddressmatch_int;

    end
  end



  //--------------------------------------------------------------------
  // Configurable filter recognition
  //--------------------------------------------------------------------


  // Instantiate a Distributed RAM based filter element for the
  // configurable pattern and mask values.

  genvar i;
  generate
  if (c_add_filter == 1 && c_has_host == 1) begin
     for (i=0; i<c_at_entries; i=i+1) begin : address_filters

       axi_ethernet_v3_01_a_v6_address_compare configurable_addresses
       (
         .cpu_clk             (bus2ip_clk),
         .cpu_reset           (bus2ip_reset),
         .cpu_field_wr        (ram_field_wr[i]),
         .cpu_compare_wr      (ram_compare_wr[i]),
         .cpu_addr            (ram_addr),
         .cpu_wr_data         (cpu_data_shift[7:0]),
         .cpu_rd_field_data   (ram_rd_field_data[i]),
         .cpu_rd_compare_data (ram_rd_compare_data[i]),

         .rx_clk              (rx_clk),
         .rx_reset            (rx_sync_reset),
         .rx_clk_en           (rx_clk_en),
         .rx_data             (rx_data),
         .rx_data_valid_reg1  (rx_data_valid_reg1),
         .rx_data_valid_reg2  (rx_data_valid_reg2),
         .rx_addr             (counter),

         .enable_comparison   (rx_filter_enable[i]),
         .match               (configurable_match[i])
       );

       // Because the filters are 64 bytes, capture their match bit on
       // the 64th frame byte and retain it for the rest of the frame.
       always @(posedge rx_clk)
       begin
         if (rx_sync_reset) begin
           configurable_match_cap[i] <= 1'b0;
         end

         else if (rx_clk_en) begin

           // Reset at beginning of frame
           if (rx_data_valid & !rx_data_valid_reg1) begin
             configurable_match_cap[i] <= 1'b0;
           end

           // Capture the configurable_match[i] but until the counter
           // has saturated, then retain this value until the frame ends.
           else if (rx_data_valid) begin
             if ((counter != 6'b111111) | !counter_sat) begin
               configurable_match_cap[i] <= configurable_match[i];
             end
           end

         end
       end

     end
  end
  endgenerate

  // handle 0 case - the match register is one bit bigger than defined with the upper bit
  // tied tothe default match value - when promiscuous mode is used this bit is set and the 
  // filter results are ignored.  when no address filter this is forced high - if an address filter
  // but AT entries is zero we want to only use the da match bits
  assign configurable_match[c_at_entries] = default_match;
  assign ram_rd_compare_data[c_at_entries] = 0;
  assign ram_rd_field_data[c_at_entries] = 0;
  
  always @(posedge rx_clk)
  begin
      configurable_match_cap[c_at_entries] <= default_match;
  end

  //--------------------------------------------------------------------
  // Combine DA recognition signals
  //--------------------------------------------------------------------


  always @(posedge rx_clk)
  begin
    if (rx_sync_reset) begin
      address_match <= 1'b0;
    end

    else if (rx_clk_en) begin

      // reset at beginning of frame
      if (rx_data_valid_reg1 & !rx_data_valid_reg2) begin
        address_match <= 1'b0;
      end

      // sample after reception of DA
      else if (counter == 6'b000111) begin
        address_match <= broadcast_match     |
                         unicast_match       |
                         pause_match         |
                         special_pause_match |
                         (|configurable_match);
      end

    end
  end



  //--------------------------------------------------------------------
  // Run RX interface through a delay line for 5 clock
  // cycles (the length of the DA field - 1) using SRL16's
  //--------------------------------------------------------------------


  // Delay the rx_data
  generate
  genvar j;
  for (j=0; j<8; j=j+1) begin : delay_data

    SRLC16E delay_rx_data (
      .Q     (rx_data_srl16[j]),
      .Q15   (),
      .A0    (1'b0),
      .A1    (1'b0),
      .A2    (1'b0),
      .A3    (1'b1),
      .CE    (rx_clk_en),
      .CLK   (rx_clk),
      .D     (rx_data[j])
    );

  end
  endgenerate 

  // Delay the rx_data_valid
  SRLC16E delay_rx_data_valid (
    .Q     (rx_data_valid_srl16),
    .Q15   (),
    .A0    (1'b1),
    .A1    (1'b0),
    .A2    (1'b1),
    .A3    (1'b0),
    .CE    (rx_clk_en),
    .CLK   (rx_clk),
    .D     (rx_data_valid)
  );



  // Add a register to each SRL16 output
  always @(posedge rx_clk)
  begin
    if (rx_sync_reset) begin
      rx_data_valid_srl16_reg1 <= 1'b0;
      rx_data_valid_srl16_reg2 <= 1'b0;
    end

    else if (rx_clk_en) begin
      rx_data_valid_srl16_reg1 <= rx_data_valid_srl16;
      rx_data_valid_srl16_reg2 <= rx_data_valid_srl16_reg1;
    end
  end


  // Delay the configurable_match_cap[x] outputs to create
  // individual match indications
  generate
  genvar x;
  if (c_add_filter == 1 && c_has_host == 1) begin
     for (x=0; x<c_at_entries; x=x+1) begin : match_filters

       SRLC16E delay_configurable_match (
         .Q     (rx_filter_match_srl16[x]),
         .Q15   (),
         .A0    (1'b0),
         .A1    (1'b1),
         .A2    (1'b1),
         .A3    (1'b0),
         .CE    (rx_clk_en),
         .CLK   (rx_clk),
         .D     (configurable_match_cap[x])
       );

       // Add a register to the SRL16 output.
       always @(posedge rx_clk)
       begin
         if (rx_sync_reset) begin
           rx_filter_match[x] <= 1'b0;
         end

         else if (rx_clk_en) begin
           rx_filter_match[x] <= rx_filter_match_srl16[x];
         end
       end

     end
  end
  endgenerate

  // handle 0 case
  assign rx_filter_match_srl16[c_at_entries] = default_match;
  always @(posedge rx_clk)
  begin
     rx_filter_match[c_at_entries] <= default_match;
  end

  //--------------------------------------------------------------------
  // Perform the filtering
  //--------------------------------------------------------------------


  // Resynchronise promiscuous mode setting into rx_clk domain
  axi_ethernet_v3_01_a_sync_block resync_promiscuous_mode
  (
    .clk       (rx_clk),
    .data_in   (promiscuous_mode),
    .data_out  (promiscuous_mode_resync)
  );


  // Sample promiscuous mode setting at beginning of frame
  always @(posedge rx_clk)
  begin
    if (rx_sync_reset) begin
      promiscuous_mode_sample <= 1'b1;
    end

    else if (rx_clk_en) begin

      if (rx_data_valid_reg1 & !rx_data_valid_reg2) begin
        promiscuous_mode_sample <= promiscuous_mode_resync;
      end

    end
  end


  // Perform the filtering
  // if no address filter then address_match will be 1 (due to default_match)
  // otherwise a match has to happen (or be in promiscous mode)
  always @(posedge rx_clk)
  begin
    if (rx_sync_reset) begin
      rx_filtered_data_valid <= 1'b0;
    end

    else if (rx_clk_en) begin
      rx_filtered_data_valid <= (promiscuous_mode_sample | address_match) &
                                rx_data_valid_srl16_reg2;
    end
  end


  // The statistics address match signal is set by filtered data valid and
  // reset at the beginning of each frame
  always @(posedge rx_clk)
  begin
    if (rx_sync_reset) begin
       rxstatsaddressmatch <= 1'b0;
    end
    else if (rx_clk_en) begin

       // JK, 28-July-2010: The reset condition needs to happen later than the
       // beginning of the subsequent frame in order to handle short IFGs on the
       // RX GMII. In the IFG is very short, the reset can happen before stats valid
       // on the previous frame. See 7/28/2010 notes in IR 56307.
       //WAS: if (rx_data_valid & !rx_data_valid_reg1) begin
       if (rx_data_valid_srl16 & !rx_data_valid_srl16_reg1) begin
         rxstatsaddressmatch <= 1'b0;
       end
       else if (rx_filtered_data_valid) begin
         rxstatsaddressmatch <= 1'b1;
       end

    end
  end


  //--------------------------------------------------------------------
  // IPIC logic for filter write
  //--------------------------------------------------------------------


  // Capture IPIC data on a write, and shift it four times for four bytes
  always @(posedge bus2ip_clk)
  begin
    if (bus2ip_reset) begin
      cpu_data_shift <= 32'b0;
    end

    else if ((bus2ip_ce | bus2ip_sel_uc) & bus2ip_wrce) begin
      cpu_data_shift <= bus2ip_data;
    end

    else if (ram_addr[1:0] != 2'b11) begin
      cpu_data_shift <= {8'b0, cpu_data_shift[31:8]};
    end

  end


  // Lower 2 bits of Distributed RAM address form a counter and count from 0
  // to 3 on any access, addressing the captured IPIC word over 4 cycles
  always @(posedge bus2ip_clk)
  begin
    if (bus2ip_reset) begin
      ram_addr[1:0] <= 2'b11;
    end

    else if ((bus2ip_ce | bus2ip_sel_uc) & (bus2ip_wrce | bus2ip_rdce)) begin
      ram_addr[1:0] <= 2'b00;
    end

    else if (ram_addr[1:0] != 2'b11) begin
      ram_addr[1:0] <= ram_addr[1:0] + 2'b01;
    end

  end


  // Upper 4 bits of Distributed RAM are used as an offset for the captured
  // IPIC word, addressing each word to one of 16 sets of addresses (16x4=64)
  always @(posedge bus2ip_clk)
  begin
    if (bus2ip_reset) begin
      ram_addr[5:2] <= 4'b0000;
    end

    else if ((bus2ip_ce | bus2ip_sel_uc) & (bus2ip_wrce | bus2ip_rdce)) begin
      ram_addr[5:2] <= bus2ip_addr[5:2];
    end

  end

  // create the write strobe for the unicast filter
  always @(posedge bus2ip_clk)
  begin
    if (bus2ip_reset) begin
      ram_field_wr_uc <= 1'b0;
    end

    else if (bus2ip_sel_uc & bus2ip_wrce) begin
      ram_field_wr_uc <= 1'b1;
    end

    else if (ram_addr[1:0] == 2'b11) begin
      ram_field_wr_uc <= 1'b0;
    end
  end

  genvar k;
  generate   
  if (c_add_filter == 1 && c_has_host == 1) begin
     for (k=0; k<c_at_entries; k=k+1) begin : write_strobes

        // Create the Distributed write strobe for the MAC Header Field Filter:
        // there is a unique write strobe per Address Filter (per distributed RAM).
        always @(posedge bus2ip_clk)
        begin
          if (bus2ip_reset) begin
            ram_field_wr[k] <= 1'b0;
          end

          else if (bus2ip_ce & bus2ip_wrce) begin
            if (bus2ip_addr[13:6] == (2 * k)) begin
              ram_field_wr[k] <= 1'b1;
            end
          end

          else if (ram_addr[1:0] == 2'b11) begin
            ram_field_wr[k] <= 1'b0;
          end
        end


        // Create the Distributed write strobe for the Compare Filter:
        // there is a unique write strobe per Address Filter (per distributed RAM).
        always @(posedge bus2ip_clk)
        begin
          if (bus2ip_reset) begin
            ram_compare_wr[k] <= 1'b0;
          end

          else if (bus2ip_ce & bus2ip_wrce) begin
            if (bus2ip_addr[13:6] == ((2 * k)+1)) begin
              ram_compare_wr[k] <= 1'b1;
            end
          end

          else if (ram_addr[1:0] == 2'b11) begin
            ram_compare_wr[k] <= 1'b0;
          end
        end

      end
  end
  endgenerate

  // handle 0 case (i.e no address filteres requested)
  always @(posedge bus2ip_clk)
  begin
      ram_field_wr[c_at_entries]   <= 1'b0;
      ram_compare_wr[c_at_entries] <= 1'b0;
  end

  // Create the Distributed Memory read strobe.
  always @(posedge bus2ip_clk)
  begin
    if (bus2ip_reset) begin
      ram_rd     <= 1'b0;
      ram_access <= 1'b0;
    end

    else if ((bus2ip_ce | bus2ip_sel_uc) & (bus2ip_wrce | bus2ip_rdce)) begin
      ram_rd     <= bus2ip_rdce;
      ram_access <= 1'b1;
    end

    else if (ram_addr[1:0] == 2'b11) begin
      ram_rd     <= 1'b0;
      ram_access <= 1'b0;
    end

  end


  // Multiplex data from the correct Dist RAM for IPIC read.

  always @(posedge bus2ip_clk)
  begin
    ram_rd_byte <= 0;
    if (bus2ip_sel_uc)
       ram_rd_byte <= uc_ram_data;
    else begin
       for (l=0; l<c_at_entries; l=l+1) begin
         if (bus2ip_addr[6]) begin
            if (bus2ip_addr[13:7] == l) begin
              ram_rd_byte <= ram_rd_compare_data[l];
            end
         end
         else begin
            if (bus2ip_addr[13:7] == l) begin
              ram_rd_byte <= ram_rd_field_data[l];
            end
         end
       end
    end
  end


  // Create the IPIC read data bus
  always @(posedge bus2ip_clk)
  begin

    ram_rd_reg <= ram_rd;

    if (ram_rd_reg) begin
      ip2bus_data <= {ram_rd_byte, ip2bus_data[31:8]};
    end

    else begin
      ip2bus_data <= 32'b0;
    end

  end


  // Create the IPIC acknowledges
  always @(posedge bus2ip_clk)
  begin
    if (bus2ip_reset) begin
      ram_access_reg <= 1'b0;
      ip2bus_rdack   <= 1'b0;
      ip2bus_wrack   <= 1'b0;
    end

    else begin
      ram_access_reg <= ram_access;
      ip2bus_rdack   <= (!ram_access & ram_access_reg &  ram_rd_reg);
      ip2bus_wrack   <= (!ram_access & ram_access_reg & !ram_rd_reg);
    end

  end


  // Tie error low as there are no current error conditions
  assign ip2bus_error = 1'b0;


endmodule
