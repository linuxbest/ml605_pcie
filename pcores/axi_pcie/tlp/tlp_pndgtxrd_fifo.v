// tlp_pndgtxrd_fifo.v --- 
// 
// Filename: tlp_pndgtxrd_fifo.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Oct 26 15:30:57 2014 (-0700)
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

module tlp_pndgtxrd_fifo (/*AUTOARG*/
   // Outputs
   PndngRdFifoUsedW, PndngRdFifoEmpty, RxPndgRdFifoEmpty,
   RxPndgRdFifoDato, RxPndgRdFifoRdReq,
   // Inputs
   clk, rst, PndgRdFifoWrReq, PndgRdHeader
   );
   input clk;
   input rst;

   output [3:0] PndngRdFifoUsedW;
   output 	PndngRdFifoEmpty;
   input 	PndgRdFifoWrReq;
   input [56:0] PndgRdHeader;

   output 	RxPndgRdFifoEmpty;
   output [56:0] RxPndgRdFifoDato;
   output 	 RxPndgRdFifoRdReq;
   
endmodule
// 
// tlp_pndgtxrd_fifo.v ends here
