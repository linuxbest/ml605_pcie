//----------------------------------------------------------------------
// $Revision: 1.3 $
// $Date: 2010/12/01 11:15:45 $
//----------------------------------------------------------------------
// Title      : IPIC Internal to Bus Multiplexer
// Project    : tri_mode_eth_mac
//----------------------------------------------------------------------
// File       : axi_ethernet_v3_01_a_ipic_mux.v
// Author     : Xilinx, Inc.
//----------------------------------------------------------------------
// Description: IPIC interface inputs to the TEMAC are bussed and
//              consumed by various modules. In addition to responding
//              to reads with RdAck and Data, each of those modules must
//              also respond to writes with WrAck, and can generate
//              individual Error signals. This module is a multiplexer
//              which selects the appropriate Data input to drive onto
//              IP2BUS_DATA. It also ORs all of the RdAck, WrAck, and
//              Error signals since only one is active at a time. All
//              outputs are registered for timing closure.
//----------------------------------------------------------------------
// (c) Copyright 2006, 2007, 2008 Xilinx, Inc. All rights reserved.
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
//----------------------------------------------------------------------

`timescale 1ps/1ps

module axi_ethernet_v3_01_a_ipic_mux (

  //--------------------------------------------------------------------
  // IPIC Interface
  //--------------------------------------------------------------------

  input              bus2ip_clk,
  input              bus2ip_reset,        // Synchronized in trimac_gen

  // signals for local chip select generation
  input      [10:8]  bus2ip_addr,
  input              bus2ip_cs,
  input              bus2ip_rdce,
  input              bus2ip_wrce,  
  // Bit 0:stats, 1:config, 2:intr, 3:af 
  output reg [3:0]   bus2ip_cs_int,  
  output reg [3:0]   bus2ip_rdce_int,
  output reg [3:0]   bus2ip_wrce_int,
  
  output reg         ip2bus_rdack,
  output reg         ip2bus_wrack,
  output reg         ip2bus_error,
  output reg [31:0]  ip2bus_data,

  //--------------------------------------------------------------------
  // TEMAC Interface
  //--------------------------------------------------------------------


  input              ip2bus_rdack_stats,  // RdAck signals from various blocks
  input              ip2bus_rdack_config,
  input              ip2bus_rdack_intr,
  input              ip2bus_rdack_af,

  input              ip2bus_wrack_stats,  // WrAck signals from various blocks
  input              ip2bus_wrack_config,
  input              ip2bus_wrack_intr,
  input              ip2bus_wrack_af,

  input              ip2bus_error_stats,  // Error signals from various blocks
  input              ip2bus_error_config,
  input              ip2bus_error_intr,
  input              ip2bus_error_af,

  input      [31:0]  ip2bus_data_stats,   // Data busses from various blocks
  input      [31:0]  ip2bus_data_config,
  input      [31:0]  ip2bus_data_intr,
  input      [31:0]  ip2bus_data_af

);

parameter C_BASE_ADDRESS_STATS = 12'h200;
parameter C_HIGH_ADDRESS_STATS = 12'h3FC;
parameter C_BASE_ADDRESS_MAC   = 12'h400;
parameter C_HIGH_ADDRESS_MAC   = 12'h5FC;
parameter C_BASE_ADDRESS_INTC  = 12'h600;
parameter C_HIGH_ADDRESS_INTC  = 12'h6FC;
parameter C_BASE_ADDRESS_ADDR  = 12'h700;
parameter C_HIGH_ADDRESS_ADDR  = 12'h7FC;

reg        ip2bus_rdack_reg;
reg        ip2bus_wrack_reg;
reg        ip2bus_error_reg;

wire       ip2bus_data_clk_en;
wire [3:0] ip2bus_data_mux_sel;

// generate per block chip selects and rd/wr enables
// these are simply decoded from the address.
always @(posedge bus2ip_clk)
begin
  if (bus2ip_reset) begin
     bus2ip_cs_int <= 4'b0000;
  end
  else if (bus2ip_cs) begin
     case (bus2ip_addr[10:9])
        C_BASE_ADDRESS_STATS[10:9] : begin // 200-3FF
           bus2ip_cs_int <= 4'b0001;
        end
        C_BASE_ADDRESS_MAC[10:9] : begin // 400-5FF
           bus2ip_cs_int <= 4'b0010;
        end
        C_BASE_ADDRESS_INTC[10:9] : begin // 600-7FF
           if (bus2ip_addr[8] == C_BASE_ADDRESS_INTC[8]) begin
              bus2ip_cs_int <= 4'b0010;
           end
           else begin
              bus2ip_cs_int <= 4'b1000;
           end
        end
        default : begin // covers addresses from 0-1FF
           bus2ip_cs_int <= 4'b0000;
        end
     endcase
  end
  else begin
     bus2ip_cs_int <= 4'b0000;
  end
end

always @(posedge bus2ip_clk)
begin
  if (bus2ip_reset) begin
     bus2ip_rdce_int <= 4'b0000;
  end
  else if (bus2ip_rdce) begin
     case (bus2ip_addr[10:9])
        C_BASE_ADDRESS_STATS[10:9] : begin // 200-3FF
           bus2ip_rdce_int <= 4'b0001;
        end
        C_BASE_ADDRESS_MAC[10:9] : begin // 400-5FF
           bus2ip_rdce_int <= 4'b0010;
        end
        C_BASE_ADDRESS_INTC[10:9] : begin // 600-7FF
           if (bus2ip_addr[8] == C_BASE_ADDRESS_INTC[8]) begin
              bus2ip_rdce_int <= 4'b0010;
           end
           else begin
              bus2ip_rdce_int <= 4'b1000;
           end
        end
        default : begin // covers addresses from 0-1FF
           bus2ip_rdce_int <= 4'b0000;
        end
     endcase
  end
  else begin
     bus2ip_rdce_int <= 4'b0000;
  end
end

always @(posedge bus2ip_clk)
begin
  if (bus2ip_reset) begin
     bus2ip_wrce_int <= 4'b0000;
  end
  else if (bus2ip_wrce) begin
     case (bus2ip_addr[10:9])
        C_BASE_ADDRESS_STATS[10:9] : begin // 200-3FF
           bus2ip_wrce_int <= 4'b0001;
        end
        C_BASE_ADDRESS_MAC[10:9] : begin // 400-5FF
           bus2ip_wrce_int <= 4'b0010;
        end
        C_BASE_ADDRESS_INTC[10:9] : begin // 600-7FF
           if (bus2ip_addr[8] == C_BASE_ADDRESS_INTC[8]) begin
              bus2ip_wrce_int <= 4'b0010;
           end
           else begin
              bus2ip_wrce_int <= 4'b1000;
           end
        end
        default : begin // covers addresses from 0-1FF
           bus2ip_wrce_int <= 4'b0000;
        end
     endcase
  end
  else begin
     bus2ip_wrce_int <= 4'b0000;
  end
end







// RdAck, WrAck, and Error outputs are all registered ORs of their constituent signals.
always @(posedge bus2ip_clk)
begin
  if (bus2ip_reset) begin
    ip2bus_rdack_reg <= 1'b0;
    ip2bus_wrack_reg <= 1'b0;
    ip2bus_error_reg <= 1'b0;
    ip2bus_rdack     <= 1'b0;
    ip2bus_wrack     <= 1'b0;
    ip2bus_error     <= 1'b0;
  end
  else begin
    ip2bus_rdack_reg <= ip2bus_rdack_stats | ip2bus_rdack_config | ip2bus_rdack_intr | ip2bus_rdack_af;
    ip2bus_wrack_reg <= ip2bus_wrack_stats | ip2bus_wrack_config | ip2bus_wrack_intr | ip2bus_wrack_af;
    ip2bus_error_reg <= ip2bus_error_stats | ip2bus_error_config | ip2bus_error_intr | ip2bus_error_af;
    ip2bus_rdack     <= (ip2bus_rdack_stats | ip2bus_rdack_config | ip2bus_rdack_intr | ip2bus_rdack_af) & !ip2bus_rdack_reg;
    ip2bus_wrack     <= (ip2bus_wrack_stats | ip2bus_wrack_config | ip2bus_wrack_intr | ip2bus_wrack_af) & !ip2bus_wrack_reg;
    ip2bus_error     <= (ip2bus_error_stats | ip2bus_error_config | ip2bus_error_intr | ip2bus_error_af) & !ip2bus_error_reg;
  end
end

// Create a clock enable for the registered data mux, which is an OR of all RdAck signals.
assign ip2bus_data_clk_en  = ip2bus_rdack_stats | ip2bus_rdack_config | ip2bus_rdack_intr | ip2bus_rdack_af;
assign ip2bus_data_mux_sel = {ip2bus_rdack_af, ip2bus_rdack_intr, ip2bus_rdack_config, ip2bus_rdack_stats};

// Multiplex the various read data busses using the RdAck signals for one-hot selection,
// and the OR of all RdAck signals as a clock enable.
always @(posedge bus2ip_clk)
begin
  if (bus2ip_reset) begin
    ip2bus_data  <= 32'b0;
  end
  else begin
    if (ip2bus_data_clk_en) begin
      case (ip2bus_data_mux_sel)
        4'b0001: ip2bus_data <= ip2bus_data_stats;
        4'b0010: ip2bus_data <= ip2bus_data_config;
        4'b0100: ip2bus_data <= ip2bus_data_intr;
        4'b1000: ip2bus_data <= ip2bus_data_af;
      endcase
    end
    else begin
      ip2bus_data  <= 32'b0;
    end
  end
end


endmodule
