------------------------------------------------------------------------
-- $Revision: 1.1 $ $Date: 2010/07/13 10:53:36 $
------------------------------------------------------------------------
------------------------------------------------------------------------
-- Title      : rate adaptation module.
-- Project    : Tri-Mode Ethernet MAC
------------------------------------------------------------------------
-- File       : rate_adapt.vhd
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
-- Description: This is the module which when in SGMII mode generates a pulse every
--              100/10/1 for 10M/100M/1G operations respectively.  The pulse is
--              used to drive the RD_ADV or WR_EN of the synchornization FIFO,
--              thus converting the data from the 1G PCS/PMA domain to the 10/100/1G
--              in the EMAC domain.
--
------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RATE_ADAPT is

   port(

      RESET             : in std_logic;                      -- Reset
      SPEED             : in std_logic_vector(1 downto 0);   -- speed configuration bits
      CORE_HAS_SGMII    : in std_logic;                      --
      CLK               : in std_logic;                      --
      DV                : in std_logic;                      -- Data Valid signal from/to GMII
      ADVANCE           : out std_logic                      -- Advance WR or RD pointser
   );

end RATE_ADAPT;

architecture RTL of RATE_ADAPT is

signal COUNT       : std_logic_vector(6 downto 0);
signal DIN         : std_logic_vector(6 downto 0);
signal CARRY       : std_logic;
signal RATE_CTL    : std_logic_vector(1 downto 0);
signal DV_REG      : std_logic;
signal SYNC        : std_logic;

attribute ASYNC_REG : string;
attribute ASYNC_REG of COUNT : signal is "TRUE";

begin

  PIPE1 : process (CLK)
  begin
    if CLK ='1' and CLK'event then
      if RESET='1' then
        DV_REG     <= '0';
      else
        DV_REG     <= DV;
      end if;
    end if;
  end process PIPE1;

-- When in SGMII mode, the spec allows for 9/99 bytes in 10/100 mode for preamble instead of
-- 10/100 (See page 7 of SGMII spec).  Therefore, the counter can not be a free-
-- running counter.  A free-runing may miss the byte which is 9/99.
-- To get around this, SYNC goes high on the rising edge of DV to set the counter into a carry-out state.
-- So in the 9/99, the first byte of the 9 repeated bytes will be latched,
-- followed by the second byte of the 10 repeated byte, etc.
--
-- SFD1 SFD2 SFD3 SFD4 SFD5 SFD6 SFD7 SFD8 SFD9 | D0_1 D0_2 D0_3 D0_4 D0_5 D0_6 D0_7 D0_8 D0_9 D0_10 | D1_1 D1_2
-- Latch                                               Latch                                                Latch
--

  SYNC_PULSE : process (CLK)
  begin
    if CLK ='1' and CLK'event then
      if RESET='1' then
        SYNC  <= '0';
      elsif (DV = '1') and (DV_REG = '0') then
        SYNC  <= '1';
      else
        SYNC  <= '0';
      end if;
    end if;
  end process SYNC_PULSE;

-- When in SGMII mode, ADVANCE for every 1/10/100 clocks for 1G/100M/10M respectively.
-- When not in SGMII mode, ADVANCE for every clock for 1G mode, every other
-- clock for 100M/10M due to the interface going from 8 bits (GMII) to 4 bits (MII).

  DECODE_MODE: process (SPEED, CORE_HAS_SGMII)
  begin  -- process DECODE_MODE
    if CORE_HAS_SGMII = '1' then
      RATE_CTL <= SPEED;
    else
      if SPEED = "10" then
        RATE_CTL <= "10";
      else
        RATE_CTL <= "11";
      end if;
    end if;
  end process DECODE_MODE;

  DEC_RATE : process (RATE_CTL)
  begin
    case RATE_CTL is
      when "10" =>          -- 1000 Mbps
        DIN <= "1111111";
      when "01" =>          -- SGMII and 100 Mbps
        DIN <= "1110110";
      when "00" =>          -- SGMII and 10 Mbps
        DIN <= "0011100";
      when "11" =>
        DIN <= "1111110";   -- not SGMII and MII
      when others =>
        DIN <= "1111111";   -- reserved
    end case;
  end process DEC_RATE;


  COUNTER: process (CLK)
  begin
    if CLK ='1' and CLK'event then
      if RESET = '1' then
        COUNT <= "1111111";
      elsif CARRY ='1'  then
        COUNT <= DIN;
      else
        COUNT <= COUNT + 1;
      end if;
    end if;
  end process;


  CARRY_GEN: process (COUNT, SYNC)
  begin
    if COUNT = "1111111" or SYNC = '1' then
      CARRY <= '1';
    else
      CARRY <= '0';
    end if;
  end process;

  ADVANCE       <= CARRY;

end RTL;
