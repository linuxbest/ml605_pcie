//----------------------------------------------------------------------
// $Revision: 1.6 $
// $Date: 2010/12/06 10:43:28 $
//----------------------------------------------------------------------
// Title      : IPIC Microprocessor Interface to MAC/Stats Host I/F
// Project    : tri_mode_eth_mac
//----------------------------------------------------------------------
// File       : axi_ethernet_v3_01_a_v6_ipic_host_if.v
// Author     : Xilinx, Inc.
//----------------------------------------------------------------------
// Description: The MAC Host Interface was intended to be a generic
//              host interface which was easy to use.  But it isn't!
//              By nature of the different read/write protocols used to
//              access configuration, statistics, MDIO and the Address
//              Filter, the MAC Host I/F is difficult to use.
//
//              This file uses the IPIC interface which is truly generic
//              and which interfaces to the MAC Host I/F.  This will
//              allow a much easier interface to any other CPU interface
//              such as AXI.
//
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


module axi_ethernet_v3_01_a_v6_ipic_host_if 
#(
  parameter                            reg_mapped   = 0,
  parameter                            async        = 0,
  parameter                            c_tri_speed  = 0, 
  parameter                            c_speed_10   = 0, 
  parameter                            c_speed_100  = 0, 
  parameter                            c_speed_1000 = 1, 
  parameter                            c_has_mii         = 0,
  parameter                            c_has_gmii        = 1,
  parameter                            c_has_rgmii_v2_0  = 0,
  parameter                            c_has_stats       = 1,
  parameter                            c_add_filter      = 0
 // parameter                            link_timer_value  = 12'h13d
)(

  //--------------------------------------------------------------------
  // IPIC Interface
  //--------------------------------------------------------------------

  input [11:0]                         link_timer_value,
  input                                bus2ip_clk,
  input                                bus2ip_reset,
  
  // memory mapped controls
  input                                bus2ip_addrvalid,
  input                                bus2ip_cs,
  input                                bus2ip_rnw,
  output reg                           ip2bus_ack,
  // register mapped controls
  input                                bus2ip_ce,
  input                                bus2ip_rdce,
  input                                bus2ip_wrce,
  output reg                           ip2bus_wrack,
  output reg                           ip2bus_rdack,
  
  input [31:0]                         bus2ip_addr,
  input [31:0]                         bus2ip_data,
  output reg [31:0]                    ip2bus_data,
  output reg                           ip2bus_error,
  output reg                           ip2bus_tousup,   
  
  //--------------------------------------------------------------------
  // mode control
  //--------------------------------------------------------------------
  
  input                                base_x_switch,

  //--------------------------------------------------------------------
  // local registers
  //--------------------------------------------------------------------
  
  input      [47:0]                    tie_pause_addr,
  output reg [47:0]                    pause_addr,
  output reg                           update_pause_addr,
  output reg                           tx_soft_reset,
  output reg                           rx_soft_reset,
  
  //--------------------------------------------------------------------
  // Ethernet MAC Host Interface
  //--------------------------------------------------------------------

  input                                host_clk,
  input                                host_reset,
  output reg  [1:0]                    host_opcode,
  output      [9:0]                    host_addr,
  output reg [31:0]                    host_wr_data,
  output reg                           host_req,
  output reg                           host_miim_sel,
  input      [31:0]                    host_rd_data_mac,
  input                                host_miim_rdy,
  
  output wire                          temac_intr

);


  //--------------------------------------------------------------------
  // Internal signals used in this module.
  //--------------------------------------------------------------------

  reg                                  wr_toggle;
  reg                                  rd_toggle;
  wire                                 wr_toggle_host;
  wire                                 rd_toggle_host;
  reg                                  wr_toggle_host_reg;
  reg                                  rd_toggle_host_reg;
  reg                                  host_toggle;
  reg                                  host_toggle_reg1;
  reg                                  host_toggle_reg2;
  wire                                 host_toggle_cpu;
  reg                                  host_toggle_cpu_reg;
  
  reg                                  host_complete_reg;
  reg                                  host_complete_reg1;
  
  wire                                 new_rd;
  wire                                 new_wr;
  reg                                  new_rd_reg;
  reg                                  new_wr_reg;
  reg  [9:0]                           host_address;
  reg                                  host_miim_rdy_reg;
  reg  [31:0]                          host_stats_msw;
  reg  [31:0]                          host_stats_lsw;
  reg  [31:0]                          host_rd_data_result;
  reg                                  ip2bus_data_en;
  reg                                  bus2ip_cs_reg;
  
  reg  [15:0]                          mdio_wr_data;
  reg  [11:0]                          mdio_info;
  reg  [1:0]                           af_select;
  reg  [31:0]                          af_config_lw;
  reg  [15:0]                          af_config_uw;
  reg                                  af_write;
  reg                                  stats_read_lo;
  reg                                  stats_read_hi;
  reg                                  mdio_ctrl_rd;
  reg                                  mdio_wrdata_rd;
  reg                                  mdio_rddata_rd;
  reg                                  af_select_rd;
  reg                                  af_read_high;
  reg  [31:0]                          host_rd_data_int;
  wire                                 bus2ip_cs_int;
  reg                                  ability_rd_en;
  reg                                  version_rd_en;
  reg                                  intr_rd_st;
  reg                                  intr_rd_pen;
  reg                                  intr_rd_en;
  reg                                  intr_status;
  reg                                  intr_enable;
  reg                                  intr_clear;
  reg                                  intr_ignore;
  wire                                 host_complete;
  wire                                 host_capture;
  wire                                 host_ack;
  
  reg                                  base_x_switch_r;
  reg                                  base_x_switch_r2;
  wire [8:0]                           new_link_timer_val;
  reg                                  request_switch;
  reg                                  request_sent;
  reg                                  complete_switch;
  


  localparam VERSION = {8'h2, 8'h2, 8'h0, 8'h0};
  localparam ABILITY = {21'd0,
                        (c_add_filter == 1),
                        ((c_has_mii == 1) || (((c_has_gmii == 1) || (c_has_rgmii_v2_0 == 1)) && (c_tri_speed == 1))),
                        (c_has_stats == 1),
                        5'b00000,
                        ((c_tri_speed == 1) || (c_speed_1000 == 1)),
                        ((c_tri_speed == 1) || (c_speed_100 == 1)),
                        ((c_tri_speed == 1) || (c_speed_10 == 1))};



  // depending upon the region we need to act differently:
  // 0x200-0x3ff : stats - bit 2 low - perform host read return lsw
  //                       bit 2 high - perform host read return msw
  // 0x400-0x410 : remap new locations onto old addresses or capture info
  // these are all direct host accesses
  //     0x400 => 0x200
  //     0x404 => 0x240
  //     0x408 => 0x280
  //     0x40C => 0x2C0
  //     0x410 => 0x300
  //     0x414 => 0x320
  // 0x500-0x50c : MDIO interface
  //     detect and generate MDIO accesses
  // 0x600 : Interrupt registers 
  //     0x600 main enable
  //     0x610 mask (ignore)
  //     0x620 status
  // 0x700 => 0x380
  // 0x704 => 0x384
  // 0x708 => 0x390 & capture filter address
  // 0x710 => 0x388
  // 0x714 => 0x38C & decode read/write and include filter address
  // 0x718-> No equivalent - ignore and ack

  //--------------------------------------------------------------------
  // Resynchronise onto host_clk
  //--------------------------------------------------------------------

