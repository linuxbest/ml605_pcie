//----------------------------------------------------------------------
// Title      : Pause request shim
// Project    : Virtex-6 FPGA Embedded Tri-Mode Ethernet MAC
//----------------------------------------------------------------------
// File       : axi_ethernet_v3_01_a_pausereq_shim.v
// Author     : Xilinx, Inc.
//----------------------------------------------------------------------
// Description: RTL fix for CR 609798.
//              When a TX pause frame is requested via assertion of the
//              pause_req port, the 16-bit pause_val is captured and
//              transmitted in the subsequent pause frame. But if two
//              pause frames are requested in close proximity, it's
//              possible that 8 bits from the first request and 8 bits
//              from the second request are used together, resulting in
//              an incorrect 16-bit pause value; this is because the TEMAC
//              has an 8-bit data path and uses the values sequentially.
//              The bug only occurs when the second pause request is
//              made on exactly the 10th consecutive tx_stats_bytevld
//              asserted cycle of the pause frame, which is when the pause
//              value is fetched and stored. This simple shim delays
//              assertions of pause_req on that one problematic cycle.
//              It's a mux control state machine which normally selects
//              the user pause_req and pause_val inputs, but delays a
//              pause_req on the 10th byte cycle, then switches to select
//              registered versions of the signals to capture the delayed
//              request on the 11th byte cycle. In this way, no requests
//              are lost. When it is safe to do so, the mux select switches
//              back to the direct user inputs. The shim does not
//              distinguish between frame types, so a pause request made
//              on the 10th byte cycle of any frame type is delayed by one
//              cycle. But since no requests are lost, this causes no harm.
//----------------------------------------------------------------------
// (c) Copyright 2011 Xilinx, Inc. All rights reserved.
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


module axi_ethernet_v3_01_a_pausereq_shim
(

  input             reset,
  input             client_clk,
  input             client_clk_en,

  input             tx_stats_bytevld,

  input             pause_req,
  input      [15:0] pause_val,

  output reg        pause_req_out,
  output reg [15:0] pause_val_out

);


  // Register the pause_req and pause_val inputs to create delayed versions
  // which can be selected by the mux.

  reg        pause_req_reg;
  reg [15:0] pause_val_reg;

  always @(posedge client_clk) begin
    if (reset) begin
      pause_req_reg <= 1'b0;
      pause_val_reg <= 16'd0;
    end
    else begin
      if (client_clk_en) begin
        pause_req_reg <= pause_req;
        pause_val_reg <= pause_val;
      end
    end
  end


  // Create a 4-bit counter which is reset to 0 whever tx_stats_bytevld is
  // low and which counts up to 10 before stopping when tx_stats_bytevld is
  // high. This is used to identify the 10th byte of each frame.

  reg [3:0] tx_stats_bytevld_ctr = 4'd0;

  always @(posedge client_clk) begin
    if (client_clk_en) begin
      if (!tx_stats_bytevld)
        tx_stats_bytevld_ctr <= 4'd0;
      else begin
        if (tx_stats_bytevld_ctr < 4'd10)
          tx_stats_bytevld_ctr <= tx_stats_bytevld_ctr + 4'd1;
      end
    end
  end


  // Create a synchronous mux select signal. The mux usually selects the
  // combinatorial pause request inputs. When the counter is "9", force the
  // pause request mux output low to avoid a pause request on the 10th byte
  // of the frame. On the next cycle, force the mux outputs to the delayed
  // pause request and pause value signals to capture the possible pause
  // request on the previous (10th byte) cycle. Then, at the next
  // opportunity when pause_req is low, switch back to the combinatorial
  // pause request inputs. Waiting for this is necessary to avoid missing
  // any additional pause requests.

  reg [1:0] pausereq_mux_slt;

  localparam PAUSEREQ_MUX_COMB      = 2'b00;
  localparam PAUSEREQ_MUX_FORCE_LOW = 2'b01;
  localparam PAUSEREQ_MUX_REG       = 2'b10;

  always @(posedge client_clk) begin
    if (reset)
      pausereq_mux_slt <= PAUSEREQ_MUX_COMB;
    else begin
      if (client_clk_en) begin
        if (tx_stats_bytevld_ctr == 4'd9)
          pausereq_mux_slt <= PAUSEREQ_MUX_FORCE_LOW;
        else if (pausereq_mux_slt == PAUSEREQ_MUX_FORCE_LOW)
          pausereq_mux_slt <= PAUSEREQ_MUX_REG;
        else if (!pause_req)
          pausereq_mux_slt <= PAUSEREQ_MUX_COMB;
      end
    end
  end


  // Create the combinatorial muxes which are controlled by the synchronous
  // mux select line. The pause_req output is a 3:1 mux, but the pause_val
  // output is a 2:1 mux since we don't need to force CLIENTEMACPAUSEVAL
  // to 16'b0 on the 10th byte cycle as long as CLIENTEMACPAUSEREQ is low.

  always @* begin
    case (pausereq_mux_slt)
      PAUSEREQ_MUX_FORCE_LOW: pause_req_out = 1'b0;
      PAUSEREQ_MUX_REG:       pause_req_out = pause_req_reg;
      default:                pause_req_out = pause_req;
    endcase

    case (pausereq_mux_slt)
      PAUSEREQ_MUX_REG: pause_val_out = pause_val_reg;
      default:          pause_val_out = pause_val;
    endcase
  end


endmodule
