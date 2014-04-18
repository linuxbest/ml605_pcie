// ofm_out_fsm.v --- 
// 
// Filename: ofm_out_fsm.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Tue Apr 15 19:14:03 2014 (-0700)
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
module ofm_out_fsm (/*AUTOARG*/
   // Outputs
   ctrl_fifo_rden, data_fifo_rden, tx_axis_mac_tdata,
   tx_axis_mac_tkeep, tx_axis_mac_tvalid, tx_axis_mac_tlast,
   tx_axis_mac_tuser, ofm_out_fsm_dbg,
   // Inputs
   tx_clk, mm2s_resetn, ctrl_fifo_rdata, ctrl_fifo_empty,
   data_fifo_rdata, data_fifo_empty, tx_axis_mac_tready
   );
   input tx_clk;
   input mm2s_resetn;
   
   input [33:0] ctrl_fifo_rdata;
   input 	ctrl_fifo_empty;
   output 	ctrl_fifo_rden;
   
   input [72:0] data_fifo_rdata;
   input 	data_fifo_empty;
   output 	data_fifo_rden;

   output [63:0] tx_axis_mac_tdata;
   output [7:0]  tx_axis_mac_tkeep;
   output 	 tx_axis_mac_tvalid;
   output 	 tx_axis_mac_tlast;
   output 	 tx_axis_mac_tuser;
   input 	 tx_axis_mac_tready;

   /*AUTOREG*/

   localparam [2:0] 		// synopsys enum state_info
     S_IDLE = 3'h0,
     S_SOF  = 3'h1,
     S_DATA = 3'h2,
     S_EOF  = 3'h3;
   reg [2:0] 	// synopsys enum state_info
		state, state_ns;
   always @(posedge tx_clk or negedge mm2s_resetn)
     begin
	if (~mm2s_resetn)
	  begin
	     state <= #1 S_IDLE;
	  end
	else
	  begin
	     state <= #1 state_ns;
	  end
     end // always @ (posedge tx_clk or mm2s_resetn)
   always @(*)
     begin
	state_ns = state;
	case (state)
	  S_IDLE: if (~ctrl_fifo_empty)
	    begin
	       state_ns = S_SOF;
	    end
	  S_SOF: if (tx_axis_mac_tvalid && tx_axis_mac_tready)
	    begin
	       state_ns = S_DATA;
	    end
	  S_DATA: if (tx_axis_mac_tvalid && tx_axis_mac_tready && data_fifo_rdata[72])
	    begin
	       state_ns = S_EOF;
	    end
	  S_EOF:
	    begin
	       state_ns = S_IDLE;
	    end
	endcase
     end // always @ (*)

   // data fifo side
   assign tx_axis_mac_tdata  =  data_fifo_rdata[63:0];
   assign tx_axis_mac_tkeep  =  data_fifo_rdata[71:64];
   assign tx_axis_mac_tlast  =  data_fifo_rdata[72];
   assign tx_axis_mac_tvalid = ~data_fifo_empty && ~ctrl_fifo_empty;
   assign tx_axis_mac_tuser  = 1'b0;
   assign data_fifo_rden     = tx_axis_mac_tvalid && tx_axis_mac_tready;
   
   // ctrl fifo side
   assign ctrl_fifo_rden     = state == S_EOF;

   output [3:0] ofm_out_fsm_dbg;
   assign ofm_out_fsm_dbg = state;
   
   /*AUTOASCIIENUM("state", "state_ascii", "S_")*/   
   // Beginning of automatic ASCII enum decoding
   reg [31:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	S_IDLE:   state_ascii = "idle";
	S_SOF:    state_ascii = "sof ";
	S_DATA:   state_ascii = "data";
	S_EOF:    state_ascii = "eof ";
	default:  state_ascii = "%Err";
      endcase
   end
   // End of automatics
endmodule
// 
// ofm_out_fsm.v ends here
