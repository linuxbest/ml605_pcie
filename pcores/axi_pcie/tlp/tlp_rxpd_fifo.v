// tlp_rxpd_fifo.v --- 
// 
// Filename: tlp_rxpd_fifo.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Oct 26 12:49:59 2014 (-0700)
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
module tlp_rxpd_fifo (/*AUTOARG*/
   // Outputs
   TxRpFifoData, RpTLPReady,
   // Inputs
   clk, rst, TxRpFifoRdReq
   );
   input clk;
   input rst;

   output [130:0] TxRpFifoData;   
   input 	  TxRpFifoRdReq;
   output 	  RpTLPReady;

   // not root port.
   assign RpTLPReady   = 1'b0;
   assign TxRpFifoData = 131'h0;
endmodule
// 
// tlp_rxpd_fifo.v ends here
