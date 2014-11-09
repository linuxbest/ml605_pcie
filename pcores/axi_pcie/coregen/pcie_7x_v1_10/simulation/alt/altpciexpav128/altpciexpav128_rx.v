// (C) 2001-2014 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on
module altpciexpav128_rx

# ( 

     parameter              CG_COMMON_CLOCK_MODE   = 0,     
     parameter              CB_P2A_PERF_PROFILE    = 3,
     parameter              CB_PCIE_MODE           = 0,
     parameter              CB_PCIE_RX_LITE        = 0,
     parameter              CB_RXM_DATA_WIDTH      = 128,
     parameter              port_type_hwtcl   = "Native endpoint",
    parameter AVALON_ADDR_WIDTH = 32           ,
    
   parameter C_M_AXI_ADDR_WIDTH      = 64,
   parameter C_M_AXI_DATA_WIDTH      = 128,
   parameter C_M_AXI_THREAD_ID_WIDTH = 3,
   parameter C_M_AXI_USER_WIDTH      = 3


)

  ( input          Clk_i,
    input 					Rstn_i,
    input 					RxmRstn_i,
    
   // Rx port interface to PCI Exp HIP
    output 					RxStReady_o,
    output 					RxStMask_o,
    input [127:0] 				RxStData_i,
    input [15:0] 				RxStBe_i,
    input [1:0] 				RxStEmpty_i,
    input 					RxStSop_i,
    input 					RxStEop_i,
    input 					RxStValid_i,
    input [7:0] 				RxStBarDec1_i,
    input [7:0] 				RxStBarDec2_i,
    
    // Tx module interface
      // buffer credit for accepting rx read
    input 					TxCpl_i,
    input [4:0] 				TxCplLen_i, // DQW
    input 					TxRespIdle_i, 
      // Rx pnding read fifo
    output [56:0] 				RxPndgRdFifoDat_o,
    output 					RxPndgRdFifoEmpty_o,
    input 					RxPndgRdFifoRdReq_i,
    
    output 					CplTagRelease_o,
    
    
/// RX Master Read Write Interface
   
    output 					RxmWrite_0_o,
    output [AVALON_ADDR_WIDTH-1:0] 		RxmAddress_0_o,
    output [CB_RXM_DATA_WIDTH-1:0] 		RxmWriteData_0_o,
    output [(CB_RXM_DATA_WIDTH/8)-1:0] 		RxmByteEnable_0_o,
    output [6:0] 				RxmBurstCount_0_o, 
    input 					RxmWaitRequest_0_i,
    output 					RxmRead_0_o,
   
    output 					RxmWrite_1_o,
    output [AVALON_ADDR_WIDTH-1:0] 		RxmAddress_1_o,
    output [CB_RXM_DATA_WIDTH-1:0] 		RxmWriteData_1_o,
    output [(CB_RXM_DATA_WIDTH/8)-1:0] 		RxmByteEnable_1_o,
    output [6:0] 				RxmBurstCount_1_o, 
    input 					RxmWaitRequest_1_i,
    output 					RxmRead_1_o,
   
    output 					RxmWrite_2_o,
    output [AVALON_ADDR_WIDTH-1:0] 		RxmAddress_2_o,
    output [CB_RXM_DATA_WIDTH-1:0] 		RxmWriteData_2_o,
    output [(CB_RXM_DATA_WIDTH/8)-1:0] 		RxmByteEnable_2_o, 
    output [6:0] 				RxmBurstCount_2_o, 
    input 					RxmWaitRequest_2_i,
    output 					RxmRead_2_o,
   
    output 					RxmWrite_3_o,
    output [AVALON_ADDR_WIDTH-1:0] 		RxmAddress_3_o,
    output [CB_RXM_DATA_WIDTH-1:0] 		RxmWriteData_3_o,
    output [(CB_RXM_DATA_WIDTH/8)-1:0] 		RxmByteEnable_3_o, 
    output [6:0] 				RxmBurstCount_3_o, 
    input 					RxmWaitRequest_3_i,
    output 					RxmRead_3_o,
   
    output 					RxmWrite_4_o,
    output [AVALON_ADDR_WIDTH-1:0] 		RxmAddress_4_o,
    output [(CB_RXM_DATA_WIDTH/8)-1:0] 		RxmByteEnable_4_o, 
    output [CB_RXM_DATA_WIDTH-1:0] 		RxmWriteData_4_o,
    output [6:0] 				RxmBurstCount_4_o, 
    input 					RxmWaitRequest_4_i,
    output 					RxmRead_4_o,
   
    output 					RxmWrite_5_o,
    output [AVALON_ADDR_WIDTH-1:0] 		RxmAddress_5_o,
    output [CB_RXM_DATA_WIDTH-1:0] 		RxmWriteData_5_o, 
    output [(CB_RXM_DATA_WIDTH/8)-1:0] 		RxmByteEnable_5_o, 
    output [6:0] 				RxmBurstCount_5_o, 
    input 					RxmWaitRequest_5_i,
    output 					RxmRead_5_o,
    
    output [130:0] 				RxRpFifoWrData_o, 
    output 					RxRpFifoWrReq_o, 
    output [127:0] 				TxReadData_o,
    output 					TxReadDataValid_o,
    
    output [127:0] 				rxm_read_data,
    output 					rxm_read_data_valid,
    
    /// paramter signals
    input [31:0] 				cb_p2a_avalon_addr_b0_i,
    input [31:0] 				cb_p2a_avalon_addr_b1_i,
    input [31:0] 				cb_p2a_avalon_addr_b2_i,
    input [31:0] 				cb_p2a_avalon_addr_b3_i,
    input [31:0] 				cb_p2a_avalon_addr_b4_i,
    input [31:0] 				cb_p2a_avalon_addr_b5_i,
    input [31:0] 				cb_p2a_avalon_addr_b6_i,
    input [223:0] 				k_bar_i,

    output 					M_AWVALID,
    output [((C_M_AXI_ADDR_WIDTH) - 1):0] 	M_AWADDR,
    output [2:0] 				M_AWPROT,
    output [3:0] 				M_AWREGION,
    output [7:0] 				M_AWLEN,
    output [2:0] 				M_AWSIZE,
    output [1:0] 				M_AWBURST,
    output 					M_AWLOCK,
    output [3:0] 				M_AWCACHE,
    output [3:0] 				M_AWQOS,
    output [((C_M_AXI_THREAD_ID_WIDTH) - 1):0] 	M_AWID,
    output [((C_M_AXI_USER_WIDTH) - 1):0] 	M_AWUSER,
    input 					M_AWREADY,
    output 					M_WVALID,
    output [((C_M_AXI_DATA_WIDTH) - 1):0] 	M_WDATA,
    output [(((C_M_AXI_DATA_WIDTH / 8)) - 1):0] M_WSTRB,
    output 					M_WLAST,
    output [((C_M_AXI_USER_WIDTH) - 1):0] 	M_WUSER,
    input 					M_WREADY,
    input 					M_BVALID,
    input [1:0] 				M_BRESP,
    input [((C_M_AXI_THREAD_ID_WIDTH) - 1):0] 	M_BID,
    input [((C_M_AXI_USER_WIDTH) - 1):0] 	M_BUSER,
    output 					M_BREADY,
   
    output 					M_ARVALID,
    output [((C_M_AXI_ADDR_WIDTH) - 1):0] 	M_ARADDR,
    output [2:0] 				M_ARPROT,
    output [3:0] 				M_ARREGION,
    output [7:0] 				M_ARLEN,
    output [2:0] 				M_ARSIZE,
    output [1:0] 				M_ARBURST,
    output 					M_ARLOCK,
    output [3:0] 				M_ARCACHE,
    output [3:0] 				M_ARQOS,
    output [((C_M_AXI_THREAD_ID_WIDTH) - 1):0] 	M_ARID,
    output [((C_M_AXI_USER_WIDTH) - 1):0] 	M_ARUSER,
    input 					M_ARREADY,
    input 					M_RVALID,
    input [((C_M_AXI_DATA_WIDTH) - 1):0] 	M_RDATA,
    input [1:0] 				M_RRESP,
    input 					M_RLAST,
    input [((C_M_AXI_THREAD_ID_WIDTH) - 1):0] 	M_RID,
    input [((C_M_AXI_USER_WIDTH) - 1):0] 	M_RUSER,
    output 					M_RREADY
  );
