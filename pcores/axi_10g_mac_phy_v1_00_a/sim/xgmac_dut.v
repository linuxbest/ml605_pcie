// xgmac_dut.v --- 
// 
// Filename: xgmac_dut.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Apr  6 17:34:03 2014 (-0700)
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
module xgmac_dut (/*AUTOARG*/
   // Outputs
   bus2ip_addr, bus2ip_data, tx_ifg_delay, training_enable,
   training_addr, training_rnw, training_wrdata, training_ipif_cs,
   rx_clk, rx_axis_aresetn, tx_axis_aresetn, an_enable,
   // Inputs
   ip2bus_data, ip2bus_error, ip2bus_rdack, ip2bus_wrack,
   training_rddata, training_rdack, training_wrack, core_clk156_out,
   resetdone
   );

   input [31:0] ip2bus_data;
   input 	ip2bus_error;
   input 	ip2bus_rdack;
   input 	ip2bus_wrack;
   
   output [31:0] bus2ip_addr;
   output [31:0] bus2ip_data;
   assign bus2ip_data = 0;
   assign bus2ip_addr = 0;
   
   output [7:0]  tx_ifg_delay;
   assign tx_ifg_delay = 0;

   output        training_enable;
   output [20:0] training_addr;
   output        training_rnw;
   output [15:0] training_wrdata;
   output        training_ipif_cs;
   assign training_enable = 0;
   assign training_addr   = 0;
   assign training_rnw    = 1;
   assign training_wrdata = 0;
   assign training_ipif_cs= 0;

   input [15:0]  training_rddata;
   input 	 training_rdack;
   input 	 training_wrack;

   input 	 core_clk156_out;
   output 	 rx_clk;
   assign rx_clk = core_clk156_out;

   input 	 resetdone;
   output 	 rx_axis_aresetn;
   output 	 tx_axis_aresetn;
   assign rx_axis_aresetn = resetdone;
   assign tx_axis_aresetn = resetdone;

   output        an_enable;
   assign        an_enable = 1'b0;
endmodule
// 
// xgmac_dut.v ends here
