////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.68d
//  \   \         Application: netgen
//  /   /         Filename: xgmac.v
// /___/   /\     Timestamp: Sun Apr  6 20:32:33 2014
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -ofmt verilog -w -sim xgmac.ngc 
// Device	: xc7k325t-2ffg900
// Input file	: xgmac.ngc
// Output file	: xgmac.v
// # of Modules	: 1
// Design Name	: xgmac
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

module xgmac (
  reset, tx_axis_aresetn, tx_axis_tvalid, tx_axis_tlast, rx_axis_aresetn, pause_req, bus2ip_clk, bus2ip_reset, bus2ip_rnw, bus2ip_cs, tx_clk0, 
tx_dcm_lock, rx_clk0, rx_dcm_lock, mdio_in, tx_axis_tready, tx_statistics_valid, rx_axis_tvalid, rx_axis_tuser, rx_axis_tlast, rx_statistics_valid, 
ip2bus_rdack, ip2bus_wrack, ip2bus_error, xgmacint, mdc, mdio_out, mdio_tri, tx_axis_tdata, tx_axis_tuser, tx_ifg_delay, tx_axis_tkeep, pause_val, 
bus2ip_addr, bus2ip_data, xgmii_rxd, xgmii_rxc, tx_statistics_vector, rx_axis_tdata, rx_axis_tkeep, rx_statistics_vector, ip2bus_data, xgmii_txd, 
xgmii_txc
);
  input reset;
  input tx_axis_aresetn;
  input tx_axis_tvalid;
  input tx_axis_tlast;
  input rx_axis_aresetn;
  input pause_req;
  input bus2ip_clk;
  input bus2ip_reset;
  input bus2ip_rnw;
  input bus2ip_cs;
  input tx_clk0;
  input tx_dcm_lock;
  input rx_clk0;
  input rx_dcm_lock;
  input mdio_in;
  output tx_axis_tready;
  output tx_statistics_valid;
  output rx_axis_tvalid;
  output rx_axis_tuser;
  output rx_axis_tlast;
  output rx_statistics_valid;
  output ip2bus_rdack;
  output ip2bus_wrack;
  output ip2bus_error;
  output xgmacint;
  output mdc;
  output mdio_out;
  output mdio_tri;
  input [63 : 0] tx_axis_tdata;
  input [127 : 0] tx_axis_tuser;
  input [7 : 0] tx_ifg_delay;
  input [7 : 0] tx_axis_tkeep;
  input [15 : 0] pause_val;
  input [10 : 0] bus2ip_addr;
  input [31 : 0] bus2ip_data;
  input [63 : 0] xgmii_rxd;
  input [7 : 0] xgmii_rxc;
  output [25 : 0] tx_statistics_vector;
  output [63 : 0] rx_axis_tdata;
  output [7 : 0] rx_axis_tkeep;
  output [29 : 0] rx_statistics_vector;
  output [31 : 0] ip2bus_data;
  output [63 : 0] xgmii_txd;
  output [7 : 0] xgmii_txc;
endmodule
