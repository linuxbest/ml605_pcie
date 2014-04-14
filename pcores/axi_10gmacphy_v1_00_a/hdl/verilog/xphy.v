////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.68d
//  \   \         Application: netgen
//  /   /         Filename: xphy.v
// /___/   /\     Timestamp: Sat Apr 12 18:10:13 2014
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -ofmt verilog -w -sim xphy.ngc 
// Device	: xc7k325t-2ffg900
// Input file	: xphy.ngc
// Output file	: xphy.v
// # of Modules	: 1
// Design Name	: xphy
// Xilinx        : /opt/Xilinx/14.6/ISE_DS/ISE/
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Command Line Tools User Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module xphy (
  reset, txreset322, rxreset322, dclk_reset, clk156, txusrclk2, rxusrclk2, dclk, mdc, mdio_in, resetdone, drp_gnt, drp_drdy, signal_detect, tx_fault, 
pma_resetout, pcs_resetout, mdio_out, mdio_tri, gt_slip, drp_req, drp_den, drp_dwe, tx_disable, tx_prbs31_en, rx_prbs31_en, clear_rx_prbs_err_count, 
xgmii_txd, xgmii_txc, prtad, pma_pmd_type, gt_rxd, gt_rxc, drp_drpdo, xgmii_rxd, xgmii_rxc, core_status, gt_txd, gt_txc, drp_daddr, drp_di, 
loopback_ctrl
);
  input reset;
  input txreset322;
  input rxreset322;
  input dclk_reset;
  input clk156;
  input txusrclk2;
  input rxusrclk2;
  input dclk;
  input mdc;
  input mdio_in;
  input resetdone;
  input drp_gnt;
  input drp_drdy;
  input signal_detect;
  input tx_fault;
  output pma_resetout;
  output pcs_resetout;
  output mdio_out;
  output mdio_tri;
  output gt_slip;
  output drp_req;
  output drp_den;
  output drp_dwe;
  output tx_disable;
  output tx_prbs31_en;
  output rx_prbs31_en;
  output clear_rx_prbs_err_count;
  input [63 : 0] xgmii_txd;
  input [7 : 0] xgmii_txc;
  input [4 : 0] prtad;
  input [2 : 0] pma_pmd_type;
  input [31 : 0] gt_rxd;
  input [7 : 0] gt_rxc;
  input [15 : 0] drp_drpdo;
  output [63 : 0] xgmii_rxd;
  output [7 : 0] xgmii_rxc;
  output [7 : 0] core_status;
  output [31 : 0] gt_txd;
  output [7 : 0] gt_txc;
  output [15 : 0] drp_daddr;
  output [15 : 0] drp_di;
  output [2 : 0] loopback_ctrl;
endmodule
