//----------------------------------------------------------------------
// Title      : IPIC Microprocessor Interface to MAC/Stats Host I/F
// Project    : tri_mode_eth_mac
//----------------------------------------------------------------------
// File       : axi_ethernet_v3_01_a_tx_axi_intf.v
// Author     : Xilinx, Inc.
//----------------------------------------------------------------------
// Description: Provides an interface between the AXI-S TX interface and
// the client interface.  Updating the tx statemachine etc is to be avoided
// in the short term...
//
// TDATA is a direct match to tx_data
// TVALID should always be high if TREADY is high (class as an error - 
// may be able to remove tuser using this method - currently classed as UNDERRUN
// TLAST will assert on the final byte of a packet - if TVALID is high on 
// following cycle this is a  busrt continuation (translate to data_valid
// being low for a cycle.  TREADY is actively controlled to perform rate adjustment
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


module axi_ethernet_v3_01_a_tx_axi_intf 
(

  input                                tx_clk,
  input                                tx_reset,
  input                                tx_enable,
  
  //--------------------------------------------------------------------
  // AXI Interface
  //--------------------------------------------------------------------

  input       [7:0]                    tx_mac_tdata,
  input                                tx_mac_tvalid,
  input                                tx_mac_tlast,
  input                                tx_mac_tuser,
  output                               tx_mac_tready,

  //--------------------------------------------------------------------
  // Ethernet MAC TX Client Interface
  //--------------------------------------------------------------------

  output                               tx_enable_out,
  output reg                           tx_continuation,
  output reg  [7:0]                    tx_data,
  output reg                           tx_data_valid,
  output reg                           tx_underrun,
  input                                tx_ack
  
);

parameter         IDLE       = 4'h0,
                  LOAD1      = 4'h1,
                  LOAD2      = 4'h2,
                  WAIT       = 4'h3,
                  CLEAR_PIPE = 4'h4,
                  RELOAD1    = 4'h5,
                  RELOAD2    = 4'h6,
                  SEND       = 4'h7,
                  BURST      = 4'h8;

reg      [3:0]                         tx_state;
reg      [3:0]                         next_tx_state;
reg                                    early_deassert;
reg                                    force_assert;
reg                                    two_byte_tx;
reg      [7:0]                         tx_data_hold;
reg                                    tx_mac_tready_reg;
reg                                    ignore_packet;
reg                                    early_underrun;
reg                                    tlast_reg;
reg                                    force_burst1;
reg                                    force_burst2;
reg                                    tx_enable_reg;
reg                                    tx_mac_tready_int;
reg                                    no_burst;
reg                                    gate_tready;

assign tx_enable_out = tx_enable_reg;
assign tx_mac_tready = tx_mac_tready_int;

// the tx_enable input is used to generate the tx_ready and passed to the client logic
// from a timing persepctive new data is expected on the following cycle this implies
// that either enable is renamed as valid (not ideal as other logic is required) OR
// everything is pipeplined to enable tready to be flopped (do this..)
always @(posedge tx_clk)
begin
   tx_enable_reg     <= tx_enable;
end

// tx_continuation simply indicates that the tx path has data available immediately
// this is only used when connected to the avb endpoint.  Assume this doesn't care 
// about errors or underrun ONLY data availability.  NOTE AXI-S must drop tvalid
// if no data is available so this should be safe.
always @(posedge tx_clk)
begin
   tx_continuation <= tx_mac_tvalid;
end

// transaction state machine
// once tvalid has been asserted it is classed as being the same transaction unless a reset
// or a tlast is asserted - i.e if tuser is asserted to indicate an error it will be 
// output as an error but will not restart the state machine.
always @(tx_state or tx_mac_tvalid or tx_mac_tuser or tx_mac_tlast or tx_ack or two_byte_tx or
         tx_enable_reg or tx_mac_tready_int or ignore_packet or no_burst or early_deassert)
