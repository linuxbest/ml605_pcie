// xphy_int.v --- 
// 
// Filename: xphy_int.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Apr  6 14:19:57 2014 (-0700)
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
module xphy_int (/*AUTOARG*/
   // Outputs
   areset, dclk_reset,
   // Inputs
   xphy_reset, is_eval
   );
   output areset;
   input  xphy_reset;
   assign areset = xphy_reset;

   output dclk_reset;
   input  is_eval;
   
   
endmodule
// 
// xphy_int.v ends here
