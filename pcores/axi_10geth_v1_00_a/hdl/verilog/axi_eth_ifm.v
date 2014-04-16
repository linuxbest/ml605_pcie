// axi_ifm.v --- 
// 
// Filename: axi_ifm.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Mon Apr 14 22:56:33 2014 (-0700)
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
module axi_eth_ifm (/*AUTOARG*/
   // Outputs
   rxs_tvalid, rxs_tlast, rxs_tkeep, rxs_tdata, rxd_tvalid, rxd_tlast,
   rxd_tkeep, rxd_tdata, rx_axis_mac_tready,
   // Inputs
   s2mm_resetn, s2mm_clk, rxs_tready, rxd_tready, rx_reset, rx_clk,
   rx_axis_mac_tvalid, rx_axis_mac_tuser, rx_axis_mac_tlast,
   rx_axis_mac_tkeep, rx_axis_mac_tdata
   );
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [63:0]		rx_axis_mac_tdata;	// To ifm_in_fsm of ifm_in_fsm.v
   input [7:0]		rx_axis_mac_tkeep;	// To ifm_in_fsm of ifm_in_fsm.v
   input		rx_axis_mac_tlast;	// To ifm_in_fsm of ifm_in_fsm.v
   input		rx_axis_mac_tuser;	// To ifm_in_fsm of ifm_in_fsm.v
   input		rx_axis_mac_tvalid;	// To ifm_in_fsm of ifm_in_fsm.v
   input		rx_clk;			// To ifm_in_fsm of ifm_in_fsm.v, ...
   input		rx_reset;		// To ifm_in_fsm of ifm_in_fsm.v, ...
   input		rxd_tready;		// To ifm_fifo of ifm_fifo.v
   input		rxs_tready;		// To ifm_fifo of ifm_fifo.v
   input		s2mm_clk;		// To ifm_out_fsm of ifm_out_fsm.v, ...
   input		s2mm_resetn;		// To ifm_out_fsm of ifm_out_fsm.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		rx_axis_mac_tready;	// From ifm_in_fsm of ifm_in_fsm.v
   output [63:0]	rxd_tdata;		// From ifm_fifo of ifm_fifo.v
   output [7:0]		rxd_tkeep;		// From ifm_fifo of ifm_fifo.v
   output		rxd_tlast;		// From ifm_fifo of ifm_fifo.v
   output		rxd_tvalid;		// From ifm_fifo of ifm_fifo.v
   output [31:0]	rxs_tdata;		// From ifm_fifo of ifm_fifo.v
   output [3:0]		rxs_tkeep;		// From ifm_fifo of ifm_fifo.v
   output		rxs_tlast;		// From ifm_fifo of ifm_fifo.v
   output		rxs_tvalid;		// From ifm_fifo of ifm_fifo.v
   // End of automatics
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			ctrl_fifo_afull;	// From ifm_fifo of ifm_fifo.v
   wire [36:0]		ctrl_fifo_wdata;	// From ifm_out_fsm of ifm_out_fsm.v
   wire			ctrl_fifo_wren;		// From ifm_out_fsm of ifm_out_fsm.v
   wire			data_fifo_afull;	// From ifm_fifo of ifm_fifo.v
   wire [72:0]		data_fifo_rdata;	// From ifm_fifo of ifm_fifo.v
   wire			data_fifo_rden;		// From ifm_out_fsm of ifm_out_fsm.v
   wire [72:0]		data_fifo_wdata;	// From ifm_in_fsm of ifm_in_fsm.v
   wire			data_fifo_wren;		// From ifm_in_fsm of ifm_in_fsm.v
   wire			good_fifo_afull;	// From ifm_fifo of ifm_fifo.v
   wire [72:0]		good_fifo_wdata;	// From ifm_out_fsm of ifm_out_fsm.v
   wire			good_fifo_wren;		// From ifm_out_fsm of ifm_out_fsm.v
   wire			info_fifo_empty;	// From ifm_fifo of ifm_fifo.v
   wire			info_fifo_rdata;	// From ifm_fifo of ifm_fifo.v
   wire			info_fifo_rden;		// From ifm_out_fsm of ifm_out_fsm.v
   wire			info_fifo_wdata;	// From ifm_in_fsm of ifm_in_fsm.v
   wire			info_fifo_wren;		// From ifm_in_fsm of ifm_in_fsm.v
   // End of automatics
   
   ifm_in_fsm  ifm_in_fsm   (/*AUTOINST*/
			     // Outputs
			     .rx_axis_mac_tready(rx_axis_mac_tready),
			     .data_fifo_wdata	(data_fifo_wdata[72:0]),
			     .data_fifo_wren	(data_fifo_wren),
			     .info_fifo_wdata	(info_fifo_wdata),
			     .info_fifo_wren	(info_fifo_wren),
			     // Inputs
			     .rx_clk		(rx_clk),
			     .rx_reset		(rx_reset),
			     .rx_axis_mac_tdata	(rx_axis_mac_tdata[63:0]),
			     .rx_axis_mac_tkeep	(rx_axis_mac_tkeep[7:0]),
			     .rx_axis_mac_tlast	(rx_axis_mac_tlast),
			     .rx_axis_mac_tuser	(rx_axis_mac_tuser),
			     .rx_axis_mac_tvalid(rx_axis_mac_tvalid),
			     .data_fifo_afull	(data_fifo_afull));
   ifm_out_fsm ifm_out_fsm (/*AUTOINST*/
			    // Outputs
			    .data_fifo_rden	(data_fifo_rden),
			    .info_fifo_rden	(info_fifo_rden),
			    .good_fifo_wdata	(good_fifo_wdata[72:0]),
			    .good_fifo_wren	(good_fifo_wren),
			    .ctrl_fifo_wdata	(ctrl_fifo_wdata[36:0]),
			    .ctrl_fifo_wren	(ctrl_fifo_wren),
			    // Inputs
			    .s2mm_clk		(s2mm_clk),
			    .s2mm_resetn	(s2mm_resetn),
			    .data_fifo_rdata	(data_fifo_rdata[72:0]),
			    .info_fifo_rdata	(info_fifo_rdata),
			    .info_fifo_empty	(info_fifo_empty),
			    .good_fifo_afull	(good_fifo_afull),
			    .ctrl_fifo_afull	(ctrl_fifo_afull));

   ifm_fifo ifm_fifo (/*AUTOINST*/
		      // Outputs
		      .data_fifo_afull	(data_fifo_afull),
		      .data_fifo_rdata	(data_fifo_rdata[72:0]),
		      .info_fifo_empty	(info_fifo_empty),
		      .info_fifo_rdata	(info_fifo_rdata),
		      .rxd_tdata	(rxd_tdata[63:0]),
		      .rxd_tkeep	(rxd_tkeep[7:0]),
		      .rxd_tlast	(rxd_tlast),
		      .rxd_tvalid	(rxd_tvalid),
		      .good_fifo_afull	(good_fifo_afull),
		      .rxs_tdata	(rxs_tdata[31:0]),
		      .rxs_tkeep	(rxs_tkeep[3:0]),
		      .rxs_tlast	(rxs_tlast),
		      .rxs_tvalid	(rxs_tvalid),
		      .ctrl_fifo_afull	(ctrl_fifo_afull),
		      // Inputs
		      .rx_clk		(rx_clk),
		      .rx_reset		(rx_reset),
		      .s2mm_clk		(s2mm_clk),
		      .data_fifo_wdata	(data_fifo_wdata[72:0]),
		      .data_fifo_wren	(data_fifo_wren),
		      .data_fifo_rden	(data_fifo_rden),
		      .info_fifo_wdata	(info_fifo_wdata),
		      .info_fifo_wren	(info_fifo_wren),
		      .info_fifo_rden	(info_fifo_rden),
		      .rxd_tready	(rxd_tready),
		      .good_fifo_wdata	(good_fifo_wdata[72:0]),
		      .good_fifo_wren	(good_fifo_wren),
		      .rxs_tready	(rxs_tready),
		      .ctrl_fifo_wdata	(ctrl_fifo_wdata[36:0]),
		      .ctrl_fifo_wren	(ctrl_fifo_wren));
endmodule   
// 
// axi_ifm.v ends here
