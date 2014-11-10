`timescale 1ps/1ps

module PIO #(
  parameter C_DATA_WIDTH = 128,            // RX/TX interface data width
  // Do not override parameters below this line
  parameter KEEP_WIDTH = C_DATA_WIDTH / 8,              // TSTRB width
  parameter TCQ        = 1
)(
  input                         user_clk,
  input                         user_reset,
  input                         user_lnk_up,

  // AXIS
  input                         s_axis_tx_tready,
  output  [C_DATA_WIDTH-1:0]    s_axis_tx_tdata,
  output  [KEEP_WIDTH-1:0]      s_axis_tx_tkeep,
  output                        s_axis_tx_tlast,
  output                        s_axis_tx_tvalid,
  output                        tx_src_dsc,


  input  [C_DATA_WIDTH-1:0]     m_axis_rx_tdata,
  input  [KEEP_WIDTH-1:0]       m_axis_rx_tkeep,
  input                         m_axis_rx_tlast,
  input                         m_axis_rx_tvalid,
  output                        m_axis_rx_tready,
  input    [21:0]               m_axis_rx_tuser,


  input                         cfg_to_turnoff,
  output                        cfg_turnoff_ok,

  input [15:0]                  cfg_completer_id,

  input  [11:0]                 fc_cpld,
  input  [7:0]                  fc_cplh,
  input  [11:0]                 fc_npd,
  input  [7:0]                  fc_nph,
  input  [11:0]                 fc_pd,
  input  [7:0]                  fc_ph,
  output [2:0]                  fc_sel
);
   
   localparam C_M_AXI_ADDR_WIDTH      = 64;
   localparam C_M_AXI_DATA_WIDTH      = 128;
   localparam C_M_AXI_THREAD_ID_WIDTH = 3;
   localparam C_M_AXI_USER_WIDTH      = 3;
   localparam C_S_AXI_ADDR_WIDTH      = 64;
   localparam C_S_AXI_DATA_WIDTH      = 128;
   localparam C_S_AXI_THREAD_ID_WIDTH = 3;
   localparam C_S_AXI_USER_WIDTH      = 3;
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [((C_M_AXI_ADDR_WIDTH)-1):0] M_ARADDR;	// From altpcie_avl of altpcie_avl.v
   wire [1:0]		M_ARBURST;		// From altpcie_avl of altpcie_avl.v
   wire [3:0]		M_ARCACHE;		// From altpcie_avl of altpcie_avl.v
   wire [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_ARID;// From altpcie_avl of altpcie_avl.v
   wire [7:0]		M_ARLEN;		// From altpcie_avl of altpcie_avl.v
   wire			M_ARLOCK;		// From altpcie_avl of altpcie_avl.v
   wire [2:0]		M_ARPROT;		// From altpcie_avl of altpcie_avl.v
   wire [3:0]		M_ARQOS;		// From altpcie_avl of altpcie_avl.v
   wire			M_ARREADY;		// From m_tb of m_tb.v
   wire [3:0]		M_ARREGION;		// From altpcie_avl of altpcie_avl.v
   wire [2:0]		M_ARSIZE;		// From altpcie_avl of altpcie_avl.v
   wire [((C_M_AXI_USER_WIDTH)-1):0] M_ARUSER;	// From altpcie_avl of altpcie_avl.v
   wire			M_ARVALID;		// From altpcie_avl of altpcie_avl.v
   wire [((C_M_AXI_ADDR_WIDTH)-1):0] M_AWADDR;	// From altpcie_avl of altpcie_avl.v
   wire [1:0]		M_AWBURST;		// From altpcie_avl of altpcie_avl.v
   wire [3:0]		M_AWCACHE;		// From altpcie_avl of altpcie_avl.v
   wire [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_AWID;// From altpcie_avl of altpcie_avl.v
   wire [7:0]		M_AWLEN;		// From altpcie_avl of altpcie_avl.v
   wire			M_AWLOCK;		// From altpcie_avl of altpcie_avl.v
   wire [2:0]		M_AWPROT;		// From altpcie_avl of altpcie_avl.v
   wire [3:0]		M_AWQOS;		// From altpcie_avl of altpcie_avl.v
   wire			M_AWREADY;		// From m_tb of m_tb.v
   wire [3:0]		M_AWREGION;		// From altpcie_avl of altpcie_avl.v
   wire [2:0]		M_AWSIZE;		// From altpcie_avl of altpcie_avl.v
   wire [((C_M_AXI_USER_WIDTH)-1):0] M_AWUSER;	// From altpcie_avl of altpcie_avl.v
   wire			M_AWVALID;		// From altpcie_avl of altpcie_avl.v
   wire [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_BID;// From m_tb of m_tb.v
   wire			M_BREADY;		// From altpcie_avl of altpcie_avl.v
   wire [1:0]		M_BRESP;		// From m_tb of m_tb.v
   wire [((C_M_AXI_USER_WIDTH)-1):0] M_BUSER;	// From m_tb of m_tb.v
   wire			M_BVALID;		// From m_tb of m_tb.v
   wire [((C_M_AXI_DATA_WIDTH)-1):0] M_RDATA;	// From m_tb of m_tb.v
   wire [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_RID;// From m_tb of m_tb.v
   wire			M_RLAST;		// From m_tb of m_tb.v
   wire			M_RREADY;		// From altpcie_avl of altpcie_avl.v
   wire [1:0]		M_RRESP;		// From m_tb of m_tb.v
   wire [((C_M_AXI_USER_WIDTH)-1):0] M_RUSER;	// From m_tb of m_tb.v
   wire			M_RVALID;		// From m_tb of m_tb.v
   wire [((C_M_AXI_DATA_WIDTH)-1):0] M_WDATA;	// From altpcie_avl of altpcie_avl.v
   wire			M_WLAST;		// From altpcie_avl of altpcie_avl.v
   wire			M_WREADY;		// From m_tb of m_tb.v
   wire [(((C_M_AXI_DATA_WIDTH/8))-1):0] M_WSTRB;// From altpcie_avl of altpcie_avl.v
   wire [((C_M_AXI_USER_WIDTH)-1):0] M_WUSER;	// From altpcie_avl of altpcie_avl.v
   wire			M_WVALID;		// From altpcie_avl of altpcie_avl.v
   wire [((C_S_AXI_ADDR_WIDTH)-1):0] S_ARADDR;	// From m_tb of m_tb.v
   wire [1:0]		S_ARBURST;		// From m_tb of m_tb.v
   wire [3:0]		S_ARCACHE;		// From m_tb of m_tb.v
   wire [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_ARID;// From m_tb of m_tb.v
   wire [7:0]		S_ARLEN;		// From m_tb of m_tb.v
   wire			S_ARLOCK;		// From m_tb of m_tb.v
   wire [2:0]		S_ARPROT;		// From m_tb of m_tb.v
   wire [3:0]		S_ARQOS;		// From m_tb of m_tb.v
   wire			S_ARREADY;		// From altpcie_avl of altpcie_avl.v
   wire [3:0]		S_ARREGION;		// From m_tb of m_tb.v
   wire [2:0]		S_ARSIZE;		// From m_tb of m_tb.v
   wire [((C_S_AXI_USER_WIDTH)-1):0] S_ARUSER;	// From m_tb of m_tb.v
   wire			S_ARVALID;		// From m_tb of m_tb.v
   wire [((C_S_AXI_ADDR_WIDTH)-1):0] S_AWADDR;	// From m_tb of m_tb.v
   wire [1:0]		S_AWBURST;		// From m_tb of m_tb.v
   wire [3:0]		S_AWCACHE;		// From m_tb of m_tb.v
   wire [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_AWID;// From m_tb of m_tb.v
   wire [7:0]		S_AWLEN;		// From m_tb of m_tb.v
   wire			S_AWLOCK;		// From m_tb of m_tb.v
   wire [2:0]		S_AWPROT;		// From m_tb of m_tb.v
   wire [3:0]		S_AWQOS;		// From m_tb of m_tb.v
   wire			S_AWREADY;		// From altpcie_avl of altpcie_avl.v
   wire [3:0]		S_AWREGION;		// From m_tb of m_tb.v
   wire [2:0]		S_AWSIZE;		// From m_tb of m_tb.v
   wire [((C_S_AXI_USER_WIDTH)-1):0] S_AWUSER;	// From m_tb of m_tb.v
   wire			S_AWVALID;		// From m_tb of m_tb.v
   wire [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_BID;// From altpcie_avl of altpcie_avl.v
   wire			S_BREADY;		// From m_tb of m_tb.v
   wire [1:0]		S_BRESP;		// From altpcie_avl of altpcie_avl.v
   wire [((C_S_AXI_USER_WIDTH)-1):0] S_BUSER;	// From altpcie_avl of altpcie_avl.v
   wire			S_BVALID;		// From altpcie_avl of altpcie_avl.v
   wire [((C_S_AXI_DATA_WIDTH)-1):0] S_RDATA;	// From altpcie_avl of altpcie_avl.v
   wire [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_RID;// From altpcie_avl of altpcie_avl.v
   wire			S_RLAST;		// From altpcie_avl of altpcie_avl.v
   wire			S_RREADY;		// From m_tb of m_tb.v
   wire [1:0]		S_RRESP;		// From altpcie_avl of altpcie_avl.v
   wire [((C_S_AXI_USER_WIDTH)-1):0] S_RUSER;	// From altpcie_avl of altpcie_avl.v
   wire			S_RVALID;		// From altpcie_avl of altpcie_avl.v
   wire [((C_S_AXI_DATA_WIDTH)-1):0] S_WDATA;	// From m_tb of m_tb.v
   wire			S_WLAST;		// From m_tb of m_tb.v
   wire			S_WREADY;		// From altpcie_avl of altpcie_avl.v
   wire [(((C_S_AXI_DATA_WIDTH/8))-1):0] S_WSTRB;// From m_tb of m_tb.v
   wire [((C_S_AXI_USER_WIDTH)-1):0] S_WUSER;	// From m_tb of m_tb.v
   wire			S_WVALID;		// From m_tb of m_tb.v
   wire [63:0]		m_Address;		// From m_tb of m_tb.v
   wire [5:0]		m_BurstCount;		// From m_tb of m_tb.v
   wire [15:0]		m_ByteEnable;		// From m_tb of m_tb.v
   wire			m_ChipSelect;		// From m_tb of m_tb.v
   wire			m_Read;			// From m_tb of m_tb.v
   wire [127:0]		m_ReadData;		// From altpcie_avl of altpcie_avl.v
   wire			m_ReadDataValid;	// From altpcie_avl of altpcie_avl.v
   wire			m_WaitRequest;		// From altpcie_avl of altpcie_avl.v
   wire			m_Write;		// From m_tb of m_tb.v
   wire [127:0]		m_WriteData;		// From m_tb of m_tb.v
   wire [31:0]		s_Address;		// From altpcie_avl of altpcie_avl.v
   wire [5:0]		s_BurstCount;		// From altpcie_avl of altpcie_avl.v
   wire [15:0]		s_ByteEnable;		// From altpcie_avl of altpcie_avl.v
   wire			s_Read;			// From altpcie_avl of altpcie_avl.v
   wire [127:0]		s_ReadData;		// From m_tb of m_tb.v
   wire			s_ReadDataValid;	// From m_tb of m_tb.v
   wire			s_WaitRequest;		// From m_tb of m_tb.v
   wire			s_Write;		// From altpcie_avl of altpcie_avl.v
   wire [127:0]		s_WriteData;		// From altpcie_avl of altpcie_avl.v
   // End of automatics
   
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
		 .tx_src_dsc		(tx_src_dsc),
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
		 .cfg_completer_id	(cfg_completer_id[15:0]),
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
		 .s_WaitRequest		(s_WaitRequest));

   m_tb #(/*AUTOINSTPARAM*/
	  // Parameters
	  .C_M_AXI_ADDR_WIDTH		(C_M_AXI_ADDR_WIDTH),
	  .C_M_AXI_DATA_WIDTH		(C_M_AXI_DATA_WIDTH),
	  .C_M_AXI_THREAD_ID_WIDTH	(C_M_AXI_THREAD_ID_WIDTH),
	  .C_M_AXI_USER_WIDTH		(C_M_AXI_USER_WIDTH),
	  .C_S_AXI_ADDR_WIDTH		(C_S_AXI_ADDR_WIDTH),
	  .C_S_AXI_DATA_WIDTH		(C_S_AXI_DATA_WIDTH),
	  .C_S_AXI_THREAD_ID_WIDTH	(C_S_AXI_THREAD_ID_WIDTH),
	  .C_S_AXI_USER_WIDTH		(C_S_AXI_USER_WIDTH))
   m_tb  (/*AUTOINST*/
	  // Outputs
	  .m_Address			(m_Address[63:0]),
	  .m_BurstCount			(m_BurstCount[5:0]),
	  .m_ByteEnable			(m_ByteEnable[15:0]),
	  .m_ChipSelect			(m_ChipSelect),
	  .m_Read			(m_Read),
	  .m_Write			(m_Write),
	  .m_WriteData			(m_WriteData[127:0]),
	  .s_ReadData			(s_ReadData[127:0]),
	  .s_ReadDataValid		(s_ReadDataValid),
	  .s_WaitRequest		(s_WaitRequest),
	  .M_AWREADY			(M_AWREADY),
	  .M_WREADY			(M_WREADY),
	  .M_BVALID			(M_BVALID),
	  .M_BRESP			(M_BRESP[1:0]),
	  .M_BID			(M_BID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
	  .M_BUSER			(M_BUSER[((C_M_AXI_USER_WIDTH)-1):0]),
	  .M_ARREADY			(M_ARREADY),
	  .M_RVALID			(M_RVALID),
	  .M_RDATA			(M_RDATA[((C_M_AXI_DATA_WIDTH)-1):0]),
	  .M_RRESP			(M_RRESP[1:0]),
	  .M_RLAST			(M_RLAST),
	  .M_RID			(M_RID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
	  .M_RUSER			(M_RUSER[((C_M_AXI_USER_WIDTH)-1):0]),
	  .S_AWVALID			(S_AWVALID),
	  .S_AWADDR			(S_AWADDR[((C_S_AXI_ADDR_WIDTH)-1):0]),
	  .S_AWPROT			(S_AWPROT[2:0]),
	  .S_AWREGION			(S_AWREGION[3:0]),
	  .S_AWLEN			(S_AWLEN[7:0]),
	  .S_AWSIZE			(S_AWSIZE[2:0]),
	  .S_AWBURST			(S_AWBURST[1:0]),
	  .S_AWLOCK			(S_AWLOCK),
	  .S_AWCACHE			(S_AWCACHE[3:0]),
	  .S_AWQOS			(S_AWQOS[3:0]),
	  .S_AWID			(S_AWID[((C_S_AXI_THREAD_ID_WIDTH)-1):0]),
	  .S_AWUSER			(S_AWUSER[((C_S_AXI_USER_WIDTH)-1):0]),
	  .S_WVALID			(S_WVALID),
	  .S_WDATA			(S_WDATA[((C_S_AXI_DATA_WIDTH)-1):0]),
	  .S_WSTRB			(S_WSTRB[(((C_S_AXI_DATA_WIDTH/8))-1):0]),
	  .S_WLAST			(S_WLAST),
	  .S_WUSER			(S_WUSER[((C_S_AXI_USER_WIDTH)-1):0]),
	  .S_BREADY			(S_BREADY),
	  .S_ARVALID			(S_ARVALID),
	  .S_ARADDR			(S_ARADDR[((C_S_AXI_ADDR_WIDTH)-1):0]),
	  .S_ARPROT			(S_ARPROT[2:0]),
	  .S_ARREGION			(S_ARREGION[3:0]),
	  .S_ARLEN			(S_ARLEN[7:0]),
	  .S_ARSIZE			(S_ARSIZE[2:0]),
	  .S_ARBURST			(S_ARBURST[1:0]),
	  .S_ARLOCK			(S_ARLOCK),
	  .S_ARCACHE			(S_ARCACHE[3:0]),
	  .S_ARQOS			(S_ARQOS[3:0]),
	  .S_ARID			(S_ARID[((C_S_AXI_THREAD_ID_WIDTH)-1):0]),
	  .S_ARUSER			(S_ARUSER[((C_S_AXI_USER_WIDTH)-1):0]),
	  .S_RREADY			(S_RREADY),
	  // Inputs
	  .user_clk			(user_clk),
	  .user_reset			(user_reset),
	  .m_ReadData			(m_ReadData[127:0]),
	  .m_ReadDataValid		(m_ReadDataValid),
	  .m_WaitRequest		(m_WaitRequest),
	  .s_Address			(s_Address[31:0]),
	  .s_BurstCount			(s_BurstCount[5:0]),
	  .s_ByteEnable			(s_ByteEnable[15:0]),
	  .s_Read			(s_Read),
	  .s_Write			(s_Write),
	  .s_WriteData			(s_WriteData[127:0]),
	  .M_AWVALID			(M_AWVALID),
	  .M_AWADDR			(M_AWADDR[((C_M_AXI_ADDR_WIDTH)-1):0]),
	  .M_AWPROT			(M_AWPROT[2:0]),
	  .M_AWREGION			(M_AWREGION[3:0]),
	  .M_AWLEN			(M_AWLEN[7:0]),
	  .M_AWSIZE			(M_AWSIZE[2:0]),
	  .M_AWBURST			(M_AWBURST[1:0]),
	  .M_AWLOCK			(M_AWLOCK),
	  .M_AWCACHE			(M_AWCACHE[3:0]),
	  .M_AWQOS			(M_AWQOS[3:0]),
	  .M_AWID			(M_AWID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
	  .M_AWUSER			(M_AWUSER[((C_M_AXI_USER_WIDTH)-1):0]),
	  .M_WVALID			(M_WVALID),
	  .M_WDATA			(M_WDATA[((C_M_AXI_DATA_WIDTH)-1):0]),
	  .M_WSTRB			(M_WSTRB[(((C_M_AXI_DATA_WIDTH/8))-1):0]),
	  .M_WLAST			(M_WLAST),
	  .M_WUSER			(M_WUSER[((C_M_AXI_USER_WIDTH)-1):0]),
	  .M_BREADY			(M_BREADY),
	  .M_ARVALID			(M_ARVALID),
	  .M_ARADDR			(M_ARADDR[((C_M_AXI_ADDR_WIDTH)-1):0]),
	  .M_ARPROT			(M_ARPROT[2:0]),
	  .M_ARREGION			(M_ARREGION[3:0]),
	  .M_ARLEN			(M_ARLEN[7:0]),
	  .M_ARSIZE			(M_ARSIZE[2:0]),
	  .M_ARBURST			(M_ARBURST[1:0]),
	  .M_ARLOCK			(M_ARLOCK),
	  .M_ARCACHE			(M_ARCACHE[3:0]),
	  .M_ARQOS			(M_ARQOS[3:0]),
	  .M_ARID			(M_ARID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
	  .M_ARUSER			(M_ARUSER[((C_M_AXI_USER_WIDTH)-1):0]),
	  .M_RREADY			(M_RREADY),
	  .S_AWREADY			(S_AWREADY),
	  .S_WREADY			(S_WREADY),
	  .S_BVALID			(S_BVALID),
	  .S_BRESP			(S_BRESP[1:0]),
	  .S_BID			(S_BID[((C_S_AXI_THREAD_ID_WIDTH)-1):0]),
	  .S_BUSER			(S_BUSER[((C_S_AXI_USER_WIDTH)-1):0]),
	  .S_ARREADY			(S_ARREADY),
	  .S_RVALID			(S_RVALID),
	  .S_RDATA			(S_RDATA[((C_S_AXI_DATA_WIDTH)-1):0]),
	  .S_RRESP			(S_RRESP[1:0]),
	  .S_RLAST			(S_RLAST),
	  .S_RID			(S_RID[((C_S_AXI_THREAD_ID_WIDTH)-1):0]),
	  .S_RUSER			(S_RUSER[((C_S_AXI_USER_WIDTH)-1):0]));
   
endmodule // PIO
