`default_nettype wire

`timescale 1ns / 1ps
`define DLY #1

//***************************** Entity Declaration ****************************

module xphy_gt_quad (/*AUTOARG*/
   // Outputs
   txp, txn, GT3_TXRESETDONE_OUT, GT3_TXOUTCLK_OUT,
   GT3_TXOUTCLKPCS_OUT, GT3_TXOUTCLKFABRIC_OUT, GT3_RXRESETDONE_OUT,
   GT3_RXPRBSERR_OUT, GT3_RXOUTCLK_OUT, GT3_RXHEADER_OUT,
   GT3_RXHEADERVALID_OUT, GT3_RXELECIDLE_OUT, GT3_RXDATA_OUT,
   GT3_RXDATAVALID_OUT, GT3_RXCDRLOCK_OUT, GT3_RXBUFSTATUS_OUT,
   GT3_EYESCANDATAERROR_OUT, GT3_DRPRDY_OUT, GT3_DRPDO_OUT,
   GT2_TXRESETDONE_OUT, GT2_TXOUTCLK_OUT, GT2_TXOUTCLKPCS_OUT,
   GT2_TXOUTCLKFABRIC_OUT, GT2_RXRESETDONE_OUT, GT2_RXPRBSERR_OUT,
   GT2_RXOUTCLK_OUT, GT2_RXHEADER_OUT, GT2_RXHEADERVALID_OUT,
   GT2_RXELECIDLE_OUT, GT2_RXDATA_OUT, GT2_RXDATAVALID_OUT,
   GT2_RXCDRLOCK_OUT, GT2_RXBUFSTATUS_OUT, GT2_EYESCANDATAERROR_OUT,
   GT2_DRPRDY_OUT, GT2_DRPDO_OUT, GT1_TXRESETDONE_OUT,
   GT1_TXOUTCLK_OUT, GT1_TXOUTCLKPCS_OUT, GT1_TXOUTCLKFABRIC_OUT,
   GT1_RXRESETDONE_OUT, GT1_RXPRBSERR_OUT, GT1_RXOUTCLK_OUT,
   GT1_RXHEADER_OUT, GT1_RXHEADERVALID_OUT, GT1_RXELECIDLE_OUT,
   GT1_RXDATA_OUT, GT1_RXDATAVALID_OUT, GT1_RXCDRLOCK_OUT,
   GT1_RXBUFSTATUS_OUT, GT1_EYESCANDATAERROR_OUT, GT1_DRPRDY_OUT,
   GT1_DRPDO_OUT, GT0_TXRESETDONE_OUT, GT0_TXOUTCLK_OUT,
   GT0_TXOUTCLKPCS_OUT, GT0_TXOUTCLKFABRIC_OUT, GT0_RXRESETDONE_OUT,
   GT0_RXPRBSERR_OUT, GT0_RXOUTCLK_OUT, GT0_RXHEADER_OUT,
   GT0_RXHEADERVALID_OUT, GT0_RXELECIDLE_OUT, GT0_RXDATA_OUT,
   GT0_RXDATAVALID_OUT, GT0_RXCDRLOCK_OUT, GT0_RXBUFSTATUS_OUT,
   GT0_EYESCANDATAERROR_OUT, GT0_DRPRDY_OUT, GT0_DRPDO_OUT,
   gt0_qplllock_i,
   // Inputs
   rxp, rxn, GT3_TXUSRCLK_IN, GT3_TXUSRCLK2_IN, GT3_TXUSERRDY_IN,
   GT3_TXSEQUENCE_IN, GT3_TXPRECURSOR_IN, GT3_TXPRBSSEL_IN,
   GT3_TXPOSTCURSOR_IN, GT3_TXPCSRESET_IN, GT3_TXMAINCURSOR_IN,
   GT3_TXINHIBIT_IN, GT3_TXHEADER_IN, GT3_TXDATA_IN, GT3_RXUSRCLK_IN,
   GT3_RXUSRCLK2_IN, GT3_RXUSERRDY_IN, GT3_RXPRBSSEL_IN,
   GT3_RXPRBSCNTRESET_IN, GT3_RXPCSRESET_IN, GT3_RXLPMEN_IN,
   GT3_RXGEARBOXSLIP_IN, GT3_RXBUFRESET_IN, GT3_LOOPBACK_IN,
   GT3_GTTXRESET_IN, GT3_GTRXRESET_IN, GT3_DRPWE_IN, GT3_DRPEN_IN,
   GT3_DRPDI_IN, GT3_DRPCLK_IN, GT3_DRPADDR_IN, GT2_TXUSRCLK_IN,
   GT2_TXUSRCLK2_IN, GT2_TXUSERRDY_IN, GT2_TXSEQUENCE_IN,
   GT2_TXPRECURSOR_IN, GT2_TXPRBSSEL_IN, GT2_TXPOSTCURSOR_IN,
   GT2_TXPCSRESET_IN, GT2_TXMAINCURSOR_IN, GT2_TXINHIBIT_IN,
   GT2_TXHEADER_IN, GT2_TXDATA_IN, GT2_RXUSRCLK_IN, GT2_RXUSRCLK2_IN,
   GT2_RXUSERRDY_IN, GT2_RXPRBSSEL_IN, GT2_RXPRBSCNTRESET_IN,
   GT2_RXPCSRESET_IN, GT2_RXLPMEN_IN, GT2_RXGEARBOXSLIP_IN,
   GT2_RXBUFRESET_IN, GT2_LOOPBACK_IN, GT2_GTTXRESET_IN,
   GT2_GTRXRESET_IN, GT2_DRPWE_IN, GT2_DRPEN_IN, GT2_DRPDI_IN,
   GT2_DRPCLK_IN, GT2_DRPADDR_IN, GT1_TXUSRCLK_IN, GT1_TXUSRCLK2_IN,
   GT1_TXUSERRDY_IN, GT1_TXSEQUENCE_IN, GT1_TXPRECURSOR_IN,
   GT1_TXPRBSSEL_IN, GT1_TXPOSTCURSOR_IN, GT1_TXPCSRESET_IN,
   GT1_TXMAINCURSOR_IN, GT1_TXINHIBIT_IN, GT1_TXHEADER_IN,
   GT1_TXDATA_IN, GT1_RXUSRCLK_IN, GT1_RXUSRCLK2_IN, GT1_RXUSERRDY_IN,
   GT1_RXPRBSSEL_IN, GT1_RXPRBSCNTRESET_IN, GT1_RXPCSRESET_IN,
   GT1_RXLPMEN_IN, GT1_RXGEARBOXSLIP_IN, GT1_RXBUFRESET_IN,
   GT1_LOOPBACK_IN, GT1_GTTXRESET_IN, GT1_GTRXRESET_IN, GT1_DRPWE_IN,
   GT1_DRPEN_IN, GT1_DRPDI_IN, GT1_DRPCLK_IN, GT1_DRPADDR_IN,
   GT0_TXUSRCLK_IN, GT0_TXUSRCLK2_IN, GT0_TXUSERRDY_IN,
   GT0_TXSEQUENCE_IN, GT0_TXPRECURSOR_IN, GT0_TXPRBSSEL_IN,
   GT0_TXPOSTCURSOR_IN, GT0_TXPCSRESET_IN, GT0_TXMAINCURSOR_IN,
   GT0_TXINHIBIT_IN, GT0_TXHEADER_IN, GT0_TXDATA_IN, GT0_RXUSRCLK_IN,
   GT0_RXUSRCLK2_IN, GT0_RXUSERRDY_IN, GT0_RXPRBSSEL_IN,
   GT0_RXPRBSCNTRESET_IN, GT0_RXPCSRESET_IN, GT0_RXLPMEN_IN,
   GT0_RXGEARBOXSLIP_IN, GT0_RXBUFRESET_IN, GT0_LOOPBACK_IN,
   GT0_GTTXRESET_IN, GT0_GTRXRESET_IN, GT0_DRPWE_IN, GT0_DRPEN_IN,
   GT0_DRPDI_IN, GT0_DRPCLK_IN, GT0_DRPADDR_IN, q1_clk0_refclk_i,
   GT_QPLLRESET_IN
   );

   // Simulation attributes
   parameter   WRAPPER_SIM_GTRESET_SPEEDUP    =   "false";     // Set to "true" to speed up sim reset
   parameter   RX_DFE_KL_CFG2_IN              =   32'h3010D90C;
   parameter   PMA_RSV_IN                     =   32'h001E7080;
   parameter   SIM_VERSION                    =   "4.0"
   
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		GT0_DRPADDR_IN;		// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_DRPCLK_IN;		// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_DRPDI_IN;		// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_DRPEN_IN;		// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_DRPWE_IN;		// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_GTRXRESET_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_GTTXRESET_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_LOOPBACK_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_RXBUFRESET_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_RXGEARBOXSLIP_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_RXLPMEN_IN;		// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_RXPCSRESET_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_RXPRBSCNTRESET_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_RXPRBSSEL_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_RXUSERRDY_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_RXUSRCLK2_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_RXUSRCLK_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_TXDATA_IN;		// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_TXHEADER_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_TXINHIBIT_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_TXMAINCURSOR_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_TXPCSRESET_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_TXPOSTCURSOR_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_TXPRBSSEL_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_TXPRECURSOR_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_TXSEQUENCE_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_TXUSERRDY_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_TXUSRCLK2_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT0_TXUSRCLK_IN;	// To gt_0 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_DRPADDR_IN;		// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_DRPCLK_IN;		// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_DRPDI_IN;		// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_DRPEN_IN;		// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_DRPWE_IN;		// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_GTRXRESET_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_GTTXRESET_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_LOOPBACK_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_RXBUFRESET_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_RXGEARBOXSLIP_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_RXLPMEN_IN;		// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_RXPCSRESET_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_RXPRBSCNTRESET_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_RXPRBSSEL_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_RXUSERRDY_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_RXUSRCLK2_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_RXUSRCLK_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_TXDATA_IN;		// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_TXHEADER_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_TXINHIBIT_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_TXMAINCURSOR_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_TXPCSRESET_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_TXPOSTCURSOR_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_TXPRBSSEL_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_TXPRECURSOR_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_TXSEQUENCE_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_TXUSERRDY_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_TXUSRCLK2_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT1_TXUSRCLK_IN;	// To gt_1 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_DRPADDR_IN;		// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_DRPCLK_IN;		// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_DRPDI_IN;		// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_DRPEN_IN;		// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_DRPWE_IN;		// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_GTRXRESET_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_GTTXRESET_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_LOOPBACK_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_RXBUFRESET_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_RXGEARBOXSLIP_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_RXLPMEN_IN;		// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_RXPCSRESET_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_RXPRBSCNTRESET_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_RXPRBSSEL_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_RXUSERRDY_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_RXUSRCLK2_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_RXUSRCLK_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_TXDATA_IN;		// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_TXHEADER_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_TXINHIBIT_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_TXMAINCURSOR_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_TXPCSRESET_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_TXPOSTCURSOR_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_TXPRBSSEL_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_TXPRECURSOR_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_TXSEQUENCE_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_TXUSERRDY_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_TXUSRCLK2_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT2_TXUSRCLK_IN;	// To gt_2 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_DRPADDR_IN;		// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_DRPCLK_IN;		// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_DRPDI_IN;		// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_DRPEN_IN;		// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_DRPWE_IN;		// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_GTRXRESET_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_GTTXRESET_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_LOOPBACK_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_RXBUFRESET_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_RXGEARBOXSLIP_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_RXLPMEN_IN;		// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_RXPCSRESET_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_RXPRBSCNTRESET_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_RXPRBSSEL_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_RXUSERRDY_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_RXUSRCLK2_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_RXUSRCLK_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_TXDATA_IN;		// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_TXHEADER_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_TXINHIBIT_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_TXMAINCURSOR_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_TXPCSRESET_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_TXPOSTCURSOR_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_TXPRBSSEL_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_TXPRECURSOR_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_TXSEQUENCE_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_TXUSERRDY_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_TXUSRCLK2_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input		GT3_TXUSRCLK_IN;	// To gt_3 of xphy_gtwizard_10gbaser_gt.v
   input [3:0]		rxn;			// To gt_0 of xphy_gtwizard_10gbaser_gt.v, ...
   input [3:0]		rxp;			// To gt_0 of xphy_gtwizard_10gbaser_gt.v, ...
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		GT0_DRPDO_OUT;		// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_DRPRDY_OUT;		// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_EYESCANDATAERROR_OUT;// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_RXBUFSTATUS_OUT;	// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_RXCDRLOCK_OUT;	// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_RXDATAVALID_OUT;	// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_RXDATA_OUT;		// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_RXELECIDLE_OUT;	// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_RXHEADERVALID_OUT;	// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_RXHEADER_OUT;	// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_RXOUTCLK_OUT;	// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_RXPRBSERR_OUT;	// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_RXRESETDONE_OUT;	// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_TXOUTCLKFABRIC_OUT;	// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_TXOUTCLKPCS_OUT;	// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_TXOUTCLK_OUT;	// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT0_TXRESETDONE_OUT;	// From gt_0 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_DRPDO_OUT;		// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_DRPRDY_OUT;		// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_EYESCANDATAERROR_OUT;// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_RXBUFSTATUS_OUT;	// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_RXCDRLOCK_OUT;	// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_RXDATAVALID_OUT;	// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_RXDATA_OUT;		// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_RXELECIDLE_OUT;	// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_RXHEADERVALID_OUT;	// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_RXHEADER_OUT;	// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_RXOUTCLK_OUT;	// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_RXPRBSERR_OUT;	// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_RXRESETDONE_OUT;	// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_TXOUTCLKFABRIC_OUT;	// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_TXOUTCLKPCS_OUT;	// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_TXOUTCLK_OUT;	// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT1_TXRESETDONE_OUT;	// From gt_1 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_DRPDO_OUT;		// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_DRPRDY_OUT;		// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_EYESCANDATAERROR_OUT;// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_RXBUFSTATUS_OUT;	// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_RXCDRLOCK_OUT;	// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_RXDATAVALID_OUT;	// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_RXDATA_OUT;		// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_RXELECIDLE_OUT;	// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_RXHEADERVALID_OUT;	// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_RXHEADER_OUT;	// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_RXOUTCLK_OUT;	// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_RXPRBSERR_OUT;	// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_RXRESETDONE_OUT;	// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_TXOUTCLKFABRIC_OUT;	// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_TXOUTCLKPCS_OUT;	// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_TXOUTCLK_OUT;	// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT2_TXRESETDONE_OUT;	// From gt_2 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_DRPDO_OUT;		// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_DRPRDY_OUT;		// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_EYESCANDATAERROR_OUT;// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_RXBUFSTATUS_OUT;	// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_RXCDRLOCK_OUT;	// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_RXDATAVALID_OUT;	// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_RXDATA_OUT;		// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_RXELECIDLE_OUT;	// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_RXHEADERVALID_OUT;	// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_RXHEADER_OUT;	// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_RXOUTCLK_OUT;	// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_RXPRBSERR_OUT;	// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_RXRESETDONE_OUT;	// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_TXOUTCLKFABRIC_OUT;	// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_TXOUTCLKPCS_OUT;	// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_TXOUTCLK_OUT;	// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output		GT3_TXRESETDONE_OUT;	// From gt_3 of xphy_gtwizard_10gbaser_gt.v
   output [3:0]		txn;			// From gt_0 of xphy_gtwizard_10gbaser_gt.v, ...
   output [3:0]		txp;			// From gt_0 of xphy_gtwizard_10gbaser_gt.v, ...
   // End of automatics
   
   //***************************** Parameter Declarations ************************
   parameter QPLL_FBDIV_TOP =  66;
   
   parameter QPLL_FBDIV_IN  =  (QPLL_FBDIV_TOP == 16)  ? 10'b0000100000 :
			       (QPLL_FBDIV_TOP == 20)  ? 10'b0000110000 :
			       (QPLL_FBDIV_TOP == 32)  ? 10'b0001100000 :
			       (QPLL_FBDIV_TOP == 40)  ? 10'b0010000000 :
			       (QPLL_FBDIV_TOP == 64)  ? 10'b0011100000 :
			       (QPLL_FBDIV_TOP == 66)  ? 10'b0101000000 :
			       (QPLL_FBDIV_TOP == 80)  ? 10'b0100100000 :
			       (QPLL_FBDIV_TOP == 100) ? 10'b0101110000 : 10'b0000000000;
   
   parameter QPLL_FBDIV_RATIO = (QPLL_FBDIV_TOP == 16)  ? 1'b1 :
				(QPLL_FBDIV_TOP == 20)  ? 1'b1 :
				(QPLL_FBDIV_TOP == 32)  ? 1'b1 :
				(QPLL_FBDIV_TOP == 40)  ? 1'b1 :
				(QPLL_FBDIV_TOP == 64)  ? 1'b1 :
				(QPLL_FBDIV_TOP == 66)  ? 1'b0 :
				(QPLL_FBDIV_TOP == 80)  ? 1'b1 :
				(QPLL_FBDIV_TOP == 100) ? 1'b1 : 1'b1;

   //***************************** Wire Declarations *****************************
   // ground and vcc signals
   wire            tied_to_ground_i;
   wire [63:0] 	   tied_to_ground_vec_i;
   wire            tied_to_vcc_i;
   wire [63:0] 	   tied_to_vcc_vec_i;
   
   //********************************* Main Body of Code**************************
   assign tied_to_ground_i             = 1'b0;
   assign tied_to_ground_vec_i         = 64'h0000000000000000;
   assign tied_to_vcc_i                = 1'b1;
   assign tied_to_vcc_vec_i            = 64'hffffffffffffffff;
   wire   gt_qplloutclk_i;
   wire   gt_qpllrefclk_i;

   /* xphy_gtwizard_10gbaser_gt AUTO_TEMPLATE "_\([0-3]\)" (
    // Simulation attributes
    .GT_SIM_GTRESET_SPEEDUP         (WRAPPER_SIM_GTRESET_SPEEDUP),
    .SIM_VERSION                    (SIM_VERSION),
    .RX_DFE_KL_CFG2_IN              (RX_DFE_KL_CFG2_IN),
    .PCS_RSVD_ATTR_IN               (48'h000000000000),
    .PMA_RSV_IN                     (PMA_RSV_IN),
    //-------------------------------- Channel ---------------------------------
    .QPLLCLK_IN                     (gt_qplloutclk_i),
    .QPLLREFCLK_IN                  (gt_qpllrefclk_i),
    //-------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
    .DRPADDR_IN                     (GT@_DRPADDR_IN),
    .DRPCLK_IN                      (GT@_DRPCLK_IN),
    .DRPDI_IN                       (GT@_DRPDI_IN),
    .DRPDO_OUT                      (GT@_DRPDO_OUT),
    .DRPEN_IN                       (GT@_DRPEN_IN),
    .DRPRDY_OUT                     (GT@_DRPRDY_OUT),
    .DRPWE_IN                       (GT@_DRPWE_IN),
    //----------------------------- Eye Scan Ports -----------------------------
    .EYESCANDATAERROR_OUT           (GT@_EYESCANDATAERROR_OUT),
    //---------------------- Loopback and Powerdown Ports ----------------------
    .LOOPBACK_IN                    (GT@_LOOPBACK_IN),
    //----------------------------- Receive Ports ------------------------------
    .RXUSERRDY_IN                   (GT@_RXUSERRDY_IN),
    //------------ Receive Ports - 64b66b and 64b67b Gearbox Ports -------------
    .RXDATAVALID_OUT                (GT@_RXDATAVALID_OUT),
    .RXGEARBOXSLIP_IN               (GT@_RXGEARBOXSLIP_IN),
    .RXHEADER_OUT                   (GT@_RXHEADER_OUT),
    .RXHEADERVALID_OUT              (GT@_RXHEADERVALID_OUT),
    //--------------------- Receive Ports - PRBS Detection ---------------------
    .RXPRBSCNTRESET_IN              (GT@_RXPRBSCNTRESET_IN),
    .RXPRBSERR_OUT                  (GT@_RXPRBSERR_OUT),
    .RXPRBSSEL_IN                   (GT@_RXPRBSSEL_IN),
    //----------------- Receive Ports - RX Data Path interface -----------------
    .GTRXRESET_IN                   (GT@_GTRXRESET_IN),
    .RXDATA_OUT                     (GT@_RXDATA_OUT),
    .RXOUTCLK_OUT                   (GT@_RXOUTCLK_OUT),
    .RXPCSRESET_IN                  (GT@_RXPCSRESET_IN),
    .RXUSRCLK_IN                    (GT@_RXUSRCLK_IN),
    .RXUSRCLK2_IN                   (GT@_RXUSRCLK2_IN),
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    .GTXRXN_IN                      (rxn[@]),
    .GTXRXP_IN                      (rxp[@]),
    .RXCDRLOCK_OUT                  (GT@_RXCDRLOCK_OUT),
    .RXELECIDLE_OUT                 (GT@_RXELECIDLE_OUT),
    //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    .RXBUFRESET_IN                  (GT@_RXBUFRESET_IN),
    .RXBUFSTATUS_OUT                (GT@_RXBUFSTATUS_OUT),
    //---------------------- Receive Ports - RX Equalizer ----------------------
    .RXLPMEN_IN                     (GT@_RXLPMEN_IN),
    //---------------------- Receive Ports - RX PLL Ports ----------------------
    .RXRESETDONE_OUT                (GT@_RXRESETDONE_OUT),
    //----------------------------- Transmit Ports -----------------------------
    .TXUSERRDY_IN                   (GT@_TXUSERRDY_IN),
    //------------ Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
    .TXHEADER_IN                    (GT@_TXHEADER_IN),
    .TXSEQUENCE_IN                  (GT@_TXSEQUENCE_IN),
    //---------------- Transmit Ports - TX Data Path interface -----------------
    .GTTXRESET_IN                   (GT@_GTTXRESET_IN),
    .TXDATA_IN                      (GT@_TXDATA_IN),
    .TXOUTCLK_OUT                   (GT@_TXOUTCLK_OUT),
    .TXOUTCLKFABRIC_OUT             (GT@_TXOUTCLKFABRIC_OUT),
    .TXOUTCLKPCS_OUT                (GT@_TXOUTCLKPCS_OUT),
    .TXPCSRESET_IN                  (GT@_TXPCSRESET_IN),
    .TXUSRCLK_IN                    (GT@_TXUSRCLK_IN),
    .TXUSRCLK2_IN                   (GT@_TXUSRCLK2_IN),
    //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    .GTXTXN_OUT                     (txn[@]),
    .GTXTXP_OUT                     (txp[@]),
    .TXINHIBIT_IN                   (GT@_TXINHIBIT_IN),
    .TXPRECURSOR_IN                 (GT@_TXPRECURSOR_IN),
    .TXPOSTCURSOR_IN                (GT@_TXPOSTCURSOR_IN),
    .TXMAINCURSOR_IN                (GT@_TXMAINCURSOR_IN),
    //--------------------- Transmit Ports - TX PLL Ports ----------------------
    .TXRESETDONE_OUT                (GT@_TXRESETDONE_OUT),
    //------------------- Transmit Ports - TX PRBS Generator -------------------
    .TXPRBSSEL_IN                   (GT@_TXPRBSSEL_IN),
    );*/
   
   //------------------------- GT Instances  -------------------------------
   xphy_gtwizard_10gbaser_gt #(/*AUTOINSTPARAM*/
			       // Parameters
			       .GT_SIM_GTRESET_SPEEDUP(WRAPPER_SIM_GTRESET_SPEEDUP), // Templated
			       .RX_DFE_KL_CFG2_IN(RX_DFE_KL_CFG2_IN), // Templated
			       .PMA_RSV_IN	(PMA_RSV_IN),	 // Templated
			       .PCS_RSVD_ATTR_IN(48'h000000000000), // Templated
			       .SIM_VERSION	(SIM_VERSION))	 // Templated
   gt_0  (/*AUTOINST*/
	  // Outputs
	  .DRPDO_OUT			(GT0_DRPDO_OUT),	 // Templated
	  .DRPRDY_OUT			(GT0_DRPRDY_OUT),	 // Templated
	  .EYESCANDATAERROR_OUT		(GT0_EYESCANDATAERROR_OUT), // Templated
	  .RXDATAVALID_OUT		(GT0_RXDATAVALID_OUT),	 // Templated
	  .RXHEADER_OUT			(GT0_RXHEADER_OUT),	 // Templated
	  .RXHEADERVALID_OUT		(GT0_RXHEADERVALID_OUT), // Templated
	  .RXPRBSERR_OUT		(GT0_RXPRBSERR_OUT),	 // Templated
	  .RXDATA_OUT			(GT0_RXDATA_OUT),	 // Templated
	  .RXOUTCLK_OUT			(GT0_RXOUTCLK_OUT),	 // Templated
	  .RXCDRLOCK_OUT		(GT0_RXCDRLOCK_OUT),	 // Templated
	  .RXELECIDLE_OUT		(GT0_RXELECIDLE_OUT),	 // Templated
	  .RXBUFSTATUS_OUT		(GT0_RXBUFSTATUS_OUT),	 // Templated
	  .RXRESETDONE_OUT		(GT0_RXRESETDONE_OUT),	 // Templated
	  .TXOUTCLK_OUT			(GT0_TXOUTCLK_OUT),	 // Templated
	  .TXOUTCLKFABRIC_OUT		(GT0_TXOUTCLKFABRIC_OUT), // Templated
	  .TXOUTCLKPCS_OUT		(GT0_TXOUTCLKPCS_OUT),	 // Templated
	  .GTXTXN_OUT			(txn[0]),		 // Templated
	  .GTXTXP_OUT			(txp[0]),		 // Templated
	  .TXRESETDONE_OUT		(GT0_TXRESETDONE_OUT),	 // Templated
	  // Inputs
	  .QPLLCLK_IN			(gt_qplloutclk_i),	 // Templated
	  .QPLLREFCLK_IN		(gt_qpllrefclk_i),	 // Templated
	  .DRPADDR_IN			(GT0_DRPADDR_IN),	 // Templated
	  .DRPCLK_IN			(GT0_DRPCLK_IN),	 // Templated
	  .DRPDI_IN			(GT0_DRPDI_IN),		 // Templated
	  .DRPEN_IN			(GT0_DRPEN_IN),		 // Templated
	  .DRPWE_IN			(GT0_DRPWE_IN),		 // Templated
	  .LOOPBACK_IN			(GT0_LOOPBACK_IN),	 // Templated
	  .RXUSERRDY_IN			(GT0_RXUSERRDY_IN),	 // Templated
	  .RXGEARBOXSLIP_IN		(GT0_RXGEARBOXSLIP_IN),	 // Templated
	  .RXPRBSCNTRESET_IN		(GT0_RXPRBSCNTRESET_IN), // Templated
	  .RXPRBSSEL_IN			(GT0_RXPRBSSEL_IN),	 // Templated
	  .GTRXRESET_IN			(GT0_GTRXRESET_IN),	 // Templated
	  .RXPCSRESET_IN		(GT0_RXPCSRESET_IN),	 // Templated
	  .RXUSRCLK_IN			(GT0_RXUSRCLK_IN),	 // Templated
	  .RXUSRCLK2_IN			(GT0_RXUSRCLK2_IN),	 // Templated
	  .GTXRXN_IN			(rxn[0]),		 // Templated
	  .GTXRXP_IN			(rxp[0]),		 // Templated
	  .RXBUFRESET_IN		(GT0_RXBUFRESET_IN),	 // Templated
	  .RXLPMEN_IN			(GT0_RXLPMEN_IN),	 // Templated
	  .TXUSERRDY_IN			(GT0_TXUSERRDY_IN),	 // Templated
	  .TXHEADER_IN			(GT0_TXHEADER_IN),	 // Templated
	  .TXSEQUENCE_IN		(GT0_TXSEQUENCE_IN),	 // Templated
	  .GTTXRESET_IN			(GT0_GTTXRESET_IN),	 // Templated
	  .TXDATA_IN			(GT0_TXDATA_IN),	 // Templated
	  .TXPCSRESET_IN		(GT0_TXPCSRESET_IN),	 // Templated
	  .TXUSRCLK_IN			(GT0_TXUSRCLK_IN),	 // Templated
	  .TXUSRCLK2_IN			(GT0_TXUSRCLK2_IN),	 // Templated
	  .TXINHIBIT_IN			(GT0_TXINHIBIT_IN),	 // Templated
	  .TXPRECURSOR_IN		(GT0_TXPRECURSOR_IN),	 // Templated
	  .TXPOSTCURSOR_IN		(GT0_TXPOSTCURSOR_IN),	 // Templated
	  .TXMAINCURSOR_IN		(GT0_TXMAINCURSOR_IN),	 // Templated
	  .TXPRBSSEL_IN			(GT0_TXPRBSSEL_IN));	 // Templated
   xphy_gtwizard_10gbaser_gt #(/*AUTOINSTPARAM*/
			       // Parameters
			       .GT_SIM_GTRESET_SPEEDUP(WRAPPER_SIM_GTRESET_SPEEDUP), // Templated
			       .RX_DFE_KL_CFG2_IN(RX_DFE_KL_CFG2_IN), // Templated
			       .PMA_RSV_IN	(PMA_RSV_IN),	 // Templated
			       .PCS_RSVD_ATTR_IN(48'h000000000000), // Templated
			       .SIM_VERSION	(SIM_VERSION))	 // Templated
   gt_1  (/*AUTOINST*/
	  // Outputs
	  .DRPDO_OUT			(GT1_DRPDO_OUT),	 // Templated
	  .DRPRDY_OUT			(GT1_DRPRDY_OUT),	 // Templated
	  .EYESCANDATAERROR_OUT		(GT1_EYESCANDATAERROR_OUT), // Templated
	  .RXDATAVALID_OUT		(GT1_RXDATAVALID_OUT),	 // Templated
	  .RXHEADER_OUT			(GT1_RXHEADER_OUT),	 // Templated
	  .RXHEADERVALID_OUT		(GT1_RXHEADERVALID_OUT), // Templated
	  .RXPRBSERR_OUT		(GT1_RXPRBSERR_OUT),	 // Templated
	  .RXDATA_OUT			(GT1_RXDATA_OUT),	 // Templated
	  .RXOUTCLK_OUT			(GT1_RXOUTCLK_OUT),	 // Templated
	  .RXCDRLOCK_OUT		(GT1_RXCDRLOCK_OUT),	 // Templated
	  .RXELECIDLE_OUT		(GT1_RXELECIDLE_OUT),	 // Templated
	  .RXBUFSTATUS_OUT		(GT1_RXBUFSTATUS_OUT),	 // Templated
	  .RXRESETDONE_OUT		(GT1_RXRESETDONE_OUT),	 // Templated
	  .TXOUTCLK_OUT			(GT1_TXOUTCLK_OUT),	 // Templated
	  .TXOUTCLKFABRIC_OUT		(GT1_TXOUTCLKFABRIC_OUT), // Templated
	  .TXOUTCLKPCS_OUT		(GT1_TXOUTCLKPCS_OUT),	 // Templated
	  .GTXTXN_OUT			(txn[1]),		 // Templated
	  .GTXTXP_OUT			(txp[1]),		 // Templated
	  .TXRESETDONE_OUT		(GT1_TXRESETDONE_OUT),	 // Templated
	  // Inputs
	  .QPLLCLK_IN			(gt_qplloutclk_i),	 // Templated
	  .QPLLREFCLK_IN		(gt_qpllrefclk_i),	 // Templated
	  .DRPADDR_IN			(GT1_DRPADDR_IN),	 // Templated
	  .DRPCLK_IN			(GT1_DRPCLK_IN),	 // Templated
	  .DRPDI_IN			(GT1_DRPDI_IN),		 // Templated
	  .DRPEN_IN			(GT1_DRPEN_IN),		 // Templated
	  .DRPWE_IN			(GT1_DRPWE_IN),		 // Templated
	  .LOOPBACK_IN			(GT1_LOOPBACK_IN),	 // Templated
	  .RXUSERRDY_IN			(GT1_RXUSERRDY_IN),	 // Templated
	  .RXGEARBOXSLIP_IN		(GT1_RXGEARBOXSLIP_IN),	 // Templated
	  .RXPRBSCNTRESET_IN		(GT1_RXPRBSCNTRESET_IN), // Templated
	  .RXPRBSSEL_IN			(GT1_RXPRBSSEL_IN),	 // Templated
	  .GTRXRESET_IN			(GT1_GTRXRESET_IN),	 // Templated
	  .RXPCSRESET_IN		(GT1_RXPCSRESET_IN),	 // Templated
	  .RXUSRCLK_IN			(GT1_RXUSRCLK_IN),	 // Templated
	  .RXUSRCLK2_IN			(GT1_RXUSRCLK2_IN),	 // Templated
	  .GTXRXN_IN			(rxn[1]),		 // Templated
	  .GTXRXP_IN			(rxp[1]),		 // Templated
	  .RXBUFRESET_IN		(GT1_RXBUFRESET_IN),	 // Templated
	  .RXLPMEN_IN			(GT1_RXLPMEN_IN),	 // Templated
	  .TXUSERRDY_IN			(GT1_TXUSERRDY_IN),	 // Templated
	  .TXHEADER_IN			(GT1_TXHEADER_IN),	 // Templated
	  .TXSEQUENCE_IN		(GT1_TXSEQUENCE_IN),	 // Templated
	  .GTTXRESET_IN			(GT1_GTTXRESET_IN),	 // Templated
	  .TXDATA_IN			(GT1_TXDATA_IN),	 // Templated
	  .TXPCSRESET_IN		(GT1_TXPCSRESET_IN),	 // Templated
	  .TXUSRCLK_IN			(GT1_TXUSRCLK_IN),	 // Templated
	  .TXUSRCLK2_IN			(GT1_TXUSRCLK2_IN),	 // Templated
	  .TXINHIBIT_IN			(GT1_TXINHIBIT_IN),	 // Templated
	  .TXPRECURSOR_IN		(GT1_TXPRECURSOR_IN),	 // Templated
	  .TXPOSTCURSOR_IN		(GT1_TXPOSTCURSOR_IN),	 // Templated
	  .TXMAINCURSOR_IN		(GT1_TXMAINCURSOR_IN),	 // Templated
	  .TXPRBSSEL_IN			(GT1_TXPRBSSEL_IN));	 // Templated
   xphy_gtwizard_10gbaser_gt #(/*AUTOINSTPARAM*/
			       // Parameters
			       .GT_SIM_GTRESET_SPEEDUP(WRAPPER_SIM_GTRESET_SPEEDUP), // Templated
			       .RX_DFE_KL_CFG2_IN(RX_DFE_KL_CFG2_IN), // Templated
			       .PMA_RSV_IN	(PMA_RSV_IN),	 // Templated
			       .PCS_RSVD_ATTR_IN(48'h000000000000), // Templated
			       .SIM_VERSION	(SIM_VERSION))	 // Templated
   gt_2  (/*AUTOINST*/
	  // Outputs
	  .DRPDO_OUT			(GT2_DRPDO_OUT),	 // Templated
	  .DRPRDY_OUT			(GT2_DRPRDY_OUT),	 // Templated
	  .EYESCANDATAERROR_OUT		(GT2_EYESCANDATAERROR_OUT), // Templated
	  .RXDATAVALID_OUT		(GT2_RXDATAVALID_OUT),	 // Templated
	  .RXHEADER_OUT			(GT2_RXHEADER_OUT),	 // Templated
	  .RXHEADERVALID_OUT		(GT2_RXHEADERVALID_OUT), // Templated
	  .RXPRBSERR_OUT		(GT2_RXPRBSERR_OUT),	 // Templated
	  .RXDATA_OUT			(GT2_RXDATA_OUT),	 // Templated
	  .RXOUTCLK_OUT			(GT2_RXOUTCLK_OUT),	 // Templated
	  .RXCDRLOCK_OUT		(GT2_RXCDRLOCK_OUT),	 // Templated
	  .RXELECIDLE_OUT		(GT2_RXELECIDLE_OUT),	 // Templated
	  .RXBUFSTATUS_OUT		(GT2_RXBUFSTATUS_OUT),	 // Templated
	  .RXRESETDONE_OUT		(GT2_RXRESETDONE_OUT),	 // Templated
	  .TXOUTCLK_OUT			(GT2_TXOUTCLK_OUT),	 // Templated
	  .TXOUTCLKFABRIC_OUT		(GT2_TXOUTCLKFABRIC_OUT), // Templated
	  .TXOUTCLKPCS_OUT		(GT2_TXOUTCLKPCS_OUT),	 // Templated
	  .GTXTXN_OUT			(txn[2]),		 // Templated
	  .GTXTXP_OUT			(txp[2]),		 // Templated
	  .TXRESETDONE_OUT		(GT2_TXRESETDONE_OUT),	 // Templated
	  // Inputs
	  .QPLLCLK_IN			(gt_qplloutclk_i),	 // Templated
	  .QPLLREFCLK_IN		(gt_qpllrefclk_i),	 // Templated
	  .DRPADDR_IN			(GT2_DRPADDR_IN),	 // Templated
	  .DRPCLK_IN			(GT2_DRPCLK_IN),	 // Templated
	  .DRPDI_IN			(GT2_DRPDI_IN),		 // Templated
	  .DRPEN_IN			(GT2_DRPEN_IN),		 // Templated
	  .DRPWE_IN			(GT2_DRPWE_IN),		 // Templated
	  .LOOPBACK_IN			(GT2_LOOPBACK_IN),	 // Templated
	  .RXUSERRDY_IN			(GT2_RXUSERRDY_IN),	 // Templated
	  .RXGEARBOXSLIP_IN		(GT2_RXGEARBOXSLIP_IN),	 // Templated
	  .RXPRBSCNTRESET_IN		(GT2_RXPRBSCNTRESET_IN), // Templated
	  .RXPRBSSEL_IN			(GT2_RXPRBSSEL_IN),	 // Templated
	  .GTRXRESET_IN			(GT2_GTRXRESET_IN),	 // Templated
	  .RXPCSRESET_IN		(GT2_RXPCSRESET_IN),	 // Templated
	  .RXUSRCLK_IN			(GT2_RXUSRCLK_IN),	 // Templated
	  .RXUSRCLK2_IN			(GT2_RXUSRCLK2_IN),	 // Templated
	  .GTXRXN_IN			(rxn[2]),		 // Templated
	  .GTXRXP_IN			(rxp[2]),		 // Templated
	  .RXBUFRESET_IN		(GT2_RXBUFRESET_IN),	 // Templated
	  .RXLPMEN_IN			(GT2_RXLPMEN_IN),	 // Templated
	  .TXUSERRDY_IN			(GT2_TXUSERRDY_IN),	 // Templated
	  .TXHEADER_IN			(GT2_TXHEADER_IN),	 // Templated
	  .TXSEQUENCE_IN		(GT2_TXSEQUENCE_IN),	 // Templated
	  .GTTXRESET_IN			(GT2_GTTXRESET_IN),	 // Templated
	  .TXDATA_IN			(GT2_TXDATA_IN),	 // Templated
	  .TXPCSRESET_IN		(GT2_TXPCSRESET_IN),	 // Templated
	  .TXUSRCLK_IN			(GT2_TXUSRCLK_IN),	 // Templated
	  .TXUSRCLK2_IN			(GT2_TXUSRCLK2_IN),	 // Templated
	  .TXINHIBIT_IN			(GT2_TXINHIBIT_IN),	 // Templated
	  .TXPRECURSOR_IN		(GT2_TXPRECURSOR_IN),	 // Templated
	  .TXPOSTCURSOR_IN		(GT2_TXPOSTCURSOR_IN),	 // Templated
	  .TXMAINCURSOR_IN		(GT2_TXMAINCURSOR_IN),	 // Templated
	  .TXPRBSSEL_IN			(GT2_TXPRBSSEL_IN));	 // Templated
   xphy_gtwizard_10gbaser_gt #(/*AUTOINSTPARAM*/
			       // Parameters
			       .GT_SIM_GTRESET_SPEEDUP(WRAPPER_SIM_GTRESET_SPEEDUP), // Templated
			       .RX_DFE_KL_CFG2_IN(RX_DFE_KL_CFG2_IN), // Templated
			       .PMA_RSV_IN	(PMA_RSV_IN),	 // Templated
			       .PCS_RSVD_ATTR_IN(48'h000000000000), // Templated
			       .SIM_VERSION	(SIM_VERSION))	 // Templated
   gt_3  (/*AUTOINST*/
	  // Outputs
	  .DRPDO_OUT			(GT3_DRPDO_OUT),	 // Templated
	  .DRPRDY_OUT			(GT3_DRPRDY_OUT),	 // Templated
	  .EYESCANDATAERROR_OUT		(GT3_EYESCANDATAERROR_OUT), // Templated
	  .RXDATAVALID_OUT		(GT3_RXDATAVALID_OUT),	 // Templated
	  .RXHEADER_OUT			(GT3_RXHEADER_OUT),	 // Templated
	  .RXHEADERVALID_OUT		(GT3_RXHEADERVALID_OUT), // Templated
	  .RXPRBSERR_OUT		(GT3_RXPRBSERR_OUT),	 // Templated
	  .RXDATA_OUT			(GT3_RXDATA_OUT),	 // Templated
	  .RXOUTCLK_OUT			(GT3_RXOUTCLK_OUT),	 // Templated
	  .RXCDRLOCK_OUT		(GT3_RXCDRLOCK_OUT),	 // Templated
	  .RXELECIDLE_OUT		(GT3_RXELECIDLE_OUT),	 // Templated
	  .RXBUFSTATUS_OUT		(GT3_RXBUFSTATUS_OUT),	 // Templated
	  .RXRESETDONE_OUT		(GT3_RXRESETDONE_OUT),	 // Templated
	  .TXOUTCLK_OUT			(GT3_TXOUTCLK_OUT),	 // Templated
	  .TXOUTCLKFABRIC_OUT		(GT3_TXOUTCLKFABRIC_OUT), // Templated
	  .TXOUTCLKPCS_OUT		(GT3_TXOUTCLKPCS_OUT),	 // Templated
	  .GTXTXN_OUT			(txn[3]),		 // Templated
	  .GTXTXP_OUT			(txp[3]),		 // Templated
	  .TXRESETDONE_OUT		(GT3_TXRESETDONE_OUT),	 // Templated
	  // Inputs
	  .QPLLCLK_IN			(gt_qplloutclk_i),	 // Templated
	  .QPLLREFCLK_IN		(gt_qpllrefclk_i),	 // Templated
	  .DRPADDR_IN			(GT3_DRPADDR_IN),	 // Templated
	  .DRPCLK_IN			(GT3_DRPCLK_IN),	 // Templated
	  .DRPDI_IN			(GT3_DRPDI_IN),		 // Templated
	  .DRPEN_IN			(GT3_DRPEN_IN),		 // Templated
	  .DRPWE_IN			(GT3_DRPWE_IN),		 // Templated
	  .LOOPBACK_IN			(GT3_LOOPBACK_IN),	 // Templated
	  .RXUSERRDY_IN			(GT3_RXUSERRDY_IN),	 // Templated
	  .RXGEARBOXSLIP_IN		(GT3_RXGEARBOXSLIP_IN),	 // Templated
	  .RXPRBSCNTRESET_IN		(GT3_RXPRBSCNTRESET_IN), // Templated
	  .RXPRBSSEL_IN			(GT3_RXPRBSSEL_IN),	 // Templated
	  .GTRXRESET_IN			(GT3_GTRXRESET_IN),	 // Templated
	  .RXPCSRESET_IN		(GT3_RXPCSRESET_IN),	 // Templated
	  .RXUSRCLK_IN			(GT3_RXUSRCLK_IN),	 // Templated
	  .RXUSRCLK2_IN			(GT3_RXUSRCLK2_IN),	 // Templated
	  .GTXRXN_IN			(rxn[3]),		 // Templated
	  .GTXRXP_IN			(rxp[3]),		 // Templated
	  .RXBUFRESET_IN		(GT3_RXBUFRESET_IN),	 // Templated
	  .RXLPMEN_IN			(GT3_RXLPMEN_IN),	 // Templated
	  .TXUSERRDY_IN			(GT3_TXUSERRDY_IN),	 // Templated
	  .TXHEADER_IN			(GT3_TXHEADER_IN),	 // Templated
	  .TXSEQUENCE_IN		(GT3_TXSEQUENCE_IN),	 // Templated
	  .GTTXRESET_IN			(GT3_GTTXRESET_IN),	 // Templated
	  .TXDATA_IN			(GT3_TXDATA_IN),	 // Templated
	  .TXPCSRESET_IN		(GT3_TXPCSRESET_IN),	 // Templated
	  .TXUSRCLK_IN			(GT3_TXUSRCLK_IN),	 // Templated
	  .TXUSRCLK2_IN			(GT3_TXUSRCLK2_IN),	 // Templated
	  .TXINHIBIT_IN			(GT3_TXINHIBIT_IN),	 // Templated
	  .TXPRECURSOR_IN		(GT3_TXPRECURSOR_IN),	 // Templated
	  .TXPOSTCURSOR_IN		(GT3_TXPOSTCURSOR_IN),	 // Templated
	  .TXMAINCURSOR_IN		(GT3_TXMAINCURSOR_IN),	 // Templated
	  .TXPRBSSEL_IN			(GT3_TXPRBSSEL_IN));	 // Templated

   input  q1_clk0_refclk_i;
   input [3:0] GT_QPLLRESET_IN;
   output      gt0_qplllock_i;
   //_________________________________________________________________________
    //_________________________________________________________________________
    //_________________________GTXE2_COMMON____________________________________

    GTXE2_COMMON #
    (
            // Simulation attributes
            .SIM_RESET_SPEEDUP   (WRAPPER_SIM_GTRESET_SPEEDUP),
            .SIM_QPLLREFCLK_SEL  (3'b001),
            .SIM_VERSION         (SIM_VERSION),


           //----------------COMMON BLOCK Attributes---------------
            .BIAS_CFG                               (64'h0000040000001000),
            .COMMON_CFG                             (32'h00000000),
            .QPLL_CFG                               (27'h0680181),
            .QPLL_CLKOUT_CFG                        (4'b0000),
            .QPLL_COARSE_FREQ_OVRD                  (6'b010000),
            .QPLL_COARSE_FREQ_OVRD_EN               (1'b0),
            .QPLL_CP                                (10'b0000011111),
            .QPLL_CP_MONITOR_EN                     (1'b0),
            .QPLL_DMONITOR_SEL                      (1'b0),
            .QPLL_FBDIV                             (QPLL_FBDIV_IN),
            .QPLL_FBDIV_MONITOR_EN                  (1'b0),
            .QPLL_FBDIV_RATIO                       (QPLL_FBDIV_RATIO),
            .QPLL_INIT_CFG                          (24'h000006),
            .QPLL_LOCK_CFG                          (16'h21E8),
            .QPLL_LPF                               (4'b1111),
            .QPLL_REFCLK_DIV                        (1)

    )
    gtxe2_common_0_i
    (
        //----------- Common Block  - Dynamic Reconfiguration Port (DRP) -----------
        .DRPADDR                        (tied_to_ground_vec_i[7:0]),
        .DRPCLK                         (tied_to_ground_i),
        .DRPDI                          (tied_to_ground_vec_i[15:0]),
        .DRPDO                          (),
        .DRPEN                          (tied_to_ground_i),
        .DRPRDY                         (),
        .DRPWE                          (tied_to_ground_i),
        //-------------------- Common Block  - Ref Clock Ports ---------------------
        .GTGREFCLK                      (tied_to_ground_i),
        .GTNORTHREFCLK0                 (tied_to_ground_i),
        .GTNORTHREFCLK1                 (tied_to_ground_i),
        .GTREFCLK0                      (q1_clk0_refclk_i),
        .GTREFCLK1                      (tied_to_ground_i),
        .GTSOUTHREFCLK0                 (tied_to_ground_i),
        .GTSOUTHREFCLK1                 (tied_to_ground_i),
        //----------------------- Common Block - QPLL Ports ------------------------
        .QPLLDMONITOR                   (),
        .QPLLFBCLKLOST                  (),
        .QPLLLOCK                       (gt0_qplllock_i),
        .QPLLLOCKDETCLK                 (0),
        .QPLLLOCKEN                     (tied_to_vcc_i),
        .QPLLOUTCLK                     (gt_qplloutclk_i),
        .QPLLOUTREFCLK                  (gt_qpllrefclk_i),
        .QPLLOUTRESET                   (tied_to_ground_i),
        .QPLLPD                         (tied_to_ground_i),
        .QPLLREFCLKLOST                 (),
        .QPLLREFCLKSEL                  (3'b001),
        .QPLLRESET                      (GT_QPLLRESET_IN[0]),
        .QPLLRSVD1                      (16'b0000000000000000),
        .QPLLRSVD2                      (5'b11111),
        .REFCLKOUTMONITOR               (),
        //--------------------------- Common Block Ports ---------------------------
        .BGBYPASSB                      (tied_to_vcc_i),
        .BGMONITORENB                   (tied_to_vcc_i),
        .BGPDB                          (tied_to_vcc_i),
        .BGRCALOVRD                     (5'b00000),
        .PMARSVD                        (8'b00000000),
        .RCALENB                        (tied_to_vcc_i)

    );
endmodule
