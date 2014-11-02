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
   m_Address, m_BurstCount, m_ByteEnable, m_ChipSelect, m_Read,
   m_Write, m_WriteData, s_ReadData, s_ReadDataValid, s_WaitRequest,
   // Inputs
   user_clk, user_reset, m_ReadData, m_ReadDataValid, m_WaitRequest,
   s_Address, s_BurstCount, s_ByteEnable, s_Read, s_Write,
   s_WriteData
   );
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
   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [63:0]		m_Address;
   reg [5:0]		m_BurstCount;
   reg [15:0]		m_ByteEnable;
   reg			m_ChipSelect;
   reg			m_Read;
   reg			m_Write;
   reg [127:0]		m_WriteData;
   reg [127:0]		s_ReadData;
   reg			s_ReadDataValid;
   // End of automatics
   
   reg [127:0] rxm_data [0:1023];
   wire [11:0] 		       rxm_addr;
   reg [11:0] 		       rxm_raddr;
   always @(posedge user_clk)
     begin
	if (s_Write)
	  begin
	     rxm_data[rxm_addr] <= s_WriteData;
	  end
	rxm_raddr       <= rxm_addr;
	s_ReadData      <= rxm_data[rxm_raddr];
	s_ReadDataValid <= s_Read;
     end
   assign rxm_addr      = s_Address;
   assign s_WaitRequest = 1'b0;

   reg master_ready;
   always @(posedge user_clk)
     begin
	if (s_Write && s_Address[15:0] == 16'h70 && s_WriteData[127:96] == 32'hAA55_55AA)
	  begin
	     master_ready <= #1 1'b1;
	  end
     end // always @ (posedge user_clk)

   initial begin
      master_ready = 1'b0;

      m_Address          = 0;
      m_BurstCount       = 0;
      //s_ChipSelect       = 0;
      m_Write            = 0;
      m_Read             = 0;
      m_WriteData        = 0;
      m_ByteEnable       = 0;

      while (master_ready == 0)
	@(posedge user_clk);

      m_Address          = 32'h8000_0000;
      m_BurstCount       = 1;
      m_ChipSelect       = 1'b1;
      m_Write            = 1'b1;
      m_Read             = 1'b0;
      m_WriteData[31:0]  = 32'h0001_0203;
      m_WriteData[63:32] = 32'h0405_0607;      
      m_WriteData[95:64] = 32'h0809_1011;
      m_WriteData[127:96]= 32'h1213_1415;
      m_ByteEnable       = 16'hFF_FF;

      while (m_WaitRequest == 1)
        @(posedge user_clk);

      m_Read             = 1'b0;      
      m_Write            = 1'b0;
      @(posedge user_clk);
      @(posedge user_clk);
      @(posedge user_clk);
      
      m_Read             = 1'b1;
      m_BurstCount       = 32+64;
      m_ByteEnable       = 16'hFF_FF;
      while (m_WaitRequest == 1)
	@(posedge user_clk)
      
      m_Read             = 1'b0;      
      m_Write            = 1'b0;
      @(posedge user_clk);

   end
   
endmodule
// 
// tb.v ends here
