// keep_to_cnt.v --- 
// 
// Filename: keep_to_cnt.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Fri Apr 18 13:58:11 2014 (-0700)
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
module keep_to_cnt (/*AUTOARG*/
   // Outputs
   cnt,
   // Inputs
   keep
   );
   input [7:0] keep;
   output [3:0] cnt;
   reg [3:0] 	cnt;
   always @(*)
     begin
	cnt = 3'h0;
	case (keep)
	  8'b0000_0001: cnt = 4'h1;
	  8'b0000_0011: cnt = 4'h2;
	  8'b0000_0111: cnt = 4'h3;
	  8'b0000_1111: cnt = 4'h4;
	  8'b0001_1111: cnt = 4'h5;
	  8'b0011_1111: cnt = 4'h6;
	  8'b0111_1111: cnt = 4'h7;
	  8'b1111_1111: cnt = 4'h8;
        endcase
     end
endmodule
// 
// keep_to_cnt.v ends here
