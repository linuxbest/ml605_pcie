// xphy_block_clk.v --- 
// 
// Filename: xphy_block_clk.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Thu Apr 24 14:42:14 2014 (-0700)
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
`timescale 1ns / 1ps
module xphy_block_clk (/*AUTOARG*/
   // Outputs
   mmcm_locked, dclk, clk156, q1_clk0_refclk_i, q1_clk0_refclk_i_bufh,
   // Inputs
   refclk_p, refclk_n, gt0_qplllock_i
   );
   input refclk_p;
   input refclk_n;

   input  gt0_qplllock_i;
   output mmcm_locked;
   output dclk;
   output clk156;

   output q1_clk0_refclk_i;
   output q1_clk0_refclk_i_bufh;
   
   wire  clkfbout;
   wire  dclk_buf;
   wire  clk156_buf;
   
   BUFHCE bufh_i (.CE (1'b1),
		  .I  (q1_clk0_refclk_i),
		  .O  (q1_clk0_refclk_i_bufh));
   
   IBUFDS_GTE2 ibufds_instQ1_CLK0 (.O     (q1_clk0_refclk_i),
				   .ODIV2 (),
				   .CEB   (1'b0),
				   .I     (refclk_p),
				   .IB    (refclk_n)
				   );
   // MMCM to generate both clk156 and dclk
   MMCME2_BASE #
     (
      .BANDWIDTH            ("OPTIMIZED"),
      .STARTUP_WAIT         ("FALSE"),
      .DIVCLK_DIVIDE        (1),
      .CLKFBOUT_MULT_F      (4.0),
      .CLKFBOUT_PHASE       (0.000),
      .CLKOUT0_DIVIDE_F     (4.000),
      .CLKOUT0_PHASE        (0.000),
      .CLKOUT0_DUTY_CYCLE   (0.500),
      .CLKIN1_PERIOD        (6.400),
      .CLKOUT1_DIVIDE       (8),
      .CLKOUT1_PHASE        (0.000),
      .CLKOUT1_DUTY_CYCLE   (0.500),
      .REF_JITTER1          (0.010)
      )
   clkgen_i
     (
      .CLKFBIN(clkfbout),
      .CLKIN1(q1_clk0_refclk_i_bufh),
      .PWRDWN(1'b0),
      .RST(!gt0_qplllock_i),
      .CLKFBOUT(clkfbout),
      .CLKOUT0(clk156_buf),
      .CLKOUT1(dclk_buf),
      .LOCKED(mmcm_locked)
      );
   BUFG clk156_bufg_inst 
     (
      .I                              (clk156_buf),
      .O                              (clk156) 
      );
   BUFG dclk_bufg_inst 
     (
      .I                              (dclk_buf),
      .O                              (dclk) 
      );  
endmodule
// 
// xphy_block_clk.v ends here
