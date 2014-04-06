//------------------------------------------------------------------------------
// Title      : CDC Sync Block
// Project    : Tri-Mode Ethernet MAC
//------------------------------------------------------------------------------
// File       : axi_ethernet_v3_01_a_sync_block.v
// Author     : Xilinx Inc.
//------------------------------------------------------------------------------
// Description: Used on signals crossing from one clock domain to
//              another, this is a flip-flop pair, with both flops
//              placed together with RLOCs into the same slice.  Thus
//              the routing delay between the two is minimum to safe-
//              guard against metastability issues.
`timescale 1ps / 1ps

module axi_ethernet_v3_01_a_sync_block #(
  parameter INITIALISE = 2'b00
)
(
  input        clk,              // clock to be sync'ed to
  input        data_in,          // Data to be 'synced'
  output       data_out          // synced data
);

  // Internal Signals
  wire data_sync1;
  wire data_sync2;


  (* ASYNC_REG = "TRUE", RLOC = "X0Y0" *)
  FD #(
    .INIT (INITIALISE[0])
  ) data_sync (
    .C  (clk),
    .D  (data_in),
    .Q  (data_sync1)
  );


  (* RLOC = "X0Y0" *)
  FD #(
   .INIT (INITIALISE[1])
  ) data_sync_reg (
  .C  (clk),
  .D  (data_sync1),
  .Q  (data_sync2)
  );


  assign data_out = data_sync2;


endmodule
