------------------------------------------------------------------------------
-- addr_response_shim.vhd
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
-- Filename:        addr_response_shim.vhd
-- Version:         v1.00a
-- Description:     address response shim
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to improve
--              readability.
--
--            -- xps_ll_temac.vhd
--               -- addr_response_shim.vhd    ******
--               -- axi_soft_temac_wrap.vhd
--               -- v6_temac_wrap.vhd
--
--              This section is optional for common/shared modules but should
--              contain a statement stating it is a common/shared module.

------------------------------------------------------------------------------
-- Author:
-- History:
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
--      combinatorial signals:                  "*_com"
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
use ieee.numeric_std.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

-------------------------------------------------------------------------------
-- Entity section
-------------------------------------------------------------------------------

entity addr_response_shim is
   generic (

      C_BUS2CORE_CLK_RATIO      : integer range 1 to 2    := 1;
      C_S_AXI_ADDR_WIDTH        : integer range 32 to 32  := 32;
      C_S_AXI_DATA_WIDTH        : integer range 32 to 32  := 32;
      C_SIPIF_DWIDTH            : integer range 32 to 32  := 32;
      C_NUM_CS                  : integer                 := 10;
      C_NUM_CE                  : integer                 := 41;
      C_FAMILY                  : string                  := "virtex6"
      );
   port (
      --Clock and Reset
      S_AXI_ACLK                : in  std_logic;                                        --  AXI4-Lite clk
      S_AXI_ARESET              : in  std_logic;                                        --  AXI4-Lite reset

      -- PLB Slave Interface with Shim
      Bus2Shim_Addr             : in  std_logic_vector(0 to C_S_AXI_ADDR_WIDTH - 1 );   --  Address bus from AXI4-Lite to Shim
      Bus2Shim_Data             : in  std_logic_vector(0 to C_SIPIF_DWIDTH - 1 );       --  Data bus from AXI4-Lite to Shim
      Bus2Shim_RNW              : in  std_logic;                                        --  RNW signal from AXI4-Lite to Shim
      Bus2Shim_CS               : in  std_logic_vector(0 to 0);                         --  CS signal from AXI4-Lite to Shim
      Bus2Shim_RdCE             : in  std_logic_vector(0 to 0);                         --  RdCE signal from AXI4-Lite to Shim
      Bus2Shim_WrCE             : in  std_logic_vector(0 to 0);                         --  WrCE signal from AXI4-Lite to Shim

      Shim2Bus_Data             : out std_logic_vector (0 to C_SIPIF_DWIDTH - 1 );      --  Data bus from Shim to AXI4-Lite
      Shim2Bus_WrAck            : out std_logic;                                        --  WrCE signal from Shim to AXI4-Lite
      Shim2Bus_RdAck            : out std_logic;                                        --  RdCE signal from Shim to AXI4-Lite

      -- TEMAC Interface with Shim
      Shim2IP_Addr              : out std_logic_vector(0 to C_S_AXI_ADDR_WIDTH - 1 );   --  Address bus from Shim to AXI Ethernet
      Shim2IP_Data              : out std_logic_vector(0 to C_SIPIF_DWIDTH - 1 );       --  Data bus from Shim to AXI Ethernet
      Shim2IP_RNW               : out std_logic;                                        --  RNW signal from Shim to AXI Ethernet
      Shim2IP_CS                : out std_logic_vector(0 to C_NUM_CS);                  --  CS signal from Shim to AXI Ethernet
      Shim2IP_RdCE              : out std_logic_vector(0 to C_NUM_CE);                  --  RdCE signal from Shim to AXI Ethernet
      Shim2IP_WrCE              : out std_logic_vector(0 to C_NUM_CE);                  --  WrCE signal from Shim to AXI Ethernet

      IP2Shim_Data              : in  std_logic_vector (0 to C_SIPIF_DWIDTH - 1 );      --  Data bus from AXI Ethernet to Shim
      IP2Shim_WrAck             : in  std_logic;                                        --  WrCE signal from AXI Ethernet to Shim
      IP2Shim_RdAck             : in  std_logic                                         --  RdCE signal from AXI Ethernet to Shim
   );

