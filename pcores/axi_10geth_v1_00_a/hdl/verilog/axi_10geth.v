// axi_10geth.v --- 
// 
// Filename: axi_10geth.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Tue Apr 15 19:20:09 2014 (-0700)
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
module axi_10geth (/*AUTOARG*/
   // Outputs
   txd_tready, txc_tready, tx_axis_mac_tvalid, tx_axis_mac_tuser,
   tx_axis_mac_tlast, tx_axis_mac_tkeep, tx_axis_mac_tdata,
   rxs_tvalid, rxs_tlast, rxs_tkeep, rxs_tdata, rxd_tvalid, rxd_tlast,
   rxd_tkeep, rxd_tdata, rx_axis_mac_tready, ofm_out_fsm_dbg,
   ifm_out_fsm_dbg, ifm_in_fsm_dbg,
   // Inputs
   txd_tvalid, txd_tlast, txd_tkeep, txd_tdata, txc_tvalid, txc_tlast,
   txc_tkeep, txc_tdata, tx_reset, tx_clk, tx_axis_mac_tready,
   s2mm_resetn, s2mm_clk, rxs_tready, rxd_tready, rx_reset, rx_clk,
   rx_axis_mac_tvalid, rx_axis_mac_tuser, rx_axis_mac_tlast,
   rx_axis_mac_tkeep, rx_axis_mac_tdata, mm2s_resetn, mm2s_clk
   );
   parameter C_FAMILY = "";
   parameter C_DBG_PORT = "";

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		mm2s_clk;		// To axi_eth_ofm of axi_eth_ofm.v
   input		mm2s_resetn;		// To axi_eth_ofm of axi_eth_ofm.v
   input [63:0]		rx_axis_mac_tdata;	// To axi_eth_ifm of axi_eth_ifm.v
   input [7:0]		rx_axis_mac_tkeep;	// To axi_eth_ifm of axi_eth_ifm.v
   input		rx_axis_mac_tlast;	// To axi_eth_ifm of axi_eth_ifm.v
   input		rx_axis_mac_tuser;	// To axi_eth_ifm of axi_eth_ifm.v
   input		rx_axis_mac_tvalid;	// To axi_eth_ifm of axi_eth_ifm.v
   input		rx_clk;			// To axi_eth_ifm of axi_eth_ifm.v
   input		rx_reset;		// To axi_eth_ifm of axi_eth_ifm.v
   input		rxd_tready;		// To axi_eth_ifm of axi_eth_ifm.v
   input		rxs_tready;		// To axi_eth_ifm of axi_eth_ifm.v
   input		s2mm_clk;		// To axi_eth_ifm of axi_eth_ifm.v
   input		s2mm_resetn;		// To axi_eth_ifm of axi_eth_ifm.v
   input		tx_axis_mac_tready;	// To axi_eth_ofm of axi_eth_ofm.v
   input		tx_clk;			// To axi_eth_ofm of axi_eth_ofm.v
   input		tx_reset;		// To axi_eth_ofm of axi_eth_ofm.v
   input [31:0]		txc_tdata;		// To axi_eth_ofm of axi_eth_ofm.v
   input [3:0]		txc_tkeep;		// To axi_eth_ofm of axi_eth_ofm.v
   input		txc_tlast;		// To axi_eth_ofm of axi_eth_ofm.v
   input		txc_tvalid;		// To axi_eth_ofm of axi_eth_ofm.v
   input [63:0]		txd_tdata;		// To axi_eth_ofm of axi_eth_ofm.v
   input [7:0]		txd_tkeep;		// To axi_eth_ofm of axi_eth_ofm.v
   input		txd_tlast;		// To axi_eth_ofm of axi_eth_ofm.v
   input		txd_tvalid;		// To axi_eth_ofm of axi_eth_ofm.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [3:0]		ifm_in_fsm_dbg;		// From axi_eth_ifm of axi_eth_ifm.v
   output [3:0]		ifm_out_fsm_dbg;	// From axi_eth_ifm of axi_eth_ifm.v
   output [3:0]		ofm_out_fsm_dbg;	// From axi_eth_ofm of axi_eth_ofm.v
   output		rx_axis_mac_tready;	// From axi_eth_ifm of axi_eth_ifm.v
   output [63:0]	rxd_tdata;		// From axi_eth_ifm of axi_eth_ifm.v
   output [7:0]		rxd_tkeep;		// From axi_eth_ifm of axi_eth_ifm.v
   output		rxd_tlast;		// From axi_eth_ifm of axi_eth_ifm.v
   output		rxd_tvalid;		// From axi_eth_ifm of axi_eth_ifm.v
   output [31:0]	rxs_tdata;		// From axi_eth_ifm of axi_eth_ifm.v
   output [3:0]		rxs_tkeep;		// From axi_eth_ifm of axi_eth_ifm.v
   output		rxs_tlast;		// From axi_eth_ifm of axi_eth_ifm.v
   output		rxs_tvalid;		// From axi_eth_ifm of axi_eth_ifm.v
   output [63:0]	tx_axis_mac_tdata;	// From axi_eth_ofm of axi_eth_ofm.v
   output [7:0]		tx_axis_mac_tkeep;	// From axi_eth_ofm of axi_eth_ofm.v
   output		tx_axis_mac_tlast;	// From axi_eth_ofm of axi_eth_ofm.v
   output		tx_axis_mac_tuser;	// From axi_eth_ofm of axi_eth_ofm.v
   output		tx_axis_mac_tvalid;	// From axi_eth_ofm of axi_eth_ofm.v
   output		txc_tready;		// From axi_eth_ofm of axi_eth_ofm.v
   output		txd_tready;		// From axi_eth_ofm of axi_eth_ofm.v
   // End of automatics

   axi_eth_ifm axi_eth_ifm (/*AUTOINST*/
			    // Outputs
			    .ifm_in_fsm_dbg	(ifm_in_fsm_dbg[3:0]),
			    .ifm_out_fsm_dbg	(ifm_out_fsm_dbg[3:0]),
			    .rx_axis_mac_tready	(rx_axis_mac_tready),
			    .rxd_tdata		(rxd_tdata[63:0]),
			    .rxd_tkeep		(rxd_tkeep[7:0]),
			    .rxd_tlast		(rxd_tlast),
			    .rxd_tvalid		(rxd_tvalid),
			    .rxs_tdata		(rxs_tdata[31:0]),
			    .rxs_tkeep		(rxs_tkeep[3:0]),
			    .rxs_tlast		(rxs_tlast),
			    .rxs_tvalid		(rxs_tvalid),
			    // Inputs
			    .rx_axis_mac_tdata	(rx_axis_mac_tdata[63:0]),
			    .rx_axis_mac_tkeep	(rx_axis_mac_tkeep[7:0]),
			    .rx_axis_mac_tlast	(rx_axis_mac_tlast),
			    .rx_axis_mac_tuser	(rx_axis_mac_tuser),
			    .rx_axis_mac_tvalid	(rx_axis_mac_tvalid),
			    .rx_clk		(rx_clk),
			    .rx_reset		(rx_reset),
			    .rxd_tready		(rxd_tready),
			    .rxs_tready		(rxs_tready),
			    .s2mm_clk		(s2mm_clk),
			    .s2mm_resetn	(s2mm_resetn));
   axi_eth_ofm axi_eth_ofm (/*AUTOINST*/
			    // Outputs
			    .ofm_out_fsm_dbg	(ofm_out_fsm_dbg[3:0]),
			    .tx_axis_mac_tdata	(tx_axis_mac_tdata[63:0]),
			    .tx_axis_mac_tkeep	(tx_axis_mac_tkeep[7:0]),
			    .tx_axis_mac_tlast	(tx_axis_mac_tlast),
			    .tx_axis_mac_tuser	(tx_axis_mac_tuser),
			    .tx_axis_mac_tvalid	(tx_axis_mac_tvalid),
			    .txc_tready		(txc_tready),
			    .txd_tready		(txd_tready),
			    // Inputs
			    .mm2s_clk		(mm2s_clk),
			    .mm2s_resetn	(mm2s_resetn),
			    .tx_axis_mac_tready	(tx_axis_mac_tready),
			    .tx_clk		(tx_clk),
			    .tx_reset		(tx_reset),
			    .txc_tdata		(txc_tdata[31:0]),
			    .txc_tkeep		(txc_tkeep[3:0]),
			    .txc_tlast		(txc_tlast),
			    .txc_tvalid		(txc_tvalid),
			    .txd_tdata		(txd_tdata[63:0]),
			    .txd_tkeep		(txd_tkeep[7:0]),
			    .txd_tlast		(txd_tlast),
			    .txd_tvalid		(txd_tvalid));

   wire [127:0] tx_dma_dbg;
   wire [127:0] rx_dma_dbg;
   wire [127:0] tx_mac_dbg;
   wire [127:0] rx_mac_dbg;
   assign tx_dma_dbg [63:0]    = txd_tdata;
   assign tx_dma_dbg [71:64]   = txd_tkeep;
   assign tx_dma_dbg [72]      = txd_tvalid;
   assign tx_dma_dbg [73]      = txd_tlast;
   assign tx_dma_dbg [74]      = txd_tready;
   /* trig */
   assign tx_dma_dbg [120]     = txd_tvalid;
   assign tx_dma_dbg [121]     = txd_tlast;
   assign tx_dma_dbg [122]     = txd_tready;
                               
   assign tx_dma_dbg [107:76]  = txc_tdata;
   assign tx_dma_dbg [111:108] = txc_tkeep;
   assign tx_dma_dbg [123]     = txc_tvalid;
   assign tx_dma_dbg [124]     = txc_tlast;
   assign tx_dma_dbg [125]     = txc_tready;
                               
   assign rx_dma_dbg [63:0]    = rxd_tdata;
   assign rx_dma_dbg [71:64]   = rxd_tkeep;
   assign rx_dma_dbg [72]      = rxd_tvalid;
   assign rx_dma_dbg [73]      = rxd_tlast;
   assign rx_dma_dbg [74]      = rxd_tready;
   /* trig */
   assign rx_dma_dbg [120]     = rxd_tvalid;
   assign rx_dma_dbg [121]     = rxd_tlast;
   assign rx_dma_dbg [122]     = rxd_tready;

   assign rx_dma_dbg [107:76]  = rxs_tdata;
   assign rx_dma_dbg [111:108] = rxs_tkeep;
   assign rx_dma_dbg [123]     = rxs_tvalid;
   assign rx_dma_dbg [124]     = rxs_tlast;
   assign rx_dma_dbg [125]     = rxs_tready;
                               
   assign rx_mac_dbg [63:0]    = rx_axis_mac_tdata;
   assign rx_mac_dbg [71:64]   = rx_axis_mac_tkeep;
   assign rx_mac_dbg [72]      = rx_axis_mac_tvalid;
   assign rx_mac_dbg [73]      = rx_axis_mac_tlast;
   assign rx_mac_dbg [74]      = rx_axis_mac_tready;  
   assign rx_mac_dbg [75]      = rx_axis_mac_tuser;
   assign rx_mac_dbg [123]     = rx_axis_mac_tvalid;
   assign rx_mac_dbg [124]     = rx_axis_mac_tlast;
   assign rx_mac_dbg [125]     = rx_axis_mac_tready;  
   assign rx_mac_dbg [126]     = rx_axis_mac_tuser;  
                               
   assign tx_mac_dbg [63:0]    = tx_axis_mac_tdata;
   assign tx_mac_dbg [71:64]   = tx_axis_mac_tkeep;
   assign tx_mac_dbg [72]      = tx_axis_mac_tvalid;
   assign tx_mac_dbg [73]      = tx_axis_mac_tlast;
   assign tx_mac_dbg [74]      = tx_axis_mac_tready;  
   assign tx_mac_dbg [75]      = tx_axis_mac_tuser;
   assign tx_mac_dbg [123]     = tx_axis_mac_tvalid;
   assign tx_mac_dbg [124]     = tx_axis_mac_tlast;
   assign tx_mac_dbg [125]     = tx_axis_mac_tready;  
   assign tx_mac_dbg [126]     = tx_axis_mac_tuser;  
   
   reg [127:0] tx_dma_reg;
   reg [127:0] rx_dma_reg;
   reg [127:0] tx_mac_reg;
   reg [127:0] rx_mac_reg;

   wire [35:0] 	CONTROL0;
   wire [35:0] 	CONTROL1;
   wire [35:0] 	CONTROL2;
   wire [35:0] 	CONTROL3; 
   wire 	tx_trig0;
   wire 	rx_trig0;
   wire 	tx_trig1;
   wire 	rx_trig1;
   always @(posedge tx_clk)
     begin
	tx_dma_reg <= #1 tx_dma_dbg;
	rx_dma_reg <= #1 rx_dma_dbg;
     end
   always @(posedge mm2s_clk)
     begin
	tx_mac_reg <= #1 tx_mac_dbg;
	rx_mac_reg <= #1 rx_mac_dbg;
     end

