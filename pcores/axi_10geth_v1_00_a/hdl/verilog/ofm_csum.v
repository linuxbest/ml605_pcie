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
   TxSum, TxSum_valid,
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
   output 	 TxSum_valid;

   wire [63:0] 	 tdata;
   wire [7:0] 	 tkeep;
   wire 	 tlast;
   wire 	 tvalid;
   assign tdata = data_fifo_wdata[63:0];
   assign tkeep = data_fifo_wdata[71:64];
   assign tlast = data_fifo_wdata[72];
   assign tvalid= data_fifo_wren;

   reg [15:0] 	 TxSum;
   reg [31:0] 	 sum;
   reg 		 sof;
   always @(posedge mm2s_clk or negedge mm2s_resetn)
     begin
	if (~mm2s_resetn || (tvalid && tlast))
	  begin
	     sof   <= #1 1'b1;
	  end
	else if (tvalid)
	  begin
	     sof <= #1 1'b0;
	  end
     end // always @ (posedge mm2s_clk or negedge mm2s_resetn)
   reg [15:0] cur_sum;
   reg 	      cur_sum_en;
   always @(posedge mm2s_clk)
     begin
	if (tvalid && sof)
	  begin
	     sum <= #1 TxCsInit;
	  end
	else if (cur_sum_en)
	  begin
	     sum <= #1 sum + cur_sum;
	  end
     end // always @ (posedge mm2s_clk)

   reg end_hit_reg;   
   reg TxSum_valid;
   always @(posedge mm2s_clk)
     begin
	if (end_hit_reg)
	  begin
	     TxSum <= #1 sum[31:16] + sum[15:0];
	  end
     end

   reg [63:0] tdata_d1;
   reg [7:0]  tkeep_d1;
   reg 	      tvalid_d1;
   always @(posedge mm2s_clk)
     begin
	tdata_d1 <= #1 tdata;
	tkeep_d1 <= #1 tkeep;
	tvalid_d1<= #1 tvalid;
     end
   reg [15:0] bcnt;
   reg [15:0] bcntd;
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
	     bcntd<= #1 bcnt;
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
   assign begin_hit = (bcnt > TxCsBegin) && ~begin_hit_reg;

   // figure out the Csum end
   wire end_hit;
   assign end_hit = tvalid & tlast;
   always @(posedge mm2s_clk)
     begin
	if ((tvalid && sof) || end_hit)
	  begin
	     cur_sum_en <= #1 1'b0;
	  end
	else if (begin_hit)
	  begin
	     cur_sum_en <= #1 1'b1;
	  end
     end // always @ (posedge mm2s_clk)
   always @(posedge mm2s_clk)
     begin
	end_hit_reg <= #1 end_hit;
	TxSum_valid <= #1 end_hit_reg;
     end

   wire [7:0] csum_mask;
   wire [3:0] csum_mask_begin_bcnt;
   wire [7:0] csum_mask_begin;
   assign csum_mask_begin_bcnt  = bcnt - TxCsBegin;
   cnt_to_keep csum_mask_begin_i (.cnt(csum_mask_begin_bcnt), .keep(csum_mask_begin));

   assign csum_mask = begin_hit ? (~csum_mask_begin) & tkeep_d1 : tkeep_d1;
   wire [15:0] cur_sum_int;
   assign cur_sum_int = (csum_mask[0] ? tdata_d1[07:00] : 8'h0) +
			(csum_mask[1] ? tdata_d1[15:08] : 8'h0) +
			(csum_mask[2] ? tdata_d1[23:16] : 8'h0) +
			(csum_mask[3] ? tdata_d1[31:24] : 8'h0) +
			(csum_mask[4] ? tdata_d1[39:32] : 8'h0) +
			(csum_mask[5] ? tdata_d1[47:40] : 8'h0) +
			(csum_mask[6] ? tdata_d1[55:48] : 8'h0) +
			(csum_mask[7] ? tdata_d1[63:56] : 8'h0);
   always @(posedge mm2s_clk)
     begin
	cur_sum <= #1 cur_sum_int;
     end
endmodule
// 
// ofm_csum.v ends here   
