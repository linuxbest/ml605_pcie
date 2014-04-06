------------------------------------------------------------------------
-- $Revision: 1.1 $ $Date: 2010/07/13 10:53:36 $
------------------------------------------------------------------------
------------------------------------------------------------------------
-- Title      : Reset quasi-synchroniser
-- Project    : Tri-Mode Ethernet MAC
------------------------------------------------------------------------
-- File       : sync_reset.vhd
-- Author     : Xilinx Inc.
------------------------------------------------------------------------
-- (c) Copyright 2001-2008 Xilinx, Inc. All rights reserved.
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
------------------------------------------------------------------------
-- Description: This reset synchronizer was derived from:
--              http://www.xilinx.com/support/techxclusives/global-techX19.htm
--              It is used to generate a reset signal which has a falling edge
--              synchronous with CLK; this allows predictable reset recovery
--              even using the asynchronous reset pins of register primitives.
-------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity SYNC_RESET is

  port (
    RESET_IN   : in  std_logic;         -- Active high asynchronous reset
    CLK        : in  std_logic;         -- clock to be sync'ed to
    RESET_OUT  : out std_logic          -- "Synchronised" reset signal
    );

end SYNC_RESET;

-------------------------------------------------------------------------------

architecture rtl of SYNC_RESET is
  signal R1, R2, R3, R4 : std_logic := '1';

  attribute async_reg : string;
  attribute async_reg of R1 : signal is "true";
  attribute async_reg of R2 : signal is "true";
  attribute async_reg of R3 : signal is "true";
  attribute async_reg of R4 : signal is "true";
  
  attribute SHREG_EXTRACT               : string;
  attribute SHREG_EXTRACT of R1 : signal is "NO";
  attribute SHREG_EXTRACT of R2 : signal is "NO";
  attribute SHREG_EXTRACT of R3 : signal is "NO";
  attribute SHREG_EXTRACT of R4 : signal is "NO";
  
begin  -- rtl

  -- Synchroniser process. In this case, 2 registers should pack into 1 slices.
  -- first two flops are asynchronously reset - 2 stage to ensure the reset is present for a full cycle
  P_RESET : process (CLK, RESET_IN)
  begin
    if (RESET_IN = '1') then
      R1        <= '1';
      R2        <= '1';
    elsif CLK'event and CLK = '1' then
      R1        <= '0';
      R2        <= R1;
    end if;
  end process P_RESET;
  
  -- second two flops are synchronously reset - this is used for all later flops
  -- and should ensure the reset is fully synchronous
  P_RESET_SYNC : process (CLK)
  begin
    if CLK'event and CLK = '1' then
      if (R2 = '1') then
        R3        <= '1';
        R4        <= '1';
      else
        R3        <= '0';
        R4        <= R3;
      end if;
    end if;
  end process P_RESET_SYNC;
  
  RESET_OUT <= R4;

end rtl;
