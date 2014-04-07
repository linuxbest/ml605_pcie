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
   bus2ip_addr, bus2ip_data, bus2ip_clk, bus2ip_cs, bus2ip_reset,
   bus2ip_rnw, rx_clk, rx_axis_aresetn, tx_axis_aresetn,
   tx_axis_tuser,
   // Inputs
   ip2bus_data, ip2bus_error, ip2bus_rdack, ip2bus_wrack,
   core_clk156_out, resetdone, rx_axis_tready, rx_axis_tuser,
   xgmacint, core_status
   );

   input [31:0] ip2bus_data;
   input 	ip2bus_error;
   input 	ip2bus_rdack;
   input 	ip2bus_wrack;
   
   output [31:0] bus2ip_addr;
   output [31:0] bus2ip_data;
   output 	 bus2ip_clk;
   output 	 bus2ip_cs;
   output 	 bus2ip_reset;
   output 	 bus2ip_rnw;
   assign bus2ip_data = 0;
   assign bus2ip_addr = 0;
   assign bus2ip_clk  = rx_clk;
   assign bus2ip_reset= 1'b0;
   assign bus2ip_rnw  = 1;
   
   input 	 core_clk156_out;
   output 	 rx_clk;
   assign rx_clk = core_clk156_out;

   input 	 resetdone;
   output 	 rx_axis_aresetn;
   output 	 tx_axis_aresetn;
   assign rx_axis_aresetn = resetdone;
   assign tx_axis_aresetn = resetdone;

   output 	 tx_axis_tuser;
   input 	 rx_axis_tready;
   input 	 rx_axis_tuser;   
   assign tx_axis_tuser  = 1'b0;

   input 	 xgmacint;
   input [7:0] 	 core_status;
endmodule
// 
// xgmac_dut.v ends here
