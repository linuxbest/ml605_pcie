// ifm_in_fsm.v --- 
// 
// Filename: ifm_in_fsm.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Mon Apr 14 23:25:09 2014 (-0700)
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
module ifm_in_fsm (/*AUTOARG*/
   // Outputs
   rx_axis_mac_tready, data_fifo_wdata, data_fifo_wren,
   info_fifo_wdata, info_fifo_wren,
   // Inputs
   rx_clk, rx_reset, rx_axis_mac_tdata, rx_axis_mac_tkeep,
   rx_axis_mac_tlast, rx_axis_mac_tuser, rx_axis_mac_tvalid,
   data_fifo_afull
   );
   input rx_clk;
   input rx_reset;

   input [63:0] rx_axis_mac_tdata;
   input [ 7:0] rx_axis_mac_tkeep;
   input        rx_axis_mac_tlast;
   input        rx_axis_mac_tuser;
   input 	rx_axis_mac_tvalid;
   output 	rx_axis_mac_tready;   

   output [72:0] data_fifo_wdata;
   output 	 data_fifo_wren;
   input 	 data_fifo_afull;

   output 	 info_fifo_wdata;
   output 	 info_fifo_wren;

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [72:0]		data_fifo_wdata;
   reg			data_fifo_wren;
   reg			info_fifo_wdata;
   reg			info_fifo_wren;
   reg			rx_axis_mac_tready;
   // End of automatics
   
   localparam [1:0] 		// synopsys enum state_info
     S_IDLE = 2'h0,
     S_WAIT = 2'h1,
     S_DROP = 2'h2;
   reg [1:0] // synopsys enum state_info
	     state, state_ns;
   always @(posedge rx_clk or posedge rx_reset)
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
   always @(*)
     begin
	state_ns = state;
	case (state)
	  S_IDLE: if (rx_axis_mac_tvalid)
	    begin
	       state_ns = data_fifo_afull ? S_DROP : S_WAIT;
	    end
	  S_DROP: if (rx_axis_mac_tvalid & rx_axis_mac_tlast)
	    begin
	       state_ns = S_IDLE;
	    end
	  S_WAIT: if (rx_axis_mac_tvalid & rx_axis_mac_tlast)
	    begin
	       state_ns = S_IDLE;
	    end
	endcase
     end // always @ (*)
   
   always @(posedge rx_clk)
     begin
	data_fifo_wren        <= #1 ((state == S_IDLE && rx_axis_mac_tvalid && ~data_fifo_afull) ||
				     (state == S_WAIT && rx_axis_mac_tvalid));
	data_fifo_wdata[63:0] <= #1 rx_axis_mac_tdata[63:0];
	data_fifo_wdata[71:64]<= #1 rx_axis_mac_tkeep[7:0];
	data_fifo_wdata[72]   <= #1 rx_axis_mac_tlast;

	info_fifo_wren        <= #1 (state == S_WAIT && rx_axis_mac_tvalid && rx_axis_mac_tlast);
	info_fifo_wdata       <= #1 rx_axis_mac_tuser;
     end
   
endmodule
// 
// ifm_in_fsm.v ends here
