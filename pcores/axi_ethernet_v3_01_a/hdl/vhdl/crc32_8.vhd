------------------------------------------------------------------------
-- $Revision: 1.1 $ $Date: 2010/07/13 10:53:36 $
------------------------------------------------------------------------
------------------------------------------------------------------------
-- Title      : 8-bit word CRC32 component
-- Project    : Tri-Mode Ethernet MAC
-------------------------------------------------------------------------------
-- File       : crc32_8.vhd
-- Author     : Xilinx Inc.
--------------------------------------------------------------------------------
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
-- Description:  This module does an 8-bit parallel CRC generation.
--               The polynomial is that specified for IEEE 802.3 (ethernet)
--               LANs and other standards.
--
--               I. Functionality:
--               1. The module does an 8-bit parallel CRC generation.
--               2. The module provides a synchronous 8-bit per clock load and
--                  unload function.
--               3. The polynomial is that specified for 802.3 LANs and other
--                  standards.
--                  The polynomial computed is:
--                  G(x)=X**32+X**26+X**23+X**22+X**16+X**12+X**11+X**10+X**8
--                       +X**7+X**5+X**4+X** >2+X+1
--
--              II. Module I/O
--              Inputs: CLK, CLKEN, RESET, COMPUTE, DATA_IN[8:0]
--              outputs: DATA_OUT[8:0], CRC[31:0]
--
--              III.Truth Table:
--
--              RESET  CLKEN  COMPUTE  | DATA_OUT
--              ------------------------------------------
--               1      X      X       | 0x0000 (all zeros: all ones after not gates)
--               0      0      X       | No change
--               0      1      0       | load/unload CRC register, 8 bits per clock
--               0      1      1       | Compute CRC, 8 bits of input per clock


--
--              Loading and unloading of the 32-bit CRC register is done one
--              byte at a time by deasserting COMPUTE and asserting CLKEN.  The data on
--              data_in is shifted into the the LSByte of the CRC register. The
--              MSByte of the CRC register is available on data_out.
--
--              Signals ending in _n are active low.
------------------------------------------------------------------------



library IEEE;
use IEEE.std_logic_1164.all;


entity CRC32_8 is
   port(
      CLK       : in std_logic;
      CLKEN     : in std_logic;
      RESET     : in std_logic;
      COMPUTE   : in std_logic;
      DATA_IN   : in std_logic_vector(7 downto 0);
      DATA_OUT  : out std_logic_vector(7 downto 0);
      CRC       : out std_logic_vector(31 downto 0);
      CE_IN     : in  std_logic);
end CRC32_8;

architecture RTL of CRC32_8 is



