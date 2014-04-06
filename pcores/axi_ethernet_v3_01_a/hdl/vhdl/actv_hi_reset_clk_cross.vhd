------------------------------------------------------------------------------
-- actv_hi_reset_clk_cross - entity and arch
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
-- Copyright 2009, 2010 Xilinx, Inc.
-- All rights reserved.
--
-- This disclaimer and copyright notice must be retained as part
-- of this file at all times.
--
------------------------------------------------------------------------------
-- Filename:        actv_hi_reset_clk_cross.vhd
-- Version:         v1.00a
-- Description:     This module converts an active high pulse from one clock to
--                   the other clock domain ensuring a pulse is detected
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to improve
--              readability.
--
--              actv_hi_reset_clk_cross.vhd
--
--              This section is optional for common/shared modules but should
--              contain a statement stating it is a common/shared module.
------------------------------------------------------------------------------
-- Author:      MSH
-- History:
-- MSH  10/28/2009
--        -- Initial design
--
--
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
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity actv_hi_reset_clk_cross is
    port    (
             ClkA               : in  std_logic;  --  Clock A input
             ClkAEN             : in  std_logic;  --  Enable signal clocked from clock A input
             ClkARst            : in  std_logic;  --  Clock A reset
             ClkAOutOfClkBRst   : out std_logic;  --  Held high until Clk B rst transitions LOW and is recognized by ClkA/CLKAEn
             ClkACombinedRstOut : out std_logic;  --  Held High until ClkBRst is detected LOW by ClkA/ClkAEn
             ClkB               : in  std_logic;  --  Clock B input
             ClkBEN             : in  std_logic;  --  Enable signal clocked from clock B input
             ClkBRst            : in  std_logic;  --  Clock B reset
             ClkBOutOfClkARst   : out std_logic;  --  Held high until Clk A rst transitions LOW and is recognized by ClkB/CLKBEn
             ClkBCombinedRstOut : out std_logic   --  Held High until ClkARst is detected LOW by ClkB/ClkBEn
            );
end actv_hi_reset_clk_cross;

architecture imp of actv_hi_reset_clk_cross is

  signal ClkARstInDetected    : std_logic;
  signal ClkBRstInCaptured    : std_logic;

  signal ClkBRstInDetected    : std_logic;
  signal ClkARstInCaptured    : std_logic;

  begin

    ClkBOutOfClkARst <= ClkBRstInCaptured;
    ClkAOutOfClkBRst <= ClkARstInCaptured;

    DETECT_RST_CLK_A : process(ClkA)
    begin
      if rising_edge(ClkA) then
        if ClkARst = '1' then
          ClkARstInDetected <= '1';
        else
          if (ClkAEN = '1') then
            if ClkBRstInCaptured = '1' then
              ClkARstInDetected <= '0';
            else
              ClkARstInDetected <= ClkARstInDetected;
            end if;
          end if;
        end if;
      end if;
    end process;

    CAPTURE_RST_CLK_B : process(ClkB)
    begin
      if rising_edge(ClkB) then
        if ClkBRst = '1' then
          ClkBRstInCaptured <= '1';
        else
          if ClkARstInDetected = '1' then
            ClkBRstInCaptured <= '1';
          elsif (ClkBEN = '1') then
            ClkBRstInCaptured <= '0';
          end if;
        end if;
      end if;
    end process;

    CAPTURE_RST_CLK_B1 : process(ClkB)
    begin
      if rising_edge(ClkB) then
        if ClkBRst = '1' then
          ClkBCombinedRstOut<= '1';
        else
          if ClkARstInDetected = '1' then
            ClkBCombinedRstOut<= '1';
          elsif (ClkBEN = '1') then
            ClkBCombinedRstOut<= '0';
          end if;
        end if;
      end if;
    end process;

    DETECT_RST_CLK_B : process(ClkB)
    begin
      if rising_edge(ClkB) then
        if ClkBRst = '1' then
          ClkBRstInDetected <= '1';
        else
          if (ClkBEN = '1') then
            if ClkARstInCaptured = '1' then
              ClkBRstInDetected <= '0';
            else
              ClkBRstInDetected <= ClkBRstInDetected;
            end if;
          end if;
        end if;
      end if;
    end process;

    CAPTURE_RST_CLK_A : process(ClkA)
    begin
      if rising_edge(ClkA) then
        if ClkARst = '1' then
          ClkARstInCaptured <= '1';
          ClkACombinedRstOut<= '1';
        else
          if (ClkAEN = '1') then
            if ClkBRstInDetected = '1' then
              ClkARstInCaptured <= '1';
              ClkACombinedRstOut<= '1';
            else
              ClkARstInCaptured <= '0';
              ClkACombinedRstOut<= '0';
            end if;
          end if;
        end if;
      end if;
    end process;
end imp;
