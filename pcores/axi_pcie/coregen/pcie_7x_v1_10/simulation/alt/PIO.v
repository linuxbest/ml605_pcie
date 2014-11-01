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
      parameter pll_refclk_freq_hwtcl                             = "100 MHz";
      parameter enable_slot_register_hwtcl                        = 0;
      parameter port_type_hwtcl                                   = "Native endpoint";
      parameter bypass_cdc_hwtcl                                  = "false";
      parameter enable_rx_buffer_checking_hwtcl                   = "false";
      parameter single_rx_detect_hwtcl                            = 0;
      parameter use_crc_forwarding_hwtcl                          = 0;
      parameter ast_width_hwtcl                                   = "rx_tx_64";
      parameter gen123_lane_rate_mode_hwtcl                       = "gen1";
      parameter lane_mask_hwtcl                                   = "x4";
      parameter disable_link_x2_support_hwtcl                     = "false";
      parameter hip_hard_reset_hwtcl                              = 1;
      parameter enable_power_on_rst_pulse_hwtcl                   = 0;
      parameter enable_pcisigtest_hwtcl                           = 0;
      parameter wrong_device_id_hwtcl                             = "disable";
      parameter data_pack_rx_hwtcl                                = "disable";
      parameter use_ast_parity                                    = 0;
      parameter ltssm_1ms_timeout_hwtcl                           = "disable";
      parameter ltssm_freqlocked_check_hwtcl                      = "disable";
      parameter deskew_comma_hwtcl                                = "com_deskw";
      parameter port_link_number_hwtcl                            = 1;
      parameter device_number_hwtcl                               = 0;
      parameter bypass_clk_switch_hwtcl                           = "TRUE";
      parameter pipex1_debug_sel_hwtcl                            = "disable";
      parameter pclk_out_sel_hwtcl                                = "pclk";
      parameter vendor_id_hwtcl                                   = 4466;
      parameter device_id_hwtcl                                   = 57345;
      parameter revision_id_hwtcl                                 = 1;
      parameter class_code_hwtcl                                  = 16711680;
      parameter subsystem_vendor_id_hwtcl                         = 4466;
      parameter subsystem_device_id_hwtcl                         = 57345;
      parameter no_soft_reset_hwtcl                               = "false";
      parameter maximum_current_hwtcl                             = 0;
      parameter d1_support_hwtcl                                  = "false";
      parameter d2_support_hwtcl                                  = "false";
      parameter d0_pme_hwtcl                                      = "false";
      parameter d1_pme_hwtcl                                      = "false";
      parameter d2_pme_hwtcl                                      = "false";
      parameter d3_hot_pme_hwtcl                                  = "false";
      parameter d3_cold_pme_hwtcl                                 = "false";
      parameter use_aer_hwtcl                                     = 0;
      parameter low_priority_vc_hwtcl                             = "single_vc";
      parameter disable_snoop_packet_hwtcl                        = "false";
      parameter max_payload_size_hwtcl                            = 128;
      parameter surprise_down_error_support_hwtcl                 = 0;
      parameter dll_active_report_support_hwtcl                   = 0;
      parameter extend_tag_field_hwtcl                            = "false";
      parameter endpoint_l0_latency_hwtcl                         = 0;
      parameter endpoint_l1_latency_hwtcl                         = 0;
      parameter indicator_hwtcl                                   = 7;
      parameter slot_power_scale_hwtcl                            = 0;
      parameter enable_l1_aspm_hwtcl                              = "false";
      parameter l1_exit_latency_sameclock_hwtcl                   = 0;
      parameter l1_exit_latency_diffclock_hwtcl                   = 0;
      parameter hot_plug_support_hwtcl                            = 0;
      parameter slot_power_limit_hwtcl                            = 0;
      parameter slot_number_hwtcl                                 = 0;
      parameter diffclock_nfts_count_hwtcl                        = 0;
      parameter sameclock_nfts_count_hwtcl                        = 0;
      parameter completion_timeout_hwtcl                          = "abcd";
      parameter enable_completion_timeout_disable_hwtcl           = 1;
      parameter extended_tag_reset_hwtcl                          = "false";
      parameter ecrc_check_capable_hwtcl                          = 0;
      parameter ecrc_gen_capable_hwtcl                            = 0;
      parameter no_command_completed_hwtcl                        = "true";
      parameter msi_multi_message_capable_hwtcl                   = "count_4";
      parameter msi_64bit_addressing_capable_hwtcl                = "true";
      parameter msi_masking_capable_hwtcl                         = "false";
      parameter msi_support_hwtcl                                 = "true";
      parameter interrupt_pin_hwtcl                               = "inta";
      parameter enable_function_msix_support_hwtcl                = 0;
      parameter msix_table_size_hwtcl                             = 0;
      parameter msix_table_bir_hwtcl                              = 0;
      parameter msix_table_offset_hwtcl                           = "0";
      parameter msix_pba_bir_hwtcl                                = 0;
      parameter msix_pba_offset_hwtcl                             = "0";
      parameter bridge_port_vga_enable_hwtcl                      = "false";
      parameter bridge_port_ssid_support_hwtcl                    = "false";
      parameter ssvid_hwtcl                                       = 0;
      parameter ssid_hwtcl                                        = 0;
      parameter eie_before_nfts_count_hwtcl                       = 4;
      parameter gen2_diffclock_nfts_count_hwtcl                   = 255;
      parameter gen2_sameclock_nfts_count_hwtcl                   = 255;
      parameter deemphasis_enable_hwtcl                           = "false";
      parameter pcie_spec_version_hwtcl                           = "v2";
      parameter l0_exit_latency_sameclock_hwtcl                   = 6;
      parameter l0_exit_latency_diffclock_hwtcl                   = 6;
      parameter rx_ei_l0s_hwtcl                                   = 1;
      parameter l2_async_logic_hwtcl                              = "enable";
      parameter aspm_config_management_hwtcl                      = "true";
      parameter atomic_op_routing_hwtcl                           = "false";
      parameter atomic_op_completer_32bit_hwtcl                   = "false";
      parameter atomic_op_completer_64bit_hwtcl                   = "false";
      parameter cas_completer_128bit_hwtcl                        = "false";
      parameter ltr_mechanism_hwtcl                               = "false";
      parameter tph_completer_hwtcl                               = "false";
      parameter extended_format_field_hwtcl                       = "false";
      parameter atomic_malformed_hwtcl                            = "false";
      parameter flr_capability_hwtcl                              = "true";
      parameter enable_adapter_half_rate_mode_hwtcl               = "false";
      parameter vc0_clk_enable_hwtcl                              = "true";
      parameter register_pipe_signals_hwtcl                       = "false";
      parameter bar0_io_space_hwtcl                               = "Disabled";
      parameter bar0_64bit_mem_space_hwtcl                        = "Enabled";
      parameter bar0_prefetchable_hwtcl                           = "Enabled";
      parameter bar0_size_mask_hwtcl                              = "256 MBytes - 28 bits";
      parameter bar1_io_space_hwtcl                               = "Disabled";
      parameter bar1_64bit_mem_space_hwtcl                        = "Disabled";
      parameter bar1_prefetchable_hwtcl                           = "Disabled";
      parameter bar1_size_mask_hwtcl                              = "N/A";
      parameter bar2_io_space_hwtcl                               = "Disabled";
      parameter bar2_64bit_mem_space_hwtcl                        = "Disabled";
      parameter bar2_prefetchable_hwtcl                           = "Disabled";
      parameter bar2_size_mask_hwtcl                              = "N/A";
      parameter bar3_io_space_hwtcl                               = "Disabled";
      parameter bar3_64bit_mem_space_hwtcl                        = "Disabled";
      parameter bar3_prefetchable_hwtcl                           = "Disabled";
      parameter bar3_size_mask_hwtcl                              = "N/A";
      parameter bar4_io_space_hwtcl                               = "Disabled";
      parameter bar4_64bit_mem_space_hwtcl                        = "Disabled";
      parameter bar4_prefetchable_hwtcl                           = "Disabled";
      parameter bar4_size_mask_hwtcl                              = "N/A";
      parameter bar5_io_space_hwtcl                               = "Disabled";
      parameter bar5_64bit_mem_space_hwtcl                        = "Disabled";
      parameter bar5_prefetchable_hwtcl                           = "Disabled";
      parameter bar5_size_mask_hwtcl                              = "N/A";
      parameter expansion_base_address_register_hwtcl             = 0;
      parameter io_window_addr_width_hwtcl                        = "window_32_bit";
      parameter prefetchable_mem_window_addr_width_hwtcl          = "prefetch_32";
      parameter skp_os_gen3_count_hwtcl                           = 0;
      parameter tx_cdc_almost_empty_hwtcl                         = 5;
      parameter rx_cdc_almost_full_hwtcl                          = 6;
      parameter tx_cdc_almost_full_hwtcl                          = 6;
      parameter rx_l0s_count_idl_hwtcl                            = 0;
      parameter cdc_dummy_insert_limit_hwtcl                      = 11;
      parameter ei_delay_powerdown_count_hwtcl                    = 10;
      parameter millisecond_cycle_count_hwtcl                     = 0;
      parameter skp_os_schedule_count_hwtcl                       = 0;
      parameter fc_init_timer_hwtcl                               = 1024;
      parameter l01_entry_latency_hwtcl                           = 31;
      parameter flow_control_update_count_hwtcl                   = 30;
      parameter flow_control_timeout_count_hwtcl                  = 200;
      parameter credit_buffer_allocation_aux_hwtcl                = "balanced";
      parameter vc0_rx_flow_ctrl_posted_header_hwtcl              = 50;
      parameter vc0_rx_flow_ctrl_posted_data_hwtcl                = 360;
      parameter vc0_rx_flow_ctrl_nonposted_header_hwtcl           = 54;
      parameter vc0_rx_flow_ctrl_nonposted_data_hwtcl             = 0;
      parameter vc0_rx_flow_ctrl_compl_header_hwtcl               = 112;
      parameter vc0_rx_flow_ctrl_compl_data_hwtcl                 = 448;
      parameter rx_ptr0_posted_dpram_min_hwtcl                    = 0;
      parameter rx_ptr0_posted_dpram_max_hwtcl                    = 0;
      parameter rx_ptr0_nonposted_dpram_min_hwtcl                 = 0;
      parameter rx_ptr0_nonposted_dpram_max_hwtcl                 = 0;
      parameter retry_buffer_last_active_address_hwtcl            = 2047;
      parameter retry_buffer_memory_settings_hwtcl                = 0;
      parameter vc0_rx_buffer_memory_settings_hwtcl               = 0;
      parameter in_cvp_mode_hwtcl                                 = 0;
      parameter slotclkcfg_hwtcl                                  = 1;
      parameter reconfig_to_xcvr_width                            = 350;
      parameter set_pld_clk_x1_625MHz_hwtcl                       = 0;
      parameter reconfig_from_xcvr_width                          = 230;
      parameter enable_l0s_aspm_hwtcl                             = "true";
      parameter cpl_spc_header_hwtcl                              = 195;
      parameter cpl_spc_data_hwtcl                                = 781;
      parameter port_width_be_hwtcl                               = 8;
      parameter port_width_data_hwtcl                             = 64;
      parameter reserved_debug_hwtcl                              = 0;
      parameter hip_reconfig_hwtcl                                = 0;
      parameter vsec_id_hwtcl                                     = 0;
      parameter vsec_rev_hwtcl                                    = 0;
      parameter gen3_rxfreqlock_counter_hwtcl                     = 0;
      parameter gen3_skip_ph2_ph3_hwtcl                           = 1;
      parameter g3_bypass_equlz_hwtcl                             = 1;
      parameter enable_tl_only_sim_hwtcl                          = 0;
      parameter use_atx_pll_hwtcl                                 = 0;
      parameter cvp_rate_sel_hwtcl                                = "full_rate";
      parameter cvp_data_compressed_hwtcl                         = "false";
      parameter cvp_data_encrypted_hwtcl                          = "false";
      parameter cvp_mode_reset_hwtcl                              = "false";
      parameter cvp_clk_reset_hwtcl                               = "false";
      parameter cseb_cpl_status_during_cvp_hwtcl                  = "config_retry_status";
      parameter core_clk_sel_hwtcl                                = "pld_clk";
      parameter g3_dis_rx_use_prst_hwtcl                          = "true";
      parameter g3_dis_rx_use_prst_ep_hwtcl                       = "false";

      parameter hwtcl_override_g2_txvod                           = 0; // When 1 use gen3 param from HWTCL; else use default
      parameter rpre_emph_a_val_hwtcl                             = 9 ;
      parameter rpre_emph_b_val_hwtcl                             = 0 ;
      parameter rpre_emph_c_val_hwtcl                             = 16;
      parameter rpre_emph_d_val_hwtcl                             = 11;
      parameter rpre_emph_e_val_hwtcl                             = 5 ;
      parameter rvod_sel_a_val_hwtcl                              = 42;
      parameter rvod_sel_b_val_hwtcl                              = 38;
      parameter rvod_sel_c_val_hwtcl                              = 38;
      parameter rvod_sel_d_val_hwtcl                              = 38;
      parameter rvod_sel_e_val_hwtcl                              = 15;


      /// Bridge Parameters
      parameter CG_ENABLE_A2P_INTERRUPT = 0;
      parameter CG_ENABLE_ADVANCED_INTERRUPT = 0;
      parameter CG_RXM_IRQ_NUM = 16;
      parameter CB_PCIE_MODE   = 0;
      parameter CB_PCIE_RX_LITE = 0;
      parameter CB_A2P_ADDR_MAP_IS_FIXED = 0;
      parameter CB_A2P_ADDR_MAP_NUM_ENTRIES = 2;
      parameter CG_AVALON_S_ADDR_WIDTH = 24;
      parameter CG_IMPL_CRA_AV_SLAVE_PORT = 1;
      parameter a2p_pass_thru_bits = 24;
      parameter CB_P2A_AVALON_ADDR_B0               = 32'h00000000;
      parameter CB_P2A_AVALON_ADDR_B1               = 32'h00000000;
      parameter CB_P2A_AVALON_ADDR_B2               = 32'h00000000;
      parameter CB_P2A_AVALON_ADDR_B3               = 32'h00000000;
      parameter CB_P2A_AVALON_ADDR_B4               = 32'h00000000;
      parameter CB_P2A_AVALON_ADDR_B5               = 32'h00000000;
      parameter CB_P2A_AVALON_ADDR_B6               = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_0_LOW   = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_0_HIGH  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_1_LOW   = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_1_HIGH  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_2_LOW   = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_2_HIGH  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_3_LOW   = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_3_HIGH  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_4_LOW   = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_4_HIGH  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_5_LOW   = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_5_HIGH  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_6_LOW   = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_6_HIGH  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_7_LOW   = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_7_HIGH  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_8_LOW   = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_8_HIGH  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_9_LOW   = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_9_HIGH  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_10_LOW  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_10_HIGH = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_11_LOW  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_11_HIGH = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_12_LOW  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_12_HIGH = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_13_LOW  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_13_HIGH = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_14_LOW  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_14_HIGH = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_15_LOW  = 32'h00000000;
      parameter CB_A2P_ADDR_MAP_FIXED_TABLE_15_HIGH = 32'h00000000;
      parameter bar_prefetchable = 1;
      parameter avmm_width_hwtcl = 64;
      parameter avmm_burst_width_hwtcl = 7;
      parameter CB_RXM_DATA_WIDTH = 128;
      parameter AVALON_ADDR_WIDTH = 32;
      parameter BYPASSS_A2P_TRANSLATION = 0;

