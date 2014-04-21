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
module eth_csum (/*AUTOARG*/
   // Outputs
   TxSum, RxSum, Sum_valid,
   // Inputs
   clk, rst, data_fifo_wren, data_fifo_wdata, CsBegin, CsInit
   );
   input clk;
   input rst;

   input data_fifo_wren;
   input [72:0] data_fifo_wdata;

   input [15:0] CsBegin;
   input [15:0] CsInit;
   output [15:0] TxSum;
   output [15:0] RxSum;
   output 	 Sum_valid;

   wire [63:0] 	 tdata;
   wire [7:0] 	 tkeep;
   wire 	 tlast;
   wire 	 tvalid;
   assign tdata = data_fifo_wdata[63:0];
   assign tkeep = data_fifo_wdata[71:64];
   assign tlast = data_fifo_wdata[72];
   assign tvalid= data_fifo_wren;

   reg 		 Sum_valid;
   reg [31:0] 	 sum;
   reg 		 sof;
   always @(posedge clk or posedge rst)
     begin
	if (rst || (tvalid && tlast))
	  begin
	     sof   <= #1 1'b1;
	  end
	else if (tvalid)
	  begin
	     sof <= #1 1'b0;
	  end
     end // always @ (posedge clk or posedge rst)
   reg [18:0] cur_sum;
   wire [18:0]cur_sum_int;
   reg 	      cur_sum_en;
   always @(posedge clk)
     begin
	if (tvalid && sof)
	  begin
	     sum <= #1 CsInit;
	  end
	else if (cur_sum_en)
	  begin
	     sum <= #1 sum + cur_sum;
	  end
     end // always @ (posedge clk)

   // cycle 0
   //  tdata, tvalid,
   // cycle 1
   //  tdata_d1, tvalid_d1, cur_sum_int,
   // cycle 2
   //  cur_sum
   // cycle 3
   //  sum
   wire [15:0] Sum_int;
   assign Sum_int = sum[31:16] + sum[15:0];

   reg 	       end_hit_reg;
   reg 	       end_hit_d1;
   reg [15:0]  TxSum_le;
   reg [15:0]  RxSum_le;
   assign TxSum = {TxSum_le[7:0], TxSum_le[15:8]};
   assign RxSum = {RxSum_le[7:0], RxSum_le[15:8]};
   always @(posedge clk)
     begin
	if (end_hit_d1)
	  begin
	     TxSum_le <= #1 (Sum_int == 16'hFFFF) ? 16'hFFFFF :~Sum_int;
	     RxSum_le <= #1 (Sum_int == 16'h0000) ? 16'hFFFFF : Sum_int;
	  end
     end

   reg [63:0] tdata_d1;
   reg [7:0]  tkeep_d1;
   reg 	      tvalid_d1;
   reg 	      tlast_d1;
   always @(posedge clk)
     begin
	tdata_d1 <= #1 tdata;
	tkeep_d1 <= #1 tvalid ? tkeep : 8'h0;
	tvalid_d1<= #1 tvalid;
	tlast_d1 <= #1 tlast;
     end
   reg [15:0] bcnt;
   reg [15:0] bcntd;
   wire [15:0] next_bcnt;
   wire [3:0]  tdata_bcnt;
   keep_to_cnt tdata_i (.cnt(tdata_bcnt), .keep(tkeep));
   assign next_bcnt = bcnt + tdata_bcnt;
   always @(posedge clk)
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
     end // always @ (posedge clk)

   // figure out the Csum begin
   reg begin_hit_reg;
   wire begin_hit;
   always @(posedge clk)
     begin
	if (tvalid && sof)
	  begin
	     begin_hit_reg <= #1 1'b0;
	  end
	else if (~begin_hit_reg)
	  begin
	     begin_hit_reg <= #1 begin_hit;
	  end
     end // always @ (posedge clk)
   assign begin_hit = (bcnt[15:3] > CsBegin[15:3]) && ~begin_hit_reg;

   // figure out the Csum end
   wire end_hit;
   assign end_hit = tvalid_d1 & tlast_d1;
   always @(posedge clk)
     begin
	if ((tvalid && sof) || end_hit_reg)
	  begin
	     cur_sum_en <= #1 1'b0;
	  end
	else if (begin_hit)
	  begin
	     cur_sum_en <= #1 1'b1;
	  end
     end // always @ (posedge clk)

   always @(posedge clk or posedge rst)
     begin
	if (rst)
	  begin
	     Sum_valid <= #1 1'b0;
	  end
	else
	  begin
	     Sum_valid <= #1 end_hit_d1;
	  end
     end
   always @(posedge clk)
     begin
	end_hit_reg <= #1 end_hit;
	end_hit_d1  <= #1 end_hit_reg;
     end

   // calculate the mask when CsBegin is ready.
   wire [7:0] csum_mask_begin;
   reg [7:0] csum_mask_begin_reg;
   reg [3:0] csum_mask_begin_bcnt;
   always @(posedge clk)
     begin
	csum_mask_begin_bcnt <= #1 4'h8 - CsBegin[2:0];
	csum_mask_begin_reg  <= #1 csum_mask_begin;
     end
   left_to_keep csum_mask_begin_i (.cnt(csum_mask_begin_bcnt), .keep(csum_mask_begin));

   wire [7:0] csum_mask;
   assign csum_mask = begin_hit ? csum_mask_begin_reg : tkeep_d1;
   assign cur_sum_int = {(csum_mask[0] ? tdata_d1[07:00] : 8'h0), (csum_mask[1] ? tdata_d1[15:08] : 8'h0)} +
			{(csum_mask[2] ? tdata_d1[23:16] : 8'h0), (csum_mask[3] ? tdata_d1[31:24] : 8'h0)} +
			{(csum_mask[4] ? tdata_d1[39:32] : 8'h0), (csum_mask[5] ? tdata_d1[47:40] : 8'h0)} +
			{(csum_mask[6] ? tdata_d1[55:48] : 8'h0), (csum_mask[7] ? tdata_d1[63:56] : 8'h0)};
   always @(posedge clk)
     begin
	cur_sum <= #1 cur_sum_int;
     end // always @ (posedge clk)
endmodule
// 
// ofm_csum.v ends here
