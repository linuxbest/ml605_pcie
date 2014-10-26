// tlp_rxcpl_buffer.v --- 
// 
// Filename: tlp_rxcpl_buffer.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Oct 26 12:50:31 2014 (-0700)
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
module tlp_rxcpl_buffer (/*AUTOARG*/
   // Outputs
   RxCplBufData,
   // Inputs
   clk, rst, RxCplRamWrAddr, RxCplRamWrDat, RxCplRamWrEna,
   RxCplRdAddr
   );
   input clk;
   input rst;

   input [8:0] RxCplRamWrAddr;
   input [129:0] RxCplRamWrDat;
   input 	 RxCplRamWrEna;

   input [8:0] 	 RxCplRdAddr;
   output [129:0] RxCplBufData;
	 
endmodule
// 
// tlp_rxcpl_buffer.v ends here
