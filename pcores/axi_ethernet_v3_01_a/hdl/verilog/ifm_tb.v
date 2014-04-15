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
module ifm_tb;
   wire [63:0]	mac_tdata;		// From axi_eth_ifm of axi_eth_ifm.v
   wire [7:0]	mac_tkeep;		// From axi_eth_ifm of axi_eth_ifm.v
   wire		mac_tlast;		// From axi_eth_ifm of axi_eth_ifm.v
   wire		mac_tvalid;		// From axi_eth_ifm of axi_eth_ifm.v
   wire		rx_axis_mac_tready;	// From axi_eth_ifm of axi_eth_ifm.v

   wire		mac_tready;
   assign       mac_tready = 1'b1;

   reg [63:0] rx_axis_mac_tdata;
   reg [7:0]  rx_axis_mac_tkeep;
   reg 	      rx_axis_mac_tlast;
   reg 	      rx_axis_mac_tuser;
   reg 	      rx_axis_mac_tvalid;
   reg 	      rx_clk;
   reg 	      sys_clk;
   reg 	      rx_reset;

   initial begin
      rx_clk = 1'b0;
      forever #(1000) rx_clk = ~rx_clk;
   end
   initial begin
      sys_clk = 1'b0;
      forever #(5333)  sys_clk = ~sys_clk;
   end
   initial begin
      rx_reset = 1'b1;
      #(10000) rx_reset = ~rx_reset;
   end

   task send_packet;
      input good;
      input [31:0] num;
      begin
	  rx_axis_mac_tdata  = 0; rx_axis_mac_tkeep  = 0;
	 while (num)
	   begin
	      rx_axis_mac_tvalid = 1'b1;
	      rx_axis_mac_tdata  = rx_axis_mac_tdata + 1;
	      rx_axis_mac_tkeep  = rx_axis_mac_tkeep + 1;
	      rx_axis_mac_tlast  = num == 1;
	      rx_axis_mac_tuser  = num == 1 && good;
	      num = num - 1;
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
      
      send_packet(1, 10);
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
   
   axi_eth_ifm axi_eth_ifm (/*AUTOINST*/
			    // Outputs
			    .mac_tdata		(mac_tdata[63:0]),
			    .mac_tkeep		(mac_tkeep[7:0]),
			    .mac_tlast		(mac_tlast),
			    .mac_tvalid		(mac_tvalid),
			    .rx_axis_mac_tready	(rx_axis_mac_tready),
			    // Inputs
			    .mac_tready		(mac_tready),
			    .rx_axis_mac_tdata	(rx_axis_mac_tdata[63:0]),
			    .rx_axis_mac_tkeep	(rx_axis_mac_tkeep[7:0]),
			    .rx_axis_mac_tlast	(rx_axis_mac_tlast),
			    .rx_axis_mac_tuser	(rx_axis_mac_tuser),
			    .rx_axis_mac_tvalid	(rx_axis_mac_tvalid),
			    .rx_clk		(rx_clk),
			    .rx_reset		(rx_reset),
			    .sys_clk		(sys_clk));
   
endmodule
// 
// ifm_tb.v ends here
