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
   s_axis_s2mm_tvalid, s_axis_s2mm_tuser, s_axis_s2mm_tlast,
   s_axis_s2mm_tkeep, s_axis_s2mm_tid, s_axis_s2mm_tdest,
   s_axis_s2mm_tdata, s_axis_s2mm_sts_tvalid, s_axis_s2mm_sts_tlast,
   s_axis_s2mm_sts_tkeep, s_axis_s2mm_sts_tdata, s_axi_lite_wready,
   s_axi_lite_rvalid, s_axi_lite_rresp, s_axi_lite_rdata,
   s_axi_lite_bvalid, s_axi_lite_bresp, s_axi_lite_awready,
   s_axi_lite_arready, m_axis_mm2s_tready, m_axis_mm2s_cntrl_tready,
   aes_sts_ready, axi_intr,
   // Inputs
   s_axis_s2mm_tready, s_axis_s2mm_sts_tready, s_axi_lite_wvalid,
   s_axi_lite_wdata, s_axi_lite_rready, s_axi_lite_bready,
   s_axi_lite_awvalid, s_axi_lite_awaddr, s_axi_lite_arvalid,
   s_axi_lite_araddr, s2mm_sts_reset_out_n, s2mm_prmry_reset_out_n,
   mm2s_prmry_reset_out_n, mm2s_cntrl_reset_out_n, m_axis_mm2s_tvalid,
   m_axis_mm2s_tuser, m_axis_mm2s_tlast, m_axis_mm2s_tkeep,
   m_axis_mm2s_tid, m_axis_mm2s_tdest, m_axis_mm2s_tdata,
   m_axis_mm2s_cntrl_tvalid, m_axis_mm2s_cntrl_tlast,
   m_axis_mm2s_cntrl_tkeep, m_axis_mm2s_cntrl_tdata, s_axi_lite_aclk,
   m_axi_mm2s_aclk, m_axi_s2mm_aclk, axi_resetn, s2mm_intr, mm2s_intr
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
   input [C_M_AXIS_MM2S_TDATA_WIDTH-1:0] m_axis_mm2s_tdata;// To aes_mm2s of aes_mm2s.v
   input [4:0]		m_axis_mm2s_tdest;	// To aes_mm2s of aes_mm2s.v
   input [4:0]		m_axis_mm2s_tid;	// To aes_mm2s of aes_mm2s.v
   input [(C_M_AXIS_MM2S_TDATA_WIDTH/8)-1:0] m_axis_mm2s_tkeep;// To aes_mm2s of aes_mm2s.v
   input		m_axis_mm2s_tlast;	// To aes_mm2s of aes_mm2s.v
   input [3:0]		m_axis_mm2s_tuser;	// To aes_mm2s of aes_mm2s.v
   input		m_axis_mm2s_tvalid;	// To aes_mm2s of aes_mm2s.v
   input		mm2s_cntrl_reset_out_n;	// To mm2s_cntrl of mm2s_cntrl.v
   input		mm2s_prmry_reset_out_n;	// To aes_mm2s of aes_mm2s.v
   input		s2mm_prmry_reset_out_n;	// To aes_mm2s of aes_mm2s.v
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
   input		s_axis_s2mm_tready;	// To aes_mm2s of aes_mm2s.v
   // End of automatics

   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		aes_sts_ready;		// From aes_sts_fsm of aes_sts_fsm.v
   output		m_axis_mm2s_cntrl_tready;// From mm2s_cntrl of mm2s_cntrl.v
   output		m_axis_mm2s_tready;	// From aes_mm2s of aes_mm2s.v
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
   output [C_S_AXIS_S2MM_TDATA_WIDTH-1:0] s_axis_s2mm_tdata;// From aes_mm2s of aes_mm2s.v
   output [4:0]		s_axis_s2mm_tdest;	// From aes_mm2s of aes_mm2s.v
   output [4:0]		s_axis_s2mm_tid;	// From aes_mm2s of aes_mm2s.v
   output [(C_S_AXIS_S2MM_TDATA_WIDTH/8)-1:0] s_axis_s2mm_tkeep;// From aes_mm2s of aes_mm2s.v
   output		s_axis_s2mm_tlast;	// From aes_mm2s of aes_mm2s.v
   output [3:0]		s_axis_s2mm_tuser;	// From aes_mm2s of aes_mm2s.v
   output		s_axis_s2mm_tvalid;	// From aes_mm2s of aes_mm2s.v
   // End of automatics

   input s_axi_lite_aclk;
   input m_axi_mm2s_aclk;
   input m_axi_s2mm_aclk;
   input axi_resetn;

   input 					   s2mm_intr;
   input 					   mm2s_intr;
   output 					   axi_intr;
   /***************************************************************************/
   /*AUTOREG*/

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			aes_s2mm_eof_empty;	// From aes_mm2s of aes_mm2s.v
   wire			aes_s2mm_eof_full;	// From aes_mm2s of aes_mm2s.v
   wire			aes_s2mm_eof_rd;	// From aes_sts_fsm of aes_sts_fsm.v
   wire [31:0]		aes_sts_dbg;		// From aes_sts_fsm of aes_sts_fsm.v
   // End of automatics
   
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

   aes_mm2s #(/*AUTOINSTPARAM*/
	      // Parameters
	      .C_FAMILY			(C_FAMILY),
	      .C_INSTANCE		(C_INSTANCE),
	      .C_M_AXIS_MM2S_TDATA_WIDTH(C_M_AXIS_MM2S_TDATA_WIDTH),
	      .C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH(C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH),
	      .C_S_AXIS_S2MM_STS_TDATA_WIDTH(C_S_AXIS_S2MM_STS_TDATA_WIDTH),
	      .C_S_AXIS_S2MM_TDATA_WIDTH(C_S_AXIS_S2MM_TDATA_WIDTH))
   aes_mm2s  (/*AUTOINST*/
	      // Outputs
	      .m_axis_mm2s_tready	(m_axis_mm2s_tready),
	      .s_axis_s2mm_tdata	(s_axis_s2mm_tdata[C_S_AXIS_S2MM_TDATA_WIDTH-1:0]),
	      .s_axis_s2mm_tkeep	(s_axis_s2mm_tkeep[(C_S_AXIS_S2MM_TDATA_WIDTH/8)-1:0]),
	      .s_axis_s2mm_tvalid	(s_axis_s2mm_tvalid),
	      .s_axis_s2mm_tlast	(s_axis_s2mm_tlast),
	      .s_axis_s2mm_tuser	(s_axis_s2mm_tuser[3:0]),
	      .s_axis_s2mm_tid		(s_axis_s2mm_tid[4:0]),
	      .s_axis_s2mm_tdest	(s_axis_s2mm_tdest[4:0]),
	      .aes_s2mm_eof_empty	(aes_s2mm_eof_empty),
	      .aes_s2mm_eof_full	(aes_s2mm_eof_full),
	      // Inputs
	      .m_axi_mm2s_aclk		(m_axi_mm2s_aclk),
	      .mm2s_prmry_reset_out_n	(mm2s_prmry_reset_out_n),
	      .m_axis_mm2s_tdata	(m_axis_mm2s_tdata[C_M_AXIS_MM2S_TDATA_WIDTH-1:0]),
	      .m_axis_mm2s_tkeep	(m_axis_mm2s_tkeep[(C_M_AXIS_MM2S_TDATA_WIDTH/8)-1:0]),
	      .m_axis_mm2s_tvalid	(m_axis_mm2s_tvalid),
	      .m_axis_mm2s_tlast	(m_axis_mm2s_tlast),
	      .m_axis_mm2s_tuser	(m_axis_mm2s_tuser[3:0]),
	      .m_axis_mm2s_tid		(m_axis_mm2s_tid[4:0]),
	      .m_axis_mm2s_tdest	(m_axis_mm2s_tdest[4:0]),
	      .s2mm_prmry_reset_out_n	(s2mm_prmry_reset_out_n),
	      .s_axis_s2mm_tready	(s_axis_s2mm_tready),
	      .aes_s2mm_eof_rd		(aes_s2mm_eof_rd));
   
   assign axi_intr = s2mm_intr | mm2s_intr;
endmodule // axi_aes
// 
// axi_aes.v ends here
