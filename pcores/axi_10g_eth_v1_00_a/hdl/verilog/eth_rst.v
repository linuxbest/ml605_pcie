// eth_rst.v --- 
// 
// Filename: eth_rst.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Apr 20 09:19:04 2014 (-0700)
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
module eth_rst (/*AUTOARG*/
   // Outputs
   sys_rst,
   // Inputs
   mm2s_resetn, s2mm_resetn, tx_reset, rx_reset, mm2s_clk, s2mm_clk
   );
   input mm2s_resetn;
   input s2mm_resetn;
   input tx_reset;
   input rx_reset;
   
   input mm2s_clk;
   input s2mm_clk;
   output sys_rst;   

   reg [31:0] rst0;
   reg [31:0] rst1;
   always @(posedge mm2s_clk or negedge mm2s_resetn)
     begin
	if (~mm2s_resetn)
	  begin
	     rst0 <= #1 32'hffff_ffff;
	  end
	else
	  begin
	     rst0 <= #1 rst0 << 1;
	  end
     end // always @ (posedge mm2s_clk or negedge mm2s_resetn)
   always @(posedge mm2s_clk or posedge tx_reset)
     begin
	if (tx_reset)
	  begin
	     rst1 <= #1 32'hffff_ffff;
	  end
	else
	  begin
	     rst1 <= #1 rst1 << 1;
	  end
     end // always @ (posedge mm2s_clk or posedge tx_reset)

   assign sys_rst = rst0[31] | rst1[31];
endmodule
// 
// eth_rst.v ends here
