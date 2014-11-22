`timescale 1ns / 1ps

module k7_tlp (/*AUTOARG*/
   // Outputs
   pci_exp_txp, pci_exp_txn, mmcm_lock, user_clk, user_reset,
   user_link_up, tx_buf_av, s_axis_tx_tready, m_axis_rx_tdata,
   m_axis_rx_tkeep, m_axis_rx_tlast, m_axis_rx_tvalid,
   m_axis_rx_tuser, fc_cpld, fc_cplh, fc_npd, fc_nph, fc_pd, fc_ph,
   cfg_to_turnoff, cfg_completer_id,
   // Inputs
   pci_exp_rxp, pci_exp_rxn, REFCLK, sys_rst_n, s_axis_tx_tuser,
   s_axis_tx_tdata, s_axis_tx_tkeep, s_axis_tx_tlast,
   s_axis_tx_tvalid, m_axis_rx_tready, fc_sel, cfg_turnoff_ok
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
   
   output  [C_NO_OF_LANES-1:0]    pci_exp_txp;
   output  [C_NO_OF_LANES-1:0]    pci_exp_txn;
   input [C_NO_OF_LANES-1:0] 	  pci_exp_rxp;
   input [C_NO_OF_LANES-1:0] 	  pci_exp_rxn;
   
   input 	    REFCLK;
   input 	    sys_rst_n;
   output           mmcm_lock; 
   
   output 	    user_clk;
   output 	    user_reset;
   output 	    user_link_up;
   
   // Tx
   output [5:0]     tx_buf_av;
   output 	    s_axis_tx_tready;
   input [3:0] 	    s_axis_tx_tuser;
   input [C_DATA_WIDTH-1:0] s_axis_tx_tdata;
   input [KEEP_WIDTH-1:0]   s_axis_tx_tkeep;
   input 		    s_axis_tx_tlast;
   input 		    s_axis_tx_tvalid;
   
   // Rx
   output [C_DATA_WIDTH-1:0] m_axis_rx_tdata;
   output [KEEP_WIDTH-1:0]   m_axis_rx_tkeep;
   output 		     m_axis_rx_tlast;
   output 		     m_axis_rx_tvalid;
   input 		     m_axis_rx_tready;
   output [21:0] 	     m_axis_rx_tuser;
   
   // Flow Control
   output [11:0] 	     fc_cpld;
   output [7:0] 	     fc_cplh;
   output [11:0] 	     fc_npd;
   output [7:0] 	     fc_nph;
   output [11:0] 	     fc_pd;
   output [7:0] 	     fc_ph;
   input [2:0] 		     fc_sel;
   
   output                    cfg_to_turnoff;
   input                     cfg_turnoff_ok;
   
   localparam  TCQ = 1;
   wire 		    tx_cfg_gnt;
   wire 		    tx_cfg_req;
   wire 		    tx_err_drop;
   wire 		    rx_np_ok;
   wire 		    rx_np_req;
  //-------------------------------------------------------
  // 3. Configuration (CFG) Interface
  //-------------------------------------------------------
  wire                                        cfg_err_cor;
  wire                                        cfg_err_ur;
  wire                                        cfg_err_ecrc;
  wire                                        cfg_err_cpl_timeout;
  wire                                        cfg_err_cpl_abort;
  wire                                        cfg_err_cpl_unexpect;
  wire                                        cfg_err_posted;
  wire                                        cfg_err_locked;
  wire  [47:0]                                cfg_err_tlp_cpl_header;
//  wire                                        cfg_err_cpl_rdy;
  wire                                        cfg_interrupt;
//  wire                                        cfg_interrupt_rdy;
  wire                                        cfg_interrupt_assert;
  wire   [7:0]                                cfg_interrupt_di;
//  wire   [7:0]                                cfg_interrupt_do;
//  wire   [2:0]                                cfg_interrupt_mmenable;
//  wire                                        cfg_interrupt_msienable;
//  wire                                        cfg_interrupt_msixenable;
//  wire                                        cfg_interrupt_msixfm;
  wire                                        cfg_interrupt_stat;
  wire   [4:0]                                cfg_pciecap_interrupt_msgnum;
//  wire                                        cfg_turnoff_ok;
//  wire                                        cfg_to_turnoff;
  wire                                        cfg_trn_pending;
  wire                                        cfg_pm_halt_aspm_l0s;
  wire                                        cfg_pm_halt_aspm_l1;
  wire                                        cfg_pm_force_state_en;
  wire   [1:0]                                cfg_pm_force_state;
  wire                                        cfg_pm_wake;
  wire   [7:0]                                cfg_bus_number;
  wire   [4:0]                                cfg_device_number;
  wire   [2:0]                                cfg_function_number;
//  wire  [15:0]                                cfg_status;
//  wire  [15:0]                                cfg_command;
//  wire  [15:0]                                cfg_dcommand;
//  wire  [15:0]                                cfg_lcommand;
//  wire  [15:0]                                cfg_dcommand2;
  wire  [63:0]                                cfg_dsn;
  wire [127:0]                                cfg_err_aer_headerlog;
  wire   [4:0]                                cfg_aer_interrupt_msgnum;
//  wire                                        cfg_err_aer_headerlog_set;
//  wire                                        cfg_aer_ecrc_check_en;
//  wire                                        cfg_aer_ecrc_gen_en;

  wire  [31:0]                                cfg_mgmt_di;
  wire   [3:0]                                cfg_mgmt_byte_en;
  wire   [9:0]                                cfg_mgmt_dwaddr;
  wire                                        cfg_mgmt_wr_en;
  wire                                        cfg_mgmt_rd_en;
  wire                                        cfg_mgmt_wr_readonly;


  //-------------------------------------------------------
  // 4. Physical Layer Control and Status (PL) Interface
  //-------------------------------------------------------

//  wire [2:0]                                  pl_initial_link_width;
//  wire [1:0]                                  pl_lane_reversal_mode;
//  wire                                        pl_link_gen2_cap;
//  wire                                        pl_link_partner_gen2_supported;
//  wire                                        pl_link_upcfg_cap;
//  wire                                        pl_received_hot_rst;
//  wire                                        pl_sel_lnk_rate;
//  wire [1:0]                                  pl_sel_lnk_width;
  wire                                        pl_directed_link_auton;
  wire [1:0]                                  pl_directed_link_change;
  wire                                        pl_directed_link_speed;
  wire [1:0]                                  pl_directed_link_width;
  wire                                        pl_upstream_prefer_deemph;

  // Wires used for external clocking connectivity
  wire                                        PIPE_PCLK_IN;
  wire                                        PIPE_RXUSRCLK_IN;
  wire   [7:0]   PIPE_RXOUTCLK_IN;
  wire                                        PIPE_DCLK_IN;
  wire                                        PIPE_USERCLK1_IN;
  wire                                        PIPE_USERCLK2_IN;
  wire                                        PIPE_MMCM_LOCK_IN;
  assign mmcm_lock = 1'b1; /* TODO */

  wire                                        PIPE_TXOUTCLK_OUT;
  wire [7:0]     PIPE_RXOUTCLK_OUT;

  wire [7:0]     PIPE_PCLK_SEL_OUT;
  wire                                        PIPE_GEN3_OUT;
 
  wire                                        PIPE_OOBCLK_IN;

 
  localparam USER_CLK_FREQ = 4;
  localparam USER_CLK2_DIV2 = "TRUE";
  localparam USERCLK2_FREQ = (USER_CLK2_DIV2 == "TRUE") ?
                             (USER_CLK_FREQ == 4) ? 3 :
                             (USER_CLK_FREQ == 3) ? 2 : USER_CLK_FREQ :
                             USER_CLK_FREQ;
  //-------------------------------------------------------
  wire sys_clk;
  assign sys_clk = REFCLK;


  reg user_reset_q;
  reg user_lnk_up_q;
  reg PIPE_MMCM_RST_N = 1'b1;

  always @(posedge user_clk) begin
    user_reset_q  <= user_reset;
    user_lnk_up_q <= user_link_up;
  end



 
  // Generate External Clock Module if External Clocking is selected
  generate
    if (PCIE_EXT_CLK == "TRUE") begin : ext_clk

      //---------- PIPE Clock Module -------------------------------------------------
      pcie_7x_v1_10_pipe_clock #
      (
          .PCIE_ASYNC_EN                  ( "FALSE" ),     // PCIe async enable
          .PCIE_TXBUF_EN                  ( "FALSE" ),     // PCIe TX buffer enable for Gen1/Gen2 only
          .PCIE_LANE                      ( C_NO_OF_LANES ),     // PCIe number of lanes
          // synthesis translate_off
          .PCIE_LINK_SPEED                ( 2 ),
          // synthesis translate_on
          .PCIE_REFCLK_FREQ               ( 0 ),     // PCIe reference clock frequency
          .PCIE_USERCLK1_FREQ             ( USER_CLK_FREQ +1 ),     // PCIe user clock 1 frequency
          .PCIE_USERCLK2_FREQ             ( USERCLK2_FREQ +1 ),     // PCIe user clock 2 frequency
          .PCIE_DEBUG_MODE                ( 0 )
      )
      pipe_clock_i
      (

          //---------- Input -------------------------------------
          .CLK_CLK                        ( sys_clk ),
          .CLK_TXOUTCLK                   ( PIPE_TXOUTCLK_OUT ),     // Reference clock from lane 0
          .CLK_RXOUTCLK_IN                ( PIPE_RXOUTCLK_OUT ),
         // .CLK_RST_N                      ( 1'b1 ),
          .CLK_RST_N                      ( PIPE_MMCM_RST_N ),
          .CLK_PCLK_SEL                   ( PIPE_PCLK_SEL_OUT ),
          .CLK_GEN3                       ( PIPE_GEN3_OUT ),

          //---------- Output ------------------------------------
          .CLK_PCLK                       ( PIPE_PCLK_IN ),
          .CLK_RXUSRCLK                   ( PIPE_RXUSRCLK_IN ),
          .CLK_RXOUTCLK_OUT               ( PIPE_RXOUTCLK_IN ),
          .CLK_DCLK                       ( PIPE_DCLK_IN ),
          .CLK_OOBCLK                     ( PIPE_OOBCLK_IN ),
          .CLK_USERCLK1                   ( PIPE_USERCLK1_IN ),
          .CLK_USERCLK2                   ( PIPE_USERCLK2_IN ),
          .CLK_MMCM_LOCK                  ( PIPE_MMCM_LOCK_IN )

      );
    end  else begin
      assign pipe_pclk_in      = 1'b0;
      assign pipe_rxusrclk_in  = 1'b0;
      assign pipe_rxoutclk_in  = 0;
      assign pipe_dclk_in      = 1'b0;
      assign pipe_userclk1_in  = 1'b0;
      assign pipe_userclk2_in  = 1'b0;
      assign pipe_mmcm_lock_in = 1'b0;
      assign pipe_oobclk_in    = 1'b0;
    end

  endgenerate
 
pcie_7x_v1_10 #(
  .PL_FAST_TRAIN      ( PL_FAST_TRAIN ),
  .PCIE_EXT_CLK       ( PCIE_EXT_CLK ),
  .PIPE_SIM_MODE      ( PIPE_SIM_MODE ),
  .BAR0               ( 32'hFF0_0000 ),
  .CFG_VEND_ID        ( C_VENDOR_ID ),
  .CFG_DEV_ID         ( C_DEVICE_ID ),
  .CFG_REV_ID         ( C_REV_ID ),
  .CFG_SUBSYS_VEND_ID ( C_SUBSYSTEM_VENDOR_ID ),
  .CFG_SUBSYS_ID      ( C_SUBSYSTEM_ID ),
  .LINK_CAP_MAX_LINK_WIDTH ( C_NO_OF_LANES )
) pcie_7x_v1_10_i
 (

  //----------------------------------------------------------------------------------------------------------------//
  // 1. PCI Express (pci_exp) Interface                                                                             //
  //----------------------------------------------------------------------------------------------------------------//

  // Tx
  .pci_exp_txn                                ( pci_exp_txn ),
  .pci_exp_txp                                ( pci_exp_txp ),

  // Rx
  .pci_exp_rxn                                ( pci_exp_rxn ),
  .pci_exp_rxp                                ( pci_exp_rxp ),

  //----------------------------------------------------------------------------------------------------------------//
  // 2. Clocking Interface                                                                                          //
  //----------------------------------------------------------------------------------------------------------------//
  .PIPE_PCLK_IN                              ( PIPE_PCLK_IN ),
  .PIPE_RXUSRCLK_IN                          ( PIPE_RXUSRCLK_IN ),
  .PIPE_RXOUTCLK_IN                          ( PIPE_RXOUTCLK_IN ),
  .PIPE_DCLK_IN                              ( PIPE_DCLK_IN ),
  .PIPE_USERCLK1_IN                          ( PIPE_USERCLK1_IN ),
  .PIPE_OOBCLK_IN                            ( PIPE_OOBCLK_IN ),
  .PIPE_USERCLK2_IN                          ( PIPE_USERCLK2_IN ),
  .PIPE_MMCM_LOCK_IN                         ( PIPE_MMCM_LOCK_IN ),

  .PIPE_TXOUTCLK_OUT                         ( PIPE_TXOUTCLK_OUT ),
  .PIPE_RXOUTCLK_OUT                         ( PIPE_RXOUTCLK_OUT ),
  .PIPE_PCLK_SEL_OUT                         ( PIPE_PCLK_SEL_OUT ),
  .PIPE_GEN3_OUT                             ( PIPE_GEN3_OUT ),


  //----------------------------------------------------------------------------------------------------------------//
  // 3. AXI-S Interface                                                                                             //
  //----------------------------------------------------------------------------------------------------------------//

  // Common
  .user_clk_out                               ( user_clk ),
  .user_reset_out                             ( user_reset ),
  .user_lnk_up                                ( user_link_up ),

  // TX

  .tx_buf_av                                  ( tx_buf_av ),
  .tx_err_drop                                ( ),
  .tx_cfg_req                                 ( ),
  .s_axis_tx_tready                           ( s_axis_tx_tready ),
  .s_axis_tx_tdata                            ( s_axis_tx_tdata ),
  .s_axis_tx_tkeep                            ( s_axis_tx_tkeep ),
  .s_axis_tx_tuser                            ( s_axis_tx_tuser ),
  .s_axis_tx_tlast                            ( s_axis_tx_tlast ),
  .s_axis_tx_tvalid                           ( s_axis_tx_tvalid ),

  .tx_cfg_gnt                                 ( tx_cfg_gnt ),

  // Rx
  .m_axis_rx_tdata                            ( m_axis_rx_tdata ),
  .m_axis_rx_tkeep                            ( m_axis_rx_tkeep ),
  .m_axis_rx_tlast                            ( m_axis_rx_tlast ),
  .m_axis_rx_tvalid                           ( m_axis_rx_tvalid ),
  .m_axis_rx_tready                           ( m_axis_rx_tready ),
  .m_axis_rx_tuser                            ( m_axis_rx_tuser ),
  .rx_np_ok                                   ( rx_np_ok ),
  .rx_np_req                                  ( rx_np_req ),

  // Flow Control
  .fc_cpld                                    ( fc_cpld ),
  .fc_cplh                                    ( fc_cplh ),
  .fc_npd                                     ( fc_npd ),
  .fc_nph                                     ( fc_nph ),
  .fc_pd                                      ( fc_pd ),
  .fc_ph                                      ( fc_ph ),
  .fc_sel                                     ( fc_sel ),


  //----------------------------------------------------------------------------------------------------------------//
  // 4. Configuration (CFG) Interface                                                                               //
  //----------------------------------------------------------------------------------------------------------------//

  //------------------------------------------------//
  // EP and RP                                      //
  //------------------------------------------------//
  .cfg_mgmt_do                                ( ),
  .cfg_mgmt_rd_wr_done                        ( ),

  .cfg_status                                 (  ),
  .cfg_command                                (  ),
  .cfg_dstatus                                (  ),
  .cfg_lstatus                                (  ),
  .cfg_pcie_link_state                        (  ),
  .cfg_dcommand                               (  ),
  .cfg_lcommand                               (  ),
  .cfg_dcommand2                              (  ),

  .cfg_pmcsr_pme_en                           ( ),
  .cfg_pmcsr_powerstate                       ( ),
  .cfg_pmcsr_pme_status                       ( ),
  .cfg_received_func_lvl_rst                  ( ),

  // Management Interface
  .cfg_mgmt_di                                ( cfg_mgmt_di ),
  .cfg_mgmt_byte_en                           ( cfg_mgmt_byte_en ),
  .cfg_mgmt_dwaddr                            ( cfg_mgmt_dwaddr ),
  .cfg_mgmt_wr_en                             ( cfg_mgmt_wr_en ),
  .cfg_mgmt_rd_en                             ( cfg_mgmt_rd_en ),
  .cfg_mgmt_wr_readonly                       ( cfg_mgmt_wr_readonly ),

  // Error Reporting Interface
  .cfg_err_ecrc                               ( cfg_err_ecrc ),
  .cfg_err_ur                                 ( cfg_err_ur ),
  .cfg_err_cpl_timeout                        ( cfg_err_cpl_timeout ),
  .cfg_err_cpl_unexpect                       ( cfg_err_cpl_unexpect ),
  .cfg_err_cpl_abort                          ( cfg_err_cpl_abort ),
  .cfg_err_posted                             ( cfg_err_posted ),
  .cfg_err_cor                                ( cfg_err_cor ),
  .cfg_err_atomic_egress_blocked              ( cfg_err_atomic_egress_blocked ),
  .cfg_err_internal_cor                       ( cfg_err_internal_cor ),
  .cfg_err_malformed                          ( cfg_err_malformed ),
  .cfg_err_mc_blocked                         ( cfg_err_mc_blocked ),
  .cfg_err_poisoned                           ( cfg_err_poisoned ),
  .cfg_err_norecovery                         ( cfg_err_norecovery ),
  .cfg_err_tlp_cpl_header                     ( cfg_err_tlp_cpl_header ),
  .cfg_err_cpl_rdy                            (  ),
  .cfg_err_locked                             ( cfg_err_locked ),
  .cfg_err_acs                                ( cfg_err_acs ),
  .cfg_err_internal_uncor                     ( cfg_err_internal_uncor ),

  .cfg_trn_pending                            ( cfg_trn_pending ),
  .cfg_pm_halt_aspm_l0s                       ( cfg_pm_halt_aspm_l0s ),
  .cfg_pm_halt_aspm_l1                        ( cfg_pm_halt_aspm_l1 ),
  .cfg_pm_force_state_en                      ( cfg_pm_force_state_en ),
  .cfg_pm_force_state                         ( cfg_pm_force_state ),

  .cfg_dsn                                    ( cfg_dsn ),

  //------------------------------------------------//
  // EP Only                                        //
  //------------------------------------------------//
  .cfg_interrupt                              ( cfg_interrupt ),
  .cfg_interrupt_rdy                          (  ),
  .cfg_interrupt_assert                       ( cfg_interrupt_assert ),
  .cfg_interrupt_di                           ( cfg_interrupt_di ),
  .cfg_interrupt_do                           ( ),
  .cfg_interrupt_mmenable                     ( ),
  .cfg_interrupt_msienable                    ( ),
  .cfg_interrupt_msixenable                   ( ),
  .cfg_interrupt_msixfm                       ( ),
  .cfg_interrupt_stat                         ( cfg_interrupt_stat ),
  .cfg_pciecap_interrupt_msgnum               ( cfg_pciecap_interrupt_msgnum ),
  .cfg_to_turnoff                             ( cfg_to_turnoff ),
  .cfg_turnoff_ok                             ( cfg_turnoff_ok ),
  .cfg_bus_number                             ( cfg_bus_number ),
  .cfg_device_number                          ( cfg_device_number ),
  .cfg_function_number                        ( cfg_function_number ),
  .cfg_pm_wake                                ( cfg_pm_wake ),

  //------------------------------------------------//
  // RP Only                                        //
  //------------------------------------------------//
  .cfg_pm_send_pme_to                         ( 1'b0 ),
  .cfg_ds_bus_number                          ( 8'b0 ),
  .cfg_ds_device_number                       ( 5'b0 ),
  .cfg_ds_function_number                     ( 3'b0 ),
  .cfg_mgmt_wr_rw1c_as_rw                     ( 1'b0 ),
  .cfg_msg_received                           ( ),
  .cfg_msg_data                               ( ),

  .cfg_bridge_serr_en                         ( ),
  .cfg_slot_control_electromech_il_ctl_pulse  ( ),
  .cfg_root_control_syserr_corr_err_en        ( ),
  .cfg_root_control_syserr_non_fatal_err_en   ( ),
  .cfg_root_control_syserr_fatal_err_en       ( ),
  .cfg_root_control_pme_int_en                ( ),
  .cfg_aer_rooterr_corr_err_reporting_en      ( ),
  .cfg_aer_rooterr_non_fatal_err_reporting_en ( ),
  .cfg_aer_rooterr_fatal_err_reporting_en     ( ),
  .cfg_aer_rooterr_corr_err_received          ( ),
  .cfg_aer_rooterr_non_fatal_err_received     ( ),
  .cfg_aer_rooterr_fatal_err_received         ( ),

  .cfg_msg_received_err_cor                   ( ),
  .cfg_msg_received_err_non_fatal             ( ),
  .cfg_msg_received_err_fatal                 ( ),
  .cfg_msg_received_pm_as_nak                 ( ),
  .cfg_msg_received_pme_to_ack                ( ),
  .cfg_msg_received_assert_int_a              ( ),
  .cfg_msg_received_assert_int_b              ( ),
  .cfg_msg_received_assert_int_c              ( ),
  .cfg_msg_received_assert_int_d              ( ),
  .cfg_msg_received_deassert_int_a            ( ),
  .cfg_msg_received_deassert_int_b            ( ),
  .cfg_msg_received_deassert_int_c            ( ),
  .cfg_msg_received_deassert_int_d            ( ),

   .cfg_msg_received_pm_pme                   ( ),
   .cfg_msg_received_setslotpowerlimit        ( ),
  //----------------------------------------------------------------------------------------------------------------//
  // 5. Physical Layer Control and Status (PL) Interface                                                            //
  //----------------------------------------------------------------------------------------------------------------//
  .pl_directed_link_change                    ( pl_directed_link_change ),
  .pl_directed_link_width                     ( pl_directed_link_width ),
  .pl_directed_link_speed                     ( pl_directed_link_speed ),
  .pl_directed_link_auton                     ( pl_directed_link_auton ),
  .pl_upstream_prefer_deemph                  ( pl_upstream_prefer_deemph ),



  .pl_sel_lnk_rate                            (  ),
  .pl_sel_lnk_width                           (  ),
  .pl_ltssm_state                             (  ),
  .pl_lane_reversal_mode                      (  ),

  .pl_phy_lnk_up                              ( ),
  .pl_tx_pm_state                             ( ),
  .pl_rx_pm_state                             ( ),

  .pl_link_upcfg_cap                          (  ),
  .pl_link_gen2_cap                           (  ),
  .pl_link_partner_gen2_supported             (  ),
  .pl_initial_link_width                      (  ),

  .pl_directed_change_done                    ( ),

  //------------------------------------------------//
  // EP Only                                        //
  //------------------------------------------------//
  .pl_received_hot_rst                        ( ),

  //------------------------------------------------//
  // RP Only                                        //
  //------------------------------------------------//
  .pl_transmit_hot_rst                        ( 1'b0 ),
  .pl_downstream_deemph_source                ( 1'b0 ),

  //----------------------------------------------------------------------------------------------------------------//
  // 6. AER Interface                                                                                               //
  //----------------------------------------------------------------------------------------------------------------//

  .cfg_err_aer_headerlog                      ( cfg_err_aer_headerlog ),
  .cfg_aer_interrupt_msgnum                   ( cfg_aer_interrupt_msgnum ),
  .cfg_err_aer_headerlog_set                  ( ),
  .cfg_aer_ecrc_check_en                      ( ),
  .cfg_aer_ecrc_gen_en                        ( ),

  //----------------------------------------------------------------------------------------------------------------//
  // 7. VC interface                                                                                                //
  //----------------------------------------------------------------------------------------------------------------//

  .cfg_vc_tcvc_map                            ( ),

  //----------------------------------------------------------------------------------------------------------------//
  // 8. System  (SYS) Interface                                                                                     //
  //----------------------------------------------------------------------------------------------------------------//


  .PIPE_MMCM_RST_N                            ( PIPE_MMCM_RST_N     ),        // Async      | Async
  .sys_clk                                    ( sys_clk ),
  .sys_rst_n                                  ( sys_rst_n )
);


//----------------------------------------------------------------------------------------------------------------//
// User App                                                                                                       //
//----------------------------------------------------------------------------------------------------------------//
  //assign fc_sel = 3'b0;

  assign rx_np_ok = 1'b1;                          // Allow Reception of Non-posted Traffic
  assign rx_np_req = 1'b1;                         // Always request Non-posted Traffic if available
  //assign s_axis_tx_tuser[0] = 1'b0;                // Unused for V6
  //assign s_axis_tx_tuser[1] = 1'b0;                // Error forward packet
  //assign s_axis_tx_tuser[2] = 1'b0;                // Stream packet

  assign tx_cfg_gnt = 1'b1;                        // Always allow transmission of Config traffic within block

  assign cfg_err_cor = 1'b0;                       // Never report Correctable Error
  assign cfg_err_ur = 1'b0;                        // Never report UR
  assign cfg_err_ecrc = 1'b0;                      // Never report ECRC Error
  assign cfg_err_cpl_timeout = 1'b0;               // Never report Completion Timeout
  assign cfg_err_cpl_abort = 1'b0;                 // Never report Completion Abort
  assign cfg_err_cpl_unexpect = 1'b0;              // Never report unexpected completion
  assign cfg_err_posted = 1'b0;                    // Never qualify cfg_err_* inputs
  assign cfg_err_locked = 1'b0;                    // Never qualify cfg_err_ur or cfg_err_cpl_abort
  assign cfg_pm_wake = 1'b0;                       // Never direct the core to send a PM_PME Message
  assign cfg_trn_pending = 1'b0;                   // Never set the transaction pending bit in the Device Status Register

  assign cfg_err_atomic_egress_blocked = 1'b0;     // Never report Atomic TLP blocked
  assign cfg_err_internal_cor = 1'b0;              // Never report internal error occurred
  assign cfg_err_malformed = 1'b0;                 // Never report malformed error
  assign cfg_err_mc_blocked = 1'b0;                // Never report multi-cast TLP blocked
  assign cfg_err_poisoned = 1'b0;                  // Never report poisoned TLP received
  assign cfg_err_norecovery = 1'b0;                // Never qualify cfg_err_poisoned or cfg_err_cpl_timeout
  assign cfg_err_acs = 1'b0;                       // Never report an ACS violation
  assign cfg_err_internal_uncor = 1'b0;            // Never report internal uncorrectable error
  assign cfg_pm_halt_aspm_l0s = 1'b0;              // Allow entry into L0s
  assign cfg_pm_halt_aspm_l1 = 1'b0;               // Allow entry into L1
  assign cfg_pm_force_state_en  = 1'b0;            // Do not qualify cfg_pm_force_state
  assign cfg_pm_force_state  = 2'b00;              // Do not move force core into specific PM state

  assign cfg_err_aer_headerlog = 128'h0;           // Zero out the AER Header Log
  assign cfg_aer_interrupt_msgnum = 5'b00000;      // Zero out the AER Root Error Status Register

  assign cfg_interrupt_stat = 1'b0;                // Never set the Interrupt Status bit
  assign cfg_pciecap_interrupt_msgnum = 5'b00000;  // Zero out Interrupt Message Number

  assign cfg_interrupt_assert = 1'b0;              // Always drive interrupt de-assert
  assign cfg_interrupt = 1'b0;                     // Never drive interrupt by qualifying cfg_interrupt_assert

  assign pl_directed_link_change = 2'b00;          // Never initiate link change
  assign pl_directed_link_width = 2'b00;          // Zero out directed link width
  assign pl_directed_link_speed = 1'b0;            // Zero out directed link speed
  assign pl_directed_link_auton = 1'b0;            // Zero out link autonomous input
  assign pl_upstream_prefer_deemph = 1'b1;         // Zero out preferred de-emphasis of upstream port

  assign cfg_interrupt_di = 8'b0;                  // Do not set interrupt fields

  assign cfg_err_tlp_cpl_header = 48'h0;           // Zero out the header information

  assign cfg_mgmt_di = 32'h0;                      // Zero out CFG MGMT input data bus
  assign cfg_mgmt_byte_en = 4'h0;                  // Zero out CFG MGMT byte enables
  assign cfg_mgmt_dwaddr = 10'h0;                  // Zero out CFG MGMT 10-bit address port
  assign cfg_mgmt_wr_en = 1'b0;                    // Do not write CFG space
  assign cfg_mgmt_rd_en = 1'b0;                    // Do not read CFG space
  assign cfg_mgmt_wr_readonly = 1'b0;              // Never treat RO bit as RW

  assign cfg_dsn = {PCI_EXP_EP_DSN_2, PCI_EXP_EP_DSN_1};  // Assign the input DSN

  //----------------------------------------------------------------------------------------------------------------//
  // Programmable I/O Module                                                                                        //
  //----------------------------------------------------------------------------------------------------------------//
  output [15:0] cfg_completer_id;
  assign cfg_completer_id      = { cfg_bus_number, cfg_device_number, cfg_function_number };
endmodule
