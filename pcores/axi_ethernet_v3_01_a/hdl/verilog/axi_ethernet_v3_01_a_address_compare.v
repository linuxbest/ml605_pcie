// $Revision: 1.1 $
// $Date: 2010/07/13 10:53:35 $
//----------------------------------------------------------------------
// Title      : Configurable Address and Frame Comparison
// Project    : Tri-Mode Ethernet MAC
//----------------------------------------------------------------------
// File       : axi_ethernet_v3_01_a_address_compare.v
// Author     : Xilinx, Inc.
//----------------------------------------------------------------------
// Description: This block instantiates two 8-bit wide dual port distributed
//              RAMs. The write side of the RAMs are connected to the CPU I/F,
//              allowing 512 bits of frame comparison, including the 48-bit
//              address, to to be written in (a byte at a time on consecutive
//              cpu_clk's). The read side of the RAMs are linked to Ethernet
//              frame reception: a byte is clocked out 1 at a time in sync
//              with the first 64 bytes of an Ethernet frame. A comparison
//              between the 64 bytes stored in the RAM and the first 64 bytes
//              of the frame is performed. One RAM is stores values to be
//              compared; the other, enables. This filter is defaults to and is
//              backwards compatible with destination address-only comparison.
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


module axi_ethernet_v3_01_a_address_compare #
(
  parameter c_mac_addr = 48'hFFFFFFFFFFFF
)
(

  // CPU interface for configurable comparison read/write
  input        cpu_clk,             // CPU clock
  input        cpu_reset,           // CPU synchronous reset
  input        cpu_field_wr,        // CPU write strobe (values)
  input        cpu_compare_wr,      // CPU write strobe (enables)
  input  [5:0] cpu_addr,            // CPU address
  input  [7:0] cpu_wr_data,         // CPU write data
  output [7:0] cpu_rd_field_data,   // CPU read data (values)
  output [7:0] cpu_rd_compare_data, // CPU read data (enables)

  // Receiver frame interface
  input        rx_clk,
  input        rx_reset,            // synchronous reset
  input        rx_clk_en,           // clock enable
  input  [7:0] rx_data,             // Received frame data
  input        rx_data_valid_reg1,  // data_valid registered
  input        rx_data_valid_reg2,  // data_valid registered
  input  [5:0] rx_addr,             // read address for the LUTs

  // Comparison enable and match indicators
  input        enable_comparison,
  output reg   match
);


  // A total of 512 bits, broken into 8 logical segments for 1-byte width,
  // 64-bit depth distributed RAMs (targets well to 6-LUTs)

  // The initial address should equal c_mac_addr
  localparam INITADR = {58'h0, c_mac_addr[47], c_mac_addr[39], c_mac_addr[31],
                               c_mac_addr[23], c_mac_addr[15], c_mac_addr[7],

                        58'h0, c_mac_addr[46], c_mac_addr[38], c_mac_addr[30],
                               c_mac_addr[22], c_mac_addr[14], c_mac_addr[6],

                        58'h0, c_mac_addr[45], c_mac_addr[37], c_mac_addr[29],
                               c_mac_addr[21], c_mac_addr[13], c_mac_addr[5],

                        58'h0, c_mac_addr[44], c_mac_addr[36], c_mac_addr[28],
                               c_mac_addr[20], c_mac_addr[12], c_mac_addr[4],

                        58'h0, c_mac_addr[43], c_mac_addr[35], c_mac_addr[27],
                               c_mac_addr[19], c_mac_addr[11], c_mac_addr[3],

                        58'h0, c_mac_addr[42], c_mac_addr[34], c_mac_addr[26],
                               c_mac_addr[18], c_mac_addr[10], c_mac_addr[2],

                        58'h0, c_mac_addr[41], c_mac_addr[33], c_mac_addr[25],
                               c_mac_addr[17], c_mac_addr[9],  c_mac_addr[1],

                        58'h0, c_mac_addr[40], c_mac_addr[32], c_mac_addr[24],
                               c_mac_addr[16], c_mac_addr[8],  c_mac_addr[0]};

  // The initial compare bits should align with all valid MAC address bits
  localparam INITMSK = {58'h0, 6'b111111,
                        58'h0, 6'b111111,
                        58'h0, 6'b111111,
                        58'h0, 6'b111111,
                        58'h0, 6'b111111,
                        58'h0, 6'b111111,
                        58'h0, 6'b111111,
                        58'h0, 6'b111111};



  //--------------------------------------------------------------------
  // Internal signals used in this module
  //--------------------------------------------------------------------

  // Byte wide comparator for Ethernet frame comparison
  wire [7:0]  expected_mac_data;
  wire [7:0]  compare_mac_data;
  reg  [7:0]  bit_match;



  //--------------------------------------------------------------------
  // Here we instantiate Dual Port Distributed RAMs
  //--------------------------------------------------------------------

  genvar i;
  generate for (i=0; i<8; i=i+1)
    begin : byte_wide_ram

    // Dual Port Distributed RAM to store the frame values. This is instantiated
    // so that the RAM outputs create a byte wide bus. On rx_addr values 0-5
    // these RAMs return the bytes of the MAC Addresss (in order) so that they
    // can be matched against the incoming bytes from the Destination Address
    // from the received frame. On rx_addr values 6-63, these RAMs return bytes
    // that can be used to further match frame contents.
      RAM64X1D #
      (
      // Initialise to the Broadcast Address in the lower 6 bytes, leaving the
      // upper 58 bytes initialized to 0 to default to address comparisons.
      .INIT       (INITADR[((i+1)*64)-1:(i*64)])
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
        .A5         (cpu_addr[5]),
        .SPO        (cpu_rd_field_data[i]),

        .DPRA0      (rx_addr[0]),
        .DPRA1      (rx_addr[1]),
        .DPRA2      (rx_addr[2]),
        .DPRA3      (rx_addr[3]),
        .DPRA4      (rx_addr[4]),
        .DPRA5      (rx_addr[5]),
        .DPO        (expected_mac_data[i])
      );


    // Dual Port Distributed RAM to store the compare bits. This is instantiated
    // so that the RAM outputs create a byte wide bus. On rx_addr values 0-5
    // these RAMs return the bytes of the MAC Addresss (in order) so that they
    // can be matched against the incoming bytes from the Destination Address
    // from the received frame. On rx_addr values 6-63, these RAMs return bytes
    // that can be used to further match frame contents.
      RAM64X1D #
      (
      // Initialise to all 1's in the lower 6 bytes, leaving the upper 58 bytes
      // initialized to 0 to default to address comparisons.
      .INIT       (INITMSK[((i+1)*64)-1:(i*64)])
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
        .A5         (cpu_addr[5]),
        .SPO        (cpu_rd_compare_data[i]),

        .DPRA0      (rx_addr[0]),
        .DPRA1      (rx_addr[1]),
        .DPRA2      (rx_addr[2]),
        .DPRA3      (rx_addr[3]),
        .DPRA4      (rx_addr[4]),
        .DPRA5      (rx_addr[5]),
        .DPO        (compare_mac_data[i])
      );

    end
  endgenerate



  //--------------------------------------------------------------------
  // Comparison logic
  //--------------------------------------------------------------------

  // Create an 8-bit combinatorial comparator to compare the received
  // byte with current byte and enable from the RAMs.
  genvar j;
  generate for (j=0; j<8; j=j+1)
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



  // Continue the matching procedure. If 1st byte matches, set
  // match signal to 1. Set to 0 if any successive byte does not match.

  always @(posedge rx_clk)
  begin
    if (rx_reset) begin
      match  <= 1'b0;
    end

    else if (rx_clk_en) begin

      if ((enable_comparison == 1'b1) & (bit_match == 8'b11111111)) begin
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
