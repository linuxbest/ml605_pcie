// ifm_fifo.v --- 
// 
// Filename: ifm_fifo.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Mon Apr 14 23:55:00 2014 (-0700)
// Version: 
// Last-Updated: 
//           By: 
//     Update #: 0
// URL: 
// Keywords: 
// Compatibility: 
// 
// 

// Commentary: 
// 
// 
// 
// 

// Change log:
// 
// 
// 

// -------------------------------------
// Naming Conventions:
// 	active low signals                 : "*_n"
// 	clock signals                      : "clk", "clk_div#", "clk_#x"
// 	reset signals                      : "rst", "rst_n"
// 	generics                           : "C_*"
// 	user defined types                 : "*_TYPE"
// 	state machine next state           : "*_ns"
// 	state machine current state        : "*_cs"
// 	combinatorial signals              : "*_com"
// 	pipelined or register delay signals: "*_d#"
// 	counter signals                    : "*cnt*"
// 	clock enable signals               : "*_ce"
// 	internal version of output port    : "*_i"
// 	device pins                        : "*_pin"
// 	ports                              : - Names begin with Uppercase
// Code:
`timescale 1ps/1ps
module ifm_fifo (/*AUTOARG*/
   // Outputs
   data_fifo_afull, data_fifo_rdata, info_fifo_empty, info_fifo_rdata,
   mac_tdata, mac_tkeep, mac_tlast, mac_tvalid, good_fifo_afull,
   // Inputs
   rx_clk, rx_reset, sys_clk, data_fifo_wdata, data_fifo_wren,
   data_fifo_rden, info_fifo_wdata, info_fifo_wren, info_fifo_rden,
   mac_tready, good_fifo_wdata, good_fifo_wren
   );
   input rx_clk;
   input rx_reset;
   input sys_clk;

   input [72:0] data_fifo_wdata;
   input 	data_fifo_wren;
   output 	data_fifo_afull;

   output [72:0]data_fifo_rdata;
   input 	data_fifo_rden;

   axi_async_fifo #(.C_FAMILY              ("kintex7"),
		   .C_FIFO_DEPTH          (1024),
		   .C_PROG_FULL_THRESH    (700),
		   .C_DATA_WIDTH          (73),
		   .C_PTR_WIDTH           (10),
		   .C_MEMORY_TYPE         (1),
		   .C_COMMON_CLOCK        (0),
		   .C_IMPLEMENTATION_TYPE (2),
		   .C_SYNCHRONIZER_STAGE  (2))
   data_fifo (.din     (data_fifo_wdata),
	      .wr_en   (data_fifo_wren),
	      .wr_clk  (rx_clk),
	      .rd_en   (data_fifo_rden),
	      .rd_clk  (sys_clk),
	      .sync_clk(sys_clk),
	      .rst     (rx_reset),
	      .dout    (data_fifo_rdata),
	      .full    (),
	      .empty   (),
	      .prog_full(data_fifo_afull));

   input 	info_fifo_wdata;
   input 	info_fifo_wren;
   output 	info_fifo_empty;
   output 	info_fifo_rdata;
   input 	info_fifo_rden;
   small_async_fifo #(.DSIZE(1), .ASIZE(8))
   info_fifo (.wfull         (),
	      .w_almost_full (),
	      .wdata         (info_fifo_wdata),
	      .winc          (info_fifo_wren),
	      .wclk          (rx_clk),
	      .wrst_n        (~rx_reset),

	      .rdata         (info_fifo_rdata),
	      .rempty        (info_fifo_empty),
	      .r_almost_empty(),
	      .rinc          (info_fifo_rden),
	      .rclk          (sys_clk),
	      .rrst_n        (~rx_reset));

   wire [72:0] 	good_fifo_rdata;
   wire 	good_fifo_empty;
   wire 	good_fifo_rden;
   output [63:0] mac_tdata;
   output [7:0]  mac_tkeep;
   output 	 mac_tlast;
   output 	 mac_tvalid;
   input 	 mac_tready;
   assign mac_tdata = good_fifo_rdata[63:0];
   assign mac_tkeep = good_fifo_rdata[71:64];
   assign mac_tlast = good_fifo_rdata[72];
   assign mac_tvalid=~good_fifo_empty;
   assign good_fifo_rden = mac_tvalid && mac_tready;
   
   input [72:0] good_fifo_wdata;
   input 	good_fifo_wren;
   output 	good_fifo_afull;   
   axi_async_fifo #(.C_FAMILY              ("kintex7"),
		   .C_FIFO_DEPTH          (1024),
		   .C_PROG_FULL_THRESH    (700),
		   .C_DATA_WIDTH          (73),
		   .C_PTR_WIDTH           (10),
		   .C_MEMORY_TYPE         (1),
		   .C_COMMON_CLOCK        (1),
		   .C_IMPLEMENTATION_TYPE (2),
		   .C_SYNCHRONIZER_STAGE  (2))
   good_fifo (.din     (good_fifo_wdata),
	      .wr_en   (good_fifo_wren),
	      .wr_clk  (sys_clk),
	      .rd_en   (good_fifo_rden),
	      .rd_clk  (sys_clk),
	      .sync_clk(sys_clk),
	      .rst     (rx_reset),
	      .dout    (good_fifo_rdata),
	      .full    (),
	      .empty   (good_fifo_empty),
	      .prog_full(good_fifo_afull));
endmodule
// 
// ifm_fifo.v ends here
