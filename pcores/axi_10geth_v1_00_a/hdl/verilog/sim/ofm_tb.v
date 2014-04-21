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
