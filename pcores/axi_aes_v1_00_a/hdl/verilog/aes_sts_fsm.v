// aes_sts_fsm.v --- 
// 
// Filename: aes_sts_fsm.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sat Aug 24 14:20:39 2013 (-0700)
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
`timescale 1 ps / 100 fs
module aes_sts_fsm (/*AUTOARG*/
   // Outputs
   s_axis_s2mm_sts_tdata, s_axis_s2mm_sts_tkeep,
   s_axis_s2mm_sts_tvalid, s_axis_s2mm_sts_tlast, aes_sts_ready,
   aes_sts_dbg,
   // Inputs
   m_axi_mm2s_aclk, m_axi_s2mm_aclk, s2mm_sts_reset_out_n,
   s_axis_s2mm_sts_tready, aes_s2mm_sof, aes_s2mm_eof
   );
   parameter C_S_AXIS_S2MM_STS_TDATA_WIDTH = 32;
   parameter C_FAMILY = "virtex6";
   
   input m_axi_mm2s_aclk;
   input m_axi_s2mm_aclk;
   
   input 					   s2mm_sts_reset_out_n;
   output [C_S_AXIS_S2MM_STS_TDATA_WIDTH-1:0] 	   s_axis_s2mm_sts_tdata;
   output [(C_S_AXIS_S2MM_STS_TDATA_WIDTH/8)-1:0]  s_axis_s2mm_sts_tkeep;
   output 					   s_axis_s2mm_sts_tvalid;
   output 					   s_axis_s2mm_sts_tlast;
   input 					   s_axis_s2mm_sts_tready;

   output 					   aes_sts_ready;
   input 					   aes_s2mm_sof;
   input 					   aes_s2mm_eof;

   output [31:0] 				   aes_sts_dbg;
   /***************************************************************************/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			aes_sts_ready;
   // End of automatics


   wire [C_S_AXIS_S2MM_STS_TDATA_WIDTH-1:0] s_axis_s2mm_sts_tdata;
   wire 				    s_axis_s2mm_sts_tlast;
   /***************************************************************************/
   localparam [2:0] // synopsys enum state_info
     S_IDLE = 3'h0,
     S_SOF  = 3'h1,
     S_DATA = 3'h2,
     S_EOF  = 3'h3,
     S_DONE = 3'h4;
   reg [2:0] // synopsys enum state_info
	     state, state_ns;
   always @(posedge m_axi_mm2s_aclk)
     begin
	if (~s2mm_sts_reset_out_n)
	  begin
	     state <= #1 S_IDLE;
	  end
	else
	  begin
	     state <= #1 state_ns;
	  end
     end // always @ (posedge m_axi_mm2s_aclk)
   wire sts_eof_fi;
   reg 	sts_eof_fo;
   always @(*)
     begin
	state_ns = state;
	case (state)
	  S_IDLE: if (aes_s2mm_sof)
	    begin
	       state_ns = S_DATA;
	    end
	  S_DATA: if (aes_s2mm_eof)
	    begin
	       state_ns = S_EOF;
	    end
	  S_EOF: if (sts_eof_fi)
	    begin
	       state_ns = S_DONE;
	    end
	  S_DONE: if (sts_eof_fo)
	    begin
	       state_ns = S_IDLE;
	    end
	endcase
     end // always @ (*)
   localparam C_STS_CNT = 4'h4;
   reg [3:0] 				sts_cnt;
   reg 					sts_wr_en;
   reg 					sts_wr_last;
   reg [31:0] 				sts_wr_din;
   always @(posedge m_axi_mm2s_aclk)
     begin
	if (state == S_IDLE)
	  begin
	     sts_cnt <= #1 C_STS_CNT;
	  end
	else if (state == S_EOF)
	  begin
	     sts_cnt <= #1 sts_cnt - 1'b1;
	  end
     end // always @ (posedge m_axi_mm2s_aclk)
   assign sts_eof_fi = sts_cnt == 0;
   always @(posedge m_axi_mm2s_aclk)
     begin
	if (state == S_DATA && aes_s2mm_eof)
	  begin
	     sts_wr_din <= #1 32'h5000_0000;
	  end
	else
	  begin
	     sts_wr_din <= #1 32'h0;
	  end
     end // always @ (posedge m_axi_mm2s_aclk)
   always @(posedge m_axi_mm2s_aclk)
     begin
	sts_wr_en   <= #1 (state == S_DATA && aes_s2mm_eof) | (state == S_EOF);
	sts_wr_last <= #1 (state == S_EOF  && sts_eof_fi);
	aes_sts_ready<= #1 state == S_IDLE || state == S_DATA;
	sts_eof_fo  <= #1 (state == S_DONE &&
			   s_axis_s2mm_sts_tvalid &&
			   s_axis_s2mm_sts_tready &&
			   s_axis_s2mm_sts_tlast);
     end
   wire sts_rd_empty;
   axi_async_fifo #(.C_FAMILY              (C_FAMILY),
		    .C_FIFO_DEPTH          (256),
		    .C_PROG_FULL_THRESH    (128),
		    .C_DATA_WIDTH          (33),
		    .C_PTR_WIDTH           (8),
		    .C_MEMORY_TYPE         (1),
		    .C_COMMON_CLOCK        (1),
		    .C_IMPLEMENTATION_TYPE (0),
		    .C_SYNCHRONIZER_STAGE  (2))
   sts_fifo (.rst      (~s2mm_prmry_reset_out_n),
	     .wr_clk   (m_axi_mm2s_aclk),
	     .rd_clk   (m_axi_mm2s_aclk),
	     .sync_clk (m_axi_mm2s_aclk),
	     .din      ({sts_wr_last, sts_wr_din}),
	     .wr_en    (sts_wr_en),
	     .rd_en    (s_axis_s2mm_sts_tready & s_axis_s2mm_sts_tvalid),
	     .dout     ({s_axis_s2mm_sts_tlast,  s_axis_s2mm_sts_tdata}),
	     .full     (),
	     .empty    (sts_rd_empty),
	     .prog_full());
   assign s_axis_s2mm_sts_tvalid = ~sts_rd_empty;
   assign s_axis_s2mm_sts_tkeep  = 4'hf;

   assign aes_sts_dbg[7:0] = state;
   /***************************************************************************/
   /*AUTOASCIIENUM("state", "state_ascii", "S_")*/
   // Beginning of automatic ASCII enum decoding
   reg [31:0]		state_ascii;		// Decode of state
   always @(state) begin
      case ({state})
	S_IDLE:   state_ascii = "idle";
	S_SOF:    state_ascii = "sof ";
	S_DATA:   state_ascii = "data";
	S_EOF:    state_ascii = "eof ";
	S_DONE:   state_ascii = "done";
	default:  state_ascii = "%Err";
      endcase
   end
   // End of automatics
endmodule
// 
// aes_sts_fsm.v ends here
