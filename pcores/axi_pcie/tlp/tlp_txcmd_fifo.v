// tlp_txcmd_fifo.v --- 
// 
// Filename: tlp_txcmd_fifo.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Oct 26 12:44:10 2014 (-0700)
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
module tlp_txcmd_fifo (/*AUTOARG*/
   // Outputs
   CmdFifoUsedW, CmdFifoEmpty, CmdFifoEmpty_r,
   // Inputs
   clk, rst, TxReqHeader, TxReqWr, CplReqHeader, CplReqWr,
   CmdFifoRdReq, CmdFifoDat
   );
   input clk;
   input rst;

   input [98:0] TxReqHeader;
   input        TxReqWr;

   input [98:0] CplReqHeader;
   input 	CplReqWr;
   
   output [3:0] CmdFifoUsedW;
   output 	CmdFifoEmpty;
   output 	CmdFifoEmpty_r;

   input 	CmdFifoRdReq;
   output [98:0] CmdFifoDat;
   
endmodule
// 
// tlp_txcmd_fifo.v ends here
