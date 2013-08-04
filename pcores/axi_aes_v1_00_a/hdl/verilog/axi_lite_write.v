// axi_lite_write.v --- 
// 
// Filename: axi_lite_write.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sat Aug  3 17:12:22 2013 (-0700)
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
`timescale 1 ps / 100 fs
module axi_lite_write (/*AUTOARG*/
   // Outputs
   wready, bvalid, bresp, reg_data_addr, reg_data_write, reg_data,
   // Inputs
   clk, reset, awvalid, awready, wvalid, wdata, bready
   );
   parameter C_ADDR_WIDTH = 10;
   parameter C_DATA_WIDTH = 32;
   
   input clk;
   input reset;

   input awvalid;
   input awready;
   
   input wvalid;
   output wready;
   input [C_DATA_WIDTH-1:0] wdata;
   
   output 		    bvalid;
   input 		    bready;
   output [1:0] 	    bresp;
   
   output [C_ADDR_WIDTH-1:0] reg_data_addr;
   output 		     reg_data_write;
   output [C_DATA_WIDTH-1:0] reg_data;
   /***************************************************************************/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [C_DATA_WIDTH-1:0] reg_data;
   reg [C_ADDR_WIDTH-1:0] reg_data_addr;
   reg			reg_data_write;
   // End of automatics

   /***************************************************************************/
   // HandShake signals
   wire 		     awhandshake;
   wire 		     whandshake;
   wire 		     bhandshake;
   assign awhandshake = awvalid & awready;
   assign whandshake  = wvalid  & wready;
   assign bhandshake  = bvalid  & bready;

   // wchannel only accept data after aw handshake
   reg 			     wready_i;
   assign wready = wready_i;

   always @(posedge clk)
     begin
	if (reset)
	  begin
	     wready_i <= #1 1'b0;
	  end
	else
	  begin
	     wready_i <= #1 (awhandshake | wready_i) & ~whandshake;
	  end
     end // always @ (posedge clk)

   // Data is registered but not latched (like awaddr) since is used a cycle later
   always @(posedge clk)
     begin
	reg_data       <= #1 wdata;
	reg_data_write <= #1 whandshake;
     end

   // bresponse is send after success w handshake
   reg bvalid_i;
   assign bvalid = bvalid_i;
   assign bresp  = 2'b0;	// Okay
   
   always @(posedge clk)
     begin
	if (reset)
	  begin
	     bvalid_i <= #1 1'b0;
	  end
	else
	  begin
	     bvalid_i <= #1 (whandshake | bvalid_i) & ~bhandshake;
	  end
     end // always @ (posedge clk)
endmodule
// 
// axi_lite_write.v ends here
