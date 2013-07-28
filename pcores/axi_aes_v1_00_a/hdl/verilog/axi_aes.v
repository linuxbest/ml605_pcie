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
module axi_aes (/*AUTOARG*/
   // Outputs
   s_axi_lite_wready, s_axi_lite_bresp, s_axi_lite_bvalid,
   s_axi_lite_arready, s_axi_lite_rvalid, s_axi_lite_rdata,
   s_axi_lite_rresp, m_axis_mm2s_tready, m_axis_mm2s_cntrl_tready,
   s_axis_s2mm_tdata, s_axis_s2mm_tkeep, m_axis_s2mm_tvalid,
   m_axis_s2mm_tlast, m_axis_s2mm_tuser, m_axis_s2mm_tid,
   m_axis_s2mm_tdest, s_axis_s2mm_sts_tdata, s_axis_s2mm_sts_tkeep,
   s_axis_s2mm_sts_tvalid, s_axis_s2mm_sts_tlast,
   // Inputs
   s_axi_lite_aclk, s_axi_mm2s_aclk, s_axi_s2mm_aclk, axi_resetn,
   s_axi_lite_awvalid, s_axi_lite_awready, s_axi_lite_awaddr,
   s_axi_lite_wvalid, s_axi_lite_wdata, s_axi_lite_bready,
   s_axi_lite_arvalid, s_axi_lite_araddr, s_axi_lite_rready,
   mm2s_prmry_reset_out_n, m_axis_mm2s_tdata, m_axis_mm2s_tkeep,
   m_axis_mm2s_tvalid, m_axis_mm2s_tlast, m_axis_mm2s_tuser,
   m_axis_mm2s_tid, m_axis_mm2s_tdest, mm2s_cntrl_reset_out_n,
   m_axis_mm2s_cntrl_tdata, m_axis_mm2s_cntrl_tkeep,
   m_axis_mm2s_cntrl_tvalid, m_axis_mm2s_cntrl_tlast,
   s2mm_prmry_reset_out_n, m_axis_s2mm_tready, s2mm_sts_reset_out_n,
   s_axis_s2mm_sts_tready
   );
   parameter C_FAMILY = "virtex6";
   parameter C_INSTANCE = "axi_aes_0";
   
   parameter C_M_AXIS_MM2S_TDATA_WIDTH = 128;
   parameter C_S_AXIS_S2MM_TDATA_WIDTH = 128;
   
   parameter C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH = 32;
   parameter C_S_AXIS_S2MM_STS_TDATA_WIDTH = 32;

   parameter C_S_AXI_LITE_ADDR_WIDTH = 10;
   parameter C_S_AXI_LITE_DATA_WIDTH = 32;

   input s_axi_lite_aclk;
   input s_axi_mm2s_aclk;
   input s_axi_s2mm_aclk;
   input axi_resetn;
   
   input s_axi_lite_awvalid;
   input s_axi_lite_awready;
   input [C_S_AXI_LITE_ADDR_WIDTH-1:0] s_axi_lite_awaddr;
   
   input 			       s_axi_lite_wvalid;
   output 			       s_axi_lite_wready;
   input [C_S_AXI_LITE_DATA_WIDTH-1:0] s_axi_lite_wdata;
   
   output [1:0] 		       s_axi_lite_bresp;
   output 			       s_axi_lite_bvalid;
   input 			       s_axi_lite_bready;
   
   input 			       s_axi_lite_arvalid;
   output 			       s_axi_lite_arready;
   input [C_S_AXI_LITE_ADDR_WIDTH-1:0] s_axi_lite_araddr;
   
   output 			       s_axi_lite_rvalid;
   input 			       s_axi_lite_rready;
   output [C_S_AXI_LITE_DATA_WIDTH-1:0] s_axi_lite_rdata;
   output [1:0] 			s_axi_lite_rresp;
   
   input 				mm2s_prmry_reset_out_n;
   input [C_M_AXIS_MM2S_TDATA_WIDTH-1:0] m_axis_mm2s_tdata;
   input [(C_M_AXIS_MM2S_TDATA_WIDTH/8)-1:0] m_axis_mm2s_tkeep;
   input 				     m_axis_mm2s_tvalid;
   input 				     m_axis_mm2s_tlast;
   input [3:0] 				     m_axis_mm2s_tuser;
   input [4:0] 				     m_axis_mm2s_tid;
   input [4:0] 				     m_axis_mm2s_tdest;
   output 				     m_axis_mm2s_tready;

   input 				     mm2s_cntrl_reset_out_n;
   input [C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH-1:0] m_axis_mm2s_cntrl_tdata;
   input [(C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH/8)-1:0] m_axis_mm2s_cntrl_tkeep;
   input 					   m_axis_mm2s_cntrl_tvalid;
   input 					   m_axis_mm2s_cntrl_tlast;
   output 					   m_axis_mm2s_cntrl_tready;

   input 					   s2mm_prmry_reset_out_n;
   output [C_S_AXIS_S2MM_TDATA_WIDTH-1:0] 	   s_axis_s2mm_tdata;
   output [(C_S_AXIS_S2MM_TDATA_WIDTH-1)/8-1:0]    s_axis_s2mm_tkeep;
   output 					   m_axis_s2mm_tvalid;
   output 					   m_axis_s2mm_tlast;
   output [3:0] 				   m_axis_s2mm_tuser;
   output [4:0] 				   m_axis_s2mm_tid;
   output [4:0] 				   m_axis_s2mm_tdest;
   input 					   m_axis_s2mm_tready;
   
   input 					   s2mm_sts_reset_out_n;
   output [C_S_AXIS_S2MM_STS_TDATA_WIDTH-1:0] 	   s_axis_s2mm_sts_tdata;
   output [(C_S_AXIS_S2MM_STS_TDATA_WIDTH/8)-1:0]  s_axis_s2mm_sts_tkeep;
   output 					   s_axis_s2mm_sts_tvalid;
   output 					   s_axis_s2mm_sts_tlast;
   input 					   s_axis_s2mm_sts_tready;
   
endmodule // axi_aes
// 
// axi_aes.v ends here
