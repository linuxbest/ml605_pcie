------------------------------------------------------------------------------
-- rx_axistream_client_shim.vhd
------------------------------------------------------------------------------
--
-- *************************************************************************
--
-- (c) Copyright 2004-2011 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-- *************************************************************************
--
-- ------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
-- Filename:        rx_axistream_client_shim.vhd
-- Description:     Receive interface between TEMAC RX AXIStream and Client AVB
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to rtlrove
--              readability.
--
--              top_level.vhd
--                  -- second_level_file1.vhd
--                      -- third_level_file1.vhd
--                          -- fourth_level_file.vhd
--                      -- third_level_file2.vhd
--                  -- second_level_file2.vhd
--                  -- second_level_file3.vhd
--
--              This section is optional for common/shared modules but should
--              contain a statement stating it is a common/shared module.
------------------------------------------------------------------------------
-- Author:          MSH
--
--  MSH     03/17/11
-- ^^^^^^
--  - Initial release of v1.00.a
-- ~~~~~~
------------------------------------------------------------------------------
-- Naming Conventions:
--      active low signals:                     "*_n"
--      clock signals:                          "clk", "clk_div#", "clk_#x"
--      reset signals:                          "rst", "rst_n"
--      generics:                               "C_*"
--      user defined types:                     "*_TYPE"
--      state machine next state:               "*_ns"
--      state machine current state:            "*_cs"
--      combinatorial signals:                  "*_cmb"
--      pipelined or register delay signals:    "*_d#"
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce"
--      internal version of : out   std_logic; port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Libraries used;
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.coregen_comp_defs.all;
use proc_common_v3_00_a.proc_common_pkg.log2;
use proc_common_v3_00_a.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

-------------------------------------------------------------------------------
-- Definition of Generics :
-------------------------------------------------------------------------------
-- System generics
--  C_FAMILY              -- Xilinx FPGA Family

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Ports :
-------------------------------------------------------------------------------
--    RXSPEEDIS10100          
--                            
--    RX_MAC_ACLK             
--    RX_RESET                
--    RX_AXIS_MAC_TDATA       
--    RX_AXIS_MAC_TVALID      
--    RX_AXIS_MAC_TLAST       
--    RX_AXIS_MAC_TUSER       
--    
--    RX_CLIENT_CLK           
--    RESET2RX_CLIENT         
--    EMAC_CLIENT_RX_GOODFRAME
--    EMAC_CLIENT_RX_BADFRAME 
--    EMAC_CLIENT_RXD_VLD     
--    RX_CLIENT_CLK_ENBL      
--    EMAC_CLIENT_RXD         
--    
-------------------------------------------------------------------------------
----                  Entity Section
-------------------------------------------------------------------------------

entity rx_axistream_client_shim is
  generic (
    C_FAMILY              : string                        := "virtex6"
    );
  port    (                                                                       
    RX_MAC_ACLK                : in  std_logic;                    
    RX_RESET                   : in  std_logic;                    
    RX_AXIS_MAC_TDATA          : in  std_logic_vector(7 downto 0); 
    RX_AXIS_MAC_TVALID         : in  std_logic;                    
    RX_AXIS_MAC_TLAST          : in  std_logic;                    
    RX_AXIS_MAC_TUSER          : in  std_logic;                    

    -- added 05/5/2011     
    RX_CLK_ENABLE_IN           : in std_logic;

    RX_CLIENT_CLK              : out std_logic;
    RESET2RX_CLIENT            : out std_logic;
    EMAC_CLIENT_RXD_VLD        : out std_logic;
    RX_CLIENT_CLK_ENBL         : out std_logic;
    EMAC_CLIENT_RXD            : out std_logic_vector(7 downto 0)
    );
end rx_axistream_client_shim;


------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of rx_axistream_client_shim is

------------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------------


------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------

type RECEIVE_DATA_VALID_GEN_SM_TYPE is (
       IDLE,
       RECEIVING_NOW
     );

signal receive_data_valid_gen_current_state : RECEIVE_DATA_VALID_GEN_SM_TYPE;
signal receive_data_valid_gen_next_state    : RECEIVE_DATA_VALID_GEN_SM_TYPE;


signal emac_client_rxd_vld_i      : std_logic;

signal derived_rx_clk_enbl             : std_logic;
signal derived_rx_clk_enbl_reg1        : std_logic;
signal derived_rx_clk_enbl_reg2        : std_logic;
signal derived_rx_clk_enbl_cmb         : std_logic;