generate
  if (reg_mapped == 0) begin

   // Create generate a pulse for the cs
   always @(posedge bus2ip_clk)
   begin
     if (bus2ip_reset) begin
       bus2ip_cs_reg <= 1'b0;
     end
     else if ((bus2ip_cs & !request_switch) | !bus2ip_cs) begin
       bus2ip_cs_reg <= bus2ip_cs;
     end
   end

   assign bus2ip_cs_int = bus2ip_cs & !bus2ip_cs_reg & bus2ip_addrvalid;
  
  end
  else begin 
  
   // Create generate a pulse for the ce
   always @(posedge bus2ip_clk)
   begin
     if (bus2ip_reset) begin
       bus2ip_cs_reg <= 1'b0;
     end
     else if ((bus2ip_ce & !request_switch) | !bus2ip_ce) begin
       bus2ip_cs_reg <= bus2ip_ce;
     end
   end

   assign bus2ip_cs_int = bus2ip_ce & !bus2ip_cs_reg;
   
  end
endgenerate


generate
  if (reg_mapped == 0 & async == 1) begin

   // Create a toggle for every write request
   always @(posedge bus2ip_clk)
   begin
     if (bus2ip_reset) begin
       wr_toggle <= 1'b0;
     end
     else if (!bus2ip_rnw & bus2ip_cs_int) begin
       wr_toggle <= !wr_toggle;
     end
   end
  
   // Create a toggle for every read request
   always @(posedge bus2ip_clk)
   begin
     if (bus2ip_reset) begin
       rd_toggle <= 1'b0;
     end
     else if (bus2ip_rnw & bus2ip_cs_int) begin
       rd_toggle <= !rd_toggle;
     end
   end
  
  end
  else if (async == 1) begin 
  
   // Create a toggle for every write request
   always @(posedge bus2ip_clk)
   begin
     if (bus2ip_reset) begin
       wr_toggle <= 1'b0;
     end
     else if (bus2ip_wrce & bus2ip_cs_int) begin
       wr_toggle <= !wr_toggle;
     end
   end
  
   // Create a toggle for every read request
   always @(posedge bus2ip_clk)
   begin
     if (bus2ip_reset) begin
       rd_toggle <= 1'b0;
     end
     else if (bus2ip_rdce & bus2ip_cs_int) begin
       rd_toggle <= !rd_toggle;
     end
   end
  
  end
