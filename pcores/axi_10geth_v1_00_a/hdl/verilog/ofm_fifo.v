// ofm_fifo.v --- 
// 
// Filename: ofm_fifo.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Tue Apr 15 19:08:36 2014 (-0700)
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
module ofm_fifo (/*AUTOARG*/
   // Outputs
   ctrl_fifo_afull, ctrl_fifo_rdata, ctrl_fifo_empty, data_fifo_afull,
   data_fifo_rdata, data_fifo_empty, tx_axis_mac_tdata,
   tx_axis_mac_tkeep, tx_axis_mac_tlast, tx_axis_mac_tuser,
   tx_axis_mac_tvalid, tx_fifo_afull,
   // Inputs
   mm2s_clk, sys_rst, tx_clk, ctrl_fifo_wdata, ctrl_fifo_wren,
   ctrl_fifo_rden, data_fifo_wdata, data_fifo_wren, data_fifo_rden,
   tx_axis_mac_tready, tx_fifo_wdata, tx_fifo_wren
   );
   input mm2s_clk;
   input sys_rst;

   input tx_clk;

   // we can hold 255 packet
   input [33:0] ctrl_fifo_wdata;
   input 	ctrl_fifo_wren;
   output 	ctrl_fifo_afull;

   output [33:0] ctrl_fifo_rdata;
   output 	 ctrl_fifo_empty;
   input 	 ctrl_fifo_rden;
   small_async_fifo #(.DSIZE(34), .ASIZE(8))
   info_fifo (.wfull         (),
	      .w_almost_full (ctrl_fifo_afull),
	      .wdata         (ctrl_fifo_wdata),
	      .winc          (ctrl_fifo_wren),
	      .wclk          (mm2s_clk),
	      .wrst_n        (~sys_rst),

	      .rdata         (ctrl_fifo_rdata),
	      .rempty        (ctrl_fifo_empty),
	      .r_almost_empty(),
	      .rinc          (ctrl_fifo_rden && ~ctrl_fifo_empty),
	      .rclk          (tx_clk),
	      .rrst_n        (~sys_rst));

   input [72:0] data_fifo_wdata;
   input 	data_fifo_wren;
   output 	data_fifo_afull;

   // 8x512 = 4096 byte, if we want support 
   output [72:0] data_fifo_rdata;
   output 	 data_fifo_empty;
   input 	 data_fifo_rden;
   afifo73_512 data_fifo(.din      (data_fifo_wdata),
			 .wr_en    (data_fifo_wren),
			 .wr_clk   (mm2s_clk),
			 .rd_en    (data_fifo_rden && ~data_fifo_empty),
			 .rd_clk   (tx_clk),
			 .rst      (sys_rst),
			 .dout     (data_fifo_rdata),
			 .full     (),
			 .empty    (data_fifo_empty),
			 .prog_full(data_fifo_afull));   

   wire [72:0]  tx_fifo_rdata;
   wire 	tx_fifo_empty;
   wire 	tx_fifo_rden;
   output [63:0] tx_axis_mac_tdata;
   output [7:0]  tx_axis_mac_tkeep;
   output 	 tx_axis_mac_tlast;
   output 	 tx_axis_mac_tuser;
   output 	 tx_axis_mac_tvalid;
   input 	 tx_axis_mac_tready;
   assign tx_axis_mac_tdata = tx_fifo_rdata[63:0];
   assign tx_axis_mac_tkeep = tx_fifo_rdata[71:64];
   assign tx_axis_mac_tuser = 1'b0;
   assign tx_axis_mac_tlast = tx_fifo_rdata[72];
   assign tx_axis_mac_tvalid=~tx_fifo_empty;
   assign tx_fifo_rden      = tx_axis_mac_tvalid && tx_axis_mac_tready;

   input [72:0]  tx_fifo_wdata;
   input 	 tx_fifo_wren;
   output 	 tx_fifo_afull;
   fifo73_512   txda_fifo (.din     (tx_fifo_wdata),
			   .wr_en   (tx_fifo_wren),
			   .clk     (tx_clk),
			   .rd_en   (tx_fifo_rden),
			   .rst     (sys_rst),
			   .dout    (tx_fifo_rdata),
			   .full    (),
			   .empty   (tx_fifo_empty),
			   .prog_full(tx_fifo_afull));   
endmodule
// 
// ofm_fifo.v ends here
