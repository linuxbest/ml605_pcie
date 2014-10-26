// rxm_dummy.v --- 
// 
// Filename: rxm_dummy.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Oct 26 15:39:57 2014 (-0700)
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
module rxm_dummy (/*AUTOARG*/
   // Outputs
   TxStReady_i, RxStData_i, RxStParity_i, RxStBe_i, RxStEmpty_i,
   RxStErr_i, RxStSop_i, RxStEop_i, RxStValid_i, RxStBarDec1_i,
   RxStBarDec2_i, RxmWaitRequest_0_i, RxmWaitRequest_1_i,
   RxmWaitRequest_2_i, RxmWaitRequest_3_i, RxmWaitRequest_4_i,
   RxmWaitRequest_5_i,
   // Inputs
   TxStData_o, TxStSop_o, TxStEop_o, TxStEmpty_o, TxStValid_o,
   RxStReady_o, RxStMask_o, RxmWrite_0_o, RxmAddress_0_o,
   RxmWriteData_0_o, RxmByteEnable_0_o, RxmBurstCount_0_o,
   RxmRead_0_o, RxmWrite_1_o, RxmAddress_1_o, RxmWriteData_1_o,
   RxmByteEnable_1_o, RxmBurstCount_1_o, RxmRead_1_o, RxmWrite_2_o,
   RxmAddress_2_o, RxmWriteData_2_o, RxmByteEnable_2_o,
   RxmBurstCount_2_o, RxmRead_2_o, RxmWrite_3_o, RxmAddress_3_o,
   RxmWriteData_3_o, RxmByteEnable_3_o, RxmBurstCount_3_o,
   RxmRead_3_o, RxmWrite_4_o, RxmAddress_4_o, RxmWriteData_4_o,
   RxmByteEnable_4_o, RxmBurstCount_4_o, RxmRead_4_o, RxmWrite_5_o,
   RxmAddress_5_o, RxmWriteData_5_o, RxmByteEnable_5_o,
   RxmBurstCount_5_o, RxmRead_5_o
   );
   
   /*AUTOINOUTCOMP("tlp_rx_cntrl", "^Rxm")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output		RxmWaitRequest_0_i;
   output		RxmWaitRequest_1_i;
   output		RxmWaitRequest_2_i;
   output		RxmWaitRequest_3_i;
   output		RxmWaitRequest_4_i;
   output		RxmWaitRequest_5_i;
   input		RxmWrite_0_o;
   input [AVALON_ADDR_WIDTH-1:0] RxmAddress_0_o;
   input [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_0_o;
   input [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_0_o;
   input [6:0]		RxmBurstCount_0_o;
   input		RxmRead_0_o;
   input		RxmWrite_1_o;
   input [AVALON_ADDR_WIDTH-1:0] RxmAddress_1_o;
   input [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_1_o;
   input [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_1_o;
   input [6:0]		RxmBurstCount_1_o;
   input		RxmRead_1_o;
   input		RxmWrite_2_o;
   input [AVALON_ADDR_WIDTH-1:0] RxmAddress_2_o;
   input [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_2_o;
   input [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_2_o;
   input [6:0]		RxmBurstCount_2_o;
   input		RxmRead_2_o;
   input		RxmWrite_3_o;
   input [AVALON_ADDR_WIDTH-1:0] RxmAddress_3_o;
   input [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_3_o;
   input [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_3_o;
   input [6:0]		RxmBurstCount_3_o;
   input		RxmRead_3_o;
   input		RxmWrite_4_o;
   input [AVALON_ADDR_WIDTH-1:0] RxmAddress_4_o;
   input [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_4_o;
   input [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_4_o;
   input [6:0]		RxmBurstCount_4_o;
   input		RxmRead_4_o;
   input		RxmWrite_5_o;
   input [AVALON_ADDR_WIDTH-1:0] RxmAddress_5_o;
   input [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_5_o;
   input [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_5_o;
   input [6:0]		RxmBurstCount_5_o;
   input		RxmRead_5_o;
   // End of automatics

   /*AUTOINOUTCOMP("tlp_rx_cntrl", "^RxSt")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output [127:0]	RxStData_i;
   output [64:0]	RxStParity_i;
   output [15:0]	RxStBe_i;
   output [1:0]		RxStEmpty_i;
   output [7:0]		RxStErr_i;
   output		RxStSop_i;
   output		RxStEop_i;
   output		RxStValid_i;
   output [7:0]		RxStBarDec1_i;
   output [7:0]		RxStBarDec2_i;
   input		RxStReady_o;
   input		RxStMask_o;
   // End of automatics

   /*AUTOINOUTCOMP("tlp_tx_cntrl", "^TxSt")*/)
   // Beginning of automatic in/out/inouts (from specific module)
   output		TxStReady_i;
   input [127:0]	TxStData_o;
   input		TxStSop_o;
   input		TxStEop_o;
   input [1:0]		TxStEmpty_o;
   input		TxStValid_o;
   // End of automatics

endmodule
// 
// rxm_dummy.v ends here
