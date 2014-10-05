//----------------------------------------------------------------------------//
//  File: axi_pcie_v1_08_a_axi_enhanced_rx_demux.v                   //
//  Date : 09/13/10                                                           //
//  Author : Naveen Kumar Rajagopal                                           //
//                                                                            //
//  Description:                                                              //
//  Demultiplexing the received AXI packet from the pipeline/ destraddler     //
//  onto the AXI -CR, AXI- CW or the AXI -RC interface                        //
//                                                                            //
//  Notes:                                                                    //
//  Optional notes section.                                                   //
//                                                                            //
//  Hierarchical:                                                             //
//    axi_enhanced_top                                                        //
//      axi_enhanced_rx                                                       //
//        axi_enhanced_rx_demux                                               //
//                                                                            //
//----------------------------------------------------------------------------//

`timescale 1ps/1ps

module axi_pcie_v1_08_a_axi_enhanced_rx_demux #(
  parameter C_DATA_WIDTH = 32,             // RX/TX interface data width
  parameter C_FAMILY = "X7",               // Targeted FPGA family
  parameter C_RX_PRESERVE_ORDER = "FALSE", // Preserve Wr/Rd ordering of packets
  parameter C_RX_REALIGN = "TRUE",         // specifies whether Relalignment is enabled or not
  parameter C_ROOT_PORT = "FALSE",         // specifies whether the core work as Root or EP
  parameter TCQ = 1,                       // Clock to Q time

  // Do not override parameters below this line
  parameter REM_WIDTH  = (C_DATA_WIDTH == 128) ? 2 : 1, // trem/rrem width
  parameter RBAR_WIDTH = (C_FAMILY == "X7") ? 8 : 7,    // trn_rbar_hit width
  parameter STRB_WIDTH = C_DATA_WIDTH / 8               // TSTRB width
  ) (

  //-------------------------------------------------
  // AXI-S RX Interface to the data pipeline
  //-------------------------------------------------
  input      [C_DATA_WIDTH-1:0] m_axis_rx_tdata,     // RX data
  input                         m_axis_rx_tvalid,    // RX data is valid
  output reg                    m_axis_rx_tready,    // RX ready for data
  input        [STRB_WIDTH-1:0] m_axis_rx_tstrb,     // RX strobe byte enables
  input                         m_axis_rx_tlast,     // RX data is last
  input                  [21:0] m_axis_rx_tuser,     // RX user signals

  input                         is_msi_trn,

  //-------------------------------------------------
  // AXI-S CR interface
  //-------------------------------------------------

  output reg [C_DATA_WIDTH-1:0] m_axis_cr_tdata,     // CR data
  output                        m_axis_cr_tvalid,    // CR data is valid
  input                         m_axis_cr_tready,    // CR ready for data
  output reg   [STRB_WIDTH-1:0] m_axis_cr_tstrb,     // CR strobe byte enables
  output reg                    m_axis_cr_tlast,     // CR data is last
  output reg             [21:0] m_axis_cr_tuser,     // CR user signals

  //-------------------------------------------------
  // AXI-S CW interface
  //-------------------------------------------------

  output reg [C_DATA_WIDTH-1:0] m_axis_cw_tdata,     // CW data
  output                        m_axis_cw_tvalid,    // CW data is valid
  input                         m_axis_cw_tready,    // CW ready for data
  output reg   [STRB_WIDTH-1:0] m_axis_cw_tstrb,     // CW strobe byte enables
  output reg                    m_axis_cw_tlast,     // CW data is last
  output reg             [21:0] m_axis_cw_tuser,     // CW user signals

  //-------------------------------------------------
  // AXI-S RC interface
  //-------------------------------------------------

  output reg [C_DATA_WIDTH-1:0] m_axis_rc_tdata,     // RC data
  output                        m_axis_rc_tvalid,    // RC data is valid
  input                         m_axis_rc_tready,    // RC ready for data
  output reg   [STRB_WIDTH-1:0] m_axis_rc_tstrb,     // RC strobe byte enables
  output reg                    m_axis_rc_tlast,     // RC data is last
  output reg             [21:0] m_axis_rc_tuser,     // RC user signals

  //-------------------------------------------------
  // AXI-S Cfg interface
  //-------------------------------------------------

  output reg [C_DATA_WIDTH-1:0] m_axis_cfg_tdata,     // CFG data
  output                        m_axis_cfg_tvalid,    // CFG data is valid
  input                         m_axis_cfg_tready,    // CFG ready for data
  output reg   [STRB_WIDTH-1:0] m_axis_cfg_tstrb,     // CFG strobe byte enables
  output reg                    m_axis_cfg_tlast,     // CFG data is last
  output reg             [21:0] m_axis_cfg_tuser,     // CFG user signals
  output reg                    is_msi,               // to indicate if the packet is MSI / Cfg Cpl
  input                  [63:0] msi_address,          // MSI Base address from the config block

  //-------------------------------------------------
  // System I/Os
  //-------------------------------------------------
  input                         com_iclk,            // user clock from block
  input                         com_sysrst,          // user reset from block
  input                         trn_lnk_up,          // TRN link up signal
  input                         cfg_req              // indicates whether user is waiting for a NP cpl
);

//*****************************************************************************************************
// Internal registers and wires
//*****************************************************************************************************

   reg              [1:0] pkt_fmt;                    // Indicates the packet format
   reg              [4:0] pkt_type;                   // Indicates the packet type
   reg              [1:0] pkt_fmt_prev;               // Indicates the packet format
   reg              [4:0] pkt_type_prev;              // Indicates the packet type
   reg              [1:0] pkt_type_p_np_cpl_cfg;      // Register to indicate posted / non posted / cpl / cfg pkts
   reg             [63:0] pkt_addr;                   // To Hold the pkt address in Memory Write TLPs
   reg             [63:0] pkt_addr_d;                 // Delayed version
   wire                   is_sof;                     // To indicate the dtart of frame
   reg                    is_sof_d;                   // Register to hold the start of frame
   wire                   data_hold_demux;               // Wire to Indicate the data hold on the CR interface
   reg                    data_prev_demux;               // register to indicate the prev data to be transmitted on CR

//*****************************************************************************************************
// Internal buffer to store the data and control signals
//*****************************************************************************************************

   reg [C_DATA_WIDTH-1:0] m_axis_rx_tdata_d;     // RX data
   reg                    m_axis_rx_tvalid_d;    // RX data is valid
   reg   [STRB_WIDTH-1:0] m_axis_rx_tstrb_d;     // RX strobe byte enables
   reg                    m_axis_rx_tlast_d;     // RX data is last
   reg             [21:0] m_axis_rx_tuser_d;     // RX user signals
   reg                    m_axis_cr_tready_d;    // CR ready for data
   reg                    m_axis_cw_tready_d;    // CW ready for data
   reg                    m_axis_rc_tready_d;    // RC ready for data
   reg                    m_axis_cfg_tready_d;   // CFG ready for data

//****************************************************************************************************
//Internal wires to select between the user ready and global ready(when link goes down)   
//****************************************************************************************************

  wire                    m_axis_cr_tready_i;
  wire                    m_axis_cw_tready_i;
  wire                    m_axis_rc_tready_i;
  wire                    m_axis_cfg_tready_i;

  reg                     m_axis_cr_tvalid_i;
  reg                     m_axis_cw_tvalid_i;
  reg                     m_axis_rc_tvalid_i;
  reg                     m_axis_cfg_tvalid_i;
  reg                     trn_in_packet;
  reg                     is_msi_trn_d;

  // trn_in_packet logic
  generate
  if(C_ROOT_PORT == "TRUE") begin : rp_trn_in_packet
    always@(posedge com_iclk) begin
      if(com_sysrst) begin
        trn_in_packet <= #TCQ 1'b0;
      end
      else begin
        // In-packet when we get tvalid && tready && sof && !eof beat
        if((m_axis_cr_tvalid && m_axis_cr_tready && m_axis_cr_tuser[14] && (!m_axis_cr_tlast)) ||
           (m_axis_cw_tvalid && m_axis_cw_tready && m_axis_cw_tuser[14] && (!m_axis_cw_tlast)) ||
           (m_axis_rc_tvalid && m_axis_rc_tready && m_axis_rc_tuser[14] && (!m_axis_rc_tlast)) ||
           (m_axis_cfg_tvalid && m_axis_cfg_tready && m_axis_cfg_tuser[14] && (!m_axis_cfg_tlast))) begin
          trn_in_packet <= #TCQ 1'b1;
        end
        // considering that mm bridge never back throttles in mid-packet reception
        else if((m_axis_cr_tvalid && m_axis_cr_tlast && m_axis_cr_tready_i) ||
                (m_axis_cw_tvalid && m_axis_cw_tlast && m_axis_cw_tready_i) ||
                (m_axis_rc_tvalid && m_axis_rc_tlast && m_axis_rc_tready_i) ||
                (m_axis_cfg_tvalid && m_axis_cfg_tlast && m_axis_cfg_tready_i)) begin
          trn_in_packet <= #TCQ 1'b0;
        end
      end
    end

    // Delayed version of is_msi_trn signal
    always@(posedge com_iclk) begin
      if(com_sysrst) begin
        is_msi_trn_d <= #TCQ 1'b0;
      end
      else begin
        is_msi_trn_d <= #TCQ is_msi_trn;
      end
    end

  end // rp_trn_in_packet
  else begin : ep_trn_in_packet
    always@(posedge com_iclk) begin
      if(com_sysrst) begin
        trn_in_packet <= #TCQ 1'b0;
        is_msi_trn_d  <= #TCQ 1'b0;
      end
      else begin
        // In-packet when we get tvalid && tready && sof && !eof beat
        if((m_axis_cr_tvalid && m_axis_cr_tready && m_axis_cr_tuser[14] && (!m_axis_cr_tlast)) ||
           (m_axis_cw_tvalid && m_axis_cw_tready && m_axis_cw_tuser[14] && (!m_axis_cw_tlast)) ||
           (m_axis_rc_tvalid && m_axis_rc_tready && m_axis_rc_tuser[14] && (!m_axis_rc_tlast))) begin
          trn_in_packet <= #TCQ 1'b1;
        end
        // considering that mm bridge never back throttles in mid-packet reception
        else if((m_axis_cr_tvalid && m_axis_cr_tlast) ||
                (m_axis_cw_tvalid && m_axis_cw_tlast) ||
                (m_axis_rc_tvalid && m_axis_rc_tlast)) begin
          trn_in_packet <= #TCQ 1'b0;
        end
      end
    end
  end // ep_trn_in_packet
  endgenerate

  assign m_axis_cr_tready_i  = trn_lnk_up? m_axis_cr_tready  : 1'b1;
  assign m_axis_cw_tready_i  = trn_lnk_up? m_axis_cw_tready  : 1'b1;
  assign m_axis_rc_tready_i  = trn_lnk_up? m_axis_rc_tready  : 1'b1;
  assign m_axis_cfg_tready_i = trn_lnk_up? m_axis_cfg_tready : 1'b1;

  assign m_axis_cr_tvalid    = ((!trn_in_packet) && (!trn_lnk_up)) ? 1'b0 : m_axis_cr_tvalid_i;
  assign m_axis_cw_tvalid    = ((!trn_in_packet) && (!trn_lnk_up)) ? 1'b0 : m_axis_cw_tvalid_i;
  assign m_axis_rc_tvalid    = ((!trn_in_packet) && (!trn_lnk_up)) ? 1'b0 : m_axis_rc_tvalid_i;
  assign m_axis_cfg_tvalid   = ((!trn_in_packet) && (!trn_lnk_up)) ? 1'b0 : m_axis_cfg_tvalid_i;
  // Local Parameters

  localparam NONPOSTED = 2'b00;
  localparam POSTED    = 2'b01;
  localparam CPL       = 2'b10;
  localparam CFG       = 2'b11;

generate
  if(C_ROOT_PORT == "FALSE") begin : endpoint_demux_hold
  assign data_hold_demux  = ((!m_axis_cr_tready_i && m_axis_cr_tvalid_i)||(!m_axis_cw_tready_i && m_axis_cw_tvalid_i) ||
                             (!m_axis_rc_tready_i && m_axis_rc_tvalid_i));
  end // endpoint_demux_hold
  else begin : rootport_demux_hold
  assign data_hold_demux  = ((!m_axis_cr_tready_i && m_axis_cr_tvalid_i)||(!m_axis_cw_tready_i && m_axis_cw_tvalid_i) ||
                            (!m_axis_rc_tready_i && m_axis_rc_tvalid_i)||(!m_axis_cfg_tready_i && m_axis_cfg_tvalid_i));
  end // rootport_demux_hold
endgenerate

  always @(posedge com_iclk) begin
    if(com_sysrst) begin
      data_prev_demux  <= #TCQ 1'b0;
    end
    else begin
      data_prev_demux  <= #TCQ data_hold_demux;
    end
  end

//---------------------------------------------------------------------
// Fetch the Packet address in case of Memory Write TLPs
// Used in case of 128 bit data with Realignment Enabled
generate
  if(C_DATA_WIDTH == 128) begin :specific_to_128
    
    always @(*) begin
      if(m_axis_rx_tuser[14] && m_axis_rx_tvalid && !data_hold_demux && !data_prev_demux) begin
        pkt_addr = (m_axis_rx_tdata[29]) ? {m_axis_rx_tdata[95:64], m_axis_rx_tdata[127:96]} : {32'b0, m_axis_rx_tdata[95:64]};
      end
      else if (m_axis_rx_tuser_d[14] && m_axis_rx_tvalid_d && !data_hold_demux && data_prev_demux) begin
        pkt_addr = (m_axis_rx_tdata_d[29]) ? {m_axis_rx_tdata_d[95:64], m_axis_rx_tdata_d[127:96]}:{32'b0, m_axis_rx_tdata_d[95:64]};
      end
      else begin
        pkt_addr = pkt_addr_d;
      end
    end

    always@(posedge com_iclk) begin
      if(com_sysrst) begin
        pkt_addr_d  <= #TCQ 64'b0;
      end
      else begin
        pkt_addr_d  <= #TCQ pkt_addr;
      end
    end
  end
endgenerate

  always @(*) begin
    if(m_axis_rx_tuser[14] && m_axis_rx_tvalid && !data_hold_demux && !data_prev_demux) begin
      pkt_fmt  = m_axis_rx_tdata[30:29]; // get the packet format of a new packet
      pkt_type = m_axis_rx_tdata[28:24]; // get the packet type of a new packet
    end
    else if(m_axis_rx_tuser_d[14] && m_axis_rx_tvalid_d && !data_hold_demux && data_prev_demux) begin
      pkt_fmt  = m_axis_rx_tdata_d[30:29];
      pkt_type = m_axis_rx_tdata_d[28:24];
    end
    else begin
      pkt_fmt  = pkt_fmt_prev;
      pkt_type = pkt_type_prev;
    end
  end

  always @(posedge com_iclk) begin
    if(com_sysrst) begin
      pkt_fmt_prev  <= #TCQ 2'b00;
      pkt_type_prev <= #TCQ 5'h00;
    end
    else begin
      pkt_fmt_prev  <= #TCQ pkt_fmt;
      pkt_type_prev <= #TCQ pkt_type;
    end
  end

  // Store the data and control signals in the internal buffer
  always @ (posedge com_iclk) begin
    if(com_sysrst) begin
      m_axis_rx_tdata_d     <= #TCQ {C_DATA_WIDTH{1'b0}};
      m_axis_rx_tvalid_d    <= #TCQ 1'b0;
      m_axis_rx_tstrb_d     <= #TCQ {STRB_WIDTH{1'b0}};
      m_axis_rx_tlast_d     <= #TCQ 1'b0;
      m_axis_rx_tuser_d     <= #TCQ 22'b0;
      m_axis_cr_tready_d    <= #TCQ 1'b0;
      m_axis_cw_tready_d    <= #TCQ 1'b0;
      m_axis_rc_tready_d    <= #TCQ 1'b0;
      m_axis_cfg_tready_d   <= #TCQ 1'b0;
    end
    else begin
      if(m_axis_rx_tready) begin
        m_axis_rx_tdata_d   <= #TCQ m_axis_rx_tdata;     // RX data
        m_axis_rx_tvalid_d  <= #TCQ m_axis_rx_tvalid;    // RX data is valid
        m_axis_rx_tstrb_d   <= #TCQ m_axis_rx_tstrb;     // RX strobe byte enables
        m_axis_rx_tlast_d   <= #TCQ m_axis_rx_tlast;     // RX data is last
        m_axis_rx_tuser_d   <= #TCQ m_axis_rx_tuser;     // RX tuser (contains is_sof and is_eof)
        m_axis_cr_tready_d  <= #TCQ m_axis_cr_tready_i;    // CR Tready signal
        m_axis_cw_tready_d  <= #TCQ m_axis_cw_tready_i;    // CW Tready signal
        m_axis_rc_tready_d  <= #TCQ m_axis_rc_tready_i;    // RC Tready signal
        m_axis_cfg_tready_d <= #TCQ m_axis_cfg_tready_i;   // CFG Tready signal
      end
   end
  end

  //-------------------------------------------------------------------------------------------------
  // Check for the packet type using the pkt_fmt and pkt_type for Posted or Non Posted or Completions
  // Configutation completions / MSI packets
  //-------------------------------------------------------------------------------------------------
  //       Signal         |   Value  |  Indicates
  //-------------------------------------------------------------------------------------------------
  //pkt_type_p_np_cpl_cfg |   2'b00  |  Non posted
  //                      |   2'b01  |  Posted
  //                      |   2'b10  |  Completion
  //                      |   2`b11  |  Config Completion / MSI
  //-------------------------------------------------------------------------------------------------

  always @(posedge com_iclk)
  begin
    if(com_sysrst) begin
      pkt_type_p_np_cpl_cfg <= #TCQ 2'b00;
      m_axis_cr_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
      m_axis_cr_tvalid_i    <= #TCQ 1'b0;
      m_axis_cr_tlast       <= #TCQ 1'b0;
      m_axis_cr_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
      m_axis_cr_tuser       <= #TCQ 22'b0;
      m_axis_cw_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
      m_axis_cw_tvalid_i    <= #TCQ 1'b0;
      m_axis_cw_tlast       <= #TCQ 1'b0;
      m_axis_cw_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
      m_axis_cw_tuser       <= #TCQ 22'b0;
      m_axis_rc_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
      m_axis_rc_tvalid_i    <= #TCQ 1'b0;
      m_axis_rc_tlast       <= #TCQ 1'b0;
      m_axis_rc_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
      m_axis_rc_tuser       <= #TCQ 22'b0;
      m_axis_cfg_tdata      <= #TCQ {C_DATA_WIDTH{1'b0}};
      m_axis_cfg_tvalid_i   <= #TCQ 1'b0;
      m_axis_cfg_tlast      <= #TCQ 1'b0;
      m_axis_cfg_tstrb      <= #TCQ {STRB_WIDTH{1'b0}};
      m_axis_cfg_tuser      <= #TCQ 22'b0;
      m_axis_rx_tready      <= #TCQ 1'b0;
      is_msi                <= #TCQ 1'b0;
    end
    else begin
    // Nam - added according to Manish's input
      // coverage off -item b 1 -allfalse
      if((pkt_type[4:2] == 3'b000 && ({pkt_fmt[1],pkt_type[1]} != 2'b10)) || (pkt_type[4:2] == 3'b011)) begin
        pkt_type_p_np_cpl_cfg <= #TCQ NONPOSTED;
        m_axis_cw_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
        m_axis_cw_tvalid_i    <= #TCQ 1'b0;
        m_axis_cw_tlast       <= #TCQ 1'b0;
        m_axis_cw_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
        m_axis_cw_tuser       <= #TCQ 22'b0;
        m_axis_rc_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
        m_axis_rc_tvalid_i    <= #TCQ 1'b0;
        m_axis_rc_tlast       <= #TCQ 1'b0;
        m_axis_rc_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
        m_axis_rc_tuser       <= #TCQ 22'b0;
        m_axis_cfg_tdata      <= #TCQ {C_DATA_WIDTH{1'b0}};
        m_axis_cfg_tvalid_i   <= #TCQ 1'b0;
        m_axis_cfg_tlast      <= #TCQ 1'b0;
        m_axis_cfg_tstrb      <= #TCQ {STRB_WIDTH{1'b0}};
        m_axis_cfg_tuser      <= #TCQ 22'b0;

        // Check for user throttle of m_axis_cr_tready

        if(!data_hold_demux) begin
          if(data_prev_demux) begin // send previous data
            m_axis_cr_tdata       <= #TCQ m_axis_rx_tdata_d;
            m_axis_cr_tvalid_i    <= #TCQ m_axis_rx_tvalid_d;
            m_axis_cr_tlast       <= #TCQ m_axis_rx_tlast_d;
            m_axis_cr_tstrb       <= #TCQ m_axis_rx_tstrb_d;
            m_axis_cr_tuser       <= #TCQ m_axis_rx_tuser_d;
          end
          else begin             // send current data
            m_axis_cr_tdata       <= #TCQ m_axis_rx_tdata;
            m_axis_cr_tvalid_i    <= #TCQ m_axis_rx_tvalid;
            m_axis_cr_tlast       <= #TCQ m_axis_rx_tlast;
            m_axis_cr_tstrb       <= #TCQ m_axis_rx_tstrb;
            m_axis_cr_tuser       <= #TCQ m_axis_rx_tuser;
          end
        end
        else begin
            //hold data
        end

        //m_axis_rx_tready driving logic
        if(m_axis_cr_tvalid_i)
          m_axis_rx_tready <= #TCQ m_axis_cr_tready_i;
        else
          m_axis_rx_tready <= #TCQ 1'b1;
      end

      //******************************************************************************************************
      // For POSTED type packet decoding, MSI type check varies according to the 3 different data widths.
      // 32 bit data width doesnt need MSI type check
      // 64 bit data needs MSI to be checked in the 2nd data beat and hence we check this in the data pipeline
      // 128 bit with Data realigned will check MSI in the 1st data beat itself
      //******************************************************************************************************

      else if((pkt_type[4:2] == 3'b000) || (pkt_type[4:3] == 2'b10)) begin
        pkt_type_p_np_cpl_cfg <= #TCQ POSTED;

       //for 32 bit data width, we have only MWr TLPs and no MSIs
        if(C_DATA_WIDTH == 32) begin
          if(C_RX_PRESERVE_ORDER == "FALSE") begin
            m_axis_cr_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
            m_axis_cr_tvalid_i    <= #TCQ 1'b0;
            m_axis_cr_tlast       <= #TCQ 1'b0;
            m_axis_cr_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
            m_axis_cr_tuser       <= #TCQ 22'b0;
            m_axis_rc_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
            m_axis_rc_tvalid_i    <= #TCQ 1'b0;
            m_axis_rc_tlast       <= #TCQ 1'b0;
            m_axis_rc_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
            m_axis_rc_tuser       <= #TCQ 22'b0;
            m_axis_cfg_tdata      <= #TCQ {C_DATA_WIDTH{1'b0}};
            m_axis_cfg_tvalid_i   <= #TCQ 1'b0;
            m_axis_cfg_tlast      <= #TCQ 1'b0;
            m_axis_cfg_tstrb      <= #TCQ {STRB_WIDTH{1'b0}};
            m_axis_cfg_tuser      <= #TCQ 22'b0;  
            if(!data_hold_demux) begin
              if(data_prev_demux) begin // send previous data
                m_axis_cw_tdata       <= #TCQ m_axis_rx_tdata_d;
                m_axis_cw_tvalid_i    <= #TCQ m_axis_rx_tvalid_d;
                m_axis_cw_tlast       <= #TCQ m_axis_rx_tlast_d;
                m_axis_cw_tstrb       <= #TCQ m_axis_rx_tstrb_d;
                m_axis_cw_tuser       <= #TCQ m_axis_rx_tuser_d;
              end
              else begin  // send current data
                m_axis_cw_tdata       <= #TCQ m_axis_rx_tdata;
                m_axis_cw_tvalid_i    <= #TCQ m_axis_rx_tvalid;
                m_axis_cw_tlast       <= #TCQ m_axis_rx_tlast;
                m_axis_cw_tstrb       <= #TCQ m_axis_rx_tstrb;
                m_axis_cw_tuser       <= #TCQ m_axis_rx_tuser;
              end
            end
            else begin
                //hold data
            end

            //m_axis_rx_tready driving logic
            if(m_axis_cw_tvalid_i)
              m_axis_rx_tready <= #TCQ m_axis_cw_tready_i;
            else
              m_axis_rx_tready <= #TCQ 1'b1;
          end
          //coverage off
          else begin
            m_axis_cw_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
            m_axis_cw_tvalid_i    <= #TCQ 1'b0;
            m_axis_cw_tlast       <= #TCQ 1'b0;
            m_axis_cw_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
            m_axis_cw_tuser       <= #TCQ 22'b0;
            m_axis_rc_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
            m_axis_rc_tvalid_i    <= #TCQ 1'b0;
            m_axis_rc_tlast       <= #TCQ 1'b0;
            m_axis_rc_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
            m_axis_rc_tuser       <= #TCQ 22'b0;
            m_axis_cfg_tdata      <= #TCQ {C_DATA_WIDTH{1'b0}};
            m_axis_cfg_tvalid_i   <= #TCQ 1'b0;
            m_axis_cfg_tlast      <= #TCQ 1'b0;
            m_axis_cfg_tstrb      <= #TCQ {STRB_WIDTH{1'b0}};
            m_axis_cfg_tuser      <= #TCQ 22'b0;      
            if(!data_hold_demux) begin
              if(data_prev_demux) begin // send previous data
                m_axis_cr_tdata       <= #TCQ m_axis_rx_tdata_d;
                m_axis_cr_tvalid_i    <= #TCQ m_axis_rx_tvalid_d;
                m_axis_cr_tlast       <= #TCQ m_axis_rx_tlast_d;
                m_axis_cr_tstrb       <= #TCQ m_axis_rx_tstrb_d;
                m_axis_cr_tuser       <= #TCQ m_axis_rx_tuser_d;
              end
              else begin  // send current data
                m_axis_cr_tdata       <= #TCQ m_axis_rx_tdata;
                m_axis_cr_tvalid_i    <= #TCQ m_axis_rx_tvalid;
                m_axis_cr_tlast       <= #TCQ m_axis_rx_tlast;
                m_axis_cr_tstrb       <= #TCQ m_axis_rx_tstrb;
                m_axis_cr_tuser       <= #TCQ m_axis_rx_tuser;
              end
            end
            else begin
              //hold data
            end

            //  m_axis_rx_tready driving logic
            if(m_axis_cr_tvalid_i)
              m_axis_rx_tready <= #TCQ m_axis_cr_tready_i;
            else
              m_axis_rx_tready <= #TCQ 1'b1;
          end
          // coverage on    
        end // end of POSTED type for 32 bit data width

        //***************************************************************************************
        // For 64 bit data, the is_msi_trn will be input from the RX data pipeline block.
        // This is done to counter the one cycle TCQ required to decode the MSI
        //***************************************************************************************

        else if (C_DATA_WIDTH == 64) begin
          if(!((is_msi_trn_d && !m_axis_cfg_tlast) || is_msi_trn)) begin
            pkt_type_p_np_cpl_cfg <= #TCQ POSTED; // route tp CW interface
            is_msi                <= #TCQ 1'b0;

            if(C_RX_PRESERVE_ORDER == "FALSE") begin
              m_axis_cr_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
              m_axis_cr_tvalid_i    <= #TCQ 1'b0;
              m_axis_cr_tlast       <= #TCQ 1'b0;
              m_axis_cr_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
              m_axis_cr_tuser       <= #TCQ 22'b0;
              m_axis_rc_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
              m_axis_rc_tvalid_i    <= #TCQ 1'b0;
              m_axis_rc_tlast       <= #TCQ 1'b0;
              m_axis_rc_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
              m_axis_rc_tuser       <= #TCQ 22'b0;
              m_axis_cfg_tdata      <= #TCQ {C_DATA_WIDTH{1'b0}};
              m_axis_cfg_tvalid_i   <= #TCQ 1'b0;
              m_axis_cfg_tlast      <= #TCQ 1'b0;
              m_axis_cfg_tstrb      <= #TCQ {STRB_WIDTH{1'b0}};
              m_axis_cfg_tuser      <= #TCQ 22'b0;        
              if(!data_hold_demux) begin
                if(data_prev_demux) begin // send previous data
                  m_axis_cw_tdata       <= #TCQ m_axis_rx_tdata_d;
                  m_axis_cw_tvalid_i    <= #TCQ m_axis_rx_tvalid_d;
                  m_axis_cw_tlast       <= #TCQ m_axis_rx_tlast_d;
                  m_axis_cw_tstrb       <= #TCQ m_axis_rx_tstrb_d;
                  m_axis_cw_tuser       <= #TCQ m_axis_rx_tuser_d;
                end
                else begin  // send current data
                    m_axis_cw_tdata     <= #TCQ m_axis_rx_tdata;
                  m_axis_cw_tvalid_i    <= #TCQ m_axis_rx_tvalid;
                  m_axis_cw_tlast       <= #TCQ m_axis_rx_tlast;
                  m_axis_cw_tstrb       <= #TCQ m_axis_rx_tstrb;
                  m_axis_cw_tuser       <= #TCQ m_axis_rx_tuser;
                end
              end
              else begin
                  //hold data
              end

              //m_axis_rx_tready driving logic
              if(m_axis_cw_tvalid_i)
                m_axis_rx_tready <= #TCQ m_axis_cw_tready_i;
              else
                m_axis_rx_tready <= #TCQ 1'b1;
            end
            //coverage off
            else begin
              m_axis_cw_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
              m_axis_cw_tvalid_i    <= #TCQ 1'b0;
              m_axis_cw_tlast       <= #TCQ 1'b0;
              m_axis_cw_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
              m_axis_cw_tuser       <= #TCQ 22'b0;
              m_axis_rc_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
              m_axis_rc_tvalid_i    <= #TCQ 1'b0;
              m_axis_rc_tlast       <= #TCQ 1'b0;
              m_axis_rc_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
              m_axis_rc_tuser       <= #TCQ 22'b0;
              m_axis_cfg_tdata      <= #TCQ {C_DATA_WIDTH{1'b0}};
              m_axis_cfg_tvalid_i   <= #TCQ 1'b0;
              m_axis_cfg_tlast      <= #TCQ 1'b0;
              m_axis_cfg_tstrb      <= #TCQ {STRB_WIDTH{1'b0}};
              m_axis_cfg_tuser      <= #TCQ 22'b0;        
              if(!data_hold_demux) begin
                if(data_prev_demux) begin // send previous data
                  m_axis_cr_tdata       <= #TCQ m_axis_rx_tdata_d;
                  m_axis_cr_tvalid_i    <= #TCQ m_axis_rx_tvalid_d;
                  m_axis_cr_tlast       <= #TCQ m_axis_rx_tlast_d;
                  m_axis_cr_tstrb       <= #TCQ m_axis_rx_tstrb_d;
                  m_axis_cr_tuser       <= #TCQ m_axis_rx_tuser_d;
                end
                else begin  // send current data
                  m_axis_cr_tdata       <= #TCQ m_axis_rx_tdata;
                  m_axis_cr_tvalid_i    <= #TCQ m_axis_rx_tvalid;
                  m_axis_cr_tlast       <= #TCQ m_axis_rx_tlast;
                  m_axis_cr_tstrb       <= #TCQ m_axis_rx_tstrb;
                  m_axis_cr_tuser       <= #TCQ m_axis_rx_tuser;
                end
              end
              else begin
                //hold data
              end

              //  m_axis_rx_tready driving logic
              if(m_axis_cr_tvalid_i)
                m_axis_rx_tready <= #TCQ m_axis_cr_tready_i;
              else
                m_axis_rx_tready <= #TCQ 1'b1;
            end
            //coverage on  
          end
          else begin // MSI packet
            pkt_type_p_np_cpl_cfg <= #TCQ CFG;
            is_msi                <= #TCQ 1'b1;
            m_axis_cw_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
            m_axis_cw_tvalid_i    <= #TCQ 1'b0;
            m_axis_cw_tlast       <= #TCQ 1'b0;
            m_axis_cw_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
            m_axis_cw_tuser       <= #TCQ 22'b0;
            m_axis_rc_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
            m_axis_rc_tvalid_i    <= #TCQ 1'b0;
            m_axis_rc_tlast       <= #TCQ 1'b0;
            m_axis_rc_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
            m_axis_rc_tuser       <= #TCQ 22'b0;
            m_axis_cr_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
            m_axis_cr_tvalid_i    <= #TCQ 1'b0;
            m_axis_cr_tlast       <= #TCQ 1'b0;
            m_axis_cr_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
            m_axis_cr_tuser       <= #TCQ 22'b0;
            if(!data_hold_demux) begin
              if(data_prev_demux) begin // send previous data
                m_axis_cfg_tdata       <= #TCQ m_axis_rx_tdata_d;
                m_axis_cfg_tvalid_i    <= #TCQ m_axis_rx_tvalid_d;
                m_axis_cfg_tlast       <= #TCQ m_axis_rx_tlast_d;
                m_axis_cfg_tstrb       <= #TCQ m_axis_rx_tstrb_d;
                m_axis_cfg_tuser       <= #TCQ m_axis_rx_tuser_d;
              end
              else begin  // send current data
                m_axis_cfg_tdata       <= #TCQ m_axis_rx_tdata;
                m_axis_cfg_tvalid_i    <= #TCQ m_axis_rx_tvalid;
                m_axis_cfg_tlast       <= #TCQ m_axis_rx_tlast;
                m_axis_cfg_tstrb       <= #TCQ m_axis_rx_tstrb;
                m_axis_cfg_tuser       <= #TCQ m_axis_rx_tuser;
              end
            end
            else begin
              //hold data
            end

            //m_axis_rx_tready driving logic
            if(m_axis_cfg_tvalid_i)
              m_axis_rx_tready <= #TCQ m_axis_cfg_tready_i;
            else
              m_axis_rx_tready <= #TCQ 1'b1;
          end
        end // End of posted type decoding for 64 bit data

        //-------------------------------------------------------------------------
        // Begining of posted type pkt decoding for 128 bit data
        //-------------------------------------------------------------------------
        else begin // 128_bit_data_posted_type_decode
          if(pkt_addr == msi_address && pkt_type[4] == 1'b0 && C_ROOT_PORT == "TRUE") begin // MSI_pkt_128
            pkt_type_p_np_cpl_cfg <= #TCQ CFG;
            is_msi                <= #TCQ 1'b1;
            m_axis_cw_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
            m_axis_cw_tvalid_i    <= #TCQ 1'b0;
            m_axis_cw_tlast       <= #TCQ 1'b0;
            m_axis_cw_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
            m_axis_cw_tuser       <= #TCQ 22'b0;
            m_axis_rc_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
            m_axis_rc_tvalid_i    <= #TCQ 1'b0;
            m_axis_rc_tlast       <= #TCQ 1'b0;
            m_axis_rc_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
            m_axis_rc_tuser       <= #TCQ 22'b0;
            m_axis_cr_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
            m_axis_cr_tvalid_i    <= #TCQ 1'b0;
            m_axis_cr_tlast       <= #TCQ 1'b0;
            m_axis_cr_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
            m_axis_cr_tuser       <= #TCQ 22'b0;
            if(!data_hold_demux) begin
              if(data_prev_demux) begin // send previous data
                m_axis_cfg_tdata       <= #TCQ m_axis_rx_tdata_d;
                m_axis_cfg_tvalid_i    <= #TCQ m_axis_rx_tvalid_d;
                m_axis_cfg_tlast       <= #TCQ m_axis_rx_tlast_d;
                m_axis_cfg_tstrb       <= #TCQ m_axis_rx_tstrb_d;
                m_axis_cfg_tuser       <= #TCQ m_axis_rx_tuser_d;
              end
              else begin  // send current data
                m_axis_cfg_tdata       <= #TCQ m_axis_rx_tdata;
                m_axis_cfg_tvalid_i    <= #TCQ m_axis_rx_tvalid;
                m_axis_cfg_tlast       <= #TCQ m_axis_rx_tlast;
                m_axis_cfg_tstrb       <= #TCQ m_axis_rx_tstrb;
                m_axis_cfg_tuser       <= #TCQ m_axis_rx_tuser;
              end
            end
            else begin
              //hold data
            end

            //m_axis_rx_tready driving logic
            if(m_axis_cfg_tvalid_i)
              m_axis_rx_tready <= #TCQ m_axis_cfg_tready_i;
            else
              m_axis_rx_tready <= #TCQ 1'b1;
          end // MSI_pkt_128
          else begin : posted_pkt_128_bit
            pkt_type_p_np_cpl_cfg <= #TCQ POSTED; // route tp CW interface
            is_msi                <= #TCQ 1'b0;

            if(C_RX_PRESERVE_ORDER == "FALSE") begin
              m_axis_cfg_tdata      <= #TCQ {C_DATA_WIDTH{1'b0}};
              m_axis_cfg_tvalid_i   <= #TCQ 1'b0;
              m_axis_cfg_tlast      <= #TCQ 1'b0;
              m_axis_cfg_tstrb      <= #TCQ {STRB_WIDTH{1'b0}};
              m_axis_cfg_tuser      <= #TCQ 22'b0;
              m_axis_rc_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
              m_axis_rc_tvalid_i    <= #TCQ 1'b0;
              m_axis_rc_tlast       <= #TCQ 1'b0;
              m_axis_rc_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
              m_axis_rc_tuser       <= #TCQ 22'b0;
              m_axis_cr_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
              m_axis_cr_tvalid_i    <= #TCQ 1'b0;
              m_axis_cr_tlast       <= #TCQ 1'b0;
              m_axis_cr_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
              m_axis_cr_tuser       <= #TCQ 22'b0;        
              if(!data_hold_demux) begin
                if(data_prev_demux) begin // send previous data
                  m_axis_cw_tdata       <= #TCQ m_axis_rx_tdata_d;
                  m_axis_cw_tvalid_i    <= #TCQ m_axis_rx_tvalid_d;
                  m_axis_cw_tlast       <= #TCQ m_axis_rx_tlast_d;
                  m_axis_cw_tstrb       <= #TCQ m_axis_rx_tstrb_d;
                  m_axis_cw_tuser       <= #TCQ m_axis_rx_tuser_d;
                end
                else begin  // send current data
                  m_axis_cw_tdata       <= #TCQ m_axis_rx_tdata;
                  m_axis_cw_tvalid_i    <= #TCQ m_axis_rx_tvalid;
                  m_axis_cw_tlast       <= #TCQ m_axis_rx_tlast;
                  m_axis_cw_tstrb       <= #TCQ m_axis_rx_tstrb;
                  m_axis_cw_tuser       <= #TCQ m_axis_rx_tuser;
                end
              end
              else begin
                  //hold data
              end

              //m_axis_rx_tready driving logic
              if(m_axis_cw_tvalid_i)
                m_axis_rx_tready <= #TCQ m_axis_cw_tready_i;
              else
                m_axis_rx_tready <= #TCQ 1'b1;
            end
            // coverage off
            else begin
              m_axis_cfg_tdata      <= #TCQ {C_DATA_WIDTH{1'b0}};
              m_axis_cfg_tvalid_i   <= #TCQ 1'b0;
              m_axis_cfg_tlast      <= #TCQ 1'b0;
              m_axis_cfg_tstrb      <= #TCQ {STRB_WIDTH{1'b0}};
              m_axis_cfg_tuser      <= #TCQ 22'b0;
              m_axis_rc_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
              m_axis_rc_tvalid_i    <= #TCQ 1'b0;
              m_axis_rc_tlast       <= #TCQ 1'b0;
              m_axis_rc_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
              m_axis_rc_tuser       <= #TCQ 22'b0;
              m_axis_cw_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
              m_axis_cw_tvalid_i    <= #TCQ 1'b0;
              m_axis_cw_tlast       <= #TCQ 1'b0;
              m_axis_cw_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
              m_axis_cw_tuser       <= #TCQ 22'b0;    
              if(!data_hold_demux) begin
                if(data_prev_demux) begin // send previous data
                  m_axis_cr_tdata       <= #TCQ m_axis_rx_tdata_d;
                  m_axis_cr_tvalid_i    <= #TCQ m_axis_rx_tvalid_d;
                  m_axis_cr_tlast       <= #TCQ m_axis_rx_tlast_d;
                  m_axis_cr_tstrb       <= #TCQ m_axis_rx_tstrb_d;
                  m_axis_cr_tuser       <= #TCQ m_axis_rx_tuser_d;
                end
                else begin  // send current data
                  m_axis_cr_tdata       <= #TCQ m_axis_rx_tdata;
                  m_axis_cr_tvalid_i    <= #TCQ m_axis_rx_tvalid;
                  m_axis_cr_tlast       <= #TCQ m_axis_rx_tlast;
                  m_axis_cr_tstrb       <= #TCQ m_axis_rx_tstrb;
                  m_axis_cr_tuser       <= #TCQ m_axis_rx_tuser;
                end
              end
              else begin
                //hold data
              end

              //  m_axis_rx_tready driving logic
              if(m_axis_cr_tvalid_i)
                m_axis_rx_tready <= #TCQ m_axis_cr_tready_i;
              else
                m_axis_rx_tready <= #TCQ 1'b1;
            end
            // coverage on
          end //posted_pkt_128_bit
        end // 128_bit_data_posted_type_decode
      end // end of posted type decoding block

      //**********************************************************
      // Completion or Config Completion packet decode
      // Holds same for 32 bit, 64 bit and 128 bit aligned datas
      //**********************************************************

      else if(pkt_type[4:2] == 3'b010) begin
        if(!cfg_req) begin
          pkt_type_p_np_cpl_cfg <= #TCQ CPL; // route it to AXI -S RC interface
          m_axis_cfg_tdata      <= #TCQ {C_DATA_WIDTH{1'b0}};
          m_axis_cfg_tvalid_i   <= #TCQ 1'b0;
          m_axis_cfg_tlast      <= #TCQ 1'b0;
          m_axis_cfg_tstrb      <= #TCQ {STRB_WIDTH{1'b0}};
          m_axis_cfg_tuser      <= #TCQ 22'b0;
          m_axis_cr_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
          m_axis_cr_tvalid_i    <= #TCQ 1'b0;
          m_axis_cr_tlast       <= #TCQ 1'b0;
          m_axis_cr_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
          m_axis_cr_tuser       <= #TCQ 22'b0;
          m_axis_cw_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
          m_axis_cw_tvalid_i    <= #TCQ 1'b0;
          m_axis_cw_tlast       <= #TCQ 1'b0;
          m_axis_cw_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
          m_axis_cw_tuser       <= #TCQ 22'b0;
          if(!data_hold_demux) begin
            if(data_prev_demux) begin // send previous data
              m_axis_rc_tdata       <= #TCQ m_axis_rx_tdata_d;
              m_axis_rc_tvalid_i    <= #TCQ m_axis_rx_tvalid_d;
              m_axis_rc_tlast       <= #TCQ m_axis_rx_tlast_d;
              m_axis_rc_tstrb       <= #TCQ m_axis_rx_tstrb_d;
              m_axis_rc_tuser       <= #TCQ m_axis_rx_tuser_d;
            end
            else begin  // send current data
              m_axis_rc_tdata       <= #TCQ m_axis_rx_tdata;
              m_axis_rc_tvalid_i    <= #TCQ m_axis_rx_tvalid;
              m_axis_rc_tlast       <= #TCQ m_axis_rx_tlast;
              m_axis_rc_tstrb       <= #TCQ m_axis_rx_tstrb;
              m_axis_rc_tuser       <= #TCQ m_axis_rx_tuser;
            end
          end
          else begin
            //hold data
          end

          //m_axis_rx_tready driving logic
          if(m_axis_rc_tvalid_i)
            m_axis_rx_tready <= #TCQ m_axis_rc_tready_i;
          else
            m_axis_rx_tready <= #TCQ 1'b1;
        end // end of !cfg_req loop
        else begin
          pkt_type_p_np_cpl_cfg <= #TCQ CFG;
          m_axis_rc_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
          m_axis_rc_tvalid_i    <= #TCQ 1'b0;
          m_axis_rc_tlast       <= #TCQ 1'b0;
          m_axis_rc_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
          m_axis_rc_tuser       <= #TCQ 22'b0;
          m_axis_cr_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
          m_axis_cr_tvalid_i    <= #TCQ 1'b0;
          m_axis_cr_tlast       <= #TCQ 1'b0;
          m_axis_cr_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
          m_axis_cr_tuser       <= #TCQ 22'b0;
          m_axis_cw_tdata       <= #TCQ {C_DATA_WIDTH{1'b0}};
          m_axis_cw_tvalid_i    <= #TCQ 1'b0;
          m_axis_cw_tlast       <= #TCQ 1'b0;
          m_axis_cw_tstrb       <= #TCQ {STRB_WIDTH{1'b0}};
          m_axis_cw_tuser       <= #TCQ 22'b0;
          is_msi                <= #TCQ 22'b0;
          if(!data_hold_demux) begin
            if(data_prev_demux) begin // send previous data
              m_axis_cfg_tdata       <= #TCQ m_axis_rx_tdata_d;
              m_axis_cfg_tvalid_i    <= #TCQ m_axis_rx_tvalid_d;
              m_axis_cfg_tlast       <= #TCQ m_axis_rx_tlast_d;
              m_axis_cfg_tstrb       <= #TCQ m_axis_rx_tstrb_d;
              m_axis_cfg_tuser       <= #TCQ m_axis_rx_tuser_d;
            end
            else begin  // send current data
              m_axis_cfg_tdata       <= #TCQ m_axis_rx_tdata;
              m_axis_cfg_tvalid_i    <= #TCQ m_axis_rx_tvalid;
              m_axis_cfg_tlast       <= #TCQ m_axis_rx_tlast;
              m_axis_cfg_tstrb       <= #TCQ m_axis_rx_tstrb;
              m_axis_cfg_tuser       <= #TCQ m_axis_rx_tuser;
            end
          end
          else begin
            //hold data
          end

          //m_axis_rx_tready driving logic
          if(m_axis_cfg_tvalid_i)
            m_axis_rx_tready <= #TCQ m_axis_cfg_tready_i;
          else
            m_axis_rx_tready <= #TCQ 1'b1;
        end
      end
    end // reset else block end
  end // end of decoding block

endmodule
