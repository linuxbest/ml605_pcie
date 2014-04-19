// ifm_tb.v --- 
// 
// Filename: ifm_tb.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Tue Apr 15 00:14:13 2014 (-0700)
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
// 	internal version of wire port    : "*_i"
// 	device pins                        : "*_pin"
// 	ports                              : - Names begin with Uppercase
// Code:
`timescale 1ps/1ps
module ifm_tb;
   wire [63:0]	rxd_tdata;		// From axi_eth_ifm of axi_eth_ifm.v
   wire [7:0]	rxd_tkeep;		// From axi_eth_ifm of axi_eth_ifm.v
   wire		rxd_tlast;		// From axi_eth_ifm of axi_eth_ifm.v
   wire		rxd_tvalid;		// From axi_eth_ifm of axi_eth_ifm.v
   wire		rx_axis_mac_tready;	// From axi_eth_ifm of axi_eth_ifm.v

   wire		rxd_tready;
   assign       rxd_tready = 1'b1;

   wire [31:0]	rxs_tdata;		// From axi_eth_ifm of axi_eth_ifm.v
   wire [3:0]	rxs_tkeep;		// From axi_eth_ifm of axi_eth_ifm.v
   wire		rxs_tlast;		// From axi_eth_ifm of axi_eth_ifm.v
   wire		rxs_tvalid;		// From axi_eth_ifm of axi_eth_ifm.v

   wire		rxs_tready;
   assign       rxs_tready = 1'b1;

   reg [63:0] rx_axis_mac_tdata;
   reg [7:0]  rx_axis_mac_tkeep;
   reg 	      rx_axis_mac_tlast;
   reg 	      rx_axis_mac_tuser;
   reg 	      rx_axis_mac_tvalid;
   reg 	      rx_clk;
   reg 	      s2mm_clk;
   reg 	      rx_reset;
   reg        s2mm_resetn;

   initial begin
      rx_clk = 1'b0;
      forever #(1000) rx_clk = ~rx_clk;
   end
   initial begin
      s2mm_clk = 1'b0;
      forever #(5333)  s2mm_clk = ~s2mm_clk;
   end
   initial begin
      rx_reset = 1'b1;
      s2mm_resetn = 1'b0;
      #(10000) rx_reset = ~rx_reset;
      #(10000) s2mm_resetn = ~s2mm_resetn;      
   end

   reg [31:0] cnt;
   task send_packet;
      input good;
      input [31:0] num;
      begin
	  rx_axis_mac_tdata  = 0; rx_axis_mac_tkeep  = 0;
	  cnt = 0;
	 while (cnt != num)
	   begin
	      rx_axis_mac_tvalid = 1'b1;
	      rx_axis_mac_tdata[7:0]   = cnt*8;
	      rx_axis_mac_tdata[15:8]  = cnt*8 + 1;
	      rx_axis_mac_tdata[23:16] = cnt*8 + 2;
	      rx_axis_mac_tdata[31:24] = cnt*8 + 3;
	      rx_axis_mac_tdata[39:32] = cnt*8 + 4;
	      rx_axis_mac_tdata[47:40] = cnt*8 + 5;
	      rx_axis_mac_tdata[55:48] = cnt*8 + 6;
	      rx_axis_mac_tdata[63:56] = cnt*8 + 7;
	      rx_axis_mac_tkeep[7:0]   = 8'b1111_1111;
	      cnt = cnt + 1;
	      rx_axis_mac_tlast  = cnt == num;
	      rx_axis_mac_tuser  = cnt == num && good;
	      @(posedge rx_clk);
	   end
	 rx_axis_mac_tvalid = 1'b0;
	 rx_axis_mac_tuser  = 0;
	 rx_axis_mac_tlast  = 0;	 
	 @(posedge rx_clk);	 
      end
   endtask // axi_eth_ifm
   
   initial begin
      rx_axis_mac_tdata  = 0;
      rx_axis_mac_tkeep  = 0;
      rx_axis_mac_tvalid = 0;
      rx_axis_mac_tuser  = 0;
      rx_axis_mac_tlast  = 0;

      @(negedge rx_reset);
      @(posedge rx_clk);
      @(posedge rx_clk);
      @(posedge rx_clk);
      @(posedge rx_clk);
      
      send_packet(0, 200);
      send_packet(1, 10);

      @(posedge rx_clk);
      @(posedge rx_clk);
      s2mm_resetn = ~s2mm_resetn;
      @(posedge rx_clk);
      @(posedge rx_clk);
      @(posedge rx_clk);
      @(posedge rx_clk);
      @(posedge rx_clk);
      s2mm_resetn = ~s2mm_resetn;      
      
      send_packet(0, 23);
      send_packet(1, 11);      
      send_packet(0, 30);
      send_packet(0, 40);
      send_packet(1, 12);      
      send_packet(1, 13);      
      send_packet(1, 14);      
      send_packet(1, 15);      
      send_packet(0, 46);
      send_packet(1, 16);      
   end

   wire [31:0] ifm_in_fsm_dbg;
   wire [31:0] ifm_out_fsm_dbg;
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
			    .rxd_tready		(rxd_tready),
			    .rxs_tready		(rxs_tready),
			    .s2mm_clk		(s2mm_clk),
			    .s2mm_resetn	(s2mm_resetn));
   
endmodule // ifm_tb
// Local Variables:
// verilog-library-directories:(".""../")
// verilog-library-files:(".")
// verilog-library-extensions:(".v" ".h")
// End:
// 
// ifm_tb.v ends here
