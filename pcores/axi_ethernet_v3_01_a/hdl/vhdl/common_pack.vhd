------------------------------------------------------------------------
-- $Revision: 1.1 $ $Date: 2010/07/13 10:53:36 $
------------------------------------------------------------------------
-- Title      : Common Package
-- Project    : Tri-Mode Ethernet MAC
------------------------------------------------------------------------
-- File       : common_pack.vhd
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package COMMON_PACK is

   component SYNC_BLOCK
    generic (INITIALISE  : in bit_vector(1 downto 0) := "00");
    port (
       CLK         : in  std_logic;          -- clock to be sync'ed to
       DATA_IN     : in  std_logic;          -- Data to be 'synced'
       DATA_OUT    : out std_logic           -- synced data
      );
   end component;


  component ELASTIC_BUFFER_8
    generic (
      D_WIDTH      : positive
      );
    port(
      WR_RESET     : in std_logic;                      -- WR clock domain Reset.
      RD_RESET     : in std_logic;                      -- RD clock domain Reset.
      CLK_WR       : in std_logic;                      -- Write clock domain.
      WR_EN        : in std_logic;                      -- FIFO data write
      D_WR         : in std_logic_vector(D_WIDTH-1 downto 0); -- Data synchronous to CLK_WR.
      EN_WR        : in std_logic;                      -- EN synchronous to CLK_WR.
      ER_WR        : in std_logic;                      -- ER synchronous to CLK_WR.
      IFG_DELAY    : in std_logic_vector(7 downto 0);   -- IFG_DELAY latched at beginning of frame
      CLK_RD       : in std_logic;                      -- Read clock domain.
      RD_ADV       : in std_logic;                      -- advance FIFO Read data
      D_RD         : out std_logic_vector(D_WIDTH-1 downto 0); -- Data synchronous to CLK_RD.
      EN_RD        : out std_logic;                     -- EN synchronous to CLK_RD.
      ER_RD        : out std_logic                      -- ER synchronous to CLK_RD.
      );
  end component;


  component RATE_ADAPT
    port (
      RESET          : in std_logic;                   -- Reset
      SPEED          : in std_logic_vector(1 downto 0);-- speed configuration bits
      CORE_HAS_SGMII : in std_logic;                   --
      CLK            : in std_logic;
      DV             : in std_logic;                   -- Data Valid signal from/to GMII
      ADVANCE        : out std_logic                   -- Advance WR or RD pointser
      );
  end component;
 
end package;
