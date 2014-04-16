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
   ctrl_fifo_wdata, ctrl_fifo_wren, ifm_out_fsm_dbg,
   // Inputs
   s2mm_clk, s2mm_resetn, data_fifo_rdata, info_fifo_rdata,
   info_fifo_empty, good_fifo_afull, ctrl_fifo_afull
   );
   input s2mm_clk;
   input s2mm_resetn;
   
   input [72:0] data_fifo_rdata;
   output 	data_fifo_rden;
   
   input [7:0]	info_fifo_rdata;
   input 	info_fifo_empty;
   output 	info_fifo_rden;
   
   output [72:0] good_fifo_wdata;
   output 	 good_fifo_wren;
   input 	 good_fifo_afull;

   output [36:0] ctrl_fifo_wdata;
   output 	 ctrl_fifo_wren;
   input 	 ctrl_fifo_afull;

   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [36:0]		ctrl_fifo_wdata;
   reg			ctrl_fifo_wren;
   reg [72:0]		good_fifo_wdata;
   reg			good_fifo_wren;
   reg			info_fifo_rden;
   // End of automatics
   
   localparam [2:0] 		// synopsys enum state_info
     S_IDLE = 3'h0,
     S_WAIT = 3'h1,
     S_DROP = 3'h2,
     S_EOF  = 3'h3,
     S_DONE = 3'h4;
   reg [2:0] // synopsys enum state_info
	     state, state_ns;
   always @(posedge s2mm_clk or negedge s2mm_resetn)
     begin
	if (~s2mm_resetn)
	  begin
	     state <= #1 S_IDLE;
	  end
	else
	  begin
	     state <= #1 state_ns;
	  end
     end // always @ (posedge rx_clk or posedge rx_reset)   
   wire ready_sof = info_fifo_empty == 0 && good_fifo_afull == 0;
   reg [3:0] wcnt;
   always @(*)
     begin
	state_ns = state;
	case (state)
	  S_IDLE: if (ready_sof)
	    begin
	       state_ns = info_fifo_rdata[7] ? S_DROP : S_WAIT;
	    end
	  S_DROP: if (data_fifo_rdata[72])
	    begin
	       state_ns = S_DONE;
	    end
	  S_WAIT: if (data_fifo_rdata[72])
	    begin
	       state_ns = S_EOF;
	    end
	  S_EOF: if (wcnt == 5)
	    begin
	       state_ns = S_DONE;
	    end
	  S_DONE:
	    begin
	       state_ns = S_IDLE;
	    end
	endcase
     end // always @ (*)
 
   reg [7:0] info_fifo_reg;
   always @(posedge s2mm_clk)
     begin
	if (state == S_IDLE)
	  begin
	     info_fifo_reg <= #1 info_fifo_rdata;
	  end
     end
   always @(posedge s2mm_clk)
     begin
	info_fifo_rden <= #1 (state == S_DROP && data_fifo_rdata[72]) ||
			  (state == S_WAIT && data_fifo_rdata[72]);
	good_fifo_wdata<= #1 data_fifo_rdata;
	good_fifo_wren <= #1 state == S_WAIT;
     end
   assign data_fifo_rden = (state == S_WAIT) || (state == S_DROP);

   always @(posedge s2mm_clk)
     begin
	if (state == S_IDLE)
	  begin
	     wcnt <= #1 0;
	  end
	else if (state == S_EOF)
	  begin
	     wcnt <= #1 wcnt + 1'b1;
	  end
     end // always @ (posedge s2mm_clk)
   reg [3:0] good_fifo_byte;
   always @(posedge s2mm_clk)
     begin
	good_fifo_byte <= #1 data_fifo_rdata[71:64] == 8'b0000_0001 ? 4'h1 :
			  data_fifo_rdata[71:64] == 8'b0000_0011 ? 4'h2 :
			  data_fifo_rdata[71:64] == 8'b0000_0111 ? 4'h3 :
			  data_fifo_rdata[71:64] == 8'b0000_1111 ? 4'h4 :
			  data_fifo_rdata[71:64] == 8'b0001_1111 ? 4'h5 :
			  data_fifo_rdata[71:64] == 8'b0011_1111 ? 4'h6 : 
			  data_fifo_rdata[71:64] == 8'b0111_1111 ? 4'h7 :
			  data_fifo_rdata[71:64] == 8'b1111_1111 ? 4'h8 : 4'h0;
     end // always @ (posedge s2mm_clk)
   
   reg [15:0] bytecnt;
   always @(posedge s2mm_clk)
     begin
	if (state == S_IDLE)
	  begin
	     bytecnt <= #1 16'h0;
	  end
	else if (good_fifo_wren)
	  begin
	     bytecnt <= #1 bytecnt + good_fifo_byte;
	  end
     end // always @ (posedge s2mm_clk)
   
   always @(posedge s2mm_clk)
     begin
	ctrl_fifo_wren              <= #1 state == S_EOF;
	case (wcnt)
	  4'h0: begin		// flags
	     ctrl_fifo_wdata[36]    <= #1 1'b0;
	     ctrl_fifo_wdata[35:32] <= #1 4'hf;
	     ctrl_fifo_wdata[31:28] <= #1 4'h5;
	     ctrl_fifo_wdata[27:0]  <= #1 28'h0;
	  end
	  4'h1: begin		// mcast addrU
	     ctrl_fifo_wdata[36]    <= #1 1'b0;
	     ctrl_fifo_wdata[35:32] <= #1 4'hf;
	     ctrl_fifo_wdata[31:0]  <= #1 32'h0;
	  end
	  4'h2: begin		// mcast addrL
	     ctrl_fifo_wdata[36]    <= #1 1'b0;
	     ctrl_fifo_wdata[35:32] <= #1 4'hf;
	     ctrl_fifo_wdata[31:0]  <= #1 32'h0;
	  end
	  4'h3: begin		// ... flags
	     ctrl_fifo_wdata[36]    <= #1 1'b0;
	     ctrl_fifo_wdata[35:32] <= #1 4'hf;
	     ctrl_fifo_wdata[31:8]  <= #1 32'h0;
	     ctrl_fifo_wdata[7]     <= #1~info_fifo_reg[0];
	     ctrl_fifo_wdata[6]     <= #1 info_fifo_reg[0];
	     ctrl_fifo_wdata[5:0]   <= #1 6'h0;
	  end
	  4'h4: begin		// T_L_TPID , RxCsRaw
	     ctrl_fifo_wdata[36]    <= #1 1'b0;
	     ctrl_fifo_wdata[35:32] <= #1 4'hf;
	     ctrl_fifo_wdata[31:0]  <= #1 32'h0;
	  end
	  4'h5: begin		// vlantag, RxByteCnt
	     ctrl_fifo_wdata[36]    <= #1 1'b1;
	     ctrl_fifo_wdata[35:32] <= #1 4'hf;
	     ctrl_fifo_wdata[31:16] <= #1 32'h0;
	     ctrl_fifo_wdata[15:0]  <= #1 bytecnt;
	  end
	  default: begin
	     ctrl_fifo_wdata        <= #1 35'h0;
	  end
	endcase
     end // always @ (posedge s2mm_clk)

   output [3:0] ifm_out_fsm_dbg;
   assign ifm_out_fsm_dbg[2:0] = state;
   assign ifm_out_fsm_dbg[3]   = good_fifo_afull;
endmodule
// 
// ifm_out_fsm.v ends here
