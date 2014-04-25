// xphy_block_gt.v --- 
// 
// Filename: xphy_block_gt.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Thu Apr 24 10:11:33 2014 (-0700)
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

module xphy_block_gt (/*AUTOARG*/
   // Outputs
   xgmii_rxd, xgmii_rxc, mdio_out, mdio_tri, core_status,
   tx_resetdone, rx_resetdone, tx_disable, sfp_rs, DRPADDR_IN,
   DRPCLK_IN, DRPDI_IN, DRPEN_IN, DRPWE_IN, LOOPBACK_IN, RXUSERRDY_IN,
   RXGEARBOXSLIP_IN, RXPRBSCNTRESET_IN, RXPRBSSEL_IN, GTRXRESET_IN,
   RXPCSRESET_IN, RXUSRCLK_IN, RXUSRCLK2_IN, RXLPMEN_IN,
   RXBUFRESET_IN, TXUSERRDY_IN, TXHEADER_IN, TXSEQUENCE_IN,
   GTTXRESET_IN, TXDATA_IN, TXPCSRESET_IN, TXUSRCLK_IN, TXUSRCLK2_IN,
   TXINHIBIT_IN, TXPRECURSOR_IN, TXPOSTCURSOR_IN, TXMAINCURSOR_IN,
   TXPRBSSEL_IN, QPLLRESET_IN,
   // Inputs
   xgmii_txd, xgmii_txc, mdc, mdio_in, prtad, signal_detect, tx_fault,
   hw_reset, clk156, dclk, mmcm_locked, gt0_qplllock_i, DRPDO_OUT,
   DRPRDY_OUT, EYESCANDATAERROR_OUT, RXDATAVALID_OUT, RXHEADER_OUT,
   RXHEADERVALID_OUT, RXPRBSERR_OUT, RXDATA_OUT, RXOUTCLK_OUT,
   RXCDRLOCK_OUT, RXELECIDLE_OUT, RXBUFSTATUS_OUT, RXRESETDONE_OUT,
   TXOUTCLK_OUT, TXOUTCLKFABRIC_OUT, TXOUTCLKPCS_OUT, TXRESETDONE_OUT,
   q1_clk0_refclk_i, q1_clk0_refclk_i_bufh
   );
   input [63:0] xgmii_txd;
   input [7:0] 	xgmii_txc;
   output [63:0] xgmii_rxd;
   output [7:0]  xgmii_rxc;
   input 	 mdc;
   input 	 mdio_in;
   output 	 mdio_out;
   output 	 mdio_tri;
   input [4 : 0] prtad;
   output [7 : 0] core_status;

   output 	  tx_resetdone;
   output 	  rx_resetdone;
   input 	  signal_detect;
   input 	  tx_fault;
   output 	  tx_disable;
   output 	  sfp_rs;
   assign sfp_rs = 1'b1;
   
   input          hw_reset;
   input          clk156;
   input          dclk;
   input          mmcm_locked;
   input          gt0_qplllock_i;

   /* DRP port */
   output [8:0] DRPADDR_IN;
   output       DRPCLK_IN;
   output [15:0] DRPDI_IN;
   input [15:0] DRPDO_OUT;
   output       DRPEN_IN;
   input        DRPRDY_OUT;
   output       DRPWE_IN;

   wire [15:0] 	  gt0_drpdi_i;
   wire [15:0] 	  gt0_drpaddr_i;
   wire [15:0] 	  gt0_drpdo_i;
   wire           gt0_drpclk_i;
   wire           gt0_drpen_i;
   wire           gt0_drpwe_i;
   wire           gt0_drprdy_i;
   assign DRPADDR_IN  = gt0_drpaddr_i[8:0];
   assign DRPCLK_IN   = gt0_drpclk_i;
   assign DRPDI_IN    = gt0_drpdi_i;
   assign DRPEN_IN    = gt0_drpen_i;
   assign DRPWE_IN    = gt0_drpwe_i;
   assign gt0_drpdo_i = DRPDO_OUT;
   assign gt0_drprdy_i= DRPRDY_OUT;
  
   /* Eye scan port */
   input EYESCANDATAERROR_OUT;

   /* loop and powerdown port */
   output [2:0] LOOPBACK_IN;
   wire [2:0] 	  gt0_loopback_i;
   assign LOOPBACK_IN = gt0_loopback_i;

   /* receive port */
   output RXUSERRDY_IN;
   wire gt0_rxuserrdy_i;
   assign RXUSERRDY_IN = gt0_rxuserrdy_i;
   
   /* receive port - 64b66b */
   input RXDATAVALID_OUT;
   input [1:0] RXHEADER_OUT;
   input RXHEADERVALID_OUT;
   output RXGEARBOXSLIP_IN;
   wire gt0_rxdatavalid_i;
   wire [1:0]  gt0_rxheader_i;
   wire gt0_rxheadervalid_i;
   wire gt0_rxgearboxslip_i;
   assign gt0_rxdatavalid_i   = RXDATAVALID_OUT;
   assign gt0_rxheader_i      = RXHEADER_OUT;
   assign gt0_rxheadervalid_i = RXHEADERVALID_OUT;
   assign RXGEARBOXSLIP_IN = gt0_rxgearboxslip_i;

   /* receive port - PRBS detection */
   output RXPRBSCNTRESET_IN;
   output [2:0] RXPRBSSEL_IN;
   input 	RXPRBSERR_OUT;
   wire   gt0_clear_rx_prbs_err_count_i;
   wire   rx_prbs31_en;
   assign RXPRBSCNTRESET_IN = gt0_clear_rx_prbs_err_count_i;
   assign RXPRBSSEL_IN      = {rx_prbs31_en, 2'b00};

   /* receive port - Rx data path */
   output GTRXRESET_IN;
   input [31:0] RXDATA_OUT;
   input RXOUTCLK_OUT;
   output RXPCSRESET_IN;
   output RXUSRCLK_IN;
   output RXUSRCLK2_IN;
   wire gt0_gtrxreset_i;
   wire [31:0] gt0_rxdata_i;
   wire gt0_rxclkout_bufg;
   wire gt0_rxpcsreset_i;
   wire gt0_rxusrclk2_i;
   wire GTRXRESET_i;
   assign gt0_rxdata_i   = RXDATA_OUT;
   assign GTRXRESET_IN   = gt0_gtrxreset_i;
   assign RXPCSRESET_IN  = gt0_rxpcsreset_i;
   assign RXUSRCLK_IN    = gt0_rxclkout_bufg;
   assign RXUSRCLK2_IN   = gt0_rxclkout_bufg;
   assign gt0_rxusrclk2_i= gt0_rxclkout_bufg;
   BUFG rxoutclk_bufg_i (.I(RXOUTCLK_OUT), .O(gt0_rxclkout_bufg));

   /* Rx */
   input RXCDRLOCK_OUT;
   input RXELECIDLE_OUT;
   output RXLPMEN_IN;
   assign RXLPMEN_IN = 1'b0;

   /* Rx port - Rx elastic buffer and phase alignment */
   output RXBUFRESET_IN;
   input [2:0] RXBUFSTATUS_OUT;
   reg 	       gt0_rxbufreset_i = 1'b0;
   wire [2:0]  gt0_rxbufstatus_i;
   assign RXBUFRESET_IN     = gt0_rxbufreset_i;
   assign gt0_rxbufstatus_i = RXBUFSTATUS_OUT;

   /* Rx port - rx pll */
   input RXRESETDONE_OUT;
   wire  gt0_rxresetdone_i;
   assign gt0_rxresetdone_i = RXRESETDONE_OUT;

   /* Transmit ports */
   output TXUSERRDY_IN;
   wire gt0_txuserrdy_i;
   assign TXUSERRDY_IN = gt0_txuserrdy_i;

   /* Transmit port - 64b66b */
   output [1:0] TXHEADER_IN;
   output [6:0] TXSEQUENCE_IN;
   wire [1:0] gt0_txheader_i;
   wire [6:0] gt0_txsequence_i;
   assign TXHEADER_IN   = gt0_txheader_i;
   assign TXSEQUENCE_IN = gt0_txsequence_i;

   /* Transmit port - data path */
   output GTTXRESET_IN;
   output [31:0] TXDATA_IN;
   input TXOUTCLK_OUT;
   input TXOUTCLKFABRIC_OUT;
   input TXOUTCLKPCS_OUT;
   output TXPCSRESET_IN;
   output TXUSRCLK_IN;
   output TXUSRCLK2_IN;
   wire gt0_gttxreset_i;
   wire [31:0] gt0_txdata_i;
   wire gt0_txoutclk_bufg;
   wire gt0_txpcsreset_i;
   wire gt0_txusrclk2_i;
   wire GTTXRESET_i;
   assign GTTXRESET_IN    = gt0_gttxreset_i;
   assign TXDATA_IN       = gt0_txdata_i;
   assign TXPCSRESET_IN   = gt0_txpcsreset_i;
   assign TXUSRCLK_IN     = gt0_txoutclk_bufg;
   assign TXUSRCLK2_IN    = gt0_txoutclk_bufg;
   assign gt0_txusrclk2_i = gt0_txoutclk_bufg;
   BUFG txoutclk_bufg_i (.I(TXOUTCLK_OUT), .O(gt0_txoutclk_bufg));

   /* Transmit port - TX and oob */
   output TXINHIBIT_IN;
   output [4:0] TXPRECURSOR_IN;
   output [4:0] TXPOSTCURSOR_IN;
   output [6:0] TXMAINCURSOR_IN;
   assign TXINHIBIT_IN    = tx_disable;
   assign TXPRECURSOR_IN  = 0;
   assign TXPOSTCURSOR_IN = 0;
   assign TXMAINCURSOR_IN = 0;

   /* Transmit port - tx pll */
   input TXRESETDONE_OUT;
   wire gt0_txresetdone_i;
   assign gt0_txresetdone_i = TXRESETDONE_OUT;

   /* Transmit port - PRBS */
   output [2:0] TXPRBSSEL_IN;
   wire tx_prbs31_en;
   assign TXPRBSSEL_IN = {tx_prbs31_en, 2'b00};

   wire areset;
   assign areset = hw_reset;
   
   output         QPLLRESET_IN;
   input 	  q1_clk0_refclk_i;
   input 	  q1_clk0_refclk_i_bufh;
 
   ////////////////////////////////////////////////////////////////////
   wire [31:0] 	  gt_txd;
   wire [7:0] 	  gt_txc;
   wire [31:0] 	  gt_rxd;
   wire [7:0] 	  gt_rxc;
  
   reg [31:0] 	  gt_rxd_d1;
   reg [7:0] 	  gt_rxc_d1;  
   
   reg 		  pma_resetout_reg;
   wire 	  pma_resetout_rising;
   reg 		  pcs_resetout_reg;
   wire 	  pcs_resetout_rising;
   
   wire 	  pma_resetout;
   wire 	  pcs_resetout;
   
   reg 		  gt0_rxuserrdy_r = 1'b0;
   reg 		  gt0_txuserrdy_r = 1'b0;
   reg [7:0] 	  reset_counter = 8'h00;
   reg [3:0] 	  reset_pulse;
   
   reg [19:0] 	  rxuserrdy_counter = 20'h0;
   // Nominal wait time of 50000 UI = 757 cyles of 156.25MHz clock
   localparam [19:0] RXRESETTIME_NOM = 20'h002F5; 
   // Maximum wait time of 37x10^6 UI = 560782 cycles of 156.25MHz clock
   localparam [19:0] RXRESETTIME_MAX = 20'h89000;
   
   // Set this according to requirements
   wire [19:0] 	  RXRESETTIME = RXRESETTIME_NOM;
   
   // Aid the detection of a cable/board being pulled
   reg [3:0] 	  rx_sample = 4'b0000; // Used to monitor RX data for a cable pull 
   reg [3:0] 	  rx_sample_prev = 4'b0000; // Used to monitor RX data for a cable pull 
   reg [19:0] 	  cable_pull_watchdog = 20'h20000; // 128K cycles 
   reg [1:0] 	  cable_pull_watchdog_event = 2'b00; // Count events which suggest no cable pull
   reg 		  cable_pull_reset = 1'b0;  // This is set when the watchdog above gets to 0.
   (* ASYNC_REG = "TRUE" *)
   reg 		  cable_pull_reset_reg = 1'b0;  // This is set when the watchdog above gets to 0.
   (* ASYNC_REG = "TRUE" *)
   reg 		  cable_pull_reset_reg_reg = 1'b0;  
   reg 		  cable_pull_reset_rising = 1'b0;  
   reg 		  cable_pull_reset_rising_reg = 1'b0;  
   
   // Aid the detection of a cable/board being plugged back in
   reg 		  cable_unpull_enable = 1'b0;
   reg [19:0] 	  cable_unpull_watchdog = 20'h20000;
   reg [10:0] 	  cable_unpull_watchdog_event = 11'b0;
   reg 		  cable_unpull_reset = 1'b0;
   (* ASYNC_REG = "TRUE" *)
   reg 		  cable_unpull_reset_reg = 1'b0;
   (* ASYNC_REG = "TRUE" *)
   reg 		  cable_unpull_reset_reg_reg = 1'b0;
   reg 		  cable_unpull_reset_rising = 1'b0;
   reg 		  cable_unpull_reset_rising_reg = 1'b0;
   
   wire 	  signal_detect_comb;
   wire 	  cable_is_pulled;
   
   // If no arbitration is required on the GT DRP ports then connect REQ to GNT...
   wire 	  drp_gnt;
   wire 	  drp_req;
   assign drp_gnt = drp_req;
        
   wire txclk322;
   wire rxclk322;
   reg txreset322;
   reg rxreset322;
   reg dclk_reset;
   xphy ten_gig_eth_pcs_pma_core (.reset(hw_reset), 
				  .txreset322(txreset322),
				  .rxreset322(rxreset322),
				  .dclk_reset(dclk_reset),
				  .pma_resetout(pma_resetout),
				  .pcs_resetout(pcs_resetout),
				  .clk156(clk156), 
				  .txusrclk2(txclk322),
				  .rxusrclk2(rxclk322),
				  .dclk(dclk),      
				  .xgmii_txd(xgmii_txd),
				  .xgmii_txc(xgmii_txc),
				  .xgmii_rxd(xgmii_rxd),
				  .xgmii_rxc(xgmii_rxc),
				  .mdc(mdc),
				  .mdio_in(mdio_in),
				  .mdio_out(mdio_out),
				  .mdio_tri(mdio_tri),
				  .prtad(prtad),
				  .core_status(core_status), 
				  .pma_pmd_type(3'b101),
				  .drp_req(drp_req),
				  .drp_gnt(drp_gnt),                            
				  .drp_den(gt0_drpen_i),                                   
				  .drp_dwe(gt0_drpwe_i),
				  .drp_daddr(gt0_drpaddr_i),                 
				  .drp_di(gt0_drpdi_i),                  
				  .drp_drdy(gt0_drprdy_i),               
				  .drp_drpdo(gt0_drpdo_i),
				  .resetdone(resetdone),
				  .gt_txd(gt_txd),
				  .gt_txc(gt_txc),
				  .gt_rxd(gt_rxd_d1),
				  .gt_rxc(gt_rxc_d1),
				  .gt_slip(gt0_rxgearboxslip_i),
				  .signal_detect(signal_detect_comb),
				  .tx_fault(tx_fault),
				  .tx_disable(tx_disable),
				  .tx_prbs31_en(tx_prbs31_en),
				  .rx_prbs31_en(rx_prbs31_en),
				  .clear_rx_prbs_err_count(gt0_clear_rx_prbs_err_count_i),
				  .loopback_ctrl(gt0_loopback_i));
   
  
   assign txclk322 = gt0_txusrclk2_i;
   assign rxclk322 = gt0_rxusrclk2_i;
   assign gt0_drpclk_i = dclk;
   
   
   (* ASYNC_REG = "TRUE" *)
   reg 		  gt0_txresetdone_i_rega = 1'b0;
   (* ASYNC_REG = "TRUE" *)
   reg 		  gt0_txresetdone_i_reg = 1'b0;
   (* ASYNC_REG = "TRUE" *)
   reg 		  gt0_rxresetdone_i_rega = 1'b0;
   (* ASYNC_REG = "TRUE" *)
   reg 		  gt0_rxresetdone_i_reg = 1'b0;
   
   reg 		  gt0_rxresetdone_i_regrx322 = 1'b0;
   
   always @(posedge clk156)
     begin
	if(mmcm_locked == 1'b1) begin
	   gt0_txresetdone_i_rega <= gt0_txresetdone_i;
	   gt0_txresetdone_i_reg <= gt0_txresetdone_i_rega;
	   gt0_rxresetdone_i_rega <= gt0_rxresetdone_i;
	   gt0_rxresetdone_i_reg <= gt0_rxresetdone_i_rega;
	end
     end
   
   assign resetdone = gt0_txresetdone_i_reg && gt0_rxresetdone_i_reg;
   assign tx_resetdone = gt0_txresetdone_i_reg && mmcm_locked;
   assign rx_resetdone = gt0_rxresetdone_i_reg && mmcm_locked;
   
   
   assign gt0_txdata_i[0 ] = gt_txd[31];
   assign gt0_txdata_i[1 ] = gt_txd[30];
   assign gt0_txdata_i[2 ] = gt_txd[29];
   assign gt0_txdata_i[3 ] = gt_txd[28];
   assign gt0_txdata_i[4 ] = gt_txd[27];
   assign gt0_txdata_i[5 ] = gt_txd[26];
   assign gt0_txdata_i[6 ] = gt_txd[25];
   assign gt0_txdata_i[7 ] = gt_txd[24];
   assign gt0_txdata_i[8 ] = gt_txd[23];
   assign gt0_txdata_i[9 ] = gt_txd[22];
   assign gt0_txdata_i[10] = gt_txd[21];
   assign gt0_txdata_i[11] = gt_txd[20];
   assign gt0_txdata_i[12] = gt_txd[19];
   assign gt0_txdata_i[13] = gt_txd[18];
   assign gt0_txdata_i[14] = gt_txd[17];
   assign gt0_txdata_i[15] = gt_txd[16];
   assign gt0_txdata_i[16] = gt_txd[15];
   assign gt0_txdata_i[17] = gt_txd[14];
   assign gt0_txdata_i[18] = gt_txd[13];
   assign gt0_txdata_i[19] = gt_txd[12];
   assign gt0_txdata_i[20] = gt_txd[11];
   assign gt0_txdata_i[21] = gt_txd[10];
   assign gt0_txdata_i[22] = gt_txd[9 ];
   assign gt0_txdata_i[23] = gt_txd[8 ];
   assign gt0_txdata_i[24] = gt_txd[7 ];
   assign gt0_txdata_i[25] = gt_txd[6 ];
   assign gt0_txdata_i[26] = gt_txd[5 ];
   assign gt0_txdata_i[27] = gt_txd[4 ];
   assign gt0_txdata_i[28] = gt_txd[3 ];
   assign gt0_txdata_i[29] = gt_txd[2 ];
   assign gt0_txdata_i[30] = gt_txd[1 ];
   assign gt0_txdata_i[31] = gt_txd[0 ];
   assign gt0_txheader_i[0] = gt_txc[1];
   assign gt0_txheader_i[1] = gt_txc[0];
   assign gt0_txsequence_i = {1'b0, gt_txc[7:2]};
   
   
   assign gt_rxd[0 ] = gt0_rxdata_i[31];
   assign gt_rxd[1 ] = gt0_rxdata_i[30];
   assign gt_rxd[2 ] = gt0_rxdata_i[29];
   assign gt_rxd[3 ] = gt0_rxdata_i[28];
   assign gt_rxd[4 ] = gt0_rxdata_i[27];
   assign gt_rxd[5 ] = gt0_rxdata_i[26];
   assign gt_rxd[6 ] = gt0_rxdata_i[25];
   assign gt_rxd[7 ] = gt0_rxdata_i[24];
   assign gt_rxd[8 ] = gt0_rxdata_i[23];
   assign gt_rxd[9 ] = gt0_rxdata_i[22];
   assign gt_rxd[10] = gt0_rxdata_i[21];
   assign gt_rxd[11] = gt0_rxdata_i[20];
   assign gt_rxd[12] = gt0_rxdata_i[19];
   assign gt_rxd[13] = gt0_rxdata_i[18];
   assign gt_rxd[14] = gt0_rxdata_i[17];
   assign gt_rxd[15] = gt0_rxdata_i[16];
   assign gt_rxd[16] = gt0_rxdata_i[15];
   assign gt_rxd[17] = gt0_rxdata_i[14];
   assign gt_rxd[18] = gt0_rxdata_i[13];
   assign gt_rxd[19] = gt0_rxdata_i[12];
   assign gt_rxd[20] = gt0_rxdata_i[11];
   assign gt_rxd[21] = gt0_rxdata_i[10];
   assign gt_rxd[22] = gt0_rxdata_i[9 ];
   assign gt_rxd[23] = gt0_rxdata_i[8 ];
   assign gt_rxd[24] = gt0_rxdata_i[7 ];
   assign gt_rxd[25] = gt0_rxdata_i[6 ];
   assign gt_rxd[26] = gt0_rxdata_i[5 ];
   assign gt_rxd[27] = gt0_rxdata_i[4 ];
   assign gt_rxd[28] = gt0_rxdata_i[3 ];
   assign gt_rxd[29] = gt0_rxdata_i[2 ];
   assign gt_rxd[30] = gt0_rxdata_i[1 ];
   assign gt_rxd[31] = gt0_rxdata_i[0 ];
   assign gt_rxc = {4'b0000, gt0_rxheadervalid_i,gt0_rxdatavalid_i, gt0_rxheader_i[0], gt0_rxheader_i[1]};
   
   always @(posedge rxclk322) begin
      gt_rxc_d1 <= gt_rxc;
      gt_rxd_d1 <= gt_rxd;
      gt0_rxresetdone_i_regrx322 <= gt0_rxresetdone_i;
   end
   
   // Asynch reset synchronizer registers
   (* ASYNC_REG = "TRUE" *)
   reg areset_q1_clk0_refclk_i_bufh_tmp;
   (* ASYNC_REG = "TRUE" *)
   reg areset_q1_clk0_refclk_i_bufh;
   (* ASYNC_REG = "TRUE" *)
   reg areset_gt0_rxusrclk2_i_tmp;
   (* ASYNC_REG = "TRUE" *)
   reg areset_gt0_rxusrclk2_i;
   (* ASYNC_REG = "TRUE" *)
   reg areset_clk156_tmp;
   (* ASYNC_REG = "TRUE" *)
   reg areset_clk156;
   (* ASYNC_REG = "TRUE" *)
   reg cable_pull_reset_rising_gt0_rxusrclk2_i_tmp;
   (* ASYNC_REG = "TRUE" *)
   reg cable_pull_reset_rising_gt0_rxusrclk2_i;
   (* ASYNC_REG = "TRUE" *)
   reg cable_unpull_reset_rising_gt0_rxusrclk2_i_tmp;
   (* ASYNC_REG = "TRUE" *)
   reg cable_unpull_reset_rising_gt0_rxusrclk2_i;
   (* ASYNC_REG = "TRUE" *)
   reg pma_resetout_rising_gt0_rxusrclk2_i_tmp;
   (* ASYNC_REG = "TRUE" *)
   reg pma_resetout_rising_gt0_rxusrclk2_i;
   (* ASYNC_REG = "TRUE" *)
   reg gt0_qplllock_i_gt0_rxusrclk2_i_tmp;
   (* ASYNC_REG = "TRUE" *)
   reg gt0_qplllock_i_gt0_rxusrclk2_i;
   (* ASYNC_REG = "TRUE" *)
   reg gt0_qplllock_i_gt0_txusrclk2_i_tmp;
   (* ASYNC_REG = "TRUE" *)
   reg gt0_qplllock_i_gt0_txusrclk2_i;
   (* ASYNC_REG = "TRUE" *)
   reg mmcm_locked_clk156_tmp;
   (* ASYNC_REG = "TRUE" *)
   reg mmcm_locked_clk156;
   (* ASYNC_REG = "TRUE" *)
   reg gt0_gtrxreset_i_gt0_rxusrclk2_i_tmp;
   (* ASYNC_REG = "TRUE" *)
   reg gt0_gtrxreset_i_gt0_rxusrclk2_i;
   (* ASYNC_REG = "TRUE" *)
   reg gt0_gttxreset_i_gt0_txusrclk2_i_tmp;
   (* ASYNC_REG = "TRUE" *)
   reg gt0_gttxreset_i_gt0_txusrclk2_i;
   
   // Asynch reset synchronizers
   always @(posedge areset or posedge q1_clk0_refclk_i_bufh)
     begin
	if(areset)
	  begin
	     areset_q1_clk0_refclk_i_bufh_tmp <= 1'b1;
	     areset_q1_clk0_refclk_i_bufh <= 1'b1;
	  end
	else
	  begin
	     areset_q1_clk0_refclk_i_bufh_tmp <= 1'b0;
	     areset_q1_clk0_refclk_i_bufh <= areset_q1_clk0_refclk_i_bufh_tmp;
	  end
     end  
   
   always @(posedge areset or posedge gt0_rxusrclk2_i)
     begin
	if(areset)
	  begin
	     areset_gt0_rxusrclk2_i_tmp <= 1'b1;
	     areset_gt0_rxusrclk2_i <= 1'b1;
	  end
	else
	  begin
	     areset_gt0_rxusrclk2_i_tmp <= 1'b0;
	     areset_gt0_rxusrclk2_i <= areset_gt0_rxusrclk2_i_tmp;
	  end
     end  
   
   always @(posedge areset or posedge clk156)
     begin
	if(areset)
	  begin
	     areset_clk156_tmp <= 1'b1;
	     areset_clk156 <= 1'b1;
	  end
	else
	  begin
	     areset_clk156_tmp <= 1'b0;
	     areset_clk156 <= areset_clk156_tmp;
	  end
     end  
   
   always @(posedge cable_pull_reset_rising or posedge gt0_rxusrclk2_i)
     begin
	if(cable_pull_reset_rising)
	  begin
	     cable_pull_reset_rising_gt0_rxusrclk2_i_tmp <= 1'b1;
	     cable_pull_reset_rising_gt0_rxusrclk2_i <= 1'b1;
	  end
	else
	  begin
	     cable_pull_reset_rising_gt0_rxusrclk2_i_tmp <= 1'b0;
	     cable_pull_reset_rising_gt0_rxusrclk2_i <= cable_pull_reset_rising_gt0_rxusrclk2_i_tmp;
	  end
     end  
   
   always @(posedge cable_unpull_reset_rising or posedge gt0_rxusrclk2_i)
     begin
	if(cable_unpull_reset_rising)
	  begin
	     cable_unpull_reset_rising_gt0_rxusrclk2_i_tmp <= 1'b1;
	     cable_unpull_reset_rising_gt0_rxusrclk2_i <= 1'b1;
	  end
	else
	  begin
	     cable_unpull_reset_rising_gt0_rxusrclk2_i_tmp <= 1'b0;
	     cable_unpull_reset_rising_gt0_rxusrclk2_i <= cable_unpull_reset_rising_gt0_rxusrclk2_i_tmp;
	  end
     end  
   
   always @(posedge pma_resetout_rising or posedge gt0_rxusrclk2_i)
     begin
	if(pma_resetout_rising)
	  begin
	     pma_resetout_rising_gt0_rxusrclk2_i_tmp <= 1'b1;
	     pma_resetout_rising_gt0_rxusrclk2_i <= 1'b1;
	  end
	else
	  begin
	     pma_resetout_rising_gt0_rxusrclk2_i_tmp <= 1'b0;
	     pma_resetout_rising_gt0_rxusrclk2_i <= pma_resetout_rising_gt0_rxusrclk2_i_tmp;
	  end
     end  
   
   always @(negedge gt0_qplllock_i or posedge gt0_rxusrclk2_i)
     begin
	if(!gt0_qplllock_i)
	  begin
	     gt0_qplllock_i_gt0_rxusrclk2_i_tmp <= 1'b0;
	     gt0_qplllock_i_gt0_rxusrclk2_i <= 1'b0;
	  end
	else
	  begin
	     gt0_qplllock_i_gt0_rxusrclk2_i_tmp <= 1'b1;
	     gt0_qplllock_i_gt0_rxusrclk2_i <= gt0_qplllock_i_gt0_rxusrclk2_i_tmp;
	  end
     end  
   
   always @(negedge gt0_qplllock_i or posedge gt0_txusrclk2_i)
     begin
	if(!gt0_qplllock_i)
	  begin
	     gt0_qplllock_i_gt0_txusrclk2_i_tmp <= 1'b0;
	     gt0_qplllock_i_gt0_txusrclk2_i <= 1'b0;
	  end
	else
	  begin
	     gt0_qplllock_i_gt0_txusrclk2_i_tmp <= 1'b1;
	     gt0_qplllock_i_gt0_txusrclk2_i <= gt0_qplllock_i_gt0_txusrclk2_i_tmp;
	  end
     end  
   
   always @(negedge mmcm_locked or posedge clk156)
     begin
	if(!mmcm_locked)
	  begin
	     mmcm_locked_clk156_tmp <= 1'b0;
	     mmcm_locked_clk156 <= 1'b0;
	  end
	else
	  begin
	     mmcm_locked_clk156_tmp <= 1'b1;
	     mmcm_locked_clk156 <= mmcm_locked_clk156_tmp;
	  end
     end       
   
   always @(posedge gt0_gtrxreset_i or posedge gt0_rxusrclk2_i)
     begin
	if(gt0_gtrxreset_i)
	  begin
	     gt0_gtrxreset_i_gt0_rxusrclk2_i_tmp <= 1'b1;
	     gt0_gtrxreset_i_gt0_rxusrclk2_i <= 1'b1;
	  end
	else
	  begin
	     gt0_gtrxreset_i_gt0_rxusrclk2_i_tmp <= 1'b0;
	     gt0_gtrxreset_i_gt0_rxusrclk2_i <= gt0_gtrxreset_i_gt0_rxusrclk2_i_tmp;
	  end
     end  
   
   always @(posedge gt0_gttxreset_i or posedge gt0_txusrclk2_i)
     begin
	if(gt0_gttxreset_i)
	  begin
	     gt0_gttxreset_i_gt0_txusrclk2_i_tmp <= 1'b1;
	     gt0_gttxreset_i_gt0_txusrclk2_i <= 1'b1;
	  end
	else
	  begin
	     gt0_gttxreset_i_gt0_txusrclk2_i_tmp <= 1'b0;
	     gt0_gttxreset_i_gt0_txusrclk2_i <= gt0_gttxreset_i_gt0_txusrclk2_i_tmp;
	  end
     end  
   
   // Reset logic from the gtwizard top level output file....
   // Adapt the reset_counter to count clk156 ticks.
   // 128 ticks at 6.4ns period will be >> 500 ns.
   // Removed all 'after DLY' text.
   
   always @(posedge q1_clk0_refclk_i_bufh or posedge areset_q1_clk0_refclk_i_bufh)
     begin
	if (areset_q1_clk0_refclk_i_bufh == 1'b1)
	  reset_counter <= 8'b0;
	else if (!reset_counter[7])
	  reset_counter   <=   reset_counter + 1'b1;   
	else
	  reset_counter   <=   reset_counter;
     end
   
   always @(posedge q1_clk0_refclk_i_bufh)
     begin
	if(!reset_counter[7])
	  reset_pulse   <=   4'b1110;
	else
	  reset_pulse   <=   {1'b0, reset_pulse[3:1]};
     end
   
   // Delay the assertion of RXUSERRDY by the given amount
   always @(posedge gt0_rxusrclk2_i or posedge gt0_gtrxreset_i_gt0_rxusrclk2_i or negedge gt0_qplllock_i_gt0_rxusrclk2_i)
     begin
	if(!gt0_qplllock_i_gt0_rxusrclk2_i || gt0_gtrxreset_i_gt0_rxusrclk2_i)
	  rxuserrdy_counter <= 20'h0;
	else if (!(rxuserrdy_counter == RXRESETTIME))
          rxuserrdy_counter   <=   rxuserrdy_counter + 1'b1;       
	else
          rxuserrdy_counter   <=   rxuserrdy_counter;
     end
   
   assign   GTTXRESET_i   =     reset_pulse[0];
   assign   GTRXRESET_i   =     reset_pulse[0];
   
   assign   QPLLRESET_IN  =     reset_pulse[0];
   
   assign gt0_rxuserrdy_i = gt0_rxuserrdy_r;
   assign gt0_txuserrdy_i = gt0_txuserrdy_r;
   
   always @(posedge gt0_rxusrclk2_i or posedge gt0_gtrxreset_i_gt0_rxusrclk2_i)
     begin
	if(gt0_gtrxreset_i_gt0_rxusrclk2_i)
	  gt0_rxuserrdy_r <= 1'b0;
	else if(rxuserrdy_counter == RXRESETTIME)
	  gt0_rxuserrdy_r <= 1'b1;
	else
	  gt0_rxuserrdy_r <= gt0_rxuserrdy_r;
     end
   
   always @(posedge gt0_txusrclk2_i or posedge gt0_gttxreset_i_gt0_txusrclk2_i)
     begin
	if(gt0_gttxreset_i_gt0_txusrclk2_i)
	  gt0_txuserrdy_r <= 1'b0;
	else
	  gt0_txuserrdy_r <= gt0_qplllock_i_gt0_txusrclk2_i;
     end
   
   // Create a watchdog which samples 4 bits from the gt_rxd vector and checks that it does
   // vary from a 1010 or 0101 or 0000 pattern. If not then there may well have been a cable pull
   // and the gt rx side needs to be reset.
   always @(posedge gt0_rxusrclk2_i or posedge cable_pull_reset_rising_gt0_rxusrclk2_i)
     begin
	if(cable_pull_reset_rising_gt0_rxusrclk2_i)
	  begin
	     cable_pull_watchdog_event <= 2'b00;
	     cable_pull_watchdog <= 20'h20000; // reset the watchdog
	     cable_pull_reset <= 1'b0; 
	     rx_sample <= 4'b0;
	     rx_sample_prev <= 4'b0;
	  end
	else
	  begin
	     // Sample 4 bits of the gt_rxd vector
	     rx_sample <= gt_rxd[7:4];
	     rx_sample_prev <= rx_sample;
	     
	     if(!cable_pull_reset && !cable_is_pulled && gt0_rxresetdone_i_regrx322)
	       begin
		  // If those 4 bits do not look like the cable-pull behaviour, increment the event counter
		  if(!(rx_sample == 4'b1010) && !(rx_sample == 4'b0101) && !(rx_sample == 4'b0000) && !(rx_sample == rx_sample_prev))  // increment the event counter
		    cable_pull_watchdog_event <= cable_pull_watchdog_event + 1;
		  else // we are seeing what may be a cable pull
		    cable_pull_watchdog_event <= 2'b00;
		  if (cable_pull_watchdog_event == 2'b10) // Two consecutive events which look like the cable is attached
		    begin
		       cable_pull_watchdog <= 20'h20000; // reset the watchdog
		       cable_pull_watchdog_event <= 2'b00;
		    end
		  else
		    cable_pull_watchdog <= cable_pull_watchdog - 1;
		  if(~|cable_pull_watchdog) 
		    cable_pull_reset <= 1'b1; // Hit GTRXRESET! 
		  else
		    cable_pull_reset <= 1'b0;
	       end
	  end
     end 
   
   always @(posedge clk156)
     begin
	if(mmcm_locked == 1'b1) begin
	   cable_pull_reset_reg <= cable_pull_reset;
	   cable_pull_reset_reg_reg <= cable_pull_reset_reg;
	   cable_pull_reset_rising <= cable_pull_reset_reg && !cable_pull_reset_reg_reg;  
	   cable_pull_reset_rising_reg <= cable_pull_reset_rising;  
	end
     end
   
   always @(posedge gt0_rxusrclk2_i or posedge areset_gt0_rxusrclk2_i or posedge pma_resetout_rising_gt0_rxusrclk2_i)
     begin
	if(areset_gt0_rxusrclk2_i || pma_resetout_rising_gt0_rxusrclk2_i)
	  cable_unpull_enable <= 1'b0;
	else if(cable_pull_reset) // Cable pull has been detected - enable cable unpull counter
	  cable_unpull_enable <= 1'b1;
	else if(cable_unpull_reset) // Cable has been detected as being plugged in again
	  cable_unpull_enable <= 1'b0;
	else
	  cable_unpull_enable <= cable_unpull_enable;
     end
   
   // Look for data on the line which does NOT look like the cable is still pulled
   // a set of 1024 non-1010 or 0101 or 0000 samples within 128k samples suggests that the cable is in.
   always @(posedge gt0_rxusrclk2_i or posedge cable_unpull_reset_rising_gt0_rxusrclk2_i)
     begin
	if(cable_unpull_reset_rising_gt0_rxusrclk2_i)
	  begin
	     cable_unpull_reset <= 1'b0; 
	     cable_unpull_watchdog_event <= 11'b0; // reset the event counter
	     cable_unpull_watchdog <= 20'h20000; // reset the watchdog window
	  end
	else
	  begin
	     if(!cable_unpull_reset && cable_is_pulled && gt0_rxresetdone_i_regrx322)
	       begin
		  // If those 4 bits do not look like the cable-pull behaviour, increment the event counter
		  if(!(rx_sample == 4'b1010) && !(rx_sample == 4'b0101) && !(rx_sample == 4'b0000) && !(rx_sample == rx_sample_prev))  // increment the event counter
		    cable_unpull_watchdog_event <= cable_unpull_watchdog_event + 1;
		  if (cable_unpull_watchdog_event[10] == 1'b1) // Detected 1k 'valid' rx data words within 128k words
		    begin
		       cable_unpull_reset <= 1'b1; // Hit GTRXRESET again!
		       cable_unpull_watchdog <= 20'h20000; // reset the watchdog window
		    end
		  else
		    cable_unpull_watchdog <= cable_unpull_watchdog - 1;    
		  if (~|cable_unpull_watchdog) 
		    begin 
		       cable_unpull_watchdog <= 20'h20000; // reset the watchdog window
		       cable_unpull_watchdog_event <= 11'b0; // reset the event counter
		    end
	       end
	  end
     end 
   
   always @(posedge clk156)
     begin
	if(mmcm_locked == 1'b1) begin
	   cable_unpull_reset_reg <= cable_unpull_reset;
	   cable_unpull_reset_reg_reg <= cable_unpull_reset_reg;
	   cable_unpull_reset_rising <= cable_unpull_reset_reg && !cable_unpull_reset_reg_reg;  
	   cable_unpull_reset_rising_reg <= cable_unpull_reset_rising;  
	end
     end
   
   // Create the local cable_is_pulled signal
   assign cable_is_pulled = cable_unpull_enable;
   
   // Create the signal_detect signal as an AND of the external signal and (not) the local cable_is_pulled
   assign signal_detect_comb = signal_detect && !cable_is_pulled;
   
   always @(posedge areset_clk156 or posedge clk156 or negedge mmcm_locked_clk156)
     begin
	if(areset_clk156 || !mmcm_locked_clk156)
	  pma_resetout_reg <= 1'b0;
	else
	  pma_resetout_reg <= pma_resetout;
     end
   
   assign pma_resetout_rising = pma_resetout && !pma_resetout_reg;
   
   always @(posedge areset_clk156 or posedge clk156 or negedge mmcm_locked_clk156)
     begin
	if(areset_clk156 || !mmcm_locked_clk156)
	  pcs_resetout_reg <= 1'b0;
	else
	  pcs_resetout_reg <= pcs_resetout;
     end
   
   assign pcs_resetout_rising = pcs_resetout && !pcs_resetout_reg;
   
   // Incorporate the pma_resetout_rising and cable_pull/unpull_reset_rising bits generated in code below.
   assign  gt0_gtrxreset_i = (GTRXRESET_i || !gt0_qplllock_i || pma_resetout_rising ||
                              cable_pull_reset_rising_reg || cable_unpull_reset_rising_reg) && reset_counter[7];
   assign  gt0_gttxreset_i = (GTTXRESET_i || !gt0_qplllock_i || pma_resetout_rising) && reset_counter[7];
   assign  gt0_qpllreset_i = QPLLRESET_IN;
   
   assign  gt0_rxpcsreset_i = pcs_resetout_rising;
   assign  gt0_txpcsreset_i = pcs_resetout_rising;
   
   // reset the GT RX Buffer when over/underflowing
   always @(posedge gt0_rxusrclk2_i)
     begin
	if(gt0_rxbufstatus_i[2] == 1'b1 && gt0_rxresetdone_i_regrx322)
	  gt0_rxbufreset_i <= 1'b1;
	else
	  gt0_rxbufreset_i <= 1'b0;
     end   

   // txreset322, rxreset322, dclk_reset
   reg 	  core_reset_tx_tmp;
   reg 	  core_reset_tx;
   reg 	  core_reset_rx_tmp;
   reg 	  core_reset_rx;
   //synthesis attribute async_reg of core_reset_tx_tmp is "true";
   //synthesis attribute async_reg of core_reset_tx is "true";
   //synthesis attribute async_reg of core_reset_rx_tmp is "true";
   //synthesis attribute async_reg of core_reset_rx is "true";
   always @(posedge clk156 or posedge hw_reset)
     begin
	if (hw_reset)
	  begin
	     core_reset_rx_tmp <= #1 1'b1;
	     core_reset_rx     <= #1 1'b1;
	     core_reset_tx_tmp <= #1 1'b1;
	     core_reset_tx     <= #1 1'b1;
	  end
	else
	  begin
	     // Hold core in reset until everything else is ready...
	     core_reset_tx_tmp <= #1 (!(tx_resetdone) || hw_reset || tx_fault || !(signal_detect));
	     core_reset_tx     <= #1 core_reset_tx_tmp;
	     core_reset_rx_tmp <= #1 (!(rx_resetdone) || hw_reset || tx_fault || !(signal_detect));
	     core_reset_rx     <= #1 core_reset_rx_tmp;
	  end
     end // always @ (posedge clk156 or posedge reset)
   // Create the other synchronized resets from the core reset...
   reg txreset322_tmp;
   reg rxreset322_tmp;
   reg dclk_reset_tmp;
   //synthesis attribute async_reg of txreset322_tmp is "true";
   //synthesis attribute async_reg of txreset322 is "true";
   //synthesis attribute async_reg of rxreset322_tmp is "true";
   //synthesis attribute async_reg of rxreset322 is "true";//
   //synthesis attribute async_reg of dclk_reset_tmp is "true";
   //synthesis attribute async_reg of dclk_reset is "true";//       
   always @(posedge txclk322 or posedge hw_reset)
     begin
	if (hw_reset)
	  begin
	     txreset322_tmp <= #1 1'b1;
	     txreset322     <= #1 1'b1;
	     rxreset322_tmp <= #1 1'b1;
	     rxreset322     <= #1 1'b1;
	     dclk_reset_tmp <= #1 1'b1;
	     dclk_reset     <= #1 1'b1;	     	     
	  end
	else
	  begin
	     txreset322_tmp <= #1 core_reset_tx;
	     txreset322     <= #1 txreset322_tmp;
	     rxreset322_tmp <= #1 core_reset_rx;
	     rxreset322     <= #1 rxreset322_tmp;
	     dclk_reset_tmp <= #1 core_reset_rx;
	     dclk_reset     <= #1 dclk_reset_tmp;
	  end
     end // always @ (posedge txclk322 or posedge reset)
endmodule
// 
// xphy_block_gt.v ends here
