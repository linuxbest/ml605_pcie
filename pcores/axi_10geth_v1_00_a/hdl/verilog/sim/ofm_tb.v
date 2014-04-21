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
module ofm_tb;

   wire tx_axis_mac_tready;
   assign tx_axis_mac_tready = 1'b1;

   wire [63:0] tx_axis_mac_tdata;	// From axi_eth_ofm of axi_eth_ofm.v
   wire [7:0]  tx_axis_mac_tkeep;	// From axi_eth_ofm of axi_eth_ofm.v
   wire        tx_axis_mac_tlast;	// From axi_eth_ofm of axi_eth_ofm.v
   wire        tx_axis_mac_tuser;	// From axi_eth_ofm of axi_eth_ofm.v
   wire        tx_axis_mac_tvalid;	// From axi_eth_ofm of axi_eth_ofm.v
   
   wire [31:0] txc_tdata;
   wire [3:0]  txc_tkeep;
   wire        txc_tlast;
   wire        txc_tvalid;
   wire        txc_tready;
   
   wire [63:0] txd_tdata;
   wire [7:0]  txd_tkeep;
   wire        txd_tlast;
   wire        txd_tvalid;
   wire        txd_tready;
   
   reg 	      tx_clk;
   reg 	      mm2s_clk;
   reg        sys_rst;
   
   initial begin
      tx_clk = 1'b0;
      forever #(1000) tx_clk = ~tx_clk;
   end
   initial begin
      mm2s_clk = 1'b0;
      forever #(5333)  mm2s_clk = ~mm2s_clk;
   end
   initial begin
      sys_rst  = 1'b1;
      #(10000) sys_rst  = ~sys_rst;
   end

   reg [72:0] data_fifo_wdata;
   reg 	      data_fifo_wren;
   wire       data_fifo_afull;
   
   reg [36:0] ctrl_fifo_wdata;
   reg 	      ctrl_fifo_wren;
   wire       ctrl_fifo_afull;

   reg [15:0]  cnt;
   task send_packet;
      input [1:0]  CsCntrl;
      input [15:0] CsBegin;
      input [15:0] CsInsert;
      input [15:0] CsInit;
      input [15:0] num;
      begin
	 ctrl_fifo_wren  = 0;
	 ctrl_fifo_wdata = 0;
	 data_fifo_wren  = 0;
	 data_fifo_wdata = 0;
 	 while (ctrl_fifo_afull && data_fifo_afull)
	   @(posedge tx_clk);

	 cnt = 0;
	 while (cnt != 6)
	   begin
	      ctrl_fifo_wren  = 1;
	      ctrl_fifo_wdata = 0;
	      ctrl_fifo_wdata[35:32] = cnt;
	      case (cnt)
		0: ctrl_fifo_wdata[31:28] = 4'ha;
		1: ctrl_fifo_wdata[1:0]   = CsCntrl;
		2: begin 
		   ctrl_fifo_wdata[15:0]  = CsInsert; 
		   ctrl_fifo_wdata[31:16] = CsBegin;
		end
		3: ctrl_fifo_wdata[15:0]  = CsInit;
		5: ctrl_fifo_wdata[36]    = 1'b1; // EOF
	      endcase
	      cnt = cnt + 1;
	      @(posedge mm2s_clk);
	   end // while (cnt != 5)
	 
	 ctrl_fifo_wren  = 0;
	 ctrl_fifo_wdata = 0;
	 cnt = 0;
	 while (cnt != num)
	   begin
	      data_fifo_wren  = 1;
	      data_fifo_wdata[7:0]   = cnt*8;
	      data_fifo_wdata[15:8]  = cnt*8 + 1;
	      data_fifo_wdata[23:16] = cnt*8 + 2;
	      data_fifo_wdata[31:24] = cnt*8 + 3;
	      data_fifo_wdata[39:32] = cnt*8 + 4;
	      data_fifo_wdata[47:40] = cnt*8 + 5;
	      data_fifo_wdata[55:48] = cnt*8 + 6;
	      data_fifo_wdata[63:56] = cnt*8 + 7;
	      data_fifo_wdata[71:64] = 8'b1111_1111;
	      cnt = cnt + 1;
	      data_fifo_wdata[72] = cnt == num;
	      if (data_fifo_wdata[72]) data_fifo_wdata[71] = 1'b0;
	      @(posedge mm2s_clk);
	   end
	 
	 data_fifo_wdata = 0;
	 data_fifo_wren  = 0;
	 @(posedge mm2s_clk);	 
      end
   endtask // axi_eth_ifm
