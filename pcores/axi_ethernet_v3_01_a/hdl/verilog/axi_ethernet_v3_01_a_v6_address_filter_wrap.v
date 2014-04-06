//----------------------------------------------------------------------
// $Revision: 1.4 $
// $Date: 2010/12/01 11:15:45 $
//----------------------------------------------------------------------
// Title      : Configurable Address and Frame Filter
// Project    : Tri-Mode Ethernet MAC
//----------------------------------------------------------------------
// File       : axi_ethernet_v3_01_a_v6_address_filter_wrap.v
// Author     : Xilinx, Inc.
//----------------------------------------------------------------------
// Description: Wrapper for the TEMAC address filter. This module
//              contains addressable registers which store the unicast
//              address and filter/mask selection. The address filter
//              is instantiated in this wrapper, which then uses a
//              transformed version of the IPIC bus for its special
//              distributed RAM access methodology.
//----------------------------------------------------------------------
// (c) Copyright 2007, 2008 Xilinx, Inc. All rights reserved.
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
`define log2(n)   ((n) <= (1<<1) ? 1 : (n) <= (1<<2) ? 2 : (n) <= (1<<3) ? 3 : (n) <= (1<<4) ? 4 : (n) <= (1<<5) ? 5 :(n) <= (1<<6) ? 6 : 7)

module axi_ethernet_v3_01_a_v6_address_filter_wrap #
(
  // Number of Addresses for Address Filter
  parameter c_at_entries  = 8,
  parameter c_has_host    = 1,
  parameter c_add_filter  = 1,
  parameter c_unicast_pause_address = 0
)
(
  // Clocks, clock enable and reset
  input                             rxcoreclk,
  input                             rx_sync_reset,
  input                             rxclk_ce,

  // Input packets (before address filter)
  input [7:0]                       data_early,
  input                             data_valid_early,

  // Input addresses
  input [47:0]                      rx_pause_addr,
  input                             update_pause_ad,
  input                             promiscuous_mode_init,

  // Output packets (only packets with a maching address)
  output [7:0]                      rx_filtered_data,
  output                            rx_filtered_data_valid,

  // Address match signals
  output                            unicastaddressmatch,
  output                            broadcastaddressmatch,
  output                            pauseaddressmatch,
  output                            specialpauseaddressmatch,
  output                            rxstatsaddressmatch,
  output [c_at_entries:0]           rx_filter_match,

  // IPIC Interrface
  input                             bus2ip_clk,
  input                             bus2ip_reset,
  input                             bus2ip_ce,
  input                             bus2ip_rdce,
  input                             bus2ip_wrce,
  output reg                        ip2bus_rdack,
  output reg                        ip2bus_wrack,
  input      [31:0]                 bus2ip_addr,
  input      [31:0]                 bus2ip_data,
  output reg [31:0]                 ip2bus_data,
  output                            ip2bus_error

);

  localparam  SELECT_BITS    = (`log2(c_at_entries)-1);

  // Memory mapped registers 
  reg  promiscuous_mode_reg;
  reg  [SELECT_BITS:0] af_select_reg; // Currently only enabling filters 0-7. If more are enabled,
                            // this register should increase up to [7:0]. Bit 3 is used
                            // or else the left shift operation will generate a warning.

  wire [6-SELECT_BITS:0] gap_filler = 0;
  // Array of address filter enables. Individually addressable by dereferencing
  // the af_select_reg first.
  reg [c_at_entries:0] filter_enable_reg;

  // Internals
  wire bus2ip_ce_comb;
  reg  bus2ip_ce_int;
  wire bus2ip_rdce_comb;
  wire bus2ip_rdce_re;
  reg  bus2ip_rdce_int;
  reg  bus2ip_rdce_re_int;
  wire bus2ip_wrce_comb;
  reg  bus2ip_wrce_int;
  wire bus2ip_wrce_re;
  reg  bus2ip_wrce_re_int;
  wire [7+SELECT_BITS:0] bus2ip_addr_comb;
  wire af_pat_msk_slt_comb;
  wire [SELECT_BITS+1:0] af_addr_pat_comb;
  wire [SELECT_BITS+1:0] af_addr_msk_comb;
  reg  [7+SELECT_BITS:0] bus2ip_addr_int;
  wire [31:0] bus2ip_data_comb;
  reg  [31:0] bus2ip_data_int;
  wire bus2ip_ce_local_comb;
  wire ip2bus_rdack_int;
  wire ip2bus_wrack_int;
  wire [31:0] ip2bus_data_int;
  wire ip2bus_error_int;
  wire [31-(SELECT_BITS+8):0] gap_filler32 = 0;
  reg  bus2ip_sel_uc;

  // --------------------------------------------------------------------------
  // Transform IPIC addresses depending on whether they access registers present
  // in this wrapper, or they're decoded to the distributed RAM filters.
  // --------------------------------------------------------------------------

  // Address bits 13:6 are used by the logic in the address filter to select among
  // distributed RAMs. Even addresses select pattern RAMs, while the subsequent odd
  // address selects its mask RAM pair. To select filter i's pattern RAM, use
  // address 2i; to select its mask RAM, use address 2i+1.
  // - Because only 8 filters are currently supported, bus2ip_addr_comb bits 13:6
  //   won't exceed 15. Therefore, tie 13:10 low. If more than 8 filters are ever
  //   supported, fold bits 13:10 into the bus2ip_addr_comb equation which follows.
  // - Bits 9:6 are between 0000 (for filter 0's pattern RAM), and 1111 (for filter
  //   7's mask RAM). Since the AF index selection register assumes a single value i
  //   for both pattern and mask, generate 2i and 2i+1 cases, then mux between them.
  //   - af_pat_msk_slt_comb   : Pattern/mask RAM selection, based on whether the
  //                             address is in the pattern or mask range.
  //   - af_addr_pat_comb      : Value 2i selects address filter i's pattern RAM.
  //   - af_addr_msk_comb      : Value 2i+1 selects address filter i's mask RAM.
  //   - bus2ip_addr_comb[9:6] : Mux output, selected by af_pat_msk_slt_comb.
  assign af_pat_msk_slt_comb   = bus2ip_addr[7:4] > 4'b0100;
  assign af_addr_pat_comb      = (af_select_reg << 1);
  assign af_addr_msk_comb      = (af_select_reg << 1) + 1'b1;
  assign bus2ip_addr_comb[7+SELECT_BITS:6] = af_pat_msk_slt_comb ? af_addr_msk_comb[SELECT_BITS+1:0] : 
                                                                   af_addr_pat_comb[SELECT_BITS+1:0];

  // Address bits 5:0 are used as the distributed RAM address in the address filter.
  // Since register map IPIC addresses are allocated to pattern and mask RAMs
  // separately, and are not on convenient boundaries, there is no closed form
  // transform to derive bits 5:0.
  // - The following are minimized logic equations derived from Karnaugh maps.
  assign bus2ip_addr_comb[5] = ~(bus2ip_addr[5] ^ bus2ip_addr[4]);
  assign bus2ip_addr_comb[4] = ~(bus2ip_addr[7] | bus2ip_addr[4]) | ~(bus2ip_addr[5] | bus2ip_addr[4]);
  // - Bits 3:0 of distributed RAM address always match bits 3:0 from IPIC.
  assign bus2ip_addr_comb[3:0] = bus2ip_addr[3:0];

  // The IPIF will only assert bus2ip_ce to this module if addresses are 0x700-0x7ff.
  // Since addresses 0x700-0x70c are consumed in this wrapper, and 0x790-0x7fc are not
  // used, drive the signal to the address filter only if addresses are in the range
  // 0x710-0x78c. The behavioral statement is unoptimized but should map to one 6-LUT.
  // Read and write enables are gated by the master enable in the address filter.
  assign bus2ip_ce_comb   = (bus2ip_addr[7:4] > 4'b0000) & (bus2ip_addr[7:4] < 4'b1001);
  assign bus2ip_rdce_comb = bus2ip_rdce;
  assign bus2ip_rdce_re   = bus2ip_rdce && ~bus2ip_rdce_int;
  assign bus2ip_wrce_comb = bus2ip_wrce;
  assign bus2ip_wrce_re   = bus2ip_wrce && ~bus2ip_wrce_int;

  // Data bus is unmodified.
  assign bus2ip_data_comb = bus2ip_data;


  // --------------------------------------------------------------------------
  // Pipeline IPIC signals as required
  // --------------------------------------------------------------------------

  // Register transformed IPIC bus input to address filter, which is necessary
  // for timing closure primarily due to long combinatorial address path.
  always @(posedge bus2ip_clk)
  begin
    if (bus2ip_reset) begin
      bus2ip_ce_int      <= 1'b0;
      bus2ip_rdce_int    <= 1'b0;
      bus2ip_rdce_re_int <= 1'b0;
      bus2ip_wrce_int    <= 1'b0;
      bus2ip_wrce_re_int <= 1'b0;
      bus2ip_addr_int    <= 0;
      bus2ip_data_int    <= 32'b0;
      bus2ip_sel_uc      <= 0;
    end

    else begin
      bus2ip_ce_int      <= bus2ip_ce_comb & bus2ip_ce;
      bus2ip_rdce_int    <= bus2ip_rdce_comb;
      bus2ip_rdce_re_int <= bus2ip_rdce_re;
      bus2ip_wrce_int    <= bus2ip_wrce_comb;
      bus2ip_wrce_re_int <= bus2ip_wrce_re;
      bus2ip_addr_int    <= bus2ip_addr_comb;
      bus2ip_data_int    <= bus2ip_data_comb;
      bus2ip_sel_uc      <= bus2ip_ce_local_comb & !bus2ip_addr[3];
    end
  end


  // --------------------------------------------------------------------------
  // Provide read/write access to memory-mapped registers
  // --------------------------------------------------------------------------

  // Decode the IPIC address bus, bits 7:4, since the upper bits are already
  // guaranteed to be correct, else the IPIF module wouldn't assert bus2ip_ce.
  // If bits 7:4 indicate an address between 0x700 and 0x70c, the user is
  // accessing registers present in this wrapper; hence generate a local enable.
  assign bus2ip_ce_local_comb = (bus2ip_addr[7:4] == 4'b0000) & bus2ip_ce;

  // IPIC reads of local memory-mapped registers
  always @(posedge bus2ip_clk)
  begin

    if (bus2ip_reset) begin
      ip2bus_data  <= 32'b0;
    end

    else if (bus2ip_ce_local_comb & bus2ip_rdce & bus2ip_addr[3]) begin
      case (bus2ip_addr[2])
        1'b0: ip2bus_data <= {promiscuous_mode_reg, 23'b0, gap_filler, af_select_reg[SELECT_BITS:0]}; // Only index 8 filters for now
        1'b1: ip2bus_data <= {31'b0, filter_enable_reg[af_select_reg[SELECT_BITS:0]]};          // Only enable 8 filters for now
      endcase
    end

    else begin
      ip2bus_data  <= ip2bus_data_int;
    end

  end

  // IPIC reads of local memory-mapped registers
  always @(posedge bus2ip_clk)
  begin

    if (bus2ip_reset) begin
      ip2bus_rdack <= 1'b0;
    end

    else if (bus2ip_ce_local_comb & bus2ip_rdce & bus2ip_addr[3]) begin
      ip2bus_rdack <= 1'b1;
    end

    else begin
      ip2bus_rdack <= ip2bus_rdack_int;
    end

  end

  generate
  if (c_has_host == 1) begin : addr_regs

    // IPIC writes to local memory-mapped registers
    always @(posedge bus2ip_clk)
    begin

      if (bus2ip_reset) begin
        promiscuous_mode_reg <= promiscuous_mode_init;
        af_select_reg        <= 0;
        filter_enable_reg    <= {(c_at_entries+1){1'b1}};  
      end

      else if (bus2ip_ce_local_comb & bus2ip_wrce & bus2ip_addr[3]) begin
        case (bus2ip_addr[2])
          1'b0: begin
                   promiscuous_mode_reg  <= bus2ip_data[31];
                   af_select_reg[SELECT_BITS:0]    <= bus2ip_data[SELECT_BITS:0];
                 end
          1'b1: filter_enable_reg[af_select_reg[SELECT_BITS:0]] <= bus2ip_data[0];
        endcase
      end
    end
    
    always @(posedge bus2ip_clk)
    begin

      if (bus2ip_reset) begin
        ip2bus_wrack         <= 1'b0;
      end

      else if (bus2ip_ce_local_comb & bus2ip_wrce & bus2ip_addr[3]) begin
        ip2bus_wrack <= 1'b1;
      end

      else begin
        ip2bus_wrack <= ip2bus_wrack_int;
      end

    end

  end
  else begin
     
     // set default values and ensure vector values are passed in
     always @(promiscuous_mode_init)
     begin
        promiscuous_mode_reg = promiscuous_mode_init;
        af_select_reg        = 0;
        filter_enable_reg    = 0;   // only the default address filter is enabled by default
        ip2bus_wrack         = 1'b0;
     end
     
  end
  endgenerate

  // No known error conditions in this module. Currently tying low by
  // assigning to the address_filter output, which is also low. If any
  // error conditions are identified, this needs to become a synchronous
  // output, in alignment with other ip2bus registered output signals.
  assign ip2bus_error = ip2bus_error_int;

  // --------------------------------------------------------------------------
  // Instantiation of the address filter, with decoded and transformed
  // IPIC address bus as required for its distributed RAM addressing.
  // --------------------------------------------------------------------------

  axi_ethernet_v3_01_a_v6_address_filter #(
    .c_at_entries             (c_at_entries),
    .c_has_host               (c_has_host), 
    .c_add_filter             (c_add_filter),
    .c_unicast_pause_address  (c_unicast_pause_address)
  ) address_filter_inst (

    // Clocks, clock enable and reset
    .rx_clk                   (rxcoreclk),
    .rx_clk_en                (rxclk_ce),
    .rx_sync_reset            (rx_sync_reset),

    // Input packets (before address filter)
    .rx_data                  (data_early),
    .rx_data_valid            (data_valid_early),
  //.rx_frame_good            (), // Unused in the current implementation
  //.rx_frame_bad             (), // Unused in the current implementation

    // Input addresses
    .promiscuous_mode         (promiscuous_mode_reg),
    .update_pause_ad          (update_pause_ad),
    .pause_addr               (rx_pause_addr),

    // Output packets (only packets with a maching address)
    .rx_filtered_data         (rx_filtered_data),
    .rx_filtered_data_valid   (rx_filtered_data_valid),
  //.rx_filtered_frame_good   (), // Unused in the current implementation
  //.rx_filtered_frame_bad    (), // Unused in the current implementation

    // Address match signals
    .unicastaddressmatch      (unicastaddressmatch),
    .broadcastaddressmatch    (broadcastaddressmatch),
    .pauseaddressmatch        (pauseaddressmatch),
    .specialpauseaddressmatch (specialpauseaddressmatch),
    .rxstatsaddressmatch      (rxstatsaddressmatch),
    .rx_filter_enable         (filter_enable_reg),
    .rx_filter_match          (rx_filter_match),

    // IPIC Interrface
    .bus2ip_clk               (bus2ip_clk),
    .bus2ip_reset             (bus2ip_reset),
    .bus2ip_sel_uc            (bus2ip_sel_uc),
    .bus2ip_ce                (bus2ip_ce_int),
    .bus2ip_rdce              (bus2ip_rdce_re_int),
    .bus2ip_wrce              (bus2ip_wrce_re_int),
    .ip2bus_rdack             (ip2bus_rdack_int),
    .ip2bus_wrack             (ip2bus_wrack_int),
    .bus2ip_addr              ({gap_filler32, bus2ip_addr_int}),
    .bus2ip_data              (bus2ip_data_int),
    .ip2bus_data              (ip2bus_data_int),
    .ip2bus_error             (ip2bus_error_int)

  );


endmodule
