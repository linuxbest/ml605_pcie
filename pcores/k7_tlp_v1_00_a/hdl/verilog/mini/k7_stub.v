// k7_stub.v --- 
// 
// Filename: k7_stub.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sat Nov 22 20:48:43 2014 (-0800)
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
module k7_stub (/*AUTOARG*/
   // Outputs
   s_axis_tx_tuser, s_axis_tx_tdata, s_axis_tx_tkeep, s_axis_tx_tlast,
   s_axis_tx_tvalid, m_axis_rx_tready, fc_sel, cfg_turnoff_ok, REFCLK,
   sys_rst_n,
   // Inputs
   s_axis_tx_tready, m_axis_rx_tdata, m_axis_rx_tkeep,
   m_axis_rx_tlast, m_axis_rx_tvalid, m_axis_rx_tuser, fc_cpld,
   fc_cplh, fc_npd, fc_nph, fc_pd, fc_ph, cfg_to_turnoff,
   cfg_completer_id, refclk_p, refclk_n, pci_exp_rstn, mmcm_lock,
   tx_buf_av, user_clk, user_link_up, user_reset
   );
   parameter C_INSTANCE        = "k7_tlp_0";
   parameter C_FAMILY          = "kintex7";
   parameter C_NO_OF_LANES     = 8;
   parameter C_MAX_LINK_SPEED  = 0;
   parameter C_DEVICE_ID       = 16'h0106;
   parameter C_VENDOR_ID       = 16'h10EE;
   parameter C_CLASS_CODE      = 24'h058000;
   parameter C_REV_ID          = 8'h10;
   parameter C_SUBSYSTEM_ID    = 16'h0000;
   parameter C_SUBSYSTEM_VENDOR_ID = 16'h0000;
   parameter C_PCIE_CAP_SLOT_IMPLEMENTED = 0;

   parameter PCI_EXP_EP_DSN_1  = 32'h12345678;
   parameter PCI_EXP_EP_DSN_2  = 32'h87654321;

   parameter PIPE_SIM_MODE     = "TRUE";
   parameter PL_FAST_TRAIN     = "TRUE"; // Simulation Speedup
   parameter PCIE_EXT_CLK      = "TRUE";  // Use External Clocking Module
   parameter C_DATA_WIDTH      = 128; // RX/TX interface data width
   parameter KEEP_WIDTH        = C_DATA_WIDTH / 8;// TSTRB width


   
   input refclk_p;
   input refclk_n;
   output REFCLK;
   
   input pci_exp_rstn;
   output sys_rst_n;

   input  mmcm_lock;
   input [5:0] tx_buf_av;
   input       user_clk;
   input       user_link_up;
   input       user_reset;
   
   /*AUTOINOUTCOMP("k7_tlp", "^cfg_")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output		cfg_turnoff_ok;
   input		cfg_to_turnoff;
   input [15:0]		cfg_completer_id;
   // End of automatics

   /*AUTOINOUTCOMP("k7_tlp", "^fc_")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output [2:0]		fc_sel;
   input [11:0]		fc_cpld;
   input [7:0]		fc_cplh;
   input [11:0]		fc_npd;
   input [7:0]		fc_nph;
   input [11:0]		fc_pd;
   input [7:0]		fc_ph;
   // End of automatics

   /*AUTOINOUTCOMP("k7_tlp", "^m_axis_")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output		m_axis_rx_tready;
   input [C_DATA_WIDTH-1:0] m_axis_rx_tdata;
   input [KEEP_WIDTH-1:0] m_axis_rx_tkeep;
   input		m_axis_rx_tlast;
   input		m_axis_rx_tvalid;
   input [21:0]		m_axis_rx_tuser;
   // End of automatics
   /*AUTOINOUTCOMP("k7_tlp", "^s_axis_")*/
   // Beginning of automatic in/out/inouts (from specific module)
   output [3:0]		s_axis_tx_tuser;
   output [C_DATA_WIDTH-1:0] s_axis_tx_tdata;
   output [KEEP_WIDTH-1:0] s_axis_tx_tkeep;
   output		s_axis_tx_tlast;
   output		s_axis_tx_tvalid;
   input		s_axis_tx_tready;
   // End of automatics

   /*AUTOREG*/

   assign sys_rst_n = pci_exp_rstn;
   
   assign fc_sel           = 3'b100;
   assign cfg_turnoff_ok   = 1'b0;

   assign s_axis_tx_tvalid = 0;
   assign s_axis_tx_tuser  = 0;
   assign s_axis_tx_tlast  = 0;
   assign s_axis_tx_tkeep  = 0;
   assign s_axis_tx_tdata  = 0;

   assign m_axis_rx_tready = 0;
  
   wire REFCLK;
   IBUFDS_GTE2 refclk_ibuf (.O(REFCLK), .ODIV2(), .I(refclk_p), .CEB(1'b0), .IB(refclk_n));
endmodule // k7_stub
// Local Variables:
// verilog-library-directories:("." "..")
// verilog-library-files:(".""sata_phy")
// verilog-library-extensions:(".v" ".h")
// End:
// 
// k7_stub.v ends here
