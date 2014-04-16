// axi_eth_ofm.v --- 
// 
// Filename: axi_eth_ofm.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Tue Apr 15 18:24:23 2014 (-0700)
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
module axi_eth_ofm (/*AUTOARG*/
   // Outputs
   txd_tready, txc_tready, tx_axis_mac_tvalid, tx_axis_mac_tuser,
   tx_axis_mac_tlast, tx_axis_mac_tkeep, tx_axis_mac_tdata,
   out_in_fsm_dbg, ofm_out_fsm_dbg,
   // Inputs
   txd_tvalid, txd_tlast, txd_tkeep, txd_tdata, txc_tvalid, txc_tlast,
   txc_tkeep, txc_tdata, tx_reset, tx_clk, tx_axis_mac_tready,
   mm2s_resetn, mm2s_clk
   );
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		mm2s_clk;		// To ofm_in_fsm of ofm_in_fsm.v, ...
   input		mm2s_resetn;		// To ofm_in_fsm of ofm_in_fsm.v, ...
   input		tx_axis_mac_tready;	// To ofm_out_fsm of ofm_out_fsm.v
   input		tx_clk;			// To ofm_fifo of ofm_fifo.v, ...
   input		tx_reset;		// To ofm_fifo of ofm_fifo.v, ...
   input [31:0]		txc_tdata;		// To ofm_in_fsm of ofm_in_fsm.v
   input [3:0]		txc_tkeep;		// To ofm_in_fsm of ofm_in_fsm.v
   input		txc_tlast;		// To ofm_in_fsm of ofm_in_fsm.v
   input		txc_tvalid;		// To ofm_in_fsm of ofm_in_fsm.v
   input [63:0]		txd_tdata;		// To ofm_in_fsm of ofm_in_fsm.v
   input [7:0]		txd_tkeep;		// To ofm_in_fsm of ofm_in_fsm.v
   input		txd_tlast;		// To ofm_in_fsm of ofm_in_fsm.v
   input		txd_tvalid;		// To ofm_in_fsm of ofm_in_fsm.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [3:0]		ofm_out_fsm_dbg;	// From ofm_out_fsm of ofm_out_fsm.v
   output [3:0]		out_in_fsm_dbg;		// From ofm_in_fsm of ofm_in_fsm.v
   output [63:0]	tx_axis_mac_tdata;	// From ofm_out_fsm of ofm_out_fsm.v
   output [7:0]		tx_axis_mac_tkeep;	// From ofm_out_fsm of ofm_out_fsm.v
   output		tx_axis_mac_tlast;	// From ofm_out_fsm of ofm_out_fsm.v
   output		tx_axis_mac_tuser;	// From ofm_out_fsm of ofm_out_fsm.v
   output		tx_axis_mac_tvalid;	// From ofm_out_fsm of ofm_out_fsm.v
   output		txc_tready;		// From ofm_in_fsm of ofm_in_fsm.v
   output		txd_tready;		// From ofm_in_fsm of ofm_in_fsm.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			ctrl_fifo_afull;	// From ofm_fifo of ofm_fifo.v
   wire			ctrl_fifo_empty;	// From ofm_fifo of ofm_fifo.v
   wire [63:0]		ctrl_fifo_rdata;	// From ofm_fifo of ofm_fifo.v
   wire			ctrl_fifo_rden;		// From ofm_out_fsm of ofm_out_fsm.v
   wire [63:0]		ctrl_fifo_wdata;	// From ofm_in_fsm of ofm_in_fsm.v
   wire			ctrl_fifo_wren;		// From ofm_in_fsm of ofm_in_fsm.v
   wire			data_fifo_afull;	// From ofm_fifo of ofm_fifo.v
   wire			data_fifo_empty;	// From ofm_fifo of ofm_fifo.v
   wire [72:0]		data_fifo_rdata;	// From ofm_fifo of ofm_fifo.v
   wire			data_fifo_rden;		// From ofm_out_fsm of ofm_out_fsm.v
   wire [72:0]		data_fifo_wdata;	// From ofm_in_fsm of ofm_in_fsm.v
   wire			data_fifo_wren;		// From ofm_in_fsm of ofm_in_fsm.v
   // End of automatics
   
   ofm_in_fsm  ofm_in_fsm (/*AUTOINST*/
			   // Outputs
			   .txd_tready		(txd_tready),
			   .txc_tready		(txc_tready),
			   .ctrl_fifo_wdata	(ctrl_fifo_wdata[63:0]),
			   .ctrl_fifo_wren	(ctrl_fifo_wren),
			   .data_fifo_wdata	(data_fifo_wdata[72:0]),
			   .data_fifo_wren	(data_fifo_wren),
			   .out_in_fsm_dbg	(out_in_fsm_dbg[3:0]),
			   // Inputs
			   .mm2s_clk		(mm2s_clk),
			   .mm2s_resetn		(mm2s_resetn),
			   .txd_tdata		(txd_tdata[63:0]),
			   .txd_tkeep		(txd_tkeep[7:0]),
			   .txd_tvalid		(txd_tvalid),
			   .txd_tlast		(txd_tlast),
			   .txc_tdata		(txc_tdata[31:0]),
			   .txc_tkeep		(txc_tkeep[3:0]),
			   .txc_tvalid		(txc_tvalid),
			   .txc_tlast		(txc_tlast),
			   .ctrl_fifo_afull	(ctrl_fifo_afull),
			   .data_fifo_afull	(data_fifo_afull));
   ofm_fifo    ofm_fifo   (/*AUTOINST*/
			   // Outputs
			   .ctrl_fifo_afull	(ctrl_fifo_afull),
			   .ctrl_fifo_rdata	(ctrl_fifo_rdata[63:0]),
			   .ctrl_fifo_empty	(ctrl_fifo_empty),
			   .data_fifo_afull	(data_fifo_afull),
			   .data_fifo_rdata	(data_fifo_rdata[72:0]),
			   .data_fifo_empty	(data_fifo_empty),
			   // Inputs
			   .mm2s_clk		(mm2s_clk),
			   .mm2s_resetn		(mm2s_resetn),
			   .tx_clk		(tx_clk),
			   .tx_reset		(tx_reset),
			   .ctrl_fifo_wdata	(ctrl_fifo_wdata[63:0]),
			   .ctrl_fifo_wren	(ctrl_fifo_wren),
			   .ctrl_fifo_rden	(ctrl_fifo_rden),
			   .data_fifo_wdata	(data_fifo_wdata[72:0]),
			   .data_fifo_wren	(data_fifo_wren),
			   .data_fifo_rden	(data_fifo_rden));
   ofm_out_fsm ofm_out_fsm(/*AUTOINST*/
			   // Outputs
			   .ctrl_fifo_rden	(ctrl_fifo_rden),
			   .data_fifo_rden	(data_fifo_rden),
			   .tx_axis_mac_tdata	(tx_axis_mac_tdata[63:0]),
			   .tx_axis_mac_tkeep	(tx_axis_mac_tkeep[7:0]),
			   .tx_axis_mac_tvalid	(tx_axis_mac_tvalid),
			   .tx_axis_mac_tlast	(tx_axis_mac_tlast),
			   .tx_axis_mac_tuser	(tx_axis_mac_tuser),
			   .ofm_out_fsm_dbg	(ofm_out_fsm_dbg[3:0]),
			   // Inputs
			   .tx_clk		(tx_clk),
			   .tx_reset		(tx_reset),
			   .ctrl_fifo_rdata	(ctrl_fifo_rdata[63:0]),
			   .ctrl_fifo_empty	(ctrl_fifo_empty),
			   .data_fifo_rdata	(data_fifo_rdata[72:0]),
			   .data_fifo_empty	(data_fifo_empty),
			   .tx_axis_mac_tready	(tx_axis_mac_tready));
   
endmodule
// 
// axi_eth_ofm.v ends here
