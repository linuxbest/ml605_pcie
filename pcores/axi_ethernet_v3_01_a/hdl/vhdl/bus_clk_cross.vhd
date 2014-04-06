------------------------------------------------------------------------------
-- bus_clk_cross - entity and arch
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
-- Filename:        bus_clk_cross.vhd
-- Version:         v1.00a
-- Description:     This module converts an active high pulse from one clock to
--                   the other clock domain ensuring a pulse is detected
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to improve
--              readability.
--
--              bus_clk_cross.vhd
--
--              This section is optional for common/shared modules but should
--              contain a statement stating it is a common/shared module.
------------------------------------------------------------------------------
-- Author:      MSH
-- History:
-- MSH  02/01/2010
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

entity bus_clk_cross is
  generic (
    C_BUS_WIDTH    : integer range 2 to 64 := 8
  );
  port    (
    Clk_A_BUS_IN   : in  std_logic_vector(C_BUS_WIDTH-1 downto 0);    --  Clk A Bus In
    Clk_B          : in  std_logic;                                   --  Clk B
    Clk_B_Rst      : in  std_logic;                                   --  Clk B Reset
    Clk_B_BUS_OUT  : out std_logic_vector(C_BUS_WIDTH-1 downto 0)     --  Clk B Bus Out
  );
end bus_clk_cross;

architecture imp of bus_clk_cross is

signal clk_b_bus_out_i    : std_logic_vector(C_BUS_WIDTH-1 downto 0);

begin

  REG_DATA_PROCESS : process (Clk_B)
  begin
--    for i in 0 to (C_BUS_WIDTH-1) loop
      if (Clk_B'event and Clk_B = '1') then
        if (Clk_B_Rst = '1') then
          clk_b_bus_out_i <= (others => '0');
          Clk_B_BUS_OUT   <= (others => '0');
        else
          clk_b_bus_out_i <= Clk_A_BUS_IN;
          Clk_B_BUS_OUT   <= clk_b_bus_out_i;
        end if;
      end if;
--    end loop;
  end process;

end imp;
