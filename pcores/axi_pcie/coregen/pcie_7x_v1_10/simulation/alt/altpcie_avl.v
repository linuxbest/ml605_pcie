// altpcie_avl.v --- 
// 
// Filename: altpcie_avl.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sat Nov  1 19:24:32 2014 (-0700)
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
`timescale 1ps/1ps
module altpcie_avl (/*AUTOARG*/
   // Outputs
   s_axis_tx_tuser, s_WriteData, s_Write, s_Read, s_ByteEnable,
   s_BurstCount, s_Address, m_WaitRequest, m_ReadDataValid,
   m_ReadData, fc_sel, S_WREADY, S_RVALID, S_RUSER, S_RRESP, S_RLAST,
   S_RID, S_RDATA, S_BVALID, S_BUSER, S_BRESP, S_BID, S_AWREADY,
   S_ARREADY, M_WVALID, M_WUSER, M_WSTRB, M_WLAST, M_WDATA, M_RREADY,
   M_BREADY, M_AWVALID, M_AWUSER, M_AWSIZE, M_AWREGION, M_AWQOS,
   M_AWPROT, M_AWLOCK, M_AWLEN, M_AWID, M_AWCACHE, M_AWBURST,
   M_AWADDR, M_ARVALID, M_ARUSER, M_ARSIZE, M_ARREGION, M_ARQOS,
   M_ARPROT, M_ARLOCK, M_ARLEN, M_ARID, M_ARCACHE, M_ARBURST,
   M_ARADDR, s_axis_tx_tdata, s_axis_tx_tkeep, s_axis_tx_tlast,
   s_axis_tx_tvalid, m_axis_rx_tready, cfg_turnoff_ok,
   // Inputs
   tx_buf_av, s_WaitRequest, s_ReadDataValid, s_ReadData, m_WriteData,
   m_Write, m_Read, m_ChipSelect, m_ByteEnable, m_BurstCount,
   m_Address, fc_ph, fc_pd, fc_nph, fc_npd, fc_cplh, fc_cpld,
   S_WVALID, S_WUSER, S_WSTRB, S_WLAST, S_WDATA, S_RREADY, S_BREADY,
   S_AWVALID, S_AWUSER, S_AWSIZE, S_AWREGION, S_AWQOS, S_AWPROT,
   S_AWLOCK, S_AWLEN, S_AWID, S_AWCACHE, S_AWBURST, S_AWADDR,
   S_ARVALID, S_ARUSER, S_ARSIZE, S_ARREGION, S_ARQOS, S_ARPROT,
   S_ARLOCK, S_ARLEN, S_ARID, S_ARCACHE, S_ARBURST, S_ARADDR,
   M_WREADY, M_RVALID, M_RUSER, M_RRESP, M_RLAST, M_RID, M_RDATA,
   M_BVALID, M_BUSER, M_BRESP, M_BID, M_AWREADY, M_ARREADY, user_clk,
   user_reset, user_lnk_up, s_axis_tx_tready, m_axis_rx_tdata,
   m_axis_rx_tkeep, m_axis_rx_tlast, m_axis_rx_tvalid,
   m_axis_rx_tuser, cfg_to_turnoff, cfg_completer_id
   );

   parameter C_DATA_WIDTH = 128;
   parameter KEEP_WIDTH   = 16;

   parameter C_M_AXI_ADDR_WIDTH      = 64;
   parameter C_M_AXI_DATA_WIDTH      = 128;
   parameter C_M_AXI_THREAD_ID_WIDTH = 3;
   parameter C_M_AXI_USER_WIDTH      = 3;   

   parameter C_S_AXI_ADDR_WIDTH      = 64;
   parameter C_S_AXI_DATA_WIDTH      = 128;
   parameter C_S_AXI_THREAD_ID_WIDTH = 3;
   parameter C_S_AXI_USER_WIDTH      = 3;   
   
   input                         user_clk;
   input                         user_reset;
   input                         user_lnk_up;
   
   // AXIS
   input                         s_axis_tx_tready;
   output [C_DATA_WIDTH-1:0] 	 s_axis_tx_tdata;
   output [KEEP_WIDTH-1:0] 	 s_axis_tx_tkeep;
   output                        s_axis_tx_tlast;
   output                        s_axis_tx_tvalid;
   
   
   input [C_DATA_WIDTH-1:0] 	 m_axis_rx_tdata;
   input [KEEP_WIDTH-1:0] 	 m_axis_rx_tkeep;
   input                         m_axis_rx_tlast;
   input                         m_axis_rx_tvalid;
   output                        m_axis_rx_tready;
   input [21:0] 		 m_axis_rx_tuser;
   
   input                         cfg_to_turnoff;
   output                        cfg_turnoff_ok;
   
   input [11:0] 		 cfg_completer_id;
   
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		M_ARREADY;		// To altpciexpav128_app of altpciexpav128_app.v
   input		M_AWREADY;		// To altpciexpav128_app of altpciexpav128_app.v
   input [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_BID;// To altpciexpav128_app of altpciexpav128_app.v
   input [1:0]		M_BRESP;		// To altpciexpav128_app of altpciexpav128_app.v
   input [((C_M_AXI_USER_WIDTH)-1):0] M_BUSER;	// To altpciexpav128_app of altpciexpav128_app.v
   input		M_BVALID;		// To altpciexpav128_app of altpciexpav128_app.v
   input [((C_M_AXI_DATA_WIDTH)-1):0] M_RDATA;	// To altpciexpav128_app of altpciexpav128_app.v
   input [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_RID;// To altpciexpav128_app of altpciexpav128_app.v
   input		M_RLAST;		// To altpciexpav128_app of altpciexpav128_app.v
   input [1:0]		M_RRESP;		// To altpciexpav128_app of altpciexpav128_app.v
   input [((C_M_AXI_USER_WIDTH)-1):0] M_RUSER;	// To altpciexpav128_app of altpciexpav128_app.v
   input		M_RVALID;		// To altpciexpav128_app of altpciexpav128_app.v
   input		M_WREADY;		// To altpciexpav128_app of altpciexpav128_app.v
   input [((C_S_AXI_ADDR_WIDTH)-1):0] S_ARADDR;	// To altpciexpav128_app of altpciexpav128_app.v
   input [1:0]		S_ARBURST;		// To altpciexpav128_app of altpciexpav128_app.v
   input [3:0]		S_ARCACHE;		// To altpciexpav128_app of altpciexpav128_app.v
   input [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_ARID;// To altpciexpav128_app of altpciexpav128_app.v
   input [7:0]		S_ARLEN;		// To altpciexpav128_app of altpciexpav128_app.v
   input		S_ARLOCK;		// To altpciexpav128_app of altpciexpav128_app.v
   input [2:0]		S_ARPROT;		// To altpciexpav128_app of altpciexpav128_app.v
   input [3:0]		S_ARQOS;		// To altpciexpav128_app of altpciexpav128_app.v
   input [3:0]		S_ARREGION;		// To altpciexpav128_app of altpciexpav128_app.v
   input [2:0]		S_ARSIZE;		// To altpciexpav128_app of altpciexpav128_app.v
   input [((C_S_AXI_USER_WIDTH)-1):0] S_ARUSER;	// To altpciexpav128_app of altpciexpav128_app.v
   input		S_ARVALID;		// To altpciexpav128_app of altpciexpav128_app.v
   input [((C_S_AXI_ADDR_WIDTH)-1):0] S_AWADDR;	// To altpciexpav128_app of altpciexpav128_app.v
   input [1:0]		S_AWBURST;		// To altpciexpav128_app of altpciexpav128_app.v
   input [3:0]		S_AWCACHE;		// To altpciexpav128_app of altpciexpav128_app.v
   input [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_AWID;// To altpciexpav128_app of altpciexpav128_app.v
   input [7:0]		S_AWLEN;		// To altpciexpav128_app of altpciexpav128_app.v
   input		S_AWLOCK;		// To altpciexpav128_app of altpciexpav128_app.v
   input [2:0]		S_AWPROT;		// To altpciexpav128_app of altpciexpav128_app.v
   input [3:0]		S_AWQOS;		// To altpciexpav128_app of altpciexpav128_app.v
   input [3:0]		S_AWREGION;		// To altpciexpav128_app of altpciexpav128_app.v
   input [2:0]		S_AWSIZE;		// To altpciexpav128_app of altpciexpav128_app.v
   input [((C_S_AXI_USER_WIDTH)-1):0] S_AWUSER;	// To altpciexpav128_app of altpciexpav128_app.v
   input		S_AWVALID;		// To altpciexpav128_app of altpciexpav128_app.v
   input		S_BREADY;		// To altpciexpav128_app of altpciexpav128_app.v
   input		S_RREADY;		// To altpciexpav128_app of altpciexpav128_app.v
   input [((C_S_AXI_DATA_WIDTH)-1):0] S_WDATA;	// To altpciexpav128_app of altpciexpav128_app.v
   input		S_WLAST;		// To altpciexpav128_app of altpciexpav128_app.v
   input [(((C_S_AXI_DATA_WIDTH/8))-1):0] S_WSTRB;// To altpciexpav128_app of altpciexpav128_app.v
   input [((C_S_AXI_USER_WIDTH)-1):0] S_WUSER;	// To altpciexpav128_app of altpciexpav128_app.v
   input		S_WVALID;		// To altpciexpav128_app of altpciexpav128_app.v
   input [11:0]		fc_cpld;		// To altpcie_stub of altpcie_stub.v
   input [7:0]		fc_cplh;		// To altpcie_stub of altpcie_stub.v
   input [11:0]		fc_npd;			// To altpcie_stub of altpcie_stub.v
   input [7:0]		fc_nph;			// To altpcie_stub of altpcie_stub.v
   input [11:0]		fc_pd;			// To altpcie_stub of altpcie_stub.v
   input [7:0]		fc_ph;			// To altpcie_stub of altpcie_stub.v
   input [63:0]		m_Address;		// To altpcie_stub of altpcie_stub.v
   input [5:0]		m_BurstCount;		// To altpcie_stub of altpcie_stub.v
   input [15:0]		m_ByteEnable;		// To altpcie_stub of altpcie_stub.v
   input		m_ChipSelect;		// To altpcie_stub of altpcie_stub.v
   input		m_Read;			// To altpcie_stub of altpcie_stub.v
   input		m_Write;		// To altpcie_stub of altpcie_stub.v
   input [127:0]	m_WriteData;		// To altpcie_stub of altpcie_stub.v
   input [127:0]	s_ReadData;		// To altpcie_stub of altpcie_stub.v
   input		s_ReadDataValid;	// To altpcie_stub of altpcie_stub.v
   input		s_WaitRequest;		// To altpcie_stub of altpcie_stub.v
   input [5:0]		tx_buf_av;		// To altpcie_stub of altpcie_stub.v
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [((C_M_AXI_ADDR_WIDTH)-1):0] M_ARADDR;// From altpciexpav128_app of altpciexpav128_app.v
   output [1:0]		M_ARBURST;		// From altpciexpav128_app of altpciexpav128_app.v
   output [3:0]		M_ARCACHE;		// From altpciexpav128_app of altpciexpav128_app.v
   output [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_ARID;// From altpciexpav128_app of altpciexpav128_app.v
   output [7:0]		M_ARLEN;		// From altpciexpav128_app of altpciexpav128_app.v
   output		M_ARLOCK;		// From altpciexpav128_app of altpciexpav128_app.v
   output [2:0]		M_ARPROT;		// From altpciexpav128_app of altpciexpav128_app.v
   output [3:0]		M_ARQOS;		// From altpciexpav128_app of altpciexpav128_app.v
   output [3:0]		M_ARREGION;		// From altpciexpav128_app of altpciexpav128_app.v
   output [2:0]		M_ARSIZE;		// From altpciexpav128_app of altpciexpav128_app.v
   output [((C_M_AXI_USER_WIDTH)-1):0] M_ARUSER;// From altpciexpav128_app of altpciexpav128_app.v
   output		M_ARVALID;		// From altpciexpav128_app of altpciexpav128_app.v
   output [((C_M_AXI_ADDR_WIDTH)-1):0] M_AWADDR;// From altpciexpav128_app of altpciexpav128_app.v
   output [1:0]		M_AWBURST;		// From altpciexpav128_app of altpciexpav128_app.v
   output [3:0]		M_AWCACHE;		// From altpciexpav128_app of altpciexpav128_app.v
   output [((C_M_AXI_THREAD_ID_WIDTH)-1):0] M_AWID;// From altpciexpav128_app of altpciexpav128_app.v
   output [7:0]		M_AWLEN;		// From altpciexpav128_app of altpciexpav128_app.v
   output		M_AWLOCK;		// From altpciexpav128_app of altpciexpav128_app.v
   output [2:0]		M_AWPROT;		// From altpciexpav128_app of altpciexpav128_app.v
   output [3:0]		M_AWQOS;		// From altpciexpav128_app of altpciexpav128_app.v
   output [3:0]		M_AWREGION;		// From altpciexpav128_app of altpciexpav128_app.v
   output [2:0]		M_AWSIZE;		// From altpciexpav128_app of altpciexpav128_app.v
   output [((C_M_AXI_USER_WIDTH)-1):0] M_AWUSER;// From altpciexpav128_app of altpciexpav128_app.v
   output		M_AWVALID;		// From altpciexpav128_app of altpciexpav128_app.v
   output		M_BREADY;		// From altpciexpav128_app of altpciexpav128_app.v
   output		M_RREADY;		// From altpciexpav128_app of altpciexpav128_app.v
   output [((C_M_AXI_DATA_WIDTH)-1):0] M_WDATA;	// From altpciexpav128_app of altpciexpav128_app.v
   output		M_WLAST;		// From altpciexpav128_app of altpciexpav128_app.v
   output [(((C_M_AXI_DATA_WIDTH/8))-1):0] M_WSTRB;// From altpciexpav128_app of altpciexpav128_app.v
   output [((C_M_AXI_USER_WIDTH)-1):0] M_WUSER;	// From altpciexpav128_app of altpciexpav128_app.v
   output		M_WVALID;		// From altpciexpav128_app of altpciexpav128_app.v
   output		S_ARREADY;		// From altpciexpav128_app of altpciexpav128_app.v
   output		S_AWREADY;		// From altpciexpav128_app of altpciexpav128_app.v
   output [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_BID;// From altpciexpav128_app of altpciexpav128_app.v
   output [1:0]		S_BRESP;		// From altpciexpav128_app of altpciexpav128_app.v
   output [((C_S_AXI_USER_WIDTH)-1):0] S_BUSER;	// From altpciexpav128_app of altpciexpav128_app.v
   output		S_BVALID;		// From altpciexpav128_app of altpciexpav128_app.v
   output [((C_S_AXI_DATA_WIDTH)-1):0] S_RDATA;	// From altpciexpav128_app of altpciexpav128_app.v
   output [((C_S_AXI_THREAD_ID_WIDTH)-1):0] S_RID;// From altpciexpav128_app of altpciexpav128_app.v
   output		S_RLAST;		// From altpciexpav128_app of altpciexpav128_app.v
   output [1:0]		S_RRESP;		// From altpciexpav128_app of altpciexpav128_app.v
   output [((C_S_AXI_USER_WIDTH)-1):0] S_RUSER;	// From altpciexpav128_app of altpciexpav128_app.v
   output		S_RVALID;		// From altpciexpav128_app of altpciexpav128_app.v
   output		S_WREADY;		// From altpciexpav128_app of altpciexpav128_app.v
   output [2:0]		fc_sel;			// From altpcie_stub of altpcie_stub.v
   output [127:0]	m_ReadData;		// From altpcie_stub of altpcie_stub.v
   output		m_ReadDataValid;	// From altpcie_stub of altpcie_stub.v
   output		m_WaitRequest;		// From altpcie_stub of altpcie_stub.v
   output [31:0]	s_Address;		// From altpcie_stub of altpcie_stub.v
   output [5:0]		s_BurstCount;		// From altpcie_stub of altpcie_stub.v
   output [15:0]	s_ByteEnable;		// From altpcie_stub of altpcie_stub.v
   output		s_Read;			// From altpcie_stub of altpcie_stub.v
   output		s_Write;		// From altpcie_stub of altpcie_stub.v
   output [127:0]	s_WriteData;		// From altpcie_stub of altpcie_stub.v
   output [3:0]		s_axis_tx_tuser;	// From altpcie_stub of altpcie_stub.v
   // End of automatics
 
   localparam pll_refclk_freq_hwtcl                             = "100 MHz";
   localparam enable_slot_register_hwtcl                        = 0;
   localparam port_type_hwtcl                                   = "Native endpoint";
   localparam bypass_cdc_hwtcl                                  = "false";
   localparam enable_rx_buffer_checking_hwtcl                   = "false";
   localparam single_rx_detect_hwtcl                            = 0;
   localparam use_crc_forwarding_hwtcl                          = 0;
   localparam ast_width_hwtcl                                   = "rx_tx_64";
   localparam gen123_lane_rate_mode_hwtcl                       = "gen1";
   localparam lane_mask_hwtcl                                   = "x4";
   localparam disable_link_x2_support_hwtcl                     = "false";
   localparam hip_hard_reset_hwtcl                              = 1;
   localparam enable_power_on_rst_pulse_hwtcl                   = 0;
   localparam enable_pcisigtest_hwtcl                           = 0;
   localparam wrong_device_id_hwtcl                             = "disable";
   localparam data_pack_rx_hwtcl                                = "disable";
   localparam use_ast_parity                                    = 0;
   localparam ltssm_1ms_timeout_hwtcl                           = "disable";
   localparam ltssm_freqlocked_check_hwtcl                      = "disable";
   localparam deskew_comma_hwtcl                                = "com_deskw";
   localparam port_link_number_hwtcl                            = 1;
   localparam device_number_hwtcl                               = 0;
   localparam bypass_clk_switch_hwtcl                           = "TRUE";
   localparam pipex1_debug_sel_hwtcl                            = "disable";
   localparam pclk_out_sel_hwtcl                                = "pclk";
   localparam vendor_id_hwtcl                                   = 4466;
   localparam device_id_hwtcl                                   = 57345;
   localparam revision_id_hwtcl                                 = 1;
   localparam class_code_hwtcl                                  = 16711680;
   localparam subsystem_vendor_id_hwtcl                         = 4466;
   localparam subsystem_device_id_hwtcl                         = 57345;
   localparam no_soft_reset_hwtcl                               = "false";
   localparam maximum_current_hwtcl                             = 0;
   localparam d1_support_hwtcl                                  = "false";
   localparam d2_support_hwtcl                                  = "false";
   localparam d0_pme_hwtcl                                      = "false";
   localparam d1_pme_hwtcl                                      = "false";
   localparam d2_pme_hwtcl                                      = "false";
   localparam d3_hot_pme_hwtcl                                  = "false";
   localparam d3_cold_pme_hwtcl                                 = "false";
   localparam use_aer_hwtcl                                     = 0;
   localparam low_priority_vc_hwtcl                             = "single_vc";
   localparam disable_snoop_packet_hwtcl                        = "false";
   localparam max_payload_size_hwtcl                            = 128;
   localparam surprise_down_error_support_hwtcl                 = 0;
   localparam dll_active_report_support_hwtcl                   = 0;
   localparam extend_tag_field_hwtcl                            = "false";
   localparam endpoint_l0_latency_hwtcl                         = 0;
   localparam endpoint_l1_latency_hwtcl                         = 0;
   localparam indicator_hwtcl                                   = 7;
   localparam slot_power_scale_hwtcl                            = 0;
   localparam enable_l1_aspm_hwtcl                              = "false";
   localparam l1_exit_latency_sameclock_hwtcl                   = 0;
   localparam l1_exit_latency_diffclock_hwtcl                   = 0;
   localparam hot_plug_support_hwtcl                            = 0;
   localparam slot_power_limit_hwtcl                            = 0;
   localparam slot_number_hwtcl                                 = 0;
   localparam diffclock_nfts_count_hwtcl                        = 0;
   localparam sameclock_nfts_count_hwtcl                        = 0;
   localparam completion_timeout_hwtcl                          = "abcd";
   localparam enable_completion_timeout_disable_hwtcl           = 1;
   localparam extended_tag_reset_hwtcl                          = "false";
   localparam ecrc_check_capable_hwtcl                          = 0;
   localparam ecrc_gen_capable_hwtcl                            = 0;
   localparam no_command_completed_hwtcl                        = "true";
   localparam msi_multi_message_capable_hwtcl                   = "count_4";
   localparam msi_64bit_addressing_capable_hwtcl                = "true";
   localparam msi_masking_capable_hwtcl                         = "false";
   localparam msi_support_hwtcl                                 = "true";
   localparam interrupt_pin_hwtcl                               = "inta";
   localparam enable_function_msix_support_hwtcl                = 0;
   localparam msix_table_size_hwtcl                             = 0;
   localparam msix_table_bir_hwtcl                              = 0;
   localparam msix_table_offset_hwtcl                           = "0";
   localparam msix_pba_bir_hwtcl                                = 0;
   localparam msix_pba_offset_hwtcl                             = "0";
   localparam bridge_port_vga_enable_hwtcl                      = "false";
   localparam bridge_port_ssid_support_hwtcl                    = "false";
   localparam ssvid_hwtcl                                       = 0;
   localparam ssid_hwtcl                                        = 0;
   localparam eie_before_nfts_count_hwtcl                       = 4;
   localparam gen2_diffclock_nfts_count_hwtcl                   = 255;
   localparam gen2_sameclock_nfts_count_hwtcl                   = 255;
   localparam deemphasis_enable_hwtcl                           = "false";
   localparam pcie_spec_version_hwtcl                           = "v2";
   localparam l0_exit_latency_sameclock_hwtcl                   = 6;
   localparam l0_exit_latency_diffclock_hwtcl                   = 6;
   localparam rx_ei_l0s_hwtcl                                   = 1;
   localparam l2_async_logic_hwtcl                              = "enable";
   localparam aspm_config_management_hwtcl                      = "true";
   localparam atomic_op_routing_hwtcl                           = "false";
   localparam atomic_op_completer_32bit_hwtcl                   = "false";
   localparam atomic_op_completer_64bit_hwtcl                   = "false";
   localparam cas_completer_128bit_hwtcl                        = "false";
   localparam ltr_mechanism_hwtcl                               = "false";
   localparam tph_completer_hwtcl                               = "false";
   localparam extended_format_field_hwtcl                       = "false";
   localparam atomic_malformed_hwtcl                            = "false";
   localparam flr_capability_hwtcl                              = "true";
   localparam enable_adapter_half_rate_mode_hwtcl               = "false";
   localparam vc0_clk_enable_hwtcl                              = "true";
   localparam register_pipe_signals_hwtcl                       = "false";
   localparam bar0_io_space_hwtcl                               = "Disabled";
   localparam bar0_64bit_mem_space_hwtcl                        = "Enabled";
   localparam bar0_prefetchable_hwtcl                           = "Enabled";
   localparam bar0_size_mask_hwtcl                              = "256 MBytes - 28 bits";
   localparam bar1_io_space_hwtcl                               = "Disabled";
   localparam bar1_64bit_mem_space_hwtcl                        = "Disabled";
   localparam bar1_prefetchable_hwtcl                           = "Disabled";
   localparam bar1_size_mask_hwtcl                              = "N/A";
   localparam bar2_io_space_hwtcl                               = "Disabled";
   localparam bar2_64bit_mem_space_hwtcl                        = "Disabled";
   localparam bar2_prefetchable_hwtcl                           = "Disabled";
   localparam bar2_size_mask_hwtcl                              = "N/A";
   localparam bar3_io_space_hwtcl                               = "Disabled";
   localparam bar3_64bit_mem_space_hwtcl                        = "Disabled";
   localparam bar3_prefetchable_hwtcl                           = "Disabled";
   localparam bar3_size_mask_hwtcl                              = "N/A";
   localparam bar4_io_space_hwtcl                               = "Disabled";
   localparam bar4_64bit_mem_space_hwtcl                        = "Disabled";
   localparam bar4_prefetchable_hwtcl                           = "Disabled";
   localparam bar4_size_mask_hwtcl                              = "N/A";
   localparam bar5_io_space_hwtcl                               = "Disabled";
   localparam bar5_64bit_mem_space_hwtcl                        = "Disabled";
   localparam bar5_prefetchable_hwtcl                           = "Disabled";
   localparam bar5_size_mask_hwtcl                              = "N/A";
   localparam expansion_base_address_register_hwtcl             = 0;
   localparam io_window_addr_width_hwtcl                        = "window_32_bit";
   localparam prefetchable_mem_window_addr_width_hwtcl          = "prefetch_32";
   localparam skp_os_gen3_count_hwtcl                           = 0;
   localparam tx_cdc_almost_empty_hwtcl                         = 5;
   localparam rx_cdc_almost_full_hwtcl                          = 6;
   localparam tx_cdc_almost_full_hwtcl                          = 6;
   localparam rx_l0s_count_idl_hwtcl                            = 0;
   localparam cdc_dummy_insert_limit_hwtcl                      = 11;
   localparam ei_delay_powerdown_count_hwtcl                    = 10;
   localparam millisecond_cycle_count_hwtcl                     = 0;
   localparam skp_os_schedule_count_hwtcl                       = 0;
   localparam fc_init_timer_hwtcl                               = 1024;
   localparam l01_entry_latency_hwtcl                           = 31;
   localparam flow_control_update_count_hwtcl                   = 30;
   localparam flow_control_timeout_count_hwtcl                  = 200;
   localparam credit_buffer_allocation_aux_hwtcl                = "balanced";
   localparam vc0_rx_flow_ctrl_posted_header_hwtcl              = 50;
   localparam vc0_rx_flow_ctrl_posted_data_hwtcl                = 360;
   localparam vc0_rx_flow_ctrl_nonposted_header_hwtcl           = 54;
   localparam vc0_rx_flow_ctrl_nonposted_data_hwtcl             = 0;
   localparam vc0_rx_flow_ctrl_compl_header_hwtcl               = 112;
   localparam vc0_rx_flow_ctrl_compl_data_hwtcl                 = 448;
   localparam rx_ptr0_posted_dpram_min_hwtcl                    = 0;
   localparam rx_ptr0_posted_dpram_max_hwtcl                    = 0;
   localparam rx_ptr0_nonposted_dpram_min_hwtcl                 = 0;
   localparam rx_ptr0_nonposted_dpram_max_hwtcl                 = 0;
   localparam retry_buffer_last_active_address_hwtcl            = 2047;
   localparam retry_buffer_memory_settings_hwtcl                = 0;
   localparam vc0_rx_buffer_memory_settings_hwtcl               = 0;
   localparam in_cvp_mode_hwtcl                                 = 0;
   localparam slotclkcfg_hwtcl                                  = 1;
   localparam reconfig_to_xcvr_width                            = 350;
   localparam set_pld_clk_x1_625MHz_hwtcl                       = 0;
   localparam reconfig_from_xcvr_width                          = 230;
   localparam enable_l0s_aspm_hwtcl                             = "true";
   localparam cpl_spc_header_hwtcl                              = 195;
   localparam cpl_spc_data_hwtcl                                = 781;
   localparam port_width_be_hwtcl                               = 8;
   localparam port_width_data_hwtcl                             = 64;
   localparam reserved_debug_hwtcl                              = 0;
   localparam hip_reconfig_hwtcl                                = 0;
   localparam vsec_id_hwtcl                                     = 0;
   localparam vsec_rev_hwtcl                                    = 0;
   localparam gen3_rxfreqlock_counter_hwtcl                     = 0;
   localparam gen3_skip_ph2_ph3_hwtcl                           = 1;
   localparam g3_bypass_equlz_hwtcl                             = 1;
   localparam enable_tl_only_sim_hwtcl                          = 0;
   localparam use_atx_pll_hwtcl                                 = 0;
   localparam cvp_rate_sel_hwtcl                                = "full_rate";
   localparam cvp_data_compressed_hwtcl                         = "false";
   localparam cvp_data_encrypted_hwtcl                          = "false";
   localparam cvp_mode_reset_hwtcl                              = "false";
   localparam cvp_clk_reset_hwtcl                               = "false";
   localparam cseb_cpl_status_during_cvp_hwtcl                  = "config_retry_status";
   localparam core_clk_sel_hwtcl                                = "pld_clk";
   localparam g3_dis_rx_use_prst_hwtcl                          = "true";
   localparam g3_dis_rx_use_prst_ep_hwtcl                       = "false";
   
      localparam hwtcl_override_g2_txvod                           = 0; // When 1 use gen3 param from HWTCL; else use default
      localparam rpre_emph_a_val_hwtcl                             = 9 ;
      localparam rpre_emph_b_val_hwtcl                             = 0 ;
      localparam rpre_emph_c_val_hwtcl                             = 16;
      localparam rpre_emph_d_val_hwtcl                             = 11;
      localparam rpre_emph_e_val_hwtcl                             = 5 ;
      localparam rvod_sel_a_val_hwtcl                              = 42;
      localparam rvod_sel_b_val_hwtcl                              = 38;
      localparam rvod_sel_c_val_hwtcl                              = 38;
      localparam rvod_sel_d_val_hwtcl                              = 38;
      localparam rvod_sel_e_val_hwtcl                              = 15;


      /// Bridge Parameters
      localparam CG_ENABLE_A2P_INTERRUPT = 0;
      localparam CG_ENABLE_ADVANCED_INTERRUPT = 0;
      localparam CG_RXM_IRQ_NUM = 16;
      localparam CB_PCIE_MODE   = 0;
      localparam CB_PCIE_RX_LITE = 0;
      localparam CB_A2P_ADDR_MAP_IS_FIXED = 0;
      localparam CB_A2P_ADDR_MAP_NUM_ENTRIES = 2;
      localparam CG_AVALON_S_ADDR_WIDTH = 32;
      localparam CG_IMPL_CRA_AV_SLAVE_PORT = 1;
      localparam a2p_pass_thru_bits = 24;
      localparam CB_P2A_AVALON_ADDR_B0               = 32'hC4000000;
      localparam CB_P2A_AVALON_ADDR_B1               = 32'h00000000;
      localparam CB_P2A_AVALON_ADDR_B2               = 32'h00000000;
      localparam CB_P2A_AVALON_ADDR_B3               = 32'h00000000;
      localparam CB_P2A_AVALON_ADDR_B4               = 32'h00000000;
      localparam CB_P2A_AVALON_ADDR_B5               = 32'h00000000;
      localparam CB_P2A_AVALON_ADDR_B6               = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_0_LOW   = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_0_HIGH  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_1_LOW   = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_1_HIGH  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_2_LOW   = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_2_HIGH  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_3_LOW   = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_3_HIGH  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_4_LOW   = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_4_HIGH  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_5_LOW   = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_5_HIGH  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_6_LOW   = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_6_HIGH  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_7_LOW   = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_7_HIGH  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_8_LOW   = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_8_HIGH  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_9_LOW   = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_9_HIGH  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_10_LOW  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_10_HIGH = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_11_LOW  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_11_HIGH = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_12_LOW  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_12_HIGH = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_13_LOW  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_13_HIGH = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_14_LOW  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_14_HIGH = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_15_LOW  = 32'h00000000;
      localparam CB_A2P_ADDR_MAP_FIXED_TABLE_15_HIGH = 32'h00000000;
      localparam bar_prefetchable = 1;
      localparam avmm_width_hwtcl = 64;
      localparam avmm_burst_width_hwtcl = 7;
      localparam CB_RXM_DATA_WIDTH = 128;
      localparam AVALON_ADDR_WIDTH = 64;
      localparam BYPASSS_A2P_TRANSLATION = 0;

// Exposed localparams
localparam ast_width                                     = (ast_width_hwtcl=="Avalon-ST 256-bit")?"rx_tx_256":(ast_width_hwtcl=="Avalon-ST 128-bit")?"rx_tx_128":"rx_tx_64";// String  : "rx_tx_64";

localparam bar0_io_space                                 = "false";
localparam bar0_64bit_mem_space                          = "false";
localparam bar0_prefetchable                             = "false";
localparam bar0_size_mask                                = 19;
localparam bar1_io_space                                 = "false"; 
localparam bar1_64bit_mem_space                          = "false"; 
localparam bar1_prefetchable                             = "false"; 
localparam bar1_size_mask                                = 0;
localparam bar2_io_space                                 = "false"; 
localparam bar2_64bit_mem_space                          = "false"; 
localparam bar2_prefetchable                             = "false"; 
localparam bar2_size_mask                                = 0;
localparam bar3_io_space                                 = "false"; 
localparam bar3_64bit_mem_space                          = "false"; 
localparam bar3_prefetchable                             = "false"; 
localparam bar3_size_mask                                = 0;
localparam bar4_io_space                                 = "false"; 
localparam bar4_64bit_mem_space                          = "false"; 
localparam bar4_prefetchable                             = "false"; 
localparam bar4_size_mask                                = 0;
localparam bar5_io_space                                 = "false"; 
localparam bar5_64bit_mem_space                          = "false"; 
localparam bar5_prefetchable                             = "false"; 
localparam bar5_size_mask                                = 0;
localparam bar_io_window_size                            = 0;

localparam expansion_base_address_register               = expansion_base_address_register_hwtcl                     ;// String  : 32'b0;


// Not visible localparams
localparam QW_ZERO                 = 64'h0;
localparam INTENDED_DEVICE_FAMILY = "Stratix V";

localparam CB_A2P_ADDR_MAP_FIXED_TABLE     = { CB_A2P_ADDR_MAP_FIXED_TABLE_15_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_15_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_14_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_14_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_13_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_13_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_12_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_12_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_11_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_11_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_10_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_10_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_9_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_9_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_8_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_8_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_7_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_7_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_6_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_6_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_5_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_5_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_4_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_4_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_3_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_3_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_2_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_2_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_1_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_1_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_0_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_0_LOW
                                              };
  
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			AvlClk_i;		// From altpcie_stub of altpcie_stub.v
   wire [3:0]		CfgAddr_i;		// From altpcie_stub of altpcie_stub.v
   wire			CfgCtlWr_i;		// From altpcie_stub of altpcie_stub.v
   wire [31:0]		CfgCtl_i;		// From altpcie_stub of altpcie_stub.v
   wire			CplPending_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire [13:2]		CraAddress_i;		// From altpcie_stub of altpcie_stub.v
   wire [3:0]		CraByteEnable_i;	// From altpcie_stub of altpcie_stub.v
   wire			CraChipSelect_i;	// From altpcie_stub of altpcie_stub.v
   wire			CraClk_i;		// From altpcie_stub of altpcie_stub.v
   wire			CraIrq_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			CraRead;		// From altpcie_stub of altpcie_stub.v
   wire [31:0]		CraReadData_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			CraRstn_i;		// From altpcie_stub of altpcie_stub.v
   wire			CraWaitRequest_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire			CraWrite;		// From altpcie_stub of altpcie_stub.v
   wire [31:0]		CraWriteData_i;		// From altpcie_stub of altpcie_stub.v
   wire			IntxAck_i;		// From altpcie_stub of altpcie_stub.v
   wire			IntxReq_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			MsiAck_i;		// From altpcie_stub of altpcie_stub.v
   wire [15:0]		MsiControl_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire [81:0]		MsiIntfc_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire [4:0]		MsiNum_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			MsiReq_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire [2:0]		MsiTc_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire [15:0]		MsixIntfc_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			Rstn_i;			// From altpcie_stub of altpcie_stub.v
   wire [3:0]		RxIntStatus_i;		// From altpcie_stub of altpcie_stub.v
   wire [7:0]		RxStBarDec1_i;		// From altpcie_stub of altpcie_stub.v
   wire [7:0]		RxStBarDec2_i;		// From altpcie_stub of altpcie_stub.v
   wire [15:0]		RxStBe_i;		// From altpcie_stub of altpcie_stub.v
   wire [127:0]		RxStData_i;		// From altpcie_stub of altpcie_stub.v
   wire [1:0]		RxStEmpty_i;		// From altpcie_stub of altpcie_stub.v
   wire			RxStEop_i;		// From altpcie_stub of altpcie_stub.v
   wire			RxStErr_i;		// From altpcie_stub of altpcie_stub.v
   wire			RxStMask_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxStReady_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxStSop_i;		// From altpcie_stub of altpcie_stub.v
   wire			RxStValid_i;		// From altpcie_stub of altpcie_stub.v
   wire [AVALON_ADDR_WIDTH-1:0] RxmAddress_0_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [AVALON_ADDR_WIDTH-1:0] RxmAddress_1_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [AVALON_ADDR_WIDTH-1:0] RxmAddress_2_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [AVALON_ADDR_WIDTH-1:0] RxmAddress_3_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [AVALON_ADDR_WIDTH-1:0] RxmAddress_4_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [AVALON_ADDR_WIDTH-1:0] RxmAddress_5_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [6:0]		RxmBurstCount_0_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [6:0]		RxmBurstCount_1_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [6:0]		RxmBurstCount_2_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [6:0]		RxmBurstCount_3_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [6:0]		RxmBurstCount_4_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [6:0]		RxmBurstCount_5_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_0_o;// From altpciexpav128_app of altpciexpav128_app.v
   wire [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_1_o;// From altpciexpav128_app of altpciexpav128_app.v
   wire [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_2_o;// From altpciexpav128_app of altpciexpav128_app.v
   wire [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_3_o;// From altpciexpav128_app of altpciexpav128_app.v
   wire [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_4_o;// From altpciexpav128_app of altpciexpav128_app.v
   wire [(CB_RXM_DATA_WIDTH/8)-1:0] RxmByteEnable_5_o;// From altpciexpav128_app of altpciexpav128_app.v
   wire [CG_RXM_IRQ_NUM-1:0] RxmIrq_i;		// From altpcie_stub of altpcie_stub.v
   wire			RxmReadDataValid_0_i;	// From altpcie_stub of altpcie_stub.v
   wire			RxmReadDataValid_1_i;	// From altpcie_stub of altpcie_stub.v
   wire			RxmReadDataValid_2_i;	// From altpcie_stub of altpcie_stub.v
   wire			RxmReadDataValid_3_i;	// From altpcie_stub of altpcie_stub.v
   wire			RxmReadDataValid_4_i;	// From altpcie_stub of altpcie_stub.v
   wire			RxmReadDataValid_5_i;	// From altpcie_stub of altpcie_stub.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmReadData_0_i;// From altpcie_stub of altpcie_stub.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmReadData_1_i;// From altpcie_stub of altpcie_stub.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmReadData_2_i;// From altpcie_stub of altpcie_stub.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmReadData_3_i;// From altpcie_stub of altpcie_stub.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmReadData_4_i;// From altpcie_stub of altpcie_stub.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmReadData_5_i;// From altpcie_stub of altpcie_stub.v
   wire			RxmRead_0_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmRead_1_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmRead_2_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmRead_3_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmRead_4_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmRead_5_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmWaitRequest_0_i;	// From altpcie_stub of altpcie_stub.v
   wire			RxmWaitRequest_1_i;	// From altpcie_stub of altpcie_stub.v
   wire			RxmWaitRequest_2_i;	// From altpcie_stub of altpcie_stub.v
   wire			RxmWaitRequest_3_i;	// From altpcie_stub of altpcie_stub.v
   wire			RxmWaitRequest_4_i;	// From altpcie_stub of altpcie_stub.v
   wire			RxmWaitRequest_5_i;	// From altpcie_stub of altpcie_stub.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_0_o;// From altpciexpav128_app of altpciexpav128_app.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_1_o;// From altpciexpav128_app of altpciexpav128_app.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_2_o;// From altpciexpav128_app of altpciexpav128_app.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_3_o;// From altpciexpav128_app of altpciexpav128_app.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_4_o;// From altpciexpav128_app of altpciexpav128_app.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmWriteData_5_o;// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmWrite_0_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmWrite_1_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmWrite_2_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmWrite_3_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmWrite_4_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmWrite_5_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			TxAdapterFifoEmpty_i;	// From altpcie_stub of altpcie_stub.v
   wire [11:0]		TxCredCplDataLimit_i;	// From altpcie_stub of altpcie_stub.v
   wire [7:0]		TxCredCplHdrLimit_i;	// From altpcie_stub of altpcie_stub.v
   wire [5:0]		TxCredHipCons_i;	// From altpcie_stub of altpcie_stub.v
   wire [5:0]		TxCredInfinit_i;	// From altpcie_stub of altpcie_stub.v
   wire [11:0]		TxCredNpDataLimit_i;	// From altpcie_stub of altpcie_stub.v
   wire [7:0]		TxCredNpHdrLimit_i;	// From altpcie_stub of altpcie_stub.v
   wire [11:0]		TxCredPDataLimit_i;	// From altpcie_stub of altpcie_stub.v
   wire [7:0]		TxCredPHdrLimit_i;	// From altpcie_stub of altpcie_stub.v
   wire [127:0]		TxStData_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire [1:0]		TxStEmpty_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			TxStEop_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			TxStReady_i;		// From altpcie_stub of altpcie_stub.v
   wire			TxStSop_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			TxStValid_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire [CG_AVALON_S_ADDR_WIDTH-1:0] TxsAddress_i;// From altpcie_stub of altpcie_stub.v
   wire [5:0]		TxsBurstCount_i;	// From altpcie_stub of altpcie_stub.v
   wire [15:0]		TxsByteEnable_i;	// From altpcie_stub of altpcie_stub.v
   wire			TxsChipSelect_i;	// From altpcie_stub of altpcie_stub.v
   wire			TxsClk_i;		// From altpcie_stub of altpcie_stub.v
   wire			TxsReadDataValid_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [127:0]		TxsReadData_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			TxsRead_i;		// From altpcie_stub of altpcie_stub.v
   wire			TxsRstn_i;		// From altpcie_stub of altpcie_stub.v
   wire			TxsWaitRequest_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [127:0]		TxsWriteData_i;		// From altpcie_stub of altpcie_stub.v
   wire			TxsWrite_i;		// From altpcie_stub of altpcie_stub.v
   wire [1:0]		current_speed;		// From altpcie_stub of altpcie_stub.v
   wire [11:0]		ko_cpl_spc_data;	// From altpcie_stub of altpcie_stub.v
   wire [7:0]		ko_cpl_spc_header;	// From altpcie_stub of altpcie_stub.v
   wire [3:0]		lane_act;		// From altpcie_stub of altpcie_stub.v
   wire [4:0]		ltssm_state;		// From altpcie_stub of altpcie_stub.v
   wire			pld_clk_inuse;		// From altpcie_stub of altpcie_stub.v
   wire			tx_cons_cred_sel;	// From altpciexpav128_app of altpciexpav128_app.v
   // End of automatics
  
   localparam CG_COMMON_CLOCK_MODE = 1;
   localparam CB_A2P_PERF_PROFILE  = 3;
   localparam CB_P2A_PERF_PROFILE  = 3;
   localparam EXTERNAL_A2P_TRANS   = 0;
   localparam NUM_PREFETCH_MASTERS = 1;
   localparam CB_A2P_ADDR_MAP_PASS_THRU_BITS = 24;

   altpciexpav128_app #(/*AUTOINSTPARAM*/
			// Parameters
			.INTENDED_DEVICE_FAMILY(INTENDED_DEVICE_FAMILY),
			.CG_AVALON_S_ADDR_WIDTH(CG_AVALON_S_ADDR_WIDTH),
			.CG_COMMON_CLOCK_MODE(CG_COMMON_CLOCK_MODE),
			.CG_IMPL_CRA_AV_SLAVE_PORT(CG_IMPL_CRA_AV_SLAVE_PORT),
			.CB_A2P_PERF_PROFILE(CB_A2P_PERF_PROFILE),
			.CB_P2A_PERF_PROFILE(CB_P2A_PERF_PROFILE),
			.CB_PCIE_MODE	(CB_PCIE_MODE),
			.CB_A2P_ADDR_MAP_IS_FIXED(CB_A2P_ADDR_MAP_IS_FIXED),
			.CB_A2P_ADDR_MAP_FIXED_TABLE(CB_A2P_ADDR_MAP_FIXED_TABLE[1023:0]),
			.CB_A2P_ADDR_MAP_NUM_ENTRIES(CB_A2P_ADDR_MAP_NUM_ENTRIES),
			.CB_A2P_ADDR_MAP_PASS_THRU_BITS(CB_A2P_ADDR_MAP_PASS_THRU_BITS),
			.CB_P2A_AVALON_ADDR_B0(CB_P2A_AVALON_ADDR_B0),
			.CB_P2A_AVALON_ADDR_B1(CB_P2A_AVALON_ADDR_B1),
			.CB_P2A_AVALON_ADDR_B2(CB_P2A_AVALON_ADDR_B2),
			.CB_P2A_AVALON_ADDR_B3(CB_P2A_AVALON_ADDR_B3),
			.CB_P2A_AVALON_ADDR_B4(CB_P2A_AVALON_ADDR_B4),
			.CB_P2A_AVALON_ADDR_B5(CB_P2A_AVALON_ADDR_B5),
			.CB_P2A_AVALON_ADDR_B6(CB_P2A_AVALON_ADDR_B6),
			.bar0_64bit_mem_space(bar0_64bit_mem_space),
			.bar0_io_space	(bar0_io_space),
			.bar0_prefetchable(bar0_prefetchable),
			.bar0_size_mask	(bar0_size_mask),
			.bar1_64bit_mem_space(bar1_64bit_mem_space),
			.bar1_io_space	(bar1_io_space),
			.bar1_prefetchable(bar1_prefetchable),
			.bar1_size_mask	(bar1_size_mask),
			.bar2_64bit_mem_space(bar2_64bit_mem_space),
			.bar2_io_space	(bar2_io_space),
			.bar2_prefetchable(bar2_prefetchable),
			.bar2_size_mask	(bar2_size_mask),
			.bar3_64bit_mem_space(bar3_64bit_mem_space),
			.bar3_io_space	(bar3_io_space),
			.bar3_prefetchable(bar3_prefetchable),
			.bar3_size_mask	(bar3_size_mask),
			.bar4_64bit_mem_space(bar4_64bit_mem_space),
			.bar4_io_space	(bar4_io_space),
			.bar4_prefetchable(bar4_prefetchable),
			.bar4_size_mask	(bar4_size_mask),
			.bar5_64bit_mem_space(bar5_64bit_mem_space),
			.bar5_io_space	(bar5_io_space),
			.bar5_prefetchable(bar5_prefetchable),
			.bar5_size_mask	(bar5_size_mask),
			.bar_io_window_size(bar_io_window_size),
			.bar_prefetchable(bar_prefetchable),
			.expansion_base_address_register(expansion_base_address_register),
			.EXTERNAL_A2P_TRANS(EXTERNAL_A2P_TRANS),
			.CG_ENABLE_A2P_INTERRUPT(CG_ENABLE_A2P_INTERRUPT),
			.CG_ENABLE_ADVANCED_INTERRUPT(CG_ENABLE_ADVANCED_INTERRUPT),
			.CG_RXM_IRQ_NUM	(CG_RXM_IRQ_NUM),
			.NUM_PREFETCH_MASTERS(NUM_PREFETCH_MASTERS),
			.CB_PCIE_RX_LITE(CB_PCIE_RX_LITE),
			.CB_RXM_DATA_WIDTH(CB_RXM_DATA_WIDTH),
			.port_type_hwtcl(port_type_hwtcl),
			.AVALON_ADDR_WIDTH(AVALON_ADDR_WIDTH),
			.BYPASSS_A2P_TRANSLATION(BYPASSS_A2P_TRANSLATION),
			.C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
			.C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
			.C_M_AXI_THREAD_ID_WIDTH(C_M_AXI_THREAD_ID_WIDTH),
			.C_M_AXI_USER_WIDTH(C_M_AXI_USER_WIDTH),
			.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
			.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
			.C_S_AXI_THREAD_ID_WIDTH(C_S_AXI_THREAD_ID_WIDTH),
			.C_S_AXI_USER_WIDTH(C_S_AXI_USER_WIDTH))
   altpciexpav128_app  (/*AUTOINST*/
			// Outputs
			.RxStReady_o	(RxStReady_o),
			.RxStMask_o	(RxStMask_o),
			.TxStData_o	(TxStData_o[127:0]),
			.TxStSop_o	(TxStSop_o),
			.TxStEop_o	(TxStEop_o),
			.TxStEmpty_o	(TxStEmpty_o[1:0]),
			.TxStValid_o	(TxStValid_o),
			.CplPending_o	(CplPending_o),
			.MsiReq_o	(MsiReq_o),
			.MsiTc_o	(MsiTc_o[2:0]),
			.MsiNum_o	(MsiNum_o[4:0]),
			.IntxReq_o	(IntxReq_o),
			.TxsReadDataValid_o(TxsReadDataValid_o),
			.TxsReadData_o	(TxsReadData_o[127:0]),
			.TxsWaitRequest_o(TxsWaitRequest_o),
			.RxmWrite_0_o	(RxmWrite_0_o),
			.RxmAddress_0_o	(RxmAddress_0_o[AVALON_ADDR_WIDTH-1:0]),
			.RxmWriteData_0_o(RxmWriteData_0_o[CB_RXM_DATA_WIDTH-1:0]),
			.RxmByteEnable_0_o(RxmByteEnable_0_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
			.RxmBurstCount_0_o(RxmBurstCount_0_o[6:0]),
			.RxmRead_0_o	(RxmRead_0_o),
			.RxmWrite_1_o	(RxmWrite_1_o),
			.RxmAddress_1_o	(RxmAddress_1_o[AVALON_ADDR_WIDTH-1:0]),
			.RxmWriteData_1_o(RxmWriteData_1_o[CB_RXM_DATA_WIDTH-1:0]),
			.RxmByteEnable_1_o(RxmByteEnable_1_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
			.RxmBurstCount_1_o(RxmBurstCount_1_o[6:0]),
			.RxmRead_1_o	(RxmRead_1_o),
			.RxmWrite_2_o	(RxmWrite_2_o),
			.RxmAddress_2_o	(RxmAddress_2_o[AVALON_ADDR_WIDTH-1:0]),
			.RxmWriteData_2_o(RxmWriteData_2_o[CB_RXM_DATA_WIDTH-1:0]),
			.RxmByteEnable_2_o(RxmByteEnable_2_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
			.RxmBurstCount_2_o(RxmBurstCount_2_o[6:0]),
			.RxmRead_2_o	(RxmRead_2_o),
			.RxmWrite_3_o	(RxmWrite_3_o),
			.RxmAddress_3_o	(RxmAddress_3_o[AVALON_ADDR_WIDTH-1:0]),
			.RxmWriteData_3_o(RxmWriteData_3_o[CB_RXM_DATA_WIDTH-1:0]),
			.RxmByteEnable_3_o(RxmByteEnable_3_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
			.RxmBurstCount_3_o(RxmBurstCount_3_o[6:0]),
			.RxmRead_3_o	(RxmRead_3_o),
			.RxmWrite_4_o	(RxmWrite_4_o),
			.RxmAddress_4_o	(RxmAddress_4_o[AVALON_ADDR_WIDTH-1:0]),
			.RxmWriteData_4_o(RxmWriteData_4_o[CB_RXM_DATA_WIDTH-1:0]),
			.RxmByteEnable_4_o(RxmByteEnable_4_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
			.RxmBurstCount_4_o(RxmBurstCount_4_o[6:0]),
			.RxmRead_4_o	(RxmRead_4_o),
			.RxmWrite_5_o	(RxmWrite_5_o),
			.RxmAddress_5_o	(RxmAddress_5_o[AVALON_ADDR_WIDTH-1:0]),
			.RxmWriteData_5_o(RxmWriteData_5_o[CB_RXM_DATA_WIDTH-1:0]),
			.RxmByteEnable_5_o(RxmByteEnable_5_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
			.RxmBurstCount_5_o(RxmBurstCount_5_o[6:0]),
			.RxmRead_5_o	(RxmRead_5_o),
			.CraReadData_o	(CraReadData_o[31:0]),
			.CraWaitRequest_o(CraWaitRequest_o),
			.CraIrq_o	(CraIrq_o),
			.MsiIntfc_o	(MsiIntfc_o[81:0]),
			.MsiControl_o	(MsiControl_o[15:0]),
			.MsixIntfc_o	(MsixIntfc_o[15:0]),
			.tx_cons_cred_sel(tx_cons_cred_sel),
			.M_AWVALID	(M_AWVALID),
			.M_AWADDR	(M_AWADDR[((C_M_AXI_ADDR_WIDTH)-1):0]),
			.M_AWPROT	(M_AWPROT[2:0]),
			.M_AWREGION	(M_AWREGION[3:0]),
			.M_AWLEN	(M_AWLEN[7:0]),
			.M_AWSIZE	(M_AWSIZE[2:0]),
			.M_AWBURST	(M_AWBURST[1:0]),
			.M_AWLOCK	(M_AWLOCK),
			.M_AWCACHE	(M_AWCACHE[3:0]),
			.M_AWQOS	(M_AWQOS[3:0]),
			.M_AWID		(M_AWID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
			.M_AWUSER	(M_AWUSER[((C_M_AXI_USER_WIDTH)-1):0]),
			.M_WVALID	(M_WVALID),
			.M_WDATA	(M_WDATA[((C_M_AXI_DATA_WIDTH)-1):0]),
			.M_WSTRB	(M_WSTRB[(((C_M_AXI_DATA_WIDTH/8))-1):0]),
			.M_WLAST	(M_WLAST),
			.M_WUSER	(M_WUSER[((C_M_AXI_USER_WIDTH)-1):0]),
			.M_BREADY	(M_BREADY),
			.M_ARVALID	(M_ARVALID),
			.M_ARADDR	(M_ARADDR[((C_M_AXI_ADDR_WIDTH)-1):0]),
			.M_ARPROT	(M_ARPROT[2:0]),
			.M_ARREGION	(M_ARREGION[3:0]),
			.M_ARLEN	(M_ARLEN[7:0]),
			.M_ARSIZE	(M_ARSIZE[2:0]),
			.M_ARBURST	(M_ARBURST[1:0]),
			.M_ARLOCK	(M_ARLOCK),
			.M_ARCACHE	(M_ARCACHE[3:0]),
			.M_ARQOS	(M_ARQOS[3:0]),
			.M_ARID		(M_ARID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
			.M_ARUSER	(M_ARUSER[((C_M_AXI_USER_WIDTH)-1):0]),
			.M_RREADY	(M_RREADY),
			.S_AWREADY	(S_AWREADY),
			.S_WREADY	(S_WREADY),
			.S_BVALID	(S_BVALID),
			.S_BRESP	(S_BRESP[1:0]),
			.S_BID		(S_BID[((C_S_AXI_THREAD_ID_WIDTH)-1):0]),
			.S_BUSER	(S_BUSER[((C_S_AXI_USER_WIDTH)-1):0]),
			.S_ARREADY	(S_ARREADY),
			.S_RVALID	(S_RVALID),
			.S_RDATA	(S_RDATA[((C_S_AXI_DATA_WIDTH)-1):0]),
			.S_RRESP	(S_RRESP[1:0]),
			.S_RLAST	(S_RLAST),
			.S_RID		(S_RID[((C_S_AXI_THREAD_ID_WIDTH)-1):0]),
			.S_RUSER	(S_RUSER[((C_S_AXI_USER_WIDTH)-1):0]),
			// Inputs
			.AvlClk_i	(AvlClk_i),
			.Rstn_i		(Rstn_i),
			.RxStData_i	(RxStData_i[127:0]),
			.RxStBe_i	(RxStBe_i[15:0]),
			.RxStEmpty_i	(RxStEmpty_i[1:0]),
			.RxStErr_i	(RxStErr_i),
			.RxStSop_i	(RxStSop_i),
			.RxStEop_i	(RxStEop_i),
			.RxStValid_i	(RxStValid_i),
			.RxStBarDec1_i	(RxStBarDec1_i[7:0]),
			.RxStBarDec2_i	(RxStBarDec2_i[7:0]),
			.TxStReady_i	(TxStReady_i),
			.TxAdapterFifoEmpty_i(TxAdapterFifoEmpty_i),
			.TxCredPDataLimit_i(TxCredPDataLimit_i[11:0]),
			.TxCredNpDataLimit_i(TxCredNpDataLimit_i[11:0]),
			.TxCredCplDataLimit_i(TxCredCplDataLimit_i[11:0]),
			.TxCredHipCons_i(TxCredHipCons_i[5:0]),
			.TxCredInfinit_i(TxCredInfinit_i[5:0]),
			.TxCredPHdrLimit_i(TxCredPHdrLimit_i[7:0]),
			.TxCredNpHdrLimit_i(TxCredNpHdrLimit_i[7:0]),
			.TxCredCplHdrLimit_i(TxCredCplHdrLimit_i[7:0]),
			.ko_cpl_spc_header(ko_cpl_spc_header[7:0]),
			.ko_cpl_spc_data(ko_cpl_spc_data[11:0]),
			.CfgCtlWr_i	(CfgCtlWr_i),
			.CfgAddr_i	(CfgAddr_i[3:0]),
			.CfgCtl_i	(CfgCtl_i[31:0]),
			.MsiAck_i	(MsiAck_i),
			.IntxAck_i	(IntxAck_i),
			.TxsClk_i	(TxsClk_i),
			.TxsRstn_i	(TxsRstn_i),
			.TxsChipSelect_i(TxsChipSelect_i),
			.TxsRead_i	(TxsRead_i),
			.TxsWrite_i	(TxsWrite_i),
			.TxsWriteData_i	(TxsWriteData_i[127:0]),
			.TxsBurstCount_i(TxsBurstCount_i[5:0]),
			.TxsAddress_i	(TxsAddress_i[CG_AVALON_S_ADDR_WIDTH-1:0]),
			.TxsByteEnable_i(TxsByteEnable_i[15:0]),
			.RxmWaitRequest_0_i(RxmWaitRequest_0_i),
			.RxmReadData_0_i(RxmReadData_0_i[CB_RXM_DATA_WIDTH-1:0]),
			.RxmReadDataValid_0_i(RxmReadDataValid_0_i),
			.RxmWaitRequest_1_i(RxmWaitRequest_1_i),
			.RxmReadData_1_i(RxmReadData_1_i[CB_RXM_DATA_WIDTH-1:0]),
			.RxmReadDataValid_1_i(RxmReadDataValid_1_i),
			.RxmWaitRequest_2_i(RxmWaitRequest_2_i),
			.RxmReadData_2_i(RxmReadData_2_i[CB_RXM_DATA_WIDTH-1:0]),
			.RxmReadDataValid_2_i(RxmReadDataValid_2_i),
			.RxmWaitRequest_3_i(RxmWaitRequest_3_i),
			.RxmReadData_3_i(RxmReadData_3_i[CB_RXM_DATA_WIDTH-1:0]),
			.RxmReadDataValid_3_i(RxmReadDataValid_3_i),
			.RxmWaitRequest_4_i(RxmWaitRequest_4_i),
			.RxmReadData_4_i(RxmReadData_4_i[CB_RXM_DATA_WIDTH-1:0]),
			.RxmReadDataValid_4_i(RxmReadDataValid_4_i),
			.RxmWaitRequest_5_i(RxmWaitRequest_5_i),
			.RxmReadData_5_i(RxmReadData_5_i[CB_RXM_DATA_WIDTH-1:0]),
			.RxmReadDataValid_5_i(RxmReadDataValid_5_i),
			.RxmIrq_i	(RxmIrq_i[CG_RXM_IRQ_NUM-1:0]),
			.CraClk_i	(CraClk_i),
			.CraRstn_i	(CraRstn_i),
			.CraChipSelect_i(CraChipSelect_i),
			.CraRead	(CraRead),
			.CraWrite	(CraWrite),
			.CraWriteData_i	(CraWriteData_i[31:0]),
			.CraAddress_i	(CraAddress_i[13:2]),
			.CraByteEnable_i(CraByteEnable_i[3:0]),
			.RxIntStatus_i	(RxIntStatus_i[3:0]),
			.pld_clk_inuse	(pld_clk_inuse),
			.ltssm_state	(ltssm_state[4:0]),
			.current_speed	(current_speed[1:0]),
			.lane_act	(lane_act[3:0]),
			.M_AWREADY	(M_AWREADY),
			.M_WREADY	(M_WREADY),
			.M_BVALID	(M_BVALID),
			.M_BRESP	(M_BRESP[1:0]),
			.M_BID		(M_BID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
			.M_BUSER	(M_BUSER[((C_M_AXI_USER_WIDTH)-1):0]),
			.M_ARREADY	(M_ARREADY),
			.M_RVALID	(M_RVALID),
			.M_RDATA	(M_RDATA[((C_M_AXI_DATA_WIDTH)-1):0]),
			.M_RRESP	(M_RRESP[1:0]),
			.M_RLAST	(M_RLAST),
			.M_RID		(M_RID[((C_M_AXI_THREAD_ID_WIDTH)-1):0]),
			.M_RUSER	(M_RUSER[((C_M_AXI_USER_WIDTH)-1):0]),
			.S_AWVALID	(S_AWVALID),
			.S_AWADDR	(S_AWADDR[((C_S_AXI_ADDR_WIDTH)-1):0]),
			.S_AWPROT	(S_AWPROT[2:0]),
			.S_AWREGION	(S_AWREGION[3:0]),
			.S_AWLEN	(S_AWLEN[7:0]),
			.S_AWSIZE	(S_AWSIZE[2:0]),
			.S_AWBURST	(S_AWBURST[1:0]),
			.S_AWLOCK	(S_AWLOCK),
			.S_AWCACHE	(S_AWCACHE[3:0]),
			.S_AWQOS	(S_AWQOS[3:0]),
			.S_AWID		(S_AWID[((C_S_AXI_THREAD_ID_WIDTH)-1):0]),
			.S_AWUSER	(S_AWUSER[((C_S_AXI_USER_WIDTH)-1):0]),
			.S_WVALID	(S_WVALID),
			.S_WDATA	(S_WDATA[((C_S_AXI_DATA_WIDTH)-1):0]),
			.S_WSTRB	(S_WSTRB[(((C_S_AXI_DATA_WIDTH/8))-1):0]),
			.S_WLAST	(S_WLAST),
			.S_WUSER	(S_WUSER[((C_S_AXI_USER_WIDTH)-1):0]),
			.S_BREADY	(S_BREADY),
			.S_ARVALID	(S_ARVALID),
			.S_ARADDR	(S_ARADDR[((C_S_AXI_ADDR_WIDTH)-1):0]),
			.S_ARPROT	(S_ARPROT[2:0]),
			.S_ARREGION	(S_ARREGION[3:0]),
			.S_ARLEN	(S_ARLEN[7:0]),
			.S_ARSIZE	(S_ARSIZE[2:0]),
			.S_ARBURST	(S_ARBURST[1:0]),
			.S_ARLOCK	(S_ARLOCK),
			.S_ARCACHE	(S_ARCACHE[3:0]),
			.S_ARQOS	(S_ARQOS[3:0]),
			.S_ARID		(S_ARID[((C_S_AXI_THREAD_ID_WIDTH)-1):0]),
			.S_ARUSER	(S_ARUSER[((C_S_AXI_USER_WIDTH)-1):0]),
			.S_RREADY	(S_RREADY));

   altpcie_stub #(/*AUTOINSTPARAM*/
		  // Parameters
		  .CB_RXM_DATA_WIDTH	(CB_RXM_DATA_WIDTH),
		  .AVALON_ADDR_WIDTH	(AVALON_ADDR_WIDTH),
		  .CG_RXM_IRQ_NUM	(CG_RXM_IRQ_NUM),
		  .CG_AVALON_S_ADDR_WIDTH(CG_AVALON_S_ADDR_WIDTH),
		  .C_DATA_WIDTH		(C_DATA_WIDTH),
		  .KEEP_WIDTH		(KEEP_WIDTH))
   altpcie_stub  (/*AUTOINST*/
		  // Outputs
		  .AvlClk_i		(AvlClk_i),
		  .Rstn_i		(Rstn_i),
		  .RxStData_i		(RxStData_i[127:0]),
		  .RxStBe_i		(RxStBe_i[15:0]),
		  .RxStEmpty_i		(RxStEmpty_i[1:0]),
		  .RxStErr_i		(RxStErr_i),
		  .RxStSop_i		(RxStSop_i),
		  .RxStEop_i		(RxStEop_i),
		  .RxStValid_i		(RxStValid_i),
		  .RxStBarDec1_i	(RxStBarDec1_i[7:0]),
		  .RxStBarDec2_i	(RxStBarDec2_i[7:0]),
		  .TxCredPDataLimit_i	(TxCredPDataLimit_i[11:0]),
		  .TxCredNpDataLimit_i	(TxCredNpDataLimit_i[11:0]),
		  .TxCredCplDataLimit_i	(TxCredCplDataLimit_i[11:0]),
		  .TxCredHipCons_i	(TxCredHipCons_i[5:0]),
		  .TxCredInfinit_i	(TxCredInfinit_i[5:0]),
		  .TxCredPHdrLimit_i	(TxCredPHdrLimit_i[7:0]),
		  .TxCredNpHdrLimit_i	(TxCredNpHdrLimit_i[7:0]),
		  .TxCredCplHdrLimit_i	(TxCredCplHdrLimit_i[7:0]),
		  .MsiAck_i		(MsiAck_i),
		  .CfgCtlWr_i		(CfgCtlWr_i),
		  .CfgAddr_i		(CfgAddr_i[3:0]),
		  .CfgCtl_i		(CfgCtl_i[31:0]),
		  .CraClk_i		(CraClk_i),
		  .CraRstn_i		(CraRstn_i),
		  .CraChipSelect_i	(CraChipSelect_i),
		  .CraRead		(CraRead),
		  .CraWrite		(CraWrite),
		  .CraWriteData_i	(CraWriteData_i[31:0]),
		  .CraAddress_i		(CraAddress_i[13:2]),
		  .CraByteEnable_i	(CraByteEnable_i[3:0]),
		  .RxmWaitRequest_0_i	(RxmWaitRequest_0_i),
		  .RxmReadData_0_i	(RxmReadData_0_i[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmReadDataValid_0_i	(RxmReadDataValid_0_i),
		  .RxmWaitRequest_1_i	(RxmWaitRequest_1_i),
		  .RxmReadData_1_i	(RxmReadData_1_i[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmReadDataValid_1_i	(RxmReadDataValid_1_i),
		  .RxmWaitRequest_2_i	(RxmWaitRequest_2_i),
		  .RxmReadData_2_i	(RxmReadData_2_i[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmReadDataValid_2_i	(RxmReadDataValid_2_i),
		  .RxmWaitRequest_3_i	(RxmWaitRequest_3_i),
		  .RxmReadData_3_i	(RxmReadData_3_i[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmReadDataValid_3_i	(RxmReadDataValid_3_i),
		  .RxmWaitRequest_4_i	(RxmWaitRequest_4_i),
		  .RxmReadData_4_i	(RxmReadData_4_i[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmReadDataValid_4_i	(RxmReadDataValid_4_i),
		  .RxmWaitRequest_5_i	(RxmWaitRequest_5_i),
		  .RxmReadData_5_i	(RxmReadData_5_i[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmReadDataValid_5_i	(RxmReadDataValid_5_i),
		  .RxmIrq_i		(RxmIrq_i[CG_RXM_IRQ_NUM-1:0]),
		  .TxStReady_i		(TxStReady_i),
		  .TxsClk_i		(TxsClk_i),
		  .TxsRstn_i		(TxsRstn_i),
		  .TxsChipSelect_i	(TxsChipSelect_i),
		  .TxsRead_i		(TxsRead_i),
		  .TxsWrite_i		(TxsWrite_i),
		  .TxsWriteData_i	(TxsWriteData_i[127:0]),
		  .TxsBurstCount_i	(TxsBurstCount_i[5:0]),
		  .TxsAddress_i		(TxsAddress_i[CG_AVALON_S_ADDR_WIDTH-1:0]),
		  .TxsByteEnable_i	(TxsByteEnable_i[15:0]),
		  .IntxAck_i		(IntxAck_i),
		  .RxIntStatus_i	(RxIntStatus_i[3:0]),
		  .current_speed	(current_speed[1:0]),
		  .ko_cpl_spc_data	(ko_cpl_spc_data[11:0]),
		  .ko_cpl_spc_header	(ko_cpl_spc_header[7:0]),
		  .lane_act		(lane_act[3:0]),
		  .ltssm_state		(ltssm_state[4:0]),
		  .pld_clk_inuse	(pld_clk_inuse),
		  .TxAdapterFifoEmpty_i	(TxAdapterFifoEmpty_i),
		  .fc_sel		(fc_sel[2:0]),
		  .s_axis_tx_tdata	(s_axis_tx_tdata[C_DATA_WIDTH-1:0]),
		  .s_axis_tx_tkeep	(s_axis_tx_tkeep[KEEP_WIDTH-1:0]),
		  .s_axis_tx_tlast	(s_axis_tx_tlast),
		  .s_axis_tx_tvalid	(s_axis_tx_tvalid),
		  .s_axis_tx_tuser	(s_axis_tx_tuser[3:0]),
		  .cfg_turnoff_ok	(cfg_turnoff_ok),
		  .m_axis_rx_tready	(m_axis_rx_tready),
		  .m_WaitRequest	(m_WaitRequest),
		  .m_ReadData		(m_ReadData[127:0]),
		  .m_ReadDataValid	(m_ReadDataValid),
		  .s_Read		(s_Read),
		  .s_Write		(s_Write),
		  .s_BurstCount		(s_BurstCount[5:0]),
		  .s_ByteEnable		(s_ByteEnable[15:0]),
		  .s_Address		(s_Address[31:0]),
		  .s_WriteData		(s_WriteData[127:0]),
		  // Inputs
		  .RxStReady_o		(RxStReady_o),
		  .RxStMask_o		(RxStMask_o),
		  .MsiReq_o		(MsiReq_o),
		  .MsiTc_o		(MsiTc_o[2:0]),
		  .MsiNum_o		(MsiNum_o[4:0]),
		  .MsiIntfc_o		(MsiIntfc_o[81:0]),
		  .MsiControl_o		(MsiControl_o[15:0]),
		  .MsixIntfc_o		(MsixIntfc_o[15:0]),
		  .CraReadData_o	(CraReadData_o[31:0]),
		  .CraWaitRequest_o	(CraWaitRequest_o),
		  .CraIrq_o		(CraIrq_o),
		  .RxmWrite_0_o		(RxmWrite_0_o),
		  .RxmAddress_0_o	(RxmAddress_0_o[AVALON_ADDR_WIDTH-1:0]),
		  .RxmWriteData_0_o	(RxmWriteData_0_o[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmByteEnable_0_o	(RxmByteEnable_0_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		  .RxmBurstCount_0_o	(RxmBurstCount_0_o[6:0]),
		  .RxmRead_0_o		(RxmRead_0_o),
		  .RxmWrite_1_o		(RxmWrite_1_o),
		  .RxmAddress_1_o	(RxmAddress_1_o[AVALON_ADDR_WIDTH-1:0]),
		  .RxmWriteData_1_o	(RxmWriteData_1_o[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmByteEnable_1_o	(RxmByteEnable_1_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		  .RxmBurstCount_1_o	(RxmBurstCount_1_o[6:0]),
		  .RxmRead_1_o		(RxmRead_1_o),
		  .RxmWrite_2_o		(RxmWrite_2_o),
		  .RxmAddress_2_o	(RxmAddress_2_o[AVALON_ADDR_WIDTH-1:0]),
		  .RxmWriteData_2_o	(RxmWriteData_2_o[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmByteEnable_2_o	(RxmByteEnable_2_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		  .RxmBurstCount_2_o	(RxmBurstCount_2_o[6:0]),
		  .RxmRead_2_o		(RxmRead_2_o),
		  .RxmWrite_3_o		(RxmWrite_3_o),
		  .RxmAddress_3_o	(RxmAddress_3_o[AVALON_ADDR_WIDTH-1:0]),
		  .RxmWriteData_3_o	(RxmWriteData_3_o[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmByteEnable_3_o	(RxmByteEnable_3_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		  .RxmBurstCount_3_o	(RxmBurstCount_3_o[6:0]),
		  .RxmRead_3_o		(RxmRead_3_o),
		  .RxmWrite_4_o		(RxmWrite_4_o),
		  .RxmAddress_4_o	(RxmAddress_4_o[AVALON_ADDR_WIDTH-1:0]),
		  .RxmWriteData_4_o	(RxmWriteData_4_o[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmByteEnable_4_o	(RxmByteEnable_4_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		  .RxmBurstCount_4_o	(RxmBurstCount_4_o[6:0]),
		  .RxmRead_4_o		(RxmRead_4_o),
		  .RxmWrite_5_o		(RxmWrite_5_o),
		  .RxmAddress_5_o	(RxmAddress_5_o[AVALON_ADDR_WIDTH-1:0]),
		  .RxmWriteData_5_o	(RxmWriteData_5_o[CB_RXM_DATA_WIDTH-1:0]),
		  .RxmByteEnable_5_o	(RxmByteEnable_5_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
		  .RxmBurstCount_5_o	(RxmBurstCount_5_o[6:0]),
		  .RxmRead_5_o		(RxmRead_5_o),
		  .TxStData_o		(TxStData_o[127:0]),
		  .TxStSop_o		(TxStSop_o),
		  .TxStEop_o		(TxStEop_o),
		  .TxStEmpty_o		(TxStEmpty_o[1:0]),
		  .TxStValid_o		(TxStValid_o),
		  .TxsReadDataValid_o	(TxsReadDataValid_o),
		  .TxsReadData_o	(TxsReadData_o[127:0]),
		  .TxsWaitRequest_o	(TxsWaitRequest_o),
		  .IntxReq_o		(IntxReq_o),
		  .tx_cons_cred_sel	(tx_cons_cred_sel),
		  .CplPending_o		(CplPending_o),
		  .user_clk		(user_clk),
		  .user_reset		(user_reset),
		  .user_lnk_up		(user_lnk_up),
		  .fc_cpld		(fc_cpld[11:0]),
		  .fc_cplh		(fc_cplh[7:0]),
		  .fc_npd		(fc_npd[11:0]),
		  .fc_nph		(fc_nph[7:0]),
		  .fc_pd		(fc_pd[11:0]),
		  .fc_ph		(fc_ph[7:0]),
		  .tx_buf_av		(tx_buf_av[5:0]),
		  .s_axis_tx_tready	(s_axis_tx_tready),
		  .m_axis_rx_tdata	(m_axis_rx_tdata[C_DATA_WIDTH-1:0]),
		  .m_axis_rx_tkeep	(m_axis_rx_tkeep[KEEP_WIDTH-1:0]),
		  .m_axis_rx_tlast	(m_axis_rx_tlast),
		  .m_axis_rx_tvalid	(m_axis_rx_tvalid),
		  .m_axis_rx_tuser	(m_axis_rx_tuser[21:0]),
		  .m_ChipSelect		(m_ChipSelect),
		  .m_Read		(m_Read),
		  .m_Write		(m_Write),
		  .m_BurstCount		(m_BurstCount[5:0]),
		  .m_ByteEnable		(m_ByteEnable[15:0]),
		  .m_Address		(m_Address[63:0]),
		  .m_WriteData		(m_WriteData[127:0]),
		  .s_WaitRequest	(s_WaitRequest),
		  .s_ReadData		(s_ReadData[127:0]),
		  .s_ReadDataValid	(s_ReadDataValid));
   
endmodule
// Local Variables:
// verilog-library-directories:("altpciexpav128" ".")
// verilog-library-files:(".""sata_phy")
// verilog-library-extensions:(".v" ".h")
// End:
// 
// altpcie_avl.v ends here
