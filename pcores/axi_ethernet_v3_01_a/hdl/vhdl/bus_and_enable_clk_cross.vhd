------------------------------------------------------------------------------
-- bus_and_enable_clk_cross - entity and arch
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
-- Filename:        bus_and_enable_clk_cross.vhd
-- Version:         v1.00a
-- Description:     This module converts an active high pulse from one clock to
--                   the other clock domain ensuring a pulse is detected
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to improve
--              readability.
--
--              bus_and_enable_clk_cross.vhd
--
--              This section is optional for common/shared modules but should
--              contain a statement stating it is a common/shared module.
------------------------------------------------------------------------------
-- Author:      MW
-- History:
-- MW  05/17/2010
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

entity bus_and_enable_clk_cross is
  generic (
    C_BUS_WIDTH    : integer range 2 to 64 := 8
  );
  port(
    ClkA          : in  std_logic;                                    --  Clk A Imput
    ClkA_EN       : in  std_logic;                                    --  Clk A Enable Input
    ClkARst       : in  std_logic;                                    --  Clk A Reset Input
    ClkASignalIn  : in  std_logic;                                    --  Clk A Signal In
    ClkABusIn     : in  std_logic_vector(C_BUS_WIDTH-1 downto 0);     --  Clk A Bus in
    ClkB          : in  std_logic;                                    --  Clk B Imput
    ClkB_EN       : in  std_logic;                                    --  Clk B Enable Input
    ClkBRst       : in  std_logic;                                    --  Clk B Reset Input
    ClkBSignalOut : out std_logic;                                    --  Clk B Signal Out
    ClkBBusOut    : out std_logic_vector(C_BUS_WIDTH-1 downto 0)      --  Clk B Bus Out
  );
end bus_and_enable_clk_cross;

architecture imp of bus_and_enable_clk_cross is

  signal ClkASignalInDetected    : std_logic;
  signal ClkBSignalInCaptured    : std_logic;

  signal clk_a2b_bus    : std_logic_vector(C_BUS_WIDTH-1 downto 0);
  signal clk_b_bus_dly  : std_logic_vector(C_BUS_WIDTH-1 downto 0);

  begin

    DETECT_PULSE_CLK_A : process(ClkA)
    begin
      if rising_edge(ClkA) then
        if ClkARst = '1' then
          ClkASignalInDetected <= '0';
          clk_a2b_bus          <= (others => '0');
        else
          if ClkA_EN = '1' then
            if ClkASignalIn = '1' then
              ClkASignalInDetected <= '1';
              clk_a2b_bus          <= ClkABusIn;
            elsif ClkBSignalInCaptured = '1' then
              ClkASignalInDetected <= '0';
              clk_a2b_bus          <= (others => '0');
            else
              ClkASignalInDetected <= ClkASignalInDetected;
              clk_a2b_bus          <= clk_a2b_bus;
            end if;
          else
            ClkASignalInDetected <= ClkASignalInDetected;
            clk_a2b_bus          <= clk_a2b_bus;
          end if;
        end if;
      end if;
    end process;

    DETECT_PULSE_CLK_B : process(ClkB)
    begin
      if rising_edge(ClkB) then
        if ClkBRst = '1' then
          ClkBSignalInCaptured <= '0';
          clk_b_bus_dly        <= (others => '0');
        else
          if ClkB_EN = '1' then
            if ClkASignalInDetected = '1' then
              ClkBSignalInCaptured <= '1';
              clk_b_bus_dly        <= clk_a2b_bus;
            else
              ClkBSignalInCaptured <= '0';
              clk_b_bus_dly        <= (others => '0');
            end if;
          else
            ClkBSignalInCaptured <= ClkBSignalInCaptured;
            clk_b_bus_dly        <= clk_b_bus_dly;
          end if;
        end if;
      end if;
    end process;

    ClkBSignalOut <= ClkBSignalInCaptured;
    ClkBBusOut    <= clk_b_bus_dly;

end imp;
