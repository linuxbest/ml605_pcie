// axi_10g_mac_phy.v --- 
// 
// Filename: axi_10g_mac_phy.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Apr  6 14:10:54 2014 (-0700)
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
module axi_10g_mac_phy (/*AUTOARG*/
   // Outputs
   txp, txn, txclk322, tx_resetdone, tx_disable, tx_axis_tready,
   training_wrack, training_rddata, training_rdack, rxclk322,
   rx_resetdone, rx_axis_tvalid, rx_axis_tuser, rx_axis_tlast,
   rx_axis_tkeep, rx_axis_tdata, dclk, core_status, clk156,
   // Inputs
   xphy_reset, txreset322, tx_ifg_delay, tx_fault, tx_dcm_lock,
   tx_clk0, tx_axis_tvalid, tx_axis_tuser, tx_axis_tlast,
   tx_axis_tkeep, tx_axis_tdata, tx_axis_aresetn, training_wrdata,
   training_rnw, training_ipif_cs, training_enable, training_drp_cs,
   training_addr, signal_detect, rxreset322, rxp, rxn, rx_dcm_lock,
   rx_clk0, rx_axis_aresetn, reset, refclk_p, refclk_n, prtad,
   an_enable
   );
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		an_enable;		// To xphy_block of xphy_block.v
   input [4:0]		prtad;			// To xphy_block of xphy_block.v
   input		refclk_n;		// To xphy_block of xphy_block.v
   input		refclk_p;		// To xphy_block of xphy_block.v
   input		reset;			// To xgmac of xgmac.v, ...
   input		rx_axis_aresetn;	// To xgmac of xgmac.v
   input		rx_clk0;		// To xgmac of xgmac.v
   input		rx_dcm_lock;		// To xgmac of xgmac.v
   input		rxn;			// To xphy_block of xphy_block.v
   input		rxp;			// To xphy_block of xphy_block.v
   input		rxreset322;		// To xphy_block of xphy_block.v
   input		signal_detect;		// To xphy_block of xphy_block.v
   input [20:0]		training_addr;		// To xphy_block of xphy_block.v
   input		training_drp_cs;	// To xphy_block of xphy_block.v
   input		training_enable;	// To xphy_block of xphy_block.v
   input		training_ipif_cs;	// To xphy_block of xphy_block.v
   input		training_rnw;		// To xphy_block of xphy_block.v
   input [15:0]		training_wrdata;	// To xphy_block of xphy_block.v
   input		tx_axis_aresetn;	// To xgmac of xgmac.v
   input [63:0]		tx_axis_tdata;		// To xgmac of xgmac.v
   input [7:0]		tx_axis_tkeep;		// To xgmac of xgmac.v
   input		tx_axis_tlast;		// To xgmac of xgmac.v
   input		tx_axis_tuser;		// To xgmac of xgmac.v
   input		tx_axis_tvalid;		// To xgmac of xgmac.v
   input		tx_clk0;		// To xgmac of xgmac.v
   input		tx_dcm_lock;		// To xgmac of xgmac.v
   input		tx_fault;		// To xphy_block of xphy_block.v
   input [7:0]		tx_ifg_delay;		// To xgmac of xgmac.v
   input		txreset322;		// To xphy_block of xphy_block.v
   input		xphy_reset;		// To xphy_int of xphy_int.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		clk156;			// From xphy_block of xphy_block.v
   output [7:0]		core_status;		// From xphy_block of xphy_block.v
   output		dclk;			// From xphy_block of xphy_block.v
   output [63:0]	rx_axis_tdata;		// From xgmac of xgmac.v
   output [7:0]		rx_axis_tkeep;		// From xgmac of xgmac.v
   output		rx_axis_tlast;		// From xgmac of xgmac.v
   output		rx_axis_tuser;		// From xgmac of xgmac.v
   output		rx_axis_tvalid;		// From xgmac of xgmac.v
   output		rx_resetdone;		// From xphy_block of xphy_block.v
   output		rxclk322;		// From xphy_block of xphy_block.v
   output		training_rdack;		// From xphy_block of xphy_block.v
   output [15:0]	training_rddata;	// From xphy_block of xphy_block.v
   output		training_wrack;		// From xphy_block of xphy_block.v
   output		tx_axis_tready;		// From xgmac of xgmac.v
   output		tx_disable;		// From xphy_block of xphy_block.v
   output		tx_resetdone;		// From xphy_block of xphy_block.v
   output		txclk322;		// From xphy_block of xphy_block.v
   output		txn;			// From xphy_block of xphy_block.v
   output		txp;			// From xphy_block of xphy_block.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			areset;			// From xphy_int of xphy_int.v
   wire			dclk_reset;		// From xphy_int of xphy_int.v
   wire			is_eval;		// From xphy_block of xphy_block.v
   wire			mdc;			// From xphy_int of xphy_int.v
   wire			mdio_in;		// From xphy_int of xphy_int.v
   wire			mdio_out;		// From xphy_block of xphy_block.v
   wire			mdio_tri;		// From xphy_block of xphy_block.v
   wire			pause_req;		// From xgmac_int of xgmac_int.v
   wire [15:0]		pause_val;		// From xgmac_int of xgmac_int.v
   wire [79:0]		rx_configuration_vector;// From xgmac_int of xgmac_int.v
   wire			rx_statistics_valid;	// From xgmac of xgmac.v
   wire [29:0]		rx_statistics_vector;	// From xgmac of xgmac.v
   wire [1:0]		status_vector;		// From xgmac of xgmac.v
   wire [79:0]		tx_configuration_vector;// From xgmac_int of xgmac_int.v
   wire			tx_statistics_valid;	// From xgmac of xgmac.v
   wire [25:0]		tx_statistics_vector;	// From xgmac of xgmac.v
   wire [7:0]		xgmii_rxc;		// From xphy_block of xphy_block.v
   wire [63:0]		xgmii_rxd;		// From xphy_block of xphy_block.v
   wire [7:0]		xgmii_txc;		// From xgmac of xgmac.v
   wire [63:0]		xgmii_txd;		// From xgmac of xgmac.v
   // End of automatics

   xgmac
     xgmac (/*AUTOINST*/
	    // Outputs
	    .tx_axis_tready		(tx_axis_tready),
	    .tx_statistics_valid	(tx_statistics_valid),
	    .rx_axis_tvalid		(rx_axis_tvalid),
	    .rx_axis_tuser		(rx_axis_tuser),
	    .rx_axis_tlast		(rx_axis_tlast),
	    .rx_statistics_valid	(rx_statistics_valid),
	    .tx_statistics_vector	(tx_statistics_vector[25:0]),
	    .rx_axis_tdata		(rx_axis_tdata[63:0]),
	    .rx_axis_tkeep		(rx_axis_tkeep[7:0]),
	    .rx_statistics_vector	(rx_statistics_vector[29:0]),
	    .status_vector		(status_vector[1:0]),
	    .xgmii_txd			(xgmii_txd[63:0]),
	    .xgmii_txc			(xgmii_txc[7:0]),
	    // Inputs
	    .reset			(reset),
	    .tx_axis_aresetn		(tx_axis_aresetn),
	    .tx_axis_tvalid		(tx_axis_tvalid),
	    .tx_axis_tlast		(tx_axis_tlast),
	    .tx_axis_tuser		(tx_axis_tuser),
	    .rx_axis_aresetn		(rx_axis_aresetn),
	    .pause_req			(pause_req),
	    .tx_clk0			(tx_clk0),
	    .tx_dcm_lock		(tx_dcm_lock),
	    .rx_clk0			(rx_clk0),
	    .rx_dcm_lock		(rx_dcm_lock),
	    .tx_axis_tdata		(tx_axis_tdata[63:0]),
	    .tx_ifg_delay		(tx_ifg_delay[7:0]),
	    .tx_axis_tkeep		(tx_axis_tkeep[7:0]),
	    .pause_val			(pause_val[15:0]),
	    .tx_configuration_vector	(tx_configuration_vector[79:0]),
	    .rx_configuration_vector	(rx_configuration_vector[79:0]),
	    .xgmii_rxd			(xgmii_rxd[63:0]),
	    .xgmii_rxc			(xgmii_rxc[7:0]));

   xgmac_int
     xgmac_int (/*AUTOINST*/
		// Outputs
		.pause_req		(pause_req),
		.pause_val		(pause_val[15:0]),
		.rx_configuration_vector(rx_configuration_vector[79:0]),
		.tx_configuration_vector(tx_configuration_vector[79:0]),
		// Inputs
		.rx_statistics_valid	(rx_statistics_valid),
		.rx_statistics_vector	(rx_statistics_vector[29:0]),
		.status_vector		(status_vector[1:0]),
		.tx_statistics_valid	(tx_statistics_valid),
		.tx_statistics_vector	(tx_statistics_vector[25:0]));


   xphy_block
     xphy_block (/*AUTOINST*/
		 // Outputs
		 .clk156		(clk156),
		 .txclk322		(txclk322),
		 .rxclk322		(rxclk322),
		 .dclk			(dclk),
		 .txp			(txp),
		 .txn			(txn),
		 .xgmii_rxd		(xgmii_rxd[63:0]),
		 .xgmii_rxc		(xgmii_rxc[7:0]),
		 .mdio_out		(mdio_out),
		 .mdio_tri		(mdio_tri),
		 .core_status		(core_status[7:0]),
		 .tx_resetdone		(tx_resetdone),
		 .rx_resetdone		(rx_resetdone),
		 .tx_disable		(tx_disable),
		 .is_eval		(is_eval),
		 .training_rddata	(training_rddata[15:0]),
		 .training_rdack	(training_rdack),
		 .training_wrack	(training_wrack),
		 // Inputs
		 .refclk_n		(refclk_n),
		 .refclk_p		(refclk_p),
		 .areset		(areset),
		 .reset			(reset),
		 .txreset322		(txreset322),
		 .rxreset322		(rxreset322),
		 .dclk_reset		(dclk_reset),
		 .rxp			(rxp),
		 .rxn			(rxn),
		 .xgmii_txd		(xgmii_txd[63:0]),
		 .xgmii_txc		(xgmii_txc[7:0]),
		 .mdc			(mdc),
		 .mdio_in		(mdio_in),
		 .prtad			(prtad[4:0]),
		 .signal_detect		(signal_detect),
		 .tx_fault		(tx_fault),
		 .an_enable		(an_enable),
		 .training_enable	(training_enable),
		 .training_addr		(training_addr[20:0]),
		 .training_rnw		(training_rnw),
		 .training_wrdata	(training_wrdata[15:0]),
		 .training_ipif_cs	(training_ipif_cs),
		 .training_drp_cs	(training_drp_cs));

   xphy_int
     xphy_int  (/*AUTOINST*/
		// Outputs
		.areset			(areset),
		.dclk_reset		(dclk_reset),
		.mdc			(mdc),
		.mdio_in		(mdio_in),
		// Inputs
		.xphy_reset		(xphy_reset),
		.mdio_out		(mdio_out),
		.mdio_tri		(mdio_tri),
		.is_eval		(is_eval));
   
endmodule
// 
// axi_10g_mac_phy.v ends here
