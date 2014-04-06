------------------------------------------------------------------------------
-- $Id: bus2ghi.vhd,v 1.1.2.2 2010/10/22 20:15:57 shurt Exp $
------------------------------------------------------------------------------
-- bus2ghi.vhd
------------------------------------------------------------------------------
--
-- DISCLAIMER OF LIABILITY
--
-- This file contains proprietary and confidential information of
-- Xilinx, Inc. ("Xilinx"), that is distributed under a license
-- from Xilinx, and may be used, copied and/or disclosed only
-- pursuant to the terms of a valid license agreement with Xilinx.
--
-- XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION
-- ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
-- EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT
-- LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,
-- MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx
-- does not warrant that functions included in the Materials will
-- meet the requirements of Licensee, or that the operation of the
-- Materials will be uninterrupted or error-free, or that defects
-- in the Materials will be corrected. Furthermore, Xilinx does
-- not warrant or make any representations regarding use, or the
-- results of the use, of the Materials in terms of correctness,
-- accuracy, reliability or otherwise.
--
-- Xilinx products are not designed or intended to be fail-safe,
-- or for use in any application requiring fail-safe performance,
-- such as life-support or safety devices or systems, Class III
-- medical devices, nuclear facilities, applications related to
-- the deployment of airbags, or any other applications that could
-- lead to death, personal injury or severe property or
-- environmental damage (individually and collectively, "critical
-- applications"). Customer assumes the sole risk and liability
-- of any use of Xilinx products in critical applications,
-- subject only to applicable laws and regulations governing
-- limitations on product liability.
--
-- Copyright 2000, 2001, 2002, 2003, 2004, 2005, 2008 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
--

------------------------------------------------------------------------------
-- Filename:        bus2ghi.vhd
-- Version:         v3.00a
-- Description:     top level of bus2ghi
--
------------------------------------------------------------------------------
-- Structure:   
--              bus2ghi.vhd
--
------------------------------------------------------------------------------
-- Change log:
-------------------------------------------------------------------------------
-- @BEGIN_CHANGELOG EDK_J_SP2
--  ***************************************************************************
--
--   New core
--
--  ***************************************************************************
-- 
-- @END_CHANGELOG 
-------------------------------------------------------------------------------
-- Author:      MSH
-- History:
--   MSH           05/13/05    First version
-- ^^^^^^
--      First release
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
--      combinatorial signals:                  "*_com" 
--      pipelined or register delay signals:    "*_d#" 
--      counter signals:                        "*cnt*"
--      clock enable signals:                   "*_ce" 
--      internal version of output port         "*_i"
--      device pins:                            "*_pin" 
--      ports:                                  - Names begin with Uppercase 
--      processes:                              "*_PROCESS" 
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

library unisim;
use unisim.vcomponents.all;

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity bus2ghi is
  port (
    -- Bus Interface
    BusClk          : in  std_logic;  -- must be same as HostClk to target
    BusRst          : in  std_logic;
    BusCs           : in  std_logic;
    BusRd           : in  std_logic;
    BusAddr         : in  std_logic_vector(0 to 31);
    BusAck          : out std_logic;
    BusRdData       : out std_logic_vector(0 to 31);
       
    -- Generic Host Interface
    HostAddr        : out std_logic_vector(9 downto 0);
    HostReq         : out std_logic;
    HostMiiMSel     : out std_logic;
    HostRdData      : in  std_logic_vector(31 downto 0);
    HostStatsLswRdy : in  std_logic;
    HostStatsMswRdy : in  std_logic
    );
   
end bus2ghi;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture imp of bus2ghi is

------------------------------------------------------------------------------
--  Constant Declarations
------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Function declarations
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Type Declarations
-----------------------------------------------------------------------------


------------------------------------------------------------------------------
-- Signal and Type Declarations
------------------------------------------------------------------------------

  signal host_address        : std_logic_vector(9 downto 0);
  signal stats_upper_word    : std_logic;
  signal host_address_bit10  : std_logic;
  signal host_stats_msw      : std_logic_vector(31 downto 0);
  signal host_stats_lsw      : std_logic_vector(31 downto 0);
  signal host_rd_data_result : std_logic_vector(31 downto 0);
  signal cpu_rd_data_en      : std_logic;
  signal hostReq_i           : std_logic;
  signal busCs_d1            : std_logic;
  signal busAck_i            : std_logic;
-----------------------------------------------------------------------------
-- Begin architecture
-----------------------------------------------------------------------------

begin
  PIPE_CS_PROCESS : process (BusClk)
  begin
    if BusClk'event and BusClk = '1' then
      if BusRst = '1' then
        busCs_d1       <= '0';
      else
        busCs_d1       <= BusCs;
      end if;
    end if;
  end process PIPE_CS_PROCESS;

  -- Sample Address and Data onto MAC Host Bus.

  -- Confused with addressing?
  -- Here we ignore the bottom 3 address bits of cpu_addr because the
  -- bus addresses bytes NOT words.  Since each MAC word is fit into a
  -- single 64-bit bus word for simplicity, when addressing a word,
  -- cpu_addr bit 3 and upwards will change. (cpu_addr[29:31] would
  -- address individual bytes within the 64-bit word).

  HOST_ADDRESS_PROCESS : process (BusClk)
  begin
    if BusClk'event and BusClk = '1' then
      if BusRst = '1' then
        host_address_bit10       <= '0';
        host_address(9 downto 0) <= (others => '0');
        stats_upper_word         <= '0';
      else
        if (BusCs = '1') then    
          host_address_bit10       <= BusAddr(18);
          host_address(9 downto 0) <= "0000" & BusAddr(23 to 28);
          stats_upper_word         <= BusAddr(29);
        end if;
      end if;
    end if;
  end process HOST_ADDRESS_PROCESS;

  -- host_address is an internal signal: assign to output
  Hostaddr <= host_address;
  
  -- Create host_miim_sel which signifies MDIO space or not
      
  HostMiiMSel <= '0';

  -- Create host_req 

  HOST_REQ_PROCESS : process (BusClk)
  begin
    if BusClk'event and BusClk = '1' then
      if BusRst = '1' then
        hostReq_i       <= '0';
      else
        hostReq_i <= (BusCs and not(busCs_d1));            -- clear - stats received
      end if;
    end if;
  end process HOST_REQ_PROCESS;
HostReq <= hostReq_i;
  -- Capture lower word of statistical read

  HOST_STATS_LSW_PROCESS : process (BusClk)
  begin
    if BusClk'event and BusClk = '1' then
      if BusRst = '1' then
        host_stats_lsw       <= (others => '0');
      else
        if (HostStatsLswRdy = '1') then    
          host_stats_lsw       <= HostRdData;
        end if;
      end if;
    end if;
  end process HOST_STATS_LSW_PROCESS;

  -- Capture upper word of statistical read

  HOST_STATS_MSW_PROCESS : process (BusClk)
  begin
    if BusClk'event and BusClk = '1' then
      if BusRst = '1' then
        host_stats_msw       <= (others => '0');
      else
        if (HostStatsMswRdy = '1') then    
          host_stats_msw       <= HostRdData;
        end if;
      end if;
    end if;
  end process HOST_STATS_MSW_PROCESS;

  -- Sample Read Data onto Host Bus

  HOST_READ_DATA_RESULTS_PROCESS : process (BusClk)
  begin
    if BusClk'event and BusClk = '1' then
      if BusRst = '1' then
        host_rd_data_result       <= (others => '0');
      else
        if (BusCs = '1') then    
          if (host_address_bit10 = '0' and host_address(9) = '0') then    
            if (stats_upper_word = '1') then    
              host_rd_data_result       <= host_stats_msw;
            else
              host_rd_data_result       <= host_stats_lsw;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process HOST_READ_DATA_RESULTS_PROCESS;

  HOST_TOGGLE_CPU_REG_PROCESS : process (BusClk)
  begin
    if BusClk'event and BusClk = '1' then
      if BusRst = '1' then
        busAck_i <= '0';
        BusAck   <= '0';
      else
        busAck_i <= HostStatsMswRdy;
        BusAck   <= busAck_i;
      end if;
    end if;
  end process HOST_TOGGLE_CPU_REG_PROCESS;

  -- Create an enable signal for driving data onto the cpu_rd_data bus

  CPU_RD_DATA_EN_PROCESS : process (BusClk)
  begin
    if BusClk'event and BusClk = '1' then
      if BusRst = '1' then
        cpu_rd_data_en       <= '0';
      else
        if (BusRd = '1' and BusCs = '1') then    
          cpu_rd_data_en       <= '1';
        else    
          cpu_rd_data_en       <= '0';
        end if;
      end if;
    end if;
  end process CPU_RD_DATA_EN_PROCESS;

  -- Sample Read Data onto generic CPU Bus

  PLB_RD_DATA_PROCESS : process (BusClk)
  begin
    if BusClk'event and BusClk = '1' then
      if BusRst = '1' then
        BusRdData       <= (others => '0');
      else
        if (cpu_rd_data_en = '1') then    
          BusRdData       <= host_rd_data_result;
        else    
          BusRdData       <= (others => '0');
        end if;
      end if;
    end if;
  end process PLB_RD_DATA_PROCESS;

end imp;
