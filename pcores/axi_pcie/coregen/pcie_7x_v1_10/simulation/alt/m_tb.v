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
   S_AWVALID, S_AWADDR, S_AWPROT, S_AWREGION, S_AWLEN, S_AWSIZE,
   S_AWBURST, S_AWLOCK, S_AWCACHE, S_AWQOS, S_AWID, S_AWUSER,
   S_WVALID, S_WDATA, S_WSTRB, S_WLAST, S_WUSER, S_BREADY, S_ARVALID,
   S_ARADDR, S_ARPROT, S_ARREGION, S_ARLEN, S_ARSIZE, S_ARBURST,
   S_ARLOCK, S_ARCACHE, S_ARQOS, S_ARID, S_ARUSER, S_RREADY,
   M_AWREADY, M_WREADY, M_BVALID, M_BRESP, M_BID, M_BUSER, M_ARREADY,
   M_RVALID, M_RDATA, M_RRESP, M_RLAST, M_RID, M_RUSER, m_Address,
   m_BurstCount, m_ByteEnable, m_ChipSelect, m_Read, m_Write,
   m_WriteData, s_ReadData, s_ReadDataValid, s_WaitRequest,
   // Inputs
   S_AWREADY, S_WREADY, S_BVALID, S_BRESP, S_BID, S_BUSER, S_ARREADY,
   S_RVALID, S_RDATA, S_RRESP, S_RLAST, S_RID, S_RUSER, M_AWVALID,
   M_AWADDR, M_AWPROT, M_AWREGION, M_AWLEN, M_AWSIZE, M_AWBURST,
   M_AWLOCK, M_AWCACHE, M_AWQOS, M_AWID, M_AWUSER, M_WVALID, M_WDATA,
   M_WSTRB, M_WLAST, M_WUSER, M_BREADY, M_ARVALID, M_ARADDR, M_ARPROT,
   M_ARREGION, M_ARLEN, M_ARSIZE, M_ARBURST, M_ARLOCK, M_ARCACHE,
   M_ARQOS, M_ARID, M_ARUSER, M_RREADY, user_clk, user_reset,
   m_ReadData, m_ReadDataValid, m_WaitRequest, s_Address,
   s_BurstCount, s_ByteEnable, s_Read, s_Write, s_WriteData
   );
   parameter C_M_AXI_ADDR_WIDTH      = 64;
   parameter C_M_AXI_DATA_WIDTH      = 128;
   parameter C_M_AXI_THREAD_ID_WIDTH = 3;
   parameter C_M_AXI_USER_WIDTH      = 3;
   parameter C_S_AXI_ADDR_WIDTH      = 64;
   parameter C_S_AXI_DATA_WIDTH      = 128;
   parameter C_S_AXI_THREAD_ID_WIDTH = 3;
   parameter C_S_AXI_USER_WIDTH      = 3;
   
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

   /*AUTOINOUTCOMP("altpciexpav128_app", "^S_")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output		S_AWVALID;
   output [((C_S_AXI_ADDR_WIDTH)-1):0] S_AWADDR;
   output [2:0]		S_AWPROT;
   output [3:0]		S_AWREGION;
   output [7:0]		S_AWLEN;
   output [2:0]		S_AWSIZE;
   output [1:0]		S_AWBURST;
   output		S_AWLOCK;
   output [3:0]		S_AWCACHE;
   output [3:0]		S_AWQOS;
   output [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_AWID;
   output [((C_S_AXI_USER_WIDTH)-1):0] S_AWUSER;
   output		S_WVALID;
   output [((C_S_AXI_DATA_WIDTH)-1):0] S_WDATA;
   output [(((C_S_AXI_DATA_WIDTH/8))-1):0] S_WSTRB;
   output		S_WLAST;
   output [((C_S_AXI_USER_WIDTH)-1):0] S_WUSER;
   output		S_BREADY;
   output		S_ARVALID;
   output [((C_S_AXI_ADDR_WIDTH)-1):0] S_ARADDR;
   output [2:0]		S_ARPROT;
   output [3:0]		S_ARREGION;
   output [7:0]		S_ARLEN;
   output [2:0]		S_ARSIZE;
   output [1:0]		S_ARBURST;
   output		S_ARLOCK;
   output [3:0]		S_ARCACHE;
   output [3:0]		S_ARQOS;
   output [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_ARID;
   output [((C_S_AXI_USER_WIDTH)-1):0] S_ARUSER;
   output		S_RREADY;
   input		S_AWREADY;
   input		S_WREADY;
   input		S_BVALID;
   input [1:0]		S_BRESP;
   input [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_BID;
   input [((C_S_AXI_USER_WIDTH)-1):0] S_BUSER;
   input		S_ARREADY;
   input		S_RVALID;
   input [((C_S_AXI_DATA_WIDTH)-1):0] S_RDATA;
   input [1:0]		S_RRESP;
   input		S_RLAST;
   input [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_RID;
   input [((C_S_AXI_USER_WIDTH)-1):0] S_RUSER;
   // End of automatics
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			M_BVALID;
   reg [((C_M_AXI_DATA_WIDTH)-1):0] M_RDATA;
   reg			M_RLAST;
   reg			M_RVALID;
   reg [((C_S_AXI_ADDR_WIDTH)-1):0] S_ARADDR;
   reg [1:0]		S_ARBURST;
   reg [3:0]		S_ARCACHE;
   reg [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_ARID;
   reg [7:0]		S_ARLEN;
   reg			S_ARLOCK;
   reg [2:0]		S_ARPROT;
   reg [3:0]		S_ARQOS;
   reg [3:0]		S_ARREGION;
   reg [2:0]		S_ARSIZE;
   reg [((C_S_AXI_USER_WIDTH)-1):0] S_ARUSER;
   reg			S_ARVALID;
   reg [((C_S_AXI_ADDR_WIDTH)-1):0] S_AWADDR;
   reg [1:0]		S_AWBURST;
   reg [3:0]		S_AWCACHE;
   reg [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_AWID;
   reg [7:0]		S_AWLEN;
   reg			S_AWLOCK;
   reg [2:0]		S_AWPROT;
   reg [3:0]		S_AWQOS;
   reg [3:0]		S_AWREGION;
   reg [2:0]		S_AWSIZE;
   reg [((C_S_AXI_USER_WIDTH)-1):0] S_AWUSER;
   reg			S_AWVALID;
   reg			S_BREADY;
   reg			S_RREADY;
   reg [((C_S_AXI_DATA_WIDTH)-1):0] S_WDATA;
   reg			S_WLAST;
   reg [(((C_S_AXI_DATA_WIDTH/8))-1):0] S_WSTRB;
   reg [((C_S_AXI_USER_WIDTH)-1):0] S_WUSER;
   reg			S_WVALID;
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
	M_RVALID     <= M_ARVALID;
	M_RLAST      <= M_ARVALID;
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
   integer ir_delay = 3;
   integer iw_delay = 3;
   integer i, j, m, ir, iw, cnt = 128;
   initial begin
      S_ARVALID          = 0;
      S_ARADDR           = 0;
      S_ARLEN            = 0;
      S_ARSIZE           = 3'b100;
      
      S_ARPROT           = 0;
      S_ARREGION         = 0;
      S_ARBURST          = 2'b10;
      S_ARLOCK           = 0;
      S_ARCACHE          = 0;
      S_ARQOS            = 0;
      S_ARID             = 0;
      S_ARUSER           = 0;

      S_RREADY           = 1;
      
      while (master_ready == 0)
	@(posedge user_clk);

      for (j = 0; j < cnt; j = j + 1) begin    
	 S_ARADDR      = 32'h8000_0000;
	 S_ARLEN       = 31;
	 S_ARVALID     = 1;
         S_ARID        = j;
	 
	 @(posedge user_clk);
	 while (S_ARREADY == 0)
	   @(posedge user_clk);

	 S_ARVALID = 0;
	 for (ir = 0; ir < ir_delay; ir = ir + 1) begin
	     @(posedge user_clk);
         end
      end
      $stop;
   end // initial begin

   initial begin
      S_AWVALID          = 0;
      S_AWADDR           = 0;
      S_AWLEN            = 0;
      S_AWSIZE           = 3'b100;
      
      S_AWPROT           = 0;
      S_AWREGION         = 0;
      S_AWBURST          = 2'b10;
      S_AWLOCK           = 0;
      S_AWCACHE          = 0;
      S_AWQOS            = 0;
      S_AWID             = 0;
      S_AWUSER           = 0;
      
      S_BREADY           = 1;

      S_WVALID           = 0;
      S_WDATA            = 0;
      S_WSTRB            = 0;
      S_WLAST            = 0;
      S_WUSER            = 0;
      
      while (master_ready == 0)
	@(posedge user_clk);

      for (m = 0; m < cnt; m = m + 1) begin    
	 S_AWADDR      = 32'h8000_0000;
	 S_AWLEN       = 31;
	 S_AWVALID     = 1;
	 @(posedge user_clk);
	 while (S_AWREADY == 0)
	   @(posedge user_clk);
	 S_AWVALID = 0;
	 
	 for (i = 0; i < S_AWLEN + 1; i = i + 1) begin
	    S_WDATA[31:0]  = (i*4)+0;
	    S_WDATA[63:32] = (i*4)+1;      
	    S_WDATA[95:64] = (i*4)+2;
	    S_WDATA[127:96]= (i*4)+3;
	    S_WSTRB        = 16'hFF_FF;
	    S_WVALID       = 1'b1;
	    @(posedge user_clk);	    	    
	    while (S_WREADY == 0)
	      @(posedge user_clk);	    
	 end
	 S_WVALID  = 0;

	 for (iw = 0; iw < iw_delay; iw = iw + 1) begin
	     @(posedge user_clk);
         end
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