endgenerate

generate
  if (async == 1) begin
   // Resynchronise the write toggle into host_clk domain
   axi_ethernet_v3_01_a_sync_block resync_write_toggle
   (
     .clk       (host_clk),
     .data_in   (wr_toggle),
     .data_out  (wr_toggle_host)
   );

   // Resynchronise the read toggle into host_clk domain
   axi_ethernet_v3_01_a_sync_block resync_read_toggle
   (
     .clk       (host_clk),
     .data_in   (rd_toggle),
     .data_out  (rd_toggle_host)
   );


   // Register read and write reclocked toggles

   always @(posedge host_clk)
   begin
     if (host_reset) begin
       wr_toggle_host_reg <= 1'b0;
       rd_toggle_host_reg <= 1'b0;
     end

     else begin
       wr_toggle_host_reg <= wr_toggle_host;
       rd_toggle_host_reg <= rd_toggle_host;
     end

   end

   // Create new write and read pulses
   assign new_wr = (wr_toggle_host ^ wr_toggle_host_reg);
   assign new_rd = (rd_toggle_host ^ rd_toggle_host_reg);
   
  end
  else if (reg_mapped == 0) begin
  
   assign new_wr = !bus2ip_rnw & bus2ip_cs_int;
   assign new_rd = bus2ip_rnw & bus2ip_cs_int;
  
  end
  else if (reg_mapped == 1) begin
  
   assign new_wr = bus2ip_wrce & bus2ip_cs_int;
   assign new_rd = bus2ip_rdce & bus2ip_cs_int;
   
  end
