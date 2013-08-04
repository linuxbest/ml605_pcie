// mm2s_cntrl.v --- 
// 
// Filename: mm2s_cntrl.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Aug  4 11:30:08 2013 (-0700)
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
module mm2s_cntrl (/*AUTOARG*/
   // Outputs
   m_axis_mm2s_cntrl_tready,
   // Inputs
   mm2s_cntrl_reset_out_n, m_axis_mm2s_cntrl_tdata,
   m_axis_mm2s_cntrl_tkeep, m_axis_mm2s_cntrl_tvalid,
   m_axis_mm2s_cntrl_tlast
   );
   parameter C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH = 32;
   
   input 				     mm2s_cntrl_reset_out_n;
   input [C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH-1:0] m_axis_mm2s_cntrl_tdata;
   input [(C_M_AXIS_MM2S_CNTRL_TDATA_WIDTH/8)-1:0] m_axis_mm2s_cntrl_tkeep;
   input 					   m_axis_mm2s_cntrl_tvalid;
   input 					   m_axis_mm2s_cntrl_tlast;
   output 					   m_axis_mm2s_cntrl_tready;

   assign m_axis_mm2s_cntrl_tready = 1'b1;
endmodule
// 
// mm2s_cntrl.v ends here
