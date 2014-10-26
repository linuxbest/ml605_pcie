// tlp_txdat_fifo.v --- 
// 
// Filename: tlp_txdat_fifo.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Oct 26 12:45:06 2014 (-0700)
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

module tlp_txdat_fifo (/*AUTOARG*/
   // Outputs
   WrDatFifoUsedW, WrDatFifoFull, WrDatFifoDo,
   // Inputs
   clk, rst, WrDatFifoWrReq, WrDatFifoEop, WrDatFifoDi,
   WrDatFifoRdReq
   );
   input clk;
   input rst;

   output [5:0] WrDatFifoUsedW;
   output 	WrDatFifoFull;
   
   input 	WrDatFifoWrReq;
   input 	WrDatFifoEop;
   input [127:0] WrDatFifoDi;
   
   input 	 WrDatFifoRdReq;
   output [128:0] WrDatFifoDo;
   
endmodule
// 
// tlp_txdat_fifo.v ends here
