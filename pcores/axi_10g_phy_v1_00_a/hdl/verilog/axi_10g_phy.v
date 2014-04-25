// xphy_block_quad.v --- 
// 
// Filename: xphy_block_quad.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Thu Apr 24 13:56:34 2014 (-0700)
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
`timescale 1ns / 1ps
module axi_10g_phy (/*AUTOARG*/
   // Outputs
   xgmii_rxd3, xgmii_rxd2, xgmii_rxd1, xgmii_rxd0, xgmii_rxc3,
   xgmii_rxc2, xgmii_rxc1, xgmii_rxc0, txp, txn, tx_resetdone3,
   tx_resetdone2, tx_resetdone1, tx_resetdone0, sfp_txd, sfp_rs,
   rx_resetdone3, rx_resetdone2, rx_resetdone1, rx_resetdone0,
   mdio_tri3, mdio_tri2, mdio_tri1, mdio_tri0, mdio_out3, mdio_out2,
   mdio_out1, mdio_out0, core_status3, core_status2, core_status1,
   core_status0, clk156,
   // Inputs
   xgmii_txd3, xgmii_txd2, xgmii_txd1, xgmii_txd0, xgmii_txc3,
   xgmii_txc2, xgmii_txc1, xgmii_txc0, sfp_txf, sfp_sgd, rxp, rxn,
   refclk_p, refclk_n, mdio_in3, mdio_in2, mdio_in1, mdio_in0, mdc3,
   mdc2, mdc1, mdc0, hw_reset
   );
   parameter C_FAMILY = "kintex7";
   parameter EXAMPLE_SIM_GTRESET_SPEEDUP = "FALSE";
   parameter C_DBG_PORT = 0;
   
   output               clk156;
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		hw_reset;		// To phy_0 of xphy_block_gt.v, ...
   input		mdc0;			// To phy_0 of xphy_block_gt.v
   input		mdc1;			// To phy_1 of xphy_block_gt.v
   input		mdc2;			// To phy_2 of xphy_block_gt.v
   input		mdc3;			// To phy_3 of xphy_block_gt.v
   input		mdio_in0;		// To phy_0 of xphy_block_gt.v
   input		mdio_in1;		// To phy_1 of xphy_block_gt.v
   input		mdio_in2;		// To phy_2 of xphy_block_gt.v
   input		mdio_in3;		// To phy_3 of xphy_block_gt.v
   input		refclk_n;		// To xphy_block_clk of xphy_block_clk.v
   input		refclk_p;		// To xphy_block_clk of xphy_block_clk.v
   input [3:0]		rxn;			// To xphy_gt_quad of xphy_gt_quad.v
   input [3:0]		rxp;			// To xphy_gt_quad of xphy_gt_quad.v
   input [3:0]		sfp_sgd;		// To phy_0 of xphy_block_gt.v, ...
   input [3:0]		sfp_txf;		// To phy_0 of xphy_block_gt.v, ...
   input [7:0]		xgmii_txc0;		// To phy_0 of xphy_block_gt.v
   input [7:0]		xgmii_txc1;		// To phy_1 of xphy_block_gt.v
   input [7:0]		xgmii_txc2;		// To phy_2 of xphy_block_gt.v
   input [7:0]		xgmii_txc3;		// To phy_3 of xphy_block_gt.v
   input [63:0]		xgmii_txd0;		// To phy_0 of xphy_block_gt.v
   input [63:0]		xgmii_txd1;		// To phy_1 of xphy_block_gt.v
   input [63:0]		xgmii_txd2;		// To phy_2 of xphy_block_gt.v
   input [63:0]		xgmii_txd3;		// To phy_3 of xphy_block_gt.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [7:0]		core_status0;		// From phy_0 of xphy_block_gt.v
   output [7:0]		core_status1;		// From phy_1 of xphy_block_gt.v
   output [7:0]		core_status2;		// From phy_2 of xphy_block_gt.v
   output [7:0]		core_status3;		// From phy_3 of xphy_block_gt.v
   output		mdio_out0;		// From phy_0 of xphy_block_gt.v
   output		mdio_out1;		// From phy_1 of xphy_block_gt.v
   output		mdio_out2;		// From phy_2 of xphy_block_gt.v
   output		mdio_out3;		// From phy_3 of xphy_block_gt.v
   output		mdio_tri0;		// From phy_0 of xphy_block_gt.v
   output		mdio_tri1;		// From phy_1 of xphy_block_gt.v
   output		mdio_tri2;		// From phy_2 of xphy_block_gt.v
   output		mdio_tri3;		// From phy_3 of xphy_block_gt.v
   output		rx_resetdone0;		// From phy_0 of xphy_block_gt.v
   output		rx_resetdone1;		// From phy_1 of xphy_block_gt.v
   output		rx_resetdone2;		// From phy_2 of xphy_block_gt.v
   output		rx_resetdone3;		// From phy_3 of xphy_block_gt.v
   output [3:0]		sfp_rs;			// From phy_0 of xphy_block_gt.v, ...
   output [3:0]		sfp_txd;		// From phy_0 of xphy_block_gt.v, ...
   output		tx_resetdone0;		// From phy_0 of xphy_block_gt.v
   output		tx_resetdone1;		// From phy_1 of xphy_block_gt.v
   output		tx_resetdone2;		// From phy_2 of xphy_block_gt.v
   output		tx_resetdone3;		// From phy_3 of xphy_block_gt.v
   output [3:0]		txn;			// From xphy_gt_quad of xphy_gt_quad.v
   output [3:0]		txp;			// From xphy_gt_quad of xphy_gt_quad.v
   output [7:0]		xgmii_rxc0;		// From phy_0 of xphy_block_gt.v
   output [7:0]		xgmii_rxc1;		// From phy_1 of xphy_block_gt.v
   output [7:0]		xgmii_rxc2;		// From phy_2 of xphy_block_gt.v
   output [7:0]		xgmii_rxc3;		// From phy_3 of xphy_block_gt.v
   output [63:0]	xgmii_rxd0;		// From phy_0 of xphy_block_gt.v
   output [63:0]	xgmii_rxd1;		// From phy_1 of xphy_block_gt.v
   output [63:0]	xgmii_rxd2;		// From phy_2 of xphy_block_gt.v
   output [63:0]	xgmii_rxd3;		// From phy_3 of xphy_block_gt.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [8:0]		GT0_DRPADDR_IN;		// From phy_0 of xphy_block_gt.v
   wire			GT0_DRPCLK_IN;		// From phy_0 of xphy_block_gt.v
   wire [15:0]		GT0_DRPDI_IN;		// From phy_0 of xphy_block_gt.v
   wire [15:0]		GT0_DRPDO_OUT;		// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT0_DRPEN_IN;		// From phy_0 of xphy_block_gt.v
   wire			GT0_DRPRDY_OUT;		// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT0_DRPWE_IN;		// From phy_0 of xphy_block_gt.v
   wire			GT0_EYESCANDATAERROR_OUT;// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT0_GTRXRESET_IN;	// From phy_0 of xphy_block_gt.v
   wire			GT0_GTTXRESET_IN;	// From phy_0 of xphy_block_gt.v
   wire [2:0]		GT0_LOOPBACK_IN;	// From phy_0 of xphy_block_gt.v
   wire			GT0_RXBUFRESET_IN;	// From phy_0 of xphy_block_gt.v
   wire [2:0]		GT0_RXBUFSTATUS_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT0_RXCDRLOCK_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT0_RXDATAVALID_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [31:0]		GT0_RXDATA_OUT;		// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT0_RXELECIDLE_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT0_RXGEARBOXSLIP_IN;	// From phy_0 of xphy_block_gt.v
   wire			GT0_RXHEADERVALID_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [1:0]		GT0_RXHEADER_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT0_RXLPMEN_IN;		// From phy_0 of xphy_block_gt.v
   wire			GT0_RXOUTCLK_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT0_RXPCSRESET_IN;	// From phy_0 of xphy_block_gt.v
   wire			GT0_RXPRBSCNTRESET_IN;	// From phy_0 of xphy_block_gt.v
   wire			GT0_RXPRBSERR_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [2:0]		GT0_RXPRBSSEL_IN;	// From phy_0 of xphy_block_gt.v
   wire			GT0_RXRESETDONE_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT0_RXUSERRDY_IN;	// From phy_0 of xphy_block_gt.v
   wire			GT0_RXUSRCLK2_IN;	// From phy_0 of xphy_block_gt.v
   wire			GT0_RXUSRCLK_IN;	// From phy_0 of xphy_block_gt.v
   wire [31:0]		GT0_TXDATA_IN;		// From phy_0 of xphy_block_gt.v
   wire [1:0]		GT0_TXHEADER_IN;	// From phy_0 of xphy_block_gt.v
   wire			GT0_TXINHIBIT_IN;	// From phy_0 of xphy_block_gt.v
   wire [6:0]		GT0_TXMAINCURSOR_IN;	// From phy_0 of xphy_block_gt.v
   wire			GT0_TXOUTCLKFABRIC_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT0_TXOUTCLKPCS_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT0_TXOUTCLK_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT0_TXPCSRESET_IN;	// From phy_0 of xphy_block_gt.v
   wire [4:0]		GT0_TXPOSTCURSOR_IN;	// From phy_0 of xphy_block_gt.v
   wire [2:0]		GT0_TXPRBSSEL_IN;	// From phy_0 of xphy_block_gt.v
   wire [4:0]		GT0_TXPRECURSOR_IN;	// From phy_0 of xphy_block_gt.v
   wire			GT0_TXRESETDONE_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [6:0]		GT0_TXSEQUENCE_IN;	// From phy_0 of xphy_block_gt.v
   wire			GT0_TXUSERRDY_IN;	// From phy_0 of xphy_block_gt.v
   wire			GT0_TXUSRCLK2_IN;	// From phy_0 of xphy_block_gt.v
   wire			GT0_TXUSRCLK_IN;	// From phy_0 of xphy_block_gt.v
   wire [8:0]		GT1_DRPADDR_IN;		// From phy_1 of xphy_block_gt.v
   wire			GT1_DRPCLK_IN;		// From phy_1 of xphy_block_gt.v
   wire [15:0]		GT1_DRPDI_IN;		// From phy_1 of xphy_block_gt.v
   wire [15:0]		GT1_DRPDO_OUT;		// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT1_DRPEN_IN;		// From phy_1 of xphy_block_gt.v
   wire			GT1_DRPRDY_OUT;		// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT1_DRPWE_IN;		// From phy_1 of xphy_block_gt.v
   wire			GT1_EYESCANDATAERROR_OUT;// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT1_GTRXRESET_IN;	// From phy_1 of xphy_block_gt.v
   wire			GT1_GTTXRESET_IN;	// From phy_1 of xphy_block_gt.v
   wire [2:0]		GT1_LOOPBACK_IN;	// From phy_1 of xphy_block_gt.v
   wire			GT1_RXBUFRESET_IN;	// From phy_1 of xphy_block_gt.v
   wire [2:0]		GT1_RXBUFSTATUS_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT1_RXCDRLOCK_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT1_RXDATAVALID_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [31:0]		GT1_RXDATA_OUT;		// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT1_RXELECIDLE_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT1_RXGEARBOXSLIP_IN;	// From phy_1 of xphy_block_gt.v
   wire			GT1_RXHEADERVALID_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [1:0]		GT1_RXHEADER_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT1_RXLPMEN_IN;		// From phy_1 of xphy_block_gt.v
   wire			GT1_RXOUTCLK_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT1_RXPCSRESET_IN;	// From phy_1 of xphy_block_gt.v
   wire			GT1_RXPRBSCNTRESET_IN;	// From phy_1 of xphy_block_gt.v
   wire			GT1_RXPRBSERR_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [2:0]		GT1_RXPRBSSEL_IN;	// From phy_1 of xphy_block_gt.v
   wire			GT1_RXRESETDONE_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT1_RXUSERRDY_IN;	// From phy_1 of xphy_block_gt.v
   wire			GT1_RXUSRCLK2_IN;	// From phy_1 of xphy_block_gt.v
   wire			GT1_RXUSRCLK_IN;	// From phy_1 of xphy_block_gt.v
   wire [31:0]		GT1_TXDATA_IN;		// From phy_1 of xphy_block_gt.v
   wire [1:0]		GT1_TXHEADER_IN;	// From phy_1 of xphy_block_gt.v
   wire			GT1_TXINHIBIT_IN;	// From phy_1 of xphy_block_gt.v
   wire [6:0]		GT1_TXMAINCURSOR_IN;	// From phy_1 of xphy_block_gt.v
   wire			GT1_TXOUTCLKFABRIC_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT1_TXOUTCLKPCS_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT1_TXOUTCLK_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT1_TXPCSRESET_IN;	// From phy_1 of xphy_block_gt.v
   wire [4:0]		GT1_TXPOSTCURSOR_IN;	// From phy_1 of xphy_block_gt.v
   wire [2:0]		GT1_TXPRBSSEL_IN;	// From phy_1 of xphy_block_gt.v
   wire [4:0]		GT1_TXPRECURSOR_IN;	// From phy_1 of xphy_block_gt.v
   wire			GT1_TXRESETDONE_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [6:0]		GT1_TXSEQUENCE_IN;	// From phy_1 of xphy_block_gt.v
   wire			GT1_TXUSERRDY_IN;	// From phy_1 of xphy_block_gt.v
   wire			GT1_TXUSRCLK2_IN;	// From phy_1 of xphy_block_gt.v
   wire			GT1_TXUSRCLK_IN;	// From phy_1 of xphy_block_gt.v
   wire [8:0]		GT2_DRPADDR_IN;		// From phy_2 of xphy_block_gt.v
   wire			GT2_DRPCLK_IN;		// From phy_2 of xphy_block_gt.v
   wire [15:0]		GT2_DRPDI_IN;		// From phy_2 of xphy_block_gt.v
   wire [15:0]		GT2_DRPDO_OUT;		// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT2_DRPEN_IN;		// From phy_2 of xphy_block_gt.v
   wire			GT2_DRPRDY_OUT;		// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT2_DRPWE_IN;		// From phy_2 of xphy_block_gt.v
   wire			GT2_EYESCANDATAERROR_OUT;// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT2_GTRXRESET_IN;	// From phy_2 of xphy_block_gt.v
   wire			GT2_GTTXRESET_IN;	// From phy_2 of xphy_block_gt.v
   wire [2:0]		GT2_LOOPBACK_IN;	// From phy_2 of xphy_block_gt.v
   wire			GT2_RXBUFRESET_IN;	// From phy_2 of xphy_block_gt.v
   wire [2:0]		GT2_RXBUFSTATUS_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT2_RXCDRLOCK_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT2_RXDATAVALID_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [31:0]		GT2_RXDATA_OUT;		// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT2_RXELECIDLE_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT2_RXGEARBOXSLIP_IN;	// From phy_2 of xphy_block_gt.v
   wire			GT2_RXHEADERVALID_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [1:0]		GT2_RXHEADER_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT2_RXLPMEN_IN;		// From phy_2 of xphy_block_gt.v
   wire			GT2_RXOUTCLK_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT2_RXPCSRESET_IN;	// From phy_2 of xphy_block_gt.v
   wire			GT2_RXPRBSCNTRESET_IN;	// From phy_2 of xphy_block_gt.v
   wire			GT2_RXPRBSERR_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [2:0]		GT2_RXPRBSSEL_IN;	// From phy_2 of xphy_block_gt.v
   wire			GT2_RXRESETDONE_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT2_RXUSERRDY_IN;	// From phy_2 of xphy_block_gt.v
   wire			GT2_RXUSRCLK2_IN;	// From phy_2 of xphy_block_gt.v
   wire			GT2_RXUSRCLK_IN;	// From phy_2 of xphy_block_gt.v
   wire [31:0]		GT2_TXDATA_IN;		// From phy_2 of xphy_block_gt.v
   wire [1:0]		GT2_TXHEADER_IN;	// From phy_2 of xphy_block_gt.v
   wire			GT2_TXINHIBIT_IN;	// From phy_2 of xphy_block_gt.v
   wire [6:0]		GT2_TXMAINCURSOR_IN;	// From phy_2 of xphy_block_gt.v
   wire			GT2_TXOUTCLKFABRIC_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT2_TXOUTCLKPCS_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT2_TXOUTCLK_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT2_TXPCSRESET_IN;	// From phy_2 of xphy_block_gt.v
   wire [4:0]		GT2_TXPOSTCURSOR_IN;	// From phy_2 of xphy_block_gt.v
   wire [2:0]		GT2_TXPRBSSEL_IN;	// From phy_2 of xphy_block_gt.v
   wire [4:0]		GT2_TXPRECURSOR_IN;	// From phy_2 of xphy_block_gt.v
   wire			GT2_TXRESETDONE_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [6:0]		GT2_TXSEQUENCE_IN;	// From phy_2 of xphy_block_gt.v
   wire			GT2_TXUSERRDY_IN;	// From phy_2 of xphy_block_gt.v
   wire			GT2_TXUSRCLK2_IN;	// From phy_2 of xphy_block_gt.v
   wire			GT2_TXUSRCLK_IN;	// From phy_2 of xphy_block_gt.v
   wire [8:0]		GT3_DRPADDR_IN;		// From phy_3 of xphy_block_gt.v
   wire			GT3_DRPCLK_IN;		// From phy_3 of xphy_block_gt.v
   wire [15:0]		GT3_DRPDI_IN;		// From phy_3 of xphy_block_gt.v
   wire [15:0]		GT3_DRPDO_OUT;		// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT3_DRPEN_IN;		// From phy_3 of xphy_block_gt.v
   wire			GT3_DRPRDY_OUT;		// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT3_DRPWE_IN;		// From phy_3 of xphy_block_gt.v
   wire			GT3_EYESCANDATAERROR_OUT;// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT3_GTRXRESET_IN;	// From phy_3 of xphy_block_gt.v
   wire			GT3_GTTXRESET_IN;	// From phy_3 of xphy_block_gt.v
   wire [2:0]		GT3_LOOPBACK_IN;	// From phy_3 of xphy_block_gt.v
   wire			GT3_RXBUFRESET_IN;	// From phy_3 of xphy_block_gt.v
   wire [2:0]		GT3_RXBUFSTATUS_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT3_RXCDRLOCK_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT3_RXDATAVALID_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [31:0]		GT3_RXDATA_OUT;		// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT3_RXELECIDLE_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT3_RXGEARBOXSLIP_IN;	// From phy_3 of xphy_block_gt.v
   wire			GT3_RXHEADERVALID_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [1:0]		GT3_RXHEADER_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT3_RXLPMEN_IN;		// From phy_3 of xphy_block_gt.v
   wire			GT3_RXOUTCLK_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT3_RXPCSRESET_IN;	// From phy_3 of xphy_block_gt.v
   wire			GT3_RXPRBSCNTRESET_IN;	// From phy_3 of xphy_block_gt.v
   wire			GT3_RXPRBSERR_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [2:0]		GT3_RXPRBSSEL_IN;	// From phy_3 of xphy_block_gt.v
   wire			GT3_RXRESETDONE_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT3_RXUSERRDY_IN;	// From phy_3 of xphy_block_gt.v
   wire			GT3_RXUSRCLK2_IN;	// From phy_3 of xphy_block_gt.v
   wire			GT3_RXUSRCLK_IN;	// From phy_3 of xphy_block_gt.v
   wire [31:0]		GT3_TXDATA_IN;		// From phy_3 of xphy_block_gt.v
   wire [1:0]		GT3_TXHEADER_IN;	// From phy_3 of xphy_block_gt.v
   wire			GT3_TXINHIBIT_IN;	// From phy_3 of xphy_block_gt.v
   wire [6:0]		GT3_TXMAINCURSOR_IN;	// From phy_3 of xphy_block_gt.v
   wire			GT3_TXOUTCLKFABRIC_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT3_TXOUTCLKPCS_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT3_TXOUTCLK_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire			GT3_TXPCSRESET_IN;	// From phy_3 of xphy_block_gt.v
   wire [4:0]		GT3_TXPOSTCURSOR_IN;	// From phy_3 of xphy_block_gt.v
   wire [2:0]		GT3_TXPRBSSEL_IN;	// From phy_3 of xphy_block_gt.v
   wire [4:0]		GT3_TXPRECURSOR_IN;	// From phy_3 of xphy_block_gt.v
   wire			GT3_TXRESETDONE_OUT;	// From xphy_gt_quad of xphy_gt_quad.v
   wire [6:0]		GT3_TXSEQUENCE_IN;	// From phy_3 of xphy_block_gt.v
   wire			GT3_TXUSERRDY_IN;	// From phy_3 of xphy_block_gt.v
   wire			GT3_TXUSRCLK2_IN;	// From phy_3 of xphy_block_gt.v
   wire			GT3_TXUSRCLK_IN;	// From phy_3 of xphy_block_gt.v
   wire [3:0]		GT_QPLLRESET_IN;	// From phy_0 of xphy_block_gt.v, ...
   wire			dclk;			// From xphy_block_clk of xphy_block_clk.v
   wire			gt0_qplllock_i;		// From xphy_gt_quad of xphy_gt_quad.v
   wire			mmcm_locked;		// From xphy_block_clk of xphy_block_clk.v
   wire			q1_clk0_refclk_i;	// From xphy_block_clk of xphy_block_clk.v
   wire			q1_clk0_refclk_i_bufh;	// From xphy_block_clk of xphy_block_clk.v
   // End of automatics
   
   /* xphy_block_gt AUTO_TEMPLATE "_\([0-3]\)" (
    .xgmii_rxd			(xgmii_rxd@[]),
    .xgmii_rxc			(xgmii_rxc@[]),
    .mdio_out			(mdio_out@),
    .mdio_tri			(mdio_tri@),
    .core_status		(core_status@[]),
    .tx_resetdone		(tx_resetdone@),
    .rx_resetdone		(rx_resetdone@),
    .tx_disable			(sfp_txd[@]),
    .sfp_rs                     (sfp_rs[@]),
    .DRPADDR_IN			(GT@_DRPADDR_IN[8:0]),
    .DRPCLK_IN			(GT@_DRPCLK_IN),
    .DRPDI_IN			(GT@_DRPDI_IN[15:0]),
    .DRPEN_IN			(GT@_DRPEN_IN),
    .DRPWE_IN			(GT@_DRPWE_IN),
    .LOOPBACK_IN		(GT@_LOOPBACK_IN[2:0]),
    .RXUSERRDY_IN		(GT@_RXUSERRDY_IN),
    .RXGEARBOXSLIP_IN		(GT@_RXGEARBOXSLIP_IN),
    .RXPRBSCNTRESET_IN		(GT@_RXPRBSCNTRESET_IN),
    .RXPRBSSEL_IN		(GT@_RXPRBSSEL_IN[2:0]),
    .GTRXRESET_IN		(GT@_GTRXRESET_IN),
    .RXPCSRESET_IN		(GT@_RXPCSRESET_IN),
    .RXUSRCLK_IN		(GT@_RXUSRCLK_IN),
    .RXUSRCLK2_IN		(GT@_RXUSRCLK2_IN),
    .RXLPMEN_IN			(GT@_RXLPMEN_IN),
    .RXBUFRESET_IN		(GT@_RXBUFRESET_IN),
    .TXUSERRDY_IN		(GT@_TXUSERRDY_IN),
    .TXHEADER_IN		(GT@_TXHEADER_IN[1:0]),
    .TXSEQUENCE_IN		(GT@_TXSEQUENCE_IN[6:0]),
    .GTTXRESET_IN		(GT@_GTTXRESET_IN),
    .TXDATA_IN			(GT@_TXDATA_IN[31:0]),
    .TXPCSRESET_IN		(GT@_TXPCSRESET_IN),
    .TXUSRCLK_IN		(GT@_TXUSRCLK_IN),
    .TXUSRCLK2_IN		(GT@_TXUSRCLK2_IN),
    .TXINHIBIT_IN		(GT@_TXINHIBIT_IN),
    .TXPRECURSOR_IN		(GT@_TXPRECURSOR_IN[4:0]),
    .TXPOSTCURSOR_IN		(GT@_TXPOSTCURSOR_IN[4:0]),
    .TXMAINCURSOR_IN		(GT@_TXMAINCURSOR_IN[6:0]),
    .TXPRBSSEL_IN		(GT@_TXPRBSSEL_IN[2:0]),
    .QPLLRESET_IN               (GT_QPLLRESET_IN[@]),
    .rxp			(rxp@),
    .rxn			(rxn@),
    .xgmii_txd			(xgmii_txd@[63:0]),
    .xgmii_txc			(xgmii_txc@[7:0]),
    .mdc			(mdc@),
    .mdio_in			(mdio_in@),
    .prtad			(@),
    .signal_detect		(sfp_sgd[@]),
    .tx_fault			(sfp_txf[@]),
    .DRPDO_OUT			(GT@_DRPDO_OUT[15:0]),
    .DRPRDY_OUT			(GT@_DRPRDY_OUT),
    .EYESCANDATAERROR_OUT	(GT@_EYESCANDATAERROR_OUT),
    .RXDATAVALID_OUT		(GT@_RXDATAVALID_OUT),
    .RXHEADER_OUT		(GT@_RXHEADER_OUT[1:0]),
    .RXHEADERVALID_OUT		(GT@_RXHEADERVALID_OUT),
    .RXDATA_OUT			(GT@_RXDATA_OUT[31:0]),
    .RXOUTCLK_OUT		(GT@_RXOUTCLK_OUT),
    .RXCDRLOCK_OUT		(GT@_RXCDRLOCK_OUT),
    .RXELECIDLE_OUT		(GT@_RXELECIDLE_OUT),
    .RXBUFSTATUS_OUT		(GT@_RXBUFSTATUS_OUT[2:0]),
    .RXRESETDONE_OUT		(GT@_RXRESETDONE_OUT),
    .RXPRBSERR_OUT              (GT@_RXPRBSERR_OUT),
    .TXOUTCLK_OUT		(GT@_TXOUTCLK_OUT),
    .TXOUTCLKFABRIC_OUT		(GT@_TXOUTCLKFABRIC_OUT),
    .TXOUTCLKPCS_OUT		(GT@_TXOUTCLKPCS_OUT),
    .TXRESETDONE_OUT		(GT@_TXRESETDONE_OUT),
    );*/

   xphy_block_gt phy_0 (/*AUTOINST*/
			// Outputs
			.xgmii_rxd	(xgmii_rxd0[63:0]),	 // Templated
			.xgmii_rxc	(xgmii_rxc0[7:0]),	 // Templated
			.mdio_out	(mdio_out0),		 // Templated
			.mdio_tri	(mdio_tri0),		 // Templated
			.core_status	(core_status0[7:0]),	 // Templated
			.tx_resetdone	(tx_resetdone0),	 // Templated
			.rx_resetdone	(rx_resetdone0),	 // Templated
			.tx_disable	(sfp_txd[0]),		 // Templated
			.sfp_rs		(sfp_rs[0]),		 // Templated
			.DRPADDR_IN	(GT0_DRPADDR_IN[8:0]),	 // Templated
			.DRPCLK_IN	(GT0_DRPCLK_IN),	 // Templated
			.DRPDI_IN	(GT0_DRPDI_IN[15:0]),	 // Templated
			.DRPEN_IN	(GT0_DRPEN_IN),		 // Templated
			.DRPWE_IN	(GT0_DRPWE_IN),		 // Templated
			.LOOPBACK_IN	(GT0_LOOPBACK_IN[2:0]),	 // Templated
			.RXUSERRDY_IN	(GT0_RXUSERRDY_IN),	 // Templated
			.RXGEARBOXSLIP_IN(GT0_RXGEARBOXSLIP_IN), // Templated
			.RXPRBSCNTRESET_IN(GT0_RXPRBSCNTRESET_IN), // Templated
			.RXPRBSSEL_IN	(GT0_RXPRBSSEL_IN[2:0]), // Templated
			.GTRXRESET_IN	(GT0_GTRXRESET_IN),	 // Templated
			.RXPCSRESET_IN	(GT0_RXPCSRESET_IN),	 // Templated
			.RXUSRCLK_IN	(GT0_RXUSRCLK_IN),	 // Templated
			.RXUSRCLK2_IN	(GT0_RXUSRCLK2_IN),	 // Templated
			.RXLPMEN_IN	(GT0_RXLPMEN_IN),	 // Templated
			.RXBUFRESET_IN	(GT0_RXBUFRESET_IN),	 // Templated
			.TXUSERRDY_IN	(GT0_TXUSERRDY_IN),	 // Templated
			.TXHEADER_IN	(GT0_TXHEADER_IN[1:0]),	 // Templated
			.TXSEQUENCE_IN	(GT0_TXSEQUENCE_IN[6:0]), // Templated
			.GTTXRESET_IN	(GT0_GTTXRESET_IN),	 // Templated
			.TXDATA_IN	(GT0_TXDATA_IN[31:0]),	 // Templated
			.TXPCSRESET_IN	(GT0_TXPCSRESET_IN),	 // Templated
			.TXUSRCLK_IN	(GT0_TXUSRCLK_IN),	 // Templated
			.TXUSRCLK2_IN	(GT0_TXUSRCLK2_IN),	 // Templated
			.TXINHIBIT_IN	(GT0_TXINHIBIT_IN),	 // Templated
			.TXPRECURSOR_IN	(GT0_TXPRECURSOR_IN[4:0]), // Templated
			.TXPOSTCURSOR_IN(GT0_TXPOSTCURSOR_IN[4:0]), // Templated
			.TXMAINCURSOR_IN(GT0_TXMAINCURSOR_IN[6:0]), // Templated
			.TXPRBSSEL_IN	(GT0_TXPRBSSEL_IN[2:0]), // Templated
			.QPLLRESET_IN	(GT_QPLLRESET_IN[0]),	 // Templated
			// Inputs
			.xgmii_txd	(xgmii_txd0[63:0]),	 // Templated
			.xgmii_txc	(xgmii_txc0[7:0]),	 // Templated
			.mdc		(mdc0),			 // Templated
			.mdio_in	(mdio_in0),		 // Templated
			.prtad		(0),			 // Templated
			.signal_detect	(sfp_sgd[0]),		 // Templated
			.tx_fault	(sfp_txf[0]),		 // Templated
			.hw_reset	(hw_reset),
			.clk156		(clk156),
			.dclk		(dclk),
			.mmcm_locked	(mmcm_locked),
			.gt0_qplllock_i	(gt0_qplllock_i),
			.DRPDO_OUT	(GT0_DRPDO_OUT[15:0]),	 // Templated
			.DRPRDY_OUT	(GT0_DRPRDY_OUT),	 // Templated
			.EYESCANDATAERROR_OUT(GT0_EYESCANDATAERROR_OUT), // Templated
			.RXDATAVALID_OUT(GT0_RXDATAVALID_OUT),	 // Templated
			.RXHEADER_OUT	(GT0_RXHEADER_OUT[1:0]), // Templated
			.RXHEADERVALID_OUT(GT0_RXHEADERVALID_OUT), // Templated
			.RXPRBSERR_OUT	(GT0_RXPRBSERR_OUT),	 // Templated
			.RXDATA_OUT	(GT0_RXDATA_OUT[31:0]),	 // Templated
			.RXOUTCLK_OUT	(GT0_RXOUTCLK_OUT),	 // Templated
			.RXCDRLOCK_OUT	(GT0_RXCDRLOCK_OUT),	 // Templated
			.RXELECIDLE_OUT	(GT0_RXELECIDLE_OUT),	 // Templated
			.RXBUFSTATUS_OUT(GT0_RXBUFSTATUS_OUT[2:0]), // Templated
			.RXRESETDONE_OUT(GT0_RXRESETDONE_OUT),	 // Templated
			.TXOUTCLK_OUT	(GT0_TXOUTCLK_OUT),	 // Templated
			.TXOUTCLKFABRIC_OUT(GT0_TXOUTCLKFABRIC_OUT), // Templated
			.TXOUTCLKPCS_OUT(GT0_TXOUTCLKPCS_OUT),	 // Templated
			.TXRESETDONE_OUT(GT0_TXRESETDONE_OUT),	 // Templated
			.q1_clk0_refclk_i(q1_clk0_refclk_i),
			.q1_clk0_refclk_i_bufh(q1_clk0_refclk_i_bufh));
   xphy_block_gt phy_1 (/*AUTOINST*/
			// Outputs
			.xgmii_rxd	(xgmii_rxd1[63:0]),	 // Templated
			.xgmii_rxc	(xgmii_rxc1[7:0]),	 // Templated
			.mdio_out	(mdio_out1),		 // Templated
			.mdio_tri	(mdio_tri1),		 // Templated
			.core_status	(core_status1[7:0]),	 // Templated
			.tx_resetdone	(tx_resetdone1),	 // Templated
			.rx_resetdone	(rx_resetdone1),	 // Templated
			.tx_disable	(sfp_txd[1]),		 // Templated
			.sfp_rs		(sfp_rs[1]),		 // Templated
			.DRPADDR_IN	(GT1_DRPADDR_IN[8:0]),	 // Templated
			.DRPCLK_IN	(GT1_DRPCLK_IN),	 // Templated
			.DRPDI_IN	(GT1_DRPDI_IN[15:0]),	 // Templated
			.DRPEN_IN	(GT1_DRPEN_IN),		 // Templated
			.DRPWE_IN	(GT1_DRPWE_IN),		 // Templated
			.LOOPBACK_IN	(GT1_LOOPBACK_IN[2:0]),	 // Templated
			.RXUSERRDY_IN	(GT1_RXUSERRDY_IN),	 // Templated
			.RXGEARBOXSLIP_IN(GT1_RXGEARBOXSLIP_IN), // Templated
			.RXPRBSCNTRESET_IN(GT1_RXPRBSCNTRESET_IN), // Templated
			.RXPRBSSEL_IN	(GT1_RXPRBSSEL_IN[2:0]), // Templated
			.GTRXRESET_IN	(GT1_GTRXRESET_IN),	 // Templated
			.RXPCSRESET_IN	(GT1_RXPCSRESET_IN),	 // Templated
			.RXUSRCLK_IN	(GT1_RXUSRCLK_IN),	 // Templated
			.RXUSRCLK2_IN	(GT1_RXUSRCLK2_IN),	 // Templated
			.RXLPMEN_IN	(GT1_RXLPMEN_IN),	 // Templated
			.RXBUFRESET_IN	(GT1_RXBUFRESET_IN),	 // Templated
			.TXUSERRDY_IN	(GT1_TXUSERRDY_IN),	 // Templated
			.TXHEADER_IN	(GT1_TXHEADER_IN[1:0]),	 // Templated
			.TXSEQUENCE_IN	(GT1_TXSEQUENCE_IN[6:0]), // Templated
			.GTTXRESET_IN	(GT1_GTTXRESET_IN),	 // Templated
			.TXDATA_IN	(GT1_TXDATA_IN[31:0]),	 // Templated
			.TXPCSRESET_IN	(GT1_TXPCSRESET_IN),	 // Templated
			.TXUSRCLK_IN	(GT1_TXUSRCLK_IN),	 // Templated
			.TXUSRCLK2_IN	(GT1_TXUSRCLK2_IN),	 // Templated
			.TXINHIBIT_IN	(GT1_TXINHIBIT_IN),	 // Templated
			.TXPRECURSOR_IN	(GT1_TXPRECURSOR_IN[4:0]), // Templated
			.TXPOSTCURSOR_IN(GT1_TXPOSTCURSOR_IN[4:0]), // Templated
			.TXMAINCURSOR_IN(GT1_TXMAINCURSOR_IN[6:0]), // Templated
			.TXPRBSSEL_IN	(GT1_TXPRBSSEL_IN[2:0]), // Templated
			.QPLLRESET_IN	(GT_QPLLRESET_IN[1]),	 // Templated
			// Inputs
			.xgmii_txd	(xgmii_txd1[63:0]),	 // Templated
			.xgmii_txc	(xgmii_txc1[7:0]),	 // Templated
			.mdc		(mdc1),			 // Templated
			.mdio_in	(mdio_in1),		 // Templated
			.prtad		(1),			 // Templated
			.signal_detect	(sfp_sgd[1]),		 // Templated
			.tx_fault	(sfp_txf[1]),		 // Templated
			.hw_reset	(hw_reset),
			.clk156		(clk156),
			.dclk		(dclk),
			.mmcm_locked	(mmcm_locked),
			.gt0_qplllock_i	(gt0_qplllock_i),
			.DRPDO_OUT	(GT1_DRPDO_OUT[15:0]),	 // Templated
			.DRPRDY_OUT	(GT1_DRPRDY_OUT),	 // Templated
			.EYESCANDATAERROR_OUT(GT1_EYESCANDATAERROR_OUT), // Templated
			.RXDATAVALID_OUT(GT1_RXDATAVALID_OUT),	 // Templated
			.RXHEADER_OUT	(GT1_RXHEADER_OUT[1:0]), // Templated
			.RXHEADERVALID_OUT(GT1_RXHEADERVALID_OUT), // Templated
			.RXPRBSERR_OUT	(GT1_RXPRBSERR_OUT),	 // Templated
			.RXDATA_OUT	(GT1_RXDATA_OUT[31:0]),	 // Templated
			.RXOUTCLK_OUT	(GT1_RXOUTCLK_OUT),	 // Templated
			.RXCDRLOCK_OUT	(GT1_RXCDRLOCK_OUT),	 // Templated
			.RXELECIDLE_OUT	(GT1_RXELECIDLE_OUT),	 // Templated
			.RXBUFSTATUS_OUT(GT1_RXBUFSTATUS_OUT[2:0]), // Templated
			.RXRESETDONE_OUT(GT1_RXRESETDONE_OUT),	 // Templated
			.TXOUTCLK_OUT	(GT1_TXOUTCLK_OUT),	 // Templated
			.TXOUTCLKFABRIC_OUT(GT1_TXOUTCLKFABRIC_OUT), // Templated
			.TXOUTCLKPCS_OUT(GT1_TXOUTCLKPCS_OUT),	 // Templated
			.TXRESETDONE_OUT(GT1_TXRESETDONE_OUT),	 // Templated
			.q1_clk0_refclk_i(q1_clk0_refclk_i),
			.q1_clk0_refclk_i_bufh(q1_clk0_refclk_i_bufh));
   xphy_block_gt phy_2 (/*AUTOINST*/
			// Outputs
			.xgmii_rxd	(xgmii_rxd2[63:0]),	 // Templated
			.xgmii_rxc	(xgmii_rxc2[7:0]),	 // Templated
			.mdio_out	(mdio_out2),		 // Templated
			.mdio_tri	(mdio_tri2),		 // Templated
			.core_status	(core_status2[7:0]),	 // Templated
			.tx_resetdone	(tx_resetdone2),	 // Templated
			.rx_resetdone	(rx_resetdone2),	 // Templated
			.tx_disable	(sfp_txd[2]),		 // Templated
			.sfp_rs		(sfp_rs[2]),		 // Templated
			.DRPADDR_IN	(GT2_DRPADDR_IN[8:0]),	 // Templated
			.DRPCLK_IN	(GT2_DRPCLK_IN),	 // Templated
			.DRPDI_IN	(GT2_DRPDI_IN[15:0]),	 // Templated
			.DRPEN_IN	(GT2_DRPEN_IN),		 // Templated
			.DRPWE_IN	(GT2_DRPWE_IN),		 // Templated
			.LOOPBACK_IN	(GT2_LOOPBACK_IN[2:0]),	 // Templated
			.RXUSERRDY_IN	(GT2_RXUSERRDY_IN),	 // Templated
			.RXGEARBOXSLIP_IN(GT2_RXGEARBOXSLIP_IN), // Templated
			.RXPRBSCNTRESET_IN(GT2_RXPRBSCNTRESET_IN), // Templated
			.RXPRBSSEL_IN	(GT2_RXPRBSSEL_IN[2:0]), // Templated
			.GTRXRESET_IN	(GT2_GTRXRESET_IN),	 // Templated
			.RXPCSRESET_IN	(GT2_RXPCSRESET_IN),	 // Templated
			.RXUSRCLK_IN	(GT2_RXUSRCLK_IN),	 // Templated
			.RXUSRCLK2_IN	(GT2_RXUSRCLK2_IN),	 // Templated
			.RXLPMEN_IN	(GT2_RXLPMEN_IN),	 // Templated
			.RXBUFRESET_IN	(GT2_RXBUFRESET_IN),	 // Templated
			.TXUSERRDY_IN	(GT2_TXUSERRDY_IN),	 // Templated
			.TXHEADER_IN	(GT2_TXHEADER_IN[1:0]),	 // Templated
			.TXSEQUENCE_IN	(GT2_TXSEQUENCE_IN[6:0]), // Templated
			.GTTXRESET_IN	(GT2_GTTXRESET_IN),	 // Templated
			.TXDATA_IN	(GT2_TXDATA_IN[31:0]),	 // Templated
			.TXPCSRESET_IN	(GT2_TXPCSRESET_IN),	 // Templated
			.TXUSRCLK_IN	(GT2_TXUSRCLK_IN),	 // Templated
			.TXUSRCLK2_IN	(GT2_TXUSRCLK2_IN),	 // Templated
			.TXINHIBIT_IN	(GT2_TXINHIBIT_IN),	 // Templated
			.TXPRECURSOR_IN	(GT2_TXPRECURSOR_IN[4:0]), // Templated
			.TXPOSTCURSOR_IN(GT2_TXPOSTCURSOR_IN[4:0]), // Templated
			.TXMAINCURSOR_IN(GT2_TXMAINCURSOR_IN[6:0]), // Templated
			.TXPRBSSEL_IN	(GT2_TXPRBSSEL_IN[2:0]), // Templated
			.QPLLRESET_IN	(GT_QPLLRESET_IN[2]),	 // Templated
			// Inputs
			.xgmii_txd	(xgmii_txd2[63:0]),	 // Templated
			.xgmii_txc	(xgmii_txc2[7:0]),	 // Templated
			.mdc		(mdc2),			 // Templated
			.mdio_in	(mdio_in2),		 // Templated
			.prtad		(2),			 // Templated
			.signal_detect	(sfp_sgd[2]),		 // Templated
			.tx_fault	(sfp_txf[2]),		 // Templated
			.hw_reset	(hw_reset),
			.clk156		(clk156),
			.dclk		(dclk),
			.mmcm_locked	(mmcm_locked),
			.gt0_qplllock_i	(gt0_qplllock_i),
			.DRPDO_OUT	(GT2_DRPDO_OUT[15:0]),	 // Templated
			.DRPRDY_OUT	(GT2_DRPRDY_OUT),	 // Templated
			.EYESCANDATAERROR_OUT(GT2_EYESCANDATAERROR_OUT), // Templated
			.RXDATAVALID_OUT(GT2_RXDATAVALID_OUT),	 // Templated
			.RXHEADER_OUT	(GT2_RXHEADER_OUT[1:0]), // Templated
			.RXHEADERVALID_OUT(GT2_RXHEADERVALID_OUT), // Templated
			.RXPRBSERR_OUT	(GT2_RXPRBSERR_OUT),	 // Templated
			.RXDATA_OUT	(GT2_RXDATA_OUT[31:0]),	 // Templated
			.RXOUTCLK_OUT	(GT2_RXOUTCLK_OUT),	 // Templated
			.RXCDRLOCK_OUT	(GT2_RXCDRLOCK_OUT),	 // Templated
			.RXELECIDLE_OUT	(GT2_RXELECIDLE_OUT),	 // Templated
			.RXBUFSTATUS_OUT(GT2_RXBUFSTATUS_OUT[2:0]), // Templated
			.RXRESETDONE_OUT(GT2_RXRESETDONE_OUT),	 // Templated
			.TXOUTCLK_OUT	(GT2_TXOUTCLK_OUT),	 // Templated
			.TXOUTCLKFABRIC_OUT(GT2_TXOUTCLKFABRIC_OUT), // Templated
			.TXOUTCLKPCS_OUT(GT2_TXOUTCLKPCS_OUT),	 // Templated
			.TXRESETDONE_OUT(GT2_TXRESETDONE_OUT),	 // Templated
			.q1_clk0_refclk_i(q1_clk0_refclk_i),
			.q1_clk0_refclk_i_bufh(q1_clk0_refclk_i_bufh));
   xphy_block_gt phy_3 (/*AUTOINST*/
			// Outputs
			.xgmii_rxd	(xgmii_rxd3[63:0]),	 // Templated
			.xgmii_rxc	(xgmii_rxc3[7:0]),	 // Templated
			.mdio_out	(mdio_out3),		 // Templated
			.mdio_tri	(mdio_tri3),		 // Templated
			.core_status	(core_status3[7:0]),	 // Templated
			.tx_resetdone	(tx_resetdone3),	 // Templated
			.rx_resetdone	(rx_resetdone3),	 // Templated
			.tx_disable	(sfp_txd[3]),		 // Templated
			.sfp_rs		(sfp_rs[3]),		 // Templated
			.DRPADDR_IN	(GT3_DRPADDR_IN[8:0]),	 // Templated
			.DRPCLK_IN	(GT3_DRPCLK_IN),	 // Templated
			.DRPDI_IN	(GT3_DRPDI_IN[15:0]),	 // Templated
			.DRPEN_IN	(GT3_DRPEN_IN),		 // Templated
			.DRPWE_IN	(GT3_DRPWE_IN),		 // Templated
			.LOOPBACK_IN	(GT3_LOOPBACK_IN[2:0]),	 // Templated
			.RXUSERRDY_IN	(GT3_RXUSERRDY_IN),	 // Templated
			.RXGEARBOXSLIP_IN(GT3_RXGEARBOXSLIP_IN), // Templated
			.RXPRBSCNTRESET_IN(GT3_RXPRBSCNTRESET_IN), // Templated
			.RXPRBSSEL_IN	(GT3_RXPRBSSEL_IN[2:0]), // Templated
			.GTRXRESET_IN	(GT3_GTRXRESET_IN),	 // Templated
			.RXPCSRESET_IN	(GT3_RXPCSRESET_IN),	 // Templated
			.RXUSRCLK_IN	(GT3_RXUSRCLK_IN),	 // Templated
			.RXUSRCLK2_IN	(GT3_RXUSRCLK2_IN),	 // Templated
			.RXLPMEN_IN	(GT3_RXLPMEN_IN),	 // Templated
			.RXBUFRESET_IN	(GT3_RXBUFRESET_IN),	 // Templated
			.TXUSERRDY_IN	(GT3_TXUSERRDY_IN),	 // Templated
			.TXHEADER_IN	(GT3_TXHEADER_IN[1:0]),	 // Templated
			.TXSEQUENCE_IN	(GT3_TXSEQUENCE_IN[6:0]), // Templated
			.GTTXRESET_IN	(GT3_GTTXRESET_IN),	 // Templated
			.TXDATA_IN	(GT3_TXDATA_IN[31:0]),	 // Templated
			.TXPCSRESET_IN	(GT3_TXPCSRESET_IN),	 // Templated
			.TXUSRCLK_IN	(GT3_TXUSRCLK_IN),	 // Templated
			.TXUSRCLK2_IN	(GT3_TXUSRCLK2_IN),	 // Templated
			.TXINHIBIT_IN	(GT3_TXINHIBIT_IN),	 // Templated
			.TXPRECURSOR_IN	(GT3_TXPRECURSOR_IN[4:0]), // Templated
			.TXPOSTCURSOR_IN(GT3_TXPOSTCURSOR_IN[4:0]), // Templated
			.TXMAINCURSOR_IN(GT3_TXMAINCURSOR_IN[6:0]), // Templated
			.TXPRBSSEL_IN	(GT3_TXPRBSSEL_IN[2:0]), // Templated
			.QPLLRESET_IN	(GT_QPLLRESET_IN[3]),	 // Templated
			// Inputs
			.xgmii_txd	(xgmii_txd3[63:0]),	 // Templated
			.xgmii_txc	(xgmii_txc3[7:0]),	 // Templated
			.mdc		(mdc3),			 // Templated
			.mdio_in	(mdio_in3),		 // Templated
			.prtad		(3),			 // Templated
			.signal_detect	(sfp_sgd[3]),		 // Templated
			.tx_fault	(sfp_txf[3]),		 // Templated
			.hw_reset	(hw_reset),
			.clk156		(clk156),
			.dclk		(dclk),
			.mmcm_locked	(mmcm_locked),
			.gt0_qplllock_i	(gt0_qplllock_i),
			.DRPDO_OUT	(GT3_DRPDO_OUT[15:0]),	 // Templated
			.DRPRDY_OUT	(GT3_DRPRDY_OUT),	 // Templated
			.EYESCANDATAERROR_OUT(GT3_EYESCANDATAERROR_OUT), // Templated
			.RXDATAVALID_OUT(GT3_RXDATAVALID_OUT),	 // Templated
			.RXHEADER_OUT	(GT3_RXHEADER_OUT[1:0]), // Templated
			.RXHEADERVALID_OUT(GT3_RXHEADERVALID_OUT), // Templated
			.RXPRBSERR_OUT	(GT3_RXPRBSERR_OUT),	 // Templated
			.RXDATA_OUT	(GT3_RXDATA_OUT[31:0]),	 // Templated
			.RXOUTCLK_OUT	(GT3_RXOUTCLK_OUT),	 // Templated
			.RXCDRLOCK_OUT	(GT3_RXCDRLOCK_OUT),	 // Templated
			.RXELECIDLE_OUT	(GT3_RXELECIDLE_OUT),	 // Templated
			.RXBUFSTATUS_OUT(GT3_RXBUFSTATUS_OUT[2:0]), // Templated
			.RXRESETDONE_OUT(GT3_RXRESETDONE_OUT),	 // Templated
			.TXOUTCLK_OUT	(GT3_TXOUTCLK_OUT),	 // Templated
			.TXOUTCLKFABRIC_OUT(GT3_TXOUTCLKFABRIC_OUT), // Templated
			.TXOUTCLKPCS_OUT(GT3_TXOUTCLKPCS_OUT),	 // Templated
			.TXRESETDONE_OUT(GT3_TXRESETDONE_OUT),	 // Templated
			.q1_clk0_refclk_i(q1_clk0_refclk_i),
			.q1_clk0_refclk_i_bufh(q1_clk0_refclk_i_bufh));
   
   xphy_block_clk
     xphy_block_clk (/*AUTOINST*/
		     // Outputs
		     .mmcm_locked	(mmcm_locked),
		     .dclk		(dclk),
		     .clk156		(clk156),
		     .q1_clk0_refclk_i	(q1_clk0_refclk_i),
		     .q1_clk0_refclk_i_bufh(q1_clk0_refclk_i_bufh),
		     // Inputs
		     .refclk_p		(refclk_p),
		     .refclk_n		(refclk_n),
		     .gt0_qplllock_i	(gt0_qplllock_i));
   
   xphy_gt_quad #(.WRAPPER_SIM_GTRESET_SPEEDUP(EXAMPLE_SIM_GTRESET_SPEEDUP))
   xphy_gt_quad  (/*AUTOINST*/
		  // Outputs
		  .GT0_DRPDO_OUT	(GT0_DRPDO_OUT[15:0]),
		  .GT0_DRPRDY_OUT	(GT0_DRPRDY_OUT),
		  .GT0_EYESCANDATAERROR_OUT(GT0_EYESCANDATAERROR_OUT),
		  .GT0_RXBUFSTATUS_OUT	(GT0_RXBUFSTATUS_OUT[2:0]),
		  .GT0_RXCDRLOCK_OUT	(GT0_RXCDRLOCK_OUT),
		  .GT0_RXDATAVALID_OUT	(GT0_RXDATAVALID_OUT),
		  .GT0_RXDATA_OUT	(GT0_RXDATA_OUT[31:0]),
		  .GT0_RXELECIDLE_OUT	(GT0_RXELECIDLE_OUT),
		  .GT0_RXHEADERVALID_OUT(GT0_RXHEADERVALID_OUT),
		  .GT0_RXHEADER_OUT	(GT0_RXHEADER_OUT[1:0]),
		  .GT0_RXOUTCLK_OUT	(GT0_RXOUTCLK_OUT),
		  .GT0_RXPRBSERR_OUT	(GT0_RXPRBSERR_OUT),
		  .GT0_RXRESETDONE_OUT	(GT0_RXRESETDONE_OUT),
		  .GT0_TXOUTCLKFABRIC_OUT(GT0_TXOUTCLKFABRIC_OUT),
		  .GT0_TXOUTCLKPCS_OUT	(GT0_TXOUTCLKPCS_OUT),
		  .GT0_TXOUTCLK_OUT	(GT0_TXOUTCLK_OUT),
		  .GT0_TXRESETDONE_OUT	(GT0_TXRESETDONE_OUT),
		  .GT1_DRPDO_OUT	(GT1_DRPDO_OUT[15:0]),
		  .GT1_DRPRDY_OUT	(GT1_DRPRDY_OUT),
		  .GT1_EYESCANDATAERROR_OUT(GT1_EYESCANDATAERROR_OUT),
		  .GT1_RXBUFSTATUS_OUT	(GT1_RXBUFSTATUS_OUT[2:0]),
		  .GT1_RXCDRLOCK_OUT	(GT1_RXCDRLOCK_OUT),
		  .GT1_RXDATAVALID_OUT	(GT1_RXDATAVALID_OUT),
		  .GT1_RXDATA_OUT	(GT1_RXDATA_OUT[31:0]),
		  .GT1_RXELECIDLE_OUT	(GT1_RXELECIDLE_OUT),
		  .GT1_RXHEADERVALID_OUT(GT1_RXHEADERVALID_OUT),
		  .GT1_RXHEADER_OUT	(GT1_RXHEADER_OUT[1:0]),
		  .GT1_RXOUTCLK_OUT	(GT1_RXOUTCLK_OUT),
		  .GT1_RXPRBSERR_OUT	(GT1_RXPRBSERR_OUT),
		  .GT1_RXRESETDONE_OUT	(GT1_RXRESETDONE_OUT),
		  .GT1_TXOUTCLKFABRIC_OUT(GT1_TXOUTCLKFABRIC_OUT),
		  .GT1_TXOUTCLKPCS_OUT	(GT1_TXOUTCLKPCS_OUT),
		  .GT1_TXOUTCLK_OUT	(GT1_TXOUTCLK_OUT),
		  .GT1_TXRESETDONE_OUT	(GT1_TXRESETDONE_OUT),
		  .GT2_DRPDO_OUT	(GT2_DRPDO_OUT[15:0]),
		  .GT2_DRPRDY_OUT	(GT2_DRPRDY_OUT),
		  .GT2_EYESCANDATAERROR_OUT(GT2_EYESCANDATAERROR_OUT),
		  .GT2_RXBUFSTATUS_OUT	(GT2_RXBUFSTATUS_OUT[2:0]),
		  .GT2_RXCDRLOCK_OUT	(GT2_RXCDRLOCK_OUT),
		  .GT2_RXDATAVALID_OUT	(GT2_RXDATAVALID_OUT),
		  .GT2_RXDATA_OUT	(GT2_RXDATA_OUT[31:0]),
		  .GT2_RXELECIDLE_OUT	(GT2_RXELECIDLE_OUT),
		  .GT2_RXHEADERVALID_OUT(GT2_RXHEADERVALID_OUT),
		  .GT2_RXHEADER_OUT	(GT2_RXHEADER_OUT[1:0]),
		  .GT2_RXOUTCLK_OUT	(GT2_RXOUTCLK_OUT),
		  .GT2_RXPRBSERR_OUT	(GT2_RXPRBSERR_OUT),
		  .GT2_RXRESETDONE_OUT	(GT2_RXRESETDONE_OUT),
		  .GT2_TXOUTCLKFABRIC_OUT(GT2_TXOUTCLKFABRIC_OUT),
		  .GT2_TXOUTCLKPCS_OUT	(GT2_TXOUTCLKPCS_OUT),
		  .GT2_TXOUTCLK_OUT	(GT2_TXOUTCLK_OUT),
		  .GT2_TXRESETDONE_OUT	(GT2_TXRESETDONE_OUT),
		  .GT3_DRPDO_OUT	(GT3_DRPDO_OUT[15:0]),
		  .GT3_DRPRDY_OUT	(GT3_DRPRDY_OUT),
		  .GT3_EYESCANDATAERROR_OUT(GT3_EYESCANDATAERROR_OUT),
		  .GT3_RXBUFSTATUS_OUT	(GT3_RXBUFSTATUS_OUT[2:0]),
		  .GT3_RXCDRLOCK_OUT	(GT3_RXCDRLOCK_OUT),
		  .GT3_RXDATAVALID_OUT	(GT3_RXDATAVALID_OUT),
		  .GT3_RXDATA_OUT	(GT3_RXDATA_OUT[31:0]),
		  .GT3_RXELECIDLE_OUT	(GT3_RXELECIDLE_OUT),
		  .GT3_RXHEADERVALID_OUT(GT3_RXHEADERVALID_OUT),
		  .GT3_RXHEADER_OUT	(GT3_RXHEADER_OUT[1:0]),
		  .GT3_RXOUTCLK_OUT	(GT3_RXOUTCLK_OUT),
		  .GT3_RXPRBSERR_OUT	(GT3_RXPRBSERR_OUT),
		  .GT3_RXRESETDONE_OUT	(GT3_RXRESETDONE_OUT),
		  .GT3_TXOUTCLKFABRIC_OUT(GT3_TXOUTCLKFABRIC_OUT),
		  .GT3_TXOUTCLKPCS_OUT	(GT3_TXOUTCLKPCS_OUT),
		  .GT3_TXOUTCLK_OUT	(GT3_TXOUTCLK_OUT),
		  .GT3_TXRESETDONE_OUT	(GT3_TXRESETDONE_OUT),
		  .txn			(txn[3:0]),
		  .txp			(txp[3:0]),
		  .gt0_qplllock_i	(gt0_qplllock_i),
		  // Inputs
		  .GT0_DRPADDR_IN	(GT0_DRPADDR_IN[8:0]),
		  .GT0_DRPCLK_IN	(GT0_DRPCLK_IN),
		  .GT0_DRPDI_IN		(GT0_DRPDI_IN[15:0]),
		  .GT0_DRPEN_IN		(GT0_DRPEN_IN),
		  .GT0_DRPWE_IN		(GT0_DRPWE_IN),
		  .GT0_GTRXRESET_IN	(GT0_GTRXRESET_IN),
		  .GT0_GTTXRESET_IN	(GT0_GTTXRESET_IN),
		  .GT0_LOOPBACK_IN	(GT0_LOOPBACK_IN[2:0]),
		  .GT0_RXBUFRESET_IN	(GT0_RXBUFRESET_IN),
		  .GT0_RXGEARBOXSLIP_IN	(GT0_RXGEARBOXSLIP_IN),
		  .GT0_RXLPMEN_IN	(GT0_RXLPMEN_IN),
		  .GT0_RXPCSRESET_IN	(GT0_RXPCSRESET_IN),
		  .GT0_RXPRBSCNTRESET_IN(GT0_RXPRBSCNTRESET_IN),
		  .GT0_RXPRBSSEL_IN	(GT0_RXPRBSSEL_IN[2:0]),
		  .GT0_RXUSERRDY_IN	(GT0_RXUSERRDY_IN),
		  .GT0_RXUSRCLK2_IN	(GT0_RXUSRCLK2_IN),
		  .GT0_RXUSRCLK_IN	(GT0_RXUSRCLK_IN),
		  .GT0_TXDATA_IN	(GT0_TXDATA_IN[31:0]),
		  .GT0_TXHEADER_IN	(GT0_TXHEADER_IN[1:0]),
		  .GT0_TXINHIBIT_IN	(GT0_TXINHIBIT_IN),
		  .GT0_TXMAINCURSOR_IN	(GT0_TXMAINCURSOR_IN[6:0]),
		  .GT0_TXPCSRESET_IN	(GT0_TXPCSRESET_IN),
		  .GT0_TXPOSTCURSOR_IN	(GT0_TXPOSTCURSOR_IN[4:0]),
		  .GT0_TXPRBSSEL_IN	(GT0_TXPRBSSEL_IN[2:0]),
		  .GT0_TXPRECURSOR_IN	(GT0_TXPRECURSOR_IN[4:0]),
		  .GT0_TXSEQUENCE_IN	(GT0_TXSEQUENCE_IN[6:0]),
		  .GT0_TXUSERRDY_IN	(GT0_TXUSERRDY_IN),
		  .GT0_TXUSRCLK2_IN	(GT0_TXUSRCLK2_IN),
		  .GT0_TXUSRCLK_IN	(GT0_TXUSRCLK_IN),
		  .GT1_DRPADDR_IN	(GT1_DRPADDR_IN[8:0]),
		  .GT1_DRPCLK_IN	(GT1_DRPCLK_IN),
		  .GT1_DRPDI_IN		(GT1_DRPDI_IN[15:0]),
		  .GT1_DRPEN_IN		(GT1_DRPEN_IN),
		  .GT1_DRPWE_IN		(GT1_DRPWE_IN),
		  .GT1_GTRXRESET_IN	(GT1_GTRXRESET_IN),
		  .GT1_GTTXRESET_IN	(GT1_GTTXRESET_IN),
		  .GT1_LOOPBACK_IN	(GT1_LOOPBACK_IN[2:0]),
		  .GT1_RXBUFRESET_IN	(GT1_RXBUFRESET_IN),
		  .GT1_RXGEARBOXSLIP_IN	(GT1_RXGEARBOXSLIP_IN),
		  .GT1_RXLPMEN_IN	(GT1_RXLPMEN_IN),
		  .GT1_RXPCSRESET_IN	(GT1_RXPCSRESET_IN),
		  .GT1_RXPRBSCNTRESET_IN(GT1_RXPRBSCNTRESET_IN),
		  .GT1_RXPRBSSEL_IN	(GT1_RXPRBSSEL_IN[2:0]),
		  .GT1_RXUSERRDY_IN	(GT1_RXUSERRDY_IN),
		  .GT1_RXUSRCLK2_IN	(GT1_RXUSRCLK2_IN),
		  .GT1_RXUSRCLK_IN	(GT1_RXUSRCLK_IN),
		  .GT1_TXDATA_IN	(GT1_TXDATA_IN[31:0]),
		  .GT1_TXHEADER_IN	(GT1_TXHEADER_IN[1:0]),
		  .GT1_TXINHIBIT_IN	(GT1_TXINHIBIT_IN),
		  .GT1_TXMAINCURSOR_IN	(GT1_TXMAINCURSOR_IN[6:0]),
		  .GT1_TXPCSRESET_IN	(GT1_TXPCSRESET_IN),
		  .GT1_TXPOSTCURSOR_IN	(GT1_TXPOSTCURSOR_IN[4:0]),
		  .GT1_TXPRBSSEL_IN	(GT1_TXPRBSSEL_IN[2:0]),
		  .GT1_TXPRECURSOR_IN	(GT1_TXPRECURSOR_IN[4:0]),
		  .GT1_TXSEQUENCE_IN	(GT1_TXSEQUENCE_IN[6:0]),
		  .GT1_TXUSERRDY_IN	(GT1_TXUSERRDY_IN),
		  .GT1_TXUSRCLK2_IN	(GT1_TXUSRCLK2_IN),
		  .GT1_TXUSRCLK_IN	(GT1_TXUSRCLK_IN),
		  .GT2_DRPADDR_IN	(GT2_DRPADDR_IN[8:0]),
		  .GT2_DRPCLK_IN	(GT2_DRPCLK_IN),
		  .GT2_DRPDI_IN		(GT2_DRPDI_IN[15:0]),
		  .GT2_DRPEN_IN		(GT2_DRPEN_IN),
		  .GT2_DRPWE_IN		(GT2_DRPWE_IN),
		  .GT2_GTRXRESET_IN	(GT2_GTRXRESET_IN),
		  .GT2_GTTXRESET_IN	(GT2_GTTXRESET_IN),
		  .GT2_LOOPBACK_IN	(GT2_LOOPBACK_IN[2:0]),
		  .GT2_RXBUFRESET_IN	(GT2_RXBUFRESET_IN),
		  .GT2_RXGEARBOXSLIP_IN	(GT2_RXGEARBOXSLIP_IN),
		  .GT2_RXLPMEN_IN	(GT2_RXLPMEN_IN),
		  .GT2_RXPCSRESET_IN	(GT2_RXPCSRESET_IN),
		  .GT2_RXPRBSCNTRESET_IN(GT2_RXPRBSCNTRESET_IN),
		  .GT2_RXPRBSSEL_IN	(GT2_RXPRBSSEL_IN[2:0]),
		  .GT2_RXUSERRDY_IN	(GT2_RXUSERRDY_IN),
		  .GT2_RXUSRCLK2_IN	(GT2_RXUSRCLK2_IN),
		  .GT2_RXUSRCLK_IN	(GT2_RXUSRCLK_IN),
		  .GT2_TXDATA_IN	(GT2_TXDATA_IN[31:0]),
		  .GT2_TXHEADER_IN	(GT2_TXHEADER_IN[1:0]),
		  .GT2_TXINHIBIT_IN	(GT2_TXINHIBIT_IN),
		  .GT2_TXMAINCURSOR_IN	(GT2_TXMAINCURSOR_IN[6:0]),
		  .GT2_TXPCSRESET_IN	(GT2_TXPCSRESET_IN),
		  .GT2_TXPOSTCURSOR_IN	(GT2_TXPOSTCURSOR_IN[4:0]),
		  .GT2_TXPRBSSEL_IN	(GT2_TXPRBSSEL_IN[2:0]),
		  .GT2_TXPRECURSOR_IN	(GT2_TXPRECURSOR_IN[4:0]),
		  .GT2_TXSEQUENCE_IN	(GT2_TXSEQUENCE_IN[6:0]),
		  .GT2_TXUSERRDY_IN	(GT2_TXUSERRDY_IN),
		  .GT2_TXUSRCLK2_IN	(GT2_TXUSRCLK2_IN),
		  .GT2_TXUSRCLK_IN	(GT2_TXUSRCLK_IN),
		  .GT3_DRPADDR_IN	(GT3_DRPADDR_IN[8:0]),
		  .GT3_DRPCLK_IN	(GT3_DRPCLK_IN),
		  .GT3_DRPDI_IN		(GT3_DRPDI_IN[15:0]),
		  .GT3_DRPEN_IN		(GT3_DRPEN_IN),
		  .GT3_DRPWE_IN		(GT3_DRPWE_IN),
		  .GT3_GTRXRESET_IN	(GT3_GTRXRESET_IN),
		  .GT3_GTTXRESET_IN	(GT3_GTTXRESET_IN),
		  .GT3_LOOPBACK_IN	(GT3_LOOPBACK_IN[2:0]),
		  .GT3_RXBUFRESET_IN	(GT3_RXBUFRESET_IN),
		  .GT3_RXGEARBOXSLIP_IN	(GT3_RXGEARBOXSLIP_IN),
		  .GT3_RXLPMEN_IN	(GT3_RXLPMEN_IN),
		  .GT3_RXPCSRESET_IN	(GT3_RXPCSRESET_IN),
		  .GT3_RXPRBSCNTRESET_IN(GT3_RXPRBSCNTRESET_IN),
		  .GT3_RXPRBSSEL_IN	(GT3_RXPRBSSEL_IN[2:0]),
		  .GT3_RXUSERRDY_IN	(GT3_RXUSERRDY_IN),
		  .GT3_RXUSRCLK2_IN	(GT3_RXUSRCLK2_IN),
		  .GT3_RXUSRCLK_IN	(GT3_RXUSRCLK_IN),
		  .GT3_TXDATA_IN	(GT3_TXDATA_IN[31:0]),
		  .GT3_TXHEADER_IN	(GT3_TXHEADER_IN[1:0]),
		  .GT3_TXINHIBIT_IN	(GT3_TXINHIBIT_IN),
		  .GT3_TXMAINCURSOR_IN	(GT3_TXMAINCURSOR_IN[6:0]),
		  .GT3_TXPCSRESET_IN	(GT3_TXPCSRESET_IN),
		  .GT3_TXPOSTCURSOR_IN	(GT3_TXPOSTCURSOR_IN[4:0]),
		  .GT3_TXPRBSSEL_IN	(GT3_TXPRBSSEL_IN[2:0]),
		  .GT3_TXPRECURSOR_IN	(GT3_TXPRECURSOR_IN[4:0]),
		  .GT3_TXSEQUENCE_IN	(GT3_TXSEQUENCE_IN[6:0]),
		  .GT3_TXUSERRDY_IN	(GT3_TXUSERRDY_IN),
		  .GT3_TXUSRCLK2_IN	(GT3_TXUSRCLK2_IN),
		  .GT3_TXUSRCLK_IN	(GT3_TXUSRCLK_IN),
		  .rxn			(rxn[3:0]),
		  .rxp			(rxp[3:0]),
		  .q1_clk0_refclk_i	(q1_clk0_refclk_i),
		  .GT_QPLLRESET_IN	(GT_QPLLRESET_IN[3:0]));
   
endmodule // xphy_block_quad
// Local Variables:
// verilog-library-directories:("." "gtx")
// verilog-library-files:("")
// verilog-library-extensions:(".v" ".h")
// End:
// 
// xphy_block_quad.v ends here
