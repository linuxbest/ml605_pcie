// altpcie_stub.v --- 
// 
// Filename: altpcie_stub.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sat Nov  1 19:28:23 2014 (-0700)
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
module altpcie_stub (/*AUTOARG*/
   // Outputs
   TxStReady_i, TxsClk_i, TxsRstn_i, TxsChipSelect_i, TxsRead_i,
   TxsWrite_i, TxsWriteData_i, TxsBurstCount_i, TxsAddress_i,
   TxsByteEnable_i, RxmWaitRequest_0_i, RxmReadData_0_i,
   RxmReadDataValid_0_i, RxmWaitRequest_1_i, RxmReadData_1_i,
   RxmReadDataValid_1_i, RxmWaitRequest_2_i, RxmReadData_2_i,
   RxmReadDataValid_2_i, RxmWaitRequest_3_i, RxmReadData_3_i,
   RxmReadDataValid_3_i, RxmWaitRequest_4_i, RxmReadData_4_i,
   RxmReadDataValid_4_i, RxmWaitRequest_5_i, RxmReadData_5_i,
   RxmReadDataValid_5_i, RxmIrq_i, CraClk_i, CraRstn_i,
   CraChipSelect_i, CraRead, CraWrite, CraWriteData_i, CraAddress_i,
   CraByteEnable_i, CfgCtlWr_i, CfgAddr_i, CfgCtl_i, MsiAck_i,
   TxCredPDataLimit_i, TxCredNpDataLimit_i, TxCredCplDataLimit_i,
   TxCredHipCons_i, TxCredInfinit_i, TxCredPHdrLimit_i,
   TxCredNpHdrLimit_i, TxCredCplHdrLimit_i, RxStData_i, RxStBe_i,
   RxStEmpty_i, RxStErr_i, RxStSop_i, RxStEop_i, RxStValid_i,
   RxStBarDec1_i, RxStBarDec2_i, AvlClk_i, Rstn_i, IntxAck_i,
   RxIntStatus_i, current_speed, ko_cpl_spc_data, ko_cpl_spc_header,
   lane_act, ltssm_state, pld_clk_inuse, TxAdapterFifoEmpty_i, fc_sel,
   s_axis_tx_tdata, s_axis_tx_tkeep, s_axis_tx_tlast,
   s_axis_tx_tvalid, tx_src_dsc, cfg_turnoff_ok, m_axis_rx_tready,
   m_WaitRequest, m_ReadData, m_ReadDataValid, s_Read, s_Write,
   s_BurstCount, s_ByteEnable, s_Address, s_WriteData,
   // Inputs
   TxStData_o, TxStSop_o, TxStEop_o, TxStEmpty_o, TxStValid_o,
   TxsReadDataValid_o, TxsReadData_o, TxsWaitRequest_o, RxmWrite_0_o,
   RxmAddress_0_o, RxmWriteData_0_o, RxmByteEnable_0_o,
   RxmBurstCount_0_o, RxmRead_0_o, RxmWrite_1_o, RxmAddress_1_o,
   RxmWriteData_1_o, RxmByteEnable_1_o, RxmBurstCount_1_o,
   RxmRead_1_o, RxmWrite_2_o, RxmAddress_2_o, RxmWriteData_2_o,
   RxmByteEnable_2_o, RxmBurstCount_2_o, RxmRead_2_o, RxmWrite_3_o,
   RxmAddress_3_o, RxmWriteData_3_o, RxmByteEnable_3_o,
   RxmBurstCount_3_o, RxmRead_3_o, RxmWrite_4_o, RxmAddress_4_o,
   RxmWriteData_4_o, RxmByteEnable_4_o, RxmBurstCount_4_o,
   RxmRead_4_o, RxmWrite_5_o, RxmAddress_5_o, RxmWriteData_5_o,
   RxmByteEnable_5_o, RxmBurstCount_5_o, RxmRead_5_o, CraReadData_o,
   CraWaitRequest_o, CraIrq_o, MsiReq_o, MsiTc_o, MsiNum_o,
   MsiIntfc_o, MsiControl_o, MsixIntfc_o, RxStReady_o, RxStMask_o,
   IntxReq_o, tx_cons_cred_sel, CplPending_o, user_clk, user_reset,
   user_lnk_up, fc_cpld, fc_cplh, fc_npd, fc_nph, fc_pd, fc_ph,
   s_axis_tx_tready, m_axis_rx_tdata, m_axis_rx_tkeep,
   m_axis_rx_tlast, m_axis_rx_tvalid, m_axis_rx_tuser, m_ChipSelect,
   m_Read, m_Write, m_BurstCount, m_ByteEnable, m_Address,
   m_WriteData, s_WaitRequest, s_ReadData, s_ReadDataValid
   );
   parameter CB_RXM_DATA_WIDTH      = 64;
   parameter AVALON_ADDR_WIDTH      = 32;
   parameter CG_RXM_IRQ_NUM         = 16;   
   parameter CG_AVALON_S_ADDR_WIDTH = 24;

   parameter C_DATA_WIDTH = 128;
   parameter KEEP_WIDTH = 16;
   
   output AvlClk_i;
   output Rstn_i;
   /*AUTOINOUTCOMP("altpciexpav128_app", "^RxSt")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output [127:0]	RxStData_i;
   output [15:0]	RxStBe_i;
   output [1:0]		RxStEmpty_i;
   output		RxStErr_i;
   output		RxStSop_i;
   output		RxStEop_i;
   output		RxStValid_i;
   output [7:0]		RxStBarDec1_i;
   output [7:0]		RxStBarDec2_i;
   input		RxStReady_o;
   input		RxStMask_o;
   // End of automatics

   /*AUTOINOUTCOMP("altpciexpav128_app", "^TxCr")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output [11:0]	TxCredPDataLimit_i;
   output [11:0]	TxCredNpDataLimit_i;
   output [11:0]	TxCredCplDataLimit_i;
   output [5:0]		TxCredHipCons_i;
   output [5:0]		TxCredInfinit_i;
   output [7:0]		TxCredPHdrLimit_i;
   output [7:0]		TxCredNpHdrLimit_i;
   output [7:0]		TxCredCplHdrLimit_i;
   // End of automatics

   /*AUTOINOUTCOMP("altpciexpav128_app", "^Msi")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output		MsiAck_i;
   input		MsiReq_o;
   input [2:0]		MsiTc_o;
   input [4:0]		MsiNum_o;
   input [81:0]		MsiIntfc_o;
   input [15:0]		MsiControl_o;
   input [15:0]		MsixIntfc_o;
   // End of automatics
   
   /*AUTOINOUTCOMP("altpciexpav128_app", "^Cfg")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output		CfgCtlWr_i;
   output [3:0]		CfgAddr_i;
   output [31:0]	CfgCtl_i;
   // End of automatics

   /*AUTOINOUTCOMP("altpciexpav128_app", "^Cra")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output		CraClk_i;
   output		CraRstn_i;
   output		CraChipSelect_i;
   output		CraRead;
   output		CraWrite;
   output [31:0]	CraWriteData_i;
   output [13:2]	CraAddress_i;
   output [3:0]		CraByteEnable_i;
   input [31:0]		CraReadData_o;
   input		CraWaitRequest_o;
   input		CraIrq_o;
   // End of automatics
   
   /*AUTOINOUTCOMP("altpciexpav128_app", "^Rxm")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output		RxmWaitRequest_0_i;
   output [CB_RXM_DATA_WIDTH-1:0] RxmReadData_0_i;
   output		RxmReadDataValid_0_i;
   output		RxmWaitRequest_1_i;
   output [CB_RXM_DATA_WIDTH-1:0] RxmReadData_1_i;
   output		RxmReadDataValid_1_i;
   output		RxmWaitRequest_2_i;
   output [CB_RXM_DATA_WIDTH-1:0] RxmReadData_2_i;
   output		RxmReadDataValid_2_i;
   output		RxmWaitRequest_3_i;
   output [CB_RXM_DATA_WIDTH-1:0] RxmReadData_3_i;
   output		RxmReadDataValid_3_i;
   output		RxmWaitRequest_4_i;
   output [CB_RXM_DATA_WIDTH-1:0] RxmReadData_4_i;
   output		RxmReadDataValid_4_i;
   output		RxmWaitRequest_5_i;
   output [CB_RXM_DATA_WIDTH-1:0] RxmReadData_5_i;
   output		RxmReadDataValid_5_i;
   output [CG_RXM_IRQ_NUM-1:0] RxmIrq_i;
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

   /*AUTOINOUTCOMP("altpciexpav128_app", "^Txs")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output		TxStReady_i;
   output		TxsClk_i;
   output		TxsRstn_i;
   output		TxsChipSelect_i;
   output		TxsRead_i;
   output		TxsWrite_i;
   output [127:0]	TxsWriteData_i;
   output [5:0]		TxsBurstCount_i;
   output [CG_AVALON_S_ADDR_WIDTH-1:0] TxsAddress_i;
   output [15:0]	TxsByteEnable_i;
   input [127:0]	TxStData_o;
   input		TxStSop_o;
   input		TxStEop_o;
   input [1:0]		TxStEmpty_o;
   input		TxStValid_o;
   input		TxsReadDataValid_o;
   input [127:0]	TxsReadData_o;
   input		TxsWaitRequest_o;
   // End of automatics

   output 		IntxAck_i;
   input 		IntxReq_o;

   output [3:0] 	RxIntStatus_i;
   output [1:0] 	current_speed;
   output [11:0] 	ko_cpl_spc_data;
   output [7:0] 	ko_cpl_spc_header;
   output [3:0] 	lane_act;
   output [4:0] 	ltssm_state;
   output 		pld_clk_inuse;
   output 		TxAdapterFifoEmpty_i;
   
   input 		tx_cons_cred_sel;
   input 		CplPending_o;

   input 		user_clk;
   input 		user_reset;
   input 		user_lnk_up;
   
   /*AUTOREG*/

   assign AvlClk_i  = user_clk;
   assign CraClk_i  = user_clk;
   assign TxsClk_i  = user_clk;
   
   assign Rstn_i    = ~user_reset;
   assign CraRstn_i = ~user_reset;
   assign TxsRstn_i = ~user_reset;
   
   assign CfgAddr_i = 0;
   assign CfgCtl_i  = 0;
   assign CfgCtlWr_i= 0;

   assign CraAddress_i    = 0;
   assign CraByteEnable_i = 0;
   assign CraChipSelect_i = 0;
   assign CraWriteData_i  = 0;
   assign CraRead         = 0;
   assign CraWrite        = 0;
   
   assign TxAdapterFifoEmpty_i = 0;

   input [11:0] 	fc_cpld;
   input [7:0] 		fc_cplh;
   input [11:0] 	fc_npd;
   input [7:0] 		fc_nph;
   input [11:0] 	fc_pd;
   input [7:0] 		fc_ph;
   output [2:0] 	fc_sel;
   assign fc_sel = 3'b001;
   
   assign TxCredCplDataLimit_i = ~0;
   assign TxCredCplHdrLimit_i  = ~0;
   assign TxCredHipCons_i      = ~0;
   assign TxCredInfinit_i      = ~0;
   assign TxCredNpDataLimit_i  = ~0;
   assign TxCredNpHdrLimit_i   = ~0;
   assign TxCredPDataLimit_i   = ~0;
   assign TxCredPHdrLimit_i    = ~0;

   assign IntxAck_i = 0;
   assign MsiAck_i  = 0;

   assign RxmIrq_i      = 0;
   assign current_speed = 0;
   assign RxIntStatus_i = 0;
   
   assign ko_cpl_spc_data   = 0;
   assign ko_cpl_spc_header = 0;

   assign lane_act      = 0;
   assign ltssm_state   = 0;
   assign pld_clk_inuse = 0;

   /* PCIE TX */
   input                         s_axis_tx_tready;
   output [C_DATA_WIDTH-1:0] 	 s_axis_tx_tdata;
   output [KEEP_WIDTH-1:0] 	 s_axis_tx_tkeep;
   output                        s_axis_tx_tlast;
   output                        s_axis_tx_tvalid;
   output                        tx_src_dsc;
   output 			 cfg_turnoff_ok;
   
   assign s_axis_tx_tdata = TxStData_o;
   assign s_axis_tx_tkeep =  TxStEop_o & TxStValid_o & TxStEmpty_o[0] ? 16'h00_FF :
			      TxStEop_o & TxStValid_o & TxStSop_o & TxStData_o[30:24] == 0 ? 16'h0F_FF : 
			      16'hFF_FF;
   assign s_axis_tx_tvalid  = TxStValid_o;
   assign s_axis_tx_tlast   = TxStEop_o;
   assign tx_src_dsc        = 1'b0;
   assign TxStReady_i       = s_axis_tx_tready;
   assign cfg_turnoff_ok    = 1'b0;
   
   /* PCIE RX */
   input [C_DATA_WIDTH-1:0] 	 m_axis_rx_tdata;
   input [KEEP_WIDTH-1:0] 	 m_axis_rx_tkeep;
   input                         m_axis_rx_tlast;
   input                         m_axis_rx_tvalid;
   output                        m_axis_rx_tready;
   input [21:0] 		 m_axis_rx_tuser;
   
   assign RxStData_i        = m_axis_rx_tdata;
   assign RxStEop_i         = m_axis_rx_tuser[21];
   assign RxStSop_i         = m_axis_rx_tuser[14];
   assign RxStValid_i       = m_axis_rx_tvalid;   
   assign RxStErr_i         = 1'b0;
   assign m_axis_rx_tready  = RxStReady_o;

   assign RxStBarDec1_i     = 8'h1;
   assign RxStBarDec2_i     = 8'h0;
   assign RxStEmpty_i       = m_axis_rx_tuser[21:17] == 5'b10011 || m_axis_rx_tuser[21:17] == 5'b10111;
   assign RxStBe_i          = m_axis_rx_tuser[21:17] == 5'b10011 ? 16'h00_0F : 16'hFF_FF;
   
   /* Avalon Master */
   output 			 m_WaitRequest;
   output [127:0] 		 m_ReadData;
   output 			 m_ReadDataValid;
   input 			 m_ChipSelect;
   input 			 m_Read;
   input 			 m_Write;
   input [5:0] 			 m_BurstCount;
   input [15:0] 		 m_ByteEnable;
   input [63:0] 		 m_Address;
   input [127:0] 		 m_WriteData;
   assign m_WaitRequest   = TxsWaitRequest_o;
   assign m_ReadData      = TxsReadData_o;
   assign m_ReadDataValid = TxsReadDataValid_o;

   assign TxsChipSelect_i = m_ChipSelect;
   assign TxsRead_i       = m_Read;
   assign TxsWrite_i      = m_Write;
   assign TxsWriteData_i  = m_WriteData;
   assign TxsBurstCount_i = m_BurstCount;
   assign TxsAddress_i    = m_Address;
   assign TxsByteEnable_i = m_ByteEnable;

   /* Avalon Slave */
   input 			 s_WaitRequest;
   input [127:0] 		 s_ReadData;
   input 			 s_ReadDataValid;

   output			 s_Read;
   output			 s_Write;
   output [5:0] 		 s_BurstCount;
   output [15:0] 		 s_ByteEnable;
   output [31:0] 		 s_Address;
   output [127:0] 		 s_WriteData;
   assign RxmWaitRequest_0_i   = s_WaitRequest;
   assign RxmReadData_0_i      = s_ReadData;
   assign RxmReadDataValid_0_i = s_ReadDataValid;
   assign s_Read               = RxmRead_0_o;
   assign s_Write              = RxmWrite_0_o;
   assign s_BurstCount         = RxmBurstCount_0_o;
   assign s_ByteEnable         = RxmByteEnable_0_o;
   assign s_Address            = RxmAddress_0_o;
   assign s_WriteData          = RxmWriteData_0_o;

   assign RxmReadDataValid_1_i = 0;
   assign RxmReadDataValid_2_i = 0;
   assign RxmReadDataValid_3_i = 0;
   assign RxmReadDataValid_4_i = 0;
   assign RxmReadDataValid_5_i = 0;
   assign RxmReadData_1_i      = 0;
   assign RxmReadData_2_i      = 0;
   assign RxmReadData_3_i      = 0;
   assign RxmReadData_4_i      = 0;
   assign RxmReadData_5_i      = 0;   
   assign RxmWaitRequest_1_i   = 0;
   assign RxmWaitRequest_2_i   = 0;
   assign RxmWaitRequest_3_i   = 0;
   assign RxmWaitRequest_4_i   = 0;
   assign RxmWaitRequest_5_i   = 0;
endmodule // altpcie_stub
// Local Variables:
// verilog-library-directories:("altpciexpav128")
// verilog-library-files:(".""sata_phy")
// verilog-library-extensions:(".v" ".h")
// End:
// 
// altpcie_stub.v ends here