begin
   next_tx_state = tx_state;
   case (tx_state)
      IDLE : begin
         if (tx_mac_tvalid & !tx_mac_tuser & !ignore_packet & !no_burst & tx_enable_reg) begin
            next_tx_state = LOAD1;
         end
      end
      LOAD1 : begin
         // this state will pass the tx_valid to the mac and will preload the pipeline
         // need 3 data values (2 cycles) - if a retransmit occurs then the TLAST will
         // be asserted and SM should move to the RELOAD state
         if (tx_mac_tlast & tx_mac_tuser) begin
            next_tx_state = CLEAR_PIPE;
         end
         else begin
            next_tx_state = LOAD2;
         end
      end
      LOAD2 : begin
         if (tx_mac_tlast & tx_mac_tuser) begin
            next_tx_state = CLEAR_PIPE;
         end
         else begin
            next_tx_state = WAIT;
         end
      end
      WAIT : begin
         // if TLAST is seen in this state then need to assert TREADY and move to RELOAD
         // otherwise sit and wait for the ack
         if (tx_mac_tlast & tx_mac_tuser) begin
            next_tx_state = CLEAR_PIPE;
         end
         else if (tx_ack & tx_enable_reg) begin
            next_tx_state = SEND;
         end
      end
      CLEAR_PIPE : begin
         if (tx_mac_tvalid) begin
            next_tx_state = RELOAD1;
         end
         else if (tx_ack & tx_enable_reg) begin
            next_tx_state = IDLE;
         end
      end
      RELOAD1 : begin
         // don't allow tlast in this state?? can't think of any reason why we would want to 
         //need to consider tvalid being low?? monitor and error??
         // only move on once tlast has been deasserted
         if (tx_mac_tvalid)
            next_tx_state = RELOAD2;
         else if (tx_ack & tx_enable_reg)
            next_tx_state = IDLE;
      end
      RELOAD2: begin
         if (tx_ack & tx_enable_reg) begin
            next_tx_state = SEND;
         end
         else begin
            next_tx_state = WAIT;
         end
      end
      SEND : begin
         // stay in this state until tlast is asserted
         if ((tx_mac_tlast & tx_mac_tready_int) | early_deassert | two_byte_tx)
            next_tx_state = BURST;
      end
      BURST : begin
         if (tx_enable_reg) begin
            next_tx_state = IDLE;
         end
      end
      default : begin
         next_tx_state = IDLE;
      end
   endcase   
end

always @(posedge tx_clk)
begin
   if (tx_reset) begin
      tx_state <= IDLE;
   end
   else begin
      tx_state <= next_tx_state;
   end
end

always @(posedge tx_clk)
begin
   if (tx_reset) begin
      ignore_packet <= 0;
   end
   else begin
      if (tx_state == IDLE & tx_mac_tvalid & tx_mac_tuser)
         ignore_packet <= 1;
      else if (tx_mac_tlast | !tx_mac_tvalid)
         ignore_packet <= 0;
   end
end


// generate data_valid - this should be asserted if next state == load, deasserted if state == burst
// OR if ack arrives during reload and underrun has been asserted
always @(posedge tx_clk)
begin
   if (tx_reset) begin
      tx_data_valid <= 0;
   end
   else begin
      if (next_tx_state == LOAD1 | (force_assert & tx_enable_reg)) begin
         tx_data_valid <= 1;
      end
      else if ((next_tx_state == IDLE & tx_enable_reg) | 
               (early_deassert & tx_ack & tx_enable_reg) |
               ((tx_state == SEND) & two_byte_tx & tx_enable_reg)) begin
         tx_data_valid <= 0;
      end
   end
end

// generate the tx_underrun signal
// simple underrun is decoded from usert OR if valid is deasserted when ready is asserted
// also have to detect and handle the case where a reload of the pipe is attempted too close
// to the reception of ACK (which isn't available to the user) - in this case the need
// for an underrun is captured and it is asserted after the ack has been removed - a new 
// packet is then immediately requested (if valid is high)
always @(posedge tx_clk)
begin
   if (tx_reset) begin
      tx_underrun <= 0;
      early_underrun <= 0;
   end
   else begin
      if (tx_mac_tready_int & tx_mac_tuser & tx_state != SEND & tx_state != IDLE)
         early_underrun <= 1;
      else if ((tx_ack & tx_enable_reg) | tx_state == RELOAD2)
         early_underrun <= 0;
      if ((tx_mac_tready_int & (!tx_mac_tvalid | tx_mac_tuser) & tx_state == SEND) |
         (tx_ack & tx_enable_reg & early_underrun & tx_state != RELOAD2))
         tx_underrun <= 1;
      else if (tx_enable_reg)
         tx_underrun <= 0;
   end
end

always @(posedge tx_clk)
begin
   if (tx_reset) begin
      early_deassert <= 0;
   end
   else begin
      // deassert data_valid if axi completes before ack - if a reload 
      // occurs automatically reassert
      if (tx_state != SEND & tx_state  != IDLE & tx_mac_tready_int & 
          tx_mac_tvalid & tx_mac_tlast) begin
         early_deassert <= 1;
      end
      else if ((!tx_data_valid & tx_enable_reg) | (next_tx_state == RELOAD2) |
               two_byte_tx) begin
         early_deassert <= 0;
      end
   end
