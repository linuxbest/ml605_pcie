// ifm_out_fsm.v --- 
// 
// Filename: ifm_out_fsm.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Mon Apr 14 23:40:50 2014 (-0700)
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
module ifm_out_fsm (/*AUTOARG*/
   // Outputs
   data_fifo_rden, info_fifo_rden, good_fifo_wdata, good_fifo_wren,
   // Inputs
   sys_clk, rx_reset, data_fifo_rdata, info_fifo_rdata,
   info_fifo_empty, good_fifo_afull
   );
   input sys_clk;
   input rx_reset;
   
   input [72:0] data_fifo_rdata;
   output 	data_fifo_rden;
   
   input 	info_fifo_rdata;
   input 	info_fifo_empty;
   output 	info_fifo_rden;
   
   output [72:0] good_fifo_wdata;
   output 	 good_fifo_wren;
   input 	 good_fifo_afull;

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [72:0]		good_fifo_wdata;
   reg			good_fifo_wren;
   reg			info_fifo_rden;
   // End of automatics
   
   localparam [1:0] 		// synopsys enum state_info
     S_IDLE = 2'h0,
     S_WAIT = 2'h1,
     S_DROP = 2'h2,
     S_EOF  = 2'h3;
   reg [1:0] // synopsys enum state_info
	     state, state_ns;
   always @(posedge sys_clk or posedge rx_reset)
     begin
	if (rx_reset)
	  begin
	     state <= #1 S_IDLE;
	  end
	else
	  begin
	     state <= #1 state_ns;
	  end
     end // always @ (posedge rx_clk or posedge rx_reset)   
   wire ready_sof = info_fifo_empty == 0 && good_fifo_afull == 0;
   always @(*)
     begin
	state_ns = state;
	case (state)
	  S_IDLE: if (ready_sof)
	    begin
	       state_ns = info_fifo_rdata ? S_WAIT : S_DROP;
	    end
	  S_DROP: if (data_fifo_rdata[72])
	    begin
	       state_ns = S_EOF;
	    end
	  S_WAIT: if (data_fifo_rdata[72])
	    begin
	       state_ns = S_EOF;	       
	    end
	  S_EOF:
	    state_ns = S_IDLE;
	endcase
     end // always @ (*)
   always @(posedge sys_clk)
     begin
	info_fifo_rden <= #1 (state == S_DROP && data_fifo_rdata[72]) ||
			  (state == S_WAIT && data_fifo_rdata[72]);
	good_fifo_wdata<= #1 data_fifo_rdata;
	good_fifo_wren <= #1 ((state == S_IDLE && ready_sof && info_fifo_rdata) ||
			      (state == S_WAIT));
     end
   assign data_fifo_rden = (state == S_IDLE && ready_sof) ||
			   (state == S_WAIT) ||
			   (state == S_DROP);
endmodule
// 
// ifm_out_fsm.v ends here
