// axi_tlp.v --- 
// 
// Filename: axi_tlp.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sat Nov 15 13:03:56 2014 (-0800)
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
module axi_tlp (/*AUTOARG*/
   // Outputs
   s_axis_tx_tvalid, s_axis_tx_tuser, s_axis_tx_tlast,
   s_axis_tx_tkeep, s_axis_tx_tdata, m_axis_rx_tready, fc_sel,
   cfg_turnoff_ok, S_WREADY, S_RVALID, S_RUSER, S_RRESP, S_RLAST,
   S_RID, S_RDATA, S_BVALID, S_BUSER, S_BRESP, S_BID, S_AWREADY,
   S_ARREADY, M_WVALID, M_WUSER, M_WSTRB, M_WLAST, M_WDATA, M_RREADY,
   M_BREADY, M_AWVALID, M_AWUSER, M_AWSIZE, M_AWREGION, M_AWQOS,
   M_AWPROT, M_AWLOCK, M_AWLEN, M_AWID, M_AWCACHE, M_AWBURST,
   M_AWADDR, M_ARVALID, M_ARUSER, M_ARSIZE, M_ARREGION, M_ARQOS,
   M_ARPROT, M_ARLOCK, M_ARLEN, M_ARID, M_ARCACHE, M_ARBURST,
   M_ARADDR,
   // Inputs
   user_reset, user_lnk_up, user_clk, tx_buf_av, s_axis_tx_tready,
   m_axis_rx_tvalid, m_axis_rx_tuser, m_axis_rx_tlast,
   m_axis_rx_tkeep, m_axis_rx_tdata, fc_ph, fc_pd, fc_nph, fc_npd,
   fc_cplh, fc_cpld, cfg_to_turnoff, cfg_completer_id, S_WVALID,
   S_WUSER, S_WSTRB, S_WLAST, S_WDATA, S_RREADY, S_BREADY, S_AWVALID,
   S_AWUSER, S_AWSIZE, S_AWREGION, S_AWQOS, S_AWPROT, S_AWLOCK,
   S_AWLEN, S_AWID, S_AWCACHE, S_AWBURST, S_AWADDR, S_ARVALID,
   S_ARUSER, S_ARSIZE, S_ARREGION, S_ARQOS, S_ARPROT, S_ARLOCK,
   S_ARLEN, S_ARID, S_ARCACHE, S_ARBURST, S_ARADDR, M_WREADY,
   M_RVALID, M_RUSER, M_RRESP, M_RLAST, M_RID, M_RDATA, M_BVALID,
   M_BUSER, M_BRESP, M_BID, M_AWREADY, M_ARREADY
   );
   parameter C_INSTANCE         = "axi_tlp_0" ;
   parameter C_FAMILY           = "kintex7" ;
   parameter C_S_AXI_ID_WIDTH   = 2 ;
   parameter C_S_AXI_DATA_WIDTH = 128 ;
   parameter C_S_AXI_ADDR_WIDTH = 32 ;
   parameter C_M_AXI_DATA_WIDTH = 128 ;
   parameter C_M_AXI_ADDR_WIDTH = 32 ;
   parameter C_S_AXI_SUPPORTS_NARROW_BURST = 1;

   parameter C_DATA_WIDTH = 128;
   parameter KEEP_WIDTH   = 16;

   //parameter C_M_AXI_ADDR_WIDTH      = 64;
   //parameter C_M_AXI_DATA_WIDTH      = 128;
   parameter C_M_AXI_THREAD_ID_WIDTH = 3;
   parameter C_M_AXI_USER_WIDTH      = 3;   

   //parameter C_S_AXI_ADDR_WIDTH      = 64;
   //parameter C_S_AXI_DATA_WIDTH      = 128;
   parameter C_S_AXI_THREAD_ID_WIDTH = 3;
   parameter C_S_AXI_USER_WIDTH      = 3;   
   
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		M_ARREADY;		// To altpcie_avl of altpcie_avl.v
   input		M_AWREADY;		// To altpcie_avl of altpcie_avl.v
   input [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_BID;// To altpcie_avl of altpcie_avl.v
   input [1:0]		M_BRESP;		// To altpcie_avl of altpcie_avl.v
   input [((C_M_AXI_USER_WIDTH)-1):0] M_BUSER;	// To altpcie_avl of altpcie_avl.v
   input		M_BVALID;		// To altpcie_avl of altpcie_avl.v
   input [((C_M_AXI_DATA_WIDTH)-1):0] M_RDATA;	// To altpcie_avl of altpcie_avl.v
   input [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_RID;// To altpcie_avl of altpcie_avl.v
   input		M_RLAST;		// To altpcie_avl of altpcie_avl.v
   input [1:0]		M_RRESP;		// To altpcie_avl of altpcie_avl.v
   input [((C_M_AXI_USER_WIDTH)-1):0] M_RUSER;	// To altpcie_avl of altpcie_avl.v
   input		M_RVALID;		// To altpcie_avl of altpcie_avl.v
   input		M_WREADY;		// To altpcie_avl of altpcie_avl.v
   input [((C_S_AXI_ADDR_WIDTH)-1):0] S_ARADDR;	// To altpcie_avl of altpcie_avl.v
   input [1:0]		S_ARBURST;		// To altpcie_avl of altpcie_avl.v
   input [3:0]		S_ARCACHE;		// To altpcie_avl of altpcie_avl.v
   input [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_ARID;// To altpcie_avl of altpcie_avl.v
   input [7:0]		S_ARLEN;		// To altpcie_avl of altpcie_avl.v
   input		S_ARLOCK;		// To altpcie_avl of altpcie_avl.v
   input [2:0]		S_ARPROT;		// To altpcie_avl of altpcie_avl.v
   input [3:0]		S_ARQOS;		// To altpcie_avl of altpcie_avl.v
   input [3:0]		S_ARREGION;		// To altpcie_avl of altpcie_avl.v
   input [2:0]		S_ARSIZE;		// To altpcie_avl of altpcie_avl.v
   input [((C_S_AXI_USER_WIDTH)-1):0] S_ARUSER;	// To altpcie_avl of altpcie_avl.v
   input		S_ARVALID;		// To altpcie_avl of altpcie_avl.v
   input [((C_S_AXI_ADDR_WIDTH)-1):0] S_AWADDR;	// To altpcie_avl of altpcie_avl.v
   input [1:0]		S_AWBURST;		// To altpcie_avl of altpcie_avl.v
   input [3:0]		S_AWCACHE;		// To altpcie_avl of altpcie_avl.v
   input [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_AWID;// To altpcie_avl of altpcie_avl.v
   input [7:0]		S_AWLEN;		// To altpcie_avl of altpcie_avl.v
   input		S_AWLOCK;		// To altpcie_avl of altpcie_avl.v
   input [2:0]		S_AWPROT;		// To altpcie_avl of altpcie_avl.v
   input [3:0]		S_AWQOS;		// To altpcie_avl of altpcie_avl.v
   input [3:0]		S_AWREGION;		// To altpcie_avl of altpcie_avl.v
   input [2:0]		S_AWSIZE;		// To altpcie_avl of altpcie_avl.v
   input [((C_S_AXI_USER_WIDTH)-1):0] S_AWUSER;	// To altpcie_avl of altpcie_avl.v
   input		S_AWVALID;		// To altpcie_avl of altpcie_avl.v
   input		S_BREADY;		// To altpcie_avl of altpcie_avl.v
   input		S_RREADY;		// To altpcie_avl of altpcie_avl.v
   input [((C_S_AXI_DATA_WIDTH)-1):0] S_WDATA;	// To altpcie_avl of altpcie_avl.v
   input		S_WLAST;		// To altpcie_avl of altpcie_avl.v
   input [(((C_S_AXI_DATA_WIDTH/8))-1):0] S_WSTRB;// To altpcie_avl of altpcie_avl.v
   input [((C_S_AXI_USER_WIDTH)-1):0] S_WUSER;	// To altpcie_avl of altpcie_avl.v
   input		S_WVALID;		// To altpcie_avl of altpcie_avl.v
   input [11:0]		cfg_completer_id;	// To altpcie_avl of altpcie_avl.v
   input		cfg_to_turnoff;		// To altpcie_avl of altpcie_avl.v
   input [11:0]		fc_cpld;		// To altpcie_avl of altpcie_avl.v
   input [7:0]		fc_cplh;		// To altpcie_avl of altpcie_avl.v
   input [11:0]		fc_npd;			// To altpcie_avl of altpcie_avl.v
   input [7:0]		fc_nph;			// To altpcie_avl of altpcie_avl.v
   input [11:0]		fc_pd;			// To altpcie_avl of altpcie_avl.v
   input [7:0]		fc_ph;			// To altpcie_avl of altpcie_avl.v
   input [C_DATA_WIDTH-1:0] m_axis_rx_tdata;	// To altpcie_avl of altpcie_avl.v
   input [KEEP_WIDTH-1:0] m_axis_rx_tkeep;	// To altpcie_avl of altpcie_avl.v
   input		m_axis_rx_tlast;	// To altpcie_avl of altpcie_avl.v
   input [21:0]		m_axis_rx_tuser;	// To altpcie_avl of altpcie_avl.v
   input		m_axis_rx_tvalid;	// To altpcie_avl of altpcie_avl.v
   input		s_axis_tx_tready;	// To altpcie_avl of altpcie_avl.v
   input [5:0]		tx_buf_av;		// To altpcie_avl of altpcie_avl.v
   input		user_clk;		// To altpcie_avl of altpcie_avl.v
   input		user_lnk_up;		// To altpcie_avl of altpcie_avl.v
   input		user_reset;		// To altpcie_avl of altpcie_avl.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [((C_M_AXI_ADDR_WIDTH)-1):0] M_ARADDR;// From altpcie_avl of altpcie_avl.v
   output [1:0]		M_ARBURST;		// From altpcie_avl of altpcie_avl.v
   output [3:0]		M_ARCACHE;		// From altpcie_avl of altpcie_avl.v
   output [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_ARID;// From altpcie_avl of altpcie_avl.v
   output [7:0]		M_ARLEN;		// From altpcie_avl of altpcie_avl.v
   output		M_ARLOCK;		// From altpcie_avl of altpcie_avl.v
   output [2:0]		M_ARPROT;		// From altpcie_avl of altpcie_avl.v
   output [3:0]		M_ARQOS;		// From altpcie_avl of altpcie_avl.v
   output [3:0]		M_ARREGION;		// From altpcie_avl of altpcie_avl.v
   output [2:0]		M_ARSIZE;		// From altpcie_avl of altpcie_avl.v
   output [((C_M_AXI_USER_WIDTH)-1):0] M_ARUSER;// From altpcie_avl of altpcie_avl.v
   output		M_ARVALID;		// From altpcie_avl of altpcie_avl.v
   output [((C_M_AXI_ADDR_WIDTH)-1):0] M_AWADDR;// From altpcie_avl of altpcie_avl.v
   output [1:0]		M_AWBURST;		// From altpcie_avl of altpcie_avl.v
   output [3:0]		M_AWCACHE;		// From altpcie_avl of altpcie_avl.v
   output [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_AWID;// From altpcie_avl of altpcie_avl.v
   output [7:0]		M_AWLEN;		// From altpcie_avl of altpcie_avl.v
   output		M_AWLOCK;		// From altpcie_avl of altpcie_avl.v
   output [2:0]		M_AWPROT;		// From altpcie_avl of altpcie_avl.v
   output [3:0]		M_AWQOS;		// From altpcie_avl of altpcie_avl.v
   output [3:0]		M_AWREGION;		// From altpcie_avl of altpcie_avl.v
   output [2:0]		M_AWSIZE;		// From altpcie_avl of altpcie_avl.v
   output [((C_M_AXI_USER_WIDTH)-1):0] M_AWUSER;// From altpcie_avl of altpcie_avl.v
   output		M_AWVALID;		// From altpcie_avl of altpcie_avl.v
   output		M_BREADY;		// From altpcie_avl of altpcie_avl.v
   output		M_RREADY;		// From altpcie_avl of altpcie_avl.v
   output [((C_M_AXI_DATA_WIDTH)-1):0] M_WDATA;	// From altpcie_avl of altpcie_avl.v
   output		M_WLAST;		// From altpcie_avl of altpcie_avl.v
   output [(((C_M_AXI_DATA_WIDTH/8))-1):0] M_WSTRB;// From altpcie_avl of altpcie_avl.v
   output [((C_M_AXI_USER_WIDTH)-1):0] M_WUSER;	// From altpcie_avl of altpcie_avl.v
   output		M_WVALID;		// From altpcie_avl of altpcie_avl.v
   output		S_ARREADY;		// From altpcie_avl of altpcie_avl.v
   output		S_AWREADY;		// From altpcie_avl of altpcie_avl.v
   output [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_BID;// From altpcie_avl of altpcie_avl.v
   output [1:0]		S_BRESP;		// From altpcie_avl of altpcie_avl.v
   output [((C_S_AXI_USER_WIDTH)-1):0] S_BUSER;	// From altpcie_avl of altpcie_avl.v
   output		S_BVALID;		// From altpcie_avl of altpcie_avl.v
   output [((C_S_AXI_DATA_WIDTH)-1):0] S_RDATA;	// From altpcie_avl of altpcie_avl.v
   output [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_RID;// From altpcie_avl of altpcie_avl.v
   output		S_RLAST;		// From altpcie_avl of altpcie_avl.v
   output [1:0]		S_RRESP;		// From altpcie_avl of altpcie_avl.v
   output [((C_S_AXI_USER_WIDTH)-1):0] S_RUSER;	// From altpcie_avl of altpcie_avl.v
   output		S_RVALID;		// From altpcie_avl of altpcie_avl.v
   output		S_WREADY;		// From altpcie_avl of altpcie_avl.v
   output		cfg_turnoff_ok;		// From altpcie_avl of altpcie_avl.v
   output [2:0]		fc_sel;			// From altpcie_avl of altpcie_avl.v
   output		m_axis_rx_tready;	// From altpcie_avl of altpcie_avl.v
   output [C_DATA_WIDTH-1:0] s_axis_tx_tdata;	// From altpcie_avl of altpcie_avl.v
   output [KEEP_WIDTH-1:0] s_axis_tx_tkeep;	// From altpcie_avl of altpcie_avl.v
   output		s_axis_tx_tlast;	// From altpcie_avl of altpcie_avl.v
   output [3:0]		s_axis_tx_tuser;	// From altpcie_avl of altpcie_avl.v
   output		s_axis_tx_tvalid;	// From altpcie_avl of altpcie_avl.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [63:0]		m_Address;		// From altpcie_avl_stub of altpcie_avl_stub.v
   wire [5:0]		m_BurstCount;		// From altpcie_avl_stub of altpcie_avl_stub.v
   wire [15:0]		m_ByteEnable;		// From altpcie_avl_stub of altpcie_avl_stub.v
   wire			m_ChipSelect;		// From altpcie_avl_stub of altpcie_avl_stub.v
   wire			m_Read;			// From altpcie_avl_stub of altpcie_avl_stub.v
   wire [127:0]		m_ReadData;		// From altpcie_avl of altpcie_avl.v
   wire			m_ReadDataValid;	// From altpcie_avl of altpcie_avl.v
   wire			m_WaitRequest;		// From altpcie_avl of altpcie_avl.v
   wire			m_Write;		// From altpcie_avl_stub of altpcie_avl_stub.v
   wire [127:0]		m_WriteData;		// From altpcie_avl_stub of altpcie_avl_stub.v
   wire [31:0]		s_Address;		// From altpcie_avl of altpcie_avl.v
   wire [5:0]		s_BurstCount;		// From altpcie_avl of altpcie_avl.v
   wire [15:0]		s_ByteEnable;		// From altpcie_avl of altpcie_avl.v
   wire			s_Read;			// From altpcie_avl of altpcie_avl.v
   wire [127:0]		s_ReadData;		// From altpcie_avl_stub of altpcie_avl_stub.v
   wire			s_ReadDataValid;	// From altpcie_avl_stub of altpcie_avl_stub.v
   wire			s_WaitRequest;		// From altpcie_avl_stub of altpcie_avl_stub.v
   wire			s_Write;		// From altpcie_avl of altpcie_avl.v
   wire [127:0]		s_WriteData;		// From altpcie_avl of altpcie_avl.v
   // End of automatics

   altpcie_avl_stub
   altpcie_avl_stub  (/*AUTOINST*/
		      // Outputs
		      .m_ChipSelect	(m_ChipSelect),
		      .m_Read		(m_Read),
		      .m_Write		(m_Write),
		      .m_BurstCount	(m_BurstCount[5:0]),
		      .m_ByteEnable	(m_ByteEnable[15:0]),
		      .m_Address	(m_Address[63:0]),
		      .m_WriteData	(m_WriteData[127:0]),
		      .s_WaitRequest	(s_WaitRequest),
		      .s_ReadData	(s_ReadData[127:0]),
		      .s_ReadDataValid	(s_ReadDataValid),
		      // Inputs
		      .m_WaitRequest	(m_WaitRequest),
		      .m_ReadData	(m_ReadData[127:0]),
		      .m_ReadDataValid	(m_ReadDataValid),
		      .s_Read		(s_Read),
		      .s_Write		(s_Write),
		      .s_BurstCount	(s_BurstCount[5:0]),
		      .s_ByteEnable	(s_ByteEnable[15:0]),
		      .s_Address	(s_Address[31:0]),
		      .s_WriteData	(s_WriteData[127:0]));
   
   altpcie_avl #(/*AUTOINSTPARAM*/
		 // Parameters
		 .C_DATA_WIDTH		(C_DATA_WIDTH),
		 .KEEP_WIDTH		(KEEP_WIDTH),
		 .C_M_AXI_ADDR_WIDTH	(C_M_AXI_ADDR_WIDTH),
		 .C_M_AXI_DATA_WIDTH	(C_M_AXI_DATA_WIDTH),
		 .C_M_AXI_THREAD_ID_WIDTH(C_M_AXI_THREAD_ID_WIDTH),
		 .C_M_AXI_USER_WIDTH	(C_M_AXI_USER_WIDTH),
		 .C_S_AXI_ADDR_WIDTH	(C_S_AXI_ADDR_WIDTH),
		 .C_S_AXI_DATA_WIDTH	(C_S_AXI_DATA_WIDTH),
		 .C_S_AXI_THREAD_ID_WIDTH(C_S_AXI_THREAD_ID_WIDTH),
		 .C_S_AXI_USER_WIDTH	(C_S_AXI_USER_WIDTH))
   altpcie_avl  (/*AUTOINST*/
		 // Outputs
		 .s_axis_tx_tdata	(s_axis_tx_tdata[C_DATA_WIDTH-1:0]),
		 .s_axis_tx_tkeep	(s_axis_tx_tkeep[KEEP_WIDTH-1:0]),
		 .s_axis_tx_tlast	(s_axis_tx_tlast),
		 .s_axis_tx_tvalid	(s_axis_tx_tvalid),
		 .m_axis_rx_tready	(m_axis_rx_tready),
		 .cfg_turnoff_ok	(cfg_turnoff_ok),
		 .M_ARADDR		(M_ARADDR[((C_M_AXI_ADDR_WIDTH)-1):0]),
		 .M_ARBURST		(M_ARBURST[1:0]),
		 .M_ARCACHE		(M_ARCACHE[3:0]),
		 .M_ARID		(M_ARID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
		 .M_ARLEN		(M_ARLEN[7:0]),
		 .M_ARLOCK		(M_ARLOCK),
		 .M_ARPROT		(M_ARPROT[2:0]),
		 .M_ARQOS		(M_ARQOS[3:0]),
		 .M_ARREGION		(M_ARREGION[3:0]),
		 .M_ARSIZE		(M_ARSIZE[2:0]),
		 .M_ARUSER		(M_ARUSER[((C_M_AXI_USER_WIDTH)-1):0]),
		 .M_ARVALID		(M_ARVALID),
		 .M_AWADDR		(M_AWADDR[((C_M_AXI_ADDR_WIDTH)-1):0]),
		 .M_AWBURST		(M_AWBURST[1:0]),
		 .M_AWCACHE		(M_AWCACHE[3:0]),
		 .M_AWID		(M_AWID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
		 .M_AWLEN		(M_AWLEN[7:0]),
		 .M_AWLOCK		(M_AWLOCK),
		 .M_AWPROT		(M_AWPROT[2:0]),
		 .M_AWQOS		(M_AWQOS[3:0]),
		 .M_AWREGION		(M_AWREGION[3:0]),
		 .M_AWSIZE		(M_AWSIZE[2:0]),
		 .M_AWUSER		(M_AWUSER[((C_M_AXI_USER_WIDTH)-1):0]),
		 .M_AWVALID		(M_AWVALID),
		 .M_BREADY		(M_BREADY),
		 .M_RREADY		(M_RREADY),
		 .M_WDATA		(M_WDATA[((C_M_AXI_DATA_WIDTH)-1):0]),
		 .M_WLAST		(M_WLAST),
		 .M_WSTRB		(M_WSTRB[(((C_M_AXI_DATA_WIDTH/8))-1):0]),
		 .M_WUSER		(M_WUSER[((C_M_AXI_USER_WIDTH)-1):0]),
		 .M_WVALID		(M_WVALID),
		 .S_ARREADY		(S_ARREADY),
		 .S_AWREADY		(S_AWREADY),
		 .S_BID			(S_BID[((C_S_AXI_THREAD_ID_WIDTH)-1):0]),
		 .S_BRESP		(S_BRESP[1:0]),
		 .S_BUSER		(S_BUSER[((C_S_AXI_USER_WIDTH)-1):0]),
		 .S_BVALID		(S_BVALID),
		 .S_RDATA		(S_RDATA[((C_S_AXI_DATA_WIDTH)-1):0]),
		 .S_RID			(S_RID[((C_S_AXI_THREAD_ID_WIDTH)-1):0]),
		 .S_RLAST		(S_RLAST),
		 .S_RRESP		(S_RRESP[1:0]),
		 .S_RUSER		(S_RUSER[((C_S_AXI_USER_WIDTH)-1):0]),
		 .S_RVALID		(S_RVALID),
		 .S_WREADY		(S_WREADY),
		 .fc_sel		(fc_sel[2:0]),
		 .m_ReadData		(m_ReadData[127:0]),
		 .m_ReadDataValid	(m_ReadDataValid),
		 .m_WaitRequest		(m_WaitRequest),
		 .s_Address		(s_Address[31:0]),
		 .s_BurstCount		(s_BurstCount[5:0]),
		 .s_ByteEnable		(s_ByteEnable[15:0]),
		 .s_Read		(s_Read),
		 .s_Write		(s_Write),
		 .s_WriteData		(s_WriteData[127:0]),
		 .s_axis_tx_tuser	(s_axis_tx_tuser[3:0]),
		 // Inputs
		 .user_clk		(user_clk),
		 .user_reset		(user_reset),
		 .user_lnk_up		(user_lnk_up),
		 .s_axis_tx_tready	(s_axis_tx_tready),
		 .m_axis_rx_tdata	(m_axis_rx_tdata[C_DATA_WIDTH-1:0]),
		 .m_axis_rx_tkeep	(m_axis_rx_tkeep[KEEP_WIDTH-1:0]),
		 .m_axis_rx_tlast	(m_axis_rx_tlast),
		 .m_axis_rx_tvalid	(m_axis_rx_tvalid),
		 .m_axis_rx_tuser	(m_axis_rx_tuser[21:0]),
		 .cfg_to_turnoff	(cfg_to_turnoff),
		 .cfg_completer_id	(cfg_completer_id[11:0]),
		 .M_ARREADY		(M_ARREADY),
		 .M_AWREADY		(M_AWREADY),
		 .M_BID			(M_BID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
		 .M_BRESP		(M_BRESP[1:0]),
		 .M_BUSER		(M_BUSER[((C_M_AXI_USER_WIDTH)-1):0]),
		 .M_BVALID		(M_BVALID),
		 .M_RDATA		(M_RDATA[((C_M_AXI_DATA_WIDTH)-1):0]),
		 .M_RID			(M_RID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
		 .M_RLAST		(M_RLAST),
		 .M_RRESP		(M_RRESP[1:0]),
		 .M_RUSER		(M_RUSER[((C_M_AXI_USER_WIDTH)-1):0]),
		 .M_RVALID		(M_RVALID),
		 .M_WREADY		(M_WREADY),
		 .S_ARADDR		(S_ARADDR[((C_S_AXI_ADDR_WIDTH)-1):0]),
		 .S_ARBURST		(S_ARBURST[1:0]),
		 .S_ARCACHE		(S_ARCACHE[3:0]),
		 .S_ARID		(S_ARID[((C_S_AXI_THREAD_ID_WIDTH)-1):0]),
		 .S_ARLEN		(S_ARLEN[7:0]),
		 .S_ARLOCK		(S_ARLOCK),
		 .S_ARPROT		(S_ARPROT[2:0]),
		 .S_ARQOS		(S_ARQOS[3:0]),
		 .S_ARREGION		(S_ARREGION[3:0]),
		 .S_ARSIZE		(S_ARSIZE[2:0]),
		 .S_ARUSER		(S_ARUSER[((C_S_AXI_USER_WIDTH)-1):0]),
		 .S_ARVALID		(S_ARVALID),
		 .S_AWADDR		(S_AWADDR[((C_S_AXI_ADDR_WIDTH)-1):0]),
		 .S_AWBURST		(S_AWBURST[1:0]),
		 .S_AWCACHE		(S_AWCACHE[3:0]),
		 .S_AWID		(S_AWID[((C_S_AXI_THREAD_ID_WIDTH)-1):0]),
		 .S_AWLEN		(S_AWLEN[7:0]),
		 .S_AWLOCK		(S_AWLOCK),
		 .S_AWPROT		(S_AWPROT[2:0]),
		 .S_AWQOS		(S_AWQOS[3:0]),
		 .S_AWREGION		(S_AWREGION[3:0]),
		 .S_AWSIZE		(S_AWSIZE[2:0]),
		 .S_AWUSER		(S_AWUSER[((C_S_AXI_USER_WIDTH)-1):0]),
		 .S_AWVALID		(S_AWVALID),
		 .S_BREADY		(S_BREADY),
		 .S_RREADY		(S_RREADY),
		 .S_WDATA		(S_WDATA[((C_S_AXI_DATA_WIDTH)-1):0]),
		 .S_WLAST		(S_WLAST),
		 .S_WSTRB		(S_WSTRB[(((C_S_AXI_DATA_WIDTH/8))-1):0]),
		 .S_WUSER		(S_WUSER[((C_S_AXI_USER_WIDTH)-1):0]),
		 .S_WVALID		(S_WVALID),
		 .fc_cpld		(fc_cpld[11:0]),
		 .fc_cplh		(fc_cplh[7:0]),
		 .fc_npd		(fc_npd[11:0]),
		 .fc_nph		(fc_nph[7:0]),
		 .fc_pd			(fc_pd[11:0]),
		 .fc_ph			(fc_ph[7:0]),
		 .m_Address		(m_Address[63:0]),
		 .m_BurstCount		(m_BurstCount[5:0]),
		 .m_ByteEnable		(m_ByteEnable[15:0]),
		 .m_ChipSelect		(m_ChipSelect),
		 .m_Read		(m_Read),
		 .m_Write		(m_Write),
		 .m_WriteData		(m_WriteData[127:0]),
		 .s_ReadData		(s_ReadData[127:0]),
		 .s_ReadDataValid	(s_ReadDataValid),
		 .s_WaitRequest		(s_WaitRequest),
		 .tx_buf_av		(tx_buf_av[5:0]));
endmodule
// 
// axi_tlp.v ends here
