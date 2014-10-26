// tlp_app.v --- 
// 
// Filename: tlp_app.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Oct 26 12:29:24 2014 (-0700)
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
module tlp_app (/*AUTOARG*/
   // Outputs
   tx_cons_cred_sel, WrDatFifoFull, TxsReadData_o, TxsReadDataValid_o,
   TxWaitRequest_o, TxStValid_o, TxStSop_o, TxStEop_o, TxStEmpty_o,
   TxStData_o, TxRpFifoRdReq_o, TxRespIdle_o, TxCplSent_o,
   TxCplLineSent_o, TagRelease_o, RxmWrite_5_o, RxmWrite_4_o,
   RxmWrite_3_o, RxmWrite_2_o, RxmWrite_1_o, RxmWrite_0_o,
   RxmWriteData_5_o, RxmWriteData_4_o, RxmWriteData_3_o,
   RxmWriteData_2_o, RxmWriteData_1_o, RxmWriteData_0_o, RxmRead_5_o,
   RxmRead_4_o, RxmRead_3_o, RxmRead_2_o, RxmRead_1_o, RxmRead_0_o,
   RxmByteEnable_5_o, RxmByteEnable_4_o, RxmByteEnable_3_o,
   RxmByteEnable_2_o, RxmByteEnable_1_o, RxmByteEnable_0_o,
   RxmBurstCount_5_o, RxmBurstCount_4_o, RxmBurstCount_3_o,
   RxmBurstCount_2_o, RxmBurstCount_1_o, RxmBurstCount_0_o,
   RxmAddress_5_o, RxmAddress_4_o, RxmAddress_3_o, RxmAddress_2_o,
   RxmAddress_1_o, RxmAddress_0_o, RxStReady_o, RxStMask_o,
   RxRpFifoWrReq_o, RxRpFifoWrData_o, RxPndgRdFifoRdReq_o,
   PndgRdHeader_o, PndgRdFifoWrReq_o, MsiReq_o, IntxReq_o, CplReq_o,
   CplRdAddr_o, CplRamWrEna_o, CplRamWrDat_o, CplRamWrAddr_o,
   CplPending_o, CplDesc_o, CmdFifoEmpty,
   // Inputs
   pld_clk_inuse, ko_cpl_spc_header, ko_cpl_spc_data, k_bar_i,
   cb_p2a_avalon_addr_b6_i, cb_p2a_avalon_addr_b5_i,
   cb_p2a_avalon_addr_b4_i, cb_p2a_avalon_addr_b3_i,
   cb_p2a_avalon_addr_b2_i, cb_p2a_avalon_addr_b1_i,
   cb_p2a_avalon_addr_b0_i, WrDatFifoDi, TxsReadDataValid_i,
   TxWrite_i, TxStReady_i, TxRpFifoData_i, TxRespIdle_i, TxRead_i,
   TxReadData_i, TxReadDataValid_i, TxCredNpHdrLimit_i,
   TxCredInfinit_i, TxCredHipCons_i, TxCpl_i, TxCplLen_i,
   TxChipSelect_i, TxByteEnable_i, TxBurstCount_i, TxAddress_i,
   TxAdapterFifoEmpty_i, RxmWaitRequest_5_i, RxmWaitRequest_4_i,
   RxmWaitRequest_3_i, RxmWaitRequest_2_i, RxmWaitRequest_1_i,
   RxmWaitRequest_0_i, RxmRstn_i, RxmIrq_i, RxStValid_i, RxStSop_i,
   RxStParity_i, RxStErr_i, RxStEop_i, RxStEmpty_i, RxStData_i,
   RxStBe_i, RxStBarDec2_i, RxStBarDec1_i, RxRdInProgress_i,
   RxPndgRdFifoEmpty_i, RxPndgRdFifoDato_i, RxCplBuffFree_i, Rstn_i,
   RpTLPReady_i, PndngRdFifoUsedW_i, PndngRdFifoEmpty_i, PCIeIrqEna_i,
   MsiData_i, MsiCsr_i, MsiAddr_i, MsiAck_i, MasterEnable_i,
   IntxAck_i, DevCsr_i, CplReq_i, CplDesc_i, CplBufData_i, Clk_i,
   BusDev_i, AvlClk_i, A2PMbWrReq_i, A2PMbWrAddr_i, clk, rst
   );
   parameter TXCPL_BUFF_ADDR_WIDTH = 8; // TODO
   
   input clk;
   input rst;

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input [11:0]		A2PMbWrAddr_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		A2PMbWrReq_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		AvlClk_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v, ...
   input [12:0]		BusDev_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v, ...
   input		Clk_i;			// To tlp_tx_cntrl of tlp_tx_cntrl.v, ...
   input [129:0]	CplBufData_i;		// To tlp_rxresp_cntrl of tlp_rxresp_cntrl.v
   input [5:0]		CplDesc_i;		// To tlp_rxresp_cntrl of tlp_rxresp_cntrl.v
   input		CplReq_i;		// To tlp_rxresp_cntrl of tlp_rxresp_cntrl.v
   input [31:0]		DevCsr_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v, ...
   input		IntxAck_i;		// To tlp_tx_cntrl of tlp_tx_cntrl.v
   input		MasterEnable_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		MsiAck_i;		// To tlp_tx_cntrl of tlp_tx_cntrl.v
   input [63:0]		MsiAddr_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [15:0]		MsiCsr_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v, ...
   input [15:0]		MsiData_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [31:0]		PCIeIrqEna_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		PndngRdFifoEmpty_i;	// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [3:0]		PndngRdFifoUsedW_i;	// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input		RpTLPReady_i;		// To tlp_tx_cntrl of tlp_tx_cntrl.v
   input		Rstn_i;			// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v, ...
   input		RxCplBuffFree_i;	// To tlp_tx_cntrl of tlp_tx_cntrl.v
   input [56:0]		RxPndgRdFifoDato_i;	// To tlp_txresp_cntrl of tlp_txresp_cntrl.v
   input		RxPndgRdFifoEmpty_i;	// To tlp_txresp_cntrl of tlp_txresp_cntrl.v
   input		RxRdInProgress_i;	// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [7:0]		RxStBarDec1_i;		// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [7:0]		RxStBarDec2_i;		// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [15:0]		RxStBe_i;		// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [127:0]	RxStData_i;		// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [1:0]		RxStEmpty_i;		// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input		RxStEop_i;		// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [7:0]		RxStErr_i;		// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [64:0]		RxStParity_i;		// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input		RxStSop_i;		// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input		RxStValid_i;		// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [CG_RXM_IRQ_NUM-1:0] RxmIrq_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		RxmRstn_i;		// To tlp_rxresp_cntrl of tlp_rxresp_cntrl.v
   input		RxmWaitRequest_0_i;	// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input		RxmWaitRequest_1_i;	// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input		RxmWaitRequest_2_i;	// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input		RxmWaitRequest_3_i;	// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input		RxmWaitRequest_4_i;	// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input		RxmWaitRequest_5_i;	// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input		TxAdapterFifoEmpty_i;	// To tlp_tx_cntrl of tlp_tx_cntrl.v
   input [CG_AVALON_S_ADDR_WIDTH-1:0] TxAddress_i;// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [5:0]		TxBurstCount_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [15:0]		TxByteEnable_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		TxChipSelect_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [4:0]		TxCplLen_i;		// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input		TxCpl_i;		// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [5:0]		TxCredHipCons_i;	// To tlp_tx_cntrl of tlp_tx_cntrl.v
   input [5:0]		TxCredInfinit_i;	// To tlp_tx_cntrl of tlp_tx_cntrl.v
   input [7:0]		TxCredNpHdrLimit_i;	// To tlp_tx_cntrl of tlp_tx_cntrl.v
   input		TxReadDataValid_i;	// To tlp_txcpl_buffer of tlp_txcpl_buffer.v, ...
   input [31:0]		TxReadData_i;		// To tlp_txcpl_buffer of tlp_txcpl_buffer.v
   input		TxRead_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		TxRespIdle_i;		// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [130:0]	TxRpFifoData_i;		// To tlp_tx_cntrl of tlp_tx_cntrl.v
   input		TxStReady_i;		// To tlp_tx_cntrl of tlp_tx_cntrl.v
   input		TxWrite_i;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		TxsReadDataValid_i;	// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [127:0]	WrDatFifoDi;		// To tlp_txdat_fifo of tlp_txdat_fifo.v
   input [31:0]		cb_p2a_avalon_addr_b0_i;// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [31:0]		cb_p2a_avalon_addr_b1_i;// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [31:0]		cb_p2a_avalon_addr_b2_i;// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [31:0]		cb_p2a_avalon_addr_b3_i;// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [31:0]		cb_p2a_avalon_addr_b4_i;// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [31:0]		cb_p2a_avalon_addr_b5_i;// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [31:0]		cb_p2a_avalon_addr_b6_i;// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [223:0]	k_bar_i;		// To tlp_rx_cntrl of tlp_rx_cntrl.v
   input [11:0]		ko_cpl_spc_data;	// To tlp_tx_cntrl of tlp_tx_cntrl.v
   input [7:0]		ko_cpl_spc_header;	// To tlp_tx_cntrl of tlp_tx_cntrl.v
   input		pld_clk_inuse;		// To tlp_tx_cntrl of tlp_tx_cntrl.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		CmdFifoEmpty;		// From tlp_txcmd_fifo of tlp_txcmd_fifo.v
   output [5:0]		CplDesc_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		CplPending_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   output [8:0]		CplRamWrAddr_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [129:0]	CplRamWrDat_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		CplRamWrEna_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [8:0]		CplRdAddr_o;		// From tlp_rxresp_cntrl of tlp_rxresp_cntrl.v
   output		CplReq_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		IntxReq_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   output		MsiReq_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   output		PndgRdFifoWrReq_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [56:0]	PndgRdHeader_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxPndgRdFifoRdReq_o;	// From tlp_txresp_cntrl of tlp_txresp_cntrl.v
   output [130:0]	RxRpFifoWrData_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxRpFifoWrReq_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxStMask_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxStReady_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [AVALON_ADDR_WIDTH-1:0] RxmAddress_0_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [AVALON_ADDR_WIDTH-1:0] RxmAddress_1_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [AVALON_ADDR_WIDTH-1:0] RxmAddress_2_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [AVALON_ADDR_WIDTH-1:0] RxmAddress_3_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [AVALON_ADDR_WIDTH-1:0] RxmAddress_4_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [AVALON_ADDR_WIDTH-1:0] RxmAddress_5_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [6:0]		RxmBurstCount_0_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [6:0]		RxmBurstCount_1_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [6:0]		RxmBurstCount_2_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [6:0]		RxmBurstCount_3_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [6:0]		RxmBurstCount_4_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [6:0]		RxmBurstCount_5_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_0_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_1_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_2_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_3_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_4_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_5_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxmRead_0_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxmRead_1_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxmRead_2_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxmRead_3_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxmRead_4_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxmRead_5_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_0_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_1_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_2_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_3_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_4_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_5_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxmWrite_0_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxmWrite_1_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxmWrite_2_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxmWrite_3_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxmWrite_4_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		RxmWrite_5_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   output		TagRelease_o;		// From tlp_rxresp_cntrl of tlp_rxresp_cntrl.v
   output [4:0]		TxCplLineSent_o;	// From tlp_tx_cntrl of tlp_tx_cntrl.v
   output		TxCplSent_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   output		TxRespIdle_o;		// From tlp_txresp_cntrl of tlp_txresp_cntrl.v
   output		TxRpFifoRdReq_o;	// From tlp_tx_cntrl of tlp_tx_cntrl.v
   output [127:0]	TxStData_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   output [1:0]		TxStEmpty_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   output		TxStEop_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   output		TxStSop_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   output		TxStValid_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   output		TxWaitRequest_o;	// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   output		TxsReadDataValid_o;	// From tlp_rxresp_cntrl of tlp_rxresp_cntrl.v
   output [127:0]	TxsReadData_o;		// From tlp_rxresp_cntrl of tlp_rxresp_cntrl.v
   output		WrDatFifoFull;		// From tlp_txdat_fifo of tlp_txdat_fifo.v
   output		tx_cons_cred_sel;	// From tlp_tx_cntrl of tlp_tx_cntrl.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			CmdFifoBusy;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   wire [98:0]		CmdFifoDat;		// From tlp_txcmd_fifo of tlp_txcmd_fifo.v
   wire			CmdFifoEmpty_r;		// From tlp_txcmd_fifo of tlp_txcmd_fifo.v
   wire			CmdFifoRdReq;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire [3:0]		CmdFifoUsedW;		// From tlp_txcmd_fifo of tlp_txcmd_fifo.v
   wire [6:0]		CplBuffRdAddr;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire [TXCPL_BUFF_ADDR_WIDTH-1:0] CplRamWrAddr;// From tlp_txresp_cntrl of tlp_txresp_cntrl.v
   wire [98:0]		CplReqHeader;		// From tlp_txresp_cntrl of tlp_txresp_cntrl.v
   wire			CplReqWr;		// From tlp_txresp_cntrl of tlp_txresp_cntrl.v
   wire [98:0]		RdBypassFifoDat;	// From tlp_rd_bypass_fifo of tlp_rd_bypass_fifo.v
   wire			RdBypassFifoEmpty;	// From tlp_rd_bypass_fifo of tlp_rd_bypass_fifo.v
   wire			RdBypassFifoFull;	// From tlp_rd_bypass_fifo of tlp_rd_bypass_fifo.v
   wire			RdBypassFifoRdReq;	// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire [6:0]		RdBypassFifoUsedw;	// From tlp_rd_bypass_fifo of tlp_rd_bypass_fifo.v
   wire			RdBypassFifoWrReq;	// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire [127:0]		TxCplDat;		// From tlp_txcpl_buffer of tlp_txcpl_buffer.v
   wire [98:0]		TxReqHeader;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   wire			TxReqWr;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   wire [128:0]		WrDatFifoDo;		// From tlp_txdat_fifo of tlp_txdat_fifo.v
   wire			WrDatFifoEop;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   wire			WrDatFifoRdReq;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire [5:0]		WrDatFifoUsedW;		// From tlp_txdat_fifo of tlp_txdat_fifo.v
   wire			WrDatFifoWrReq;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   // End of automatics

   /* TX */
   tlp_m_axi_cntrl #(/*AUTOINSTPARAM*/
		     // Parameters
		     .CG_RXM_IRQ_NUM	(CG_RXM_IRQ_NUM),
		     .CB_A2P_ADDR_MAP_PASS_THRU_BITS(CB_A2P_ADDR_MAP_PASS_THRU_BITS))
   tlp_m_axi_cntrl  (/*AUTOINST*/
		     // Outputs
		     .TxWaitRequest_o	(TxWaitRequest_o),
		     .TxReqWr		(TxReqWr),
		     .TxReqHeader	(TxReqHeader[98:0]),
		     .CmdFifoBusy	(CmdFifoBusy),
		     .WrDatFifoWrReq	(WrDatFifoWrReq),
		     .WrDatFifoEop	(WrDatFifoEop),
		     // Inputs
		     .AvlClk_i		(AvlClk_i),
		     .Rstn_i		(Rstn_i),
		     .TxChipSelect_i	(TxChipSelect_i),
		     .TxRead_i		(TxRead_i),
		     .TxWrite_i		(TxWrite_i),
		     .TxBurstCount_i	(TxBurstCount_i[5:0]),
		     .TxAddress_i	(TxAddress_i[CG_AVALON_S_ADDR_WIDTH-1:0]),
		     .TxByteEnable_i	(TxByteEnable_i[15:0]),
		     .CmdFifoUsedW	(CmdFifoUsedW[3:0]),
		     .WrDatFifoUsedW	(WrDatFifoUsedW[5:0]),
		     .DevCsr_i		(DevCsr_i[31:0]),
		     .BusDev_i		(BusDev_i[12:0]),
		     .MasterEnable_i	(MasterEnable_i),
		     .MsiCsr_i		(MsiCsr_i[15:0]),
		     .MsiAddr_i		(MsiAddr_i[63:0]),
		     .MsiData_i		(MsiData_i[15:0]),
		     .PCIeIrqEna_i	(PCIeIrqEna_i[31:0]),
		     .A2PMbWrAddr_i	(A2PMbWrAddr_i[11:0]),
		     .A2PMbWrReq_i	(A2PMbWrReq_i),
		     .TxsReadDataValid_i(TxsReadDataValid_i),
		     .RxmIrq_i		(RxmIrq_i[CG_RXM_IRQ_NUM-1:0]));
   
   tlp_txcmd_fifo #(/*AUTOINSTPARAM*/)
   tlp_txcmd_fifo  (/*AUTOINST*/
		    // Outputs
		    .CmdFifoUsedW	(CmdFifoUsedW[3:0]),
		    .CmdFifoEmpty	(CmdFifoEmpty),
		    .CmdFifoEmpty_r	(CmdFifoEmpty_r),
		    .CmdFifoDat		(CmdFifoDat[98:0]),
		    // Inputs
		    .clk		(clk),
		    .rst		(rst),
		    .TxReqHeader	(TxReqHeader[98:0]),
		    .TxReqWr		(TxReqWr),
		    .CplReqHeader	(CplReqHeader[98:0]),
		    .CplReqWr		(CplReqWr),
		    .CmdFifoRdReq	(CmdFifoRdReq));
   
   tlp_txdat_fifo #(/*AUTOINSTPARAM*/)
   tlp_txdat_fifo  (/*AUTOINST*/
		    // Outputs
		    .WrDatFifoUsedW	(WrDatFifoUsedW[5:0]),
		    .WrDatFifoFull	(WrDatFifoFull),
		    .WrDatFifoDo	(WrDatFifoDo[128:0]),
		    // Inputs
		    .clk		(clk),
		    .rst		(rst),
		    .WrDatFifoWrReq	(WrDatFifoWrReq),
		    .WrDatFifoEop	(WrDatFifoEop),
		    .WrDatFifoDi	(WrDatFifoDi[127:0]),
		    .WrDatFifoRdReq	(WrDatFifoRdReq));
   
   tlp_rd_bypass_fifo #(/*AUTOINSTPARAM*/)
   tlp_rd_bypass_fifo  (/*AUTOINST*/
			// Outputs
			.RdBypassFifoEmpty(RdBypassFifoEmpty),
			.RdBypassFifoFull(RdBypassFifoFull),
			.RdBypassFifoUsedw(RdBypassFifoUsedw[6:0]),
			.RdBypassFifoDat(RdBypassFifoDat[98:0]),
			// Inputs
			.clk		(clk),
			.rst		(rst),
			.RdBypassFifoWrReq(RdBypassFifoWrReq),
			.RdBypassFifoRdReq(RdBypassFifoRdReq),
			.CmdFifoDat	(CmdFifoDat[98:0]));

   tlp_txcpl_buffer #(/*AUTOINSTPARAM*/
		      // Parameters
		      .TXCPL_BUFF_ADDR_WIDTH(TXCPL_BUFF_ADDR_WIDTH))
   tlp_txcpl_buffer  (/*AUTOINST*/
		      // Outputs
		      .TxCplDat		(TxCplDat[127:0]),
		      // Inputs
		      .clk		(clk),
		      .rst		(rst),
		      .CplRamWrAddr	(CplRamWrAddr[TXCPL_BUFF_ADDR_WIDTH-1:0]),
		      .TxReadDataValid_i(TxReadDataValid_i),
		      .TxReadData_i	(TxReadData_i[31:0]),
		      .CplBuffRdAddr	(CplBuffRdAddr[TXCPL_BUFF_ADDR_WIDTH-1:0]));

   tlp_txresp_cntrl #(/*AUTOINSTPARAM*/
		      // Parameters
		      .TXCPL_BUFF_ADDR_WIDTH(TXCPL_BUFF_ADDR_WIDTH))
   tlp_txresp_cntrl  (/*AUTOINST*/
		      // Outputs
		      .RxPndgRdFifoRdReq_o(RxPndgRdFifoRdReq_o),
		      .CplReqHeader	(CplReqHeader[98:0]),
		      .CplReqWr		(CplReqWr),
		      .CplRamWrAddr	(CplRamWrAddr[TXCPL_BUFF_ADDR_WIDTH-1:0]),
		      .TxRespIdle_o	(TxRespIdle_o),
		      // Inputs
		      .AvlClk_i		(AvlClk_i),
		      .Rstn_i		(Rstn_i),
		      .RxPndgRdFifoEmpty_i(RxPndgRdFifoEmpty_i),
		      .RxPndgRdFifoDato_i(RxPndgRdFifoDato_i[56:0]),
		      .TxReadDataValid_i(TxReadDataValid_i),
		      .CmdFifoUsedW	(CmdFifoUsedW[3:0]),
		      .CmdFifoBusy	(CmdFifoBusy),
		      .DevCsr_i		(DevCsr_i[31:0]),
		      .BusDev_i		(BusDev_i[12:0]));
   
   tlp_tx_cntrl #(/*AUTOINSTPARAM*/
		  // Parameters
		  .ADDRESS_32BIT	(ADDRESS_32BIT),
		  .CB_PCIE_MODE		(CB_PCIE_MODE),
		  .CB_PCIE_RX_LITE	(CB_PCIE_RX_LITE),
		  .deviceFamily		(deviceFamily))
   tlp_tx_cntrl  (/*AUTOINST*/
		  // Outputs
		  .TxStData_o		(TxStData_o[127:0]),
		  .TxStSop_o		(TxStSop_o),
		  .TxStEop_o		(TxStEop_o),
		  .TxStEmpty_o		(TxStEmpty_o[1:0]),
		  .TxStValid_o		(TxStValid_o),
		  .CmdFifoRdReq		(CmdFifoRdReq),
		  .RdBypassFifoWrReq	(RdBypassFifoWrReq),
		  .RdBypassFifoRdReq	(RdBypassFifoRdReq),
		  .CplBuffRdAddr	(CplBuffRdAddr[6:0]),
		  .WrDatFifoRdReq	(WrDatFifoRdReq),
		  .TxRpFifoRdReq_o	(TxRpFifoRdReq_o),
		  .TxCplSent_o		(TxCplSent_o),
		  .TxCplLineSent_o	(TxCplLineSent_o[4:0]),
		  .MsiReq_o		(MsiReq_o),
		  .IntxReq_o		(IntxReq_o),
		  .CplPending_o		(CplPending_o),
		  .tx_cons_cred_sel	(tx_cons_cred_sel),
		  // Inputs
		  .Clk_i		(Clk_i),
		  .Rstn_i		(Rstn_i),
		  .TxStReady_i		(TxStReady_i),
		  .TxAdapterFifoEmpty_i	(TxAdapterFifoEmpty_i),
		  .TxCredHipCons_i	(TxCredHipCons_i[5:0]),
		  .TxCredInfinit_i	(TxCredInfinit_i[5:0]),
		  .TxCredNpHdrLimit_i	(TxCredNpHdrLimit_i[7:0]),
		  .ko_cpl_spc_header	(ko_cpl_spc_header[7:0]),
		  .ko_cpl_spc_data	(ko_cpl_spc_data[11:0]),
		  .CmdFifoDat		(CmdFifoDat[98:0]),
		  .CmdFifoEmpty_r	(CmdFifoEmpty_r),
		  .RdBypassFifoEmpty	(RdBypassFifoEmpty),
		  .RdBypassFifoFull	(RdBypassFifoFull),
		  .RdBypassFifoUsedw	(RdBypassFifoUsedw[6:0]),
		  .RdBypassFifoDat	(RdBypassFifoDat[97:0]),
		  .TxCplDat		(TxCplDat[127:0]),
		  .WrDatFifoDo		(WrDatFifoDo[128:0]),
		  .TxRpFifoData_i	(TxRpFifoData_i[130:0]),
		  .RpTLPReady_i		(RpTLPReady_i),
		  .RxCplBuffFree_i	(RxCplBuffFree_i),
		  .BusDev_i		(BusDev_i[12:0]),
		  .MsiCsr_i		(MsiCsr_i[15:0]),
		  .MsiAck_i		(MsiAck_i),
		  .IntxAck_i		(IntxAck_i),
		  .pld_clk_inuse	(pld_clk_inuse));
  
   /* RX */
   tlp_s_axi_cntrl #(/*AUTOINSTPARAM*/)
   tlp_s_axi_cntrl  (/*AUTOINST*/
		     // Inputs
		     .clk		(clk),
		     .rst		(rst));
   
   tlp_rx_cntrl #(/*AUTOINSTPARAM*/
		  // Parameters
		  .CB_PCIE_MODE		(CB_PCIE_MODE),
		  .CB_PCIE_RX_LITE	(CB_PCIE_RX_LITE),
		  .CB_RXM_DATA_WIDTH	(CB_RXM_DATA_WIDTH),
		  .port_type_hwtcl	(port_type_hwtcl),
		  .AVALON_ADDR_WIDTH	(AVALON_ADDR_WIDTH))
   tlp_rx_cntrl  (/*AUTOINST*/
		  // Outputs
		  .RxStReady_o		(RxStReady_o),
		  .RxStMask_o		(RxStMask_o),
		  .RxmWrite_0_o		(RxmWrite_0_o),
		  .RxmAddress_0_o	(RxmAddress_0_o[AVALON_ADDR_WIDTH-1:0]),
		  .RxmWriteData_0_o	(RxmWriteData_0_o[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmByteEnable_0_o	(RxmByteEnable_0_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		  .RxmBurstCount_0_o	(RxmBurstCount_0_o[6:0]),
		  .RxmRead_0_o		(RxmRead_0_o),
		  .RxmWrite_1_o		(RxmWrite_1_o),
		  .RxmAddress_1_o	(RxmAddress_1_o[AVALON_ADDR_WIDTH-1:0]),
		  .RxmWriteData_1_o	(RxmWriteData_1_o[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmByteEnable_1_o	(RxmByteEnable_1_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		  .RxmBurstCount_1_o	(RxmBurstCount_1_o[6:0]),
		  .RxmRead_1_o		(RxmRead_1_o),
		  .RxmWrite_2_o		(RxmWrite_2_o),
		  .RxmAddress_2_o	(RxmAddress_2_o[AVALON_ADDR_WIDTH-1:0]),
		  .RxmWriteData_2_o	(RxmWriteData_2_o[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmByteEnable_2_o	(RxmByteEnable_2_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		  .RxmBurstCount_2_o	(RxmBurstCount_2_o[6:0]),
		  .RxmRead_2_o		(RxmRead_2_o),
		  .RxmWrite_3_o		(RxmWrite_3_o),
		  .RxmAddress_3_o	(RxmAddress_3_o[AVALON_ADDR_WIDTH-1:0]),
		  .RxmWriteData_3_o	(RxmWriteData_3_o[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmByteEnable_3_o	(RxmByteEnable_3_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		  .RxmBurstCount_3_o	(RxmBurstCount_3_o[6:0]),
		  .RxmRead_3_o		(RxmRead_3_o),
		  .RxmWrite_4_o		(RxmWrite_4_o),
		  .RxmAddress_4_o	(RxmAddress_4_o[AVALON_ADDR_WIDTH-1:0]),
		  .RxmWriteData_4_o	(RxmWriteData_4_o[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmByteEnable_4_o	(RxmByteEnable_4_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		  .RxmBurstCount_4_o	(RxmBurstCount_4_o[6:0]),
		  .RxmRead_4_o		(RxmRead_4_o),
		  .RxmWrite_5_o		(RxmWrite_5_o),
		  .RxmAddress_5_o	(RxmAddress_5_o[AVALON_ADDR_WIDTH-1:0]),
		  .RxmWriteData_5_o	(RxmWriteData_5_o[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmByteEnable_5_o	(RxmByteEnable_5_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		  .RxmBurstCount_5_o	(RxmBurstCount_5_o[6:0]),
		  .RxmRead_5_o		(RxmRead_5_o),
		  .RxRpFifoWrData_o	(RxRpFifoWrData_o[130:0]),
		  .RxRpFifoWrReq_o	(RxRpFifoWrReq_o),
		  .PndgRdFifoWrReq_o	(PndgRdFifoWrReq_o),
		  .PndgRdHeader_o	(PndgRdHeader_o[56:0]),
		  .CplRamWrAddr_o	(CplRamWrAddr_o[8:0]),
		  .CplRamWrDat_o	(CplRamWrDat_o[129:0]),
		  .CplRamWrEna_o	(CplRamWrEna_o),
		  .CplReq_o		(CplReq_o),
		  .CplDesc_o		(CplDesc_o[5:0]),
		  // Inputs
		  .Clk_i		(Clk_i),
		  .Rstn_i		(Rstn_i),
		  .RxStData_i		(RxStData_i[127:0]),
		  .RxStParity_i		(RxStParity_i[64:0]),
		  .RxStBe_i		(RxStBe_i[15:0]),
		  .RxStEmpty_i		(RxStEmpty_i[1:0]),
		  .RxStErr_i		(RxStErr_i[7:0]),
		  .RxStSop_i		(RxStSop_i),
		  .RxStEop_i		(RxStEop_i),
		  .RxStValid_i		(RxStValid_i),
		  .RxStBarDec1_i	(RxStBarDec1_i[7:0]),
		  .RxStBarDec2_i	(RxStBarDec2_i[7:0]),
		  .RxmWaitRequest_0_i	(RxmWaitRequest_0_i),
		  .RxmWaitRequest_1_i	(RxmWaitRequest_1_i),
		  .RxmWaitRequest_2_i	(RxmWaitRequest_2_i),
		  .RxmWaitRequest_3_i	(RxmWaitRequest_3_i),
		  .RxmWaitRequest_4_i	(RxmWaitRequest_4_i),
		  .RxmWaitRequest_5_i	(RxmWaitRequest_5_i),
		  .PndngRdFifoUsedW_i	(PndngRdFifoUsedW_i[3:0]),
		  .PndngRdFifoEmpty_i	(PndngRdFifoEmpty_i),
		  .RxRdInProgress_i	(RxRdInProgress_i),
		  .TxCpl_i		(TxCpl_i),
		  .TxCplLen_i		(TxCplLen_i[4:0]),
		  .TxRespIdle_i		(TxRespIdle_i),
		  .DevCsr_i		(DevCsr_i[31:0]),
		  .cb_p2a_avalon_addr_b0_i(cb_p2a_avalon_addr_b0_i[31:0]),
		  .cb_p2a_avalon_addr_b1_i(cb_p2a_avalon_addr_b1_i[31:0]),
		  .cb_p2a_avalon_addr_b2_i(cb_p2a_avalon_addr_b2_i[31:0]),
		  .cb_p2a_avalon_addr_b3_i(cb_p2a_avalon_addr_b3_i[31:0]),
		  .cb_p2a_avalon_addr_b4_i(cb_p2a_avalon_addr_b4_i[31:0]),
		  .cb_p2a_avalon_addr_b5_i(cb_p2a_avalon_addr_b5_i[31:0]),
		  .cb_p2a_avalon_addr_b6_i(cb_p2a_avalon_addr_b6_i[31:0]),
		  .k_bar_i		(k_bar_i[223:0]));
   
   tlp_rxpd_fifo #(/*AUTOINSTPARAM*/)
   tlp_rxpd_fifo  (/*AUTOINST*/
		   // Inputs
		   .clk			(clk),
		   .rst			(rst));
   
   tlp_rxcpl_buffer #(/*AUTOINSTPARAM*/)
   tlp_rxcpl_buffer  (/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst		(rst));

   tlp_rxresp_cntrl #(/*AUTOINSTPARAM*/
		      // Parameters
		      .CG_COMMON_CLOCK_MODE(CG_COMMON_CLOCK_MODE))
   tlp_rxresp_cntrl (/*AUTOINST*/
		     // Outputs
		     .CplRdAddr_o	(CplRdAddr_o[8:0]),
		     .TagRelease_o	(TagRelease_o),
		     .TxsReadData_o	(TxsReadData_o[127:0]),
		     .TxsReadDataValid_o(TxsReadDataValid_o),
		     // Inputs
		     .Clk_i		(Clk_i),
		     .AvlClk_i		(AvlClk_i),
		     .Rstn_i		(Rstn_i),
		     .RxmRstn_i		(RxmRstn_i),
		     .CplReq_i		(CplReq_i),
		     .CplDesc_i		(CplDesc_i[5:0]),
		     .CplBufData_i	(CplBufData_i[129:0]));
endmodule
// 
// tlp_app.v ends here
