------------------------------------------------------------------------
-- $Revision: 1.6 $ $Date: 2010/12/06 10:43:28 $
------------------------------------------------------------------------
------------------------------------------------------------------------
-- Title      : Package for address filter components
-- Project    : Tri-Mode Ethernet MAC
------------------------------------------------------------------------
-- File       : axi_stream_pack.vhd
-- Author     : Xilinx Inc.
------------------------------------------------------------------------
-- (c) Copyright 2003-2008 Xilinx, Inc. All rights reserved.
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
-- Description: The component declarations for the entities within the
--              Address Filter block
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package axi_stream_pack is


component axi_ethernet_v3_01_a_rx_axi_intf 
   generic (
      C_AT_ENTRIES               : integer := 8
   );
   port (
      rx_clk                     : in  std_logic;            
      rx_reset                   : in  std_logic;            
      rx_enable                  : in  std_logic;
  
      rx_data                    : in  std_logic_vector(7 downto 0);            
      rx_data_valid              : in  std_logic;  
      rx_good_frame              : in  std_logic;  
      rx_bad_frame               : in  std_logic;           
      rx_frame_match             : in  std_logic;            
  
      rx_filter_match            : in  std_logic_vector(C_AT_ENTRIES downto 0); 
      rx_filter_tuser            : out std_logic_vector(C_AT_ENTRIES downto 0); 
  
      rx_mac_tdata               : out std_logic_vector(7 downto 0);      
      rx_mac_tvalid              : out std_logic;      
      rx_mac_tlast               : out std_logic;      
      rx_mac_tuser               : out std_logic     
  );
end component;

component axi_ethernet_v3_01_a_tx_axi_intf 
   generic (
      C_HAS_SGMII                : integer := 0
   );
  port (
      tx_clk                     : in  std_logic;
      tx_reset                   : in  std_logic;
      tx_enable                  : in  std_logic;
      speed_is_10_100            : in  std_logic;            
                                   
      tx_mac_tdata               : in  std_logic_vector(7 downto 0);
      tx_mac_tvalid              : in  std_logic;
      tx_mac_tlast               : in  std_logic;
      tx_mac_tuser               : in  std_logic;
      tx_mac_tready              : out std_logic;

      tx_enable_out              : out std_logic;
      tx_continuation            : out std_logic;
      tx_data                    : out std_logic_vector(7 downto 0);
      tx_data_valid              : out std_logic;
      tx_underrun                : out std_logic;
      tx_ack                     : in  std_logic;
      tx_retransmit              : in  std_logic
  );
end component;

end axi_stream_pack;