// Exposed parameters
localparam ast_width                                     = (ast_width_hwtcl=="Avalon-ST 256-bit")?"rx_tx_256":(ast_width_hwtcl=="Avalon-ST 128-bit")?"rx_tx_128":"rx_tx_64";// String  : "rx_tx_64";

localparam bar0_io_space                                 = (bar0_io_space_hwtcl        == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar0_64bit_mem_space                          = (bar0_64bit_mem_space_hwtcl == "Enabled")?"true":"false"            ;// String  : "true";
localparam bar0_prefetchable                             = (bar0_prefetchable_hwtcl    == "Enabled")?"true":"false"            ;// String  : "true";
localparam bar0_size_mask                                = bar0_size_mask_hwtcl                                                ;// String  : "256 MBytes - 28 bits";
localparam bar1_io_space                                 = (bar1_io_space_hwtcl        == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar1_64bit_mem_space                          = (bar1_64bit_mem_space_hwtcl == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar1_prefetchable                             = (bar1_prefetchable_hwtcl    == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar1_size_mask                                = bar1_size_mask_hwtcl                                                ;// String  : "N/A";
localparam bar2_io_space                                 = (bar2_io_space_hwtcl        == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar2_64bit_mem_space                          = (bar2_64bit_mem_space_hwtcl == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar2_prefetchable                             = (bar2_prefetchable_hwtcl    == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar2_size_mask                                = bar2_size_mask_hwtcl                                                ;// String  : "N/A";
localparam bar3_io_space                                 = (bar3_io_space_hwtcl        == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar3_64bit_mem_space                          = (bar3_64bit_mem_space_hwtcl == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar3_prefetchable                             = (bar3_prefetchable_hwtcl    == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar3_size_mask                                = bar3_size_mask_hwtcl                                                ;// String  : "N/A";
localparam bar4_io_space                                 = (bar4_io_space_hwtcl        == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar4_64bit_mem_space                          = (bar4_64bit_mem_space_hwtcl == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar4_prefetchable                             = (bar4_prefetchable_hwtcl    == "Enabled")?"true":"false"            ;// String  : "false";
localparam bar4_size_mask                                = bar4_size_mask_hwtcl                                                ;// String  : "N/A";
localparam bar5_io_space                                 = (bar5_io_space_hwtcl         == "Enabled")?"true":"false"           ;// String  : "false";
localparam bar5_64bit_mem_space                          = (bar5_64bit_mem_space_hwtcl  == "Enabled")?"true":"false"           ;// String  : "false";
localparam bar5_prefetchable                             = (bar5_prefetchable_hwtcl     == "Enabled")?"true":"false"           ;// String  : "false";
localparam bar5_size_mask                                = bar5_size_mask_hwtcl                                                ;// String  : "N/A";
localparam bar_io_window_size                            = 0;

localparam expansion_base_address_register               = expansion_base_address_register_hwtcl                     ;// String  : 32'b0;


// Not visible parameters
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

   /*AUTOINPUT*/
   /*AUTOOUTPUT*/
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			AvlClk_i;		// From tb of tb.v
   wire [3:0]		CfgAddr_i;		// From tb of tb.v
   wire			CfgCtlWr_i;		// From tb of tb.v
   wire [31:0]		CfgCtl_i;		// From tb of tb.v
   wire			CplPending_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire [13:2]		CraAddress_i;		// From tb of tb.v
   wire [3:0]		CraByteEnable_i;	// From tb of tb.v
   wire			CraChipSelect_i;	// From tb of tb.v
   wire			CraClk_i;		// From tb of tb.v
   wire			CraIrq_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			CraRead;		// From tb of tb.v
   wire [31:0]		CraReadData_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			CraRstn_i;		// From tb of tb.v
   wire			CraWaitRequest_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire			CraWrite;		// From tb of tb.v
   wire [31:0]		CraWriteData_i;		// From tb of tb.v
   wire			IntxAck_i;		// From tb of tb.v
   wire			IntxReq_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			MsiAck_i;		// From tb of tb.v
   wire [15:0]		MsiControl_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire [81:0]		MsiIntfc_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire [4:0]		MsiNum_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			MsiReq_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire [2:0]		MsiTc_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire [15:0]		MsixIntfc_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			Rstn_i;			// From tb of tb.v
   wire [3:0]		RxIntStatus_i;		// From tb of tb.v
   wire [7:0]		RxStBarDec1_i;		// From tb of tb.v
   wire [7:0]		RxStBarDec2_i;		// From tb of tb.v
   wire [15:0]		RxStBe_i;		// From tb of tb.v
   wire [127:0]		RxStData_i;		// From tb of tb.v
   wire [1:0]		RxStEmpty_i;		// From tb of tb.v
   wire			RxStEop_i;		// From tb of tb.v
   wire			RxStErr_i;		// From tb of tb.v
   wire			RxStMask_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxStReady_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxStSop_i;		// From tb of tb.v
   wire			RxStValid_i;		// From tb of tb.v
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
   wire [CG_RXM_IRQ_NUM-1:0] RxmIrq_i;		// From tb of tb.v
   wire			RxmReadDataValid_0_i;	// From tb of tb.v
   wire			RxmReadDataValid_1_i;	// From tb of tb.v
   wire			RxmReadDataValid_2_i;	// From tb of tb.v
   wire			RxmReadDataValid_3_i;	// From tb of tb.v
   wire			RxmReadDataValid_4_i;	// From tb of tb.v
   wire			RxmReadDataValid_5_i;	// From tb of tb.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmReadData_0_i;// From tb of tb.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmReadData_1_i;// From tb of tb.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmReadData_2_i;// From tb of tb.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmReadData_3_i;// From tb of tb.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmReadData_4_i;// From tb of tb.v
   wire [CB_RXM_DATA_WIDTH-1:0] RxmReadData_5_i;// From tb of tb.v
   wire			RxmRead_0_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmRead_1_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmRead_2_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmRead_3_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmRead_4_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmRead_5_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			RxmWaitRequest_0_i;	// From tb of tb.v
   wire			RxmWaitRequest_1_i;	// From tb of tb.v
   wire			RxmWaitRequest_2_i;	// From tb of tb.v
   wire			RxmWaitRequest_3_i;	// From tb of tb.v
   wire			RxmWaitRequest_4_i;	// From tb of tb.v
   wire			RxmWaitRequest_5_i;	// From tb of tb.v
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
   wire			TxAdapterFifoEmpty_i;	// From tb of tb.v
   wire [11:0]		TxCredCplDataLimit_i;	// From tb of tb.v
   wire [7:0]		TxCredCplHdrLimit_i;	// From tb of tb.v
   wire [5:0]		TxCredHipCons_i;	// From tb of tb.v
   wire [5:0]		TxCredInfinit_i;	// From tb of tb.v
   wire [11:0]		TxCredNpDataLimit_i;	// From tb of tb.v
   wire [7:0]		TxCredNpHdrLimit_i;	// From tb of tb.v
   wire [11:0]		TxCredPDataLimit_i;	// From tb of tb.v
   wire [7:0]		TxCredPHdrLimit_i;	// From tb of tb.v
   wire [127:0]		TxStData_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire [1:0]		TxStEmpty_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			TxStEop_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			TxStReady_i;		// From tb of tb.v
   wire			TxStSop_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			TxStValid_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire [CG_AVALON_S_ADDR_WIDTH-1:0] TxsAddress_i;// From tb of tb.v
   wire [5:0]		TxsBurstCount_i;	// From tb of tb.v
   wire [15:0]		TxsByteEnable_i;	// From tb of tb.v
   wire			TxsChipSelect_i;	// From tb of tb.v
   wire			TxsClk_i;		// From tb of tb.v
   wire			TxsReadDataValid_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [127:0]		TxsReadData_o;		// From altpciexpav128_app of altpciexpav128_app.v
   wire			TxsRead_i;		// From tb of tb.v
   wire			TxsRstn_i;		// From tb of tb.v
   wire			TxsWaitRequest_o;	// From altpciexpav128_app of altpciexpav128_app.v
   wire [127:0]		TxsWriteData_i;		// From tb of tb.v
   wire			TxsWrite_i;		// From tb of tb.v
   wire [1:0]		current_speed;		// From tb of tb.v
   wire [11:0]		ko_cpl_spc_data;	// From tb of tb.v
   wire [7:0]		ko_cpl_spc_header;	// From tb of tb.v
   wire [3:0]		lane_act;		// From tb of tb.v
   wire [4:0]		ltssm_state;		// From tb of tb.v
   wire			pld_clk_inuse;		// From tb of tb.v
   wire			tx_cons_cred_sel;	// From altpciexpav128_app of altpciexpav128_app.v
   // End of automatics
  
   parameter CG_COMMON_CLOCK_MODE = 1;
   parameter CB_A2P_PERF_PROFILE  = 3;
   parameter CB_P2A_PERF_PROFILE  = 3;
   parameter EXTERNAL_A2P_TRANS   = 0;
   parameter NUM_PREFETCH_MASTERS = 1;
   parameter CB_A2P_ADDR_MAP_PASS_THRU_BITS = 20;

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
			.BYPASSS_A2P_TRANSLATION(BYPASSS_A2P_TRANSLATION))
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
			.lane_act	(lane_act[3:0]));

   tb #(/*AUTOINSTPARAM*/
	// Parameters
	.CB_RXM_DATA_WIDTH		(CB_RXM_DATA_WIDTH),
	.AVALON_ADDR_WIDTH		(AVALON_ADDR_WIDTH),
	.CG_RXM_IRQ_NUM			(CG_RXM_IRQ_NUM),
	.CG_AVALON_S_ADDR_WIDTH		(CG_AVALON_S_ADDR_WIDTH))
   tb  (/*AUTOINST*/
	// Outputs
	.AvlClk_i			(AvlClk_i),
	.Rstn_i				(Rstn_i),
	.RxStData_i			(RxStData_i[127:0]),
	.RxStBe_i			(RxStBe_i[15:0]),
	.RxStEmpty_i			(RxStEmpty_i[1:0]),
	.RxStErr_i			(RxStErr_i),
	.RxStSop_i			(RxStSop_i),
	.RxStEop_i			(RxStEop_i),
	.RxStValid_i			(RxStValid_i),
	.RxStBarDec1_i			(RxStBarDec1_i[7:0]),
	.RxStBarDec2_i			(RxStBarDec2_i[7:0]),
	.TxStReady_i			(TxStReady_i),
	.TxAdapterFifoEmpty_i		(TxAdapterFifoEmpty_i),
	.TxCredPDataLimit_i		(TxCredPDataLimit_i[11:0]),
	.TxCredNpDataLimit_i		(TxCredNpDataLimit_i[11:0]),
	.TxCredCplDataLimit_i		(TxCredCplDataLimit_i[11:0]),
	.TxCredHipCons_i		(TxCredHipCons_i[5:0]),
	.TxCredInfinit_i		(TxCredInfinit_i[5:0]),
	.TxCredPHdrLimit_i		(TxCredPHdrLimit_i[7:0]),
	.TxCredNpHdrLimit_i		(TxCredNpHdrLimit_i[7:0]),
	.TxCredCplHdrLimit_i		(TxCredCplHdrLimit_i[7:0]),
	.ko_cpl_spc_header		(ko_cpl_spc_header[7:0]),
	.ko_cpl_spc_data		(ko_cpl_spc_data[11:0]),
	.CfgCtlWr_i			(CfgCtlWr_i),
	.CfgAddr_i			(CfgAddr_i[3:0]),
	.CfgCtl_i			(CfgCtl_i[31:0]),
	.MsiAck_i			(MsiAck_i),
	.IntxAck_i			(IntxAck_i),
	.TxsClk_i			(TxsClk_i),
	.TxsRstn_i			(TxsRstn_i),
	.TxsChipSelect_i		(TxsChipSelect_i),
	.TxsRead_i			(TxsRead_i),
	.TxsWrite_i			(TxsWrite_i),
	.TxsWriteData_i			(TxsWriteData_i[127:0]),
	.TxsBurstCount_i		(TxsBurstCount_i[5:0]),
	.TxsAddress_i			(TxsAddress_i[CG_AVALON_S_ADDR_WIDTH-1:0]),
	.TxsByteEnable_i		(TxsByteEnable_i[15:0]),
	.RxmWaitRequest_0_i		(RxmWaitRequest_0_i),
	.RxmReadData_0_i		(RxmReadData_0_i[CB_RXM_DATA_WIDTH-1:0]),
	.RxmReadDataValid_0_i		(RxmReadDataValid_0_i),
	.RxmWaitRequest_1_i		(RxmWaitRequest_1_i),
	.RxmReadData_1_i		(RxmReadData_1_i[CB_RXM_DATA_WIDTH-1:0]),
	.RxmReadDataValid_1_i		(RxmReadDataValid_1_i),
	.RxmWaitRequest_2_i		(RxmWaitRequest_2_i),
	.RxmReadData_2_i		(RxmReadData_2_i[CB_RXM_DATA_WIDTH-1:0]),
	.RxmReadDataValid_2_i		(RxmReadDataValid_2_i),
	.RxmWaitRequest_3_i		(RxmWaitRequest_3_i),
	.RxmReadData_3_i		(RxmReadData_3_i[CB_RXM_DATA_WIDTH-1:0]),
	.RxmReadDataValid_3_i		(RxmReadDataValid_3_i),
	.RxmWaitRequest_4_i		(RxmWaitRequest_4_i),
	.RxmReadData_4_i		(RxmReadData_4_i[CB_RXM_DATA_WIDTH-1:0]),
	.RxmReadDataValid_4_i		(RxmReadDataValid_4_i),
	.RxmWaitRequest_5_i		(RxmWaitRequest_5_i),
	.RxmReadData_5_i		(RxmReadData_5_i[CB_RXM_DATA_WIDTH-1:0]),
	.RxmReadDataValid_5_i		(RxmReadDataValid_5_i),
	.RxmIrq_i			(RxmIrq_i[CG_RXM_IRQ_NUM-1:0]),
	.CraClk_i			(CraClk_i),
	.CraRstn_i			(CraRstn_i),
	.CraChipSelect_i		(CraChipSelect_i),
	.CraRead			(CraRead),
	.CraWrite			(CraWrite),
	.CraWriteData_i			(CraWriteData_i[31:0]),
	.CraAddress_i			(CraAddress_i[13:2]),
	.CraByteEnable_i		(CraByteEnable_i[3:0]),
	.RxIntStatus_i			(RxIntStatus_i[3:0]),
	.pld_clk_inuse			(pld_clk_inuse),
	.ltssm_state			(ltssm_state[4:0]),
	.current_speed			(current_speed[1:0]),
	.lane_act			(lane_act[3:0]),
	.s_axis_tx_tdata		(s_axis_tx_tdata[127:0]),
	.s_axis_tx_tkeep		(s_axis_tx_tkeep[15:0]),
	.s_axis_tx_tlast		(s_axis_tx_tlast),
	.s_axis_tx_tvalid		(s_axis_tx_tvalid),
	.tx_src_dsc			(tx_src_dsc),
	.m_axis_rx_tready		(m_axis_rx_tready),
	.cfg_turnoff_ok			(cfg_turnoff_ok),
	// Inputs
	.RxStReady_o			(RxStReady_o),
	.RxStMask_o			(RxStMask_o),
	.TxStData_o			(TxStData_o[127:0]),
	.TxStSop_o			(TxStSop_o),
	.TxStEop_o			(TxStEop_o),
	.TxStEmpty_o			(TxStEmpty_o[1:0]),
	.TxStValid_o			(TxStValid_o),
	.CplPending_o			(CplPending_o),
	.MsiReq_o			(MsiReq_o),
	.MsiTc_o			(MsiTc_o[2:0]),
	.MsiNum_o			(MsiNum_o[4:0]),
	.IntxReq_o			(IntxReq_o),
	.TxsReadDataValid_o		(TxsReadDataValid_o),
	.TxsReadData_o			(TxsReadData_o[127:0]),
	.TxsWaitRequest_o		(TxsWaitRequest_o),
	.RxmWrite_0_o			(RxmWrite_0_o),
	.RxmAddress_0_o			(RxmAddress_0_o[AVALON_ADDR_WIDTH-1:0]),
	.RxmWriteData_0_o		(RxmWriteData_0_o[CB_RXM_DATA_WIDTH-1:0]),
	.RxmByteEnable_0_o		(RxmByteEnable_0_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
	.RxmBurstCount_0_o		(RxmBurstCount_0_o[6:0]),
	.RxmRead_0_o			(RxmRead_0_o),
	.RxmWrite_1_o			(RxmWrite_1_o),
	.RxmAddress_1_o			(RxmAddress_1_o[AVALON_ADDR_WIDTH-1:0]),
	.RxmWriteData_1_o		(RxmWriteData_1_o[CB_RXM_DATA_WIDTH-1:0]),
	.RxmByteEnable_1_o		(RxmByteEnable_1_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
	.RxmBurstCount_1_o		(RxmBurstCount_1_o[6:0]),
	.RxmRead_1_o			(RxmRead_1_o),
	.RxmWrite_2_o			(RxmWrite_2_o),
	.RxmAddress_2_o			(RxmAddress_2_o[AVALON_ADDR_WIDTH-1:0]),
	.RxmWriteData_2_o		(RxmWriteData_2_o[CB_RXM_DATA_WIDTH-1:0]),
	.RxmByteEnable_2_o		(RxmByteEnable_2_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
	.RxmBurstCount_2_o		(RxmBurstCount_2_o[6:0]),
	.RxmRead_2_o			(RxmRead_2_o),
	.RxmWrite_3_o			(RxmWrite_3_o),
	.RxmAddress_3_o			(RxmAddress_3_o[AVALON_ADDR_WIDTH-1:0]),
	.RxmWriteData_3_o		(RxmWriteData_3_o[CB_RXM_DATA_WIDTH-1:0]),
	.RxmByteEnable_3_o		(RxmByteEnable_3_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
	.RxmBurstCount_3_o		(RxmBurstCount_3_o[6:0]),
	.RxmRead_3_o			(RxmRead_3_o),
	.RxmWrite_4_o			(RxmWrite_4_o),
	.RxmAddress_4_o			(RxmAddress_4_o[AVALON_ADDR_WIDTH-1:0]),
	.RxmWriteData_4_o		(RxmWriteData_4_o[CB_RXM_DATA_WIDTH-1:0]),
	.RxmByteEnable_4_o		(RxmByteEnable_4_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
	.RxmBurstCount_4_o		(RxmBurstCount_4_o[6:0]),
	.RxmRead_4_o			(RxmRead_4_o),
	.RxmWrite_5_o			(RxmWrite_5_o),
	.RxmAddress_5_o			(RxmAddress_5_o[AVALON_ADDR_WIDTH-1:0]),
	.RxmWriteData_5_o		(RxmWriteData_5_o[CB_RXM_DATA_WIDTH-1:0]),
	.RxmByteEnable_5_o		(RxmByteEnable_5_o[(CB_RXM_DATA_WIDTH/8)-1:0]),
	.RxmBurstCount_5_o		(RxmBurstCount_5_o[6:0]),
	.RxmRead_5_o			(RxmRead_5_o),
	.CraReadData_o			(CraReadData_o[31:0]),
	.CraWaitRequest_o		(CraWaitRequest_o),
	.CraIrq_o			(CraIrq_o),
	.MsiIntfc_o			(MsiIntfc_o[81:0]),
	.MsiControl_o			(MsiControl_o[15:0]),
	.MsixIntfc_o			(MsixIntfc_o[15:0]),
	.tx_cons_cred_sel		(tx_cons_cred_sel),
	.user_clk			(user_clk),
	.user_reset			(user_reset),
	.user_lnk_up			(user_lnk_up),
	.s_axis_tx_tready		(s_axis_tx_tready),
	.m_axis_rx_tdata		(m_axis_rx_tdata[127:0]),
	.m_axis_rx_tkeep		(m_axis_rx_tkeep[15:0]),
	.m_axis_rx_tlast		(m_axis_rx_tlast),
	.m_axis_rx_tvalid		(m_axis_rx_tvalid),
	.m_axis_rx_tuser		(m_axis_rx_tuser[21:0]),
	.cfg_to_turnoff			(cfg_to_turnoff),
	.cfg_completer_id		(cfg_completer_id[15:0]));
endmodule // PIO