/*
 * 19:42:38.032398 IP (tos 0x10, ttl 64, id 27210, offset 0, flags [DF], proto TCP (6), length 60)
 *   192.168.101.50.43921 > 192.168.101.60.ssh: Flags [S], cksum 0x4bee (incorrect -> 0x890d), seq \
 *      572719365, win 14600, options [mss 1460,sackOK,TS val 813903 ecr 0,nop,wscale 7], length 0
 *      0x0000:  4510 003c 6a4a 4000 4006 84a2 c0a8 6532  E..<jJ@.@.....e2
 *      0x0010:  c0a8 653c ab91 0016 2223 0105 0000 0000  ..e<...."#......
 *      0x0020:  a002 3908 4bee 0000 0204 05b4 0402 080a  ..9.K...........
 *      0x0030:  000c 6b4f 0000 0000 0103 0307            ..kO........
 */
   task send_packet_tcp1;
      begin
	 ctrl_fifo_wren  = 0;
	 ctrl_fifo_wdata = 0;
	 data_fifo_wren  = 0;
	 data_fifo_wdata = 0;
 	 while (ctrl_fifo_afull && data_fifo_afull)
	   @(posedge tx_clk);

	 cnt = 0;
	 while (cnt != 6)
	   begin
	      ctrl_fifo_wren  = 1;
	      ctrl_fifo_wdata = 0;
	      ctrl_fifo_wdata[35:32] = 4'hf;
	      case (cnt)
		0: ctrl_fifo_wdata[31:28] = 4'ha;
		1: ctrl_fifo_wdata[1:0]   = 2'b01;
		2: begin 
		   ctrl_fifo_wdata[15:0]  = 16'h32; 
		   ctrl_fifo_wdata[31:16] = 16'h22;
		end
		3: ctrl_fifo_wdata[15:0]  = 16'h00;
		5: ctrl_fifo_wdata[36]    = 1'b1; // EOF
	      endcase
	      cnt = cnt + 1;
	      @(posedge mm2s_clk);
	   end // while (cnt != 5)
	 
	 ctrl_fifo_wren  = 0;
	 ctrl_fifo_wdata = 0;
	 data_fifo_wren  = 1;
	 data_fifo_wdata[71:64] = 8'b1111_1111;
	 data_fifo_wdata[63:0]  = 64'he40a80df_16bae290; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'h10450008_235224e3; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'h06400040_4a6a3c00; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'ha8c03265_a8c0a284; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'h23221600_91ab3c65; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'h02a00000_00000501; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'h04020000_ee4b0839; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'h0c000a08_0204b405; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'h03010000_00004f6b; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'h00000000_00000703; 
	 data_fifo_wdata[71:64] = 8'b0000_0011; 
	 data_fifo_wdata[72]    = 1'b1;
	 @(posedge mm2s_clk);

	 data_fifo_wdata = 0;
	 data_fifo_wren  = 0;
	 @(posedge mm2s_clk);	 
      end
   endtask // axi_eth_ifm
