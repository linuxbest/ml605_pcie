//----------------------------------------------------------------------
// Title      : IPIC Microprocessor Interface to MAC/Stats Host I/F
// Project    : tri_mode_eth_mac
//----------------------------------------------------------------------
// File       : axi_ethernet_v3_01_a_rx_axi_intf.v
// Author     : Xilinx, Inc.
//----------------------------------------------------------------------
// Description: Provides an interface between the AXI-S RX interface and
// the client interface. 
//
//----------------------------------------------------------------------
// (c) Copyright 2010 Xilinx, Inc. All rights reserved.
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


module axi_ethernet_v3_01_a_rx_axi_intf #
(
  // Number of Addresses for Address Filter
  parameter c_at_entries  = 8
)
(

  input                                rx_clk,
  input                                rx_reset,
  input                                rx_enable,
  
  //--------------------------------------------------------------------
  // Ethernet MAC RX Client Interface
  //--------------------------------------------------------------------

  input       [7:0]                    rx_data,
  input                                rx_data_valid,
  input                                rx_good_frame,
  input                                rx_bad_frame,
  
  //--------------------------------------------------------------------
  // Ethernet MAC RX Filter support
  //--------------------------------------------------------------------
  
  input       [c_at_entries:0]         rx_filter_match, 
  output reg  [c_at_entries:0]         rx_filter_tuser,
  
  //--------------------------------------------------------------------
  // AXI Interface
  //--------------------------------------------------------------------

  output reg  [7:0]                    rx_mac_tdata,
  output reg                           rx_mac_tvalid,
  output reg                           rx_mac_tlast,
  output reg                           rx_mac_tuser

);

reg   [7:0]                            rx_data_reg;
reg   [1:0]                            next_rx_state;
reg   [1:0]                            rx_state;

parameter         IDLE = 2'b00,
                  PKT  = 2'b01,
                  WAIT = 2'b10,
                  DONE = 2'b11;


// need to pipeline signals(twice?) to ensure the timing works
always @(posedge rx_clk)
begin
   if (rx_enable) begin
      rx_data_reg          <= rx_data;
   end
end

// use a simple state machine again..
always @(rx_state or rx_data_valid or rx_good_frame or rx_bad_frame)
begin
   next_rx_state           = rx_state;
   case (rx_state)
      IDLE : begin
         if (rx_data_valid)
            next_rx_state  = PKT;
      end
      PKT : begin
         if (rx_good_frame | rx_bad_frame) begin
            next_rx_state  = DONE;
         end
         else if (!rx_data_valid) begin
            next_rx_state  = WAIT;
         end
      end
      WAIT : begin
         // will sit in this state until get good/bad frame
         if (rx_good_frame | rx_bad_frame) begin
            next_rx_state  = DONE;
         end
         // this is an error condition - if no good/bad frame indication need to error
         // and allow next packet out correctly
         else if (rx_data_valid) begin
            next_rx_state = PKT;
         end
      end
      DONE : begin
         next_rx_state     = IDLE;
      end
      default : begin
      
      end
   endcase
end

always @(posedge rx_clk)
begin
   if (rx_reset) begin
      rx_state             <= 0;
   end
   else if (rx_enable) begin
      rx_state             <= next_rx_state;
   end
end


// generate the valid output - can use state == pkt OR done to generate
always @(posedge rx_clk)
begin
   if (rx_reset) begin
      rx_mac_tvalid        <= 0;
   end
   else begin
      if ((((rx_state == PKT | rx_state == WAIT) & next_rx_state == PKT) | next_rx_state == DONE) & rx_enable)
         rx_mac_tvalid     <= 1;
      else 
         rx_mac_tvalid     <= 0;
   end
end

// generate the tlast output
always @(posedge rx_clk)
begin
   if (rx_reset) begin
      rx_mac_tlast         <= 0;
   end
   else begin
      if ((next_rx_state == DONE | (rx_state == WAIT & next_rx_state == PKT)) & rx_enable)
         rx_mac_tlast      <= 1;
      else
         rx_mac_tlast      <= 0;
   end   
end


// generate the tuser output - only assert on tlast IF a bad frame
always @(posedge rx_clk)
begin
   if (rx_reset) begin
      rx_mac_tuser        <= 0;
   end
   else begin
      if ((next_rx_state == DONE | (rx_state == WAIT & next_rx_state == PKT)) & !rx_good_frame & rx_enable)
         rx_mac_tuser     <= 1;
      else
         rx_mac_tuser     <= 0;
   end
end

// finally output data
always @(posedge rx_clk)
begin
   if (rx_reset) begin
      rx_mac_tdata         <= 0;
   end
   else begin
      if (rx_state == PKT & rx_enable)
         rx_mac_tdata      <= rx_data_reg;
   end
end

// the address filter match values are entirely separate from the other axi signals but should have the 
// same timing as TUSER
// if no address filter then the output will be removed at the higher level so just drive the outputs low
// (the output width is based on c_at_entries which is always at least 0 giving a minimum of a single bit signal)
// equally if c_at_entries is 0 the output will be ignored at a higher level..
// should the per filter outputs be affected by flow control???

generate
if (c_at_entries != 0) begin

   // generate the filter tuser output - only assert on tlast IF filtered do not take value of 
   // good/bad frame into account
   always @(posedge rx_clk)
   begin
      if (rx_reset) begin
         rx_filter_tuser[c_at_entries-1:0]      <= 0;
      end
      else begin
         if ((next_rx_state == DONE | (rx_state == WAIT & next_rx_state == PKT)) & rx_enable)
            rx_filter_tuser[c_at_entries-1:0]   <= ~rx_filter_match[c_at_entries-1:0];
         else
            rx_filter_tuser[c_at_entries-1:0]   <= 0;
      end
   end

   // since the vector is one bigger than we want (to support setting c_at_entries to 0) we may as well do
   // something usefult with it...
   ///one possible use model of these outputs is to have a specific fifo use one of these to control which 
   // packet is rx'd, but we would want the main output to only assert if none of the filters match
   // put this logic into the extra bit - i.e this could replace the main mac_tuser output in this case
   always @(posedge rx_clk)
   begin
      if (rx_reset) begin
         rx_filter_tuser[c_at_entries]          <= 0;
      end
      else begin
         if ((next_rx_state == DONE | (rx_state == WAIT & next_rx_state == PKT)) & rx_good_frame & rx_enable)
            rx_filter_tuser[c_at_entries]       <= |rx_filter_match[c_at_entries-1:0];
      end
   end
   
end
else begin

   // drive all bits of tuser to 0
   always @(posedge rx_clk)
   begin
      if (rx_reset) begin
         rx_filter_tuser         <= 0;
      end
   end

end
endgenerate
endmodule
