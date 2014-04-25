// cnt_to_keep.v --- 
// 
// Filename: cnt_to_keep.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Fri Apr 18 14:01:26 2014 (-0700)
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
module cnt_to_keep (/*AUTOARG*/
   // Outputs
   keep,
   // Inputs
   cnt
   );
   input [3:0] cnt;
   output [7:0] keep;

   reg [7:0] keep;
   always @(*)
     begin
	keep = 8'b0000_0000;
	case (cnt)
	  4'h1: keep = 8'b0000_0001;
	  4'h2: keep = 8'b0000_0011;
	  4'h3: keep = 8'b0000_0111;
	  4'h4: keep = 8'b0000_1111;
	  4'h5: keep = 8'b0001_1111;
	  4'h6: keep = 8'b0011_1111;
	  4'h7: keep = 8'b0111_1111;
	  4'h8: keep = 8'b1111_1111;	  
	endcase
     end
endmodule
// 
// cnt_to_keep.v ends here