//define the clogb2 constant function
   function integer clogb2;
      input [31:0] depth;
      begin
         depth = depth - 1 ;
         for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
           depth = depth >> 1 ;       
      end
   endfunction // clogb2


localparam CB_RX_CD_BUFFER_DEPTH = (CB_P2A_PERF_PROFILE == 2)? 64 : 128;
localparam CB_RX_CPL_BUFFER_DEPTH =256;  // 8 tags , 512B
localparam RXCD_BUFF_ADDR_WIDTH     = clogb2(CB_RX_CD_BUFFER_DEPTH) ;   
localparam RX_CPL_BUFF_ADDR_WIDTH     =   clogb2(CB_RX_CPL_BUFFER_DEPTH) ;
wire   [7:0]      cdfifo_wrusedw;
wire              cdfifo_wrreq;
wire   [71:0]     cdfifo_datain;
wire   [3:0]      rxpndgrd_fifo_usedw;
wire              rxpndgrd_fifo_wrreq;
wire   [56:0]     rxpndgrd_fifo_datain;
wire              cdfifo_rdempty;
wire   [71:0]    cdfifo_dataout;
wire             rxpndgrd_fifo_wrfull;
wire             cdfifo_rdreq;

wire  [7:0]      cplram_wraddr;
wire   [7:0]     cplram_rdaddr;
wire  [129:0]     cplram_wrdat;
wire  [129:0]     cplram_data_out;          
wire             cpl_realease_tag;
wire  [5:0]      cpl_desc;
wire 		 cpl_eop;

