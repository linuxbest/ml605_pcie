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
   S_WREADY, S_RVALID, S_RUSER, S_RRESP, S_RLAST, S_RID, S_RDATA,
   S_BVALID, S_BUSER, S_BRESP, S_BID, S_AWREADY, S_ARREADY, M_WVALID,
   M_WUSER, M_WSTRB, M_WLAST, M_WDATA, M_RREADY, M_BREADY, M_AWVALID,
   M_AWUSER, M_AWSIZE, M_AWREGION, M_AWQOS, M_AWPROT, M_AWLOCK,
   M_AWLEN, M_AWID, M_AWCACHE, M_AWBURST, M_AWADDR, M_ARVALID,
   M_ARUSER, M_ARSIZE, M_ARREGION, M_ARQOS, M_ARPROT, M_ARLOCK,
   M_ARLEN, M_ARID, M_ARCACHE, M_ARBURST, M_ARADDR,
   // Inputs
   S_WVALID, S_WUSER, S_WSTRB, S_WLAST, S_WDATA, S_RREADY, S_BREADY,
   S_AWVALID, S_AWUSER, S_AWSIZE, S_AWREGION, S_AWQOS, S_AWPROT,
   S_AWLOCK, S_AWLEN, S_AWID, S_AWCACHE, S_AWBURST, S_AWADDR,
   S_ARVALID, S_ARUSER, S_ARSIZE, S_ARREGION, S_ARQOS, S_ARPROT,
   S_ARLOCK, S_ARLEN, S_ARID, S_ARCACHE, S_ARBURST, S_ARADDR,
   M_WREADY, M_RVALID, M_RUSER, M_RRESP, M_RLAST, M_RID, M_RDATA,
   M_BVALID, M_BUSER, M_BRESP, M_BID, M_AWREADY, M_ARREADY, ARESETn,
   ACLK, clk, rst
   );
   parameter TXCPL_BUFF_ADDR_WIDTH = 8; // TODO
   
   input clk;
   input rst;

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		ACLK;			// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v, ...
   input		ARESETn;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v, ...
   input		M_ARREADY;		// To tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   input		M_AWREADY;		// To tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   input [((AXI4_ID_WIDTH)-1):0] M_BID;		// To tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   input [1:0]		M_BRESP;		// To tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   input [((AXI4_USER_WIDTH)-1):0] M_BUSER;	// To tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   input		M_BVALID;		// To tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   input [((AXI4_RDATA_WIDTH)-1):0] M_RDATA;	// To tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   input [((AXI4_ID_WIDTH)-1):0] M_RID;		// To tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   input		M_RLAST;		// To tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   input [1:0]		M_RRESP;		// To tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   input [((AXI4_USER_WIDTH)-1):0] M_RUSER;	// To tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   input		M_RVALID;		// To tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   input		M_WREADY;		// To tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   input [((AXI4_ADDRESS_WIDTH)-1):0] S_ARADDR;	// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [1:0]		S_ARBURST;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [3:0]		S_ARCACHE;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [((AXI4_ID_WIDTH)-1):0] S_ARID;	// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [7:0]		S_ARLEN;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		S_ARLOCK;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [2:0]		S_ARPROT;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [3:0]		S_ARQOS;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [3:0]		S_ARREGION;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [2:0]		S_ARSIZE;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [((AXI4_USER_WIDTH)-1):0] S_ARUSER;	// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		S_ARVALID;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [((AXI4_ADDRESS_WIDTH)-1):0] S_AWADDR;	// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [1:0]		S_AWBURST;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [3:0]		S_AWCACHE;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [((AXI4_ID_WIDTH)-1):0] S_AWID;	// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [7:0]		S_AWLEN;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		S_AWLOCK;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [2:0]		S_AWPROT;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [3:0]		S_AWQOS;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [3:0]		S_AWREGION;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [2:0]		S_AWSIZE;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [((AXI4_USER_WIDTH)-1):0] S_AWUSER;	// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		S_AWVALID;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		S_BREADY;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		S_RREADY;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [((AXI4_WDATA_WIDTH)-1):0] S_WDATA;	// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		S_WLAST;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [(((AXI4_WDATA_WIDTH/8))-1):0] S_WSTRB;// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input [((AXI4_USER_WIDTH)-1):0] S_WUSER;	// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   input		S_WVALID;		// To tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [((AXI4_ADDRESS_WIDTH)-1):0] M_ARADDR;// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [1:0]		M_ARBURST;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [3:0]		M_ARCACHE;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [((AXI4_ID_WIDTH)-1):0] M_ARID;	// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [7:0]		M_ARLEN;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output		M_ARLOCK;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [2:0]		M_ARPROT;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [3:0]		M_ARQOS;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [3:0]		M_ARREGION;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [2:0]		M_ARSIZE;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [((AXI4_USER_WIDTH)-1):0] M_ARUSER;	// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output		M_ARVALID;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [((AXI4_ADDRESS_WIDTH)-1):0] M_AWADDR;// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [1:0]		M_AWBURST;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [3:0]		M_AWCACHE;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [((AXI4_ID_WIDTH)-1):0] M_AWID;	// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [7:0]		M_AWLEN;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output		M_AWLOCK;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [2:0]		M_AWPROT;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [3:0]		M_AWQOS;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [3:0]		M_AWREGION;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [2:0]		M_AWSIZE;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [((AXI4_USER_WIDTH)-1):0] M_AWUSER;	// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output		M_AWVALID;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output		M_BREADY;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output		M_RREADY;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [((AXI4_WDATA_WIDTH)-1):0] M_WDATA;	// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output		M_WLAST;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [(((AXI4_WDATA_WIDTH/8))-1):0] M_WSTRB;// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output [((AXI4_USER_WIDTH)-1):0] M_WUSER;	// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output		M_WVALID;		// From tlp_s_axi_cntrl of tlp_s_axi_cntrl.v
   output		S_ARREADY;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   output		S_AWREADY;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   output [((AXI4_ID_WIDTH)-1):0] S_BID;	// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   output [1:0]		S_BRESP;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   output [((AXI4_USER_WIDTH)-1):0] S_BUSER;	// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   output		S_BVALID;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   output [((AXI4_RDATA_WIDTH)-1):0] S_RDATA;	// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   output [((AXI4_ID_WIDTH)-1):0] S_RID;	// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   output		S_RLAST;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   output [1:0]		S_RRESP;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   output [((AXI4_USER_WIDTH)-1):0] S_RUSER;	// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   output		S_RVALID;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   output		S_WREADY;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [11:0]		A2PMbWrAddr;		// From tlp_rxpd_fifo of tlp_rxpd_fifo.v
   wire			A2PMbWrReq;		// From tlp_rxpd_fifo of tlp_rxpd_fifo.v
   wire			AvlClk_i;		// From txm_dummy of rxm_dummy.v
   wire [12:0]		BusDev_i;		// From txm_dummy of rxm_dummy.v
   wire			Clk_i;			// From txm_dummy of rxm_dummy.v
   wire			CmdFifoBusy;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   wire [98:0]		CmdFifoDat;		// From tlp_txcmd_fifo of tlp_txcmd_fifo.v
   wire			CmdFifoEmpty;		// From tlp_txcmd_fifo of tlp_txcmd_fifo.v
   wire			CmdFifoEmpty_r;		// From tlp_txcmd_fifo of tlp_txcmd_fifo.v
   wire			CmdFifoRdReq;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire [3:0]		CmdFifoUsedW;		// From tlp_txcmd_fifo of tlp_txcmd_fifo.v
   wire [6:0]		CplBuffRdAddr;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire			CplPending_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire [TXCPL_BUFF_ADDR_WIDTH-1:0] CplRamWrAddr;// From tlp_txresp_cntrl of tlp_txresp_cntrl.v
   wire [98:0]		CplReqHeader;		// From tlp_txresp_cntrl of tlp_txresp_cntrl.v
   wire			CplReqWr;		// From tlp_txresp_cntrl of tlp_txresp_cntrl.v
   wire [31:0]		DevCsr_i;		// From txm_dummy of rxm_dummy.v
   wire			IntxAck_i;		// From txm_dummy of rxm_dummy.v
   wire			IntxReq_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire			MasterEnable;		// From tlp_rxpd_fifo of tlp_rxpd_fifo.v
   wire			MsiAck_i;		// From txm_dummy of rxm_dummy.v
   wire [63:0]		MsiAddr_i;		// From txm_dummy of rxm_dummy.v
   wire [15:0]		MsiCsr_i;		// From txm_dummy of rxm_dummy.v
   wire [15:0]		MsiData_i;		// From txm_dummy of rxm_dummy.v
   wire			MsiReq_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire [31:0]		PCIeIrqEna;		// From tlp_rxpd_fifo of tlp_rxpd_fifo.v
   wire			PndgRdFifoWrReq;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [56:0]		PndgRdHeader;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			PndngRdFifoEmpty;	// From tlp_pndgtxrd_fifo of tlp_pndgtxrd_fifo.v
   wire [3:0]		PndngRdFifoUsedW;	// From tlp_pndgtxrd_fifo of tlp_pndgtxrd_fifo.v
   wire [98:0]		RdBypassFifoDat;	// From tlp_rd_bypass_fifo of tlp_rd_bypass_fifo.v
   wire			RdBypassFifoEmpty;	// From tlp_rd_bypass_fifo of tlp_rd_bypass_fifo.v
   wire			RdBypassFifoFull;	// From tlp_rd_bypass_fifo of tlp_rd_bypass_fifo.v
   wire			RdBypassFifoRdReq;	// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire [6:0]		RdBypassFifoUsedw;	// From tlp_rd_bypass_fifo of tlp_rd_bypass_fifo.v
   wire			RdBypassFifoWrReq;	// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire			RpTLPReady;		// From tlp_rxpd_fifo of tlp_rxpd_fifo.v
   wire			Rstn_i;			// From txm_dummy of rxm_dummy.v
   wire [129:0]		RxCplBufData;		// From tlp_rxcpl_buffer of tlp_rxcpl_buffer.v
   wire			RxCplBuffFree;		// From tlp_rxresp_cntrl of tlp_rxresp_cntrl.v
   wire [5:0]		RxCplDesc;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [8:0]		RxCplRamWrAddr;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [129:0]		RxCplRamWrDat;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			RxCplRamWrEna;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [8:0]		RxCplRdAddr;		// From tlp_rxresp_cntrl of tlp_rxresp_cntrl.v
   wire			RxCplReq;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [56:0]		RxPndgRdFifoDato;	// From tlp_pndgtxrd_fifo of tlp_pndgtxrd_fifo.v
   wire			RxPndgRdFifoEmpty;	// From tlp_pndgtxrd_fifo of tlp_pndgtxrd_fifo.v
   wire			RxPndgRdFifoRdReq;	// From tlp_txresp_cntrl of tlp_txresp_cntrl.v
   wire			RxRdInProgress;		// From tlp_rxpd_fifo of tlp_rxpd_fifo.v
   wire [130:0]		RxRpFifoWrData;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			RxRpFifoWrReq;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [7:0]		RxStBarDec1_i;		// From txm_dummy of rxm_dummy.v
   wire [7:0]		RxStBarDec2_i;		// From txm_dummy of rxm_dummy.v
   wire [15:0]		RxStBe_i;		// From txm_dummy of rxm_dummy.v
   wire [127:0]		RxStData_i;		// From txm_dummy of rxm_dummy.v
   wire [1:0]		RxStEmpty_i;		// From txm_dummy of rxm_dummy.v
   wire			RxStEop_i;		// From txm_dummy of rxm_dummy.v
   wire [7:0]		RxStErr_i;		// From txm_dummy of rxm_dummy.v
   wire			RxStMask_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [64:0]		RxStParity_i;		// From txm_dummy of rxm_dummy.v
   wire			RxStReady_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			RxStSop_i;		// From txm_dummy of rxm_dummy.v
   wire			RxStValid_i;		// From txm_dummy of rxm_dummy.v
   wire [AVALON_ADDR_WIDTH-1:0] RxmAddress_0_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [AVALON_ADDR_WIDTH-1:0] RxmAddress_1_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [AVALON_ADDR_WIDTH-1:0] RxmAddress_2_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [AVALON_ADDR_WIDTH-1:0] RxmAddress_3_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [AVALON_ADDR_WIDTH-1:0] RxmAddress_4_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [AVALON_ADDR_WIDTH-1:0] RxmAddress_5_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [6:0]		RxmBurstCount_0_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [6:0]		RxmBurstCount_1_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [6:0]		RxmBurstCount_2_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [6:0]		RxmBurstCount_3_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [6:0]		RxmBurstCount_4_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [6:0]		RxmBurstCount_5_o;	// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_0_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_1_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_2_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_3_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_4_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_5_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [CG_RXM_IRQ_NUM-1:0] RxmIrq;		// From txm_dummy of rxm_dummy.v
   wire			RxmRead_0_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			RxmRead_1_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			RxmRead_2_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			RxmRead_3_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			RxmRead_4_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			RxmRead_5_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			RxmRstn_i;		// From txm_dummy of rxm_dummy.v
   wire			RxmWaitRequest_0_i;	// From txm_dummy of rxm_dummy.v
   wire			RxmWaitRequest_1_i;	// From txm_dummy of rxm_dummy.v
   wire			RxmWaitRequest_2_i;	// From txm_dummy of rxm_dummy.v
   wire			RxmWaitRequest_3_i;	// From txm_dummy of rxm_dummy.v
   wire			RxmWaitRequest_4_i;	// From txm_dummy of rxm_dummy.v
   wire			RxmWaitRequest_5_i;	// From txm_dummy of rxm_dummy.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_0_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_1_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_2_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_3_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_4_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_5_o;// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			RxmWrite_0_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			RxmWrite_1_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			RxmWrite_2_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			RxmWrite_3_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			RxmWrite_4_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			RxmWrite_5_o;		// From tlp_rx_cntrl of tlp_rx_cntrl.v
   wire			TxAdapterFifoEmpty_i;	// From txm_dummy of rxm_dummy.v
   wire [CG_AVALON_S_ADDR_WIDTH-1:0] TxAddress_i;// From txm_dummy of rxm_dummy.v
   wire [5:0]		TxBurstCount_i;		// From txm_dummy of rxm_dummy.v
   wire [15:0]		TxByteEnable_i;		// From txm_dummy of rxm_dummy.v
   wire			TxChipSelect_i;		// From txm_dummy of rxm_dummy.v
   wire [127:0]		TxCplDat;		// From tlp_txcpl_buffer of tlp_txcpl_buffer.v
   wire [4:0]		TxCplLine;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire			TxCplWr;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire [5:0]		TxCredHipCons_i;	// From txm_dummy of rxm_dummy.v
   wire [5:0]		TxCredInfinit_i;	// From txm_dummy of rxm_dummy.v
   wire [7:0]		TxCredNpHdrLimit_i;	// From txm_dummy of rxm_dummy.v
   wire			TxReadDataValid_i;	// From txm_dummy of rxm_dummy.v
   wire [31:0]		TxReadData_i;		// From txm_dummy of rxm_dummy.v
   wire			TxRead_i;		// From txm_dummy of rxm_dummy.v
   wire [98:0]		TxReqHeader;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   wire			TxReqWr;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   wire			TxRespIdle;		// From tlp_txresp_cntrl of tlp_txresp_cntrl.v
   wire [130:0]		TxRpFifoData;		// From tlp_rxpd_fifo of tlp_rxpd_fifo.v
   wire			TxRpFifoRdReq;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire [127:0]		TxStData_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire [1:0]		TxStEmpty_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire			TxStEop_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire			TxStReady_i;		// From txm_dummy of rxm_dummy.v
   wire			TxStSop_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire			TxStValid_o;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire			TxWaitRequest_o;	// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   wire			TxWrite_i;		// From txm_dummy of rxm_dummy.v
   wire			TxsReadDataValid_i;	// From txm_dummy of rxm_dummy.v
   wire			TxsReadDataValid_o;	// From tlp_rxresp_cntrl of tlp_rxresp_cntrl.v
   wire [127:0]		TxsReadData_o;		// From tlp_rxresp_cntrl of tlp_rxresp_cntrl.v
   wire [127:0]		WrDatFifoDi;		// From txm_dummy of rxm_dummy.v
   wire [128:0]		WrDatFifoDo;		// From tlp_txdat_fifo of tlp_txdat_fifo.v
   wire			WrDatFifoEop;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   wire			WrDatFifoFull;		// From tlp_txdat_fifo of tlp_txdat_fifo.v
   wire			WrDatFifoRdReq;		// From tlp_tx_cntrl of tlp_tx_cntrl.v
   wire [5:0]		WrDatFifoUsedW;		// From tlp_txdat_fifo of tlp_txdat_fifo.v
   wire			WrDatFifoWrReq;		// From tlp_m_axi_cntrl of tlp_m_axi_cntrl.v
   wire [31:0]		cb_p2a_avalon_addr_b0_i;// From txm_dummy of rxm_dummy.v
   wire [31:0]		cb_p2a_avalon_addr_b1_i;// From txm_dummy of rxm_dummy.v
   wire [31:0]		cb_p2a_avalon_addr_b2_i;// From txm_dummy of rxm_dummy.v
   wire [31:0]		cb_p2a_avalon_addr_b3_i;// From txm_dummy of rxm_dummy.v
   wire [31:0]		cb_p2a_avalon_addr_b4_i;// From txm_dummy of rxm_dummy.v
   wire [31:0]		cb_p2a_avalon_addr_b5_i;// From txm_dummy of rxm_dummy.v
   wire [31:0]		cb_p2a_avalon_addr_b6_i;// From txm_dummy of rxm_dummy.v
   wire [223:0]		k_bar_i;		// From txm_dummy of rxm_dummy.v
   wire [11:0]		ko_cpl_spc_data;	// From txm_dummy of rxm_dummy.v
   wire [7:0]		ko_cpl_spc_header;	// From txm_dummy of rxm_dummy.v
   wire			pld_clk_inuse;		// From txm_dummy of rxm_dummy.v
   wire			tx_cons_cred_sel;	// From tlp_tx_cntrl of tlp_tx_cntrl.v
   // End of automatics

   /* TX */
   tlp_m_axi_cntrl #(/*AUTOINSTPARAM*/
		     // Parameters
		     .CG_RXM_IRQ_NUM	(CG_RXM_IRQ_NUM),
		     .CB_A2P_ADDR_MAP_PASS_THRU_BITS(CB_A2P_ADDR_MAP_PASS_THRU_BITS),
		     .AXI4_ADDRESS_WIDTH(AXI4_ADDRESS_WIDTH),
		     .AXI4_RDATA_WIDTH	(AXI4_RDATA_WIDTH),
		     .AXI4_WDATA_WIDTH	(AXI4_WDATA_WIDTH),
		     .AXI4_ID_WIDTH	(AXI4_ID_WIDTH))
   tlp_m_axi_cntrl  (/*AUTOINST*/
		     // Outputs
		     .TxWaitRequest_o	(TxWaitRequest_o),
		     .TxReqWr		(TxReqWr),
		     .TxReqHeader	(TxReqHeader[98:0]),
		     .CmdFifoBusy	(CmdFifoBusy),
		     .WrDatFifoWrReq	(WrDatFifoWrReq),
		     .WrDatFifoEop	(WrDatFifoEop),
		     .S_AWREADY		(S_AWREADY),
		     .S_WREADY		(S_WREADY),
		     .S_BVALID		(S_BVALID),
		     .S_BRESP		(S_BRESP[1:0]),
		     .S_BID		(S_BID[((AXI4_ID_WIDTH)-1):0]),
		     .S_BUSER		(S_BUSER[((AXI4_USER_WIDTH)-1):0]),
		     .S_ARREADY		(S_ARREADY),
		     .S_RVALID		(S_RVALID),
		     .S_RDATA		(S_RDATA[((AXI4_RDATA_WIDTH)-1):0]),
		     .S_RRESP		(S_RRESP[1:0]),
		     .S_RLAST		(S_RLAST),
		     .S_RID		(S_RID[((AXI4_ID_WIDTH)-1):0]),
		     .S_RUSER		(S_RUSER[((AXI4_USER_WIDTH)-1):0]),
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
		     .MasterEnable	(MasterEnable),
		     .MsiCsr_i		(MsiCsr_i[15:0]),
		     .MsiAddr_i		(MsiAddr_i[63:0]),
		     .MsiData_i		(MsiData_i[15:0]),
		     .PCIeIrqEna	(PCIeIrqEna[31:0]),
		     .A2PMbWrAddr	(A2PMbWrAddr[11:0]),
		     .A2PMbWrReq	(A2PMbWrReq),
		     .TxsReadDataValid_i(TxsReadDataValid_i),
		     .RxmIrq		(RxmIrq[CG_RXM_IRQ_NUM-1:0]),
		     .ACLK		(ACLK),
		     .ARESETn		(ARESETn),
		     .S_AWVALID		(S_AWVALID),
		     .S_AWADDR		(S_AWADDR[((AXI4_ADDRESS_WIDTH)-1):0]),
		     .S_AWPROT		(S_AWPROT[2:0]),
		     .S_AWREGION	(S_AWREGION[3:0]),
		     .S_AWLEN		(S_AWLEN[7:0]),
		     .S_AWSIZE		(S_AWSIZE[2:0]),
		     .S_AWBURST		(S_AWBURST[1:0]),
		     .S_AWLOCK		(S_AWLOCK),
		     .S_AWCACHE		(S_AWCACHE[3:0]),
		     .S_AWQOS		(S_AWQOS[3:0]),
		     .S_AWID		(S_AWID[((AXI4_ID_WIDTH)-1):0]),
		     .S_AWUSER		(S_AWUSER[((AXI4_USER_WIDTH)-1):0]),
		     .S_WVALID		(S_WVALID),
		     .S_WDATA		(S_WDATA[((AXI4_WDATA_WIDTH)-1):0]),
		     .S_WSTRB		(S_WSTRB[(((AXI4_WDATA_WIDTH/8))-1):0]),
		     .S_WLAST		(S_WLAST),
		     .S_WUSER		(S_WUSER[((AXI4_USER_WIDTH)-1):0]),
		     .S_BREADY		(S_BREADY),
		     .S_ARVALID		(S_ARVALID),
		     .S_ARADDR		(S_ARADDR[((AXI4_ADDRESS_WIDTH)-1):0]),
		     .S_ARPROT		(S_ARPROT[2:0]),
		     .S_ARREGION	(S_ARREGION[3:0]),
		     .S_ARLEN		(S_ARLEN[7:0]),
		     .S_ARSIZE		(S_ARSIZE[2:0]),
		     .S_ARBURST		(S_ARBURST[1:0]),
		     .S_ARLOCK		(S_ARLOCK),
		     .S_ARCACHE		(S_ARCACHE[3:0]),
		     .S_ARQOS		(S_ARQOS[3:0]),
		     .S_ARID		(S_ARID[((AXI4_ID_WIDTH)-1):0]),
		     .S_ARUSER		(S_ARUSER[((AXI4_USER_WIDTH)-1):0]),
		     .S_RREADY		(S_RREADY));
   
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
		      .RxPndgRdFifoRdReq(RxPndgRdFifoRdReq),
		      .CplReqHeader	(CplReqHeader[98:0]),
		      .CplReqWr		(CplReqWr),
		      .CplRamWrAddr	(CplRamWrAddr[TXCPL_BUFF_ADDR_WIDTH-1:0]),
		      .TxRespIdle	(TxRespIdle),
		      // Inputs
		      .AvlClk_i		(AvlClk_i),
		      .Rstn_i		(Rstn_i),
		      .RxPndgRdFifoEmpty(RxPndgRdFifoEmpty),
		      .RxPndgRdFifoDato	(RxPndgRdFifoDato[56:0]),
		      .TxReadDataValid_i(TxReadDataValid_i),
		      .CmdFifoUsedW	(CmdFifoUsedW[3:0]),
		      .CmdFifoBusy	(CmdFifoBusy),
		      .DevCsr_i		(DevCsr_i[31:0]),
		      .BusDev_i		(BusDev_i[12:0]));
   
   tlp_tx_cntrl #(/*AUTOINSTPARAM*/
		  // Parameters
		  .ADDRESS_32BIT	(ADDRESS_32BIT),
		  .CB_PCIE_MODE		(CB_PCIE_MODE),
		  .CB_PCIE_RX_LITE	(CB_PCIE_RX_LITE))
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
		  .TxRpFifoRdReq	(TxRpFifoRdReq),
		  .TxCplWr		(TxCplWr),
		  .TxCplLine		(TxCplLine[4:0]),
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
		  .TxRpFifoData		(TxRpFifoData[130:0]),
		  .RpTLPReady		(RpTLPReady),
		  .RxCplBuffFree	(RxCplBuffFree),
		  .BusDev_i		(BusDev_i[12:0]),
		  .MsiCsr_i		(MsiCsr_i[15:0]),
		  .MsiAck_i		(MsiAck_i),
		  .IntxAck_i		(IntxAck_i),
		  .pld_clk_inuse	(pld_clk_inuse));
  
   /* RX */
   tlp_s_axi_cntrl #(/*AUTOINSTPARAM*/
		     // Parameters
		     .AXI4_ADDRESS_WIDTH(AXI4_ADDRESS_WIDTH),
		     .AXI4_RDATA_WIDTH	(AXI4_RDATA_WIDTH),
		     .AXI4_WDATA_WIDTH	(AXI4_WDATA_WIDTH),
		     .AXI4_ID_WIDTH	(AXI4_ID_WIDTH))
   tlp_s_axi_cntrl  (/*AUTOINST*/
		     // Outputs
		     .M_AWVALID		(M_AWVALID),
		     .M_AWADDR		(M_AWADDR[((AXI4_ADDRESS_WIDTH)-1):0]),
		     .M_AWPROT		(M_AWPROT[2:0]),
		     .M_AWREGION	(M_AWREGION[3:0]),
		     .M_AWLEN		(M_AWLEN[7:0]),
		     .M_AWSIZE		(M_AWSIZE[2:0]),
		     .M_AWBURST		(M_AWBURST[1:0]),
		     .M_AWLOCK		(M_AWLOCK),
		     .M_AWCACHE		(M_AWCACHE[3:0]),
		     .M_AWQOS		(M_AWQOS[3:0]),
		     .M_AWID		(M_AWID[((AXI4_ID_WIDTH)-1):0]),
		     .M_AWUSER		(M_AWUSER[((AXI4_USER_WIDTH)-1):0]),
		     .M_WVALID		(M_WVALID),
		     .M_WDATA		(M_WDATA[((AXI4_WDATA_WIDTH)-1):0]),
		     .M_WSTRB		(M_WSTRB[(((AXI4_WDATA_WIDTH/8))-1):0]),
		     .M_WLAST		(M_WLAST),
		     .M_WUSER		(M_WUSER[((AXI4_USER_WIDTH)-1):0]),
		     .M_BREADY		(M_BREADY),
		     .M_ARVALID		(M_ARVALID),
		     .M_ARADDR		(M_ARADDR[((AXI4_ADDRESS_WIDTH)-1):0]),
		     .M_ARPROT		(M_ARPROT[2:0]),
		     .M_ARREGION	(M_ARREGION[3:0]),
		     .M_ARLEN		(M_ARLEN[7:0]),
		     .M_ARSIZE		(M_ARSIZE[2:0]),
		     .M_ARBURST		(M_ARBURST[1:0]),
		     .M_ARLOCK		(M_ARLOCK),
		     .M_ARCACHE		(M_ARCACHE[3:0]),
		     .M_ARQOS		(M_ARQOS[3:0]),
		     .M_ARID		(M_ARID[((AXI4_ID_WIDTH)-1):0]),
		     .M_ARUSER		(M_ARUSER[((AXI4_USER_WIDTH)-1):0]),
		     .M_RREADY		(M_RREADY),
		     // Inputs
		     .ACLK		(ACLK),
		     .ARESETn		(ARESETn),
		     .M_AWREADY		(M_AWREADY),
		     .M_WREADY		(M_WREADY),
		     .M_BVALID		(M_BVALID),
		     .M_BRESP		(M_BRESP[1:0]),
		     .M_BID		(M_BID[((AXI4_ID_WIDTH)-1):0]),
		     .M_BUSER		(M_BUSER[((AXI4_USER_WIDTH)-1):0]),
		     .M_ARREADY		(M_ARREADY),
		     .M_RVALID		(M_RVALID),
		     .M_RDATA		(M_RDATA[((AXI4_RDATA_WIDTH)-1):0]),
		     .M_RRESP		(M_RRESP[1:0]),
		     .M_RLAST		(M_RLAST),
		     .M_RID		(M_RID[((AXI4_ID_WIDTH)-1):0]),
		     .M_RUSER		(M_RUSER[((AXI4_USER_WIDTH)-1):0]));
   
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
		  .RxRpFifoWrData	(RxRpFifoWrData[130:0]),
		  .RxRpFifoWrReq	(RxRpFifoWrReq),
		  .PndgRdFifoWrReq	(PndgRdFifoWrReq),
		  .PndgRdHeader		(PndgRdHeader[56:0]),
		  .RxCplRamWrAddr	(RxCplRamWrAddr[8:0]),
		  .RxCplRamWrDat	(RxCplRamWrDat[129:0]),
		  .RxCplRamWrEna	(RxCplRamWrEna),
		  .RxCplReq		(RxCplReq),
		  .RxCplDesc		(RxCplDesc[5:0]),
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
		  .PndngRdFifoUsedW	(PndngRdFifoUsedW[3:0]),
		  .PndngRdFifoEmpty	(PndngRdFifoEmpty),
		  .RxRdInProgress	(RxRdInProgress),
		  .TxCplWr		(TxCplWr),
		  .TxCplLine		(TxCplLine[4:0]),
		  .TxRespIdle		(TxRespIdle),
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
		   // Outputs
		   .TxRpFifoData	(TxRpFifoData[130:0]),
		   .RpTLPReady		(RpTLPReady),
		   .RxRdInProgress	(RxRdInProgress),
		   .A2PMbWrAddr		(A2PMbWrAddr[11:0]),
		   .A2PMbWrReq		(A2PMbWrReq),
		   .PCIeIrqEna		(PCIeIrqEna[31:0]),
		   .MasterEnable	(MasterEnable),
		   // Inputs
		   .clk			(clk),
		   .rst			(rst),
		   .TxRpFifoRdReq	(TxRpFifoRdReq),
		   .RxRpFifoWrData	(RxRpFifoWrData[130:0]),
		   .RxRpFifoWrReq	(RxRpFifoWrReq));

   tlp_pndgtxrd_fifo #(/*AUTOINSTPARAM*/)
   tlp_pndgtxrd_fifo  (/*AUTOINST*/
		       // Outputs
		       .PndngRdFifoUsedW(PndngRdFifoUsedW[3:0]),
		       .PndngRdFifoEmpty(PndngRdFifoEmpty),
		       .RxPndgRdFifoEmpty(RxPndgRdFifoEmpty),
		       .RxPndgRdFifoDato(RxPndgRdFifoDato[56:0]),
		       // Inputs
		       .clk		(clk),
		       .rst		(rst),
		       .PndgRdFifoWrReq	(PndgRdFifoWrReq),
		       .PndgRdHeader	(PndgRdHeader[56:0]),
		       .RxPndgRdFifoRdReq(RxPndgRdFifoRdReq));
   
   tlp_rxcpl_buffer #(/*AUTOINSTPARAM*/)
   tlp_rxcpl_buffer  (/*AUTOINST*/
		      // Outputs
		      .RxCplBufData	(RxCplBufData[129:0]),
		      // Inputs
		      .clk		(clk),
		      .rst		(rst),
		      .RxCplRamWrAddr	(RxCplRamWrAddr[8:0]),
		      .RxCplRamWrDat	(RxCplRamWrDat[129:0]),
		      .RxCplRamWrEna	(RxCplRamWrEna),
		      .RxCplRdAddr	(RxCplRdAddr[8:0]));

   tlp_rxresp_cntrl #(/*AUTOINSTPARAM*/
		      // Parameters
		      .CG_COMMON_CLOCK_MODE(CG_COMMON_CLOCK_MODE))
   tlp_rxresp_cntrl (/*AUTOINST*/
		     // Outputs
		     .RxCplRdAddr	(RxCplRdAddr[8:0]),
		     .RxCplBuffFree	(RxCplBuffFree),
		     .TxsReadData_o	(TxsReadData_o[127:0]),
		     .TxsReadDataValid_o(TxsReadDataValid_o),
		     // Inputs
		     .Clk_i		(Clk_i),
		     .AvlClk_i		(AvlClk_i),
		     .Rstn_i		(Rstn_i),
		     .RxmRstn_i		(RxmRstn_i),
		     .RxCplReq		(RxCplReq),
		     .RxCplDesc		(RxCplDesc[5:0]),
		     .RxCplBufData	(RxCplBufData[129:0]));

   rxm_dummy
     txm_dummy (/*AUTOINST*/
		// Outputs
		.RxmWaitRequest_0_i	(RxmWaitRequest_0_i),
		.RxmWaitRequest_1_i	(RxmWaitRequest_1_i),
		.RxmWaitRequest_2_i	(RxmWaitRequest_2_i),
		.RxmWaitRequest_3_i	(RxmWaitRequest_3_i),
		.RxmWaitRequest_4_i	(RxmWaitRequest_4_i),
		.RxmWaitRequest_5_i	(RxmWaitRequest_5_i),
		.RxStData_i		(RxStData_i[127:0]),
		.RxStParity_i		(RxStParity_i[64:0]),
		.RxStBe_i		(RxStBe_i[15:0]),
		.RxStEmpty_i		(RxStEmpty_i[1:0]),
		.RxStErr_i		(RxStErr_i[7:0]),
		.RxStSop_i		(RxStSop_i),
		.RxStEop_i		(RxStEop_i),
		.RxStValid_i		(RxStValid_i),
		.RxStBarDec1_i		(RxStBarDec1_i[7:0]),
		.RxStBarDec2_i		(RxStBarDec2_i[7:0]),
		.TxStReady_i		(TxStReady_i),
		.TxAdapterFifoEmpty_i	(TxAdapterFifoEmpty_i),
		.TxAddress_i		(TxAddress_i[CG_AVALON_S_ADDR_WIDTH-1:0]),
		.TxBurstCount_i		(TxBurstCount_i[5:0]),
		.TxByteEnable_i		(TxByteEnable_i[15:0]),
		.TxChipSelect_i		(TxChipSelect_i),
		.TxCredHipCons_i	(TxCredHipCons_i[5:0]),
		.TxCredInfinit_i	(TxCredInfinit_i[5:0]),
		.TxCredNpHdrLimit_i	(TxCredNpHdrLimit_i[7:0]),
		.TxReadDataValid_i	(TxReadDataValid_i),
		.TxReadData_i		(TxReadData_i[31:0]),
		.TxRead_i		(TxRead_i),
		.TxWrite_i		(TxWrite_i),
		.TxsReadDataValid_i	(TxsReadDataValid_i),
		.WrDatFifoDi		(WrDatFifoDi[127:0]),
		.AvlClk_i		(AvlClk_i),
		.BusDev_i		(BusDev_i[12:0]),
		.Clk_i			(Clk_i),
		.DevCsr_i		(DevCsr_i[31:0]),
		.IntxAck_i		(IntxAck_i),
		.MsiAck_i		(MsiAck_i),
		.MsiAddr_i		(MsiAddr_i[63:0]),
		.MsiCsr_i		(MsiCsr_i[15:0]),
		.MsiData_i		(MsiData_i[15:0]),
		.Rstn_i			(Rstn_i),
		.RxmIrq			(RxmIrq[CG_RXM_IRQ_NUM-1:0]),
		.RxmRstn_i		(RxmRstn_i),
		.cb_p2a_avalon_addr_b0_i(cb_p2a_avalon_addr_b0_i[31:0]),
		.cb_p2a_avalon_addr_b1_i(cb_p2a_avalon_addr_b1_i[31:0]),
		.cb_p2a_avalon_addr_b2_i(cb_p2a_avalon_addr_b2_i[31:0]),
		.cb_p2a_avalon_addr_b3_i(cb_p2a_avalon_addr_b3_i[31:0]),
		.cb_p2a_avalon_addr_b4_i(cb_p2a_avalon_addr_b4_i[31:0]),
		.cb_p2a_avalon_addr_b5_i(cb_p2a_avalon_addr_b5_i[31:0]),
		.cb_p2a_avalon_addr_b6_i(cb_p2a_avalon_addr_b6_i[31:0]),
		.k_bar_i		(k_bar_i[223:0]),
		.ko_cpl_spc_data	(ko_cpl_spc_data[11:0]),
		.ko_cpl_spc_header	(ko_cpl_spc_header[7:0]),
		.pld_clk_inuse		(pld_clk_inuse),
		// Inputs
		.RxmWrite_0_o		(RxmWrite_0_o),
		.RxmAddress_0_o		(RxmAddress_0_o[AVALON_ADDR_WIDTH-1:0]),
		.RxmWriteData_0_o	(RxmWriteData_0_o[CB_RXM_DATA_WIDTH-1:0]),
		.RxmByteEnable_0_o	(RxmByteEnable_0_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		.RxmBurstCount_0_o	(RxmBurstCount_0_o[6:0]),
		.RxmRead_0_o		(RxmRead_0_o),
		.RxmWrite_1_o		(RxmWrite_1_o),
		.RxmAddress_1_o		(RxmAddress_1_o[AVALON_ADDR_WIDTH-1:0]),
		.RxmWriteData_1_o	(RxmWriteData_1_o[CB_RXM_DATA_WIDTH-1:0]),
		.RxmByteEnable_1_o	(RxmByteEnable_1_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		.RxmBurstCount_1_o	(RxmBurstCount_1_o[6:0]),
		.RxmRead_1_o		(RxmRead_1_o),
		.RxmWrite_2_o		(RxmWrite_2_o),
		.RxmAddress_2_o		(RxmAddress_2_o[AVALON_ADDR_WIDTH-1:0]),
		.RxmWriteData_2_o	(RxmWriteData_2_o[CB_RXM_DATA_WIDTH-1:0]),
		.RxmByteEnable_2_o	(RxmByteEnable_2_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		.RxmBurstCount_2_o	(RxmBurstCount_2_o[6:0]),
		.RxmRead_2_o		(RxmRead_2_o),
		.RxmWrite_3_o		(RxmWrite_3_o),
		.RxmAddress_3_o		(RxmAddress_3_o[AVALON_ADDR_WIDTH-1:0]),
		.RxmWriteData_3_o	(RxmWriteData_3_o[CB_RXM_DATA_WIDTH-1:0]),
		.RxmByteEnable_3_o	(RxmByteEnable_3_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		.RxmBurstCount_3_o	(RxmBurstCount_3_o[6:0]),
		.RxmRead_3_o		(RxmRead_3_o),
		.RxmWrite_4_o		(RxmWrite_4_o),
		.RxmAddress_4_o		(RxmAddress_4_o[AVALON_ADDR_WIDTH-1:0]),
		.RxmWriteData_4_o	(RxmWriteData_4_o[CB_RXM_DATA_WIDTH-1:0]),
		.RxmByteEnable_4_o	(RxmByteEnable_4_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		.RxmBurstCount_4_o	(RxmBurstCount_4_o[6:0]),
		.RxmRead_4_o		(RxmRead_4_o),
		.RxmWrite_5_o		(RxmWrite_5_o),
		.RxmAddress_5_o		(RxmAddress_5_o[AVALON_ADDR_WIDTH-1:0]),
		.RxmWriteData_5_o	(RxmWriteData_5_o[CB_RXM_DATA_WIDTH-1:0]),
		.RxmByteEnable_5_o	(RxmByteEnable_5_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		.RxmBurstCount_5_o	(RxmBurstCount_5_o[6:0]),
		.RxmRead_5_o		(RxmRead_5_o),
		.RxStReady_o		(RxStReady_o),
		.RxStMask_o		(RxStMask_o),
		.TxStData_o		(TxStData_o[127:0]),
		.TxStSop_o		(TxStSop_o),
		.TxStEop_o		(TxStEop_o),
		.TxStEmpty_o		(TxStEmpty_o[1:0]),
		.TxStValid_o		(TxStValid_o),
		.CplPending_o		(CplPending_o),
		.TxWaitRequest_o	(TxWaitRequest_o),
		.TxsReadDataValid_o	(TxsReadDataValid_o),
		.TxsReadData_o		(TxsReadData_o[127:0]),
		.WrDatFifoFull		(WrDatFifoFull),
		.CmdFifoEmpty		(CmdFifoEmpty),
		.IntxReq_o		(IntxReq_o),
		.MsiReq_o		(MsiReq_o),
		.tx_cons_cred_sel	(tx_cons_cred_sel));
   
endmodule
// 
// tlp_app.v ends here
