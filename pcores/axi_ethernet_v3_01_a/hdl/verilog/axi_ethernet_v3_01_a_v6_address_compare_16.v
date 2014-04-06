// $Revision: 1.1 $
// $Date: 2011/05/13 20:59:41 $
//----------------------------------------------------------------------
// Title      : Configurable Address and Frame Comparison
// Project    : Tri-Mode Ethernet MAC
//----------------------------------------------------------------------
// File       : axi_ethernet_v3_01_a_v6_address_compare_16.v
// Author     : Xilinx, Inc.
//----------------------------------------------------------------------
// Description: This block instantiates two 16-bit wide dual port distributed
//              RAMs. The write side of the RAMs are connected to the CPU I/F,
//              allowing 512 bits of frame comparison, including the 48-bit
//              address, to to be written in (a word at a time on consecutive
//              cpu_clk's). The read side of the RAMs are linked to Ethernet
//              frame reception: a word is clocked out 1 at a time in sync
//              with the first 32 words of an Ethernet frame. A comparison
//              between the 32 words stored in the RAM and the first 32 words
//              of the frame is performed. One RAM stores values to be
//              compared; the other, enables. This filter defaults to and is
//              backwards compatible with destination address-only comparison.
//----------------------------------------------------------------------
// (c) Copyright 2007-2011 Xilinx, Inc. All rights reserved.
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


