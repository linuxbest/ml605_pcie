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
   reg 	      tx_reset;
   reg        mm2s_resetn;
   
   initial begin
      tx_clk = 1'b0;
      forever #(1000) tx_clk = ~tx_clk;
   end
   initial begin
      mm2s_clk = 1'b0;
      forever #(5333)  mm2s_clk = ~mm2s_clk;
   end
   initial begin
      tx_reset = 1'b1;
      mm2s_resetn = 1'b0;
      #(10000) tx_reset = ~tx_reset;
      #(10000) mm2s_resetn = ~mm2s_resetn;
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
   
   initial begin
      data_fifo_wdata = 0;
      data_fifo_wren  = 0;
      ctrl_fifo_wdata = 0;
      ctrl_fifo_wren  = 0;
      
      @(negedge tx_reset);
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
      
      mm2s_resetn = ~mm2s_resetn;
      @(posedge tx_clk);
      @(posedge tx_clk);
      @(posedge tx_clk);
      @(posedge tx_clk);
      mm2s_resetn = ~mm2s_resetn;
      @(posedge tx_clk);
      @(posedge tx_clk);
      @(posedge tx_clk);
      @(posedge tx_clk);

      send_packet(0, 0, 0, 0, 33);
      send_packet(0, 0, 0, 0, 34); 
      send_packet(0, 0, 0, 0, 34);

      send_packet(2'b01, 	// csum enable
		  16'h14, 	// Beign
		  16'h40, 	// Insert
		  16'hf,	// Initial
		  30);		// length
      send_packet(2'b01, 	// csum enable
		  16'h18, 	// Beign
		  16'h42, 	// Insert
		  16'h2,	// Initial
		  30);		// length
   
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
			    .mm2s_resetn	(mm2s_resetn),
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