endgenerate


  // Register new write and read pulses

  always @(posedge host_clk)
  begin
    if (host_reset) begin
      new_wr_reg  <= 1'b0;
      new_rd_reg  <= 1'b0;
    end

    else begin
      new_wr_reg  <= new_wr;
      new_rd_reg  <= new_rd;
    end

  end



  //--------------------------------------------------------------------
  // Translate transactions onto MAC Host Bus
  //--------------------------------------------------------------------

  // Sample Address and Data onto MAC Host Bus.

  // Confused with addressing?
  // Here we ignore the bottom 2 address bits of bus2ip_addr because the
  // IPIC addresses bytes NOT words.  Since each MAC word is fit into a
  // single 32-bit IPIC word for simplicity, when addressing a word,
  // bus2ip_addr bit 2 and upwards will change. (bus2ip_addr[1:0] would
  // address individual bytes within the 32-bit word).
  // address translation is a bit more complicated
  always @(posedge host_clk)
  begin
    if (host_reset) begin
      host_miim_sel      <=  1'b0;
      host_address[9:0]  <= 10'b0;
      host_opcode        <= 2'b10;  // read
      host_wr_data       <= 32'b0;
      host_req           <= 1'b0;
    end

    // Sample
    else if (new_wr | new_rd) begin
      // default (avoids repeating this too often)
      host_req          <= 1'b0;
      host_miim_sel     <= 1'b0;
      host_address[9:0] <= 10'h3C0;  // doesn't appear to be defined?            
      host_opcode       <= 2'b10;    // dummy read
      host_wr_data      <= bus2ip_data[31:0];   
            
      // MAC config registers
      if (bus2ip_addr[11:8] == 4'b0100) begin
         if (bus2ip_addr[7:5] == 3'b000 & 
             (bus2ip_addr[4:2] == 3'b100 | !bus2ip_addr[4])) begin 
            // direct remap of the address
            host_address[9:0]    <= {1'b1, bus2ip_addr[4:2], 6'b000000};          
            host_opcode          <= {new_rd, new_wr}; 
         end
         // code for the 0x320 register map from 420
         else if (bus2ip_addr[7:5] == 3'b001 & 
             (bus2ip_addr[4:2] == 3'b000)) begin 
            // direct remap of the address
            host_address[9:0]    <= {2'b11, bus2ip_addr[3:2], 6'b100000};          
            host_opcode          <= {new_rd, new_wr}; 
         end
      end
      // MDIO features - need to perform a host access for first reg at 500?
      else if (bus2ip_addr[11:8] == 4'b0101) begin
         if (bus2ip_addr[7:2] == 6'b000000) begin
            host_address[9:0]    <= 10'h340;            
            host_opcode          <= {new_rd, new_wr}; 
         end
         else if (bus2ip_addr[7:2] == 6'b000001) begin
            // this is the mdio control register - if written AND the initiate bit is set then
            // perform an mdio access otherwise just do a dummy read to host and return required data
            if (new_wr & bus2ip_data[11]) begin  // should we also check Ready is active??
               host_req             <= 1'b1;
               host_miim_sel        <= 1'b1;
               host_address[9:5]    <= bus2ip_data[28:24];            
               host_address[4:0]    <= bus2ip_data[20:16];            
               host_opcode          <= bus2ip_data[15:14]; 
               host_wr_data         <= {bus2ip_data[31:16], mdio_wr_data};   
            end
         end
         else if (new_rd) begin
            host_address[9]         <= 1'b0;
            host_miim_sel           <= 1'b1;
         end
      end
    end
    else if (request_sent) begin
      complete_switch   <= 1'b1;
      host_req          <= 1'b0;
      host_miim_sel     <= 1'b0;
      host_address[9:0] <= 10'h300;            
      host_opcode       <= 2'b01;
      host_wr_data      <= {2'b10, 1'b0, ~base_x_switch_r2, base_x_switch_r2, 1'b1, 17'd0, new_link_timer_val};   
    end
    // can only enter this once the access has completed
    else begin
       // just respond with zero's/ack
       complete_switch      <= 1'b0;
       host_miim_sel        <= 1'b0;
       host_address[9:0]    <= 10'h3C0;  // doesn't appear to be defined?            
       host_opcode          <= 2'b10;   // dummy read
       host_req             <= 1'b0;
       // by default set wr_data to that required for bas x switch update
       // shouldn't matter as ignored 
      host_wr_data      <= {2'b10, 1'b0, ~base_x_switch_r2, base_x_switch_r2, 1'b1, 17'd0, new_link_timer_val};   
    end

  end


// capture non legacy register contents 
// and replicate register if required
  always @(posedge host_clk)
  begin
    if (host_reset) begin
      mdio_wr_data      <= 16'b0;
      mdio_info         <= 12'b0;
      pause_addr        <= tie_pause_addr;
      update_pause_addr <= 0;
    end

    // Sample
    else if (new_wr) begin
       
       if (bus2ip_addr[11:2] == 10'b0101000001) begin
             mdio_info         <= {bus2ip_data[28:24], bus2ip_data[20:16], bus2ip_data[15:14]};
       end
       if (bus2ip_addr[11:2] == 10'b0101000010) begin
             mdio_wr_data      <= bus2ip_data[15:0];
       end
       if (bus2ip_addr[11:2] == 10'b0100000000) begin
             pause_addr[31:0]  <= bus2ip_data[31:0];
       end
       if (bus2ip_addr[11:2] == 10'b0100000001) begin
             pause_addr[47:32] <= bus2ip_data[15:0];
             update_pause_addr <= !update_pause_addr;
       end
    end
  end
  
// replicate soft reset
  always @(posedge host_clk)
  begin
    if (host_reset) begin
      rx_soft_reset     <= 1'b0;
    end

    // Sample
    else if (new_wr) begin
       
       if (bus2ip_addr[11:2] == 10'b0100000001) begin
             rx_soft_reset     <= bus2ip_data[31];
       end
    end
    else begin
          rx_soft_reset     <= 0;
    end
  end
  
// replicate soft reset
  always @(posedge host_clk)
  begin
    if (host_reset) begin
      tx_soft_reset     <= 1'b0;
    end

    // Sample
    else if (new_wr) begin
       
       if (bus2ip_addr[11:2] == 10'b0100000010) begin
             tx_soft_reset     <= bus2ip_data[31];
       end
    end
    else begin
          tx_soft_reset     <= 0;
    end
  end
  
// decode read accesses to non-legacy registers (as these have to be constructed locally)
  always @(posedge host_clk)
  begin
    if (host_reset) begin
      mdio_ctrl_rd      <= 1'b0;
      mdio_wrdata_rd    <= 1'b0;
      mdio_rddata_rd    <= 1'b0;
      intr_rd_st        <= 1'b0;
      intr_rd_pen       <= 1'b0;
      intr_rd_en        <= 1'b0;
      ability_rd_en     <= 1'b0;
      version_rd_en     <= 1'b0;
    end

    // if a read is taking place we want to remember which data should be returned
    // until the entire transaction completes - may as well decode as early as possible
    // to allow multicycle path if required
    // any new memory map only registers HAVE to be decoded so the appropriate response
    // can be generated
    else if (new_rd) begin
       // set defaults to ensure they clear..
       mdio_ctrl_rd      <= 1'b0;
       mdio_wrdata_rd    <= 1'b0;
       mdio_rddata_rd    <= 1'b0;
       intr_rd_en        <= 1'b0;
       intr_rd_pen       <= 1'b0;
       intr_rd_st        <= 1'b0;
       ability_rd_en     <= 1'b0;
       version_rd_en     <= 1'b0;
       if (bus2ip_addr[11:2] == 10'b0101000001) begin
          mdio_ctrl_rd         <= 1'b1;
       end
       if (bus2ip_addr[11:2] == 10'b0101000010) begin
          mdio_wrdata_rd       <= 1'b1;
       end
       if (bus2ip_addr[11:2] == 10'b0101000011) begin
          mdio_rddata_rd       <= 1'b1;
       end
       if (bus2ip_addr[11:2] == 10'b0110000000) begin
          intr_rd_st           <= 1'b1;
       end
       if (bus2ip_addr[11:2] == 10'b0110000100) begin
          intr_rd_pen          <= 1'b1;
       end
       if (bus2ip_addr[11:2] == 10'b0110001000) begin
          intr_rd_en           <= 1'b1;
       end
       if (bus2ip_addr[11:2] == 10'b0100111110) begin
          version_rd_en         <= 1'b1;
       end
       if (bus2ip_addr[11:2] == 10'b0100111111) begin
          ability_rd_en         <= 1'b1;
       end
    end
    else if (host_complete) begin
       mdio_ctrl_rd      <= 1'b0;
       mdio_wrdata_rd    <= 1'b0;
       mdio_rddata_rd    <= 1'b0;
       intr_rd_en        <= 1'b0;
       intr_rd_pen       <= 1'b0;
       intr_rd_st        <= 1'b0;
       ability_rd_en     <= 1'b0;
       version_rd_en     <= 1'b0;
    end
  end
  
  // generate an include to ignore mdio_ready being set first time 
  // (as this occurs when mdio is enabled)
  always @(posedge host_clk)
  begin
     if (host_reset) begin
        intr_ignore        <= 1'b1;
     end
     else if (!host_miim_rdy & host_miim_rdy_reg) begin
        intr_ignore     <= 1'b0;
     end
  end
  
  // implement interrupt enable (620) 
  always @(posedge host_clk)
  begin
     if (host_reset) begin
        intr_enable        <= 1'b1;
     end
     else if (new_wr & bus2ip_addr[11:2] == 10'b0110001000) begin
        intr_enable     <= bus2ip_data[0];
     end
  end
  
  // implement interrupt status etc
  always @(posedge host_clk)
  begin
     if (host_reset) begin
        intr_status        <= 1'b0;
     end
     else begin
        // Status (600)
        if (new_wr & bus2ip_addr[11:2] == 10'b0110000000) begin
           intr_status     <= bus2ip_data[0];
        end
        else begin
           // status should be set if MDIO ready is asserted - only on rising edge
           if (host_miim_rdy & !host_miim_rdy_reg & !intr_ignore)
              intr_status  <= 1'b1;
           else 
              intr_status <= intr_status & ~intr_clear;
        end
     end
  end
  
  // implement interrupt status etc
  always @(posedge host_clk)
  begin
     if (host_reset) begin
        intr_clear         <= 1'b1;
     end
     else begin
        // Clear (630) has to self clear after being written
        if (new_wr & bus2ip_addr[11:2] == 10'b0110001100) begin
           intr_clear     <= bus2ip_data[0];
        end
        else begin
           intr_clear     <= 0;
        end
     end
  end
  
  // generate the interrupt output - this is currently just a comb of the enable and status
  assign temac_intr = intr_status & intr_enable;      
  

  // host_address is an internal signal: assign to output
  assign host_addr = host_address;


generate
  if (async == 1) begin  
   // Create a toggle to acknowledge the completion of all transactions

   always @(posedge host_clk)
   begin
     if (host_reset) begin
       host_miim_rdy_reg <= 1'b0;
       host_toggle       <= 1'b0;
       host_toggle_reg1  <= 1'b0;
       host_toggle_reg2  <= 1'b0;
     end

     else begin

       host_miim_rdy_reg <= host_miim_rdy;

       // write or read MAC configuration
       if (((new_wr_reg | new_rd_reg) & 
            ((!host_miim_sel & host_address[9]) | host_miim_sel))) begin
          host_toggle <= !host_toggle;
       end

       // need an extra cycle on an af read as well as stats
       if (((new_wr_reg | new_rd_reg) &
            ((!host_miim_sel & host_address[9]) | host_miim_sel))) begin
          host_toggle_reg1 <= !host_toggle;  // skip a stage
       end
       else begin
          host_toggle_reg1 <= host_toggle;
       end

       host_toggle_reg2 <= host_toggle_reg1;

     end
   end

   assign host_complete = host_toggle_reg1 ^ host_toggle_reg2;
  end
  else begin
   // Create a toggle to acknowledge the completion of all transactions

   always @(posedge host_clk)
   begin
     if (host_reset) begin
       host_miim_rdy_reg <= 1'b0;
       host_complete_reg <= 1'b0;
     end

     else begin

       host_miim_rdy_reg <= host_miim_rdy;

       // write or read MAC configuration
       if (((new_wr_reg | new_rd_reg) & 
            ((!host_miim_sel & host_address[9]) | host_miim_sel))) begin
          host_complete_reg <= 1'b1;
       end
       else begin
          host_complete_reg <= 1'b0;
       end

       if (host_complete_reg)
         host_complete_reg1 <= 1'b1;
       else 
         host_complete_reg1 <= 1'b0;

     end
   end

   assign host_capture = host_complete_reg;
   assign host_complete = host_complete_reg1;
   
  end
endgenerate


  // Sample Read Data onto Host Bus - need to handle this more carefully to allow for 
  // expected responses from new registers
  // MAC config is covered by standard accesses
  // MDIO - first reg is ok 504-50c need handled
  // mdio_ctrl_rd     
  // mdio_wrdata_rd   
  // mdio_rddata_rd   

  always @(mdio_ctrl_rd or mdio_wrdata_rd or mdio_rddata_rd or mdio_info or 
          host_miim_rdy or host_rd_data_mac or mdio_wr_data or host_rd_data_mac or
          intr_rd_en or intr_rd_pen or intr_rd_st or intr_enable or intr_status or
          version_rd_en or ability_rd_en)
  begin
     // Read MAC/AF data
     if (mdio_ctrl_rd) begin
       host_rd_data_int = {3'b000, mdio_info[11:7], 3'b000, mdio_info[6:0], 6'h0, host_miim_rdy, 7'h0};
     end
     else if (mdio_wrdata_rd) begin
       host_rd_data_int = {16'h0000, mdio_wr_data};
     end
     else if (mdio_rddata_rd) begin
       host_rd_data_int = {15'h0000, host_miim_rdy, host_rd_data_mac[15:0]};
     end
     else if (intr_rd_st) begin
       host_rd_data_int = {31'd0, intr_status};
     end
     else if (intr_rd_pen) begin
       host_rd_data_int = {31'd0, intr_enable & intr_status};
     end
     else if (intr_rd_en) begin
       host_rd_data_int = {31'd0, intr_enable};
     end
     else if (version_rd_en) begin
       host_rd_data_int = VERSION;
     end
     else if (ability_rd_en) begin
       host_rd_data_int = ABILITY;
     end
     else begin
       host_rd_data_int = host_rd_data_mac;
     end
  end

generate
  if (async == 1) begin
  
    always @(posedge host_clk)
    begin
      if (host_reset) begin
        host_rd_data_result <= 32'b0;
      end

      else if (host_complete) begin
         host_rd_data_result <= host_rd_data_int;
      end
   end

   //--------------------------------------------------------------------
   // Translate transactions back onto Generic Bus
   //--------------------------------------------------------------------


   // Resynchronise the host toggle into bus2ip_clk domain
   axi_ethernet_v3_01_a_sync_block resync_host_toggle
   (
     .clk       (bus2ip_clk),
     .data_in   (host_toggle_reg2),
     .data_out  (host_toggle_cpu)
   );
  
   always @(posedge bus2ip_clk)
   begin
     if (bus2ip_reset) begin
       host_toggle_cpu_reg    <= 1'b0;
     end
     else begin
       host_toggle_cpu_reg    <= host_toggle_cpu;
     end
   end

   assign host_ack = host_toggle_cpu ^ host_toggle_cpu_reg;

  end
  else begin
  
    always @(posedge host_clk)
    begin
      if (host_reset) begin
        host_rd_data_result <= 32'b0;
      end

      else if (host_capture) begin
         host_rd_data_result <= host_rd_data_int;
      end
   end

   assign host_ack = host_complete;
   
  end
endgenerate



generate
  if (reg_mapped == 0) begin
  
  // Register host reclocked toggle
   always @(posedge bus2ip_clk)
   begin
     if (bus2ip_reset) begin
       ip2bus_ack             <= 1'b0;
       ip2bus_rdack           <= 1'b0;
       ip2bus_wrack           <= 1'b0;
     end
     else begin
       ip2bus_ack             <= host_ack;
     end
   end

   // Create an enable signal for driving data onto the ip2bus_data bus

   always @(posedge bus2ip_clk)
   begin
     if (bus2ip_reset) begin
       ip2bus_data_en <= 1'b0;
     end
     else begin
       if (bus2ip_rnw & bus2ip_cs) begin
         ip2bus_data_en <= 1'b1;
       end
       else if (host_ack) begin
         ip2bus_data_en <= 1'b0;
       end
     end
   end

  end
  else begin
   // the rd/wr ce timing requires it to be maintained throughout the transfer so 
   // they can be used to assert the correct ack
   always @(posedge bus2ip_clk)
   begin
     if (bus2ip_reset) begin
       ip2bus_ack              <= 1'b0;
       ip2bus_rdack            <= 1'b0;
       ip2bus_wrack            <= 1'b0;
       ip2bus_error            <= 1'b0;
     end
     else begin
       ip2bus_rdack            <= bus2ip_rdce & (host_ack);
       ip2bus_wrack            <= bus2ip_wrce & (host_ack);
     end
   end
  
   // Create an enable signal for driving data onto the ip2bus_data bus

   always @(posedge bus2ip_clk)
   begin
     if (bus2ip_reset) begin
       ip2bus_data_en <= 1'b0;
     end
     else begin
       if (bus2ip_rdce & bus2ip_ce) begin
         ip2bus_data_en <= 1'b1;
       end
       else if (host_ack) begin
         ip2bus_data_en <= 1'b0;
       end
     end
   end

  end
endgenerate



  // Sample Read Data onto generic CPU Bus
  always @(posedge bus2ip_clk)
  begin
    if (bus2ip_reset) begin
      ip2bus_data <= 32'b0;
    end
    else begin
      if (ip2bus_data_en & (host_ack)) begin
        ip2bus_data <= host_rd_data_result;
      end
      else begin
        ip2bus_data <= 32'b0;
      end
    end
  end
  
  //--------------------------------------------------
  // control the base_x_switch - coded assuming clock domains are common
  //--------------------------------------------------
    
  // first register the input
  always @(posedge bus2ip_clk)
  begin
     if (bus2ip_reset) begin
        base_x_switch_r    <= 0;
        base_x_switch_r2   <= 0;
     end
     else begin
        base_x_switch_r    <= base_x_switch;
        base_x_switch_r2   <= base_x_switch_r;
     end
  end

   assign new_link_timer_val = base_x_switch_r2 ? 9'h13d : link_timer_value[8:0];
   
  // when an edge is detected we want to request access to the host - if an access is in progress
  // then stall - otherwise continue and hold off external host accesses
  always @(posedge bus2ip_clk)
  begin
     if (bus2ip_reset) begin
        request_switch <= 0;
        request_sent   <= 0;
     end
     else begin
        if (base_x_switch_r2 ^ base_x_switch_r) begin
           request_switch <= 1;
        end
        else if (complete_switch) begin
           request_switch <= 0;
        end
        if (request_switch & !bus2ip_cs_reg) begin
           request_sent   <= 1;
        end
        else begin
           request_sent   <= 0;
        end
     end
  end

endmodule
