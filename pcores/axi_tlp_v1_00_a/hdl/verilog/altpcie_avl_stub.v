// altpcie_avl_stub.v --- 
// 
// Filename: altpcie_avl_stub.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sat Nov 15 13:11:32 2014 (-0800)
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
module altpcie_avl_stub (/*AUTOARG*/
   // Outputs
   m_ChipSelect, m_Read, m_Write, m_BurstCount, m_ByteEnable,
   m_Address, m_WriteData, s_WaitRequest, s_ReadData, s_ReadDataValid,
   // Inputs
   m_axis_rx_tready, m_WaitRequest, m_ReadData, m_ReadDataValid,
   s_Read, s_Write, s_BurstCount, s_ByteEnable, s_Address,
   s_WriteData
   );
   
   output		m_ChipSelect;
   output		m_Read;
   output		m_Write;
   output [5:0]		m_BurstCount;
   output [15:0]	m_ByteEnable;
   output [63:0]	m_Address;
   output [127:0]	m_WriteData;
   input		m_axis_rx_tready;
   input		m_WaitRequest;
   input [127:0]	m_ReadData;
   input		m_ReadDataValid;

   output		s_WaitRequest;
   output [127:0]	s_ReadData;
   output		s_ReadDataValid;
   input		s_Read;
   input		s_Write;
   input [5:0]		s_BurstCount;
   input [15:0]		s_ByteEnable;
   input [31:0]		s_Address;
   input [127:0]	s_WriteData;

   /*AUTOREG*/

   assign m_Address    = 0;
   assign m_BurstCount = 0;
   assign m_ByteEnable = 0;
   assign m_ChipSelect = 0;
   assign m_Read       = 0;
   assign m_Write      = 0;
   assign m_WriteData  = 0;
   assign s_ReadData   = 0;
   assign s_ReadDataValid = 0;
   assign s_WaitRequest   = 0;
endmodule
// 
// altpcie_avl_stub.v ends here
