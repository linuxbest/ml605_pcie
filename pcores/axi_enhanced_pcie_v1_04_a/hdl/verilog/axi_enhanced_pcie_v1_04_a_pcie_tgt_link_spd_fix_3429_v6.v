//-----------------------------------------------------------------------------
//
// (c) Copyright 2009-2011 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
// Project    : Virtex-6 Integrated Block for PCI Express
// File       : axi_enhanced_pcie_v1_04_a_pcie_tgt_link_spd_fix_3429_v6.v
// Version    : 2.3
//--
//-- Description: Virtex6 Workaround for Root Port Target Link Speed Bug
//--
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

module axi_enhanced_pcie_v1_04_a_pcie_tgt_link_spd_fix_3429_v6 (

  // Common
  input                                         trn_clk,
  input                                         trn_reset_n,
  input                                         trn_lnk_up_n,

  input   [9:0]                                 cfg_dwaddr,
  input  [31:0]                                 cfg_di,
  input   [3:0]                                 cfg_byte_en_n,
  input                                         cfg_rd_wr_done_n,
  input                                         cfg_wr_en_n,
  input                                         cfg_rd_en_n,

  input   [1:0]                                 capability_speed,   // 01 - Gen1, 10 - Gen2
  input   [1:0]                                 current_speed,      // 01 - Gen1, 10 - Gen2

  input  [5:0]                                  pl_ltssm_state,     
  input                                         pl_sel_link_rate,
  input                                         pl_link_gen2_capable,

  output [1:0]                                  pl_directed_link_change,
  output                                        pl_directed_link_speed

);

  parameter TCQ = 1;
  parameter AUTO_SPD_CHG_RESET = 1'b0;
  parameter AUTO_SPD_CHG_DONE  = 1'b1;

  reg  [1:0]                                   reg_tgt_lnk_spd = 2'b00;
  wire [1:0]                                   tgt_lnk_spd;

  reg                                          reg_first_tgt_spd_chg = 1'b0; 
  wire                                         first_tgt_spd_chg;

  reg  [1:0]                                   reg_new_tgt_lnk_spd = 2'b00;
  wire [1:0]                                   new_tgt_lnk_spd;

  reg  [1:0]                                   reg_pl_directed_link_change;
  reg                                          reg_pl_directed_link_speed;

  reg                                          reg_change_speed;
  wire                                         change_speed;

  reg                                          reg_auto_change_speed;

  reg   [0:0]                                  reg_state_auto_spd;
  wire  [0:0]                                  state_auto_spd;


  // Logic that tracks tgt link speed
  always @(posedge trn_clk)
    reg_tgt_lnk_spd <= #TCQ first_tgt_spd_chg ? new_tgt_lnk_spd : capability_speed;

  assign tgt_lnk_spd = reg_tgt_lnk_spd;

  // Logic to snoop the cfg interface
  always @(posedge trn_clk) begin

    reg_change_speed <= #TCQ 1'b0; 

    case (cfg_dwaddr)

      // Access offset 30H, target_link_speed byte0:bits[3:0] 
      10'h24 : begin

        if ((cfg_wr_en_n == 1'b0) && 
            (cfg_byte_en_n[0] == 1'b0) && 
            (cfg_rd_wr_done_n == 1'b0)) begin

          // unconditionally update
          reg_new_tgt_lnk_spd <= #TCQ cfg_di[1:0];  

          if (first_tgt_spd_chg == 1'b0)
            reg_first_tgt_spd_chg <= #TCQ 1'b1;

        end

      end

      // Access offset 10H, link_retrain byte0:bit5
      10'h1c : begin

        // If we've a gen2 port, then consider speed change
        if (capability_speed == 2'b10)
          if ((cfg_wr_en_n == 1'b0) && 
              (cfg_byte_en_n[0] == 1'b0) && 
              (cfg_di[5] == 1'b1) && 
              (cfg_rd_wr_done_n == 1'b0) && 
              (pl_ltssm_state == 6'h16))
            reg_change_speed <= #TCQ 1'b1; 

      end

    endcase 

  end

  assign change_speed = reg_change_speed | reg_auto_change_speed;
  assign first_tgt_spd_chg = reg_first_tgt_spd_chg;
  assign new_tgt_lnk_spd = reg_new_tgt_lnk_spd;

  // Speed Change Logic
  always @(posedge trn_clk) begin

    // Ignore speed changes if trn_lnk_up_n is de-asserted.
    if (!trn_reset_n) begin

      reg_pl_directed_link_change <= #TCQ 2'b00;
      reg_pl_directed_link_speed <= #TCQ 1'b0;

    end else begin

      case (pl_ltssm_state)

        // When in L0
        6'h16: begin

          if (change_speed) begin
    
            reg_pl_directed_link_change <= #TCQ 2'b10;
            reg_pl_directed_link_speed <= #TCQ  tgt_lnk_spd[1] ? 1'b1 : 1'b0;
  
          end 
      
        end    
      
        // Then, in Recovery.Idle
        6'h20: begin
   
          if (pl_directed_link_change != 2'b00) begin
  
            reg_pl_directed_link_change <= #TCQ 2'b00;
            reg_pl_directed_link_speed <= #TCQ 1'b0;
          
          end
  
        end

      endcase

    end

  end

  // Auto Speed Change Logic
  always @(posedge trn_clk) begin

    if (!trn_reset_n) begin

      reg_auto_change_speed <= 1'b0;
      reg_state_auto_spd <= #TCQ AUTO_SPD_CHG_RESET;

    end else begin

      case (state_auto_spd)

        AUTO_SPD_CHG_RESET : begin

          if (pl_ltssm_state == 6'h16) begin

            if ((pl_link_gen2_capable == 1'b1) &&
                (capability_speed == 2'b10)) begin

              reg_auto_change_speed <= #TCQ 1'b1;
              reg_state_auto_spd <= #TCQ AUTO_SPD_CHG_DONE;

            end else begin

              reg_auto_change_speed <= #TCQ 1'b0;
              reg_state_auto_spd <= #TCQ AUTO_SPD_CHG_DONE;

            end

          end else begin

            reg_auto_change_speed <= #TCQ 1'b0;
            reg_state_auto_spd <= #TCQ AUTO_SPD_CHG_RESET;

          end

        end 

        AUTO_SPD_CHG_DONE : begin

          reg_auto_change_speed <= #TCQ 1'b0;
          reg_state_auto_spd <= #TCQ AUTO_SPD_CHG_DONE;

        end 

      endcase

    end

  end
  assign state_auto_spd = reg_state_auto_spd;

  assign pl_directed_link_change = reg_pl_directed_link_change;
  assign pl_directed_link_speed = reg_pl_directed_link_speed;

endmodule
