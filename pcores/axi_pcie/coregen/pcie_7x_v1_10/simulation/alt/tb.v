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
// 	internal version of output port    : "*_i"
// 	device pins                        : "*_pin"
// 	ports                              : - Names begin with Uppercase
// Code:
module tb (/*AUTOARG*/
   // Outputs
   AvlClk_i, Rstn_i, RxStData_i, RxStBe_i, RxStEmpty_i, RxStErr_i,
   RxStSop_i, RxStEop_i, RxStValid_i, RxStBarDec1_i, RxStBarDec2_i,
   TxStReady_i, TxAdapterFifoEmpty_i, TxCredPDataLimit_i,
   TxCredNpDataLimit_i, TxCredCplDataLimit_i, TxCredHipCons_i,
   TxCredInfinit_i, TxCredPHdrLimit_i, TxCredNpHdrLimit_i,
   TxCredCplHdrLimit_i, ko_cpl_spc_header, ko_cpl_spc_data,
   CfgCtlWr_i, CfgAddr_i, CfgCtl_i, MsiAck_i, IntxAck_i, TxsClk_i,
   TxsRstn_i, TxsChipSelect_i, TxsRead_i, TxsWrite_i, TxsWriteData_i,
   TxsBurstCount_i, TxsAddress_i, TxsByteEnable_i, RxmWaitRequest_0_i,
   RxmReadData_0_i, RxmReadDataValid_0_i, RxmWaitRequest_1_i,
   RxmReadData_1_i, RxmReadDataValid_1_i, RxmWaitRequest_2_i,
   RxmReadData_2_i, RxmReadDataValid_2_i, RxmWaitRequest_3_i,
   RxmReadData_3_i, RxmReadDataValid_3_i, RxmWaitRequest_4_i,
   RxmReadData_4_i, RxmReadDataValid_4_i, RxmWaitRequest_5_i,
   RxmReadData_5_i, RxmReadDataValid_5_i, RxmIrq_i, CraClk_i,
   CraRstn_i, CraChipSelect_i, CraRead, CraWrite, CraWriteData_i,
   CraAddress_i, CraByteEnable_i, RxIntStatus_i, pld_clk_inuse,
   ltssm_state, current_speed, lane_act, s_axis_tx_tdata,
   s_axis_tx_tkeep, s_axis_tx_tlast, s_axis_tx_tvalid, tx_src_dsc,
   m_axis_rx_tready, cfg_turnoff_ok,
   // Inputs
   RxStReady_o, RxStMask_o, TxStData_o, TxStSop_o, TxStEop_o,
   TxStEmpty_o, TxStValid_o, CplPending_o, MsiReq_o, MsiTc_o,
   MsiNum_o, IntxReq_o, TxsReadDataValid_o, TxsReadData_o,
   TxsWaitRequest_o, RxmWrite_0_o, RxmAddress_0_o, RxmWriteData_0_o,
   RxmByteEnable_0_o, RxmBurstCount_0_o, RxmRead_0_o, RxmWrite_1_o,
   RxmAddress_1_o, RxmWriteData_1_o, RxmByteEnable_1_o,
   RxmBurstCount_1_o, RxmRead_1_o, RxmWrite_2_o, RxmAddress_2_o,
   RxmWriteData_2_o, RxmByteEnable_2_o, RxmBurstCount_2_o,
   RxmRead_2_o, RxmWrite_3_o, RxmAddress_3_o, RxmWriteData_3_o,
   RxmByteEnable_3_o, RxmBurstCount_3_o, RxmRead_3_o, RxmWrite_4_o,
   RxmAddress_4_o, RxmWriteData_4_o, RxmByteEnable_4_o,
   RxmBurstCount_4_o, RxmRead_4_o, RxmWrite_5_o, RxmAddress_5_o,
   RxmWriteData_5_o, RxmByteEnable_5_o, RxmBurstCount_5_o,
   RxmRead_5_o, CraReadData_o, CraWaitRequest_o, CraIrq_o, MsiIntfc_o,
   MsiControl_o, MsixIntfc_o, tx_cons_cred_sel, user_clk, user_reset,
   user_lnk_up, s_axis_tx_tready, m_axis_rx_tdata, m_axis_rx_tkeep,
   m_axis_rx_tlast, m_axis_rx_tvalid, m_axis_rx_tuser, cfg_to_turnoff,
   cfg_completer_id
   );
 
   parameter CB_RXM_DATA_WIDTH      = 64;
   parameter AVALON_ADDR_WIDTH      = 32;
   parameter CG_RXM_IRQ_NUM         = 16;   
   parameter CG_AVALON_S_ADDR_WIDTH = 24;
   
   /*AUTOINOUTCOMP("altpciexpav128_app")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output		AvlClk_i;
   output		Rstn_i;
   output [127:0]	RxStData_i;
   output [15:0]	RxStBe_i;
   output [1:0]		RxStEmpty_i;
   output		RxStErr_i;
   output		RxStSop_i;
   output		RxStEop_i;
   output		RxStValid_i;
   output [7:0]		RxStBarDec1_i;
   output [7:0]		RxStBarDec2_i;
   output		TxStReady_i;
   output		TxAdapterFifoEmpty_i;
   output [11:0]	TxCredPDataLimit_i;
   output [11:0]	TxCredNpDataLimit_i;
   output [11:0]	TxCredCplDataLimit_i;
   output [5:0]		TxCredHipCons_i;
   output [5:0]		TxCredInfinit_i;
   output [7:0]		TxCredPHdrLimit_i;
   output [7:0]		TxCredNpHdrLimit_i;
   output [7:0]		TxCredCplHdrLimit_i;
   output [7:0]		ko_cpl_spc_header;
   output [11:0]	ko_cpl_spc_data;
   output		CfgCtlWr_i;
   output [3:0]		CfgAddr_i;
   output [31:0]	CfgCtl_i;
   output		MsiAck_i;
   output		IntxAck_i;
   output		TxsClk_i;
   output		TxsRstn_i;
   output		TxsChipSelect_i;
   output		TxsRead_i;
   output		TxsWrite_i;
   output [127:0]	TxsWriteData_i;
   output [5:0]		TxsBurstCount_i;
   output [CG_AVALON_S_ADDR_WIDTH-1:0] TxsAddress_i;
   output [15:0]	TxsByteEnable_i;
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
   output		CraClk_i;
   output		CraRstn_i;
   output		CraChipSelect_i;
   output		CraRead;
   output		CraWrite;
   output [31:0]	CraWriteData_i;
   output [13:2]	CraAddress_i;
   output [3:0]		CraByteEnable_i;
   output [3:0]		RxIntStatus_i;
   output		pld_clk_inuse;
   output [4:0]		ltssm_state;
   output [1:0]		current_speed;
   output [3:0]		lane_act;
   input		RxStReady_o;
   input		RxStMask_o;
   input [127:0]	TxStData_o;
   input		TxStSop_o;
   input		TxStEop_o;
   input [1:0]		TxStEmpty_o;
   input		TxStValid_o;
   input		CplPending_o;
   input		MsiReq_o;
   input [2:0]		MsiTc_o;
   input [4:0]		MsiNum_o;
   input		IntxReq_o;
   input		TxsReadDataValid_o;
   input [127:0]	TxsReadData_o;
   input		TxsWaitRequest_o;
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
   input [31:0]		CraReadData_o;
   input		CraWaitRequest_o;
   input		CraIrq_o;
   input [81:0]		MsiIntfc_o;
   input [15:0]		MsiControl_o;
   input [15:0]		MsixIntfc_o;
   input		tx_cons_cred_sel;
   // End of automatics

   input 		user_clk;
   input 		user_reset;
   input 		user_lnk_up;
   
   input 		s_axis_tx_tready;
   output [127:0] 	s_axis_tx_tdata;
   output [15:0] 	s_axis_tx_tkeep;
   output 		s_axis_tx_tlast;
   output 		s_axis_tx_tvalid;
   output 		tx_src_dsc;
   
   
   input [127:0] 	m_axis_rx_tdata;
   input [15:0] 	m_axis_rx_tkeep;
   input 		m_axis_rx_tlast;
   input 		m_axis_rx_tvalid;
   output 		m_axis_rx_tready;
   input [21:0] 	m_axis_rx_tuser;
   
   input 		cfg_to_turnoff;
   output 		cfg_turnoff_ok;
   input [15:0] 	cfg_completer_id;


   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			RxmReadDataValid_0_i;
   reg [CB_RXM_DATA_WIDTH-1:0] RxmReadData_0_i;
   reg [CG_AVALON_S_ADDR_WIDTH-1:0] TxsAddress_i;
   reg [5:0]		TxsBurstCount_i;
   reg [15:0]		TxsByteEnable_i;
   reg			TxsChipSelect_i;
   reg			TxsRead_i;
   reg [127:0]		TxsWriteData_i;
   reg			TxsWrite_i;
   reg [1:0]		current_speed;
   reg [3:0]		lane_act;
   reg [4:0]		ltssm_state;
   // End of automatics
   
   assign AvlClk_i      = user_clk;
   assign Rstn_i        = ~user_reset;
   assign RxStBarDec1_i = 8'b0000_0001;
   assign RxStBarDec2_i = 8'b0000_0000;

   assign CfgAddr_i = 0;
   assign CfgCtl_i  = 0;
   assign CfgCtlWr_i= 0;

   assign CraWriteData_i = 0;
   assign CraAddress_i   = 0;
   assign CraByteEnable_i= 0;
   assign CraChipSelect_i= 0;
   assign CraClk_i       = user_clk;
   assign CraRead        = 0;
   assign CraRstn_i      = ~user_reset;
   assign CraWriteData_i = 0;
   assign CraWrite       = 0;

   assign IntxAck_i      = 0;
   assign MsiAck_i       = 0;
   assign RxIntStatus_i  = 0;

   assign RxmIrq_i       = 0;
   
   assign RxmReadData_1_i = 0;
   assign RxmReadData_2_i = 0;
   assign RxmReadData_3_i = 0;
   assign RxmReadData_4_i = 0;
   assign RxmReadData_5_i = 0;

   assign RxmReadDataValid_1_i = 0;
   assign RxmReadDataValid_2_i = 0;
   assign RxmReadDataValid_3_i = 0;
   assign RxmReadDataValid_4_i = 0;
   assign RxmReadDataValid_5_i = 0;   

   assign RxmWaitRequest_0_i = 0;
   assign RxmWaitRequest_1_i = 0;
   assign RxmWaitRequest_2_i = 0;
   assign RxmWaitRequest_3_i = 0;
   assign RxmWaitRequest_4_i = 0;
   assign RxmWaitRequest_5_i = 0;
   
   assign TxCredCplDataLimit_i = ~0;
   assign TxCredCplHdrLimit_i  = ~0;
   assign TxCredHipCons_i      = ~0;
   assign TxCredInfinit_i      = ~0;
   assign TxCredNpDataLimit_i  = ~0;
   assign TxCredNpHdrLimit_i   = ~0;
   assign TxCredPDataLimit_i   = ~0;
   assign TxCredPHdrLimit_i    = ~0;

   assign TxsClk_i        = user_clk;
   assign TxsRstn_i       = ~user_reset;
   
   assign ko_cpl_spc_data   = 0;
   assign ko_cpl_spc_header = 0;
   assign pld_clk_inuse     = 0;

   assign RxStData_i        = m_axis_rx_tdata;
   assign RxStEop_i         = m_axis_rx_tuser[21];
   assign RxStSop_i         = m_axis_rx_tuser[14];
   assign RxStValid_i       = m_axis_rx_tvalid;   
   //assign RxStSop_i         = 1'b0;
   assign RxStErr_i         = 1'b0;
   assign m_axis_rx_tready  = RxStReady_o;

   // xilinx axi
   // m_axis_rx_tuser[21:17]
   // 5'b10011 = EOF at AXI byte 3  (DWORD 0) m_axis_rx_tdata[31:24]
   // 5'b10111 = EOF at AXI byte 7  (DWORD 1) m_axis_rx_tdata[63:56]
   // 5'b11011 = EOF at AXI byte 11 (DWORD 2) m_axis_rx_tdata[95:88]
   // 5'b11111 = EOF at AXI byte 15 (DWORD 3) m_axis_rx_tdata[127:120]
   // 5'b00011 = No EOF present

   // altera
   // value 1, rx_st_data[63:0] holds valid data but
   //          rx_st_data[127:64] does not hold valid data.
   assign RxStEmpty_i       = m_axis_rx_tuser[21:17] == 5'b10011 || m_axis_rx_tuser[21:17] == 5'b10111;
   assign RxStBe_i          = m_axis_rx_tuser[21:17] == 5'b10011 ? 16'h00_0F : 16'hFF_FF;

   assign TxAdapterFifoEmpty_i = 1'b0;

   //When tx_st_eop<n> is asserted and tx_st_empty<n>
   //has value 1, tx_st_data[63:0] holds valid data but
   //tx_st_data[127:64] does not hold valid data.
   //
   //When tx_st_eop<n> is asserted and tx_st_empty<n>
   //has value 0, tx_st_data[127:0] holds valid data.

   wire dw3_mem_rd;
   assign dw3_mem_rd        = TxStData_o[30:24] == 0;

   assign s_axis_tx_tdata   = TxStData_o;
   assign s_axis_tx_tkeep   = TxStEop_o & TxStValid_o & TxStEmpty_o[0]         ? 16'h00_FF :
                              TxStEop_o & TxStValid_o & TxStSop_o & dw3_mem_rd ? 16'h0F_FF : 16'hFF_FF;
   assign s_axis_tx_tvalid  = TxStValid_o;
   assign s_axis_tx_tlast   = TxStEop_o;
   assign tx_src_dsc        = 1'b0;
   assign TxStReady_i       = s_axis_tx_tready;

   assign cfg_turnoff_ok    = 1'b0;

   always @(posedge user_clk)
     begin
	if (RxStValid_i && RxStReady_o && m_axis_rx_tuser[14:10] == 5'b11000)
	  begin
	     $stop;
	  end
     end

   reg [CB_RXM_DATA_WIDTH-1:0] rxm_data [0:1023];
   wire [11:0] 		       rxm_addr;
   reg [11:0] 		       rxm_raddr;
   always @(posedge user_clk)
     begin
	if (RxmWrite_0_o)
	  begin
	     rxm_data[rxm_addr] <= RxmWriteData_0_o;
	  end
	rxm_raddr            <= rxm_addr;
	RxmReadData_0_i      <= rxm_data[rxm_raddr];
	RxmReadDataValid_0_i <= RxmRead_0_o;
     end
   assign rxm_addr = RxmAddress_0_o;

   reg master_ready;
   always @(posedge user_clk)
     begin
	if (RxmWrite_0_o && RxmAddress_0_o[15:0] == 16'h70 && RxmWriteData_0_o[127:96] == 32'hAA55_55AA)
	  begin
	     master_ready <= #1 1'b1;
	  end
     end // always @ (posedge user_clk)

   initial begin
      master_ready = 1'b0;

      TxsAddress_i          = 0;
      TxsBurstCount_i       = 0;
      TxsChipSelect_i       = 0;
      TxsWrite_i            = 0;
      TxsRead_i             = 0;
      TxsWriteData_i        = 0;
      TxsByteEnable_i       = 0;

      while (master_ready == 0)
	@(posedge user_clk);

      TxsAddress_i          = 32'h8000_0000;
      TxsBurstCount_i       = 1;
      TxsChipSelect_i       = 1'b1;
      TxsWrite_i            = 1'b1;
      TxsRead_i             = 1'b0;
      TxsWriteData_i[31:0]  = 32'h0001_0203;
      TxsWriteData_i[63:32] = 32'h0405_0607;      
      TxsWriteData_i[95:64] = 32'h0809_1011;
      TxsWriteData_i[127:96]= 32'h1213_1415;
      TxsByteEnable_i       = 16'hFF_FF;

      //while (TxsWaitRequest_o == 1)
      //  @(posedge user_clk);

      TxsRead_i             = 1'b0;      
      TxsWrite_i            = 1'b0;
      @(posedge user_clk);
      @(posedge user_clk);
      @(posedge user_clk);
      
      TxsRead_i             = 1'b1;
      TxsBurstCount_i       = 32+64;
      TxsByteEnable_i       = 16'hFF_FF;
      while (TxsWaitRequest_o == 1)
	@(posedge user_clk)
      
      TxsRead_i             = 1'b0;      
      TxsWrite_i            = 1'b0;
      @(posedge user_clk);

   end
   
endmodule
// 
// tb.v ends here
