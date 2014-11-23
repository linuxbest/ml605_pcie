// k7_pcie.v --- 
// 
// Filename: k7_pcie.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sat Nov 22 20:46:57 2014 (-0800)
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
module k7_pcie (/*AUTOARG*/
   // Outputs
   pci_exp_txp, pci_exp_txn,
   // Inputs
   refclk_p, refclk_n, pci_exp_rxp, pci_exp_rxn, pci_exp_rstn
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

   parameter PIPE_SIM_MODE     = "FALSE";
   parameter PL_FAST_TRAIN     = "FALSE"; // Simulation Speedup
   parameter PCIE_EXT_CLK      = "TRUE";  // Use External Clocking Module
   parameter C_DATA_WIDTH      = 128; // RX/TX interface data width
   parameter KEEP_WIDTH        = C_DATA_WIDTH / 8;// TSTRB width

   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		pci_exp_rstn;		// To k7_stub of k7_stub.v
   input [C_NO_OF_LANES-1:0] pci_exp_rxn;	// To k7_tlp of k7_tlp.v
   input [C_NO_OF_LANES-1:0] pci_exp_rxp;	// To k7_tlp of k7_tlp.v
   input		refclk_n;		// To k7_stub of k7_stub.v
   input		refclk_p;		// To k7_stub of k7_stub.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [C_NO_OF_LANES-1:0] pci_exp_txn;	// From k7_tlp of k7_tlp.v
   output [C_NO_OF_LANES-1:0] pci_exp_txp;	// From k7_tlp of k7_tlp.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			REFCLK;			// From k7_stub of k7_stub.v
   wire [15:0]		cfg_completer_id;	// From k7_tlp of k7_tlp.v
   wire			cfg_to_turnoff;		// From k7_tlp of k7_tlp.v
   wire			cfg_turnoff_ok;		// From k7_stub of k7_stub.v
   wire [11:0]		fc_cpld;		// From k7_tlp of k7_tlp.v
   wire [7:0]		fc_cplh;		// From k7_tlp of k7_tlp.v
   wire [11:0]		fc_npd;			// From k7_tlp of k7_tlp.v
   wire [7:0]		fc_nph;			// From k7_tlp of k7_tlp.v
   wire [11:0]		fc_pd;			// From k7_tlp of k7_tlp.v
   wire [7:0]		fc_ph;			// From k7_tlp of k7_tlp.v
   wire [2:0]		fc_sel;			// From k7_stub of k7_stub.v
   wire [C_DATA_WIDTH-1:0] m_axis_rx_tdata;	// From k7_tlp of k7_tlp.v
   wire [KEEP_WIDTH-1:0] m_axis_rx_tkeep;	// From k7_tlp of k7_tlp.v
   wire			m_axis_rx_tlast;	// From k7_tlp of k7_tlp.v
   wire			m_axis_rx_tready;	// From k7_stub of k7_stub.v
   wire [21:0]		m_axis_rx_tuser;	// From k7_tlp of k7_tlp.v
   wire			m_axis_rx_tvalid;	// From k7_tlp of k7_tlp.v
   wire			mmcm_lock;		// From k7_tlp of k7_tlp.v
   wire [C_DATA_WIDTH-1:0] s_axis_tx_tdata;	// From k7_stub of k7_stub.v
   wire [KEEP_WIDTH-1:0] s_axis_tx_tkeep;	// From k7_stub of k7_stub.v
   wire			s_axis_tx_tlast;	// From k7_stub of k7_stub.v
   wire			s_axis_tx_tready;	// From k7_tlp of k7_tlp.v
   wire [3:0]		s_axis_tx_tuser;	// From k7_stub of k7_stub.v
   wire			s_axis_tx_tvalid;	// From k7_stub of k7_stub.v
   wire			sys_rst_n;		// From k7_stub of k7_stub.v
   wire [5:0]		tx_buf_av;		// From k7_tlp of k7_tlp.v
   wire			user_clk;		// From k7_tlp of k7_tlp.v
   wire			user_link_up;		// From k7_tlp of k7_tlp.v
   wire			user_reset;		// From k7_tlp of k7_tlp.v
   // End of automatics

   k7_tlp #(/*AUTOINSTPARAM*/
	    // Parameters
	    .C_INSTANCE			(C_INSTANCE),
	    .C_FAMILY			(C_FAMILY),
	    .C_NO_OF_LANES		(C_NO_OF_LANES),
	    .C_MAX_LINK_SPEED		(C_MAX_LINK_SPEED),
	    .C_DEVICE_ID		(C_DEVICE_ID),
	    .C_VENDOR_ID		(C_VENDOR_ID),
	    .C_CLASS_CODE		(C_CLASS_CODE),
	    .C_REV_ID			(C_REV_ID),
	    .C_SUBSYSTEM_ID		(C_SUBSYSTEM_ID),
	    .C_SUBSYSTEM_VENDOR_ID	(C_SUBSYSTEM_VENDOR_ID),
	    .C_PCIE_CAP_SLOT_IMPLEMENTED(C_PCIE_CAP_SLOT_IMPLEMENTED),
	    .PCI_EXP_EP_DSN_1		(PCI_EXP_EP_DSN_1),
	    .PCI_EXP_EP_DSN_2		(PCI_EXP_EP_DSN_2),
	    .PIPE_SIM_MODE		(PIPE_SIM_MODE),
	    .PL_FAST_TRAIN		(PL_FAST_TRAIN),
	    .PCIE_EXT_CLK		(PCIE_EXT_CLK),
	    .C_DATA_WIDTH		(C_DATA_WIDTH),
	    .KEEP_WIDTH			(KEEP_WIDTH))
   k7_tlp  (/*AUTOINST*/
	    // Outputs
	    .pci_exp_txp		(pci_exp_txp[C_NO_OF_LANES-1:0]),
	    .pci_exp_txn		(pci_exp_txn[C_NO_OF_LANES-1:0]),
	    .mmcm_lock			(mmcm_lock),
	    .user_clk			(user_clk),
	    .user_reset			(user_reset),
	    .user_link_up		(user_link_up),
	    .tx_buf_av			(tx_buf_av[5:0]),
	    .s_axis_tx_tready		(s_axis_tx_tready),
	    .m_axis_rx_tdata		(m_axis_rx_tdata[C_DATA_WIDTH-1:0]),
	    .m_axis_rx_tkeep		(m_axis_rx_tkeep[KEEP_WIDTH-1:0]),
	    .m_axis_rx_tlast		(m_axis_rx_tlast),
	    .m_axis_rx_tvalid		(m_axis_rx_tvalid),
	    .m_axis_rx_tuser		(m_axis_rx_tuser[21:0]),
	    .fc_cpld			(fc_cpld[11:0]),
	    .fc_cplh			(fc_cplh[7:0]),
	    .fc_npd			(fc_npd[11:0]),
	    .fc_nph			(fc_nph[7:0]),
	    .fc_pd			(fc_pd[11:0]),
	    .fc_ph			(fc_ph[7:0]),
	    .cfg_to_turnoff		(cfg_to_turnoff),
	    .cfg_completer_id		(cfg_completer_id[15:0]),
	    // Inputs
	    .pci_exp_rxp		(pci_exp_rxp[C_NO_OF_LANES-1:0]),
	    .pci_exp_rxn		(pci_exp_rxn[C_NO_OF_LANES-1:0]),
	    .REFCLK			(REFCLK),
	    .sys_rst_n			(sys_rst_n),
	    .s_axis_tx_tuser		(s_axis_tx_tuser[3:0]),
	    .s_axis_tx_tdata		(s_axis_tx_tdata[C_DATA_WIDTH-1:0]),
	    .s_axis_tx_tkeep		(s_axis_tx_tkeep[KEEP_WIDTH-1:0]),
	    .s_axis_tx_tlast		(s_axis_tx_tlast),
	    .s_axis_tx_tvalid		(s_axis_tx_tvalid),
	    .m_axis_rx_tready		(m_axis_rx_tready),
	    .fc_sel			(fc_sel[2:0]),
	    .cfg_turnoff_ok		(cfg_turnoff_ok));
   
   k7_stub #(/*AUTOINSTPARAM*/
	     // Parameters
	     .C_INSTANCE		(C_INSTANCE),
	     .C_FAMILY			(C_FAMILY),
	     .C_NO_OF_LANES		(C_NO_OF_LANES),
	     .C_MAX_LINK_SPEED		(C_MAX_LINK_SPEED),
	     .C_DEVICE_ID		(C_DEVICE_ID),
	     .C_VENDOR_ID		(C_VENDOR_ID),
	     .C_CLASS_CODE		(C_CLASS_CODE),
	     .C_REV_ID			(C_REV_ID),
	     .C_SUBSYSTEM_ID		(C_SUBSYSTEM_ID),
	     .C_SUBSYSTEM_VENDOR_ID	(C_SUBSYSTEM_VENDOR_ID),
	     .C_PCIE_CAP_SLOT_IMPLEMENTED(C_PCIE_CAP_SLOT_IMPLEMENTED),
	     .PCI_EXP_EP_DSN_1		(PCI_EXP_EP_DSN_1),
	     .PCI_EXP_EP_DSN_2		(PCI_EXP_EP_DSN_2),
	     .PIPE_SIM_MODE		(PIPE_SIM_MODE),
	     .PL_FAST_TRAIN		(PL_FAST_TRAIN),
	     .PCIE_EXT_CLK		(PCIE_EXT_CLK),
	     .C_DATA_WIDTH		(C_DATA_WIDTH),
	     .KEEP_WIDTH		(KEEP_WIDTH))
   k7_stub (/*AUTOINST*/
	    // Outputs
	    .REFCLK			(REFCLK),
	    .sys_rst_n			(sys_rst_n),
	    .cfg_turnoff_ok		(cfg_turnoff_ok),
	    .fc_sel			(fc_sel[2:0]),
	    .m_axis_rx_tready		(m_axis_rx_tready),
	    .s_axis_tx_tuser		(s_axis_tx_tuser[3:0]),
	    .s_axis_tx_tdata		(s_axis_tx_tdata[C_DATA_WIDTH-1:0]),
	    .s_axis_tx_tkeep		(s_axis_tx_tkeep[KEEP_WIDTH-1:0]),
	    .s_axis_tx_tlast		(s_axis_tx_tlast),
	    .s_axis_tx_tvalid		(s_axis_tx_tvalid),
	    // Inputs
	    .refclk_p			(refclk_p),
	    .refclk_n			(refclk_n),
	    .pci_exp_rstn		(pci_exp_rstn),
	    .mmcm_lock			(mmcm_lock),
	    .tx_buf_av			(tx_buf_av[5:0]),
	    .user_clk			(user_clk),
	    .user_link_up		(user_link_up),
	    .user_reset			(user_reset),
	    .cfg_to_turnoff		(cfg_to_turnoff),
	    .cfg_completer_id		(cfg_completer_id[15:0]),
	    .fc_cpld			(fc_cpld[11:0]),
	    .fc_cplh			(fc_cplh[7:0]),
	    .fc_npd			(fc_npd[11:0]),
	    .fc_nph			(fc_nph[7:0]),
	    .fc_pd			(fc_pd[11:0]),
	    .fc_ph			(fc_ph[7:0]),
	    .m_axis_rx_tdata		(m_axis_rx_tdata[C_DATA_WIDTH-1:0]),
	    .m_axis_rx_tkeep		(m_axis_rx_tkeep[KEEP_WIDTH-1:0]),
	    .m_axis_rx_tlast		(m_axis_rx_tlast),
	    .m_axis_rx_tvalid		(m_axis_rx_tvalid),
	    .m_axis_rx_tuser		(m_axis_rx_tuser[21:0]),
	    .s_axis_tx_tready		(s_axis_tx_tready));
   
endmodule // k7_pcie
// Local Variables:
// verilog-library-directories:("." "..")
// verilog-library-files:(".""sata_phy")
// verilog-library-extensions:(".v" ".h")
// End:
// 
// k7_pcie.v ends here
