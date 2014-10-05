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
   parameter                PCIE_GT_DEVICE = "GTX",      // Select the GT to use (GTP for Artix-7, GTX for K7/V7)
   parameter               PCIE_PLL_SEL   = "CPLL",     // Select the PLL (CPLL or QPLL)
   parameter               PCIE_ASYNC_EN  = "FALSE",    // Asynchronous Clocking Enable
   parameter               PCIE_TXBUF_EN  = "FALSE",    // Use the Tansmit Buffer
   parameter               PCIE_CHAN_BOND = 0
)
(
   //-----------------------------------------------------------------------------------------------------------------//
   // pl ltssm
   input   wire [5:0]                pl_ltssm_state         ,
   // Pipe Per-Link Signals
   input   wire                      pipe_tx_rcvr_det       ,
   input   wire                      pipe_tx_reset          ,
   input   wire                      pipe_tx_rate           ,
   input   wire                      pipe_tx_deemph         ,
   input   wire [2:0]                pipe_tx_margin         ,
   input   wire                      pipe_tx_swing          ,

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
   output  wire [ 1:0]               pipe_rx0_char_is_k     ,
   output  wire [15:0]               pipe_rx0_data          ,
   output  wire                      pipe_rx0_valid         ,
   output  wire                      pipe_rx0_chanisaligned ,
   output  wire [ 2:0]               pipe_rx0_status        ,
   output  wire                      pipe_rx0_phy_status    ,
   output  wire                      pipe_rx0_elec_idle     ,
   input   wire                      pipe_rx0_polarity      ,
   input   wire                      pipe_tx0_compliance    ,
   input   wire [ 1:0]               pipe_tx0_char_is_k     ,
   input   wire [15:0]               pipe_tx0_data          ,
   input   wire                      pipe_tx0_elec_idle     ,
   input   wire [ 1:0]               pipe_tx0_powerdown     ,

   // Pipe Per-Lane Signals - Lane 1
   output  wire [ 1:0]               pipe_rx1_char_is_k     ,
   output  wire [15:0]               pipe_rx1_data          ,
   output  wire                      pipe_rx1_valid         ,
   output  wire                      pipe_rx1_chanisaligned ,
   output  wire [ 2:0]               pipe_rx1_status        ,
   output  wire                      pipe_rx1_phy_status    ,
   output  wire                      pipe_rx1_elec_idle     ,
   input   wire                      pipe_rx1_polarity      ,
   input   wire                      pipe_tx1_compliance    ,
   input   wire [ 1:0]               pipe_tx1_char_is_k     ,
   input   wire [15:0]               pipe_tx1_data          ,
   input   wire                      pipe_tx1_elec_idle     ,
   input   wire [ 1:0]               pipe_tx1_powerdown     ,

   // Pipe Per-Lane Signals - Lane 2
   output  wire [ 1:0]               pipe_rx2_char_is_k     ,
   output  wire [15:0]               pipe_rx2_data          ,
   output  wire                      pipe_rx2_valid         ,
   output  wire                      pipe_rx2_chanisaligned ,
   output  wire [ 2:0]               pipe_rx2_status        ,
   output  wire                      pipe_rx2_phy_status    ,
   output  wire                      pipe_rx2_elec_idle     ,
   input   wire                      pipe_rx2_polarity      ,
   input   wire                      pipe_tx2_compliance    ,
   input   wire [ 1:0]               pipe_tx2_char_is_k     ,
   input   wire [15:0]               pipe_tx2_data          ,
   input   wire                      pipe_tx2_elec_idle     ,
   input   wire [ 1:0]               pipe_tx2_powerdown     ,

   // Pipe Per-Lane Signals - Lane 3
   output  wire [ 1:0]               pipe_rx3_char_is_k     ,
   output  wire [15:0]               pipe_rx3_data          ,
   output  wire                      pipe_rx3_valid         ,
   output  wire                      pipe_rx3_chanisaligned ,
   output  wire [ 2:0]               pipe_rx3_status        ,
   output  wire                      pipe_rx3_phy_status    ,
   output  wire                      pipe_rx3_elec_idle     ,
   input   wire                      pipe_rx3_polarity      ,
   input   wire                      pipe_tx3_compliance    ,
   input   wire [ 1:0]               pipe_tx3_char_is_k     ,
   input   wire [15:0]               pipe_tx3_data          ,
   input   wire                      pipe_tx3_elec_idle     ,
   input   wire [ 1:0]               pipe_tx3_powerdown     ,

   // Pipe Per-Lane Signals - Lane 4
   output  wire [ 1:0]               pipe_rx4_char_is_k     ,
   output  wire [15:0]               pipe_rx4_data          ,
   output  wire                      pipe_rx4_valid         ,
   output  wire                      pipe_rx4_chanisaligned ,
   output  wire [ 2:0]               pipe_rx4_status        ,
   output  wire                      pipe_rx4_phy_status    ,
   output  wire                      pipe_rx4_elec_idle     ,
   input   wire                      pipe_rx4_polarity      ,
   input   wire                      pipe_tx4_compliance    ,
   input   wire [ 1:0]               pipe_tx4_char_is_k     ,
   input   wire [15:0]               pipe_tx4_data          ,
   input   wire                      pipe_tx4_elec_idle     ,
   input   wire [ 1:0]               pipe_tx4_powerdown     ,

   // Pipe Per-Lane Signals - Lane 5
   output  wire [ 1:0]               pipe_rx5_char_is_k     ,
   output  wire [15:0]               pipe_rx5_data          ,
   output  wire                      pipe_rx5_valid         ,
   output  wire                      pipe_rx5_chanisaligned ,
   output  wire [ 2:0]               pipe_rx5_status        ,
   output  wire                      pipe_rx5_phy_status    ,
   output  wire                      pipe_rx5_elec_idle     ,
   input   wire                      pipe_rx5_polarity      ,
   input   wire                      pipe_tx5_compliance    ,
   input   wire [ 1:0]               pipe_tx5_char_is_k     ,
   input   wire [15:0]               pipe_tx5_data          ,
   input   wire                      pipe_tx5_elec_idle     ,
   input   wire [ 1:0]               pipe_tx5_powerdown     ,

   // Pipe Per-Lane Signals - Lane 6
   output  wire [ 1:0]               pipe_rx6_char_is_k     ,
   output  wire [15:0]               pipe_rx6_data          ,
   output  wire                      pipe_rx6_valid         ,
   output  wire                      pipe_rx6_chanisaligned ,
   output  wire [ 2:0]               pipe_rx6_status        ,
   output  wire                      pipe_rx6_phy_status    ,
   output  wire                      pipe_rx6_elec_idle     ,
   input   wire                      pipe_rx6_polarity      ,
   input   wire                      pipe_tx6_compliance    ,
   input   wire [ 1:0]               pipe_tx6_char_is_k     ,
   input   wire [15:0]               pipe_tx6_data          ,
   input   wire                      pipe_tx6_elec_idle     ,
   input   wire [ 1:0]               pipe_tx6_powerdown     ,

   // Pipe Per-Lane Signals - Lane 7
   output  wire [ 1:0]               pipe_rx7_char_is_k     ,
   output  wire [15:0]               pipe_rx7_data          ,
   output  wire                      pipe_rx7_valid         ,
   output  wire                      pipe_rx7_chanisaligned ,
   output  wire [ 2:0]               pipe_rx7_status        ,
   output  wire                      pipe_rx7_phy_status    ,
   output  wire                      pipe_rx7_elec_idle     ,
   input   wire                      pipe_rx7_polarity      ,
   input   wire                      pipe_tx7_compliance    ,
   input   wire [ 1:0]               pipe_tx7_char_is_k     ,
   input   wire [15:0]               pipe_tx7_data          ,
   input   wire                      pipe_tx7_elec_idle     ,
   input   wire [ 1:0]               pipe_tx7_powerdown     ,

   // PCI Express signals
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txn            ,
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txp            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxn            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxp            ,

   // Non PIPE signals
   input   wire                      sys_clk                ,
   input   wire                      sys_rst_n              ,
   input   wire                      PIPE_MMCM_RST_N        ,
   output  wire                      pipe_clk               ,
   output  wire                      user_clk               ,
   output  wire                      user_clk2              ,
   output  wire                      clock_locked           ,

   output  wire                      phy_rdy_n
);
  localparam                          TCQ  = 100;      // clock to out delay model

  //---------------------------------------------------- PIPE SIMULATION --------------------------------------------------------------------//
  localparam      LINK_CAP_MAX_LINK_SPEED = (PL_FAST_TRAIN == "TRUE") ? 2 : 3;
  localparam      USERCLK2_FREQ   =  (USER_CLK2_DIV2 == "FALSE") ? USER_CLK_FREQ :
                                                        (USER_CLK_FREQ == 4) ? 3 :
                                                        (USER_CLK_FREQ == 3) ? 2 :
                                                       USER_CLK_FREQ;
   wire pcl_sel_sim;
   reg [15:0] pipe_cnt1 = 0;
   reg phy_rdy_ni = 0;
   //--------------------------------------------------------------------//  
        pcie_7x_v1_10_pipe_clock #
        (
            .PCIE_ASYNC_EN                  (PCIE_ASYNC_EN),        // PCIe async enable
            .PCIE_TXBUF_EN                  (PCIE_TXBUF_EN),        // PCIe TX buffer enable for Gen1/Gen2 only
            .PCIE_LANE                      (LINK_CAP_MAX_LINK_WIDTH),            // PCIe number of lanes
            .PCIE_LINK_SPEED                (LINK_CAP_MAX_LINK_SPEED),      // PCIe link speed
            .PCIE_REFCLK_FREQ               (REF_CLK_FREQ),     // PCIe reference clock frequency
            .PCIE_USERCLK1_FREQ             (USER_CLK_FREQ + 1),   // PCIe user clock 1 frequency
            .PCIE_USERCLK2_FREQ             (USERCLK2_FREQ + 1),   // PCIe user clock 2 frequency
            .PCIE_DEBUG_MODE                (1'b0)       // PCIe debug mode
        )
        pipe_clock_i
        (
            //---------- Input -------------------------------------
            .CLK_CLK                        (sys_clk),
            .CLK_TXOUTCLK                   (sys_clk),       // Reference clock from lane 0
            .CLK_RXOUTCLK_IN                ({LINK_CAP_MAX_LINK_WIDTH {1'b0}}),
            .CLK_RST_N                      (1'b1),
            .CLK_PCLK_SEL                   ({LINK_CAP_MAX_LINK_WIDTH {pcl_sel_sim}}),
            .CLK_GEN3                       (1'b0),

            //---------- Output ------------------------------------
            .CLK_PCLK                       (pipe_clk),
            .CLK_RXUSRCLK                   ( ),
            .CLK_RXOUTCLK_OUT               (PIPE_RXOUTCLK_OUT),
            .CLK_DCLK                       ( ),
            .CLK_USERCLK1                   (user_clk),
            .CLK_USERCLK2                   (user_clk2),
            .CLK_MMCM_LOCK                  ( )
        );
   //--------------------------------------------------------------------//  
   always @(posedge pipe_clk)
   begin
       if (sys_rst_n == 0) begin
           pipe_cnt1 <= #TCQ 0;
       end else begin
     //--------------------------------------------------------------------//  
          if (pipe_cnt1 == 8190)
              pipe_cnt1 <= #TCQ 0;
          else begin
             if (pipe_tx_rcvr_det || pipe_cnt1 >= 100) 
                 pipe_cnt1 <= #TCQ pipe_cnt1 + 1;
             else
                 pipe_cnt1 <= #TCQ 0;
          end
     //--------------------------------------------------------------------//  
       end
   end 
   //--------------------------------------------------------------------//  
   assign pipe_rx0_phy_status    =  (((pipe_tx_rate == 1) && (pipe_cnt1 == 4000) && (pl_ltssm_state == 6'b011111)) ? 1 : 
                                    ((pipe_cnt1 == 1100) ? 1 : ((pipe_cnt1 == 1500) ? 1 : 0))); 
   assign pipe_rx1_phy_status    =  pipe_rx0_phy_status; 
   assign pipe_rx2_phy_status    =  pipe_rx0_phy_status; 
   assign pipe_rx3_phy_status    =  pipe_rx0_phy_status; 
   assign pipe_rx4_phy_status    =  pipe_rx0_phy_status; 
   assign pipe_rx5_phy_status    =  pipe_rx0_phy_status; 
   assign pipe_rx6_phy_status    =  pipe_rx0_phy_status; 
   assign pipe_rx7_phy_status    =  pipe_rx0_phy_status; 
   //--------------------------------------------------------------------//  
   assign pipe_rx0_chanisaligned =  (((sys_rst_n == 1 && pipe_tx_rate == 0 ) ? 1 : (sys_rst_n == 0 && pipe_tx_rate == 0) ? 0 : 
                                    ((pipe_tx_rate == 1) && (pipe_cnt1 == 3350) && (pl_ltssm_state == 6'b011111)) ? 0 : 
                                    ((pipe_tx_rate == 1) && (pipe_cnt1 == 4100)  ? 1 : pipe_rx0_chanisaligned ))) ;
   assign pipe_rx1_chanisaligned = pipe_rx0_chanisaligned; 
   assign pipe_rx2_chanisaligned = pipe_rx0_chanisaligned; 
   assign pipe_rx3_chanisaligned = pipe_rx0_chanisaligned; 
   assign pipe_rx4_chanisaligned = pipe_rx0_chanisaligned; 
   assign pipe_rx5_chanisaligned = pipe_rx0_chanisaligned; 
   assign pipe_rx6_chanisaligned = pipe_rx0_chanisaligned; 
   assign pipe_rx7_chanisaligned = pipe_rx0_chanisaligned;
 
   //--------------------------------------------------------------------------------------------------------------------------------------------------------//  
   assign pipe_rx0_status        =  ((sys_rst_n == 0) ? 0 :  
                                    ((pipe_tx_rate == 1) && (pipe_cnt1 == 3400) && (pl_ltssm_state == 6'b011111)) ? 4 : 
                                    ((pipe_tx_rate == 1) && (pipe_cnt1 == 3450) && (pl_ltssm_state == 6'b011111)) ? 0 : 
                                    ((pipe_cnt1 == 1100) ? 3 : (pipe_cnt1 == 1101) ? 0 : pipe_rx0_status));  
   assign pipe_rx1_status        =  pipe_rx0_status;  
   assign pipe_rx2_status        =  pipe_rx0_status;  
   assign pipe_rx3_status        =  pipe_rx0_status;  
   assign pipe_rx4_status        =  pipe_rx0_status;  
   assign pipe_rx5_status        =  pipe_rx0_status;  
   assign pipe_rx6_status        =  pipe_rx0_status;  
   assign pipe_rx7_status        =  pipe_rx0_status;  
   //--------------------------------------------------------------------//  
   assign pipe_rx0_valid         =  (((pipe_tx_rate == 1) && (pipe_cnt1 == 3300) && (pl_ltssm_state == 6'b011111)) ? 0 : 
                                    ((pipe_tx_rate == 1) && (pipe_cnt1 == 4120)  ? 1 :
                                    ((sys_rst_n == 0 && pipe_tx_rate == 0) ? 0 : ((pipe_rx0_data != 0 && pipe_tx_rate == 0) ? 1 : pipe_rx0_valid))));  
   assign pipe_rx1_valid         =  pipe_rx0_valid;
   assign pipe_rx2_valid         =  pipe_rx0_valid;
   assign pipe_rx3_valid         =  pipe_rx0_valid;
   assign pipe_rx4_valid         =  pipe_rx0_valid;
   assign pipe_rx5_valid         =  pipe_rx0_valid;
   assign pipe_rx6_valid         =  pipe_rx0_valid;
   assign pipe_rx7_valid         =  pipe_rx0_valid;
   //--------------------------------------------------------------------//  
   assign pipe_rx0_elec_idle     =  0;
   assign pipe_rx1_elec_idle     =  0;
   assign pipe_rx2_elec_idle     =  0;
   assign pipe_rx3_elec_idle     =  0;
   assign pipe_rx4_elec_idle     =  0;
   assign pipe_rx5_elec_idle     =  0;
   assign pipe_rx6_elec_idle     =  0;
   assign pipe_rx7_elec_idle     =  0;
   //--------------------------------------------------------------------//  
   assign phy_rdy_n = phy_rdy_ni;
   //--------------------------------------------------------------------//  
   assign pcl_sel_sim            =  ((sys_rst_n == 0 && pipe_tx_rate == 0) ? 0 : ((pipe_tx_rate == 1) && (pipe_cnt1 == 3500)) ? 1 : pcl_sel_sim);
   //--------------------------------------------------------------------// 
   initial begin
   phy_rdy_ni =  1'b1;
   #20000; 
   phy_rdy_ni =  1'b0;
   end
   //--------------------------------------------------------------------// 

   //assign pipe_rx0_char_is_k = pipe_tx0_char_is_k;
   //assign pipe_rx0_data      = pipe_tx0_data;
   //assign pipe_rx1_char_is_k = pipe_tx1_char_is_k;
   //assign pipe_rx1_data      = pipe_tx1_data;
   //assign pipe_rx2_char_is_k = pipe_tx2_char_is_k;
   //assign pipe_rx2_data      = pipe_tx2_data;
   //assign pipe_rx3_char_is_k = pipe_tx3_char_is_k;
   //assign pipe_rx3_data      = pipe_tx3_data;
   //assign pipe_rx4_char_is_k = pipe_tx4_char_is_k;
   //assign pipe_rx4_data      = pipe_tx4_data;
   //assign pipe_rx5_char_is_k = pipe_tx5_char_is_k;
   //assign pipe_rx5_data      = pipe_tx5_data;
   //assign pipe_rx6_char_is_k = pipe_tx6_char_is_k;
   //assign pipe_rx6_data      = pipe_tx6_data;
   //assign pipe_rx7_char_is_k = pipe_tx7_char_is_k;
   //assign pipe_rx7_data      = pipe_tx7_data;

   parameter                    BFM_ID     = 0;		// 0..3
   parameter                    BFM_TYPE   = 1'b0;	// 0=>rootport, 1=endpoint
   parameter                    BFM_LANES  = 8;		// 1=>x1, 4=x4 , 8=x8
   parameter                    BFM_WIDTH  = 16;	// 8=>8-bit 16=>16-bit 32=>32bit
   parameter                    IO_SIZE    = 16;
   parameter                    MEM32_SIZE = 16;
   parameter                    MEM64_SIZE = 16;

   wire [7:0] pipe_tx_elec_idle;
   wire [7:0] pipe_tx_compl;
   wire [7:0] pipe_rx_polarity;
   assign pipe_tx_elec_idle = 8'h0;
   assign pipe_tx_compl     = 8'h0;
   assign pipe_rx_polarity  = 8'h0;
   
   reg clk125;
   reg clk250;
   wire tx_rate;
   assign tx_rate = 1'b0;
   // tx_rate 
   //  0: 2.5Gps, clk125 125Mhz, clk250 250Mhz
   //  1: 5.0Gps, clk125 250Mhz, clk250 500Mhz
   initial
     begin
	clk125   <= 1'b0;
	clk250   <= 1'b0;
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

   wire                       chk_txval;
   wire [63:0]                chk_txdata;
   wire [7:0]                 chk_txdatak;
   wire                       chk_rxval;
   wire [63:0]                chk_rxdata;
   wire [7:0]                 chk_rxdatak;
   wire [4:0]                 chk_ltssm;
   /* pldawrap_pipe AUTO_TEMPLATE (
    .rate               (tx_rate), // I
    .tx_detectrx        (1'b0),    // I
    .power_down         (2'b0),    // I
    
    .tx_elecidle        (pipe_tx_elec_idle[]), // I
    .tx_compl           (pipe_tx_compl[]),     // I
    .rx_polarity        (pipe_rx_polarity[]),  // I
    .rx_elecidle        (), // O
    .rx_valid           (), // O
    
    .tx_data\([0-7]\)   (pipe_tx\1_data[]),
    .tx_datak\([0-7]\)  (pipe_tx\1_char_is_k[]),
    .rx_data\([0-7]\)   (pipe_rx\1_data[]),
    .rx_datak\([0-7]\)  (pipe_rx\1_char_is_k[]),
    
    //.tx_data\([0-7]\)   ({pipe_tx\1_data[7:0],    pipe_tx\1_data[15:8]}),
    //.tx_datak\([0-7]\)  ({pipe_tx\1_char_is_k[0], pipe_tx\1_char_is_k[1]}),
    //.rx_data\([0-7]\)   ({pipe_rx\1_data[7:0],    pipe_rx\1_data[15:8]}),
    //.rx_datak\([0-7]\)  ({pipe_rx\1_char_is_k[0], pipe_rx\1_char_is_k[1]}),

    .rx_status\([0-7]\) (),
    .rstn               (sys_rst_n),
    .clk62              (),
    .clk125             (clk125),
    .clk250             (clk250),
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
		   .rx_elecidle		(),			 // Templated
		   .rx_valid		(),			 // Templated
		   .rx_data0		(pipe_rx0_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak0		(pipe_rx0_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status0		(),			 // Templated
		   .rx_data1		(pipe_rx1_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak1		(pipe_rx1_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status1		(),			 // Templated
		   .rx_data2		(pipe_rx2_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak2		(pipe_rx2_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status2		(),			 // Templated
		   .rx_data3		(pipe_rx3_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak3		(pipe_rx3_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status3		(),			 // Templated
		   .rx_data4		(pipe_rx4_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak4		(pipe_rx4_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status4		(),			 // Templated
		   .rx_data5		(pipe_rx5_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak5		(pipe_rx5_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status5		(),			 // Templated
		   .rx_data6		(pipe_rx6_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak6		(pipe_rx6_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status6		(),			 // Templated
		   .rx_data7		(pipe_rx7_data[BFM_WIDTH-1:0]), // Templated
		   .rx_datak7		(pipe_rx7_char_is_k[BFM_WIDTH/8-1:0]), // Templated
		   .rx_status7		(),			 // Templated
		   .chk_txval		(chk_txval),
		   .chk_txdata		(chk_txdata[63:0]),
		   .chk_txdatak		(chk_txdatak[7:0]),
		   .chk_rxval		(chk_rxval),
		   .chk_rxdata		(chk_rxdata[63:0]),
		   .chk_rxdatak		(chk_rxdatak[7:0]),
		   .chk_ltssm		(chk_ltssm[4:0]),
		   // Inputs
		   .clk62		(),			 // Templated
		   .clk125		(clk125),		 // Templated
		   .clk250		(clk250),		 // Templated
		   .rstn		(sys_rst_n),		 // Templated
		   .rate		(tx_rate),		 // Templated
		   .tx_detectrx		(1'b0),			 // Templated
		   .power_down		(2'b0),			 // Templated
		   .tx_elecidle		(pipe_tx_elec_idle[7:0]), // Templated
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

   parameter PCIE_DEVCTRL_REG_ADDR = 8'h88;
   parameter MAX_PAYLOAD = 256;
   
`include "pkg_xbfm_defines.h"

`define BFM pldawrap_pipe

   reg [15:0] csr;
   reg [32767:0] databuf;

   initial
     begin
	// Initialise BFM
	#30000

	`BFM.xbfm_print_comment ("### Initialise BFM");

	`BFM.xbfm_print_comment ("### BFM: 0");
	`BFM.xbfm_init (32'h00000000,32'hAAAA0000,64'hBBBBBBBBCCCC0000);
	`BFM.xbfm_print_comment ("### BFM: 1");
	`BFM.xbfm_set_requesterid (16'h0008);
	`BFM.xbfm_print_comment ("### BFM: 2");
	`BFM.xbfm_set_maxpayload  (MAX_PAYLOAD);
	
	 // Wait for link to get initialised then disable PIPE logging
	`BFM.xbfm_print_comment ("### BFM: 3");
	`BFM.xbfm_wait_linkup;
	`BFM.xbfm_print_comment ("### BFM: 4");
	`BFM.xbfm_configure_log(`XBFM_LOG_NOPIPE);
	`BFM.xbfm_print_comment ("### BFM: 5");
     end
endmodule
