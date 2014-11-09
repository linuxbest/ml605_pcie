// tb.v --- 
// 
// Filename: tb.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Mon Oct 27 20:31:56 2014 (-0700)
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
// 	internal version of input port    : "*"
// 	device pins                        : "*_pin"
// 	ports                              : - Names begin with Uppercase
// Code:
module m_tb (/*AUTOARG*/
   // Outputs
   M_AWREADY, M_WREADY, M_BVALID, M_BRESP, M_BID, M_BUSER, M_ARREADY,
   M_RVALID, M_RDATA, M_RRESP, M_RLAST, M_RID, M_RUSER, m_Address,
   m_BurstCount, m_ByteEnable, m_ChipSelect, m_Read, m_Write,
   m_WriteData, s_ReadData, s_ReadDataValid, s_WaitRequest,
   // Inputs
   M_AWVALID, M_AWADDR, M_AWPROT, M_AWREGION, M_AWLEN, M_AWSIZE,
   M_AWBURST, M_AWLOCK, M_AWCACHE, M_AWQOS, M_AWID, M_AWUSER,
   M_WVALID, M_WDATA, M_WSTRB, M_WLAST, M_WUSER, M_BREADY, M_ARVALID,
   M_ARADDR, M_ARPROT, M_ARREGION, M_ARLEN, M_ARSIZE, M_ARBURST,
   M_ARLOCK, M_ARCACHE, M_ARQOS, M_ARID, M_ARUSER, M_RREADY, user_clk,
   user_reset, m_ReadData, m_ReadDataValid, m_WaitRequest, s_Address,
   s_BurstCount, s_ByteEnable, s_Read, s_Write, s_WriteData
   );
   parameter C_M_AXI_ADDR_WIDTH      = 64;
   parameter C_M_AXI_DATA_WIDTH      = 128;
   parameter C_M_AXI_THREAD_ID_WIDTH = 3;
   parameter C_M_AXI_USER_WIDTH      = 3;
   
   input user_clk;
   input user_reset;

   output [63:0] m_Address;		// To altpcie_stub of altpcie_stub.v
   output [5:0]  m_BurstCount;		// To altpcie_stub of altpcie_stub.v
   output [15:0] m_ByteEnable;		// To altpcie_stub of altpcie_stub.v
   output 	 m_ChipSelect;		// To altpcie_stub of altpcie_stub.v
   output 	 m_Read;			// To altpcie_stub of altpcie_stub.v
   output 	 m_Write;		// To altpcie_stub of altpcie_stub.v
   output [127:0] m_WriteData;		// To altpcie_stub of altpcie_stub.v
   output [127:0] s_ReadData;		// To altpcie_stub of altpcie_stub.v
   output 	  s_ReadDataValid;	// To altpcie_stub of altpcie_stub.v
   output 	  s_WaitRequest;		// To altpcie_stub of altpcie_stub.v
   input [127:0]  m_ReadData;		// From altpcie_stub of altpcie_stub.v
   input 	  m_ReadDataValid;	// From altpcie_stub of altpcie_stub.v
   input 	  m_WaitRequest;		// From altpcie_stub of altpcie_stub.v
   input [31:0]   s_Address;		// From altpcie_stub of altpcie_stub.v
   input [5:0] 	  s_BurstCount;		// From altpcie_stub of altpcie_stub.v
   input [15:0]   s_ByteEnable;		// From altpcie_stub of altpcie_stub.v
   input 	  s_Read;			// From altpcie_stub of altpcie_stub.v
   input 	  s_Write;		// From altpcie_stub of altpcie_stub.v
   input [127:0]  s_WriteData;		// From altpcie_stub of altpcie_stub.v

   /*AUTOINOUTCOMP("altpciexpav128_app", "^M_")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output		M_AWREADY;
   output		M_WREADY;
   output		M_BVALID;
   output [1:0]		M_BRESP;
   output [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_BID;
   output [((C_M_AXI_USER_WIDTH)-1):0] M_BUSER;
   output		M_ARREADY;
   output		M_RVALID;
   output [((C_M_AXI_DATA_WIDTH)-1):0] M_RDATA;
   output [1:0]		M_RRESP;
   output		M_RLAST;
   output [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_RID;
   output [((C_M_AXI_USER_WIDTH)-1):0] M_RUSER;
   input		M_AWVALID;
   input [((C_M_AXI_ADDR_WIDTH)-1):0] M_AWADDR;
   input [2:0]		M_AWPROT;
   input [3:0]		M_AWREGION;
   input [7:0]		M_AWLEN;
   input [2:0]		M_AWSIZE;
   input [1:0]		M_AWBURST;
   input		M_AWLOCK;
   input [3:0]		M_AWCACHE;
   input [3:0]		M_AWQOS;
   input [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_AWID;
   input [((C_M_AXI_USER_WIDTH)-1):0] M_AWUSER;
   input		M_WVALID;
   input [((C_M_AXI_DATA_WIDTH)-1):0] M_WDATA;
   input [(((C_M_AXI_DATA_WIDTH/8))-1):0] M_WSTRB;
   input		M_WLAST;
   input [((C_M_AXI_USER_WIDTH)-1):0] M_WUSER;
   input		M_BREADY;
   input		M_ARVALID;
   input [((C_M_AXI_ADDR_WIDTH)-1):0] M_ARADDR;
   input [2:0]		M_ARPROT;
   input [3:0]		M_ARREGION;
   input [7:0]		M_ARLEN;
   input [2:0]		M_ARSIZE;
   input [1:0]		M_ARBURST;
   input		M_ARLOCK;
   input [3:0]		M_ARCACHE;
   input [3:0]		M_ARQOS;
   input [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_ARID;
   input [((C_M_AXI_USER_WIDTH)-1):0] M_ARUSER;
   input		M_RREADY;
   // End of automatics
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			M_BVALID;
   reg [((C_M_AXI_DATA_WIDTH)-1):0] M_RDATA;
   reg			M_RLAST;
   reg			M_RVALID;
   reg [63:0]		m_Address;
   reg [5:0]		m_BurstCount;
   reg [15:0]		m_ByteEnable;
   reg			m_ChipSelect;
   reg			m_Read;
   reg			m_Write;
   reg [127:0]		m_WriteData;
   reg [127:0]		s_ReadData;
   reg			s_ReadDataValid;
   reg			s_WaitRequest;
   // End of automatics

   // SLAVE 
   reg [127:0] 		rxm_data [0:1023];
   wire [11:0] 		rxm_addr;
   reg [11:0] 		rxm_raddr;
   reg 			master_ready = 1'b0;   
   always @(posedge user_clk)
     begin
	if (M_WVALID)
	  begin
	     rxm_data[rxm_addr] <= M_WDATA;
	     master_ready       <= M_AWADDR[15:0] == 16'h70 && M_WDATA[127:96] == 32'hAA55_55AA;
	  end
	rxm_raddr    <= M_ARADDR;
	M_RDATA      <= rxm_data[rxm_raddr];
	M_RVALID     <= s_Read;
	M_RLAST      <= s_Read;
     end
   assign rxm_addr      = M_AWADDR;
   
   assign M_ARREADY     = 1'b1;
   assign M_AWREADY     = 1'b1;
   assign M_WREADY      = 1'b1;
   
   assign M_BID         = 0;
   assign M_BRESP       = 0;
   assign M_BUSER       = 0;
   assign M_RID         = 0;
   assign M_RRESP       = 0;
   assign M_RUSER       = 0;
   
   // MASTER
   integer i, j, cnt = 65536;
   initial begin
      master_ready = 1'b0;

      m_Address          = 0;
      m_BurstCount       = 0;
      m_ChipSelect       = 0;
      m_Write            = 0;
      m_Read             = 0;
      m_WriteData        = 0;
      m_ByteEnable       = 0;

      m_Read             = 1'b0;
      m_Write            = 1'b0;
      
      while (master_ready == 0)
	@(posedge user_clk);
	for (j = 0; j < cnt; j = j + 1) begin    
      m_Address          = 32'h8000_0000;
      m_ByteEnable       = 16'hFF_FF;
      m_BurstCount       = 32;
      m_Read             = 1'b1;
      m_ChipSelect       = 1'b1;
      while (m_WaitRequest == 1)
	@(posedge user_clk)

      m_Read             = 1'b0;      
      m_Write            = 1'b0;
      
      @(posedge user_clk);
      @(posedge user_clk);
      @(posedge user_clk);
 
      m_Write            = 1'b1;
      m_Read             = 1'b0;

      for (i = 0; i < m_BurstCount; ) begin
	 m_WriteData[31:0]   = (i*4)+0;
	 m_WriteData[63:32]  = (i*4)+1;
	 m_WriteData[95:64]  = (i*4)+2;
	 m_WriteData[127:96] = (i*4)+3;
	 m_ByteEnable        = 16'hFF_FF;
	 if (m_WaitRequest == 0) begin
	    i = i + 1;
	 end
         @(posedge user_clk);
      end // for (i = 0; i < 64; i = i + 1)

      m_Write            = 1'b0;
      @(posedge user_clk);

      end
   end
   
endmodule
// Local Variables:
// verilog-library-directories:("altpciexpav128")
// verilog-library-files:(".""sata_phy")
// verilog-library-extensions:(".v" ".h")
// End:
// 
// tb.v ends here