end addr_response_shim;

architecture rtl of addr_response_shim is


   signal bus2Shim_Addr_reg    : std_logic_vector(0 to C_S_AXI_ADDR_WIDTH - 1 );
   signal bus2Shim_CS_reg      : std_logic;
   signal shim2IP_RNW_int      : std_logic;
   signal bus2Shim_RdCE_reg    : std_logic;
   signal bus2Shim_WrCE_reg    : std_logic;
   signal invalidAddrRspns     : std_logic;
   signal invalidAddrRspns_reg : std_logic;
   signal invalidRdReq         : std_logic;
   signal invalidWrReq         : std_logic;
   signal shim2IP_CS_int       : std_logic_vector(0 to C_NUM_CS);
   signal shim2IP_RdCE_int     : std_logic_vector(0 to C_NUM_CE);
   signal shim2IP_WrCE_int     : std_logic_vector(0 to C_NUM_CE);
   signal IP2Shim_WrAck_int    : std_logic;
   signal IP2Shim_RdAck_int    : std_logic;

   begin


      IP2Shim_WrAck_int <= IP2Shim_WrAck or invalidWrReq;
      IP2Shim_RdAck_int <= IP2Shim_RdAck or invalidRdReq;

      Shim2IP_Data      <= Bus2Shim_Data ;  --write data

      Shim2Bus_Data     <= IP2Shim_Data;    --read data
      Shim2Bus_WrAck    <= IP2Shim_WrAck_int;
      Shim2Bus_RdAck    <= IP2Shim_rDAck_int;

      ----------------------------------------------------------------------------
      -- Use Chip Select to register the address data; Otherwise Zeros
      ----------------------------------------------------------------------------
      ADDR_REG : process (S_AXI_ACLK)
      begin

         if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESET = '1' or (IP2Shim_WrAck_int = '1' or IP2Shim_RdAck_int = '1') then
               bus2Shim_Addr_reg <= (others => '0');
            elsif Bus2Shim_CS(0) = '1' then
               bus2Shim_Addr_reg <= Bus2Shim_Addr;
            else
               bus2Shim_Addr_reg <= bus2Shim_Addr_reg;
            end if;
         end if;
      end process;

      ----------------------------------------------------------------------------
      -- Use Chip Select to register Chip Select; Otherwise Zero
      ----------------------------------------------------------------------------
      CS_REG : process (S_AXI_ACLK)
      begin

         if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESET = '1' or (IP2Shim_WrAck_int = '1' or IP2Shim_RdAck_int = '1') then
               bus2Shim_CS_reg <= '0';
            elsif Bus2Shim_CS(0) = '1' then
               bus2Shim_CS_reg <= Bus2Shim_CS(0);
            else
               bus2Shim_CS_reg <= bus2Shim_CS_reg;
            end if;
         end if;
      end process;

      ----------------------------------------------------------------------------
      -- Use Chip Select to register Read Not Write; Otherwise Zero
      ----------------------------------------------------------------------------
      RNW_REG : process (S_AXI_ACLK)
      begin

         if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESET = '1' or (IP2Shim_WrAck_int = '1' or IP2Shim_RdAck_int = '1') then
               shim2IP_RNW_int <= '0';
            elsif Bus2Shim_CS(0) = '1' then
               shim2IP_RNW_int <= Bus2Shim_RNW;
            else
               shim2IP_RNW_int <= shim2IP_RNW_int;
            end if;
         end if;
      end process;

      ----------------------------------------------------------------------------
      -- Use Chip Select and Bus2Shim_RNW to register Read Chip Enable
      -- Otherwise Zero
      ----------------------------------------------------------------------------
      RDCE_REG : process (S_AXI_ACLK)
      begin

         if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESET = '1' or (IP2Shim_WrAck_int = '1' or IP2Shim_RdAck_int = '1') then
               bus2Shim_RdCE_reg <= '0';
            elsif Bus2Shim_CS(0) = '1' and Bus2Shim_RNW = '1' then
               bus2Shim_RdCE_reg <= Bus2Shim_RdCE(0);
            else
               bus2Shim_RdCE_reg <= bus2Shim_RdCE_reg;
            end if;
         end if;
      end process;

      ----------------------------------------------------------------------------
      -- Use Chip Select and Bus2Shim_RNW to register Write Chip Enable
      -- Otherwise Zero
      ----------------------------------------------------------------------------
      WRCE_REG : process (S_AXI_ACLK)
      begin

         if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESET = '1' or (IP2Shim_WrAck_int = '1' or IP2Shim_RdAck_int = '1') then
               bus2Shim_WrCE_reg <= '0';
            elsif Bus2Shim_CS(0) = '1' and Bus2Shim_RNW = '0' then
               bus2Shim_WrCE_reg <= Bus2Shim_WrCE(0);
            else
               bus2Shim_WrCE_reg <= bus2Shim_WrCE_reg;
            end if;
         end if;
      end process;


      ----------------------------------------------------------------------------
      -- Decode the address and set appropriate CE
      --    If the Address does not exist, ie it is in a gap,
      --    then set invalidAddrRspns
      ----------------------------------------------------------------------------
      ADDR_DECODE : process (bus2Shim_CS_reg,bus2Shim_RdCE_reg,bus2Shim_WrCE_reg,
                             bus2Shim_Addr_reg)
      begin


         if bus2Shim_CS_reg = '1' then
            if bus2Shim_Addr_reg(14 to 29) = "0000000000000000" then   --0x0
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- RAF
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(0)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(1 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(1 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
            elsif bus2Shim_Addr_reg(14 to 29) = "0000000000000001" then --0x4
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- TPF
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0)               <= '0';
               shim2IP_WrCE_int(0)               <= '0';
               shim2IP_RdCE_int(1)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(1)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(2 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(2 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
            elsif bus2Shim_Addr_reg(14 to 29) = "0000000000000010" then --0x8
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- IFGP
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 1)          <= (others => '0');
               shim2IP_WrCE_int(0 to 1)          <= (others => '0');
               shim2IP_RdCE_int(2)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(2)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(3 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(3 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
            elsif bus2Shim_Addr_reg(14 to 29) = "0000000000000011" then --0xC
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- IS
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 2)          <= (others => '0');
               shim2IP_WrCE_int(0 to 2)          <= (others => '0');
               shim2IP_RdCE_int(3)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(3)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(4 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(4 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
            elsif bus2Shim_Addr_reg(14 to 29) = "0000000000000100" then --0x10
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- IP
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 3)          <= (others => '0');
               shim2IP_WrCE_int(0 to 3)          <= (others => '0');
               shim2IP_RdCE_int(4)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(4)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(5 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(5 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
            elsif bus2Shim_Addr_reg(14 to 29) = "0000000000000101" then --0x14
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- IE
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 4)          <= (others => '0');
               shim2IP_WrCE_int(0 to 4)          <= (others => '0');
               shim2IP_RdCE_int(5)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(5)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(6 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(6 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
            elsif bus2Shim_Addr_reg(14 to 29) = "0000000000000110" then --0x18
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- TTAG
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 5)          <= (others => '0');
               shim2IP_WrCE_int(0 to 5)          <= (others => '0');
               shim2IP_RdCE_int(6)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(6)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(7 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(7 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
            elsif bus2Shim_Addr_reg(14 to 29) = "0000000000000111" then --0x1C
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- RTAG
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 6)          <= (others => '0');
               shim2IP_WrCE_int(0 to 6)          <= (others => '0');
               shim2IP_RdCE_int(7)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(7)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(8 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(8 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
            elsif bus2Shim_Addr_reg(14 to 29) = "0000000000001000" then --0x20
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- UAWL
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 7)          <= (others => '0');
               shim2IP_WrCE_int(0 to 7)          <= (others => '0');
               shim2IP_RdCE_int(8)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(8)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(9 to C_NUM_CE)   <= (others => '0');
               shim2IP_WrCE_int(9 to C_NUM_CE)   <= (others => '0');
               invalidAddrRspns                  <= '0';
            elsif bus2Shim_Addr_reg(14 to 29) = "0000000000001001" then --0x24
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- UAWU
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 8)          <= (others => '0');
               shim2IP_WrCE_int(0 to 8)          <= (others => '0');
               shim2IP_RdCE_int(9)               <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(9)               <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(10 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(10 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
            elsif bus2Shim_Addr_reg(14 to 29) = "0000000000001010" then --0x28
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- TPID0
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 9)          <= (others => '0');
               shim2IP_WrCE_int(0 to 9)          <= (others => '0');
               shim2IP_RdCE_int(10)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(10)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(11 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(11 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
            elsif bus2Shim_Addr_reg(14 to 29) = "0000000000001011" then --0x2C
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- TPID1
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 10)         <= (others => '0');
               shim2IP_WrCE_int(0 to 10)         <= (others => '0');
               shim2IP_RdCE_int(11)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(11)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(12 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(12 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
            elsif bus2Shim_Addr_reg(14 to 29) = "0000000000001100" then --0x30
               shim2IP_CS_int(0)                 <= bus2Shim_CS_reg;      -- PCSPMA Status
               shim2IP_CS_int(1 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 11)         <= (others => '0');
               shim2IP_WrCE_int(0 to 11)         <= (others => '0');
               shim2IP_RdCE_int(12)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(12)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(13 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(13 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';

            -- statistics and temac registers via external shim decode
            elsif bus2Shim_Addr_reg(14 to 22) = "000000001" or
                  bus2Shim_Addr_reg(14 to 21) = "00000001" then        --0x00200 - 0x007FC
               shim2IP_CS_int(0)                 <= '0';
               shim2IP_CS_int(1)                 <= bus2Shim_CS_reg;
               shim2IP_CS_int(2 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 15)         <= (others => '0');
               shim2IP_WrCE_int(0 to 15)         <= (others => '0');
               shim2IP_RdCE_int(16)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(16)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(17 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(17 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
            -- Tx VLAN
            elsif bus2Shim_Addr_reg(14 to 17) = "0001" then        --0x04000 - 0x07FFC
               shim2IP_CS_int(0 to 1)            <= (others => '0');
               shim2IP_CS_int(2)                 <= bus2Shim_CS_reg;
               shim2IP_CS_int(3 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 16)         <= (others => '0');
               shim2IP_WrCE_int(0 to 16)         <= (others => '0');
               shim2IP_RdCE_int(17)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(17)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(18 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(18 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
            -- Rx VLAN
            elsif bus2Shim_Addr_reg(14 to 16) = "001" then        --0x08000 - 0x0BFFC
               shim2IP_CS_int(0 to 2)            <= (others => '0');
               shim2IP_CS_int(3)                 <= bus2Shim_CS_reg;
               shim2IP_CS_int(4 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 17)         <= (others => '0');
               shim2IP_WrCE_int(0 to 17)         <= (others => '0');
               shim2IP_RdCE_int(18)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(18)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(19 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(19 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
            -- AVB
            elsif bus2Shim_Addr_reg(14 to 15) = "01" then        --0x010000 - 0x013FFC
               shim2IP_CS_int(0 to 3)            <= (others => '0');
               shim2IP_CS_int(4)                 <= bus2Shim_CS_reg;
               shim2IP_CS_int(5 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 18)         <= (others => '0');
               shim2IP_WrCE_int(0 to 18)         <= (others => '0');
               shim2IP_RdCE_int(19)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(19)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(20 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(20 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
            -- multicast
            elsif bus2Shim_Addr_reg(14) = '1' then        --0x020000 - 0x03FFFC
               shim2IP_CS_int(0 to 4)            <= (others => '0');
               shim2IP_CS_int(5)                 <= bus2Shim_CS_reg;
               shim2IP_CS_int(6 to C_NUM_CS)     <= (others => '0');
               shim2IP_RdCE_int(0 to 19)         <= (others => '0');
               shim2IP_WrCE_int(0 to 19)         <= (others => '0');
               shim2IP_RdCE_int(20)              <= bus2Shim_RdCE_reg;
               shim2IP_WrCE_int(20)              <= bus2Shim_WrCE_reg;
               shim2IP_RdCE_int(21 to C_NUM_CE)  <= (others => '0');
               shim2IP_WrCE_int(21 to C_NUM_CE)  <= (others => '0');
               invalidAddrRspns                  <= '0';
            else
               shim2IP_CS_int       <= (others => '0');
               shim2IP_RdCE_int     <= (others => '0');
               shim2IP_WrCE_int     <= (others => '0');
               invalidAddrRspns     <= '1';
            end if;
         else
            shim2IP_CS_int       <= (others => '0');
            shim2IP_RdCE_int     <= (others => '0');
            shim2IP_WrCE_int     <= (others => '0');
            invalidAddrRspns     <= '0';
         end if;
      end process;


      ----------------------------------------------------------------------------
      -- Register Address Decode Signals for timing
      ----------------------------------------------------------------------------
      REG_DECODE_SIGNALS : process (S_AXI_ACLK)
      begin

         if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESET = '1' or IP2Shim_WrAck_int = '1' or IP2Shim_RdAck_int = '1' then
               shim2IP_CS   <= (others => '0');
               shim2IP_RdCE <= (others => '0');
               shim2IP_WrCE <= (others => '0');
               shim2IP_RNW  <= '0';
               Shim2IP_Addr <= (others => '0');
            else
               shim2IP_CS   <= shim2IP_CS_int  ;
               shim2IP_RdCE <= shim2IP_RdCE_int;
               shim2IP_WrCE <= shim2IP_WrCE_int;
               shim2IP_RNW  <= shim2IP_RNW_int;
               Shim2IP_Addr <= bus2Shim_Addr_reg;
            end if;
         end if;
      end process;


      ----------------------------------------------------------------------------
      -- Delay invalid response for rising edge detect
      ----------------------------------------------------------------------------
      DELAY_INVALID_RESPONSE : process (S_AXI_ACLK)
      begin

         if rising_edge(S_AXI_ACLK) then
            if bus2Shim_CS_reg = '1' then
               invalidAddrRspns_reg <= invalidAddrRspns;
            else
               invalidAddrRspns_reg <= '0';
            end if;
         end if;
      end process;



      ----------------------------------------------------------------------------
      -- Set invalid Request for Read transaction if it occured
      ----------------------------------------------------------------------------
      SET_INVALID_READ : process (S_AXI_ACLK)
      begin

         if rising_edge(S_AXI_ACLK) then
            if bus2Shim_RdCE_reg = '1' then
               --Pulse signal using rising edge detection
               invalidRdReq <= invalidAddrRspns and not invalidAddrRspns_reg;
            else
               invalidRdReq <= '0';
            end if;
         end if;
      end process;


      ----------------------------------------------------------------------------
      -- Set invalid Request for Write transaction if it occured
      ----------------------------------------------------------------------------
      SET_INVALID_WRITE : process (S_AXI_ACLK)
      begin

         if rising_edge(S_AXI_ACLK) then
            if bus2Shim_WrCE_reg = '1' then
               --Pulse signal using rising edge detection
               invalidWrReq <= invalidAddrRspns and not invalidAddrRspns_reg;
            else
               invalidWrReq <= '0';
            end if;
         end if;
      end process;


end rtl;
