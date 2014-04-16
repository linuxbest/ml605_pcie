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
   rxd_tdata, rxd_tkeep, rxd_tlast, rxd_tvalid, good_fifo_afull,
   rxs_tdata, rxs_tkeep, rxs_tlast, rxs_tvalid, ctrl_fifo_afull,
   // Inputs
   rx_clk, s2mm_clk, s2mm_resetn, data_fifo_wdata, data_fifo_wren,
   data_fifo_rden, info_fifo_wdata, info_fifo_wren, info_fifo_rden,
   rxd_tready, good_fifo_wdata, good_fifo_wren, rxs_tready,
   ctrl_fifo_wdata, ctrl_fifo_wren
   );
   input rx_clk;
   input s2mm_clk;
   input s2mm_resetn;

   input [72:0] data_fifo_wdata;
   input 	data_fifo_wren;
   output 	data_fifo_afull;

   output [72:0]data_fifo_rdata;
   input 	data_fifo_rden;

   wire         data_fifo_empty;
   afifo73_512 data_fifo(.din     (data_fifo_wdata),
			 .wr_en   (data_fifo_wren),
			 .wr_clk  (rx_clk),
			 .rd_en   (data_fifo_rden && ~data_fifo_empty),
			 .rd_clk  (s2mm_clk),
			 .rst     (~s2mm_resetn),
			 .dout    (data_fifo_rdata),
			 .full    (),
			 .empty   (data_fifo_empty),
			 .prog_full(data_fifo_afull));

   input [7:0]	info_fifo_wdata;
   input 	info_fifo_wren;
   output 	info_fifo_empty;
   output [7:0]	info_fifo_rdata;
   input 	info_fifo_rden;
   small_async_fifo #(.DSIZE(8), .ASIZE(8))
   info_fifo (.wfull         (),
	      .w_almost_full (),
	      .wdata         (info_fifo_wdata),
	      .winc          (info_fifo_wren),
	      .wclk          (rx_clk),
	      .wrst_n        (s2mm_resetn),

	      .rdata         (info_fifo_rdata),
	      .rempty        (info_fifo_empty),
	      .r_almost_empty(),
	      .rinc          (info_fifo_rden && ~info_fifo_empty),
	      .rclk          (s2mm_clk),
	      .rrst_n        (s2mm_resetn));

   wire [72:0] 	good_fifo_rdata;
   wire 	good_fifo_empty;
   wire 	good_fifo_rden;
   output [63:0] rxd_tdata;
   output [7:0]  rxd_tkeep;
   output 	 rxd_tlast;
   output 	 rxd_tvalid;
   input 	 rxd_tready;
   assign rxd_tdata = good_fifo_rdata[63:0];
   assign rxd_tkeep = good_fifo_rdata[71:64];
   assign rxd_tlast = good_fifo_rdata[72];
   assign rxd_tvalid=~good_fifo_empty;
   assign good_fifo_rden = rxd_tvalid && rxd_tready;
   
   input [72:0] good_fifo_wdata;
   input 	good_fifo_wren;
   output 	good_fifo_afull;   
   fifo73_512   good_fifo (.din     (good_fifo_wdata),
			   .wr_en   (good_fifo_wren),
			   .clk     (s2mm_clk),
			   .rd_en   (good_fifo_rden),
			   .rst     (~s2mm_resetn),
			   .dout    (good_fifo_rdata),
			   .full    (),
			   .empty   (good_fifo_empty),
			   .prog_full(good_fifo_afull));

   wire [36:0] 	ctrl_fifo_rdata;
   wire 	ctrl_fifo_empty;
   wire 	ctrl_fifo_rden;
   output [31:0] rxs_tdata;
   output [3:0]  rxs_tkeep;
   output 	 rxs_tlast;
   output 	 rxs_tvalid;
   input 	 rxs_tready;
   assign rxs_tdata = ctrl_fifo_rdata[31:0];
   assign rxs_tkeep = ctrl_fifo_rdata[35:32];
   assign rxs_tlast = ctrl_fifo_rdata[36];
   assign rxs_tvalid=~ctrl_fifo_empty;
   assign ctrl_fifo_rden = rxs_tvalid && rxs_tready;
   
   input [36:0] ctrl_fifo_wdata;
   input 	ctrl_fifo_wren;
   output 	ctrl_fifo_afull;   
   fifo37_512 ctrl_fifo (.din     (ctrl_fifo_wdata),
			 .wr_en   (ctrl_fifo_wren),
			 .clk     (s2mm_clk),
			 .rd_en   (ctrl_fifo_rden),
			 .rst     (~s2mm_resetn),
			 .dout    (ctrl_fifo_rdata),
			 .full    (),
			 .empty   (ctrl_fifo_empty),
			 .prog_full(ctrl_fifo_afull));  
endmodule
// 
// ifm_fifo.v ends here
