// xphy_int.v --- 
// 
// Filename: xphy_int.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Apr  6 14:19:57 2014 (-0700)
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
module xphy_int (/*AUTOARG*/
   // Outputs
   areset, dclk_reset, resetdone, core_clk156_out, txreset322,
   rxreset322, xgmii_txd_int, xgmii_txc_int, xgmii_rxd, xgmii_rxc,
   rx_dcm_lock, tx_dcm_lock,
   // Inputs
   xphy_reset, is_eval, tx_resetdone, rx_resetdone, clk156, reset,
   tx_fault, signal_detect, txclk322, xgmii_txd, xgmii_txc,
   xgmii_rxd_int, xgmii_rxc_int
   );
   output areset;
   input  xphy_reset;
   assign areset = xphy_reset;

   output dclk_reset;
   input  is_eval;
   
   input  tx_resetdone;
   input  rx_resetdone;
   output resetdone;
   assign resetdone = tx_resetdone && rx_resetdone;

   input  clk156;
   input  reset;
   input  tx_fault;
   input  signal_detect;
   output core_clk156_out;
   assign core_clk156_out = clk156;

   reg 	  core_reset_tx_tmp;
   reg 	  core_reset_tx;
   reg 	  core_reset_rx_tmp;
   reg 	  core_reset_rx;
   //synthesis attribute async_reg of core_reset_tx_tmp is "true";
   //synthesis attribute async_reg of core_reset_tx is "true";
   //synthesis attribute async_reg of core_reset_rx_tmp is "true";
   //synthesis attribute async_reg of core_reset_rx is "true";
   always @(posedge clk156 or posedge reset)
     begin
	if (reset)
	  begin
	     core_reset_rx_tmp <= #1 1'b1;
	     core_reset_rx     <= #1 1'b1;
	     core_reset_tx_tmp <= #1 1'b1;
	     core_reset_tx     <= #1 1'b1;
	  end
	else
	  begin
	     // Hold core in reset until everything else is ready...
	     core_reset_tx_tmp <= #1 (!(tx_resetdone) || reset || tx_fault || !(signal_detect));
	     core_reset_tx     <= #1 core_reset_tx_tmp;
	     core_reset_rx_tmp <= #1 (!(rx_resetdone) || reset || tx_fault || !(signal_detect));
	     core_reset_rx     <= #1 core_reset_rx_tmp;
	  end
     end // always @ (posedge clk156 or posedge reset)

   input txclk322;
   output txreset322;
   output rxreset322;
   // Create the other synchronized resets from the core reset...
   reg txreset322_tmp;
   reg txreset322;
   reg rxreset322_tmp;
   reg rxreset322;
   reg dclk_reset_tmp;
   reg dclk_reset;
   //synthesis attribute async_reg of txreset322_tmp is "true";
   //synthesis attribute async_reg of txreset322 is "true";
   //synthesis attribute async_reg of rxreset322_tmp is "true";
   //synthesis attribute async_reg of rxreset322 is "true";//
   //synthesis attribute async_reg of dclk_reset_tmp is "true";
   //synthesis attribute async_reg of dclk_reset is "true";//       
   always @(posedge txclk322 or posedge reset)
     begin
	if (reset)
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

   input [63:0]  xgmii_txd;
   input [7:0] 	 xgmii_txc;
   output [63:0] xgmii_txd_int;
   output [7:0]  xgmii_txc_int;
   reg [63:0]    xgmii_txd_int;
   reg [7:0]     xgmii_txc_int;

   input [63:0]  xgmii_rxd_int;
   input [7:0] 	 xgmii_rxc_int;
   output [63:0] xgmii_rxd;
   output [7:0]  xgmii_rxc;
   reg    [63:0] xgmii_rxd;
   reg    [7:0]  xgmii_rxc;   
   always @(posedge clk156)
     begin
	xgmii_txd_int <= #1 xgmii_txd;
	xgmii_txd_int <= #1 xgmii_txd;
	xgmii_rxd     <= #1 xgmii_rxd_int;
	xgmii_rxc     <= #1 xgmii_rxc_int;
     end

   output rx_dcm_lock;
   output tx_dcm_lock;
   assign rx_dcm_lock = rx_resetdone;
   assign tx_dcm_lock = tx_resetdone;
   
endmodule
// 
// xphy_int.v ends here
