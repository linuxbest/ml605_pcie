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
   ctrl_fifo_rden, data_fifo_rden, tx_fifo_wdata, tx_fifo_wren,
   ofm_out_fsm_dbg,
   // Inputs
   tx_clk, mm2s_resetn, ctrl_fifo_rdata, ctrl_fifo_empty,
   data_fifo_rdata, data_fifo_empty, tx_fifo_afull
   );
   input tx_clk;
   input mm2s_resetn;
   
   input [33:0] ctrl_fifo_rdata;
   input 	ctrl_fifo_empty;
   output 	ctrl_fifo_rden;
   
   input [72:0] data_fifo_rdata;
   input 	data_fifo_empty;
   output 	data_fifo_rden;

   output [72:0] tx_fifo_wdata;
   output 	 tx_fifo_wren;
   input 	 tx_fifo_afull;
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [72:0]		tx_fifo_wdata;
   reg			tx_fifo_wren;
   // End of automatics

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
	  S_SOF: if (~tx_fifo_afull && ~data_fifo_empty)
	    begin
	       state_ns = S_DATA;
	    end
	  S_DATA: if (data_fifo_rdata[72] && ~data_fifo_empty)
	    begin
	       state_ns = S_EOF;
	    end
	  S_EOF:
	    begin
	       state_ns = S_IDLE;
	    end
	endcase
     end // always @ (*)

   wire [15:0] TxCsSum;
   wire [15:0] TxCsInsert;
   wire [1:0]  TxCsCntrl;
   assign TxCsSum    = ctrl_fifo_rdata[15:0];
   assign TxCsInsert = ctrl_fifo_rdata[31:16];
   assign TxCsCntrl  = ctrl_fifo_rdata[33:32];

   reg [15:0] bcnt;
   wire [15:0] next_bcnt;
   wire [3:0]  tdata_bcnt;
   keep_to_cnt tdata_i (.cnt(tdata_bcnt), .keep(data_fifo_rdata[71:64]));   
   assign next_bcnt = bcnt + tdata_bcnt;
   always @(posedge tx_clk)
     begin
	if (state == S_SOF)
	  begin
	     bcnt <= #1 tdata_bcnt;
	  end
	else if (state == S_DATA)
	  begin
	     bcnt <= #1 next_bcnt;
	  end
     end // always @ (posedge mm2s_clk)
   reg insert_hit_reg;
   wire insert_hit;
   always @(posedge tx_clk)
     begin
	if (state == S_SOF)
	  begin
	     insert_hit_reg <= #1 1'b0;
	  end
	else if (~insert_hit_reg)
	  begin
	     insert_hit_reg <= #1 insert_hit;
	  end
     end
   assign insert_hit = (bcnt > TxCsInsert) && ~insert_hit_reg && (TxCsCntrl == 2'b01);
   reg  [3:0] insert_mask;
   wire [3:0] insert_mask_bcnt;
   assign insert_mask_bcnt = bcnt - TxCsInsert;
   always @(*)
   begin
      insert_mask = 4'b0000;
      case (insert_mask_bcnt)
	4'h8: insert_mask = 4'b0001;
	4'h6: insert_mask = 4'b0010;
	4'h4: insert_mask = 4'b0100;
	4'h2: insert_mask = 4'b1000;
      endcase
   end
   reg [72:0] fifo_rdata;
   reg 	      fifo_rden;
   always @(posedge tx_clk)
     begin
	fifo_rdata <= #1 data_fifo_rdata;
	fifo_rden  <= #1 data_fifo_rden;
     end
   assign data_fifo_rden     = (state == S_SOF && ~tx_fifo_afull && ~data_fifo_empty) ||
			       (state == S_DATA && ~data_fifo_empty);
   always @(posedge tx_clk)
     begin
	tx_fifo_wdata[15:00] <= #1 insert_hit && insert_mask[0] ? TxCsSum : fifo_rdata[15:00];
	tx_fifo_wdata[31:16] <= #1 insert_hit && insert_mask[1] ? TxCsSum : fifo_rdata[31:16];
	tx_fifo_wdata[47:32] <= #1 insert_hit && insert_mask[2] ? TxCsSum : fifo_rdata[47:32];
	tx_fifo_wdata[63:48] <= #1 insert_hit && insert_mask[3] ? TxCsSum : fifo_rdata[63:48];	
	tx_fifo_wdata[72:64] <= #1 fifo_rdata[72:64];
	tx_fifo_wren         <= #1 fifo_rden;
     end
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
