// xgmac_int.v --- 
// 
// Filename: xgmac_int.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Apr  6 14:13:37 2014 (-0700)
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
module xgmac_int (/*AUTOARG*/
   // Outputs
   pause_req, pause_val, rx_configuration_vector,
   tx_configuration_vector,
   // Inputs
   rx_statistics_valid, rx_statistics_vector, status_vector,
   tx_statistics_valid, tx_statistics_vector
   );

   output pause_req;
   output [15:0] pause_val;

   input 	 rx_statistics_valid;
   input [29:0]  rx_statistics_vector;
   input [1:0] 	 status_vector;

   output [79:0] rx_configuration_vector;
   output [79:0] tx_configuration_vector;

   input 	 tx_statistics_valid;
   input [25:0]  tx_statistics_vector;

   /*TODO*/
endmodule
// 
// xgmac_int.v ends here
