// aes_mm2s.v --- 
// 
// Filename: aes_mm2s.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sat Aug 24 18:03:28 2013 (-0700)
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
module aes_mm2s(/*AUTOARG*/
   // Outputs
   m_axis_mm2s_tready, s_axis_s2mm_tdata, s_axis_s2mm_tkeep,
   s_axis_s2mm_tvalid, s_axis_s2mm_tlast, s_axis_s2mm_tuser,
   s_axis_s2mm_tid, s_axis_s2mm_tdest, aes_s2mm_eof_empty,
   aes_s2mm_eof_full,
   // Inputs
   m_axi_mm2s_aclk, mm2s_prmry_reset_out_n, m_axis_mm2s_tdata,
   m_axis_mm2s_tkeep, m_axis_mm2s_tvalid, m_axis_mm2s_tlast,
   m_axis_mm2s_tuser, m_axis_mm2s_tid, m_axis_mm2s_tdest,
   s2mm_prmry_reset_out_n, s_axis_s2mm_tready, aes_s2mm_eof_rd
   );
   parameter C_FAMILY = "virtex6";
   parameter C_INSTANCE = "axi_aes_0";
   
   parameter C_M_AXIS_MM2S_TDATA_WIDTH = 128;
   parameter C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH = 32;
   
   parameter C_S_AXIS_S2MM_STS_TDATA_WIDTH = 32;
   parameter C_S_AXIS_S2MM_TDATA_WIDTH = 128;

   input m_axi_mm2s_aclk;
   
   input 				mm2s_prmry_reset_out_n;
   input [C_M_AXIS_MM2S_TDATA_WIDTH-1:0] m_axis_mm2s_tdata;
   input [(C_M_AXIS_MM2S_TDATA_WIDTH/8)-1:0] m_axis_mm2s_tkeep;
   input 				     m_axis_mm2s_tvalid;
   input 				     m_axis_mm2s_tlast;
   input [3:0] 				     m_axis_mm2s_tuser;
   input [4:0] 				     m_axis_mm2s_tid;
   input [4:0] 				     m_axis_mm2s_tdest;
   output 				     m_axis_mm2s_tready;


   input 					   s2mm_prmry_reset_out_n;
   output [C_S_AXIS_S2MM_TDATA_WIDTH-1:0] 	   s_axis_s2mm_tdata;
   output [(C_S_AXIS_S2MM_TDATA_WIDTH/8)-1:0]      s_axis_s2mm_tkeep;
   output 					   s_axis_s2mm_tvalid;
   output 					   s_axis_s2mm_tlast;
   output [3:0] 				   s_axis_s2mm_tuser;
   output [4:0] 				   s_axis_s2mm_tid;
   output [4:0] 				   s_axis_s2mm_tdest;
   input 					   s_axis_s2mm_tready;

   output 					   aes_s2mm_eof_empty;
   output 					   aes_s2mm_eof_full;
   input 					   aes_s2mm_eof_rd;
   /***************************************************************************/
   /*AUTOREG*/

   reg [127:0] 					   aes_din;
   reg [255:0] 					   aes_key;
   always @(posedge m_axi_mm2s_aclk)
     begin
	aes_key <= #1 256'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
     end

   wire mm2s_handshake;
   assign mm2s_handshake = m_axis_mm2s_tvalid && m_axis_mm2s_tready;
   always @(posedge m_axi_mm2s_aclk)
     begin
	if (~mm2s_prmry_reset_out_n)
	  begin
	     aes_din <= #1 128'h0;
	  end
	else if (mm2s_handshake)
	  begin
	     aes_din <= #1 m_axis_mm2s_tdata;
	  end
     end // always @ (posedge m_axi_mm2s_aclk)

   wire [127:0] aes_din_i;
   wire [127:0] aes_out_i;
   wire [127:0] aes_out_w;
   reg [127:0] 	aes_out;
   always @(posedge m_axi_mm2s_aclk)
     begin
	aes_out <= #1 aes_out_w;
     end
   aes_256 aes_256(.clk  (m_axi_mm2s_aclk),
		   .state(aes_din_i),
		   .key  (aes_key),
		   .out  (aes_out_i));
   genvar i;
   generate
      for (i = 0; i < 128; i = i + 8) begin: swap_aes_out
	 assign aes_out_w[127-i:120-i] = aes_out_i[i+7:i];
	 assign aes_din_i[127-i:120-i] = aes_din[i+7:i];
      end
   endgenerate
   
   localparam C_SNUM = 29;
   reg [C_SNUM:0] sfifo_r;
   reg [C_SNUM:0] lfifo_r;
   reg sfifo_o;
   reg lfifo_o;
   always @(posedge m_axi_mm2s_aclk)
     begin
	sfifo_r <= #1 {sfifo_r[C_SNUM-1:0], mm2s_handshake};
	sfifo_o <= #1  sfifo_r[C_SNUM];

	lfifo_r <= #1 {lfifo_r[C_SNUM-1:0], m_axis_mm2s_tlast};
	lfifo_o <= #1  lfifo_r[C_SNUM];
     end

   wire aes_rd_full;
   wire aes_rd_empty;
   wire [C_S_AXIS_S2MM_TDATA_WIDTH-1:0] s_axis_s2mm_tdata;
   wire 				s_axis_s2mm_tlast;   
   axi_async_fifo #(.C_FAMILY              (C_FAMILY),
		    .C_FIFO_DEPTH          (256),
		    .C_PROG_FULL_THRESH    (128),
		    .C_DATA_WIDTH          (129),
		    .C_PTR_WIDTH           (8),
		    .C_MEMORY_TYPE         (1),
		    .C_COMMON_CLOCK        (1),
		    .C_IMPLEMENTATION_TYPE (0),
		    .C_SYNCHRONIZER_STAGE  (2))
   aes_fifo (.rst      (~mm2s_prmry_reset_out_n),
	     .wr_clk   (m_axi_mm2s_aclk),
	     .rd_clk   (m_axi_mm2s_aclk),
	     .sync_clk (m_axi_mm2s_aclk),
	     .din      ({lfifo_o, aes_out}),
	     .wr_en    (sfifo_o),
	     .rd_en    (s_axis_s2mm_tready & s_axis_s2mm_tvalid),
	     .dout     ({s_axis_s2mm_tlast, s_axis_s2mm_tdata}),
	     .full     (),
	     .empty    (aes_rd_empty),
	     .prog_full(aes_rd_full));
   assign m_axis_mm2s_tready = ~aes_rd_full && ~aes_s2mm_eof_full;
   assign s_axis_s2mm_tvalid = ~aes_rd_empty;
   /***************************************************************************/
   assign s_axis_s2mm_tdest = 0;
   assign s_axis_s2mm_tuser = 0;
   assign s_axis_s2mm_tid = 0;
   assign s_axis_s2mm_tkeep = 16'hffff;

   /***************************************************************************/
   reg 					aes_s2mm_eof;
   always @(posedge m_axi_mm2s_aclk)
     begin
	aes_s2mm_eof <= #1 s_axis_s2mm_tready & s_axis_s2mm_tvalid & s_axis_s2mm_tlast;
     end
   wire 					   aes_s2mm_eof_empty;
   wire 					   aes_s2mm_eof_full;   
   axi_async_fifo #(.C_FAMILY              (C_FAMILY),
		    .C_FIFO_DEPTH          (256),
		    .C_PROG_FULL_THRESH    (128),
		    .C_DATA_WIDTH          (9),
		    .C_PTR_WIDTH           (8),
		    .C_MEMORY_TYPE         (1),
		    .C_COMMON_CLOCK        (1),
		    .C_IMPLEMENTATION_TYPE (0),
		    .C_SYNCHRONIZER_STAGE  (2))
   eof_fifo (.rst      (~mm2s_prmry_reset_out_n),
	     .wr_clk   (m_axi_mm2s_aclk),
	     .rd_clk   (m_axi_mm2s_aclk),
	     .sync_clk (m_axi_mm2s_aclk),
	     .din      (9'h0),
	     .wr_en    (aes_s2mm_eof),
	     .rd_en    (aes_s2mm_eof_rd),
	     .dout     (),
	     .full     (),
	     .empty    (aes_s2mm_eof_empty),
	     .prog_full(aes_s2mm_eof_full));   
endmodule
// 
// aes_mm2s.v ends here
