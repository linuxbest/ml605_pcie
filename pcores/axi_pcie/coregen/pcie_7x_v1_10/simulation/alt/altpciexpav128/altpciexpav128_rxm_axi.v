// altpciexpav128_rxm_axi.v --- 
// 
// Filename: altpciexpav128_rxm_axi.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Nov  9 11:47:10 2014 (-0800)
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
// 	clock signals                      : "clk"; "clk_div#"; "clk_#x"
// 	reset signals                      : "rst"; "rst_n"
// 	generics                           : "C_*"
// 	user defined types                 : "*_TYPE"
// 	state machine next state           : "*_ns"
// 	state machine current state        : "*_cs"
// 	combinatorial signals              : "*_com"
// 	pipelined or register delay signals: "*_d#"
// 	counter signals                    : "*cnt*"
// 	clock enable signals               : "*_ce"
// 	internal version of output port    : "*_i"
// 	device pins                        : "*_pin"
// 	ports                              : - Names begin with Uppercase
// Code:
`timescale 1ns / 1ps
module altpciexpav128_rxm_axi (/*AUTOARG*/
   // Outputs
   CoreRxmWaitRequest_o, M_AWVALID, M_AWADDR, M_AWPROT, M_AWREGION,
   M_AWLEN, M_AWSIZE, M_AWBURST, M_AWLOCK, M_AWCACHE, M_AWQOS, M_AWID,
   M_AWUSER, M_WVALID, M_WDATA, M_WSTRB, M_WLAST, M_WUSER, M_BREADY,
   M_ARVALID, M_ARADDR, M_ARPROT, M_ARREGION, M_ARLEN, M_ARSIZE,
   M_ARBURST, M_ARLOCK, M_ARCACHE, M_ARQOS, M_ARID, M_ARUSER,
   M_RREADY, rxm_read_data, rxm_read_data_valid,
   // Inputs
   Clk_i, Rstn_i, CoreRxmWrite_i, CoreRxmRead_i, CoreRxmWriteSOP_i,
   CoreRxmWriteEOP_i, CoreRxmBarHit_i, CoreRxmAddress_i,
   CoreRxmWriteData_i, CoreRxmByteEnable_i, CoreRxmBurstCount_i,
   M_AWREADY, M_WREADY, M_BVALID, M_BRESP, M_BID, M_BUSER, M_ARREADY,
   M_RVALID, M_RDATA, M_RRESP, M_RLAST, M_RID, M_RUSER
   );
   parameter CB_RXM_DATA_WIDTH = 128;
   parameter AVALON_ADDR_WIDTH = 64;

   parameter C_M_AXI_ADDR_WIDTH      = 64;
   parameter C_M_AXI_DATA_WIDTH      = 128;
   parameter C_M_AXI_THREAD_ID_WIDTH = 3;
   parameter C_M_AXI_USER_WIDTH      = 3;

   input                                 Clk_i;
   input                                 Rstn_i;
   input                                 CoreRxmWrite_i;
   input                                 CoreRxmRead_i;
   input                                 CoreRxmWriteSOP_i;
   input                                 CoreRxmWriteEOP_i;
   input [6:0]                           CoreRxmBarHit_i;
   input [AVALON_ADDR_WIDTH-1:0]         CoreRxmAddress_i;
   input [CB_RXM_DATA_WIDTH-1:0]         CoreRxmWriteData_i;
   input [(CB_RXM_DATA_WIDTH/8)-1:0]     CoreRxmByteEnable_i;
   input [6:0]                           CoreRxmBurstCount_i; 
   output                                CoreRxmWaitRequest_o;

   output 		M_AWVALID;
   output [((C_M_AXI_ADDR_WIDTH) - 1):0] M_AWADDR;
   output [2:0] 			 M_AWPROT;
   output [3:0] 			 M_AWREGION;
   output [7:0] 			 M_AWLEN;
   output [2:0] 			 M_AWSIZE;
   output [1:0] 			 M_AWBURST;
   output 				 M_AWLOCK;
   output [3:0] 			 M_AWCACHE;
   output [3:0] 			 M_AWQOS;
   output [((C_M_AXI_THREAD_ID_WIDTH) - 1):0] M_AWID;
   output [((C_M_AXI_USER_WIDTH) - 1):0]      M_AWUSER;
   input 				      M_AWREADY;
   output 				      M_WVALID;
   output [((C_M_AXI_DATA_WIDTH) - 1):0]      M_WDATA;
   output [(((C_M_AXI_DATA_WIDTH / 8)) - 1):0] M_WSTRB;
   output 				       M_WLAST;
   output [((C_M_AXI_USER_WIDTH) - 1):0]       M_WUSER;
   input 				       M_WREADY;
   input 				       M_BVALID;
   input [1:0] 				       M_BRESP;
   input [((C_M_AXI_THREAD_ID_WIDTH) - 1):0]   M_BID;
   input [((C_M_AXI_USER_WIDTH) - 1):0]        M_BUSER;
   output 				       M_BREADY;
   
   output 				       M_ARVALID;
   output [((C_M_AXI_ADDR_WIDTH) - 1):0]       M_ARADDR;
   output [2:0] 			       M_ARPROT;
   output [3:0] 			       M_ARREGION;
   output [7:0] 			       M_ARLEN;
   output [2:0] 			       M_ARSIZE;
   output [1:0] 			       M_ARBURST;
   output 				       M_ARLOCK;
   output [3:0] 			       M_ARCACHE;
   output [3:0] 			       M_ARQOS;
   output [((C_M_AXI_THREAD_ID_WIDTH) - 1):0]  M_ARID;
   output [((C_M_AXI_USER_WIDTH) - 1):0]       M_ARUSER;
   input 				       M_ARREADY;
   input 				       M_RVALID;
   input [((C_M_AXI_DATA_WIDTH) - 1):0]        M_RDATA;
   input [1:0] 				       M_RRESP;
   input 				       M_RLAST;
   input [((C_M_AXI_THREAD_ID_WIDTH) - 1):0]   M_RID;
   input [((C_M_AXI_USER_WIDTH) - 1):0]        M_RUSER;
   output 				       M_RREADY;
   
   output [127:0] rxm_read_data;
   output         rxm_read_data_valid;
   
   /*AUTOREG*/

   wire 				       fifo_wrreq;
   wire 				       fifo_rdreq;
   wire [193 + AVALON_ADDR_WIDTH - 32 : 0]     fifo_wr_data;
   wire [193 + AVALON_ADDR_WIDTH - 32 : 0]     fifo_data_out;
   wire [3:0] 				       fifo_count;

   assign CoreRxmWaitRequest_o = (fifo_count > 2);
   assign fifo_wrreq           = ~CoreRxmWaitRequest_o & (CoreRxmWrite_i | CoreRxmRead_i);
   assign fifo_wr_data         = {CoreRxmBurstCount_i, CoreRxmAddress_i,CoreRxmBarHit_i,CoreRxmRead_i, CoreRxmWrite_i, CoreRxmWriteEOP_i, CoreRxmWriteSOP_i, CoreRxmByteEnable_i, CoreRxmWriteData_i};

   altpciexpav128_fifo #(.FIFO_DEPTH(3),
			 .DATA_WIDTH(194 + AVALON_ADDR_WIDTH - 32))
   rxm_fifo (.clk       (Clk_i),
	     .rstn      (Rstn_i),
	     .data      (fifo_wr_data),
	     .srst      (1'b0),
	     .wrreq     (fifo_wrreq),
	     .rdreq     (fifo_rdreq),
	     .q         (fifo_data_out),
	     .fifo_count(fifo_count));

   wire 				       rxm_sop;
   wire 				       rxm_eop;
   wire 				       rxm_read;
   wire 				       rxm_write;
   assign rxm_sop   = fifo_data_out[144];
   assign rxm_eop   = fifo_data_out[145];
   assign rxm_write = fifo_data_out[146];
   assign rxm_read  = fifo_data_out[147];

   localparam [1:0] // synopsys enum state
     S_IDLE = 2'b00,
     S_ADDR = 2'b10,
     S_DATA = 2'b11;
   reg [1:0] // synopsys enum state
	     state, state_ns;
   always @(posedge Clk_i)
     begin
	if (~Rstn_i)
	  begin
	     state <= #1 S_IDLE;
	  end
	else
	  begin
	     state <= #1 state_ns;	     
	  end
     end // always @ (posedge Clk_i)
   always @(*)
     begin
	state_ns = state;
	case (state)
	  S_IDLE:
	    if (fifo_count != 4'h0)
	      begin
		 state_ns = S_ADDR;
	      end
	  S_ADDR:
	    if (rxm_eop && rxm_read && M_ARREADY)
	      begin
		 state_ns = S_IDLE;		 
	      end
	    else if (rxm_write && M_AWREADY && M_WREADY)
	      begin
		 state_ns = rxm_eop ? S_IDLE : S_DATA;		 
	      end
	  S_DATA:
	    if (rxm_eop && M_WREADY)
	      begin
		 state_ns = S_IDLE;
	      end
	endcase
     end // always @ (*)
   wire [2:0] fifo_rdreq_int;
   assign fifo_rdreq_int[0] = state == S_ADDR && (rxm_eop && rxm_read && M_ARREADY);
   assign fifo_rdreq_int[1] = state == S_ADDR && (rxm_write && M_ARREADY);
   assign fifo_rdreq_int[2] = state == S_DATA && M_WREADY;
   assign fifo_rdreq        = |fifo_rdreq_int;

   wire [31:0] req_addr;
   wire [15:0] req_len;
   assign req_addr = fifo_data_out[186+ AVALON_ADDR_WIDTH -32:155];
   assign req_len  = fifo_data_out[193 + AVALON_ADDR_WIDTH -32:187 + AVALON_ADDR_WIDTH -32];

   // AW 
   assign M_AWVALID  = state == S_ADDR && rxm_write;
   assign M_AWADDR   = req_addr;
   assign M_AWBURST  = 2'b01;	// INCR ONLY
   assign M_AWSIZE   = 3'b100;	// 16byte   
   assign M_AWLEN    = req_len - 1;
   
   assign M_AWPROT   = 0;
   assign M_AWREGION = 0;
   assign M_AWLOCK   = 0;
   assign M_AWCACHE  = 0;
   assign M_AWQOS    = 0;
   assign M_AWID     = 0;
   assign M_AWUSER   = 0;

   // DW
   assign M_WVALID   = (state == S_ADDR && rxm_write) | (state == S_DATA);
   assign M_WSTRB    = fifo_data_out[143:128];
   assign M_WDATA    = fifo_data_out[127:0];
   assign M_WLAST    = (state == S_ADDR && rxm_write && rxm_eop) | (state == S_DATA && rxm_eop);
   assign M_WUSER    = 0;
   
   assign M_BREADY   = 1'b1;
   // TODO
   //   WRESP

   // AR
   assign M_ARVALID  = state == S_ADDR && rxm_read;
   assign M_ARADDR   = req_addr;
   assign M_ARBURST  = 2'b01;	// INCR ONLY
   assign M_ARSIZE   = 3'b100;	// 16byte   
   assign M_ARLEN    = req_len - 1;
   
   assign M_ARPROT   = 0;
   assign M_ARREGION = 0;
   assign M_ARLOCK   = 0;
   assign M_ARCACHE  = 0;
   assign M_ARQOS    = 0;
   assign M_ARID     = 0;
   assign M_ARUSER   = 0;

   // AR DATA
   assign M_RREADY   = 1'b1;
   assign rxm_read_data_valid = M_RVALID;
   assign rxm_read_data       = M_RDATA;
   // TODO:
   //   RRESP 
endmodule
// 
// altpciexpav128_rxm_axi.v ends here
