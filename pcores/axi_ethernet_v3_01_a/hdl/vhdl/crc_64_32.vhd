------------------------------------------------------------------------
-- $Revision: 1.1 $ $Date: 2010/07/13 10:53:36 $
------------------------------------------------------------------------
------------------------------------------------------------------------
-- Title      : CRC 64 32
-- Project    : Tri-Mode Ethernet MAC
------------------------------------------------------------------------
------------------------------------------------------------------------
-- File       : crc_64_32.vhd
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
-- Description:
------------------------------------------------------------------------


library unisim;
use unisim.vcomponents.all;

library work;
use work.all;

library IEEE;
use IEEE.std_logic_1164.all;

entity CRC_64_32 is
   port(
      CLK               : in std_logic;
      BYTE_EN           : in std_logic;
      CE_IN             : in std_logic;
      CRC_OK            : out std_logic);
end CRC_64_32;


architecture RTL of CRC_64_32 is

   component CC8CE
     port(C   : in  std_logic;
          CLR : in  std_logic;
          CE  : in  std_logic;
          Q   : out std_logic_vector(7 downto 0);
          CEO : out std_logic;
          TC  : out std_logic);
   end component;

   component CC2CE
     port(C   : in  std_logic;
          CLR : in  std_logic;
          CE  : in  std_logic;
          Q   : out std_logic_vector(1 downto 0);
          CEO : out std_logic;
          TC  : out std_logic);
   end component;

   component FDC
     port(C   : in  std_logic;
          CLR : in  std_logic;
          D   : in  std_logic;
          Q   : out std_logic);
   end component;

   component FDCE
     port(C   : in  std_logic;
          CLR : in  std_logic;
          CE  : in  std_logic;
          D   : in  std_logic;
          Q   : out std_logic);
   end component;

   signal int1, int1q : std_logic;
   signal int2, int2q : std_logic;
   signal int3, int3q : std_logic;
   signal int4, int4q : std_logic;
   signal int5, int5q : std_logic;
   signal int6, int6q : std_logic;

   signal TQ0          : STD_LOGIC;
   signal X36_1N12     : STD_LOGIC;
   signal C0           : STD_LOGIC;
   signal TC_ASSIGN_I0 : STD_LOGIC;
   signal Q0_ASSIGN_LI : STD_LOGIC;

begin


   CRC1 : CC8CE
     port map(
       C   => CLK,
       CLR => '0',
       CE  => CE_IN,
       CEO => int1);

   FF1 : FDC
     port map(
       C   => CLK,
       CLR => '0',
       D   => int1,
       Q   => int1q);

   CRC2 : CC8CE
     port map(
       C   => CLK,
       CLR => '0',
       CE  => int1q,
       CEO => int2);

   FF2 : FDC
     port map(
       C   => CLK,
       CLR => '0',
       D   => int2,
       Q   => int2q);

   CRC3 : CC8CE
     port map(
       C   => CLK,
       CLR => '0',
       CE  => int2q,
       CEO => int3);

   FF3 : FDC
     port map(
       C   => CLK,
       CLR => '0',
       D   => int3,
       Q   => int3q);

   CRC4 : CC8CE
     port map(
       C   => CLK,
       CLR => '0',
       CE  => int3q,
       CEO => int4);

   FF4 : FDC
     port map(
       C   => CLK,
       CLR => '0',
       D   => int4,
       Q   => int4q);

   CRC5 : CC2CE
     port map(
       C   => CLK,
       CLR => '0',
       CE  => int4q,
       CEO => int5);

   FF5 : FDC
     port map(
       C   => CLK,
       CLR => '0',
       D   => int5,
       Q   => int5q);

   C0 <= '1';

   X36_1N12 <= '0';

   X36_1I6 : XORCY port map(
        CI => C0,
        LI => Q0_ASSIGN_LI,
        O  => TQ0);

   X36_1I36 : FDCE port map(
        D   => TQ0,
        CE  => int5q,
        C   => CLK,
        CLR => '0',
        Q   => Q0_ASSIGN_LI);

   X36_1I4 : MUXCY_L port map(
        DI => X36_1N12,
        CI => C0,
        S  => Q0_ASSIGN_LI,
        LO => TC_ASSIGN_I0);

   X36_1I956 : AND2 port map(
        I0 => int5q,
        I1 => TC_ASSIGN_I0,
        O  => int6);

   FF6 : FDCE
     port map(
       C   => CLK,
       CE  => int6,
       CLR => '0',
       D   => '1',
       Q   => int6q);

   CRC_OK <= BYTE_EN and int6q;

end RTL;
