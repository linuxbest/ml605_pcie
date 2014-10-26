// tlp_txcpl_buffer.v --- 
// 
// Filename: tlp_txcpl_buffer.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Oct 26 12:47:51 2014 (-0700)
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
module tlp_txcpl_buffer (/*AUTOARG*/
   // Outputs
   TxCplDat,
   // Inputs
   clk, rst, CplRamWrAddr, TxReadDataValid_i, TxReadData_i,
   CplBuffRdAddr
   );
   parameter TXCPL_BUFF_ADDR_WIDTH = 8;
   
   input clk;
   input rst;

   input [TXCPL_BUFF_ADDR_WIDTH-1:0] CplRamWrAddr;
   input 			     TxReadDataValid_i; // TODO
   input [31:0] 		     TxReadData_i;
   
   input [TXCPL_BUFF_ADDR_WIDTH-1:0] CplBuffRdAddr;
   output [127:0] 		     TxCplDat;
   
endmodule
// 
// tlp_txcpl_buffer.v ends here
