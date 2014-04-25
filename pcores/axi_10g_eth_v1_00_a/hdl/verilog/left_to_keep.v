// left_to_keep.v --- 
// 
// Filename: left_to_keep.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sat Apr 19 17:08:45 2014 (-0700)
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
module left_to_keep(/*AUTOARG*/
   // Outputs
   keep,
   // Inputs
   cnt
   );
   input [3:0] cnt;
   output [7:0] keep;

   reg [7:0] 	keep;
   always @(*)
     begin
	keep = 8'b0000_0000;
	case (cnt)
	  4'h1: keep = 8'b1000_0000;
	  4'h2: keep = 8'b1100_0000;
	  4'h3: keep = 8'b1110_0000;
	  4'h4: keep = 8'b1111_0000;
	  4'h5: keep = 8'b1111_1000;
	  4'h6: keep = 8'b1111_1100;
	  4'h7: keep = 8'b1111_1110;
	  4'h8: keep = 8'b1111_1111;	  
	endcase
     end
endmodule
// 
// left_to_keep.v ends here
