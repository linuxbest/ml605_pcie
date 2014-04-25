// axi_10g_mac.v --- 
// 
// Filename: axi_10g_mac.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Thu Apr 24 20:58:42 2014 (-0700)
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
`timescale 1ns/1ps
module axi_10g_mac (/*AUTOARG*/
   // Outputs
   xgmii_txd, xgmii_txc, xgmacint, tx_statistics_vector,
   tx_statistics_valid, tx_axis_tready, s_axi_wready, s_axi_rvalid,
   s_axi_rresp, s_axi_rdata, s_axi_bvalid, s_axi_bresp, s_axi_awready,
   s_axi_arready, rx_statistics_vector, rx_statistics_valid,
   rx_axis_tvalid, rx_axis_tuser, rx_axis_tlast, rx_axis_tkeep,
   rx_axis_tdata, mdio_tri, mdio_out, mdc, rx_mac_aclk, rx_reset,
   tx_mac_aclk, tx_reset,
   // Inputs
   xgmii_rxd, xgmii_rxc, tx_resetdone, tx_ifg_delay, tx_axis_tvalid,
   tx_axis_tuser, tx_axis_tlast, tx_axis_tkeep, tx_axis_tdata,
   s_axi_wvalid, s_axi_wdata, s_axi_rready, s_axi_bready,
   s_axi_awvalid, s_axi_awaddr, s_axi_arvalid, s_axi_aresetn,
   s_axi_araddr, s_axi_aclk, rx_resetdone, pause_val, pause_req,
   mdio_in, clk156, hw_reset, s_axi_wstrb, core_status,
   rx_axis_tready
   );
   parameter C_FAMILY = "";   
   parameter C_DBG_PORT = 0;

   parameter C_BASEADDR = 32'h0000_0000;
   parameter C_HIGHADDR = 32'h0000_0000;
   parameter C_S_AXI_ADDR_WIDTH = 32;
   parameter C_S_AXI_DATA_WIDTH = 32;
   parameter C_S_AXI_ID_WIDTH = 2;

   input hw_reset;
   wire [31:0] bus2ip_addr;
   input [3:0] s_axi_wstrb;

   output      rx_mac_aclk;
   output      rx_reset;
   output      tx_mac_aclk;
   output      tx_reset;
   input [7:0] core_status;
   input       rx_axis_tready;
   
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		clk156;			// To xgmac of xgmac.v, ...
   input		mdio_in;		// To xgmac of xgmac.v
   input		pause_req;		// To xgmac of xgmac.v
   input [15:0]		pause_val;		// To xgmac of xgmac.v
   input		rx_resetdone;		// To xgmac of xgmac.v, ...
   input		s_axi_aclk;		// To xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   input [31:0]		s_axi_araddr;		// To xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   input		s_axi_aresetn;		// To xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   input		s_axi_arvalid;		// To xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   input [31:0]		s_axi_awaddr;		// To xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   input		s_axi_awvalid;		// To xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   input		s_axi_bready;		// To xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   input		s_axi_rready;		// To xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   input [31:0]		s_axi_wdata;		// To xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   input		s_axi_wvalid;		// To xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   input [63:0]		tx_axis_tdata;		// To xgmac of xgmac.v
   input [7:0]		tx_axis_tkeep;		// To xgmac of xgmac.v
   input		tx_axis_tlast;		// To xgmac of xgmac.v
   input [127:0]	tx_axis_tuser;		// To xgmac of xgmac.v
   input		tx_axis_tvalid;		// To xgmac of xgmac.v
   input [7:0]		tx_ifg_delay;		// To xgmac of xgmac.v
   input		tx_resetdone;		// To xgmac of xgmac.v, ...
   input [7:0]		xgmii_rxc;		// To xgmac of xgmac.v
   input [63:0]		xgmii_rxd;		// To xgmac of xgmac.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		mdc;			// From xgmac of xgmac.v
   output		mdio_out;		// From xgmac of xgmac.v
   output		mdio_tri;		// From xgmac of xgmac.v
   output [63:0]	rx_axis_tdata;		// From xgmac of xgmac.v
   output [7:0]		rx_axis_tkeep;		// From xgmac of xgmac.v
   output		rx_axis_tlast;		// From xgmac of xgmac.v
   output		rx_axis_tuser;		// From xgmac of xgmac.v
   output		rx_axis_tvalid;		// From xgmac of xgmac.v
   output		rx_statistics_valid;	// From xgmac of xgmac.v
   output [29:0]	rx_statistics_vector;	// From xgmac of xgmac.v
   output		s_axi_arready;		// From xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   output		s_axi_awready;		// From xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   output [1:0]		s_axi_bresp;		// From xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   output		s_axi_bvalid;		// From xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   output [31:0]	s_axi_rdata;		// From xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   output [1:0]		s_axi_rresp;		// From xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   output		s_axi_rvalid;		// From xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   output		s_axi_wready;		// From xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   output		tx_axis_tready;		// From xgmac of xgmac.v
   output		tx_statistics_valid;	// From xgmac of xgmac.v
   output [25:0]	tx_statistics_vector;	// From xgmac of xgmac.v
   output		xgmacint;		// From xgmac of xgmac.v
   output [7:0]		xgmii_txc;		// From xgmac of xgmac.v
   output [63:0]	xgmii_txd;		// From xgmac of xgmac.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			bus2ip_clk;		// From xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   wire			bus2ip_cs;		// From xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   wire [31:0]		bus2ip_data;		// From xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   wire			bus2ip_reset;		// From xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   wire			bus2ip_rnw;		// From xgmac_axi4_lite_ipif_wrapper of xgmac_axi4_lite_ipif_wrapper.v
   wire [31:0]		ip2bus_data;		// From xgmac of xgmac.v
   wire			ip2bus_error;		// From xgmac of xgmac.v
   wire			ip2bus_rdack;		// From xgmac of xgmac.v
   wire			ip2bus_wrack;		// From xgmac of xgmac.v
   // End of automatics

   assign rx_mac_aclk = clk156;
   assign tx_mac_aclk = clk156;
   assign rx_reset    = ~rx_resetdone;
   assign tx_reset    = ~tx_resetdone;
   
   /* xgmac AUTO_TEMPLATE (
    .tx_clk0         (clk156),
    .rx_clk0         (clk156),
    .reset           (hw_reset),
    .tx_axis_aresetn (tx_resetdone),
    .rx_axis_aresetn (rx_resetdone),
    .tx_dcm_lock     (tx_resetdone),
    .rx_dcm_lock     (rx_resetdone),
    );*/
   xgmac
     xgmac (/*AUTOINST*/
	    // Outputs
	    .tx_axis_tready		(tx_axis_tready),
	    .tx_statistics_valid	(tx_statistics_valid),
	    .rx_axis_tvalid		(rx_axis_tvalid),
	    .rx_axis_tuser		(rx_axis_tuser),
	    .rx_axis_tlast		(rx_axis_tlast),
	    .rx_statistics_valid	(rx_statistics_valid),
	    .ip2bus_rdack		(ip2bus_rdack),
	    .ip2bus_wrack		(ip2bus_wrack),
	    .ip2bus_error		(ip2bus_error),
	    .xgmacint			(xgmacint),
	    .mdc			(mdc),
	    .mdio_out			(mdio_out),
	    .mdio_tri			(mdio_tri),
	    .tx_statistics_vector	(tx_statistics_vector[25:0]),
	    .rx_axis_tdata		(rx_axis_tdata[63:0]),
	    .rx_axis_tkeep		(rx_axis_tkeep[7:0]),
	    .rx_statistics_vector	(rx_statistics_vector[29:0]),
	    .ip2bus_data		(ip2bus_data[31:0]),
	    .xgmii_txd			(xgmii_txd[63:0]),
	    .xgmii_txc			(xgmii_txc[7:0]),
	    // Inputs
	    .reset			(hw_reset),		 // Templated
	    .tx_axis_aresetn		(tx_resetdone),		 // Templated
	    .tx_axis_tvalid		(tx_axis_tvalid),
	    .tx_axis_tlast		(tx_axis_tlast),
	    .rx_axis_aresetn		(rx_resetdone),		 // Templated
	    .pause_req			(pause_req),
	    .bus2ip_clk			(bus2ip_clk),
	    .bus2ip_reset		(bus2ip_reset),
	    .bus2ip_rnw			(bus2ip_rnw),
	    .bus2ip_cs			(bus2ip_cs),
	    .tx_clk0			(clk156),		 // Templated
	    .tx_dcm_lock		(tx_resetdone),		 // Templated
	    .rx_clk0			(clk156),		 // Templated
	    .rx_dcm_lock		(rx_resetdone),		 // Templated
	    .mdio_in			(mdio_in),
	    .tx_axis_tdata		(tx_axis_tdata[63:0]),
	    .tx_axis_tuser		(tx_axis_tuser[127:0]),
	    .tx_ifg_delay		(tx_ifg_delay[7:0]),
	    .tx_axis_tkeep		(tx_axis_tkeep[7:0]),
	    .pause_val			(pause_val[15:0]),
	    .bus2ip_addr		(bus2ip_addr[10:0]),
	    .bus2ip_data		(bus2ip_data[31:0]),
	    .xgmii_rxd			(xgmii_rxd[63:0]),
	    .xgmii_rxc			(xgmii_rxc[7:0]));

   xgmac_axi4_lite_ipif_wrapper #(.C_BASE_ADDRESS	(C_BASEADDR),
                                  .C_HIGH_ADDRESS       (C_HIGHADDR))
   xgmac_axi4_lite_ipif_wrapper  (/*AUTOINST*/
				  // Outputs
				  .s_axi_awready	(s_axi_awready),
				  .s_axi_wready		(s_axi_wready),
				  .s_axi_bresp		(s_axi_bresp[1:0]),
				  .s_axi_bvalid		(s_axi_bvalid),
				  .s_axi_arready	(s_axi_arready),
				  .s_axi_rdata		(s_axi_rdata[31:0]),
				  .s_axi_rresp		(s_axi_rresp[1:0]),
				  .s_axi_rvalid		(s_axi_rvalid),
				  .bus2ip_clk		(bus2ip_clk),
				  .bus2ip_reset		(bus2ip_reset),
				  .bus2ip_addr		(bus2ip_addr[31:0]),
				  .bus2ip_cs		(bus2ip_cs),
				  .bus2ip_rnw		(bus2ip_rnw),
				  .bus2ip_data		(bus2ip_data[31:0]),
				  // Inputs
				  .s_axi_aclk		(s_axi_aclk),
				  .s_axi_aresetn	(s_axi_aresetn),
				  .s_axi_awaddr		(s_axi_awaddr[31:0]),
				  .s_axi_awvalid	(s_axi_awvalid),
				  .s_axi_wdata		(s_axi_wdata[31:0]),
				  .s_axi_wvalid		(s_axi_wvalid),
				  .s_axi_bready		(s_axi_bready),
				  .s_axi_araddr		(s_axi_araddr[31:0]),
				  .s_axi_arvalid	(s_axi_arvalid),
				  .s_axi_rready		(s_axi_rready),
				  .ip2bus_data		(ip2bus_data[31:0]),
				  .ip2bus_wrack		(ip2bus_wrack),
				  .ip2bus_rdack		(ip2bus_rdack),
				  .ip2bus_error		(ip2bus_error));
   
endmodule // axi_10g_mac
// Local Variables:
// verilog-library-directories:("../../loopback" "." "axi_ipif")
// verilog-library-files:("")
// verilog-library-extensions:(".v" ".h")
// End:
// 
// axi_10g_mac.v ends here
