------------------------------------------------------------------------------
-- reg_cr - entity and arch
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
-- Filename:        reg_cr.vhd
-- Version:         v1.01a
-- Description:     Include a meaningful description of your file. Multi-line
--                  descriptions should align with each other
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to improve
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
-- Author:
-- History:
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity reg_cr is
    port    (
             Clk      : in  std_logic;  --intPlbClk               --  Clk        in
                                                                  --
             Stats_clk: in  std_logic;                            --  Stats_clk  in
             Host_clk : in  std_logic;                            --  Host_clk   in
             txClClk  : in  std_logic;                            --  txClClk    in
             rxClClk  : in  std_logic;                            --  rxClClk    in
                                                                  --
             RST      : in  std_logic;                            --  RST        in
             RdCE     : in  std_logic;                            --  RdCE       in
             WrCE     : in  std_logic;                            --  WrCE       in
             DataIn   : in  std_logic_vector(17 to 31);           --  DataIn     in
             DataOut  : out std_logic_vector(17 to 31);           --  DataOut    out
             RegData  : out std_logic_vector(17 to 31)            --  RegData    out
            );
end reg_cr;

------------------------------------------------------------------------------
-- Architecture
------------------------------------------------------------------------------

architecture imp of reg_cr is

------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------

signal reg_data : std_logic_vector(17 to 31);

begin

------------------------------------------------------------------------------
-- Concurrent Signal Assignments
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- REG_DATA_PROCESS
------------------------------------------------------------------------------

REG_DATA_PROCESS : process (reg_data)
begin
  for i in 17 to 31 loop
      RegData(i) <= reg_data(i);
  end loop;
end process;

------------------------------------------------------------------------------
-- BUS_READ_PROCESS
------------------------------------------------------------------------------

BUS_READ_PROCESS : process (RdCE, reg_data)
begin
  for i in 17 to 31 loop
     DataOut(i) <= RdCE and reg_data(i);
  end loop;
end process;

------------------------------------------------------------------------------
-- BUS_WRITE_PROCESS
------------------------------------------------------------------------------

BUS_WRITE_PROCESS : process (Clk)
begin
    if (Clk'event and Clk = '1')
    then
        if (Rst = '1')
        then
            reg_data <= (others => '0');
        elsif (WrCE = '1')
        then
            reg_data(17)       <= DataIn(17);
            reg_data(19 to 30) <= DataIn(19 to 30);
            reg_data(18)       <= '0';
            reg_data(31)       <= '0';
        end if;
    end if;
end process;

end imp;
