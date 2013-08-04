// axi_lite_slave.v --- 
// 
// Filename: axi_lite_slave.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sat Aug  3 17:00:26 2013 (-0700)
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
module axi_lite_slave (/*AUTOARG*/
   // Outputs
   s_axi_lite_awready, s_axi_lite_wready, s_axi_lite_bresp,
   s_axi_lite_bvalid, s_axi_lite_arready, s_axi_lite_rvalid,
   s_axi_lite_rdata, s_axi_lite_rresp,
   // Inputs
   s_axi_lite_aclk, axi_resetn, s_axi_lite_awvalid, s_axi_lite_awaddr,
   s_axi_lite_wvalid, s_axi_lite_wdata, s_axi_lite_bready,
   s_axi_lite_arvalid, s_axi_lite_araddr, s_axi_lite_rready
   );
   input s_axi_lite_aclk;   
   input axi_resetn;

   input s_axi_lite_awvalid;
   output s_axi_lite_awready;
   input [C_S_AXI_LITE_ADDR_WIDTH-1:0] s_axi_lite_awaddr;
   
   input 			       s_axi_lite_wvalid;
   output 			       s_axi_lite_wready;
   input [C_S_AXI_LITE_DATA_WIDTH-1:0] s_axi_lite_wdata;
   
   output [1:0] 		       s_axi_lite_bresp;
   output 			       s_axi_lite_bvalid;
   input 			       s_axi_lite_bready;
   
   input 			       s_axi_lite_arvalid;
   output 			       s_axi_lite_arready;
   input [C_S_AXI_LITE_ADDR_WIDTH-1:0] s_axi_lite_araddr;
   
   output 			       s_axi_lite_rvalid;
   input 			       s_axi_lite_rready;
   output [C_S_AXI_LITE_DATA_WIDTH-1:0] s_axi_lite_rdata;
   output [1:0] 			s_axi_lite_rresp;

   /***************************************************************************/
   /*AUTOREG*/

   /***************************************************************************/
   assign s_axi_lite_arready = 0;
   assign s_axi_lite_awready = 0;
   assign s_axi_lite_rdata   = 0;
   assign s_axi_lite_rresp   = 0;
   assign s_axi_lite_rvalid  = 0;
   assign s_axi_lite_wready  = 0;
   assign s_axi_lite_bresp   = 0;
   assign s_axi_lite_bvalid  = 0;
   
endmodule
// 
// axi_lite_slave.v ends here
