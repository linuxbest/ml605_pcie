// ofm_in_fsm.v --- 
// 
// Filename: ofm_in_fsm.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Tue Apr 15 18:28:08 2014 (-0700)
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
module ofm_in_fsm (/*AUTOARG*/
   // Outputs
   txd_tready, txc_tready, ctrl_fifo_wdata, ctrl_fifo_wren,
   data_fifo_wdata, data_fifo_wren, TxCsBegin, TxCsInsert, TxCsInit,
   ofm_in_fsm_dbg,
   // Inputs
   mm2s_clk, mm2s_resetn, txd_tdata, txd_tkeep, txd_tvalid, txd_tlast,
   txc_tdata, txc_tkeep, txc_tvalid, txc_tlast, ctrl_fifo_afull,
   data_fifo_afull, TxSum_valid, TxSum
   );
   input mm2s_clk;
   input mm2s_resetn;

   input [63:0] txd_tdata;
   input [7:0] 	txd_tkeep;
   input 	txd_tvalid;
   input 	txd_tlast;
   output 	txd_tready;

   input [31:0] txc_tdata;
   input [3:0] 	txc_tkeep;
   input 	txc_tvalid;
   input 	txc_tlast;
   output 	txc_tready;

   input 	ctrl_fifo_afull;
   output [33:0] ctrl_fifo_wdata;
   output 	 ctrl_fifo_wren;
   
   input 	data_fifo_afull;
   output [72:0] data_fifo_wdata;
   output 	 data_fifo_wren;

   input 	 TxSum_valid;
   input [15:0]  TxSum;
   output [15:0] TxCsBegin;
   output [15:0] TxCsInsert;
   output [15:0] TxCsInit;
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [33:0]		ctrl_fifo_wdata;
   reg			ctrl_fifo_wren;
   reg [72:0]		data_fifo_wdata;
   reg			data_fifo_wren;
   // End of automatics

   localparam [1:0] 		// synopsys enum state_info
     S_IDLE = 2'h0,
     S_CTRL = 2'h1,
     S_WAIT = 2'h2,
     S_DATA = 2'h3;
   reg [1:0] 	// synopsys enum state_info
		state, state_ns;
   always @(posedge mm2s_clk or negedge mm2s_resetn)
     begin
	if (~mm2s_resetn)
	  begin
	     state <= #1 S_IDLE;
	  end
	else
	  begin
	     state <= #1 state_ns;
	  end
     end // always @ (posedge mm2s_clk or negedge mm2s_resetn)

   reg tx_ok;
   reg ctrl_fifo_afull_reg;
   reg data_fifo_afull_reg;
   always @(*)
     begin
	state_ns = state;
	case (state)
	  S_IDLE: if (txc_tvalid && ~ctrl_fifo_afull_reg)
	    begin
	       state_ns = S_CTRL;
	    end
	  S_CTRL: if (txc_tvalid && txc_tlast)
	    begin
	       state_ns = S_WAIT;
	    end
	  S_WAIT: if (txd_tvalid && ~data_fifo_afull_reg)
	    begin
	       state_ns = S_DATA;
	    end
	  S_DATA: if (txd_tvalid && txd_tlast)
	    begin
	       state_ns = S_IDLE;
	    end
	endcase
     end // always @ (*)

   // ctrl data extract
   reg [2:0] tcnt;
   always @(posedge mm2s_clk)
     begin
	if (state == S_IDLE)
	  begin
	     tcnt <= #1 0;
	  end
	else if (txc_tready && txc_tvalid)
	  begin
	     tcnt <= #1 tcnt + 1'b1;	     
	  end
     end // always @ (posedge mm2s_clk)
   always @(posedge mm2s_clk)
     begin
	ctrl_fifo_afull_reg <= #1 ctrl_fifo_afull;
     end
   assign txc_tready = state == S_CTRL;

   // Only support Paritial transmit checksum offloading
   // 1) TxCsCntrl must be 2'b00 or 2'b01
   // 2) TxCsBegin  >= 14
   // 3) TxCsInsert >   8
   reg [3:0]  TxFlag;
   reg [15:0] TxCsBegin;
   reg [15:0] TxCsInsert;
   reg [15:0] TxCsInit;
   reg [1:0]  TxCsCntrl;
   always @(posedge mm2s_clk)
     begin
	if (txc_tready && txc_tvalid)
	  begin
	     case (tcnt)
	       3'h0: begin
		  TxFlag      <= #1 txc_tdata[31:28]; 
	       end
	       3'h1: TxCsCntrl<= #1 txc_tdata[1:0];
	       3'h2: begin 
		  TxCsBegin   <= #1 {txc_tdata[31:17], 1'b0}; 
		  TxCsInsert  <= #1 {txc_tdata[15:01], 1'b0};
	       end
	       3'h3: TxCsInit <= #1 txc_tdata[15:0];
	     endcase
	  end
     end // always @ (posedge mm2s_clk)

   always @(posedge mm2s_clk or negedge mm2s_resetn)
     begin
	if (~mm2s_resetn)
	  begin
	     ctrl_fifo_wren <= #1 1'b0;
	     data_fifo_wren <= #1 1'b0;
	  end
	else
	  begin
	     ctrl_fifo_wren <= #1 TxSum_valid;
	     data_fifo_wren <= #1 txd_tready && txd_tvalid;
	  end
     end // always @ (posedge mm2s_clk)

   // we caculate the CheckSum in mm2s clock domain,
   // insert the TxSum into stream in tx clock domain.
   always @(posedge mm2s_clk)
     begin
	if (txd_tready && txd_tvalid)
	  begin
	     ctrl_fifo_wdata[15:0]  <= #1 TxSum;
	     ctrl_fifo_wdata[31:16] <= #1 TxCsInsert;
	     ctrl_fifo_wdata[33:32] <= #1 TxCsCntrl;
	  end
     end
   
   always @(posedge mm2s_clk)
     begin
	data_fifo_afull_reg <= #1 data_fifo_afull;
     end
   assign txd_tready = state == S_DATA;
   always @(posedge mm2s_clk)
     begin
	data_fifo_wdata[63:0]  <= #1 txd_tdata;
	data_fifo_wdata[71:64] <= #1 txd_tkeep;
	data_fifo_wdata[72]    <= #1 txd_tlast;
     end

   output [3:0]   ofm_in_fsm_dbg;
   assign ofm_in_fsm_dbg = state;
   /*AUTOASCIIENUM("state", "state_ascii", "S_")*/
   // Beginning of automatic ASCII enum decoding
   reg [31:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	S_IDLE:   state_ascii = "idle";
	S_CTRL:   state_ascii = "ctrl";
	S_WAIT:   state_ascii = "wait";
	S_DATA:   state_ascii = "data";
	default:  state_ascii = "%Err";
      endcase
   end
   // End of automatics
endmodule
// 
// ofm_in_fsm.v ends here
