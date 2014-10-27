// tlp_s_axi_cntrl.v --- 
// 
// Filename: tlp_s_axi_cntrl.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Oct 26 12:49:28 2014 (-0700)
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
module tlp_s_axi_cntrl (/*AUTOARG*/
   // Outputs
   AWVALID, AWADDR, AWPROT, AWREGION, AWLEN, AWSIZE, AWBURST, AWLOCK,
   AWCACHE, AWQOS, AWID, AWUSER, WVALID, WDATA, WSTRB, WLAST, WUSER,
   BREADY, ARVALID, ARADDR, ARPROT, ARREGION, ARLEN, ARSIZE, ARBURST,
   ARLOCK, ARCACHE, ARQOS, ARID, ARUSER, RREADY,
   // Inputs
   ACLK, ARESETn, AWREADY, WREADY, BVALID, BRESP, BID, BUSER, ARREADY,
   RVALID, RDATA, RRESP, RLAST, RID, RUSER
   );
   parameter AXI4_ADDRESS_WIDTH = 64;
   parameter AXI4_RDATA_WIDTH   = 128;
   parameter AXI4_WDATA_WIDTH   = 128;
   parameter AXI4_ID_WIDTH      = 3;

   input  ACLK;
   input  ARESETn;
   output                                    M_AWVALID;
   output [((AXI4_ADDRESS_WIDTH) - 1):0]     M_AWADDR;
   output [2:0] 			     M_AWPROT;
   output [3:0] 			     M_AWREGION;
   output [7:0] 			     M_AWLEN;
   output [2:0] 			     M_AWSIZE;
   output [1:0] 			     M_AWBURST;
   output 				     M_AWLOCK;
   output [3:0] 			     M_AWCACHE;
   output [3:0] 			     M_AWQOS;
   output [((AXI4_ID_WIDTH) - 1):0] 	     M_AWID;
   output [((AXI4_USER_WIDTH) - 1):0] 	     M_AWUSER;
   input 				     M_AWREADY;
   output 				     M_WVALID;
   output [((AXI4_WDATA_WIDTH) - 1):0] 	     M_WDATA;
   output [(((AXI4_WDATA_WIDTH / 8)) - 1):0] M_WSTRB;
   output 				     M_WLAST;
   output [((AXI4_USER_WIDTH) - 1):0] 	     M_WUSER;
   input 				     M_WREADY;
   input 				     M_BVALID;
   input [1:0] 				     M_BRESP;
   input [((AXI4_ID_WIDTH) - 1):0] 	     M_BID;
   input [((AXI4_USER_WIDTH) - 1):0] 	     M_BUSER;
   output 				     M_BREADY;
   
   output 				     M_ARVALID;
   output [((AXI4_ADDRESS_WIDTH) - 1):0]     M_ARADDR;
   output [2:0] 			     M_ARPROT;
   output [3:0] 			     M_ARREGION;
   output [7:0] 			     M_ARLEN;
   output [2:0] 			     M_ARSIZE;
   output [1:0] 			     M_ARBURST;
   output 				     M_ARLOCK;
   output [3:0] 			     M_ARCACHE;
   output [3:0] 			     M_ARQOS;
   output [((AXI4_ID_WIDTH) - 1):0] 	     M_ARID;
   output [((AXI4_USER_WIDTH) - 1):0] 	     M_ARUSER;
   input 				     M_ARREADY;
   input 				     M_RVALID;
   input [((AXI4_RDATA_WIDTH) - 1):0] 	     M_RDATA;
   input [1:0] 				     M_RRESP;
   input 				     M_RLAST;
   input [((AXI4_ID_WIDTH) - 1):0] 	     M_RID;
   input [((AXI4_USER_WIDTH) - 1):0] 	     M_RUSER;
   output 				     M_RREADY;
 
endmodule
// 
// tlp_s_axi_cntrl.v ends here
