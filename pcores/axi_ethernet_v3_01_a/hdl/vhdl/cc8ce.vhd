------------------------------------------------------------------------
-- $Revision: 1.1 $ $Date: 2010/07/13 10:53:36 $
------------------------------------------------------------------------
------------------------------------------------------------------------
-- Title      : This file contains the code for an 8-bit counter
-- Project    : Tri-Mode Ethernet MAC
------------------------------------------------------------------------
-- File       : cc8ce.vhd
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


library IEEE;
use IEEE.std_logic_1164.all;

entity CC8CE is port (
        Q   : out STD_LOGIC_VECTOR (7 downto 0);
        C   : in  STD_LOGIC;
        CE  : in  STD_LOGIC;
        CEO : out STD_LOGIC;
        CLR : in  STD_LOGIC;
        TC  : out STD_LOGIC
); end CC8CE;

architecture SCHEMATIC of CC8CE is

--SIGNALS

signal TQ7          : STD_LOGIC;
signal TQ5          : STD_LOGIC;
signal TQ4          : STD_LOGIC;
signal TQ1          : STD_LOGIC;
signal TQ0          : STD_LOGIC;
signal TQ6          : STD_LOGIC;
signal C4           : STD_LOGIC;
signal C5           : STD_LOGIC;
signal C7           : STD_LOGIC;
signal C6           : STD_LOGIC;
signal TQ2          : STD_LOGIC;
signal TQ3          : STD_LOGIC;
signal X36_1N12     : STD_LOGIC;
signal C1           : STD_LOGIC;
signal C2           : STD_LOGIC;
signal C3           : STD_LOGIC;
signal C0           : STD_LOGIC;
signal Q7_ASSIGN_LI : STD_LOGIC;
signal TC_ASSIGN_I1 : STD_LOGIC;
signal Q6_ASSIGN_LI : STD_LOGIC;
signal Q5_ASSIGN_LI : STD_LOGIC;
signal Q4_ASSIGN_LI : STD_LOGIC;
signal Q3_ASSIGN_LI : STD_LOGIC;
signal Q2_ASSIGN_S  : STD_LOGIC;
signal Q1_ASSIGN_LI : STD_LOGIC;
signal Q0_ASSIGN_LI : STD_LOGIC;

attribute ASYNC_REG : string;
attribute ASYNC_REG of X36_1I263 : label is "TRUE";
attribute ASYNC_REG of X36_1I276 : label is "TRUE";
attribute ASYNC_REG of X36_1I289 : label is "TRUE";
attribute ASYNC_REG of X36_1I237 : label is "TRUE";
attribute ASYNC_REG of X36_1I250 : label is "TRUE";
attribute ASYNC_REG of X36_1I224 : label is "TRUE";
attribute ASYNC_REG of X36_1I35  : label is "TRUE";
attribute ASYNC_REG of X36_1I36  : label is "TRUE";

begin

--SIGNAL ASSIGNMENTS

Q(7) <= Q7_ASSIGN_LI;
TC   <= TC_ASSIGN_I1;
Q(6) <= Q6_ASSIGN_LI;
Q(5) <= Q5_ASSIGN_LI;
Q(4) <= Q4_ASSIGN_LI;
Q(3) <= Q3_ASSIGN_LI;
Q(2) <= Q2_ASSIGN_S;
Q(1) <= Q1_ASSIGN_LI;
Q(0) <= Q0_ASSIGN_LI;

--COMPONENT INSTANCES

