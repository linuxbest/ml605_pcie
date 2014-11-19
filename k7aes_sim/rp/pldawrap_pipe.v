`timescale 1 ns / 1 ps

//-----------------------------------------------------------------------------
// This confidential and proprietary software may be used only as authorized by
// a licensing agreement from PLDApplications. In the event of publication, a
// copyright notice must be reproduced on all authorized copies.
//
//-----------------------------------------------------------------------------
// Project : PCIEBFM
// $RCSfile: pldawrap_pipe.v,v $
// $Date: 2012/11/15 13:26:31 $
// $Revision: 1.2 $
// $Name: QuickPCIe_v141_b025_rev1 $
// $Author: stvutev $
//-----------------------------------------------------------------------------
// Dependency  :
//-----------------------------------------------------------------------------
// Description : PLDA PCIeBFM wrapper with PIPE interface
//-----------------------------------------------------------------------------
// Revision:
// $Log: pldawrap_pipe.v,v $
// Revision 1.2  2012/11/15 13:26:31  stvutev
// Updated to ezdma_v146_b205 with tag QuickPCIe_v141_b025_rev1
//
// Revision 1.19  2010/07/26 10:22:49  plegros
// Fixed potential clock race issue in 32/16=>8 bit conversion
//
// Revision 1.16  2010/07/12 12:24:59  plegros
// More robust toggle_r implementation
//
// Revision 1.15  2010/06/11 11:53:46  plegros
// Fixed toggle_r
//
// Revision 1.14  2010/06/08 13:50:18  plegros
// Added support for 32-bit PIPE interface
//
// Revision 1.13  2008/10/24 12:21:43  plegros
// Fix for ALDEC verilog encryption
//
// Revision 1.12  2008/07/23 09:20:53  plegros
// Added x2 support, fix for XHDL4 translation
//
// Revision 1.11  2007/12/04 15:55:07  plegros
// Added rate output to pciebfm_top
//
// Revision 1.10  2007/11/13 09:36:57  plegros
// Added support for configurable memory space size
//
// Revision 1.9  2007/11/07 14:51:15  plegros
// Added rate input
//
// Revision 1.8  2007/01/09 10:04:03  rtuszewski
//  - add checker signals
//
// Revision 1.7  2006/08/01 11:29:20  plegros
// Removed BFM_CHECKER parameter inside BFM
//
// Revision 1.6  2006/07/06 13:19:47  plegros
// Fixed tx_compliance
//
// Revision 1.5  2006/07/04 15:32:22  plegros
// *** empty log message ***
//
// Revision 1.4  2006/07/04 12:35:59  plegros
// Added vlog reference to package xbfm_defines
//
// Revision 1.3  2006/06/28 14:05:46  plegros
// Fix for VHDL-VLOG translation
//
// Revision 1.2  2006/06/15 13:46:48  wmullergegler
// *** empty log message ***
//
// Revision 1.1.1.1  2006/06/15 10:13:05  plegros
// Initial release
//
// Revision 1.4  2006/06/01 11:53:41  plegros
// Update for version 1.0
//
// Revision 1.3  2006/05/23 08:09:26  plegros
// Added PCS test mode
//
// Revision 1.2  2006/05/02 14:14:37  plegros
// Clock/reset generation is now on top
//
// Revision 1.1.1.1  2006/04/27 12:59:12  plegros
// Initial release
//
//
//-----------------------------------------------------------------------------

//------------------------------------------------------------------

module pldawrap_pipe(clk62, clk125, clk250, rstn, rate, tx_detectrx, phy_status, power_down, tx_elecidle, tx_compl, rx_polarity, rx_elecidle, rx_valid, tx_data0, tx_datak0, rx_data0, rx_datak0, rx_status0, tx_data1, tx_datak1, rx_data1, rx_datak1, rx_status1, tx_data2, tx_datak2, rx_data2, rx_datak2, rx_status2, tx_data3, tx_datak3, rx_data3, rx_datak3, rx_status3, tx_data4, tx_datak4, rx_data4, rx_datak4, rx_status4, tx_data5, tx_datak5, rx_data5, rx_datak5, rx_status5, tx_data6, tx_datak6, rx_data6, rx_datak6, rx_status6, tx_data7, tx_datak7, rx_data7, rx_datak7, rx_status7, chk_txval, chk_txdata, chk_txdatak, chk_rxval, chk_rxdata, chk_rxdatak, chk_ltssm);
   parameter                    BFM_ID = 0;		// 0..3
   parameter                    BFM_TYPE = 1'b0;		// 0=>rootport, 1=endpoint
   parameter                    BFM_LANES = 4;		// 1=>x1, 4=x4 , 8=x8
   parameter                    BFM_WIDTH = 16;		// 8=>8-bit 16=>16-bit 32=>32bit
   parameter                    IO_SIZE = 16;
   parameter                    MEM32_SIZE = 16;
   parameter                    MEM64_SIZE = 16;
   input                        clk62;
   input                        clk125;
   input                        clk250;
   input                        rstn;
   
   // 8/16-bit PIPE interface
   input                        rate;
   input                        tx_detectrx;
   output reg                   phy_status;
   input [1:0]                  power_down;
   
   input [7:0]                  tx_elecidle;
   input [7:0]                  tx_compl;
   input [7:0]                  rx_polarity;
   output reg [7:0]             rx_elecidle;
   output reg [7:0]             rx_valid;
   
   input [BFM_WIDTH-1:0]        tx_data0;
   input [BFM_WIDTH/8-1:0]      tx_datak0;
   output reg [BFM_WIDTH-1:0]   rx_data0;
   output reg [BFM_WIDTH/8-1:0] rx_datak0;
   output reg [2:0]             rx_status0;
   
   input [BFM_WIDTH-1:0]        tx_data1;
   input [BFM_WIDTH/8-1:0]      tx_datak1;
   output reg [BFM_WIDTH-1:0]   rx_data1;
   output reg [BFM_WIDTH/8-1:0] rx_datak1;
   output reg [2:0]             rx_status1;
   
   input [BFM_WIDTH-1:0]        tx_data2;
   input [BFM_WIDTH/8-1:0]      tx_datak2;
   output reg [BFM_WIDTH-1:0]   rx_data2;
   output reg [BFM_WIDTH/8-1:0] rx_datak2;
   output reg [2:0]             rx_status2;
   
   input [BFM_WIDTH-1:0]        tx_data3;
   input [BFM_WIDTH/8-1:0]      tx_datak3;
   output reg [BFM_WIDTH-1:0]   rx_data3;
   output reg [BFM_WIDTH/8-1:0] rx_datak3;
   output reg [2:0]             rx_status3;
   
   input [BFM_WIDTH-1:0]        tx_data4;
   input [BFM_WIDTH/8-1:0]      tx_datak4;
   output reg [BFM_WIDTH-1:0]   rx_data4;
   output reg [BFM_WIDTH/8-1:0] rx_datak4;
   output reg [2:0]             rx_status4;
   
   input [BFM_WIDTH-1:0]        tx_data5;
   input [BFM_WIDTH/8-1:0]      tx_datak5;
   output reg [BFM_WIDTH-1:0]   rx_data5;
   output reg [BFM_WIDTH/8-1:0] rx_datak5;
   output reg [2:0]             rx_status5;
   
   input [BFM_WIDTH-1:0]        tx_data6;
   input [BFM_WIDTH/8-1:0]      tx_datak6;
   output reg [BFM_WIDTH-1:0]   rx_data6;
   output reg [BFM_WIDTH/8-1:0] rx_datak6;
   output reg [2:0]             rx_status6;
   
   input [BFM_WIDTH-1:0]        tx_data7;
   input [BFM_WIDTH/8-1:0]      tx_datak7;
   output reg [BFM_WIDTH-1:0]   rx_data7;
   output reg [BFM_WIDTH/8-1:0] rx_datak7;
   output reg [2:0]             rx_status7;
   
   // checker interface
   output                       chk_txval;
   output [63:0]                chk_txdata;
   output [7:0]                 chk_txdatak;
   output                       chk_rxval;
   output [63:0]                chk_rxdata;
   output [7:0]                 chk_rxdatak;
   output [4:0]                 chk_ltssm;
   
   //------------------------------------------------------------------
   
   // 0..3
   // 0=>rootport, 1=endpoint
   // 1=>x1, 4=x4 , 8=x8
   
   // 1=>x1, 4=x4 , 8=x8
   
`include "pkg_xbfm_defines.h"
`include "pkg_xbfm.h"
   
   // PIPE 8-bit interface
   reg [7:0]                    txdata0;
   reg [7:0]                    txdata1;
   reg [7:0]                    txdata2;
   reg [7:0]                    txdata3;
   reg [7:0]                    txdata4;
   reg [7:0]                    txdata5;
   reg [7:0]                    txdata6;
   reg [7:0]                    txdata7;
   reg [7:0]                    txdatak;
   reg [7:0]                    txcompl;
   reg [7:0]                    rxpolarity;
   reg [7:0]                    txelecidle;
   wire [7:0]                   rxelecidle;
   wire [7:0]                   rxdatak;
   wire [7:0]                   rxvalid;
   wire [7:0]                   rxdata0;
   wire [7:0]                   rxdata1;
   wire [7:0]                   rxdata2;
   wire [7:0]                   rxdata3;
   wire [7:0]                   rxdata4;
   wire [7:0]                   rxdata5;
   wire [7:0]                   rxdata6;
   wire [7:0]                   rxdata7;
   wire [2:0]                   rxstatus0;
   wire [2:0]                   rxstatus1;
   wire [2:0]                   rxstatus2;
   wire [2:0]                   rxstatus3;
   wire [2:0]                   rxstatus4;
   wire [2:0]                   rxstatus5;
   wire [2:0]                   rxstatus6;
   wire [2:0]                   rxstatus7;
   
   // PCS interface
   wire [7:0]                   rx_val;
   wire [7:0]                   tx_val;
   wire [7:0]                   rx_eidle;
   wire [7:0]                   tx_eidle;
   wire [7:0]                   detect;
   wire [79:0]                  rx_10b;
   wire [79:0]                  tx_10b;
   
   // Wrapping logic
   reg [31:0]                   rxd0_reg;
   reg [31:0]                   rxd1_reg;
   reg [31:0]                   rxd2_reg;
   reg [31:0]                   rxd3_reg;
   reg [31:0]                   rxd4_reg;
   reg [31:0]                   rxd5_reg;
   reg [31:0]                   rxd6_reg;
   reg [31:0]                   rxd7_reg;
   reg [31:0]                   rxdk_reg;
   reg [11:0]                   rxsts0_reg;
   reg [11:0]                   rxsts1_reg;
   reg [11:0]                   rxsts2_reg;
   reg [11:0]                   rxsts3_reg;
   reg [11:0]                   rxsts4_reg;
   reg [11:0]                   rxsts5_reg;
   reg [11:0]                   rxsts6_reg;
   reg [11:0]                   rxsts7_reg;
   reg [3:0]                    phystatus_reg;
   
   reg [7:0]                    tx_compl_r;
   reg [7:0]                    tx_elecidle_r;
   reg [7:0]                    rx_polarity_r;
   reg [BFM_WIDTH-1:0]          tx_data0_r;
   reg [BFM_WIDTH-1:0]          tx_data1_r;
   reg [BFM_WIDTH-1:0]          tx_data2_r;
   reg [BFM_WIDTH-1:0]          tx_data3_r;
   reg [BFM_WIDTH-1:0]          tx_data4_r;
   reg [BFM_WIDTH-1:0]          tx_data5_r;
   reg [BFM_WIDTH-1:0]          tx_data6_r;
   reg [BFM_WIDTH-1:0]          tx_data7_r;
   reg [BFM_WIDTH/8-1:0]        tx_datak0_r;
   reg [BFM_WIDTH/8-1:0]        tx_datak1_r;
   reg [BFM_WIDTH/8-1:0]        tx_datak2_r;
   reg [BFM_WIDTH/8-1:0]        tx_datak3_r;
   reg [BFM_WIDTH/8-1:0]        tx_datak4_r;
   reg [BFM_WIDTH/8-1:0]        tx_datak5_r;
   reg [BFM_WIDTH/8-1:0]        tx_datak6_r;
   reg [BFM_WIDTH/8-1:0]        tx_datak7_r;
   reg [1:0]                    power_down_r;
   reg                          tx_detectrx_r;
   
   reg                          txdetectrx;
   wire                         phystatus;
   wire                         pclk;
   reg [1:0]                    powerdown;
   reg [1:0]                    pclk_r;
   reg [1:0]                    toggle_r;
   //-------------------------------------------------------
   // PIPE 32bit@62.5Mhz <=> PIPE 8bit@250MHz interface
   //-------------------------------------------------------
   
   generate
      if (BFM_WIDTH == 32)
      begin : gpipe32b
         assign pclk = clk62;
         
         
         always @(posedge clk62 or negedge rstn)
            if (rstn == 1'b0)
            begin
               rx_data0 <= {BFM_WIDTH{1'b0}};
               rx_data1 <= {BFM_WIDTH{1'b0}};
               rx_data2 <= {BFM_WIDTH{1'b0}};
               rx_data3 <= {BFM_WIDTH{1'b0}};
               rx_data4 <= {BFM_WIDTH{1'b0}};
               rx_data5 <= {BFM_WIDTH{1'b0}};
               rx_data6 <= {BFM_WIDTH{1'b0}};
               rx_data7 <= {BFM_WIDTH{1'b0}};
               rx_datak0 <= {BFM_WIDTH/8{1'b0}};
               rx_datak1 <= {BFM_WIDTH/8{1'b0}};
               rx_datak2 <= {BFM_WIDTH/8{1'b0}};
               rx_datak3 <= {BFM_WIDTH/8{1'b0}};
               rx_datak4 <= {BFM_WIDTH/8{1'b0}};
               rx_datak5 <= {BFM_WIDTH/8{1'b0}};
               rx_datak6 <= {BFM_WIDTH/8{1'b0}};
               rx_datak7 <= {BFM_WIDTH/8{1'b0}};
               rx_status0 <= 3'b000;
               rx_status1 <= 3'b000;
               rx_status2 <= 3'b000;
               rx_status3 <= 3'b000;
               rx_status4 <= 3'b000;
               rx_status5 <= 3'b000;
               rx_status6 <= 3'b000;
               rx_status7 <= 3'b000;
               rx_elecidle <= {8{1'b1}};
               rx_valid <= {8{1'b0}};
               phy_status <= 1'b1;
            end
            else 
            begin
               rx_data0 <= {rxd0_reg[7:0], rxd0_reg[15:8], rxd0_reg[23:16], rxd0_reg[31:24]};
               rx_data1 <= {rxd1_reg[7:0], rxd1_reg[15:8], rxd1_reg[23:16], rxd1_reg[31:24]};
               rx_data2 <= {rxd2_reg[7:0], rxd2_reg[15:8], rxd2_reg[23:16], rxd2_reg[31:24]};
               rx_data3 <= {rxd3_reg[7:0], rxd3_reg[15:8], rxd3_reg[23:16], rxd3_reg[31:24]};
               rx_data4 <= {rxd4_reg[7:0], rxd4_reg[15:8], rxd4_reg[23:16], rxd4_reg[31:24]};
               rx_data5 <= {rxd5_reg[7:0], rxd5_reg[15:8], rxd5_reg[23:16], rxd5_reg[31:24]};
               rx_data6 <= {rxd6_reg[7:0], rxd6_reg[15:8], rxd6_reg[23:16], rxd6_reg[31:24]};
               rx_data7 <= {rxd7_reg[7:0], rxd7_reg[15:8], rxd7_reg[23:16], rxd7_reg[31:24]};
               
               rx_datak0 <= {rxdk_reg[0], rxdk_reg[8], rxdk_reg[16], rxdk_reg[24]};
               rx_datak1 <= {rxdk_reg[1], rxdk_reg[9], rxdk_reg[17], rxdk_reg[25]};
               rx_datak2 <= {rxdk_reg[2], rxdk_reg[10], rxdk_reg[18], rxdk_reg[26]};
               rx_datak3 <= {rxdk_reg[3], rxdk_reg[11], rxdk_reg[19], rxdk_reg[27]};
               rx_datak4 <= {rxdk_reg[4], rxdk_reg[12], rxdk_reg[20], rxdk_reg[28]};
               rx_datak5 <= {rxdk_reg[5], rxdk_reg[13], rxdk_reg[21], rxdk_reg[29]};
               rx_datak6 <= {rxdk_reg[6], rxdk_reg[14], rxdk_reg[22], rxdk_reg[30]};
               rx_datak7 <= {rxdk_reg[7], rxdk_reg[15], rxdk_reg[23], rxdk_reg[31]};
               
               rx_status0 <= rxsts0_reg[2:0] | rxsts0_reg[5:3] | rxsts0_reg[8:6] | rxsts0_reg[11:9];
               rx_status1 <= rxsts1_reg[2:0] | rxsts1_reg[5:3] | rxsts1_reg[8:6] | rxsts1_reg[11:9];
               rx_status2 <= rxsts2_reg[2:0] | rxsts2_reg[5:3] | rxsts2_reg[8:6] | rxsts2_reg[11:9];
               rx_status3 <= rxsts3_reg[2:0] | rxsts3_reg[5:3] | rxsts3_reg[8:6] | rxsts3_reg[11:9];
               rx_status4 <= rxsts4_reg[2:0] | rxsts4_reg[5:3] | rxsts4_reg[8:6] | rxsts4_reg[11:9];
               rx_status5 <= rxsts5_reg[2:0] | rxsts5_reg[5:3] | rxsts5_reg[8:6] | rxsts5_reg[11:9];
               rx_status6 <= rxsts6_reg[2:0] | rxsts6_reg[5:3] | rxsts6_reg[8:6] | rxsts6_reg[11:9];
               rx_status7 <= rxsts7_reg[2:0] | rxsts7_reg[5:3] | rxsts7_reg[8:6] | rxsts7_reg[11:9];
               
               rx_elecidle <= rxelecidle;
               rx_valid <= rxvalid;
               phy_status <= phystatus_reg[0] | phystatus_reg[1] | phystatus_reg[2] | phystatus_reg[3];
            end
      end
   endgenerate
   
   //-------------------------------------------------------
   // PIPE 16bit@125Mhz <=> PIPE 8bit@250MHz interface
   //-------------------------------------------------------
   
   generate
      if (BFM_WIDTH == 16)
      begin : gpipe16b
         assign pclk = clk125;
         
         
         always @(posedge clk125 or negedge rstn)
            if (rstn == 1'b0)
            begin
               rx_data0 <= {BFM_WIDTH{1'b0}};
               rx_data1 <= {BFM_WIDTH{1'b0}};
               rx_data2 <= {BFM_WIDTH{1'b0}};
               rx_data3 <= {BFM_WIDTH{1'b0}};
               rx_data4 <= {BFM_WIDTH{1'b0}};
               rx_data5 <= {BFM_WIDTH{1'b0}};
               rx_data6 <= {BFM_WIDTH{1'b0}};
               rx_data7 <= {BFM_WIDTH{1'b0}};
               rx_datak0 <= {BFM_WIDTH/8{1'b0}};
               rx_datak1 <= {BFM_WIDTH/8{1'b0}};
               rx_datak2 <= {BFM_WIDTH/8{1'b0}};
               rx_datak3 <= {BFM_WIDTH/8{1'b0}};
               rx_datak4 <= {BFM_WIDTH/8{1'b0}};
               rx_datak5 <= {BFM_WIDTH/8{1'b0}};
               rx_datak6 <= {BFM_WIDTH/8{1'b0}};
               rx_datak7 <= {BFM_WIDTH/8{1'b0}};
               rx_status0 <= 3'b000;
               rx_status1 <= 3'b000;
               rx_status2 <= 3'b000;
               rx_status3 <= 3'b000;
               rx_status4 <= 3'b000;
               rx_status5 <= 3'b000;
               rx_status6 <= 3'b000;
               rx_status7 <= 3'b000;
               rx_elecidle <= {8{1'b1}};
               rx_valid <= {8{1'b0}};
               phy_status <= 1'b1;
            end
            else 
            begin
               rx_data0 <= {rxd0_reg[7:0], rxd0_reg[15:8]};
               rx_data1 <= {rxd1_reg[7:0], rxd1_reg[15:8]};
               rx_data2 <= {rxd2_reg[7:0], rxd2_reg[15:8]};
               rx_data3 <= {rxd3_reg[7:0], rxd3_reg[15:8]};
               rx_data4 <= {rxd4_reg[7:0], rxd4_reg[15:8]};
               rx_data5 <= {rxd5_reg[7:0], rxd5_reg[15:8]};
               rx_data6 <= {rxd6_reg[7:0], rxd6_reg[15:8]};
               rx_data7 <= {rxd7_reg[7:0], rxd7_reg[15:8]};
               
               rx_datak0 <= {rxdk_reg[0], rxdk_reg[8]};
               rx_datak1 <= {rxdk_reg[1], rxdk_reg[9]};
               rx_datak2 <= {rxdk_reg[2], rxdk_reg[10]};
               rx_datak3 <= {rxdk_reg[3], rxdk_reg[11]};
               rx_datak4 <= {rxdk_reg[4], rxdk_reg[12]};
               rx_datak5 <= {rxdk_reg[5], rxdk_reg[13]};
               rx_datak6 <= {rxdk_reg[6], rxdk_reg[14]};
               rx_datak7 <= {rxdk_reg[7], rxdk_reg[15]};
               
               rx_status0 <= rxsts0_reg[2:0] | rxsts0_reg[5:3];
               rx_status1 <= rxsts1_reg[2:0] | rxsts1_reg[5:3];
               rx_status2 <= rxsts2_reg[2:0] | rxsts2_reg[5:3];
               rx_status3 <= rxsts3_reg[2:0] | rxsts3_reg[5:3];
               rx_status4 <= rxsts4_reg[2:0] | rxsts4_reg[5:3];
               rx_status5 <= rxsts5_reg[2:0] | rxsts5_reg[5:3];
               rx_status6 <= rxsts6_reg[2:0] | rxsts6_reg[5:3];
               rx_status7 <= rxsts7_reg[2:0] | rxsts7_reg[5:3];
               
               rx_elecidle <= rxelecidle;
               rx_valid <= rxvalid;
               phy_status <= phystatus_reg[0] | phystatus_reg[1];
            end
      end
   endgenerate
   
   //-------------------------------------------------------
   // PIPE 16/32bit <=> PIPE 8bit@250MHz interface
   //-------------------------------------------------------
   
   generate
      if (BFM_WIDTH == 16 | BFM_WIDTH == 32)
      begin : gpipe1632b
         
         always @(posedge clk250 or negedge rstn)
         begin: xhdl0
            integer                      i;
            if (rstn == 1'b0)
            begin
               phystatus_reg <= 4'b1111;
               rxsts0_reg <= {12{1'b0}};
               rxsts1_reg <= {12{1'b0}};
               rxsts2_reg <= {12{1'b0}};
               rxsts3_reg <= {12{1'b0}};
               rxsts4_reg <= {12{1'b0}};
               rxsts5_reg <= {12{1'b0}};
               rxsts6_reg <= {12{1'b0}};
               rxsts7_reg <= {12{1'b0}};
               rxd0_reg <= {32{1'b0}};
               rxd1_reg <= {32{1'b0}};
               rxd2_reg <= {32{1'b0}};
               rxd3_reg <= {32{1'b0}};
               rxd4_reg <= {32{1'b0}};
               rxd5_reg <= {32{1'b0}};
               rxd6_reg <= {32{1'b0}};
               rxd7_reg <= {32{1'b0}};
               rxdk_reg <= {32{1'b0}};
               
               pclk_r <= 2'b00;
               toggle_r <= 2'b00;
               tx_compl_r <= {8{1'b0}};
               tx_data0_r <= {BFM_WIDTH{1'b0}};
               tx_data1_r <= {BFM_WIDTH{1'b0}};
               tx_data2_r <= {BFM_WIDTH{1'b0}};
               tx_data3_r <= {BFM_WIDTH{1'b0}};
               tx_data4_r <= {BFM_WIDTH{1'b0}};
               tx_data5_r <= {BFM_WIDTH{1'b0}};
               tx_data6_r <= {BFM_WIDTH{1'b0}};
               tx_data7_r <= {BFM_WIDTH{1'b0}};
               tx_datak0_r <= {BFM_WIDTH/8{1'b0}};
               tx_datak1_r <= {BFM_WIDTH/8{1'b0}};
               tx_datak2_r <= {BFM_WIDTH/8{1'b0}};
               tx_datak3_r <= {BFM_WIDTH/8{1'b0}};
               tx_datak4_r <= {BFM_WIDTH/8{1'b0}};
               tx_datak5_r <= {BFM_WIDTH/8{1'b0}};
               tx_datak6_r <= {BFM_WIDTH/8{1'b0}};
               tx_datak7_r <= {BFM_WIDTH/8{1'b0}};
               tx_elecidle_r <= {8{1'b1}};
               rx_polarity_r <= {8{1'b0}};
               power_down_r <= 2'b10;
               tx_detectrx_r <= 1'b0;
               
               txcompl <= {8{1'b0}};
               txdata0 <= {8{1'b0}};
               txdata1 <= {8{1'b0}};
               txdata2 <= {8{1'b0}};
               txdata3 <= {8{1'b0}};
               txdata4 <= {8{1'b0}};
               txdata5 <= {8{1'b0}};
               txdata6 <= {8{1'b0}};
               txdata7 <= {8{1'b0}};
               txdatak <= {8{1'b0}};
               rxpolarity <= {8{1'b0}};
               txelecidle <= {8{1'b1}};
               powerdown <= 2'b10;
               txdetectrx <= 1'b0;
            end
            else 
            begin
               rxsts0_reg <= {rxsts0_reg[8:0], rxstatus0};
               rxsts1_reg <= {rxsts1_reg[8:0], rxstatus1};
               rxsts2_reg <= {rxsts2_reg[8:0], rxstatus2};
               rxsts3_reg <= {rxsts3_reg[8:0], rxstatus3};
               rxsts4_reg <= {rxsts4_reg[8:0], rxstatus4};
               rxsts5_reg <= {rxsts5_reg[8:0], rxstatus5};
               rxsts6_reg <= {rxsts6_reg[8:0], rxstatus6};
               rxsts7_reg <= {rxsts7_reg[8:0], rxstatus7};
               
               rxd0_reg <= {rxd0_reg[23:0], rxdata0};
               rxd1_reg <= {rxd1_reg[23:0], rxdata1};
               rxd2_reg <= {rxd2_reg[23:0], rxdata2};
               rxd3_reg <= {rxd3_reg[23:0], rxdata3};
               rxd4_reg <= {rxd4_reg[23:0], rxdata4};
               rxd5_reg <= {rxd5_reg[23:0], rxdata5};
               rxd6_reg <= {rxd6_reg[23:0], rxdata6};
               rxd7_reg <= {rxd7_reg[23:0], rxdata7};
               rxdk_reg <= {rxdk_reg[23:0], rxdatak};
               
               phystatus_reg <= {phystatus_reg[2:0], phystatus};
               
               pclk_r <= {pclk_r[0], pclk};
               
               if (pclk_r == 2'b01)
               begin
                  toggle_r <= 2'b00;
                  tx_compl_r <= tx_compl;
                  tx_data0_r <= tx_data0;
                  tx_data1_r <= tx_data1;
                  tx_data2_r <= tx_data2;
                  tx_data3_r <= tx_data3;
                  tx_data4_r <= tx_data4;
                  tx_data5_r <= tx_data5;
                  tx_data6_r <= tx_data6;
                  tx_data7_r <= tx_data7;
                  tx_datak0_r <= tx_datak0;
                  tx_datak1_r <= tx_datak1;
                  tx_datak2_r <= tx_datak2;
                  tx_datak3_r <= tx_datak3;
                  tx_datak4_r <= tx_datak4;
                  tx_datak5_r <= tx_datak5;
                  tx_datak6_r <= tx_datak6;
                  tx_datak7_r <= tx_datak7;
                  tx_elecidle_r <= tx_elecidle;
                  rx_polarity_r <= rx_polarity;
                  power_down_r <= power_down;
                  tx_detectrx_r <= tx_detectrx;
               end
               else
                  toggle_r <= toggle_r + 1'b1;
               
               for (i = 0; i <= BFM_WIDTH/8 - 1; i = i + 1)
                  if (toggle_r == i)
                  begin
                     if (i == 0)
                        txcompl <= tx_compl_r;
                     else
                        txcompl <= {8{1'b0}};
                     
                     txdata0 <= tx_data0_r[i*8 +: 8];
                     txdata1 <= tx_data1_r[i*8 +: 8];
                     txdata2 <= tx_data2_r[i*8 +: 8];
                     txdata3 <= tx_data3_r[i*8 +: 8];
                     txdata4 <= tx_data4_r[i*8 +: 8];
                     txdata5 <= tx_data5_r[i*8 +: 8];
                     txdata6 <= tx_data6_r[i*8 +: 8];
                     txdata7 <= tx_data7_r[i*8 +: 8];
                     txdatak <= ({tx_datak7_r[i], tx_datak6_r[i], tx_datak5_r[i], tx_datak4_r[i], tx_datak3_r[i], tx_datak2_r[i], tx_datak1_r[i], tx_datak0_r[i]}) & (~tx_elecidle_r);
                  end
               
               txelecidle <= tx_elecidle_r;
               rxpolarity <= rx_polarity_r;
               powerdown <= power_down_r;
               txdetectrx <= tx_detectrx_r;
            end
         end
      end
   endgenerate
   
   //-------------------------------------------------------
   // PIPE 8-bit @ 250 MHz interface
   //-------------------------------------------------------
   
   generate
      if (BFM_WIDTH == 8)
      begin : gpipe8b
         
         always @(negedge rstn or posedge clk250)
            if (rstn == 1'b0)
            begin
               rxpolarity <= {8{1'b0}};
               txelecidle <= {8{1'b1}};
               txcompl <= {8{1'b0}};
               
               powerdown <= 2'b10;
               txdetectrx <= 1'b0;
               rx_elecidle <= {8{1'b1}};
               rx_valid <= {8{1'b0}};
               phy_status <= 1'b1;
               
               rx_status0 <= 3'b000;
               rx_status1 <= 3'b000;
               rx_status2 <= 3'b000;
               rx_status3 <= 3'b000;
               rx_status4 <= 3'b000;
               rx_status5 <= 3'b000;
               rx_status6 <= 3'b000;
               rx_status7 <= 3'b000;
               
               rx_data0 <= {BFM_WIDTH{1'b0}};
               rx_data1 <= {BFM_WIDTH{1'b0}};
               rx_data2 <= {BFM_WIDTH{1'b0}};
               rx_data3 <= {BFM_WIDTH{1'b0}};
               rx_data4 <= {BFM_WIDTH{1'b0}};
               rx_data5 <= {BFM_WIDTH{1'b0}};
               rx_data6 <= {BFM_WIDTH{1'b0}};
               rx_data7 <= {BFM_WIDTH{1'b0}};
               
               rx_datak0 <= {BFM_WIDTH/8{1'b0}};
               rx_datak1 <= {BFM_WIDTH/8{1'b0}};
               rx_datak2 <= {BFM_WIDTH/8{1'b0}};
               rx_datak3 <= {BFM_WIDTH/8{1'b0}};
               rx_datak4 <= {BFM_WIDTH/8{1'b0}};
               rx_datak5 <= {BFM_WIDTH/8{1'b0}};
               rx_datak6 <= {BFM_WIDTH/8{1'b0}};
               rx_datak7 <= {BFM_WIDTH/8{1'b0}};
               
               txdata0 <= {8{1'b0}};
               txdata1 <= {8{1'b0}};
               txdata2 <= {8{1'b0}};
               txdata3 <= {8{1'b0}};
               txdata4 <= {8{1'b0}};
               txdata5 <= {8{1'b0}};
               txdata6 <= {8{1'b0}};
               txdata7 <= {8{1'b0}};
               txdatak <= {8{1'b0}};
            end
            else 
            begin
               rxpolarity <= rx_polarity;
               txelecidle <= tx_elecidle;
               txcompl <= tx_compl;
               
               powerdown <= power_down;
               txdetectrx <= tx_detectrx;
               rx_elecidle <= rxelecidle;
               rx_valid <= rxvalid;
               phy_status <= phystatus;
               
               rx_status0 <= rxstatus0;
               rx_status1 <= rxstatus1;
               rx_status2 <= rxstatus2;
               rx_status3 <= rxstatus3;
               rx_status4 <= rxstatus4;
               rx_status5 <= rxstatus5;
               rx_status6 <= rxstatus6;
               rx_status7 <= rxstatus7;
               
               rx_data0 <= rxdata0;
               rx_data1 <= rxdata1;
               rx_data2 <= rxdata2;
               rx_data3 <= rxdata3;
               rx_data4 <= rxdata4;
               rx_data5 <= rxdata5;
               rx_data6 <= rxdata6;
               rx_data7 <= rxdata7;
               
               rx_datak0[0] <= rxdatak[0];
               rx_datak1[0] <= rxdatak[1];
               rx_datak2[0] <= rxdatak[2];
               rx_datak3[0] <= rxdatak[3];
               rx_datak4[0] <= rxdatak[4];
               rx_datak5[0] <= rxdatak[5];
               rx_datak6[0] <= rxdatak[6];
               rx_datak7[0] <= rxdatak[7];
               
               txdata0 <= tx_data0;
               txdata1 <= tx_data1;
               txdata2 <= tx_data2;
               txdata3 <= tx_data3;
               txdata4 <= tx_data4;
               txdata5 <= tx_data5;
               txdata6 <= tx_data6;
               txdata7 <= tx_data7;
               
               txdatak[7:0] <= ({tx_datak7[0], tx_datak6[0], tx_datak5[0], tx_datak4[0], tx_datak3[0], tx_datak2[0], tx_datak1[0], tx_datak0[0]}) & (~tx_elecidle);
            end
      end
   endgenerate
   
   //--------------------------------------------------------------------
   // PCS for external device
   //--------------------------------------------------------------------
   
   
   pciebfm8x250_pcs #(.BFM_LANES(BFM_LANES)) extpcs(
      .clk250(clk250),
      .rstn(rstn),
      
      .rx_val(rx_val),
      .rx_10b(rx_10b),
      .rx_detect(detect),
      .rx_eidle(rx_eidle),
      .tx_val(tx_val),
      .tx_10b(tx_10b),
      .tx_eidle(tx_eidle),
      
      .rate(rate),
      .phystatus(phystatus),
      .powerdown(powerdown),
      .txdetectrx(txdetectrx),
      
      .rxdatak(rxdatak),
      .txdatak(txdatak),
      .txelecidle(txelecidle),
      .txcompl(txcompl),
      .rxpolarity(rxpolarity),
      .rxvalid(rxvalid),
      .rxelecidle(rxelecidle),
      
      .txdata0(txdata0),
      .rxdata0(rxdata0),
      .rxstatus0(rxstatus0),
      .txdata1(txdata1),
      .rxdata1(rxdata1),
      .rxstatus1(rxstatus1),
      .txdata2(txdata2),
      .rxdata2(rxdata2),
      .rxstatus2(rxstatus2),
      .txdata3(txdata3),
      .rxdata3(rxdata3),
      .rxstatus3(rxstatus3),
      .txdata4(txdata4),
      .rxdata4(rxdata4),
      .rxstatus4(rxstatus4),
      .txdata5(txdata5),
      .rxdata5(rxdata5),
      .rxstatus5(rxstatus5),
      .txdata6(txdata6),
      .rxdata6(rxdata6),
      .rxstatus6(rxstatus6),
      .txdata7(txdata7),
      .rxdata7(rxdata7),
      .rxstatus7(rxstatus7)
   );
   
   //--------------------------------------------------------------------
   // Port mapping for BFM
   //--------------------------------------------------------------------
   
   
   pciebfm_top #(.BFM_ID(BFM_ID), .BFM_TYPE(BFM_TYPE), .BFM_LANES(BFM_LANES), .IO_SIZE(IO_SIZE), .MEM32_SIZE(MEM32_SIZE), .MEM64_SIZE(MEM64_SIZE)) bfm(
      .clk(clk250),
      .resetn(rstn),
      .rxtx_rate(),
      
      .rx_val(tx_val),
      .rx_10b(tx_10b),
      .rx_detect(detect),
      .rx_eidle(tx_eidle),
      .tx_val(rx_val),
      .tx_10b(rx_10b),
      .tx_eidle(rx_eidle),
      .chk_txval(chk_txval),
      .chk_txdata(chk_txdata),
      .chk_txdatak(chk_txdatak),
      .chk_rxval(chk_rxval),
      .chk_rxdata(chk_rxdata),
      .chk_rxdatak(chk_rxdatak),
      .chk_ltssm(chk_ltssm)
   );
   
   assign detect = {8{1'b1}};
   
endmodule
