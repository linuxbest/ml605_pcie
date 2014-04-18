// ofm_csum.v --- 
// 
// Filename: ofm_csum.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Fri Apr 18 11:31:09 2014 (-0700)
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
// 	internal version of output port    : "*_i"
// 	device pins                        : "*_pin"
// 	ports                              : - Names begin with Uppercase
// Code:
`timescale 1ps/1ps
module ofm_csum (/*AUTOARG*/
   // Outputs
   TxSum,
   // Inputs
   mm2s_clk, mm2s_resetn, data_fifo_wren, data_fifo_wdata, TxCsBegin,
   TxCsInit, TxCsInsert
   );
   input mm2s_clk;
   input mm2s_resetn;

   input data_fifo_wren;
   input [72:0] data_fifo_wdata;

   input [15:0] TxCsBegin;
   input [15:0] TxCsInit;
   input [15:0] TxCsInsert;
   output [15:0] TxSum;

   wire [63:0] 	 tdata;
   wire [7:0] 	 tkeep;
   wire 	 tlast;
   wire 	 tvalid;
   assign tdata = data_fifo_wdata[63:0];
   assign tkeep = data_fifo_wdata[71:64];
   assign tlast = data_fifo_wdata[72];
   assign tvalid= data_fifo_wren;

   reg [15:0] 	 TxSum;
   reg [15:0] 	 sum;
   reg 		 sof;
   always @(posedge mm2s_clk or negedge mm2s_resetn)
     begin
	if (~mm2s_resetn || (tvalid && tlast))
	  begin
	     sof   <= #1 1'b1;
	     TxSum <= #1 sum;
	  end
	else if (tvalid)
	  begin
	     sof <= #1 1'b0;
	  end
     end // always @ (posedge mm2s_clk or negedge mm2s_resetn)
   wire [15:0] cur_sum;
   always @(posedge mm2s_clk)
     begin
	if (tvalid && sof)
	  begin
	     sum <= #1 TxCsInit;
	  end
	else if (tvalid)
	  begin
	     sum <= #1 sum + cur_sum;
	  end
     end // always @ (posedge mm2s_clk)

   reg [15:0] bcnt;		// 
   wire [15:0] next_bcnt;
   wire [3:0]  tdata_bcnt;
   keep_to_cnt tdata_i (.cnt(tdata_bcnt), .keep(tkeep));
   assign next_bcnt = bcnt + tdata_bcnt;
   always @(posedge mm2s_clk)
     begin
	if (tvalid && sof)
	  begin
	     bcnt <= #1 tdata_bcnt;
	  end
	else if (tvalid)
	  begin
	     bcnt <= #1 next_bcnt;
	  end
     end // always @ (posedge mm2s_clk)

   // figure out the Csum begin
   reg begin_hit_reg;
   wire begin_hit;
   always @(posedge mm2s_clk)
     begin
	if (tvalid && sof)
	  begin
	     begin_hit_reg <= #1 1'b0;
	  end
	else if (~begin_hit_reg)
	  begin
	     begin_hit_reg <= #1 begin_hit;
	  end
     end // always @ (posedge mm2s_clk)
   assign begin_hit = (bcnt >= TxCsBegin) && ~begin_hit_reg;

   // figure out the Csum end
   reg end_hit_reg;
   wire end_hit;
   always @(posedge mm2s_clk)
     begin
	if (tvalid && sof)
	  begin
	     end_hit_reg <= #1 1'b0;
	  end
	else if (~end_hit_reg)
	  begin
	     end_hit_reg <= #1 end_hit;
	  end
     end // always @ (posedge mm2s_clk)
   assign end_hit = (bcnt >= TxCsInsert) && ~end_hit_reg;

   wire [7:0] csum_mask;
   wire [3:0] csum_mask_begin_bcnt;
   wire [3:0] csum_mask_end_bcnt;
   wire [7:0]  csum_mask_begin;
   wire [7:0] csum_mask_end;
   assign csum_mask_begin_bcnt  = bcnt - TxCsBegin;
   assign csum_mask_end_bcnt    = bcnt - TxCsInsert;
   cnt_to_keep csum_mask_begin_i (.cnt(csum_mask_begin_bcnt), .keep(csum_mask_begin));
   cnt_to_keep csum_mask_end_i   (.cnt(csum_mask_end_bcnt),   .keep(csum_mask_end));   

   assign csum_mask = begin_hit ? csum_mask_begin : 
		      end_hit   ? csum_mask_end   : tkeep;
   
   assign cur_sum = 16'h00;
endmodule
// 
// ofm_csum.v ends here   
