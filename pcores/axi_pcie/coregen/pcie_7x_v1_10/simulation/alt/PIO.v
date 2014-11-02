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

  input [15:0]                  cfg_completer_id

);

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
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
		 .KEEP_WIDTH		(KEEP_WIDTH))
   altpcie_avl  (/*AUTOINST*/
		 // Outputs
		 .s_axis_tx_tdata	(s_axis_tx_tdata[C_DATA_WIDTH-1:0]),
		 .s_axis_tx_tkeep	(s_axis_tx_tkeep[KEEP_WIDTH-1:0]),
		 .s_axis_tx_tlast	(s_axis_tx_tlast),
		 .s_axis_tx_tvalid	(s_axis_tx_tvalid),
		 .tx_src_dsc		(tx_src_dsc),
		 .m_axis_rx_tready	(m_axis_rx_tready),
		 .cfg_turnoff_ok	(cfg_turnoff_ok),
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

   m_tb #(/*AUTOINSTPARAM*/)
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
	  .s_WriteData			(s_WriteData[127:0]));
   
endmodule // PIO