signal rx_axis_mac_tvalid_d1      : std_logic;                    
signal rx_axis_mac_tvalid_d2      : std_logic;                    
signal rx_axis_mac_tvalid_d3      : std_logic; 

signal rx_tvalid_end              : std_logic;    

signal rx_tvalid                  : std_logic;
signal rx_tvalid_d1               : std_logic;
signal rx_tvalid_d2               : std_logic;

signal no_stripping               : std_logic;
signal no_stripping_d1            : std_logic;
signal no_stripping_d2            : std_logic;
signal no_stripping_d3            : std_logic;

signal rx_axis_mac_tlast_d1            : std_logic;
signal rx_axis_mac_tlast_d2            : std_logic;
signal rx_axis_mac_tlast_d3            : std_logic;

signal rx_tvalid_start        : std_logic;                    
signal rx_tvalid_d3           : std_logic;
signal rx_tvalid_d4           : std_logic;

begin

  RX_CLIENT_CLK   <= RX_MAC_ACLK;
  RESET2RX_CLIENT <= RX_RESET;

  --------------------------------------------------------------------------
  -- receive data valid gen State Machine
  -- RXDVLDSM_REGS_PROCESS: registered process of the state machine
  -- RXDVLDSM_CMB_PROCESS:  combinatorial next-state logic
  --------------------------------------------------------------------------

  RXDVLDSM_REGS_PROCESS: process (rx_mac_aclk)
  begin
    if rising_edge(rx_mac_aclk) then
      if rx_reset = '1' then
        receive_data_valid_gen_current_state <= IDLE;
        derived_rx_clk_enbl_reg1 <= '0';
        derived_rx_clk_enbl_reg2 <= '0';
      else
        receive_data_valid_gen_current_state <= receive_data_valid_gen_next_state;
        derived_rx_clk_enbl_reg1 <= derived_rx_clk_enbl_cmb after 1 ps;
        derived_rx_clk_enbl_reg2 <= derived_rx_clk_enbl_reg1 after 1 ps;
      end if;
    end if;
  end process;

  
  RXDVLDSM_CMB_PROCESS: process (
    RX_CLK_ENABLE_IN,
    rx_axis_mac_tvalid,
    rx_axis_mac_tlast
    )
  begin

    case receive_data_valid_gen_current_state is

      when IDLE =>
        if (rx_axis_mac_tvalid = '1') then
          receive_data_valid_gen_next_state <= RECEIVING_NOW;
          derived_rx_clk_enbl_cmb           <= rx_axis_mac_tvalid;
        else
          receive_data_valid_gen_next_state <= IDLE;
          derived_rx_clk_enbl_cmb           <= RX_CLK_ENABLE_IN;
        end if;

      when RECEIVING_NOW =>
        if (rx_axis_mac_tlast = '1') then
          receive_data_valid_gen_next_state <= IDLE;
          derived_rx_clk_enbl_cmb           <= rx_axis_mac_tvalid;
        else
          receive_data_valid_gen_next_state <= RECEIVING_NOW;
          derived_rx_clk_enbl_cmb           <= rx_axis_mac_tvalid;
        end if;

      when others   =>
        receive_data_valid_gen_next_state   <= IDLE;
        derived_rx_clk_enbl_cmb             <= RX_CLK_ENABLE_IN;
    end case;
  end process;

  RX_CLIENT_CLK_ENBL <= derived_rx_clk_enbl;
  EMAC_CLIENT_RXD_VLD<= emac_client_rxd_vld_i;
   
  detect_stripping: process (RX_MAC_ACLK)
  begin
    if rising_edge(RX_MAC_ACLK) then
      if RX_RESET = '1' then
        no_stripping    <= '0';
        no_stripping_d1 <= '0';
        no_stripping_d2 <= '0';
        no_stripping_d3 <= '0';
      elsif (RX_AXIS_MAC_TLAST = '1') and (rx_tvalid_d1 = '1') then 
        no_stripping    <= '1';
        no_stripping_d1 <= no_stripping;
        no_stripping_d2 <= no_stripping_d1;
        no_stripping_d3 <= no_stripping_d2;
      elsif (rx_tvalid_end = '1' or rx_tvalid_d4 = '1') then 
        no_stripping    <= '0';
        no_stripping_d1 <= no_stripping;
        no_stripping_d2 <= no_stripping_d1;
        no_stripping_d3 <= no_stripping_d2;
      else
        no_stripping    <= no_stripping;
        no_stripping_d1 <= no_stripping;
        no_stripping_d2 <= no_stripping_d1;
        no_stripping_d3 <= no_stripping_d2;
      end if;
    end if;
   end process detect_stripping;

  CREATE_RX_AXIS_MAC_TVALID_PROCESS: process (rx_mac_aclk)
  begin
    if rising_edge(rx_mac_aclk) then
      if rx_reset = '1' then
        rx_axis_mac_tvalid_d1 <= '0';
        rx_axis_mac_tvalid_d2    <= '0';                    
        rx_axis_mac_tvalid_d3    <= '0';                    
      else
        if rx_axis_mac_tlast = '1' then
          rx_axis_mac_tvalid_d1 <= '0';
          rx_axis_mac_tvalid_d2 <= rx_axis_mac_tvalid_d1;                    
          rx_axis_mac_tvalid_d3 <= rx_axis_mac_tvalid_d2;                    
        else
          rx_axis_mac_tvalid_d1 <= rx_axis_mac_tvalid;                    
          rx_axis_mac_tvalid_d2 <= rx_axis_mac_tvalid_d1;                    
          rx_axis_mac_tvalid_d3 <= rx_axis_mac_tvalid_d2;                    
        end if;
      end if;
    end if;
  end process CREATE_RX_AXIS_MAC_TVALID_PROCESS;



  CREATE_EMAC_CLIENT_RXD_VLD_PROCESS: process (rx_mac_aclk)
  begin
    if rising_edge(rx_mac_aclk) then
      if rx_reset = '1' then
        emac_client_rxd_vld_i       <= '0';
        rx_axis_mac_tlast_d1     <= '0';
        rx_axis_mac_tlast_d2     <= '0';
        rx_axis_mac_tlast_d3     <= '0';
        rx_tvalid_start <= '0';                    
        rx_tvalid_end   <= '0';     
        rx_tvalid       <= '0';
        rx_tvalid_d1    <= '0';
        rx_tvalid_d2    <= '0';
        rx_tvalid_d3    <= '0';
        rx_tvalid_d4    <= '0';
      else
        rx_tvalid_d1    <= rx_tvalid;
        rx_tvalid_d2    <= rx_tvalid_d1;
        rx_tvalid_d3    <= rx_tvalid_d2;
        rx_tvalid_d4    <= rx_tvalid_d3;

        if (rx_axis_mac_tvalid = '0') and (rx_axis_mac_tvalid_d1 = '0') and (rx_axis_mac_tvalid_d3 = '1') then
          rx_tvalid_end <= '1';                    
        else
          rx_tvalid_end <= '0';                    
        end if;

        if (RX_AXIS_MAC_TVALID = '1') and (rx_axis_mac_tvalid_d1 = '0') and (rx_axis_mac_tvalid_d2 = '0') and (rx_axis_mac_tvalid_d3 = '0') and (RX_AXIS_MAC_TLAST = '0')then
          rx_tvalid_start <= '1';                    
        else
          rx_tvalid_start <= '0';                    
        end if;

          if rx_axis_mac_tlast = '1' and rx_axis_mac_tvalid_d1 = '0' then
            emac_client_rxd_vld_i  <= '0';
          else
            emac_client_rxd_vld_i  <= rx_axis_mac_tvalid or rx_axis_mac_tvalid_d1;
          end if;
       
        rx_axis_mac_tlast_d1     <= rx_axis_mac_tlast;
        rx_axis_mac_tlast_d2     <= rx_axis_mac_tlast_d1;
        rx_axis_mac_tlast_d3     <= rx_axis_mac_tlast_d2;
      end if;
    end if;
  end process CREATE_EMAC_CLIENT_RXD_VLD_PROCESS;



  CREATE_EMAC_CLIENT_RXD_LEGACY_PROCESS: process (rx_mac_aclk)
  begin
    if rising_edge(rx_mac_aclk) then
      if rx_reset = '1' then
        EMAC_CLIENT_RXD  <= (others => '0');
      else

        EMAC_CLIENT_RXD  <= rx_axis_mac_tdata;
      end if;
    end if;
  end process CREATE_EMAC_CLIENT_RXD_LEGACY_PROCESS;

end rtl;   