end

always @(posedge tx_clk)
begin
   if (tx_reset) begin
      force_assert <= 0;
   end
   else begin
      if ((early_deassert & (((next_tx_state == RELOAD2) & !tx_mac_tlast))) |
          (tx_ack & tx_enable_reg & force_burst1 & !force_burst2) |
          (force_burst2 & !force_burst1 & tx_enable_reg)) begin
         force_assert <= 1;
      end
      else if (tx_data_valid & tx_enable_reg) begin
         force_assert <= 0;
      end
   end
end

// need to consider two cases for burst which are not andled by the standard state machine
// exit route
// set force_burst one in both cases
always @(posedge tx_clk)
begin
   if (tx_reset) begin
      force_burst1 <= 0;
   end
   else begin
      if ((early_deassert & tlast_reg & tx_mac_tvalid & 
          (tx_state == LOAD2 | tx_state == RELOAD2)) | 
          (two_byte_tx & 
          ((tlast_reg & tx_mac_tvalid & tx_state == WAIT)))) begin
         force_burst1 <= 1;
      end
      else if (tx_ack & tx_enable_reg) begin
         force_burst1 <= 0;
      end
   end
end

always @(posedge tx_clk)
begin
   if (tx_reset) begin
      force_burst2 <= 0;
   end
   else begin
      if (two_byte_tx & 
          ((tlast_reg & tx_mac_tvalid & tx_state == WAIT))) begin
         force_burst2 <= 1;
      end
      else if (!force_burst1 & tx_enable_reg) begin
         force_burst2 <= 0;
      end
   end
end

// annoyingly we need to detect if no burst is required and force data_valid low for two
// cycles as currently, if tvalid goes high after one cycle data_valid will also
// only be low for a cycle
always @(posedge tx_clk)
begin
   if (tx_reset) begin
      no_burst <= 0;
   end
   else begin
      if ( tx_state == BURST & !tx_mac_tvalid) begin
         no_burst <= 1;
      end
      else begin
         no_burst <= 0;
      end
   end
end


// capture data - need to hold 2 bytes?
always @(posedge tx_clk)
begin
   if (tx_reset) begin
      tlast_reg <= 0;
      tx_data_hold <= 0;
      two_byte_tx <= 0;
   end
   else begin
      if (tx_mac_tlast & tx_mac_tready_int)
         tlast_reg <= 1;
      else if (tx_enable_reg)
         tlast_reg <= 0;
      if ((tx_state == LOAD2) | (tx_state == RELOAD2)) begin
         two_byte_tx <= tx_mac_tlast;
      end
      if (tx_mac_tready_int) begin
         tx_data_hold <= tx_mac_tdata;
      end
   end
end

// generate the data - ack will result in pre-captured data being output
always @(posedge tx_clk)
begin
   if (tx_reset) begin
      tx_data <= 0;
   end
   else begin
      if (((tx_state == IDLE) | (tx_state == RELOAD1) | (tx_state == SEND) |
          ((tx_state == RELOAD2) & tx_ack)) & tx_enable_reg)
         tx_data <= tx_mac_tdata;
      else if (tx_ack & tx_enable_reg)
         tx_data <= tx_data_hold;
   end
end

// generate tready - this can be asserted/deasserted irrespective of the value of tvalid
always @(posedge tx_clk)
begin
   if (tx_reset) begin
      tx_mac_tready_reg <= 0;
   end
   else begin
      if ((next_tx_state == LOAD1) | 
          (next_tx_state == LOAD2 & !tx_mac_tlast) | 
          (next_tx_state == CLEAR_PIPE) | 
          (next_tx_state == RELOAD1) | 
          (next_tx_state == RELOAD2) | 
          ((next_tx_state == SEND) & (!early_deassert & !two_byte_tx)) |
          (ignore_packet & !tx_mac_tlast))
         tx_mac_tready_reg <= 1;
      else
         tx_mac_tready_reg <= 0;
   end
end

always @(posedge tx_clk)
begin
   if (tx_reset) begin
      gate_tready <= 1;
   end
   else begin
      if (next_tx_state == SEND) begin
         if (tx_enable)
            gate_tready <= 1;
         else
            gate_tready <= 0;
      end
      else begin
         gate_tready <= 1;
      end
   end
end

always @(tx_mac_tready_reg or gate_tready)
begin
   tx_mac_tready_int = (tx_mac_tready_reg & gate_tready);
end


endmodule