X36_1I4   : MUXCY_L port map(
        DI  => X36_1N12,
        CI  => C0,
        S   => Q0_ASSIGN_LI,
        LO  => C1
);
X36_1I26  : MUXCY_L port map(
        DI  => X36_1N12,
        CI  => C1,
        S   => Q1_ASSIGN_LI,
        LO  => C2
);
X36_1I233 : MUXCY_L port map(
        DI  => X36_1N12,
        CI  => C2,
        S   => Q2_ASSIGN_S,
        LO  => C3
);
X36_1I246 : MUXCY_L port map(
        DI  => X36_1N12,
        CI  => C3,
        S   => Q3_ASSIGN_LI,
        LO  => C4
);
X36_1I263 : FDCE port map(
        D   => TQ5,
        CE  => CE,
        C   => C,
        CLR => CLR,
        Q   => Q5_ASSIGN_LI
);
X36_1I276 : FDCE port map(
        D   => TQ6,
        CE  => CE,
        C   => C,
        CLR => CLR,
        Q   => Q6_ASSIGN_LI
);
X36_1I289 : FDCE port map(
        D   => TQ7,
        CE  => CE,
        C   => C,
        CLR => CLR,
        Q   => Q7_ASSIGN_LI
);
X36_1I956 : AND2 port map(
        I0  => CE,
        I1  => TC_ASSIGN_I1,
        O   => CEO
);
X36_1I923 : VCC port map(
        P   => C0
);
X36_1I886 : GND port map(
        G   => X36_1N12
);
X36_1I285 : MUXCY_L port map(
        DI  => X36_1N12,
        CI  => C6,
        S   => Q6_ASSIGN_LI,
        LO  => C7
);
X36_1I272 : MUXCY_L port map(
        DI  => X36_1N12,
        CI  => C5,
        S   => Q5_ASSIGN_LI,
        LO  => C6
);
X36_1I259 : MUXCY_L port map(
        DI  => X36_1N12,
        CI  => C4,
        S   => Q4_ASSIGN_LI,
        LO  => C5
);
X36_1I298 : MUXCY port map(
        DI  => X36_1N12,
        CI  => C7,
        S   => Q7_ASSIGN_LI,
        O   => TC_ASSIGN_I1
);
X36_1I6   : XORCY port map(
        CI  => C0,
        LI  => Q0_ASSIGN_LI,
        O   => TQ0
);
X36_1I28  : XORCY port map(
        CI  => C1,
        LI  => Q1_ASSIGN_LI,
        O   => TQ1
);
X36_1I226 : XORCY port map(
        CI  => C2,
        LI  => Q2_ASSIGN_S,
        O   => TQ2
);
X36_1I239 : XORCY port map(
        CI  => C3,
        LI  => Q3_ASSIGN_LI,
        O   => TQ3
);
X36_1I252 : XORCY port map(
        CI  => C4,
        LI  => Q4_ASSIGN_LI,
        O   => TQ4
);
X36_1I265 : XORCY port map(
        CI  => C5,
        LI  => Q5_ASSIGN_LI,
        O   => TQ5
);
X36_1I278 : XORCY port map(
        CI  => C6,
        LI  => Q6_ASSIGN_LI,
        O   => TQ6
);
X36_1I291 : XORCY port map(
        CI  => C7,
        LI  => Q7_ASSIGN_LI,
        O   => TQ7
);
X36_1I237 : FDCE port map(
        D   => TQ3,
        CE  => CE,
        C   => C,
        CLR => CLR,
        Q   => Q3_ASSIGN_LI
);
X36_1I250 : FDCE port map(
        D   => TQ4,
        CE  => CE,
        C   => C,
        CLR => CLR,
        Q   => Q4_ASSIGN_LI
);
X36_1I224 : FDCE port map(
        D   => TQ2,
        CE  => CE,
        C   => C,
        CLR => CLR,
        Q   => Q2_ASSIGN_S
);
X36_1I35  : FDCE port map(
        D   => TQ1,
        CE  => CE,
        C   => C,
        CLR => CLR,
        Q   => Q1_ASSIGN_LI
);
X36_1I36  : FDCE port map(
        D   => TQ0,
        CE  => CE,
        C   => C,
        CLR => CLR,
        Q   => Q0_ASSIGN_LI
);

end SCHEMATIC;
