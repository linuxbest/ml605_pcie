//-----------------------------------------------------------------------------
//
// (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : Series-7 Integrated Block for PCI Express
// File       : axi_pcie_v1_08_a_pcie_7x_v2_0_2_gt_top.v
// Version    : 1.9
//-- Description: GTX module for 7-series Integrated PCIe Block
//--
//--
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

module axi_pcie_v1_08_a_pcie_7x_v2_0_2_gt_top #
(
   parameter               LINK_CAP_MAX_LINK_WIDTH = 8, // 1 - x1 , 2 - x2 , 4 - x4 , 8 - x8
   parameter               REF_CLK_FREQ = 0,            // 0 - 100 MHz , 1 - 125 MHz , 2 - 250 MHz
   parameter               USER_CLK2_DIV2 = "FALSE",    // "FALSE" => user_clk2 = user_clk
                                                        // "TRUE" => user_clk2 = user_clk/2, where user_clk = 500 or 250 MHz.
   parameter  integer      USER_CLK_FREQ = 3,           // 0 - 31.25 MHz , 1 - 62.5 MHz , 2 - 125 MHz , 3 - 250 MHz , 4 - 500Mhz
   parameter               PL_FAST_TRAIN = "FALSE",     // Simulation Speedup
   parameter               PCIE_EXT_CLK = "FALSE",      // Use External Clocking
   parameter               PCIE_USE_MODE = "1.0",       // 1.0 = K325T IES, 1.1 = VX485T IES, 3.0 = K325T GES
   parameter               PCIE_GT_DEVICE = "GTX",      // Select the GT to use (GTP for Artix-7, GTX for K7/V7)
   parameter               PCIE_PLL_SEL   = "CPLL",     // Select the PLL (CPLL or QPLL)
   parameter               PCIE_ASYNC_EN  = "FALSE",    // Asynchronous Clocking Enable
   parameter               PCIE_TXBUF_EN  = "FALSE",    // Use the Tansmit Buffer
   parameter               PCIE_CHAN_BOND = 0
)
(
   //-----------------------------------------------------------------------------------------------------------------//
   // pl ltssm
   input   [5:0]                pl_ltssm_state         ,
   // Pipe Per-Link Signals
   input                        pipe_tx_rcvr_det       ,
   input                        pipe_tx_reset          ,
   input                        pipe_tx_rate           ,
   input                        pipe_tx_deemph         ,
   input   [2:0]                pipe_tx_margin         ,
   input                        pipe_tx_swing          ,

   //-----------------------------------------------------------------------------------------------------------------//
   // Clock Inputs                                                                                                    //
   //-----------------------------------------------------------------------------------------------------------------//
   input                                      PIPE_PCLK_IN,
   input                                      PIPE_RXUSRCLK_IN,
   input [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  PIPE_RXOUTCLK_IN,
   input                                      PIPE_DCLK_IN,
   input                                      PIPE_USERCLK1_IN,
   input                                      PIPE_USERCLK2_IN,
   input                                      PIPE_OOBCLK_IN,
   input                                      PIPE_MMCM_LOCK_IN,

   output                                     PIPE_TXOUTCLK_OUT,
   output [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_RXOUTCLK_OUT,
   output [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_PCLK_SEL_OUT,
   output                                     PIPE_GEN3_OUT,

   // Pipe Per-Lane Signals - Lane 0
   output  [ 1:0]               pipe_rx0_char_is_k     ,
   output  [15:0]               pipe_rx0_data          ,
   output                       pipe_rx0_valid         ,
   output                       pipe_rx0_chanisaligned ,
   output  [ 2:0]               pipe_rx0_status        ,
   output                       pipe_rx0_phy_status    ,
   output                       pipe_rx0_elec_idle     ,
   input                        pipe_rx0_polarity      ,
   input                        pipe_tx0_compliance    ,
   input   [ 1:0]               pipe_tx0_char_is_k     ,
   input   [15:0]               pipe_tx0_data          ,
   input                        pipe_tx0_elec_idle     ,
   input   [ 1:0]               pipe_tx0_powerdown     ,

   // Pipe Per-Lane Signals - Lane 1
   output  [ 1:0]               pipe_rx1_char_is_k     ,
   output  [15:0]               pipe_rx1_data          ,
   output                       pipe_rx1_valid         ,
   output                       pipe_rx1_chanisaligned ,
   output  [ 2:0]               pipe_rx1_status        ,
   output                       pipe_rx1_phy_status    ,
   output                       pipe_rx1_elec_idle     ,
   input                        pipe_rx1_polarity      ,
   input                        pipe_tx1_compliance    ,
   input   [ 1:0]               pipe_tx1_char_is_k     ,
   input   [15:0]               pipe_tx1_data          ,
   input                        pipe_tx1_elec_idle     ,
   input   [ 1:0]               pipe_tx1_powerdown     ,

   // Pipe Per-Lane Signals - Lane 2
   output  [ 1:0]               pipe_rx2_char_is_k     ,
   output  [15:0]               pipe_rx2_data          ,
   output                       pipe_rx2_valid         ,
   output                       pipe_rx2_chanisaligned ,
   output  [ 2:0]               pipe_rx2_status        ,
   output                       pipe_rx2_phy_status    ,
   output                       pipe_rx2_elec_idle     ,
   input                        pipe_rx2_polarity      ,
   input                        pipe_tx2_compliance    ,
   input   [ 1:0]               pipe_tx2_char_is_k     ,
   input   [15:0]               pipe_tx2_data          ,
   input                        pipe_tx2_elec_idle     ,
   input   [ 1:0]               pipe_tx2_powerdown     ,

   // Pipe Per-Lane Signals - Lane 3
   output  [ 1:0]               pipe_rx3_char_is_k     ,
   output  [15:0]               pipe_rx3_data          ,
   output                       pipe_rx3_valid         ,
   output                       pipe_rx3_chanisaligned ,
   output  [ 2:0]               pipe_rx3_status        ,
   output                       pipe_rx3_phy_status    ,
   output                       pipe_rx3_elec_idle     ,
   input                        pipe_rx3_polarity      ,
   input                        pipe_tx3_compliance    ,
   input   [ 1:0]               pipe_tx3_char_is_k     ,
   input   [15:0]               pipe_tx3_data          ,
   input                        pipe_tx3_elec_idle     ,
   input   [ 1:0]               pipe_tx3_powerdown     ,

   // Pipe Per-Lane Signals - Lane 4
   output  [ 1:0]               pipe_rx4_char_is_k     ,
   output  [15:0]               pipe_rx4_data          ,
   output                       pipe_rx4_valid         ,
   output                       pipe_rx4_chanisaligned ,
   output  [ 2:0]               pipe_rx4_status        ,
   output                       pipe_rx4_phy_status    ,
   output                       pipe_rx4_elec_idle     ,
   input                        pipe_rx4_polarity      ,
   input                        pipe_tx4_compliance    ,
   input   [ 1:0]               pipe_tx4_char_is_k     ,
   input   [15:0]               pipe_tx4_data          ,
   input                        pipe_tx4_elec_idle     ,
   input   [ 1:0]               pipe_tx4_powerdown     ,

   // Pipe Per-Lane Signals - Lane 5
   output  [ 1:0]               pipe_rx5_char_is_k     ,
   output  [15:0]               pipe_rx5_data          ,
   output                       pipe_rx5_valid         ,
   output                       pipe_rx5_chanisaligned ,
   output  [ 2:0]               pipe_rx5_status        ,
   output                       pipe_rx5_phy_status    ,
   output                       pipe_rx5_elec_idle     ,
   input                        pipe_rx5_polarity      ,
   input                        pipe_tx5_compliance    ,
   input   [ 1:0]               pipe_tx5_char_is_k     ,
   input   [15:0]               pipe_tx5_data          ,
   input                        pipe_tx5_elec_idle     ,
   input   [ 1:0]               pipe_tx5_powerdown     ,

   // Pipe Per-Lane Signals - Lane 6
   output  [ 1:0]               pipe_rx6_char_is_k     ,
   output  [15:0]               pipe_rx6_data          ,
   output                       pipe_rx6_valid         ,
   output                       pipe_rx6_chanisaligned ,
   output  [ 2:0]               pipe_rx6_status        ,
   output                       pipe_rx6_phy_status    ,
   output                       pipe_rx6_elec_idle     ,
   input                        pipe_rx6_polarity      ,
   input                        pipe_tx6_compliance    ,
   input   [ 1:0]               pipe_tx6_char_is_k     ,
   input   [15:0]               pipe_tx6_data          ,
   input                        pipe_tx6_elec_idle     ,
   input   [ 1:0]               pipe_tx6_powerdown     ,

   // Pipe Per-Lane Signals - Lane 7
   output  [ 1:0]               pipe_rx7_char_is_k     ,
   output  [15:0]               pipe_rx7_data          ,
   output                       pipe_rx7_valid         ,
   output                       pipe_rx7_chanisaligned ,
   output  [ 2:0]               pipe_rx7_status        ,
   output                       pipe_rx7_phy_status    ,
   output                       pipe_rx7_elec_idle     ,
   input                        pipe_rx7_polarity      ,
   input                        pipe_tx7_compliance    ,
   input   [ 1:0]               pipe_tx7_char_is_k     ,
   input   [15:0]               pipe_tx7_data          ,
   input                        pipe_tx7_elec_idle     ,
   input   [ 1:0]               pipe_tx7_powerdown     ,

   // PCI Express signals
   output  [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txn            ,
   output  [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txp            ,
   input   [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxn            ,
   input   [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxp            ,

   // Non PIPE signals
   input                        sys_clk                ,
   input                        sys_rst_n              ,
   input                        PIPE_MMCM_RST_N        ,
   output                       pipe_clk               ,
   output                       user_clk               ,
   output                       user_clk2              ,
   output                       clock_locked           ,

   output                       phy_rdy_n
);
   parameter                    BFM_ID     = 0;		// 0..3
   parameter                    BFM_TYPE   = 1'b0;	// 0=>rootport, 1=endpoint
   parameter                    BFM_LANES  = 8;		// 1=>x1, 4=x4 , 8=x8
   parameter                    BFM_WIDTH  = 16;	// 8=>8-bit 16=>16-bit 32=>32bit
   parameter                    IO_SIZE    = 16;
   parameter                    MEM32_SIZE = 16;
   parameter                    MEM64_SIZE = 16;

   assign pipe_rx7_chanisaligned = 1'b1;
   assign pipe_rx6_chanisaligned = 1'b1;
   assign pipe_rx5_chanisaligned = 1'b1;
   assign pipe_rx4_chanisaligned = 1'b1;
   assign pipe_rx3_chanisaligned = 1'b1;
   assign pipe_rx2_chanisaligned = 1'b1;
   assign pipe_rx1_chanisaligned = 1'b1;
   assign pipe_rx0_chanisaligned = 1'b1;      
   
   reg 				     clk62;
   reg 				     clk125;
   reg 				     clk250;
   wire 			     tx_rate;

   assign pipe_clk     = clk125;
   assign user_clk     = clk125;
   assign user_clk2    = clk250;
   assign clock_locked = 1'b1;
   assign tx_rate      = 1'b1;
   
   // tx_rate 
   //  0: 2.5Gps, clk125 125Mhz, clk250 250Mhz
   //  1: 5.0Gps, clk125 250Mhz, clk250 500Mhz
   initial
     begin
	clk125   <= 1'b0;
	clk250   <= 1'b0;
	clk62    <= 1'b0;
     end
   always
     begin
	if (tx_rate)
	  begin
	     #1;
	  end
	else
	  begin
	     #2;
	  end
	clk250 <= ~clk250;
     end // always begin
   always
     begin
	if (tx_rate)
	  begin
	     #2;
	  end
	else
	  begin
	     #4;
	  end
	clk125 <= ~clk125;
     end
   always
     begin
	if (tx_rate)
	  begin
	     #2;
	  end
	else
	  begin
	     #4;
	  end
	clk62 <= ~clk62;
     end
 
   wire phy_status;
   assign phy_status = 1'b0;
   assign phy_rdy_n  = 1'b0;

   wire [7:0] pipe_tx_elec_idle;
   wire [7:0] pipe_tx_compl;
   wire [7:0] pipe_rx_polarity;
   wire [7:0] pipe_rx_elec_idle;
   wire [7:0] pipe_rx_valid;
   
   assign pipe_tx_elec_idle = {pipe_tx7_elec_idle,
			       pipe_tx6_elec_idle,
			       pipe_tx5_elec_idle,
			       pipe_tx4_elec_idle,
			       pipe_tx3_elec_idle,
			       pipe_tx2_elec_idle,
			       pipe_tx1_elec_idle,
			       pipe_tx0_elec_idle};
   assign pipe_tx_compl     = {pipe_tx7_compliance,
			       pipe_tx6_compliance,
			       pipe_tx5_compliance,
			       pipe_tx4_compliance,
			       pipe_tx3_compliance,
			       pipe_tx2_compliance,
			       pipe_tx1_compliance,
			       pipe_tx0_compliance};
   assign pipe_rx_polarity  = {pipe_rx7_polarity,
			       pipe_rx6_polarity,
			       pipe_rx5_polarity,
			       pipe_rx4_polarity,
			       pipe_rx3_polarity,
			       pipe_rx2_polarity,
			       pipe_rx1_polarity,
			       pipe_rx0_polarity};
   assign pipe_rx7_elec_idle = pipe_rx_elec_idle[7];
   assign pipe_rx6_elec_idle = pipe_rx_elec_idle[6];
   assign pipe_rx5_elec_idle = pipe_rx_elec_idle[5];
   assign pipe_rx4_elec_idle = pipe_rx_elec_idle[4];
   assign pipe_rx3_elec_idle = pipe_rx_elec_idle[3];
   assign pipe_rx2_elec_idle = pipe_rx_elec_idle[2];
   assign pipe_rx1_elec_idle = pipe_rx_elec_idle[1];
   assign pipe_rx0_elec_idle = pipe_rx_elec_idle[0];
   
   assign pipe_rx7_valid = pipe_rx_valid[7];
   assign pipe_rx6_valid = pipe_rx_valid[6];
   assign pipe_rx5_valid = pipe_rx_valid[5];
   assign pipe_rx4_valid = pipe_rx_valid[4];
   assign pipe_rx3_valid = pipe_rx_valid[3];
   assign pipe_rx2_valid = pipe_rx_valid[2];
   assign pipe_rx1_valid = pipe_rx_valid[1];
   assign pipe_rx0_valid = pipe_rx_valid[0];

   assign pipe_rx7_phy_status = phy_status;
   assign pipe_rx6_phy_status = phy_status;
   assign pipe_rx5_phy_status = phy_status;
   assign pipe_rx4_phy_status = phy_status;
   assign pipe_rx3_phy_status = phy_status;
   assign pipe_rx2_phy_status = phy_status;
   assign pipe_rx1_phy_status = phy_status;
   assign pipe_rx0_phy_status = phy_status;

   assign pipe_tx_rcvr_det = 1'b0;
   
   /* pldawrap_pipe AUTO_TEMPLATE (
    .rate               (tx_rate),
    .tx_detectrx        (1'b0),
    .power_down         (2'b0),
    
    .tx_elecidle        (pipe_rx_elec_idle[]),
    .tx_compl           (pipe_tx_compl[]),
    .rx_polarity        (pipe_rx_polarity[]),
    .rx_elecidle        (pipe_rx_elec_idle[]),
    .rx_valid           (pipe_rx_valid[]),
    
    .tx_data\([0-7]\)   (pipe_tx\1_data[]),
    .tx_datak\([0-7]\)  (pipe_tx\1_char_is_k[]),
    .rx_data\([0-7]\)   (pipe_rx\1_data[]),
    .rx_datak\([0-7]\)  (pipe_rx\1_char_is_k[]),
    .rx_status\([0-7]\) (pipe_rx\1_status[]),
    
    .chk_\([a-z]+\)     (),
    .rstn               (sys_rst_n),
    );
    */
   pldawrap_pipe #(/*AUTOINSTPARAM*/
		   // Parameters
		   .BFM_ID		(BFM_ID),
		   .BFM_TYPE		(BFM_TYPE),
		   .BFM_LANES		(BFM_LANES),
		   .BFM_WIDTH		(BFM_WIDTH),
		   .IO_SIZE		(IO_SIZE),
		   .MEM32_SIZE		(MEM32_SIZE),
		   .MEM64_SIZE		(MEM64_SIZE))
   pldawrap_pipe  (/*AUTOINST*/
		   // Outputs
		   .phy_status		(phy_status),
		   .rx_elecidle		(pipe_rx_elec_idle[7:0]), // Templated
		   .rx_valid		(pipe_rx_valid[7:0]),	 // Templated
		   .rx_data0		(pipe_rx0_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak0		(pipe_rx0_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status0		(pipe_rx0_status[2:0]),	 // Templated
		   .rx_data1		(pipe_rx1_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak1		(pipe_rx1_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status1		(pipe_rx1_status[2:0]),	 // Templated
		   .rx_data2		(pipe_rx2_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak2		(pipe_rx2_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status2		(pipe_rx2_status[2:0]),	 // Templated
		   .rx_data3		(pipe_rx3_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak3		(pipe_rx3_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status3		(pipe_rx3_status[2:0]),	 // Templated
		   .rx_data4		(pipe_rx4_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak4		(pipe_rx4_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status4		(pipe_rx4_status[2:0]),	 // Templated
		   .rx_data5		(pipe_rx5_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak5		(pipe_rx5_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status5		(pipe_rx5_status[2:0]),	 // Templated
		   .rx_data6		(pipe_rx6_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak6		(pipe_rx6_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status6		(pipe_rx6_status[2:0]),	 // Templated
		   .rx_data7		(pipe_rx7_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak7		(pipe_rx7_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status7		(pipe_rx7_status[2:0]),	 // Templated
		   .chk_txval		(),			 // Templated
		   .chk_txdata		(),			 // Templated
		   .chk_txdatak		(),			 // Templated
		   .chk_rxval		(),			 // Templated
		   .chk_rxdata		(),			 // Templated
		   .chk_rxdatak		(),			 // Templated
		   .chk_ltssm		(),			 // Templated
		   // Inputs
		   .clk62		(clk62),
		   .clk125		(clk125),
		   .clk250		(clk250),
		   .rstn		(sys_rst_n),		 // Templated
		   .rate		(tx_rate),		 // Templated
		   .tx_detectrx		(1'b0),			 // Templated
		   .power_down		(2'b0),			 // Templated
		   .tx_elecidle		(pipe_rx_elec_idle[7:0]), // Templated
		   .tx_compl		(pipe_tx_compl[7:0]),	 // Templated
		   .rx_polarity		(pipe_rx_polarity[7:0]), // Templated
		   .tx_data0		(pipe_tx0_data[BFM_WIDTH-1:0]), // Templated
		   .tx_datak0		(pipe_tx0_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .tx_data1		(pipe_tx1_data[BFM_WIDTH-1:0]), // Templated
		   .tx_datak1		(pipe_tx1_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .tx_data2		(pipe_tx2_data[BFM_WIDTH-1:0]), // Templated
		   .tx_datak2		(pipe_tx2_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .tx_data3		(pipe_tx3_data[BFM_WIDTH-1:0]), // Templated
		   .tx_datak3		(pipe_tx3_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .tx_data4		(pipe_tx4_data[BFM_WIDTH-1:0]), // Templated
		   .tx_datak4		(pipe_tx4_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .tx_data5		(pipe_tx5_data[BFM_WIDTH-1:0]), // Templated
		   .tx_datak5		(pipe_tx5_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .tx_data6		(pipe_tx6_data[BFM_WIDTH-1:0]), // Templated
		   .tx_datak6		(pipe_tx6_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .tx_data7		(pipe_tx7_data[BFM_WIDTH-1:0]), // Templated
		   .tx_datak7		(pipe_tx7_char_is_k[BFM_WIDTH/8-1:0])); // Templated
   
endmodule

