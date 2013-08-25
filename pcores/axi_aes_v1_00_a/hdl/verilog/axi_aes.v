// axi_aes.v --- 
// 
// Filename: axi_aes.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Jul 28 16:31:05 2013 (-0700)
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
module axi_aes (/*AUTOARG*/
   // Outputs
   s_axis_s2mm_sts_tvalid, s_axis_s2mm_sts_tlast,
   s_axis_s2mm_sts_tkeep, s_axis_s2mm_sts_tdata, s_axi_lite_wready,
   s_axi_lite_rvalid, s_axi_lite_rresp, s_axi_lite_rdata,
   s_axi_lite_bvalid, s_axi_lite_bresp, s_axi_lite_awready,
   s_axi_lite_arready, m_axis_mm2s_cntrl_tready, aes_sts_ready,
   aes_s2mm_eof_rd, m_axis_mm2s_tready, s_axis_s2mm_tdata,
   s_axis_s2mm_tkeep, s_axis_s2mm_tvalid, s_axis_s2mm_tlast,
   s_axis_s2mm_tuser, s_axis_s2mm_tid, s_axis_s2mm_tdest, axi_intr,
   // Inputs
   s_axis_s2mm_sts_tready, s_axi_lite_wvalid, s_axi_lite_wdata,
   s_axi_lite_rready, s_axi_lite_bready, s_axi_lite_awvalid,
   s_axi_lite_awaddr, s_axi_lite_arvalid, s_axi_lite_araddr,
   s2mm_sts_reset_out_n, mm2s_cntrl_reset_out_n,
   m_axis_mm2s_cntrl_tvalid, m_axis_mm2s_cntrl_tlast,
   m_axis_mm2s_cntrl_tkeep, m_axis_mm2s_cntrl_tdata, s_axi_lite_aclk,
   m_axi_mm2s_aclk, m_axi_s2mm_aclk, axi_resetn,
   mm2s_prmry_reset_out_n, m_axis_mm2s_tdata, m_axis_mm2s_tkeep,
   m_axis_mm2s_tvalid, m_axis_mm2s_tlast, m_axis_mm2s_tuser,
   m_axis_mm2s_tid, m_axis_mm2s_tdest, s2mm_prmry_reset_out_n,
   s_axis_s2mm_tready, s2mm_intr, mm2s_intr
   );
   parameter C_FAMILY = "virtex6";
   parameter C_INSTANCE = "axi_aes_0";
   
   parameter C_S_AXI_LITE_ADDR_WIDTH = 10;
   parameter C_S_AXI_LITE_DATA_WIDTH = 32;
   
   parameter C_M_AXIS_MM2S_TDATA_WIDTH = 128;
   parameter C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH = 32;
   
   parameter C_S_AXIS_S2MM_STS_TDATA_WIDTH = 32;
   parameter C_S_AXIS_S2MM_TDATA_WIDTH = 128;

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH-1:0] m_axis_mm2s_cntrl_tdata;// To mm2s_cntrl of mm2s_cntrl.v
   input [(C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH/8)-1:0] m_axis_mm2s_cntrl_tkeep;// To mm2s_cntrl of mm2s_cntrl.v
   input		m_axis_mm2s_cntrl_tlast;// To mm2s_cntrl of mm2s_cntrl.v
   input		m_axis_mm2s_cntrl_tvalid;// To mm2s_cntrl of mm2s_cntrl.v
   input		mm2s_cntrl_reset_out_n;	// To mm2s_cntrl of mm2s_cntrl.v
   input		s2mm_sts_reset_out_n;	// To aes_sts_fsm of aes_sts_fsm.v
   input [C_S_AXI_LITE_ADDR_WIDTH-1:0] s_axi_lite_araddr;// To axi_lite_slave of axi_lite_slave.v
   input		s_axi_lite_arvalid;	// To axi_lite_slave of axi_lite_slave.v
   input [C_S_AXI_LITE_ADDR_WIDTH-1:0] s_axi_lite_awaddr;// To axi_lite_slave of axi_lite_slave.v
   input		s_axi_lite_awvalid;	// To axi_lite_slave of axi_lite_slave.v
   input		s_axi_lite_bready;	// To axi_lite_slave of axi_lite_slave.v
   input		s_axi_lite_rready;	// To axi_lite_slave of axi_lite_slave.v
   input [C_S_AXI_LITE_DATA_WIDTH-1:0] s_axi_lite_wdata;// To axi_lite_slave of axi_lite_slave.v
   input		s_axi_lite_wvalid;	// To axi_lite_slave of axi_lite_slave.v
   input		s_axis_s2mm_sts_tready;	// To aes_sts_fsm of aes_sts_fsm.v
   // End of automatics

   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		aes_s2mm_eof_rd;	// From aes_sts_fsm of aes_sts_fsm.v
   output		aes_sts_ready;		// From aes_sts_fsm of aes_sts_fsm.v
   output		m_axis_mm2s_cntrl_tready;// From mm2s_cntrl of mm2s_cntrl.v
   output		s_axi_lite_arready;	// From axi_lite_slave of axi_lite_slave.v
   output		s_axi_lite_awready;	// From axi_lite_slave of axi_lite_slave.v
   output [1:0]		s_axi_lite_bresp;	// From axi_lite_slave of axi_lite_slave.v
   output		s_axi_lite_bvalid;	// From axi_lite_slave of axi_lite_slave.v
   output [C_S_AXI_LITE_DATA_WIDTH-1:0] s_axi_lite_rdata;// From axi_lite_slave of axi_lite_slave.v
   output [1:0]		s_axi_lite_rresp;	// From axi_lite_slave of axi_lite_slave.v
   output		s_axi_lite_rvalid;	// From axi_lite_slave of axi_lite_slave.v
   output		s_axi_lite_wready;	// From axi_lite_slave of axi_lite_slave.v
   output [C_S_AXIS_S2MM_STS_TDATA_WIDTH-1:0] s_axis_s2mm_sts_tdata;// From aes_sts_fsm of aes_sts_fsm.v
   output [(C_S_AXIS_S2MM_STS_TDATA_WIDTH/8)-1:0] s_axis_s2mm_sts_tkeep;// From aes_sts_fsm of aes_sts_fsm.v
   output		s_axis_s2mm_sts_tlast;	// From aes_sts_fsm of aes_sts_fsm.v
   output		s_axis_s2mm_sts_tvalid;	// From aes_sts_fsm of aes_sts_fsm.v
   // End of automatics

   input s_axi_lite_aclk;
   input m_axi_mm2s_aclk;
   input m_axi_s2mm_aclk;
   input axi_resetn;

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

   input 					   s2mm_intr;
   input 					   mm2s_intr;
   output 					   axi_intr;
   /***************************************************************************/
   /*AUTOREG*/

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [31:0]		aes_sts_dbg;		// From aes_sts_fsm of aes_sts_fsm.v
   // End of automatics
   
   reg 						   aes_s2mm_sof;
   reg 						   aes_s2mm_eof;
   
   wire 					   aes_s2mm_eof_empty;
   wire 					   aes_s2mm_eof_full;
   wire 					   aes_s2mm_eof_rd;
   
   axi_lite_slave # (/*AUTOINSTPARAM*/
		     // Parameters
		     .C_S_AXI_LITE_ADDR_WIDTH(C_S_AXI_LITE_ADDR_WIDTH),
		     .C_S_AXI_LITE_DATA_WIDTH(C_S_AXI_LITE_DATA_WIDTH))
   axi_lite_slave (/*AUTOINST*/
		   // Outputs
		   .s_axi_lite_awready	(s_axi_lite_awready),
		   .s_axi_lite_wready	(s_axi_lite_wready),
		   .s_axi_lite_bresp	(s_axi_lite_bresp[1:0]),
		   .s_axi_lite_bvalid	(s_axi_lite_bvalid),
		   .s_axi_lite_arready	(s_axi_lite_arready),
		   .s_axi_lite_rvalid	(s_axi_lite_rvalid),
		   .s_axi_lite_rdata	(s_axi_lite_rdata[C_S_AXI_LITE_DATA_WIDTH-1:0]),
		   .s_axi_lite_rresp	(s_axi_lite_rresp[1:0]),
		   // Inputs
		   .s_axi_lite_aclk	(s_axi_lite_aclk),
		   .axi_resetn		(axi_resetn),
		   .s_axi_lite_awvalid	(s_axi_lite_awvalid),
		   .s_axi_lite_awaddr	(s_axi_lite_awaddr[C_S_AXI_LITE_ADDR_WIDTH-1:0]),
		   .s_axi_lite_wvalid	(s_axi_lite_wvalid),
		   .s_axi_lite_wdata	(s_axi_lite_wdata[C_S_AXI_LITE_DATA_WIDTH-1:0]),
		   .s_axi_lite_bready	(s_axi_lite_bready),
		   .s_axi_lite_arvalid	(s_axi_lite_arvalid),
		   .s_axi_lite_araddr	(s_axi_lite_araddr[C_S_AXI_LITE_ADDR_WIDTH-1:0]),
		   .s_axi_lite_rready	(s_axi_lite_rready),
		   .aes_sts_dbg		(aes_sts_dbg[31:0]));

   mm2s_cntrl #(/*AUTOINSTPARAM*/
		// Parameters
		.C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH(C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH))
   mm2s_cntrl  (/*AUTOINST*/
		// Outputs
		.m_axis_mm2s_cntrl_tready(m_axis_mm2s_cntrl_tready),
		// Inputs
		.mm2s_cntrl_reset_out_n	(mm2s_cntrl_reset_out_n),
		.m_axis_mm2s_cntrl_tdata(m_axis_mm2s_cntrl_tdata[C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH-1:0]),
		.m_axis_mm2s_cntrl_tkeep(m_axis_mm2s_cntrl_tkeep[(C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH/8)-1:0]),
		.m_axis_mm2s_cntrl_tvalid(m_axis_mm2s_cntrl_tvalid),
		.m_axis_mm2s_cntrl_tlast(m_axis_mm2s_cntrl_tlast));

   aes_sts_fsm #(/*AUTOINSTPARAM*/
		 // Parameters
		 .C_S_AXIS_S2MM_STS_TDATA_WIDTH(C_S_AXIS_S2MM_STS_TDATA_WIDTH),
		 .C_FAMILY		(C_FAMILY))
   aes_sts_fsm  (/*AUTOINST*/
		 // Outputs
		 .s_axis_s2mm_sts_tdata	(s_axis_s2mm_sts_tdata[C_S_AXIS_S2MM_STS_TDATA_WIDTH-1:0]),
		 .s_axis_s2mm_sts_tkeep	(s_axis_s2mm_sts_tkeep[(C_S_AXIS_S2MM_STS_TDATA_WIDTH/8)-1:0]),
		 .s_axis_s2mm_sts_tvalid(s_axis_s2mm_sts_tvalid),
		 .s_axis_s2mm_sts_tlast	(s_axis_s2mm_sts_tlast),
		 .aes_sts_ready		(aes_sts_ready),
		 .aes_s2mm_eof_rd	(aes_s2mm_eof_rd),
		 .aes_sts_dbg		(aes_sts_dbg[31:0]),
		 // Inputs
		 .m_axi_mm2s_aclk	(m_axi_mm2s_aclk),
		 .m_axi_s2mm_aclk	(m_axi_s2mm_aclk),
		 .s2mm_sts_reset_out_n	(s2mm_sts_reset_out_n),
		 .s_axis_s2mm_sts_tready(s_axis_s2mm_sts_tready),
		 .aes_s2mm_eof_empty	(aes_s2mm_eof_empty),
		 .aes_s2mm_eof_full	(aes_s2mm_eof_full));
   
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

   wire [127:0] aes_out_i;
   wire [127:0] aes_out_w;
   reg [127:0] 	aes_out;
   always @(posedge m_axi_mm2s_aclk)
     begin
	aes_out <= #1 aes_out_w;
     end
   aes_256 aes_256(.clk  (m_axi_mm2s_aclk),
		   .state(aes_din),
		   .key  (aes_key),
		   .out  (aes_out_i));
   genvar i;
   generate
      for (i = 0; i < 128; i = i + 8) begin: swap_aes_out
	 assign aes_out_w[127-i:120-i] = aes_out_i[i+7:i];
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

   assign axi_intr = s2mm_intr | mm2s_intr;
   /***************************************************************************/
   reg 					s2mm_sof;
   always @(posedge m_axi_mm2s_aclk)
     begin
	if (~mm2s_prmry_reset_out_n || 
	    (s_axis_s2mm_tready & s_axis_s2mm_tvalid & s_axis_s2mm_tlast))
	  begin
	     s2mm_sof <= #1 1'b1;
	  end
	else if (s2mm_sof & s_axis_s2mm_tready & s_axis_s2mm_tvalid)
	  begin
	     s2mm_sof <= #1 1'b0;
	  end
     end // always @ (posedge m_axi_mm2s_aclk)
   always @(posedge m_axi_mm2s_aclk)
     begin
	aes_s2mm_sof <= #1 s_axis_s2mm_tready & s_axis_s2mm_tvalid & s2mm_sof;
	aes_s2mm_eof <= #1 s_axis_s2mm_tready & s_axis_s2mm_tvalid & s_axis_s2mm_tlast;
     end
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
endmodule // axi_aes
// 
// axi_aes.v ends here
