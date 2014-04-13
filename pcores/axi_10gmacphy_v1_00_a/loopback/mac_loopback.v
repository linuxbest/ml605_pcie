// mac_loopback.v --- 
// 
// Filename: mac_loopback.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Apr  6 19:16:36 2014 (-0700)
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
module mac_loopback (/*AUTOARG*/
   // Outputs
   txp, txn, tx_disable, sfp_rs,
   // Inputs
   tx_fault, signal_detect, rxp, rxn, reset, refclk_p, refclk_n
   );
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		refclk_n;		// To axi_10g_mac_phy of axi_10gmacphy.v
   input		refclk_p;		// To axi_10g_mac_phy of axi_10gmacphy.v
   input		reset;			// To axi_10g_mac_phy of axi_10gmacphy.v, ...
   input		rxn;			// To axi_10g_mac_phy of axi_10gmacphy.v
   input		rxp;			// To axi_10g_mac_phy of axi_10gmacphy.v
   input		signal_detect;		// To axi_10g_mac_phy of axi_10gmacphy.v
   input		tx_fault;		// To axi_10g_mac_phy of axi_10gmacphy.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		sfp_rs;			// From axi_10g_mac_phy of axi_10gmacphy.v
   output		tx_disable;		// From axi_10g_mac_phy of axi_10gmacphy.v
   output		txn;			// From axi_10g_mac_phy of axi_10gmacphy.v
   output		txp;			// From axi_10g_mac_phy of axi_10gmacphy.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [31:0]		bus2ip_addr;		// From xgmac_dut of xgmac_dut.v
   wire			bus2ip_clk;		// From xgmac_dut of xgmac_dut.v
   wire			bus2ip_cs;		// From xgmac_dut of xgmac_dut.v
   wire [31:0]		bus2ip_data;		// From xgmac_dut of xgmac_dut.v
   wire			bus2ip_reset;		// From xgmac_dut of xgmac_dut.v
   wire			bus2ip_rnw;		// From xgmac_dut of xgmac_dut.v
   wire			core_clk156_out;	// From axi_10g_mac_phy of axi_10gmacphy.v
   wire [31:0]		ip2bus_data;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire			ip2bus_error;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire			ip2bus_rdack;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire			ip2bus_wrack;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire			linkup;			// From axi_10g_mac_phy of axi_10gmacphy.v
   wire			resetdone;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire [63:0]		rx_axis_tdata;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire [7:0]		rx_axis_tkeep;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire			rx_axis_tlast;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire			rx_axis_tready;		// From xgmac_address_swap of xgmac_address_swap.v
   wire			rx_axis_tuser;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire			rx_axis_tvalid;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire			rx_clk;			// From xgmac_dut of xgmac_dut.v
   wire			rx_mac_aclk;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire			rx_reset;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire [63:0]		tx_axis_tdata;		// From xgmac_address_swap of xgmac_address_swap.v
   wire [7:0]		tx_axis_tkeep;		// From xgmac_address_swap of xgmac_address_swap.v
   wire			tx_axis_tlast;		// From xgmac_address_swap of xgmac_address_swap.v
   wire			tx_axis_tready;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire [127:0]		tx_axis_tuser;		// From xgmac_dut of xgmac_dut.v
   wire			tx_axis_tvalid;		// From xgmac_address_swap of xgmac_address_swap.v
   wire			tx_mac_aclk;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire			tx_reset;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire			xgmacint;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire [7:0]		xgmii_rxc_dbg;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire [63:0]		xgmii_rxd_dbg;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire [7:0]		xgmii_txc_dbg;		// From axi_10g_mac_phy of axi_10gmacphy.v
   wire [63:0]		xgmii_txd_dbg;		// From axi_10g_mac_phy of axi_10gmacphy.v
   // End of automatics
   
   axi_10gmacphy    #(.C_DBG_PORT(1))
     axi_10g_mac_phy (/*AUTOINST*/
		      // Outputs
		      .core_clk156_out	(core_clk156_out),
		      .ip2bus_data	(ip2bus_data[31:0]),
		      .ip2bus_error	(ip2bus_error),
		      .ip2bus_rdack	(ip2bus_rdack),
		      .ip2bus_wrack	(ip2bus_wrack),
		      .linkup		(linkup),
		      .resetdone	(resetdone),
		      .rx_axis_tdata	(rx_axis_tdata[63:0]),
		      .rx_axis_tkeep	(rx_axis_tkeep[7:0]),
		      .rx_axis_tlast	(rx_axis_tlast),
		      .rx_axis_tuser	(rx_axis_tuser),
		      .rx_axis_tvalid	(rx_axis_tvalid),
		      .rx_mac_aclk	(rx_mac_aclk),
		      .rx_reset		(rx_reset),
		      .sfp_rs		(sfp_rs),
		      .tx_axis_tready	(tx_axis_tready),
		      .tx_disable	(tx_disable),
		      .tx_mac_aclk	(tx_mac_aclk),
		      .tx_reset		(tx_reset),
		      .txn		(txn),
		      .txp		(txp),
		      .xgmacint		(xgmacint),
		      .xgmii_rxc_dbg	(xgmii_rxc_dbg[7:0]),
		      .xgmii_rxd_dbg	(xgmii_rxd_dbg[63:0]),
		      .xgmii_txc_dbg	(xgmii_txc_dbg[7:0]),
		      .xgmii_txd_dbg	(xgmii_txd_dbg[63:0]),
		      // Inputs
		      .bus2ip_addr	(bus2ip_addr[31:0]),
		      .bus2ip_clk	(bus2ip_clk),
		      .bus2ip_cs	(bus2ip_cs),
		      .bus2ip_data	(bus2ip_data[31:0]),
		      .bus2ip_reset	(bus2ip_reset),
		      .bus2ip_rnw	(bus2ip_rnw),
		      .refclk_n		(refclk_n),
		      .refclk_p		(refclk_p),
		      .reset		(reset),
		      .rx_axis_tready	(rx_axis_tready),
		      .rxn		(rxn),
		      .rxp		(rxp),
		      .signal_detect	(signal_detect),
		      .tx_axis_tdata	(tx_axis_tdata[63:0]),
		      .tx_axis_tkeep	(tx_axis_tkeep[7:0]),
		      .tx_axis_tlast	(tx_axis_tlast),
		      .tx_axis_tuser	(tx_axis_tuser[127:0]),
		      .tx_axis_tvalid	(tx_axis_tvalid),
		      .tx_fault		(tx_fault));

   xgmac_address_swap
     xgmac_address_swap (/*AUTOINST*/
			 // Outputs
			 .rx_axis_tready	(rx_axis_tready),
			 .tx_axis_tdata		(tx_axis_tdata[63:0]),
			 .tx_axis_tkeep		(tx_axis_tkeep[7:0]),
			 .tx_axis_tlast		(tx_axis_tlast),
			 .tx_axis_tvalid	(tx_axis_tvalid),
			 // Inputs
			 .reset			(reset),
			 .rx_clk		(rx_clk),
			 .rx_axis_tdata		(rx_axis_tdata[63:0]),
			 .rx_axis_tkeep		(rx_axis_tkeep[7:0]),
			 .rx_axis_tlast		(rx_axis_tlast),
			 .rx_axis_tvalid	(rx_axis_tvalid),
			 .tx_axis_tready	(tx_axis_tready));

   xgmac_dut
     xgmac_dut (/*AUTOINST*/
		// Outputs
		.bus2ip_addr		(bus2ip_addr[31:0]),
		.bus2ip_data		(bus2ip_data[31:0]),
		.bus2ip_clk		(bus2ip_clk),
		.bus2ip_cs		(bus2ip_cs),
		.bus2ip_reset		(bus2ip_reset),
		.bus2ip_rnw		(bus2ip_rnw),
		.rx_clk			(rx_clk),
		.tx_axis_tuser		(tx_axis_tuser[127:0]),
		// Inputs
		.ip2bus_data		(ip2bus_data[31:0]),
		.ip2bus_error		(ip2bus_error),
		.ip2bus_rdack		(ip2bus_rdack),
		.ip2bus_wrack		(ip2bus_wrack),
		.core_clk156_out	(core_clk156_out),
		.rx_axis_tready		(rx_axis_tready),
		.rx_axis_tuser		(rx_axis_tuser),
		.xgmacint		(xgmacint),
		.linkup			(linkup),
		.xgmii_txd_dbg		(xgmii_txd_dbg[63:0]),
		.xgmii_rxd_dbg		(xgmii_rxd_dbg[63:0]),
		.xgmii_txc_dbg		(xgmii_txc_dbg[7:0]),
		.xgmii_rxc_dbg		(xgmii_rxc_dbg[7:0]),
		.rx_mac_aclk		(rx_mac_aclk),
		.rx_reset		(rx_reset),
		.tx_mac_aclk		(tx_mac_aclk),
		.tx_reset		(tx_reset),
		.resetdone		(resetdone));

endmodule // mac_loopback
// Local Variables:
// verilog-library-directories:("../hdl/verilog/" "../sim/" ".")
// verilog-library-files:("")
// verilog-library-extensions:(".v" ".h")
// End:
// 
// mac_loopback.v ends here