-- purpose: Reverses bus routing between MSB and LSB inclusive
-- type   : function
   function REVERSE (INPUT_BUS: std_logic_vector) return std_logic_vector is
      variable REVERSED_BUS : std_logic_vector(INPUT_BUS'RANGE);
   begin
      for I in INPUT_BUS'RANGE loop
         REVERSED_BUS(I) := INPUT_BUS(INPUT_BUS'HIGH - I);
      end loop;
      return REVERSED_BUS;
   end REVERSE;



   signal REG            : std_logic_vector(31 downto 0);
   signal CRC_LSB        : std_logic_vector(7 downto 0);



begin



-- purpose: We think CRC should be transmitted in this order!
-- type   : routing
   CRC      <= REVERSE(REG);
   CRC_LSB  <= REG(31 downto 24);
   DATA_OUT <= REVERSE(CRC_LSB);



-- purpose: perfoms either a simple 8-bit shift, or the MAC CRC function.
-- type   : sequential
-- inputs : CLK, RESET, CLKEN, COMPUTE, DATA_IN, REG
-- outputs: REG
   CRC_COMPUTE: process(CLK)
   begin
      if CLK'event and CLK = '1' then

         if RESET = '1' then
            REG     <= (others => '0');

         elsif CLKEN = '1' and CE_IN = '1' then
            if COMPUTE = '0' then
               REG     <= REG(23 downto 0) & DATA_IN;  -- necessary top unload CRC result at end of calculation.
            else
               REG(31) <= not ((not REG(23)) xor (not REG(29)) xor DATA_IN(2));

               REG(30) <= not ((not REG(22)) xor (not REG(31)) xor DATA_IN(0) xor (not REG(28))
                               xor DATA_IN(3));

               REG(29) <= not ((not REG(21)) xor (not REG(31)) xor DATA_IN(0) xor (not REG(30))
                               xor DATA_IN(1) xor (not REG(27)) xor DATA_IN(4));

               REG(28) <= not ((not REG(20)) xor (not REG(30)) xor DATA_IN(1) xor (not REG(29))
                               xor DATA_IN(2) xor (not REG(26)) xor DATA_IN(5));

               REG(27) <= not ((not REG(19)) xor (not REG(31)) xor DATA_IN(0) xor (not REG(29))
                               xor DATA_IN(2) xor (not REG(28)) xor DATA_IN(3) xor (not REG(25))
                               xor DATA_IN(6));

               REG(26) <= not ((not REG(18)) xor (not REG(30)) xor DATA_IN(1) xor (not REG(28))
                               xor DATA_IN(3) xor (not REG(27)) xor DATA_IN(4) xor (not REG(24))
                               xor DATA_IN(7));

               REG(25) <= not ((not REG(17)) xor (not REG(27)) xor DATA_IN(4) xor (not REG(26))
                               xor DATA_IN(5));

               REG(24) <= not ((not REG(16)) xor (not REG(31)) xor DATA_IN(0) xor (not REG(26))
                               xor DATA_IN(5) xor (not REG(25)) xor DATA_IN(6));

               REG(23) <= not ((not REG(15)) xor (not REG(30)) xor DATA_IN(1) xor (not REG(25))
                               xor DATA_IN(6) xor (not REG(24)) xor DATA_IN(7));

               REG(22) <= not ((not REG(14)) xor (not REG(24)) xor DATA_IN(7));

               REG(21) <= not ((not REG(13)) xor (not REG(29)) xor DATA_IN(2));

               REG(20) <= not ((not REG(12)) xor (not REG(28)) xor DATA_IN(3));

               REG(19) <= not ((not REG(11)) xor (not REG(31)) xor DATA_IN(0) xor (not REG(27))
                               xor DATA_IN(4));

               REG(18) <= not ((not REG(10)) xor (not REG(31)) xor DATA_IN(0) xor (not REG(30))
                               xor DATA_IN(1) xor (not REG(26)) xor DATA_IN(5));

               REG(17) <= not ((not REG(9)) xor (not REG(30)) xor DATA_IN(1) xor (not REG(29))
                               xor DATA_IN(2) xor (not REG(25)) xor DATA_IN(6));

               REG(16) <= not ((not REG(8)) xor (not REG(29)) xor DATA_IN(2) xor (not REG(28))
                               xor DATA_IN(3) xor (not REG(24)) xor DATA_IN(7));

               REG(15) <= not ((not REG(7)) xor (not REG(31)) xor DATA_IN(0) xor (not REG(29))
                               xor DATA_IN(2) xor (not REG(28)) xor DATA_IN(3) xor (not REG(27))
                               xor DATA_IN(4));

               REG(14) <= not ((not REG(6)) xor (not REG(31)) xor DATA_IN(0) xor (not REG(30))
                               xor DATA_IN(1) xor (not REG(28)) xor DATA_IN(3) xor (not REG(27))
                               xor DATA_IN(4) xor (not REG(26)) xor DATA_IN(5));

               REG(13) <= not ((not REG(5)) xor (not REG(31)) xor DATA_IN(0) xor (not REG(30))
                               xor DATA_IN(1) xor (not REG(29)) xor DATA_IN(2) xor (not REG(27))
                               xor DATA_IN(4) xor (not REG(26)) xor DATA_IN(5) xor (not REG(25))
                               xor DATA_IN(6));

               REG(12) <= not ((not REG(4)) xor (not REG(30)) xor DATA_IN(1) xor (not REG(29))
                               xor DATA_IN(2) xor (not REG(28)) xor DATA_IN(3) xor (not REG(26))
                               xor DATA_IN(5) xor (not REG(25)) xor DATA_IN(6) xor (not REG(24))
                               xor DATA_IN(7));

               REG(11) <= not ((not REG(3)) xor (not REG(28)) xor DATA_IN(3) xor (not REG(27))
                               xor DATA_IN(4) xor (not REG(25)) xor DATA_IN(6) xor (not REG(24))
                               xor DATA_IN(7));

               REG(10) <= not ((not REG(2)) xor (not REG(29)) xor DATA_IN(2) xor (not REG(27))
                               xor DATA_IN(4) xor (not REG(26)) xor DATA_IN(5) xor (not REG(24))
                               xor DATA_IN(7));

               REG(9)  <= not ((not REG(1)) xor (not REG(29)) xor DATA_IN(2) xor (not REG(28))
                               xor DATA_IN(3) xor (not REG(26)) xor DATA_IN(5) xor (not REG(25))
                               xor DATA_IN(6));

               REG(8)  <= not ((not REG(0)) xor (not REG(28)) xor DATA_IN(3) xor (not REG(27))
                               xor DATA_IN(4) xor (not REG(25)) xor DATA_IN(6) xor (not REG(24))
                               xor DATA_IN(7));

               REG(7)  <= not (((not REG(31)) xor DATA_IN(0)) xor (not REG(29)) xor DATA_IN(2)
                               xor (not REG(27)) xor DATA_IN(4) xor (not REG(26)) xor DATA_IN(5)
                               xor (not REG(24)) xor DATA_IN(7));

               REG(6)  <= not (((not REG(31)) xor DATA_IN(0)) xor (not REG(30)) xor DATA_IN(1)
                               xor (not REG(29)) xor DATA_IN(2) xor (not REG(28)) xor DATA_IN(3)
                               xor (not REG(26)) xor DATA_IN(5) xor (not REG(25)) xor DATA_IN(6));

               REG(5)  <= not (((not REG(31)) xor DATA_IN(0)) xor (not REG(30)) xor DATA_IN(1)
                               xor (not REG(29)) xor DATA_IN(2) xor (not REG(28)) xor DATA_IN(3)
                               xor (not REG(27)) xor DATA_IN(4) xor (not REG(25)) xor DATA_IN(6)
                               xor (not REG(24)) xor DATA_IN(7));

               REG(4)  <= not (((not REG(30)) xor DATA_IN(1)) xor (not REG(28)) xor DATA_IN(3)
                               xor (not REG(27)) xor DATA_IN(4) xor (not REG(26)) xor DATA_IN(5)
                               xor (not REG(24)) xor DATA_IN(7));

               REG(3)  <= not (((not REG(31)) xor DATA_IN(0)) xor (not REG(27)) xor DATA_IN(4)
                               xor (not REG(26)) xor DATA_IN(5) xor (not REG(25)) xor DATA_IN(6));

               REG(2)  <= not (((not REG(31)) xor DATA_IN(0)) xor (not REG(30)) xor DATA_IN(1)
                               xor (not REG(26)) xor DATA_IN(5) xor (not REG(25)) xor DATA_IN(6)
                               xor (not REG(24)) xor DATA_IN(7));

               REG(1)  <= not (((not REG(31)) xor DATA_IN(0)) xor (not REG(30)) xor DATA_IN(1)
                               xor (not REG(25)) xor DATA_IN(6) xor (not REG(24)) xor DATA_IN(7));

               REG(0)  <= not (((not REG(30)) xor DATA_IN(1)) xor (not REG(24)) xor DATA_IN(7));
            end if;
         end if;
      end if;
   end process;



end RTL;