/*
 * 23:53:25.673489 IP (tos 0x10, ttl 64, id 61935, offset 0, flags [DF], proto TCP (6), length 60)
 *  192.168.101.50.35230 > 192.168.101.60.ssh: Flags [S], cksum 0xf7d5 (incorrect -> 0xd5f5), seq \
 *      1837036053, win 14600, options [mss 1460,sackOK,TS val 4294902778 ecr 0,nop,wscale 7], length 0
 *      0x0000:  4510 003c f1ef 4000 4006 fcfc c0a8 6532  E..<..@.@.....e2
 *      0x0010:  c0a8 653c 899e 0016 6d7e f215 0000 0000  ..e<....m~......
 *      0x0020:  a002 3908 f7d5 0000 0204 05b4 0402 080a  ..9.............
 *      0x0030:  ffff 03fa 0000 0000 0103 0307            ............
 */
   task send_packet_tcp2;
      begin
	 ctrl_fifo_wren  = 0;
	 ctrl_fifo_wdata = 0;
	 data_fifo_wren  = 0;
	 data_fifo_wdata = 0;
 	 while (ctrl_fifo_afull && data_fifo_afull)
	   @(posedge tx_clk);

	 cnt = 0;
	 while (cnt != 6)
	   begin
	      ctrl_fifo_wren  = 1;
	      ctrl_fifo_wdata = 0;
	      ctrl_fifo_wdata[35:32] = 4'hf;
	      case (cnt)
		0: ctrl_fifo_wdata[31:28] = 4'ha;
		1: ctrl_fifo_wdata[1:0]   = 2'b01;
		2: begin 
		   ctrl_fifo_wdata[15:0]  = 16'h32; 
		   ctrl_fifo_wdata[31:16] = 16'h22;
		end
		3: ctrl_fifo_wdata[15:0]  = 16'h00;
		5: ctrl_fifo_wdata[36]    = 1'b1; // EOF
	      endcase
	      cnt = cnt + 1;
	      @(posedge mm2s_clk);
	   end // while (cnt != 5)
	 
	 ctrl_fifo_wren  = 0;
	 ctrl_fifo_wdata = 0;
	 data_fifo_wren  = 1;
	 data_fifo_wdata[71:64] = 8'b1111_1111;
	 data_fifo_wdata[63:0]  = 64'h999280df_16bae290; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'h10450008_05dd5521; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'h06400040_eff13c00; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'ha8c03265_a8c0fcfc; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'h7e6d1600_9e893c65; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'h02a00000_000015f2; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'h04020000_ee4b0839; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'hffff0a08_0204b405; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'h03010000_0000fa03; @(posedge mm2s_clk);
	 data_fifo_wdata[63:0]  = 64'h00000000_00000703; 
	 data_fifo_wdata[71:64] = 8'b0000_0011; 
	 data_fifo_wdata[72]    = 1'b1;
	 @(posedge mm2s_clk);

	 data_fifo_wdata = 0;
	 data_fifo_wren  = 0;
	 @(posedge mm2s_clk);	 
      end
   endtask // axi_eth_ifm

   /* 0xfeb3 */
   task send_packet_tcp_e2;
      begin
	 ctrl_fifo_wren  = 0;
	 ctrl_fifo_wdata = 0;
	 data_fifo_wren  = 0;
	 data_fifo_wdata = 0;
 	 while (ctrl_fifo_afull && data_fifo_afull)
	   @(posedge tx_clk);

	 cnt = 0;
	 while (cnt != 6)
	   begin
	      ctrl_fifo_wren  = 1;
	      ctrl_fifo_wdata = 0;
	      ctrl_fifo_wdata[35:32] = 4'hf;
	      case (cnt)
		0: ctrl_fifo_wdata[31:28] = 4'ha;
		1: ctrl_fifo_wdata[1:0]   = 2'b01;
		2: begin 
		   ctrl_fifo_wdata[15:0]  = 16'h32; 
		   ctrl_fifo_wdata[31:16] = 16'h22;
		end
		3: ctrl_fifo_wdata[15:0]  = 16'h00;
		5: ctrl_fifo_wdata[36]    = 1'b1; // EOF
	      endcase
	      cnt = cnt + 1;
	      @(posedge mm2s_clk);
	   end // while (cnt != 5)
	 
	 ctrl_fifo_wren  = 0;
	 ctrl_fifo_wdata = 0;
	 data_fifo_wren  = 1;
	 data_fifo_wdata[71:64] = 8'b1111_1111;
	                      data_fifo_wdata[63:0]  = 64'hf02e80df_16bae290;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h10450008_164767ad;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h06400040_3eb3dc05;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'ha8c03265_a8c00e36;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h86ea5fd5_16003c65;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h1080fa83_aac3e849;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h01010000_8e51c100;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h020020be_00000a08;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h04b63e22_5097a45f;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h234fb12a_c5fb5d52;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hdcdd377e_b6a25ac4;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h909c3981_e8fd33e5;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hd9087bd7_7e795436;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hbc27925e_7bd9fc94;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h7689c0b7_db0d05bb;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h5f89d74d_8604ef0a;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h5f88178d_7e8a25fb;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h2c8cb41f_e97862d8;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h24fac825_66e91d57;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hd400dc7b_c8624d09;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'haa89fd4a_066f2ce6;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h0e1f6f03_cedca5e4;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h80f8b19e_0e46d13a;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h9a0bb5eb_b504972c;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'haf1d38ef_fb944c8a;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h14f295b8_bed11a48;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h33059d0b_25493710;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h99e4da3a_1f051d0c;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h9d25dfcd_e0fd2020;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'ha756a0ce_26032e38;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h53654484_b60c29da;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h15aae48b_9bcfa573;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hb73af0d4_495108b7;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h382241d5_f90f1502;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h0acfdb86_ca2f8e9a;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'he7b838c8_c73857f3;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hef3545bd_cb8fc355;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h9ea7abb5_b2ee77b4;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h0cd32929_310c228f;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h24da4f5e_e0b807da;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h49aef614_5cbbbb84;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h1212e9f4_947a2660;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hea8ec8d7_338fbc22;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h7cc7aeee_10c02a0e;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hbec9005e_19d77269;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h339958b8_3e7e7ea5;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h6c301697_1baed885;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h58dd7fb3_f42ea8c9;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hac237b55_f4942683;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'ha4000758_0ca0dad5;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hfd9c0579_6ac0d2f5;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hdd675b5b_c8e9a7e9;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h5c7b59fc_bbf28050;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hc4d11904_599ce083;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hb77d0384_05773493;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hc763ab0e_8cd1d9de;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h03c4f3fe_245afc05;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h2c8091d4_ae1db06c;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'he48b5049_01d0c0b0;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h89f7850c_e06023cd;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h940c571b_a2a9ec9d;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h5a6728c1_a745f9c6;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hc66be944_4a3d4891;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hf2ea01f9_f6cac277;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'ha9e19b88_eba24f70;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h5bd720f5_baff20f0;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h9efa542c_117b28be;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h22ec6266_2768b473;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hfc7665a8_0a4fa618;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h8bf5f88f_f6e6a25c;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h2224c958_5132e2d8;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h9bdf25c1_8aee86d5;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hfb13fa50_d87488c6;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h070aba53_ef7f32c5;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'he0566e78_ac42ad42;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hbecec573_46992d8b;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hff447f54_0b29a7c8;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h3bc88588_c1eb6b07;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h27f9ad39_f6948d34;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h719d1811_6f788373;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h99c41450_bdb3d3d0;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h08e7079a_cc69179e;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h8b924afe_9386a708;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h9fc4ca96_856a7b41;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hdb5963db_a4b0113a;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hc83046d6_de77bcfe;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h00438dee_107972f0;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h853b95e6_1e6b2f9a;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hb5f01f7d_af3e6f6a;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h7c7ad7b6_ce80ef9e;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hd0ca352f_f8e15919;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hb54dd6a6_dffb102d;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h7e49fea2_cfd8ac20;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h2abef14c_520eaeaf;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'ha43368a0_3156ea9f;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h203eb474_e0ce4240;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hac96855f_c5e329c6;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h9e2167ee_864ad468;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h9f938c84_ef1ede7b;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h8f93b3dc_7b5b35f6;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h3700b6b9_78613254;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hc8c8594d_bce2a873;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h1b36d039_cd34347e;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hdf6d8eb9_ae35836e;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hef017ad8_d9408927;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'ha05f2d25_b432b0ba;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h75201dc1_95851758;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hbe8dbb98_c101e03a;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h13c30581_8e5af3fa;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hd6a26e19_abbed933;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'ha944524f_9a8c0c02;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h2e40307b_9420e078;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hcaba8fa6_c7e3eb5d;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h1c26e908_f99741aa;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hb42f765e_d783b692;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h2e9cb329_9be16f4a;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h6c98a0af_54bd1acd;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h3dfd77d7_9d1264f1;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h52b7c41a_6601f1bb;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h52a6f4d4_783e8886;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'he7cdd6f7_18d2b632;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h400aa506_e5371285;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'heb9bf5be_3961099c;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hbe0b4123_2d101bed;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hac2d7f92_063686ca;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h8736b74b_881babf5;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h5d433fea_2111f4c6;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h1e0847f3_814083bb;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'haab1eda3_b8cecd15;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'he9680b16_27d9f846;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h9fb5d088_6f607954;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h5b422b1e_019ead18;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h6b2c9e4f_b1340a13;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h3857ce23_6a5cb130;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h8fe559e5_26acf8bc;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'he5a882bf_2ac06e75;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h9a1265b3_bdcd46da;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hf8a6bdc9_a6e1fd37;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hffe44231_83b72f5c;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hf7a6ee5c_9a599bea;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h49a0cff1_20f2311e;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'he93e897e_1986ff74;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hef9ff99a_d97fb0d4;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'ha063e226_b2257e44;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hb8208a31_0695d938;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hcd36f811_86c06d48;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h06b0d1b4_640e77c2;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hb3cf5e85_704e8a9f;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h29873dff_d4709c7f;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hefb7957d_ab289671;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h288bb87e_256413dc;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hfc5cc21a_3df53e5a;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h2d45a460_b32dae39;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h9ef98b5e_9ba49808;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h4949c757_41b07e9a;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h3d751c23_b15dc859;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h95955acd_975dd1c1;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h87191eea_850990a9;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hf773a9ca_21de80b4;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'ha97e34db_71eba829;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h9e2e072c_62afd5ee;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h34abd74a_9623d9b9;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h83c6de42_bb866aad;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h51295a41_d49ca9b9;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h23e4bf40_08c44f8e;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h081bf96d_bc891097;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h1c907ea5_94093e5f;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hd4defb0c_ccb5d2b4;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h2bd832c0_bc80e502;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hd00349e1_fb7bea44;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hbeaf83ec_1c6c6cf4;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hfc98f9df_12023e56;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h709261cf_1b224d77;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h2f9228f8_76b1293c;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hef03547b_0d52b404;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h2a8b0480_6cc67fea;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h4fa39986_1421d535;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h406a0341_89bc9766;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hdcd28098_b1c4f6c9;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h2ecc3e48_638dedf4;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'ha2891aff_41b2b030;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'hee0bdf70_aa56428c;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h797e9ca7_ecac8550;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'ha46d8913_def2c5cc;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h6d2c4e65_41f6d2a8;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h87c06633_cb41b11b;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h78c88dd3_c2e560ab;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h1116ead6_bfa91800;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'he60cda32_0c0a493d;
	 @(posedge mm2s_clk); data_fifo_wdata[63:0]  = 64'h00000000_00008185;
	 data_fifo_wdata[71:64] = 8'b0000_0011; 
	 data_fifo_wdata[72]    = 1'b1;
	 @(posedge mm2s_clk);

	 data_fifo_wdata = 0;
	 data_fifo_wren  = 0;
	 @(posedge mm2s_clk);	 
      end
   endtask // axi_eth_ifm

   initial begin
      data_fifo_wdata = 0;
      data_fifo_wren  = 0;
      ctrl_fifo_wdata = 0;
      ctrl_fifo_wren  = 0;
      
      @(negedge sys_rst);
      @(posedge tx_clk);
      @(posedge tx_clk);
      @(posedge tx_clk);
      @(posedge tx_clk);
      
      send_packet(0, 0, 0, 0, 32);
      cnt = 0;
      while (cnt != 50)
      begin
	 @(posedge tx_clk);
	 cnt = cnt + 1;
      end
      
      sys_rst = ~sys_rst;
      @(posedge tx_clk);
      @(posedge tx_clk);
      @(posedge tx_clk);
      @(posedge tx_clk);
      sys_rst = ~sys_rst;
      @(posedge tx_clk);
      @(posedge tx_clk);
      @(posedge tx_clk);
      @(posedge tx_clk);

      send_packet(0, 0, 0, 0, 33);
      send_packet(0, 0, 0, 0, 34); 
      send_packet(0, 0, 0, 0, 34);
  
      send_packet_tcp1();
      send_packet_tcp2();
      send_packet_tcp_e2();
   end
  
   wire [31:0] ofm_in_fsm_dbg;
   wire [31:0] ofm_out_fsm_dbg;
   wire [31:0] ifm_in_fsm_dbg;
   wire [31:0] ifm_out_fsm_dbg;
   axi_eth_ofm axi_eth_ofm (/*AUTOINST*/
			    // Outputs
			    .ofm_in_fsm_dbg	(ofm_in_fsm_dbg[3:0]),
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
			    .sys_rst		(sys_rst),
			    .tx_axis_mac_tready	(tx_axis_mac_tready),
			    .tx_clk		(tx_clk),
			    .txc_tdata		(txc_tdata[31:0]),
			    .txc_tkeep		(txc_tkeep[3:0]),
			    .txc_tlast		(txc_tlast),
			    .txc_tvalid		(txc_tvalid),
			    .txd_tdata		(txd_tdata[63:0]),
			    .txd_tkeep		(txd_tkeep[7:0]),
			    .txd_tlast		(txd_tlast),
			    .txd_tvalid		(txd_tvalid));

   wire [72:0] data_fifo_rdata;
   wire        data_fifo_rden;
   wire        data_fifo_empty;
   assign txd_tdata      = data_fifo_rdata[63:0];
   assign txd_tkeep      = data_fifo_rdata[71:64];
   assign txd_tlast      = data_fifo_rdata[72];
   assign txd_tvalid     = ~data_fifo_empty;
   assign data_fifo_rden = txd_tready && txd_tvalid;

   wire [36:0] ctrl_fifo_rdata;
   wire        ctrl_fifo_rden;
   wire        ctrl_fifo_empty;
   assign txc_tdata      = ctrl_fifo_rdata[31:0];
   assign txc_tkeep      = ctrl_fifo_rdata[35:32];
   assign txc_tlast      = ctrl_fifo_rdata[36];
   assign txc_tvalid     = ~ctrl_fifo_empty;
   assign ctrl_fifo_rden = txc_tready && txc_tvalid;   
   
   axi_async_fifo #(.C_FAMILY              ("kintex7"),
		   .C_FIFO_DEPTH          (1024),
		   .C_PROG_FULL_THRESH    (700),
		   .C_DATA_WIDTH          (73),
		   .C_PTR_WIDTH           (10),
		   .C_MEMORY_TYPE         (1),
		   .C_COMMON_CLOCK        (0),
		   .C_IMPLEMENTATION_TYPE (2),
		   .C_SYNCHRONIZER_STAGE  (2))
   data_fifo (.din      (data_fifo_wdata),
	      .wr_en    (data_fifo_wren),
	      .wr_clk   (mm2s_clk),
	      .rd_en    (data_fifo_rden),
	      .rd_clk   (mm2s_clk),
	      .sync_clk (mm2s_clk),
	      .rst      (tx_reset),
	      .dout     (data_fifo_rdata),
	      .full     (),
	      .empty    (data_fifo_empty),
	      .prog_full(data_fifo_afull));   
   
   axi_async_fifo #(.C_FAMILY              ("kintex7"),
		   .C_FIFO_DEPTH          (1024),
		   .C_PROG_FULL_THRESH    (700),
		   .C_DATA_WIDTH          (37),
		   .C_PTR_WIDTH           (10),
		   .C_MEMORY_TYPE         (1),
		   .C_COMMON_CLOCK        (0),
		   .C_IMPLEMENTATION_TYPE (2),
		   .C_SYNCHRONIZER_STAGE  (2))
   ctrl_fifo (.din      (ctrl_fifo_wdata),
	      .wr_en    (ctrl_fifo_wren),
	      .wr_clk   (mm2s_clk),
	      .rd_en    (ctrl_fifo_rden),
	      .rd_clk   (mm2s_clk),
	      .sync_clk (mm2s_clk),
	      .rst      (tx_reset),
	      .dout     (ctrl_fifo_rdata),
	      .full     (),
	      .empty    (ctrl_fifo_empty),
	      .prog_full(ctrl_fifo_afull));      
endmodule
// Local Variables:
// verilog-library-directories:(".""../")
// verilog-library-files:(".")
// verilog-library-extensions:(".v" ".h")
// End:
// 
// ifm_tb.v ends here