generate if (C_DBG_PORT == 1) begin
     icon4 icon4 (/*AUTOINST*/
		  // Inouts
		  .CONTROL0		(CONTROL0[35:0]),
		  .CONTROL1		(CONTROL1[35:0]),
		  .CONTROL2		(CONTROL2[35:0]),
		  .CONTROL3		(CONTROL3[35:0]));
     ila128_16 ila_txdma (
			  // Outputs
			  .TRIG_OUT	(tx_trig0),
			  // Inouts
			  .CONTROL	(CONTROL0[35:0]),
			  // Inputs
			  .CLK		(mm2s_clk),
			  .TRIG0	(tx_dma_reg[127:112]),
			  .DATA		(tx_dma_reg[127:0]));
     ila128_16 ila_txmac (
			  // Outputs
			  .TRIG_OUT	(tx_trig1),
			  // Inouts
			  .CONTROL	(CONTROL1[35:0]),
			  // Inputs
			  .CLK		(tx_clk),
			  .TRIG0	({tx_trig0, tx_mac_reg[126:112]}),
			  .DATA		(tx_mac_reg[127:0]));
     ila128_16 ila_rxdma (
			  // Outputs
			  .TRIG_OUT	(rx_trig0),
			  // Inouts
			  .CONTROL	(CONTROL2[35:0]),
			  // Inputs
			  .CLK		(mm2s_clk),
			  .TRIG0	({rx_trig1, rx_dma_reg[126:112]}),
			  .DATA		(rx_dma_reg[127:0]));
     ila128_16 ila_rxmac (
			  // Outputs
			  .TRIG_OUT	(rx_trig1),
			  // Inouts
			  .CONTROL	(CONTROL3[35:0]),
			  // Inputs
			  .CLK		(tx_clk),
			  .TRIG0	(rx_mac_reg[127:112]),
			  .DATA		(rx_mac_reg[127:0]));
end endgenerate
endmodule
// 
// axi_10geth.v ends here
