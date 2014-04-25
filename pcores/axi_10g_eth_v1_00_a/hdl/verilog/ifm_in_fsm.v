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
   rx_axis_mac_tready, data_fifo_wdata, data_fifo_wren, pause_req,
   pause_val, info_fifo_wdata, info_fifo_wren, ifm_in_fsm_dbg,
   // Inputs
   rx_clk, sys_rst, rx_axis_mac_tdata, rx_axis_mac_tkeep,
   rx_axis_mac_tlast, rx_axis_mac_tuser, rx_axis_mac_tvalid,
   data_fifo_afull, wr_data_count, info_fifo_wfull
   );
   input rx_clk;
   input sys_rst;

   input [63:0] rx_axis_mac_tdata;
   input [ 7:0] rx_axis_mac_tkeep;
   input        rx_axis_mac_tlast;
   input        rx_axis_mac_tuser;
   input 	rx_axis_mac_tvalid;
   output 	rx_axis_mac_tready;   

   output [72:0] data_fifo_wdata;
   output 	 data_fifo_wren;
   input 	 data_fifo_afull;
   input [11:0]  wr_data_count;

   output 	 pause_req;
   output [15:0] pause_val;
   
   output [7:0]  info_fifo_wdata;
   output 	 info_fifo_wren;
   input         info_fifo_wfull;

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [72:0]		data_fifo_wdata;
   reg			data_fifo_wren;
   reg [7:0]		info_fifo_wdata;
   reg			info_fifo_wren;
   reg			pause_req;
   reg [15:0]		pause_val;
   // End of automatics

   localparam [1:0] 		// synopsys enum state_info
     S_IDLE = 2'h0,
     S_WAIT = 2'h1,
     S_DROP = 2'h2;
   reg [1:0] // synopsys enum state_info
	     state, state_ns;
   always @(posedge rx_clk or posedge sys_rst)
     begin
	if (sys_rst)
	  begin
	     state <= #1 S_IDLE;
	  end
	else
	  begin
	     state <= #1 state_ns;
	  end
     end // always @ (posedge rx_clk or posedge sys_rst)
   always @(*)
     begin
	state_ns = state;
	case (state)
	  S_IDLE: if (rx_axis_mac_tvalid)
	    begin
	       state_ns = (data_fifo_afull || info_fifo_wfull) ? S_DROP : S_WAIT;
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

   assign rx_axis_mac_tready = 1'b1;
   always @(posedge rx_clk or posedge sys_rst)
     begin
	if (sys_rst)
	  begin
	     data_fifo_wren <= #1 1'b0;
	     info_fifo_wren <= #1 1'b0;
	  end
	else
	  begin
	     data_fifo_wren <= #1 ((state == S_IDLE && rx_axis_mac_tvalid && ~data_fifo_afull) ||
				   (state == S_WAIT && rx_axis_mac_tvalid));
	     info_fifo_wren <= #1 (state == S_WAIT && rx_axis_mac_tvalid && rx_axis_mac_tlast);
	  end
     end // always @ (posedge rx_clk or posedge sys_rst)
   always @(posedge rx_clk)
     begin
	data_fifo_wdata[63:0] <= #1 rx_axis_mac_tdata[63:0];
	data_fifo_wdata[71:64]<= #1 rx_axis_mac_tkeep[7:0];
	data_fifo_wdata[72]   <= #1 rx_axis_mac_tlast;
	info_fifo_wdata[0]    <= #1 rx_axis_mac_tuser;
	info_fifo_wdata[7:1]  <= #1 0;
     end // always @ (posedge rx_clk)

   always @(posedge rx_clk)
     begin
	pause_req <= #1 wr_data_count[11] | wr_data_count[10];
	pause_val <= #1 16'h80;	// pause for 8x128=1024 data cycle
     end
   
   output [3:0] ifm_in_fsm_dbg;
   assign ifm_in_fsm_dbg = state;
endmodule
// 
// ifm_in_fsm.v ends here
