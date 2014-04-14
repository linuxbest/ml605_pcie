// axi_lite_slave.v --- 
// 
// Filename: axi_lite_slave.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sat Aug  3 17:00:26 2013 (-0700)
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
`timescale 1 ps / 100 fs
module axi_lite_slave (/*AUTOARG*/
   // Outputs
   s_axi_lite_awready, s_axi_lite_wready, s_axi_lite_bresp,
   s_axi_lite_bvalid, s_axi_lite_arready, s_axi_lite_rvalid,
   s_axi_lite_rdata, s_axi_lite_rresp, intr_out,
   // Inputs
   s_axi_lite_aclk, axi_resetn, s_axi_lite_awvalid, s_axi_lite_awaddr,
   s_axi_lite_wvalid, s_axi_lite_wdata, s_axi_lite_bready,
   s_axi_lite_arvalid, s_axi_lite_araddr, s_axi_lite_rready,
   aes_sts_dbg, intr_in
   );
   parameter C_S_AXI_LITE_ADDR_WIDTH = 10;
   parameter C_S_AXI_LITE_DATA_WIDTH = 32;
   
   input s_axi_lite_aclk;   
   input axi_resetn;

   input s_axi_lite_awvalid;
   output s_axi_lite_awready;
   input [C_S_AXI_LITE_ADDR_WIDTH-1:0] s_axi_lite_awaddr;
   
   input 			       s_axi_lite_wvalid;
   output 			       s_axi_lite_wready;
   input [C_S_AXI_LITE_DATA_WIDTH-1:0] s_axi_lite_wdata;
   
   output [1:0] 		       s_axi_lite_bresp;
   output 			       s_axi_lite_bvalid;
   input 			       s_axi_lite_bready;
   
   input 			       s_axi_lite_arvalid;
   output 			       s_axi_lite_arready;
   input [C_S_AXI_LITE_ADDR_WIDTH-1:0] s_axi_lite_araddr;
   
   output 			       s_axi_lite_rvalid;
   input 			       s_axi_lite_rready;
   output [C_S_AXI_LITE_DATA_WIDTH-1:0] s_axi_lite_rdata;
   output [1:0] 			s_axi_lite_rresp;

   input [31:0] 			aes_sts_dbg;
   input [31:0]				intr_in;
   output 				intr_out;
   /***************************************************************************/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			intr_out;
   reg [C_S_AXI_LITE_DATA_WIDTH-1:0] s_axi_lite_rdata;
   reg [1:0]		s_axi_lite_rresp;
   reg			s_axi_lite_rvalid;
   // End of automatics

   localparam C_ADDR_WIDTH = C_S_AXI_LITE_ADDR_WIDTH;
   localparam C_DATA_WIDTH = C_S_AXI_LITE_DATA_WIDTH;

   reg [C_ADDR_WIDTH-1:0] addr;
   wire 		  clk;
   wire 		  reset;
   assign clk   = s_axi_lite_aclk;
   assign reset = ~axi_resetn;
 
   /***************************************************************************/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [C_DATA_WIDTH-1:0] reg_data;		// From axi_lite_write of axi_lite_write.v
   wire [C_ADDR_WIDTH-1:0] reg_data_addr;	// From axi_lite_write of axi_lite_write.v
   wire			reg_data_write;		// From axi_lite_write of axi_lite_write.v
   // End of automatics
   
   /***************************************************************************/
   /* axi_lite_write AUTO_TEMPLATE (
    .aw\([a-z]+\) (s_axi_lite_aw\1[]),
    .w\([a-z]+\)  (s_axi_lite_w\1[]),
    .b\([a-z]+\)  (s_axi_lite_b\1[]),
    ); */
   axi_lite_write 
     #(/*AUTOINSTPARAM*/
       // Parameters
       .C_ADDR_WIDTH			(C_ADDR_WIDTH),
       .C_DATA_WIDTH			(C_DATA_WIDTH))
   axi_lite_write (/*AUTOINST*/
		   // Outputs
		   .wready		(s_axi_lite_wready),	 // Templated
		   .bvalid		(s_axi_lite_bvalid),	 // Templated
		   .bresp		(s_axi_lite_bresp[1:0]), // Templated
		   .reg_data_addr	(reg_data_addr[C_ADDR_WIDTH-1:0]),
		   .reg_data_write	(reg_data_write),
		   .reg_data		(reg_data[C_DATA_WIDTH-1:0]),
		   // Inputs
		   .clk			(clk),
		   .reset		(reset),
		   .awvalid		(s_axi_lite_awvalid),	 // Templated
		   .awready		(s_axi_lite_awready),	 // Templated
		   .wvalid		(s_axi_lite_wvalid),	 // Templated
		   .wdata		(s_axi_lite_wdata[C_DATA_WIDTH-1:0]), // Templated
		   .bready		(s_axi_lite_bready));	 // Templated

   wire 		arhandleshake;
   wire 		rhandshake;
   wire 		awhandshake;   
   wire 		bhandshake;
   assign arhandleshake = s_axi_lite_arvalid & s_axi_lite_arready;
   assign rhandshake    = s_axi_lite_rvalid  & s_axi_lite_rready;
   assign awhandshake   = s_axi_lite_awvalid & s_axi_lite_awready;
   assign bhandshake    = s_axi_lite_bvalid  & s_axi_lite_bready;

   reg 			awready_r;
   reg 			arready_r;
   assign s_axi_lite_awready = awready_r;
   assign s_axi_lite_arready = arready_r;
   
   reg 			wr_pending;
   reg 			rd_pending;   
   always @(posedge clk)
     begin
	if (reset)
	  begin
	     wr_pending <= #1 1'b0;
	  end
	else
	  begin
	     wr_pending <= #1 (awhandshake | wr_pending) & ~bhandshake;
	  end
     end // always @ (posedge clk)
   always @(posedge clk)
     begin
	if (reset)
	  begin
	     rd_pending <= #1 1'b0;
	  end
	else
	  begin
	     rd_pending <= #1 (arhandleshake | rd_pending) & ~rhandshake;
	  end
     end // always @ (posedge clk)
   always @(posedge clk)
     begin
	if (reset)
	  begin
	     awready_r <= #1 1'b0;
	  end
	else
	  begin
	     awready_r <= #1 s_axi_lite_awvalid & ~rd_pending & ~wr_pending & ~awready_r;
	  end
     end // always @ (posedge clk)
   always @(posedge clk)
     begin
	if (reset)
	  begin
	     arready_r <= #1 1'b0;
	  end
	else
	  begin
	     arready_r <= #1 s_axi_lite_arvalid & ~rd_pending & ~wr_pending & ~s_axi_lite_awvalid & ~arready_r;
	  end
     end // always @ (posedge clk)
   always @(posedge clk)
     begin
	if (awhandshake)
	  begin
	     addr <= #1 s_axi_lite_awaddr;
	  end
	else if (arhandleshake)
	  begin
	     addr <= #1 s_axi_lite_araddr;
	  end
     end // always @ (posedge clk)

   reg [C_DATA_WIDTH-1:0] rdata_i;
   always @(posedge clk)
     begin
	s_axi_lite_rvalid <= #1 rd_pending;
	s_axi_lite_rresp  <= #1 2'b0; // OKay
	s_axi_lite_rdata  <= #1 rdata_i;
     end

   reg [31:0] int_in_reg;
   reg [31:0] int_en_reg;
   reg [31:0] int_sts_reg;
   always @(posedge clk)
     begin
	intr_out    <= #1 int_sts_reg != 0;
	int_sts_reg <= #1 int_en_reg & int_in_reg;
	int_in_reg  <= #1 intr_in;
     end

   always @(posedge clk)
     begin
	if (reset)
	  begin
	     int_en_reg <= #1 32'h0;
	  end
	else if (reg_data_addr[6:2] == 5'h2 && reg_data_write)
	  begin
	     int_en_reg <= #1 reg_data;
	  end
     end // always @ (posedge clk)
   
   always @(*)
     begin
	rdata_i = 32'h0;
	case (addr[6:2])
	  5'h0: rdata_i = 32'hdead_beef;
	  5'h1: rdata_i = int_in_reg;
	  5'h2: rdata_i = int_en_reg;
	  5'h3: rdata_i = int_sts_reg;

	  5'h4: rdata_i = 32'h4;
	  5'h5: rdata_i = 32'h5;
	  5'h6: rdata_i = 32'h6;
	  5'h7: rdata_i = 32'h7;

	  5'h8: rdata_i = 32'h8;
	  5'h9: rdata_i = 32'h9;
	  5'ha: rdata_i = 32'ha;
	  5'hb: rdata_i = 32'hb;

	  5'hc: rdata_i = 32'hc;
	  5'hd: rdata_i = 32'hd;
	  5'he: rdata_i = aes_sts_dbg;
	  5'hf: rdata_i = 32'hdead_beef;
	endcase
     end
endmodule
// 
// axi_lite_slave.v ends here
