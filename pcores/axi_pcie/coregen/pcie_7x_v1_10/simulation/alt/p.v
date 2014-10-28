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
      parameter max_payload_size_hwtcl                            = 256;
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
      parameter CB_A2P_ADDR_MAP_NUM_ENTRIES = 1;
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
      parameter CB_RXM_DATA_WIDTH = 64;
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

localparam CB_A2P_ADDR_MAP_FIXED_TABLE_INT = { CB_A2P_ADDR_MAP_FIXED_TABLE_15_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_15_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_14_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_14_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_13_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_13_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_12_HIGH,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_12_LOW,
                                               CB_A2P_ADDR_MAP_FIXED_TABLE_11_HIGH;
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