module axi_ethernet_v3_01_a_v6_address_compare_16 #
(
  parameter C_MAC_ADDR = 48'hFFFFFFFFFFFF
)
(

  // CPU interface for configurable comparison read/write
  input         cpu_clk,             // CPU clock
  input         cpu_reset,           // CPU synchronous reset
  input         cpu_field_wr,        // CPU write strobe (values)
  input         cpu_compare_wr,      // CPU write strobe (enables)
  input  [4:0]  cpu_addr,            // CPU address
  input  [15:0] cpu_wr_data,         // CPU write data
  output [15:0] cpu_rd_field_data,   // CPU read data (values)
  output [15:0] cpu_rd_compare_data, // CPU read data (enables)

  // Receiver frame interface
  input         rx_clk,
  input         rx_reset,            // synchronous reset
  input         rx_clk_en,           // clock enable
  input  [15:0] rx_data,             // Received frame data
  input         rx_data_valid_reg1,  // data_valid registered
  input         rx_data_valid_reg2,  // data_valid registered
  input  [4:0]  rx_addr,             // read address for the LUTs

  // Comparison enable and match indicators
  input        enable_comparison,
  output reg   match
);


  // A total of 512 bits, broken into 8 logical segments for 2-byte width,
  // 32-bit depth distributed RAMs

  // The initial address should equal C_MAC_ADDR
  localparam INITADR = {29'h0, C_MAC_ADDR[47], C_MAC_ADDR[31], C_MAC_ADDR[15],
                        29'h0, C_MAC_ADDR[46], C_MAC_ADDR[30], C_MAC_ADDR[14],
                        29'h0, C_MAC_ADDR[45], C_MAC_ADDR[29], C_MAC_ADDR[13],
                        29'h0, C_MAC_ADDR[44], C_MAC_ADDR[28], C_MAC_ADDR[12],
                        29'h0, C_MAC_ADDR[43], C_MAC_ADDR[27], C_MAC_ADDR[11],
                        29'h0, C_MAC_ADDR[42], C_MAC_ADDR[26], C_MAC_ADDR[10],
                        29'h0, C_MAC_ADDR[41], C_MAC_ADDR[25], C_MAC_ADDR[9],
                        29'h0, C_MAC_ADDR[40], C_MAC_ADDR[24], C_MAC_ADDR[8],
                        29'h0, C_MAC_ADDR[39], C_MAC_ADDR[23], C_MAC_ADDR[7],
                        29'h0, C_MAC_ADDR[38], C_MAC_ADDR[22], C_MAC_ADDR[6],
                        29'h0, C_MAC_ADDR[37], C_MAC_ADDR[21], C_MAC_ADDR[5],
                        29'h0, C_MAC_ADDR[36], C_MAC_ADDR[20], C_MAC_ADDR[4],
                        29'h0, C_MAC_ADDR[35], C_MAC_ADDR[19], C_MAC_ADDR[3],
                        29'h0, C_MAC_ADDR[34], C_MAC_ADDR[18], C_MAC_ADDR[2],
                        29'h0, C_MAC_ADDR[33], C_MAC_ADDR[17], C_MAC_ADDR[1],
                        29'h0, C_MAC_ADDR[32], C_MAC_ADDR[16], C_MAC_ADDR[0]};

  // The initial compare bits should align with all valid MAC address bits
  localparam INITMSK = {29'h0, 3'b111,
                        29'h0, 3'b111,
                        29'h0, 3'b111,
                        29'h0, 3'b111,
                        29'h0, 3'b111,
                        29'h0, 3'b111,
                        29'h0, 3'b111,
                        29'h0, 3'b111,
                        29'h0, 3'b111,
                        29'h0, 3'b111,
                        29'h0, 3'b111,
                        29'h0, 3'b111,
                        29'h0, 3'b111,
                        29'h0, 3'b111,
                        29'h0, 3'b111,
                        29'h0, 3'b111};



  //--------------------------------------------------------------------
  // Internal signals used in this module
  //--------------------------------------------------------------------

  // Word wide comparator for Ethernet frame comparison
  wire [15:0]  expected_mac_data;
  wire [15:0]  compare_mac_data;
  reg  [15:0]  bit_match;



  //--------------------------------------------------------------------
  // Here we instantiate Dual Port Distributed RAMs
  //--------------------------------------------------------------------

  genvar i;
  generate for (i=0; i<16; i=i+1)
    begin : word_wide_ram

    // Dual Port Distributed RAM to store the frame values. This is instantiated
    // so that the RAM outputs create a word-wide bus. On rx_addr values 0-2
    // these RAMs return the words of the MAC Addresss (in order) so that they
    // can be matched against the incoming words from the Destination Address
    // from the received frame. On rx_addr values 3-31, these RAMs return words
    // that can be used to further match frame contents.
      RAM32X1D #
      (
      // Initialize to the Broadcast Address in the lower 3 words, leaving the
      // upper 29 words initialized to 0 to default to address comparisons.
      .INIT       (INITADR[((i+1)*32)-1:(i*32)])
      )
      header_field_dist_ram
      (
        .D          (cpu_wr_data[i]),
        .WE         (cpu_field_wr),
        .WCLK       (cpu_clk),

        .A0         (cpu_addr[0]),
        .A1         (cpu_addr[1]),
        .A2         (cpu_addr[2]),
        .A3         (cpu_addr[3]),
        .A4         (cpu_addr[4]),
        .SPO        (cpu_rd_field_data[i]),

        .DPRA0      (rx_addr[0]),
        .DPRA1      (rx_addr[1]),
        .DPRA2      (rx_addr[2]),
        .DPRA3      (rx_addr[3]),
        .DPRA4      (rx_addr[4]),
        .DPO        (expected_mac_data[i])
      );


    // Dual Port Distributed RAM to store the compare bits. This is instantiated
    // so that the RAM outputs create a word-wide bus. On rx_addr values 0-2
    // these RAMs return the words of the MAC Addresss (in order) so that they
    // can be matched against the incoming words from the Destination Address
    // from the received frame. On rx_addr values 3-31, these RAMs return words
    // that can be used to further match frame contents.
      RAM32X1D #
      (
      // Initialize to all 1's in the lower 3 words, leaving the upper 29 words
      // initialized to 0 to default to address comparisons.
      .INIT       (INITMSK[((i+1)*32)-1:(i*32)])
      )
      header_compare_dist_ram
      (
        .D          (cpu_wr_data[i]),
        .WE         (cpu_compare_wr),
        .WCLK       (cpu_clk),

        .A0         (cpu_addr[0]),
        .A1         (cpu_addr[1]),
        .A2         (cpu_addr[2]),
        .A3         (cpu_addr[3]),
        .A4         (cpu_addr[4]),
        .SPO        (cpu_rd_compare_data[i]),

        .DPRA0      (rx_addr[0]),
        .DPRA1      (rx_addr[1]),
        .DPRA2      (rx_addr[2]),
        .DPRA3      (rx_addr[3]),
        .DPRA4      (rx_addr[4]),
        .DPO        (compare_mac_data[i])
      );

    end
  endgenerate



  //--------------------------------------------------------------------
  // Comparison logic
  //--------------------------------------------------------------------

  // Create a 16-bit combinatorial comparator to compare the received
  // word with current word and enable from the RAMs.
  genvar j;
  generate for (j=0; j<16; j=j+1)
    begin : bit_match_gen

      always @(posedge rx_clk)
      begin
        if (rx_reset) begin
          bit_match[j] <= 1'b0;
        end

        else if (rx_clk_en) begin

          if ((expected_mac_data[j] == rx_data[j]) |
              (compare_mac_data[j] == 1'b0)) begin
            bit_match[j] <= 1'b1;
          end

          else begin
            bit_match[j] <= 1'b0;
          end

        end
      end

    end
  endgenerate



  // Continue the matching procedure. If 1st word matches, set
  // match signal to 1. Set to 0 if any successive word does not match.

  always @(posedge rx_clk)
  begin
    if (rx_reset) begin
      match  <= 1'b0;
    end

    else if (rx_clk_en) begin

      if ((enable_comparison == 1'b1) & (bit_match == 16'b1111111111111111)) begin
        if (rx_data_valid_reg1 & !rx_data_valid_reg2) begin
          match <= 1'b1;
        end
      end

      else begin
        match <= 1'b0;
      end

    end
  end



endmodule