wire 		 cpl_req;
wire 		 cplram_wr_ena;
wire 		 DevCsr_i;
reg [56:0]       rx_pending_read_reg;
reg              rx_read_in_progress_reg;
wire             rx_read_in_progress;
reg              rx_pending_valid_reg;


// instantiate the Rx control module on the PCIe clock domain


altpciexpav128_rx_cntrl

#(

   .CB_PCIE_MODE(CB_PCIE_MODE),
   .CB_RXM_DATA_WIDTH(CB_RXM_DATA_WIDTH),
   .CB_PCIE_RX_LITE  (CB_PCIE_RX_LITE),
   .port_type_hwtcl(port_type_hwtcl),
   .AVALON_ADDR_WIDTH (AVALON_ADDR_WIDTH),
   /*AUTOINSTPARAM*/
  // Parameters
  .C_M_AXI_ADDR_WIDTH			(C_M_AXI_ADDR_WIDTH),
  .C_M_AXI_DATA_WIDTH			(C_M_AXI_DATA_WIDTH),
  .C_M_AXI_THREAD_ID_WIDTH		(C_M_AXI_THREAD_ID_WIDTH),
  .C_M_AXI_USER_WIDTH			(C_M_AXI_USER_WIDTH))

rx_pcie_cntrl

 ( .Clk_i(Clk_i),
   .Rstn_i(Rstn_i),
  
    
    // Rx port interface to PCI Exp core
   .RxStReady_o(RxStReady_o),
   .RxStMask_o(RxStMask_o),
   .RxStData_i(RxStData_i),
   .RxStParity_i(64'h0),
   .RxStBe_i(RxStBe_i),
   .RxStEmpty_i(RxStEmpty_i),
   .RxStErr_i(8'h0),
   .RxStSop_i(RxStSop_i),
   .RxStEop_i(RxStEop_i),
   .RxStValid_i(RxStValid_i),
   .RxStBarDec1_i(RxStBarDec1_i),
   .RxStBarDec2_i(RxStBarDec2_i),
   
   /// RX Master Read Write Interface
   
   .RxmWrite_0_o(RxmWrite_0_o),
 .RxmAddress_0_o(RxmAddress_0_o),
 .RxmWriteData_0_o(RxmWriteData_0_o),
 .RxmByteEnable_0_o(RxmByteEnable_0_o),
 .RxmBurstCount_0_o(RxmBurstCount_0_o), 
 .RxmWaitRequest_0_i(RxmWaitRequest_0_i),
 .RxmRead_0_o(RxmRead_0_o),

 .RxmWrite_1_o(RxmWrite_1_o),
 .RxmAddress_1_o(RxmAddress_1_o),
 .RxmWriteData_1_o(RxmWriteData_1_o),
 .RxmByteEnable_1_o(RxmByteEnable_1_o),
 .RxmBurstCount_1_o(RxmBurstCount_1_o), 
 .RxmWaitRequest_1_i(RxmWaitRequest_1_i),
 .RxmRead_1_o(RxmRead_1_o),
 
 .RxmWrite_2_o(RxmWrite_2_o),
 .RxmAddress_2_o(RxmAddress_2_o),
 .RxmWriteData_2_o(RxmWriteData_2_o),
 .RxmByteEnable_2_o(RxmByteEnable_2_o),
 .RxmBurstCount_2_o(RxmBurstCount_2_o), 
 .RxmWaitRequest_2_i(RxmWaitRequest_2_i),
 .RxmRead_2_o(RxmRead_2_o),
 
 .RxmWrite_3_o(RxmWrite_3_o),
 .RxmAddress_3_o(RxmAddress_3_o),
 .RxmWriteData_3_o(RxmWriteData_3_o),
 .RxmByteEnable_3_o(RxmByteEnable_3_o),
 .RxmBurstCount_3_o(RxmBurstCount_3_o), 
 .RxmWaitRequest_3_i(RxmWaitRequest_3_i),
 .RxmRead_3_o(RxmRead_3_o),
 
 .RxmWrite_4_o(RxmWrite_4_o),
 .RxmAddress_4_o(RxmAddress_4_o),
 .RxmWriteData_4_o(RxmWriteData_4_o),
 .RxmByteEnable_4_o(RxmByteEnable_4_o),
 .RxmBurstCount_4_o(RxmBurstCount_4_o), 
 .RxmWaitRequest_4_i(RxmWaitRequest_4_i),
 .RxmRead_4_o(RxmRead_4_o),
 
 .RxmWrite_5_o(RxmWrite_5_o),
 .RxmAddress_5_o(RxmAddress_5_o),
 .RxmWriteData_5_o(RxmWriteData_5_o),
 .RxmByteEnable_5_o(RxmByteEnable_5_o),
 .RxmBurstCount_5_o(RxmBurstCount_5_o), 
 .RxmWaitRequest_5_i(RxmWaitRequest_5_i),
 .RxmRead_5_o(RxmRead_5_o),
  
 .RxRpFifoWrData_o(RxRpFifoWrData_o),      
 .RxRpFifoWrReq_o(RxRpFifoWrReq_o),  
   
   .CplReq_o(cpl_req),
   .CplDesc_o(cpl_desc),
    
    .PndngRdFifoEmpty_i(RxPndgRdFifoEmpty_o),
    .PndngRdFifoUsedW_i(rxpndgrd_fifo_usedw),
    .PndgRdFifoWrReq_o(rxpndgrd_fifo_wrreq),
    .PndgRdHeader_o(rxpndgrd_fifo_datain),
    
    .RxRdInProgress_i(rx_read_in_progress),
    


   // Completion data dual port ram interface
    .CplRamWrAddr_o(cplram_wraddr),
    .CplRamWrDat_o(cplram_wrdat),
    .CplRamWrEna_o(cplram_wr_ena),
    
    // Read respose module interface
    
    // Tx Completion interface
    .TxCpl_i(TxCpl_i),                                                        
    .TxCplLen_i(TxCplLen_i), // this is modified len (+1, +2, or unchanged)    
    .TxRespIdle_i(TxRespIdle_i),
    
      // cfg signals
    .DevCsr_i(DevCsr_i),    
        /// paramter signals  
    .k_bar_i(k_bar_i),                                    
    .cb_p2a_avalon_addr_b0_i(cb_p2a_avalon_addr_b0_i),    
    .cb_p2a_avalon_addr_b1_i(cb_p2a_avalon_addr_b1_i),    
    .cb_p2a_avalon_addr_b2_i(cb_p2a_avalon_addr_b2_i),    
    .cb_p2a_avalon_addr_b3_i(cb_p2a_avalon_addr_b3_i),    
    .cb_p2a_avalon_addr_b4_i(cb_p2a_avalon_addr_b4_i),    
    .cb_p2a_avalon_addr_b5_i(cb_p2a_avalon_addr_b5_i),    
    .cb_p2a_avalon_addr_b6_i(cb_p2a_avalon_addr_b6_i),    
                                                          

    /*AUTOINST*/
  // Outputs
  .rxm_read_data			(rxm_read_data[127:0]),
  .rxm_read_data_valid			(rxm_read_data_valid),
  .M_AWVALID				(M_AWVALID),
  .M_AWADDR				(M_AWADDR[((C_M_AXI_ADDR_WIDTH)-1):0]),
  .M_AWPROT				(M_AWPROT[2:0]),
  .M_AWREGION				(M_AWREGION[3:0]),
  .M_AWLEN				(M_AWLEN[7:0]),
  .M_AWSIZE				(M_AWSIZE[2:0]),
  .M_AWBURST				(M_AWBURST[1:0]),
  .M_AWLOCK				(M_AWLOCK),
  .M_AWCACHE				(M_AWCACHE[3:0]),
  .M_AWQOS				(M_AWQOS[3:0]),
  .M_AWID				(M_AWID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
  .M_AWUSER				(M_AWUSER[((C_M_AXI_USER_WIDTH)-1):0]),
  .M_WVALID				(M_WVALID),
  .M_WDATA				(M_WDATA[((C_M_AXI_DATA_WIDTH)-1):0]),
  .M_WSTRB				(M_WSTRB[(((C_M_AXI_DATA_WIDTH/8))-1):0]),
  .M_WLAST				(M_WLAST),
  .M_WUSER				(M_WUSER[((C_M_AXI_USER_WIDTH)-1):0]),
  .M_BREADY				(M_BREADY),
  .M_ARVALID				(M_ARVALID),
  .M_ARADDR				(M_ARADDR[((C_M_AXI_ADDR_WIDTH)-1):0]),
  .M_ARPROT				(M_ARPROT[2:0]),
  .M_ARREGION				(M_ARREGION[3:0]),
  .M_ARLEN				(M_ARLEN[7:0]),
  .M_ARSIZE				(M_ARSIZE[2:0]),
  .M_ARBURST				(M_ARBURST[1:0]),
  .M_ARLOCK				(M_ARLOCK),
  .M_ARCACHE				(M_ARCACHE[3:0]),
  .M_ARQOS				(M_ARQOS[3:0]),
  .M_ARID				(M_ARID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
  .M_ARUSER				(M_ARUSER[((C_M_AXI_USER_WIDTH)-1):0]),
  .M_RREADY				(M_RREADY),
  // Inputs
  .M_AWREADY				(M_AWREADY),
  .M_WREADY				(M_WREADY),
  .M_BVALID				(M_BVALID),
  .M_BRESP				(M_BRESP[1:0]),
  .M_BID				(M_BID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
  .M_BUSER				(M_BUSER[((C_M_AXI_USER_WIDTH)-1):0]),
  .M_ARREADY				(M_ARREADY),
  .M_RVALID				(M_RVALID),
  .M_RDATA				(M_RDATA[((C_M_AXI_DATA_WIDTH)-1):0]),
  .M_RRESP				(M_RRESP[1:0]),
  .M_RLAST				(M_RLAST),
  .M_RID				(M_RID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
  .M_RUSER				(M_RUSER[((C_M_AXI_USER_WIDTH)-1):0]));                          



generate if (CB_PCIE_RX_LITE == 0)
  begin: pndgtxrd_fifo  
  	
  	assign rx_read_in_progress = 1'b0;

     sync_fifo #(
		 // Parameters
		 .WIDTH			(57),
		 .DEPTH			(16),
		 .STYLE			("BRAM"),
		 .AFASSERT		(15),
		 .AEASSERT		(1),
		 .FWFT			(0),
		 .SUP_REWIND		(0),
		 .INIT_OUTREG		(0),
		 .ADDRW			(4))
     pndgtxrd_sc_fifo (
		       // Outputs
		       .dout		(RxPndgRdFifoDat_o),
		       .full		(),
		       .afull		(),
		       .empty		(),
		       .aempty		(),
		       .data_count	(rxpndgrd_fifo_usedw),
		       // Inputs
		       .clk		(Clk_i),
		       .rst_n		(Rstn_i),
		       .din		(rxpndgrd_fifo_datain),
		       .wr_en		(rxpndgrd_fifo_wrreq),
		       .rd_en		(RxPndgRdFifoRdReq_i),
		       .mark_addr	(0),
		       .clear_addr	(0),
		       .rewind		(0));

  end
   
else // generate
  begin
  	         always @ (posedge Clk_i or negedge Rstn_i) 
  	          begin       
  	           if(~Rstn_i)                                     
  	             rx_pending_read_reg <= 57'h0;                 
  	           else if(rxpndgrd_fifo_wrreq)                    
  	             rx_pending_read_reg <= rxpndgrd_fifo_datain;  
  	          end
  	                                                           
  	                                                           
  	        always @ (posedge Clk_i or negedge Rstn_i)         
  	          begin                                              
  	              if(~Rstn_i)                                     
  	                rx_pending_valid_reg <= 1'b0;                 
  	              else if(rxpndgrd_fifo_wrreq)                    
  	                rx_pending_valid_reg <= 1'b1;                 
  	              else if(RxPndgRdFifoRdReq_i)                    
  	                rx_pending_valid_reg <= 1'b0;                 
  	          end                                             
  	          
  	        always @ (posedge Clk_i or negedge Rstn_i)         
  	          begin                                              
  	              if(~Rstn_i)                                     
  	                rx_read_in_progress_reg <= 1'b0;                 
  	              else if(rxpndgrd_fifo_wrreq)                    
  	                rx_read_in_progress_reg <= 1'b1;                 
  	              else if(TxCpl_i)                    
  	                rx_read_in_progress_reg <= 1'b0;                 
  	          end                    
  	             
  	                                                           
  	        assign RxPndgRdFifoEmpty_o = ~rx_pending_valid_reg;
  	        assign RxPndgRdFifoDat_o   = rx_pending_read_reg;  
  	        assign rx_read_in_progress = rx_read_in_progress_reg;
  end
endgenerate
  
// instantiate the Rx Read respose module
altpciexpav128_rx_resp           
# ( 
     .CG_COMMON_CLOCK_MODE(CG_COMMON_CLOCK_MODE)
     
)
rxavl_resp

  
   ( .Clk_i(Clk_i),
     .AvlClk_i(Clk_i),
     .Rstn_i(Rstn_i),
     .RxmRstn_i(RxmRstn_i),
    
    // Interface to Transaction layer
     .CplReq_i(cpl_req),
     .CplDesc_i(cpl_desc), 
    
    /// interface to completion buffer
     .CplRdAddr_o(cplram_rdaddr),
     .CplBufData_i(cplram_data_out),
    
    // interface to tx control
     .TagRelease_o(CplTagRelease_o),
    
    // interface to Avalon slave
     //.TxsReadData_o(TxReadData_o),
     .TxsReadDataValid_o(TxReadDataValid_o)
  );
  
  
  
  //// instantiate the Rx Completion data ram
generate if(CB_PCIE_MODE == 0)
begin : cpl_ram
   generic_tpram   #(
		     // Parameters
		     .aw		(RX_CPL_BUFF_ADDR_WIDTH),
		     .dw		(130))
   cpl_tpram        (
		     // Outputs
		     .do_a		(),
		     .do_b		(cplram_data_out),
		     // Inputs
		     .clk_a		(Clk_i),
		     .rst_a		(0),
		     .ce_a		(1),
		     .we_a		(cplram_wr_ena),
		     .oe_a		(0),
		     .addr_a		(cplram_wraddr),
		     .di_a		(cplram_wrdat),

		     .clk_b		(Clk_i),
		     .rst_b		(0),
		     .ce_b		(1),
		     .we_b		(0),
		     .oe_b		(1),
		     .addr_b		(cplram_rdaddr),
		     .di_b		(0));
 
assign TxReadData_o = cplram_data_out[127:0];
assign cpl_eop = cplram_data_out[129];
				
end
  else
    begin
      assign TxReadData_o = 64'h0;
      assign cpl_eop = 1'b0;
    end
    
endgenerate

endmodule
