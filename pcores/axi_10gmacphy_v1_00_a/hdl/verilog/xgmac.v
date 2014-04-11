//////////////////////////////////////////////////////////////////////////////
// (c) Copyright 2001-2008 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// 
//////////////////////////////////////////////////////////////////////////////


module xgmac
(
  // Port declarations
  
  input  reset,
  input  tx_axis_aresetn,
  input  [63 : 0] tx_axis_tdata,
  input  [7 : 0] tx_axis_tkeep,
  input  tx_axis_tvalid,
  output tx_axis_tready,
  input  [7 : 0] tx_ifg_delay,
  input  tx_axis_tlast,
  input  [127 :0] tx_axis_tuser,
  output [25 : 0] tx_statistics_vector,
  output tx_statistics_valid,
  input  [15 : 0] pause_val,
  input  pause_req,
  input  rx_axis_aresetn,
  output [63 : 0] rx_axis_tdata,
  output [7 : 0] rx_axis_tkeep,
  output rx_axis_tvalid,
  output rx_axis_tlast,
  output rx_axis_tuser,
  output [29 : 0] rx_statistics_vector,
  output rx_statistics_valid,
  input  bus2ip_clk,
  input  bus2ip_reset,
  input  bus2ip_rnw,
  input  [10 : 0] bus2ip_addr,
  input  [31 : 0] bus2ip_data,
  output [31 : 0] ip2bus_data,
  input  bus2ip_cs,
  output ip2bus_rdack,
  output ip2bus_wrack, 
  output ip2bus_error, 
  output xgmacint, 
  output mdc,
  input  mdio_in,
  output mdio_out,
  output mdio_tri,
  input  tx_clk0,
  input  tx_dcm_lock,
  output [63 : 0] xgmii_txd,
  output [7 : 0] xgmii_txc,
  input  rx_clk0,
  input  rx_dcm_lock,
  input  [63 : 0] xgmii_rxd,
  input  [7 : 0] xgmii_rxc
   );
  
endmodule



