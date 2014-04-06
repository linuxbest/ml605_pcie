------------------------------------------------------------------------------
-- rx_csum_if.vhd
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
-- Filename:        rx_csum_if.vhd
-- Version:         v2.00a
-- Description:      
--                   
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
-- Author:      DRP
-- History:
--
--  <initials>      <date>
-- ^^^^^^
--      Description of changes. If multiple lines are needed to fully describe
--      the changes made to the design, these lines should align with each other.
-- ~~~~~~
--
--  <initials>      <date>
-- ^^^^^^
--      More changes
-- ~~~~~~
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

entity rx_csum_if is
  port (
    CLK       : in  std_logic;
    CLK_ENBL  : in  std_logic;
    RST       : in  std_logic;
    INTRFRMRST: in  std_logic;
    CALC_ENBL : in  std_logic;
    WORD_ENBL : in  std_logic;
    DATA_IN   : in  std_logic_vector(15 downto 0);
    CSUM_VLD  : out std_logic;
    CSUM      : out std_logic_vector(15 downto 0)
    );
end entity;

architecture beh of rx_csum_if is

  signal checksum            : std_logic_vector(16 downto 0);
  signal calcEnable_d1       : std_logic;
  signal wordEnable_d1       : std_logic;
  signal endOfEnablePulse    : std_logic;
  signal endOfEnablePulse_d1 : std_logic;
  signal dataIn_d1           : std_logic_vector(15 downto 0);
  signal byteCount           : std_logic_vector(2 downto 0);

  begin
  
    ---------------------------------------------------------------------------
    -- 
    ---------------------------------------------------------------------------
    process(CLK)
      begin
        if(rising_edge(CLK)) then
          if(RST='1' or INTRFRMRST='1') then
            dataIn_d1   <= (others => '0');
          else
            if(CLK_ENBL='1') then
              dataIn_d1   <= DATA_IN;
            end if;
          end if;
        end if;
    end process;

    process(CLK)
      begin
        if(rising_edge(CLK)) then
          if(RST='1' or INTRFRMRST='1') then
            endOfEnablePulse    <= '0';
            endOfEnablePulse_d1 <= '0';
            calcEnable_d1       <= '0';
            wordEnable_d1       <= '0';
          else
            if(CLK_ENBL='1') then
              wordEnable_d1       <= WORD_ENBL;
              calcEnable_d1       <= CALC_ENBL;
              endOfEnablePulse    <= not(CALC_ENBL) and calcEnable_d1;
              endOfEnablePulse_d1 <= endOfEnablePulse;
            end if;
          end if;
        end if;
    end process;

    ---------------------------------------------------------------------------
    -- this is where the checksum is calculated
    ---------------------------------------------------------------------------

    process(clk)
      begin
        if(rising_edge(clk)) then
          if(rst='1') then
            checksum    <= (others => '0');
            byteCount   <= (others => '0');
          else
            if(CLK_ENBL='1') then
              if(calcEnable_d1='1') then
                if (byteCount < X"7" and wordEnable_d1 = '1') then
                  byteCount <= byteCount + 1;
                end if;
                if (byteCount = x"7" and wordEnable_d1 = '1') then
                  if (checksum + dataIn_d1 > X"ffff") then                
                    checksum <= checksum + dataIn_d1 - X"ffff";
                  else
                    checksum <= checksum + dataIn_d1;
                  end if;
                end if;
              else
                checksum   <= (others => '0');
                byteCount  <= (others => '0');
              end if;
            end if;
          end if;
        end if;
    end process;
    
    CSUM_VLD <= endOfEnablePulse_d1;

    process(CLK)
      begin
        if(rising_edge(CLK)) then
          if(RST='1' or INTRFRMRST='1') then
            CSUM  <= (others => '0');
          else
            if(CLK_ENBL='1') then
              if (checksum(15 downto 0) = X"0000") then
                CSUM  <= X"ffff";
              else
                CSUM  <= checksum(15 downto 0);
              end if;
            end if;
          end if;
        end if;
    end process;
    
end beh;


                      
