------------------------------------------------------------------------------
-- rx_axistream_if.vhd
------------------------------------------------------------------------------
-- (c) Copyright 2004-2009 Xilinx, Inc. All rights reserved.
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
-- AND CONDITIONS, EXPRESS, rtlLIED, OR STATUTORY, INCLUDING
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
-- ------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
-- Filename:        rx_axistream_if.vhd
-- Version:         v1.00a
-- Description:     Receive interface between AXIStream and Temac
--
------------------------------------------------------------------------------
-- Structure:   This section should show the hierarchical structure of the
--              designs. Separate lines with blank lines if necessary to rtlrove
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
-- Author:          MSH
--
--  MSH     07/01/10
-- ^^^^^^
--  - Initial release of v1.00.a
-- ~~~~~~
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
use ieee.std_logic_arith.all;
use ieee.std_logic_arith.conv_integer;
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.coregen_comp_defs.all;
use proc_common_v3_00_a.proc_common_pkg.log2;
use proc_common_v3_00_a.family_support.all;
use proc_common_v3_00_a.all;

-- synopsys translate_off
library XilinxCoreLib;
-- synopsys translate_on

library unisim;
use unisim.vcomponents.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

-------------------------------------------------------------------------------
-- Definition of Generics :
-------------------------------------------------------------------------------
-- System generics
--  C_FAMILY              -- Xilinx FPGA Family
--
-- Ethernet generics
--  C_TYPE
--     0  Soft TEMAC capable of 10 or 100 Mbps
--     1  Soft TEMAC capable of 10, 100, or 1000 Mbps
--     2  V6 hard TEMAC capable of 10, 100, or 1000 Mbps
--  C_PHY_TYPE
--     0  MII
--     1  GMII
--     2  RGMII V1.3
--     3  RGMII V2.0
--     4  SGMII
--     5  1000Base-X PCS/PMA @ 1 Gbps
--     6  1000Base-X PCS/PMA @ 2 Gbps (C_TYPE=2 only)
--     7  1000Base-X PCS/PMA @ 2.5 Gbps (C_TYPE=2 only)
--  C_RXD_MEM_BYTES               -- Depth of RX memory in Bytes
--  C_RXCSUM
--     0  No checksum offloading
--     1  Partial (legacy) checksum offloading
--     2  Full checksum offloading
--  C_RXVLAN_TRAN         -- Enable RX enhanced VLAN translation
--  C_RXVLAN_TAG          -- Enable RX enhanced VLAN taging
--  C_RXVLAN_STRP         -- Enable RX enhanced VLAN striping
--  C_MCAST_EXTEND        -- Enable RX extended multicast address filtering
--  C_STATS               -- Enable statistics gathering

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Ports :
-------------------------------------------------------------------------------
--    BUS2IP_CLK
--    BUS2IP_RESET
--
--    AXI_STR_RXD_ACLK
--    AXI_STR_RXD_VALID
--    AXI_STR_RXD_READY
--    AXI_STR_RXD_LAST
--    AXI_STR_RXD_STRB
--    AXI_STR_RXD_DATA
--
--    AXI_STR_RXS_ACLK
--    AXI_STR_RXS_VALID
--    AXI_STR_RXS_READY
--    AXI_STR_RXS_LAST
--    AXI_STR_RXS_STRB
--    AXI_STR_RXS_DATA
--
--    EMAC_CLIENT_RXD_LEGACY
--    EMAC_CLIENT_RXD_VLD_LEGACY
--    EMAC_CLIENT_RX_GOODFRAME_LEGACY
--    EMAC_CLIENT_RX_BADFRAME_LEGACY
--    EMAC_CLIENT_RX_FRAMEDROP
--    LEGACY_RX_FILTER_MATCH
--
--    RX_CLIENT_CLK
--    RX_CLIENT_CLK_ENBL
--
--    EMAC_CLIENT_RX_STATS
--    EMAC_CLIENT_RX_STATS_VLD
--    EMAC_CLIENT_RX_STATS_BYTE_VLD
--    EMAC_CLIENT_RXD_VLD_2STATS
--    SOFT_EMAC_CLIENT_RX_STATS
--
--    RTAGREGDATA
--    TPID0REGDATA
--    TPID1REGDATA
--    UAWLREGDATA
--    UAWUREGDATA
--    RXCLCLKMCASTADDR
--    RXCLCLKMCASTEN
--    RXCLCLKMCASTRDDATA
--    LLINKCLKVLANADDR
--    LLINKCLKVLANRDDATA
--    LLINKCLKRXVLANBRAMENA
--
--    LLINKCLKEMULTIFLTRENBL
--    LLINKCLKNEWFNCENBL
--    LLINKCLKRXVSTRPMODE
--    LLINKCLKRXVTAGMODE
-------------------------------------------------------------------------------
----                  Entity Section
-------------------------------------------------------------------------------

entity rx_axistream_if is
  generic (
    C_RXD_MEM_BYTES       : integer                       := 4096;
    C_RXD_MEM_ADDR_WIDTH  : integer                       := 10;
    C_RXS_MEM_BYTES       : integer                       := 4096;
    C_RXS_MEM_ADDR_WIDTH  : integer                       := 10;
    C_FAMILY              : string                        := "virtex6";
    C_TYPE                : integer range 0 to 2          := 0;
      -- 0 - Soft TEMAC capable of 10 or 100 Mbps
      -- 1 - Soft TEMAC capable of 10, 100, or 1000 Mbps
      -- 2 - V6 hard TEMAC
    C_PHY_TYPE            : integer range 0 to 7          := 1;
      -- 0 - MII
      -- 1 - GMII
      -- 2 - RGMII V1.3
      -- 3 - RGMII V2.0
      -- 4 - SGMII
      -- 5 - 1000Base-X PCS/PMA @ 1 Gbps
      -- 6 - 1000Base-X PCS/PMA @ 2 Gbps (C_TYPE=2 only)
      -- 7 - 1000Base-X PCS/PMA @ 2.5 Gbps (C_TYPE=2 only)
    C_RXCSUM              : integer range 0 to 2          := 0;
      -- 0 - No checksum offloading
      -- 1 - Partial (legacy) checksum offloading
      -- 2 - Full checksum offloading
    C_RXVLAN_TRAN         : integer range 0 to 1          := 0;
    C_RXVLAN_TAG          : integer range 0 to 1          := 0;
    C_RXVLAN_STRP         : integer range 0 to 1          := 0;
    C_MCAST_EXTEND        : integer range 0 to 1          := 0;
    C_STATS               : integer range 0 to 1          := 0
    );

  port    (
    AXI_STR_RXD_ACLK                : in  std_logic;                                        --  Receive AXI-Stream Data Clock
    AXI_STR_RXD_VALID               : out std_logic;                                        --  Receive AXI-Stream Data VALID
    AXI_STR_RXD_READY               : in  std_logic;                                        --  Receive AXI-Stream Data READY
    AXI_STR_RXD_LAST                : out std_logic;                                        --  Receive AXI-Stream Data LAST
    AXI_STR_RXD_STRB                : out std_logic_vector(3 downto 0);                     --  Receive AXI-Stream Data STRB
    AXI_STR_RXD_DATA                : out std_logic_vector(31 downto 0);                    --  Receive AXI-Stream Data DATA
    RESET2AXI_STR_RXD               : in  std_logic;                                        --  Reset

    AXI_STR_RXS_ACLK                : in  std_logic;                                        --  Receive AXI-Stream Status Clock
    AXI_STR_RXS_VALID               : out std_logic;                                        --  Receive AXI-Stream Status VALID
    AXI_STR_RXS_READY               : in  std_logic;                                        --  Receive AXI-Stream Status READY
    AXI_STR_RXS_LAST                : out std_logic;                                        --  Receive AXI-Stream Status LAST
    AXI_STR_RXS_STRB                : out std_logic_vector(3 downto 0);                     --  Receive AXI-Stream Status STRB
    AXI_STR_RXS_DATA                : out std_logic_vector(31 downto 0);                    --  Receive AXI-Stream Status DATA
    RESET2AXI_STR_RXS               : in  std_logic;                                        --  Reset

    AXI_STR_RXD_DPMEM_WR_DATA       : out std_logic_vector(35 downto 0);                    --  Receive Data Memory Wr Data
    AXI_STR_RXD_DPMEM_RD_DATA       : in  std_logic_vector(35 downto 0);                    --  Receive Data Memory Rd Data
    AXI_STR_RXD_DPMEM_WR_EN         : out std_logic_vector(0 downto 0);                     --  Receive Data Memory Wr Enable
    AXI_STR_RXD_DPMEM_ADDR          : out std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);  --  Receive Data Memory Addr

    AXI_STR_RXS_DPMEM_WR_DATA       : out std_logic_vector(35 downto 0);                    --  Receive Status Memory Wr Data
    AXI_STR_RXS_DPMEM_RD_DATA       : in  std_logic_vector(35 downto 0);                    --  Receive Status Memory Rd Data
    AXI_STR_RXS_DPMEM_WR_EN         : out std_logic_vector(0 downto 0);                     --  Receive Status Memory Wr Enable
    AXI_STR_RXS_DPMEM_ADDR          : out std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);  --  Receive Status Memory Addr

    AXI_STR_RXS_MEM_LAST_READ_OUT_PTR_GRAY : out std_logic_vector(35 downto 0);             --  Receive Status GRAY Pointer
    AXI_STR_RXD_MEM_LAST_READ_OUT_PTR_GRAY : out std_logic_vector(35 downto 0)              --  Receive Data GRAY Pointer
    );
end rx_axistream_if;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of rx_axistream_if is

---------------------------------------------------------------------
-- Functions
---------------------------------------------------------------------

-- Convert a binary value into a gray code
function bin_to_gray (
   bin : std_logic_vector)
   return std_logic_vector is

   variable gray : std_logic_vector(bin'range);

begin

   for i in bin'range loop
      if i = bin'left then
         gray(i) := bin(i);
      else
         gray(i) := bin(i+1) xor bin(i);
      end if;
   end loop;  -- i

   return gray;

end bin_to_gray;

constant PRE_GRAY_CODED_FF : std_logic_vector(35 downto 0) := x"FFFFFFFFF";

type RXS_AXISTREAM_STATES is (
  RESET_INIT_1,
  RESET_INIT_2,
  READ_RXD_MEM_NEXT_AVAILABLE4WRITE_PTR_1,
  READ_RXD_MEM_NEXT_AVAILABLE4WRITE_PTR_2,
  ADDR_SETUP_PAUSE_1,
  READ_RXD_MEM_LAST_READ_OUT_PTR,
  ADDR_SETUP_PAUSE_2,
  READ_RXS_MEM_NEXT_AVAILABLE4WRITE_PTR_1,
  READ_RXS_MEM_NEXT_AVAILABLE4WRITE_PTR_2,
  ADDR_SETUP_PAUSE_3,
  READ_RXS_MEM_LAST_READ_OUT_PTR,
  PAUSE_READ_STATUS_WORD1,
  READ_STATUS_WORD1,
  READ_STATUS_WORD2,
  READ_STATUS_WORD3,
  READ_STATUS_WORD4,
  READ_STATUS_WORD5,
  READ_STATUS_WORD6,
  UPDATE_RXS_MEM_LAST_READ_OUT_PTR,
  SEND_STATUS_WORD1,
  SEND_STATUS_WORD2,
  SEND_STATUS_WORD3,
  SEND_STATUS_WORD4,
  SEND_STATUS_WORD5,
  SEND_STATUS_WORD6,
  WAIT_FRAME_DONE,
  UPDATE_RXD_MEM_LAST_READ_OUT_PTR,
  REPEAT_AGAIN
  );

signal rxs_axistream_current_state : RXS_AXISTREAM_STATES;
signal rxs_axistream_next_state    : RXS_AXISTREAM_STATES;

type RXD_AXISTREAM_STATES is (
  IDLE,
  PRIME,
  RD_FRAME_FROM_MEM,
  ALMOST_FULL_WAIT1,
  ALMOST_FULL_WAIT2,
  ALMOST_FULL_WAIT3,
  ALMOST_FULL_WAIT4,
  WAIT_END_FRAME,
  PRE_IDLE);

signal rxd_axistream_current_state : RXD_AXISTREAM_STATES;
signal rxd_axistream_next_state    : RXD_AXISTREAM_STATES;

signal rxs_mem_next_available4write_ptr_1_reg : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_next_available4write_ptr_1_cmb : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);

signal rxd_mem_next_available4write_ptr_1_reg : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);
signal rxd_mem_next_available4write_ptr_1_cmb : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);

signal axi_str_rxs_dpmem_rd_data_d1           : std_logic_vector(35 downto 0);

signal rxd2rxs_frame_done                     : std_logic;
signal rxs2rxd_frame_done                     : std_logic;

signal frame_length_bytes               : std_logic_vector(15 downto 0);
signal frame_length_words               : integer range 0 to 32767;
signal last_rxd_strb                    : std_logic_vector(3 downto 0);

signal rxd_mem_next_available4write_ptr_cmb : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);
signal rxd_mem_next_available4write_ptr_reg : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);
signal rxd_mem_last_read_out_ptr_cmb        : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);
signal rxd_mem_last_read_out_ptr_reg        : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_next_available4write_ptr_cmb : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_next_available4write_ptr_reg : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_last_read_out_ptr_true_cmb   : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_last_read_out_ptr_true_reg   : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_last_read_out_ptr_cmb        : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_last_read_out_ptr_reg        : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_last_read_out_ptr_plus_one   : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);

signal rxd_mem_full_mask                : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);
signal rxd_mem_full_mask_minus_one      : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);
signal rxd_mem_empty_mask               : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);
signal rxd_mem_one_mask                 : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);
signal rxd_mem_two_mask                 : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_full_mask                : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_full_mask_minus_one      : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_empty_mask               : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_one_mask                 : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_two_mask                 : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_three_mask               : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_four_mask                : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);

signal zero_extend_rxd_mask36           : std_logic_vector(35 downto C_RXD_MEM_ADDR_WIDTH + 1);
signal zero_extend_rxs_mask36           : std_logic_vector(35 downto C_RXS_MEM_ADDR_WIDTH + 1);

signal rxs_status_word_1                : std_logic_vector(35 downto 0);
signal rxs_status_word_2                : std_logic_vector(35 downto 0);
signal rxs_status_word_3                : std_logic_vector(35 downto 0);
signal rxs_status_word_4                : std_logic_vector(35 downto 0);
signal rxs_status_word_5                : std_logic_vector(35 downto 0);
signal rxs_status_word_6                : std_logic_vector(35 downto 0);

signal rxd_addr_cntr_en                 : std_logic;
signal rxd_mem_addr_cntr                : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);

signal rxs2rxd_frame_ready              : std_logic;

signal fifoDataIn    : std_logic_vector(0 to 35);
signal fifoWrEn      : std_logic;
signal fifoRdEn      : std_logic;
signal fifoDataOut   : std_logic_vector(0 to 35);
signal fifoFull      : std_logic;
signal fifoEmpty     : std_logic;
signal fifoDataCount      : std_logic_vector(0 to 5);
signal fifoAlmostFull     : std_logic;
signal rxd_addr_cntr_load : std_logic;
signal rxd_word_cnt       : integer range 0 to 32767;
signal rxd_word_cnt_vector : std_logic_vector (15 downto 0);

signal rxd_mem_last_read_out_ptr_gray_d1           : std_logic_vector(35 downto 0);
signal rxd_mem_last_read_out_ptr_gray              : std_logic_vector(35 downto 0);
signal rxd_mem_last_read_out_ptr_toconvertto_gray  : std_logic_vector(35 downto 0);

signal rxs_mem_last_read_out_ptr_toconvertto_gray        : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_last_read_out_ptr_toconvertto_gray_clean  : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_last_read_out_ptr_gray                    : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_last_read_out_ptr_gray_d1                 : std_logic_vector(35 downto 0);

--------------------------------------------------------
-- Declare general attributes used in this file
-- for defining each component being used with
-- the generatecore utility

attribute box_type: string;
attribute GENERATOR_DEFAULT: string;

  -----------------------------------------------------------------------------
  -- The following is the location of the DualPort Memory pointers in the RXS
  -- memory
  -- Address:  Pointer:
  --   0x0       rxd_mem_next_available4write_ptr
  --   0x1       rxd_mem_last_read_out_ptr
  --   0x2       rxs_mem_next_available4write_ptr
  --   0x3       rxs_mem_last_read_out_ptr
  -----------------------------------------------------------------------------

begin

  -------------------------------------------------------------------------
  -- Convert binary encoded RXS last read pointer to gray encoded to send
  -- to receive client interface
  -------------------------------------------------------------------------
  GET_RXS_LAST_READ_GRAY_PROCESS: process (AXI_STR_RXS_ACLK)
  begin
    if rising_edge(AXI_STR_RXS_ACLK) then
      if RESET2AXI_STR_RXS = '1' then
        rxs_mem_last_read_out_ptr_toconvertto_gray <= (others => '0');
      else
        if (rxs_axistream_current_state = READ_STATUS_WORD6 or
            rxs_axistream_current_state = READ_STATUS_WORD1 or
            rxs_axistream_current_state = READ_STATUS_WORD2 or
            rxs_axistream_current_state = READ_STATUS_WORD3 or
            rxs_axistream_current_state = READ_STATUS_WORD4 or
            rxs_axistream_current_state = READ_STATUS_WORD5
        ) then
          rxs_mem_last_read_out_ptr_toconvertto_gray <= rxs_mem_last_read_out_ptr_reg;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------------
  -- This processes ensures that the grey code is clean
  -------------------------------------------------------------------------------
  process(AXI_STR_RXS_ACLK)
    begin
      if rising_edge(AXI_STR_RXS_ACLK) then
        if RESET2AXI_STR_RXS = '1' then
          rxs_mem_last_read_out_ptr_toconvertto_gray_clean <= (others => '0');
        else
          if(conv_integer(rxs_mem_last_read_out_ptr_toconvertto_gray) > 0) then
            if(rxs_mem_last_read_out_ptr_toconvertto_gray_clean < rxs_mem_last_read_out_ptr_toconvertto_gray) then
              rxs_mem_last_read_out_ptr_toconvertto_gray_clean <= rxs_mem_last_read_out_ptr_toconvertto_gray_clean + '1';
            elsif(rxs_mem_last_read_out_ptr_toconvertto_gray_clean > rxs_mem_last_read_out_ptr_toconvertto_gray) then
              rxs_mem_last_read_out_ptr_toconvertto_gray_clean <= rxs_mem_last_read_out_ptr_toconvertto_gray_clean + '1';
            end if;
        end if;
        end if;
      end if;
  end process;

  rxs_mem_last_read_out_ptr_gray <= bin_to_gray(rxs_mem_last_read_out_ptr_toconvertto_gray_clean);

  -------------------------------------------------------------------------
  -- Register gray encoded RXS last read pointer to send to receive client
  -- interface. reset to all ones at power-up
  -------------------------------------------------------------------------
  RXS_LAST_READ_GRAY_PROCESS: process (AXI_STR_RXS_ACLK)
  begin
    if rising_edge(AXI_STR_RXS_ACLK) then
      if RESET2AXI_STR_RXS = '1' then
        rxs_mem_last_read_out_ptr_gray_d1  <= bin_to_gray(PRE_GRAY_CODED_FF);
      else
        rxs_mem_last_read_out_ptr_gray_d1(35 downto C_RXS_MEM_ADDR_WIDTH + 1) <= (others => '0');
        rxs_mem_last_read_out_ptr_gray_d1(C_RXS_MEM_ADDR_WIDTH downto 0) <= rxs_mem_last_read_out_ptr_gray;
      end if;
    end if;
  end process;

  AXI_STR_RXS_MEM_LAST_READ_OUT_PTR_GRAY <= rxs_mem_last_read_out_ptr_gray_d1;

  -------------------------------------------------------------------------
  -- Convert binary encoded RXD last read pointer to gray encoded to send
  -- to receive client interface
  -------------------------------------------------------------------------
  rxd_mem_last_read_out_ptr_toconvertto_gray(35 downto C_RXD_MEM_ADDR_WIDTH + 1) <= (others => '0');
  rxd_mem_last_read_out_ptr_toconvertto_gray(C_RXD_MEM_ADDR_WIDTH downto 0) <= (rxd_mem_addr_cntr - 1) when
    not(rxs_axistream_current_state = UPDATE_RXD_MEM_LAST_READ_OUT_PTR) else
    (rxd_mem_last_read_out_ptr_reg - '1');
  rxd_mem_last_read_out_ptr_gray <= bin_to_gray(rxd_mem_last_read_out_ptr_toconvertto_gray);

  -------------------------------------------------------------------------
  -- Register gray encoded RXD last read pointer to send to receive client
  -- interface. reset to all ones at power-up
  -------------------------------------------------------------------------
  RXD_LAST_READ_GRAY_PROCESS: process (AXI_STR_RXS_ACLK)
  begin
    if rising_edge(AXI_STR_RXS_ACLK) then
      if RESET2AXI_STR_RXS = '1' then
        rxd_mem_last_read_out_ptr_gray_d1  <= bin_to_gray(PRE_GRAY_CODED_FF);
      else
        if (rxs_axistream_current_state = SEND_STATUS_WORD1 or
            rxs_axistream_current_state = SEND_STATUS_WORD2 or
            rxs_axistream_current_state = SEND_STATUS_WORD3 or
            rxs_axistream_current_state = SEND_STATUS_WORD4 or
            rxs_axistream_current_state = SEND_STATUS_WORD5 or
            rxs_axistream_current_state = SEND_STATUS_WORD6 or
            ((rxs_axistream_current_state = WAIT_FRAME_DONE) and (rxd_addr_cntr_en = '1'))   or
            rxs_axistream_current_state = UPDATE_RXD_MEM_LAST_READ_OUT_PTR
        ) then
          rxd_mem_last_read_out_ptr_gray_d1 <= rxd_mem_last_read_out_ptr_gray;
        end if;
      end if;
    end if;
  end process;

  AXI_STR_RXD_MEM_LAST_READ_OUT_PTR_GRAY <= rxd_mem_last_read_out_ptr_gray_d1;

-------------------------------------------------------------------------------

  PIPE_RXS_READ_DATA: process (AXI_STR_RXS_ACLK) -- clock to out of BRAM is slow so register it to make timing easier
  begin
    if rising_edge(AXI_STR_RXS_ACLK) then
      if RESET2AXI_STR_RXS = '1' then
        axi_str_rxs_dpmem_rd_data_d1 <= (others => '0');
      else
        axi_str_rxs_dpmem_rd_data_d1 <= AXI_STR_RXS_DPMEM_RD_DATA;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- Generate variable width address masks for checking memory pointers
  -------------------------------------------------------------------------
  RXD_GEN_MASK: for I in C_RXD_MEM_ADDR_WIDTH downto 0 generate
    rxd_mem_full_mask(I) <= '1';
    rxd_mem_empty_mask(I)  <= '0';
  end generate;

  rxd_mem_one_mask            <= rxd_mem_empty_mask + 1;
  rxd_mem_two_mask            <= rxd_mem_empty_mask + 2;
  rxd_mem_full_mask_minus_one <= rxd_mem_full_mask - 1;

  RXS_GEN_MASK: for I in C_RXS_MEM_ADDR_WIDTH downto 0 generate
    rxs_mem_full_mask(I) <= '1';
    rxs_mem_empty_mask(I)  <= '0';
  end generate;

  rxs_mem_one_mask            <= rxs_mem_empty_mask + 1;
  rxs_mem_two_mask            <= rxs_mem_empty_mask + 2;
  rxs_mem_three_mask          <= rxs_mem_empty_mask + 3;
  rxs_mem_four_mask           <= rxs_mem_empty_mask + 4;
  rxs_mem_full_mask_minus_one <= rxs_mem_full_mask - 1;

  zero_extend_rxd_mask36      <= (others => '0');
  zero_extend_rxs_mask36      <= (others => '0');


  RXD_MEM_ADDR_COUNTER: process (AXI_STR_RXD_ACLK)
  begin
    if rising_edge(AXI_STR_RXD_ACLK) then
      if RESET2AXI_STR_RXD = '1' then
        rxd_mem_addr_cntr    <= (others => '0');
      elsif (rxd_addr_cntr_load = '1') then
        rxd_mem_addr_cntr  <= rxs_status_word_1(C_RXD_MEM_ADDR_WIDTH downto 0);
      else
        if (rxd_addr_cntr_en = '1') then
          rxd_mem_addr_cntr  <= rxd_mem_addr_cntr + 1;
        end if;
      end if;
    end if;
  end process;

  rxd_word_cnt_vector(15 downto 0) <= conv_std_logic_vector(rxd_word_cnt,16);

  STORE_STATUS_WORDS: process (AXI_STR_RXS_ACLK)
  --  There is no chance of a simultaneous RXD DPMEM write/read here because at this point this
  --  area of memory has long since been written
  begin
    if rising_edge(AXI_STR_RXS_ACLK) then
      if RESET2AXI_STR_RXS = '1' then
        rxs_status_word_1         <= (others => '0');
        rxs_status_word_2         <= (others => '0');
        rxs_status_word_3         <= (others => '0');
        rxs_status_word_4         <= (others => '0');
        rxs_status_word_5         <= (others => '0');
        rxs_status_word_6         <= (others => '0');
        frame_length_bytes        <= (others => '0');
        frame_length_words        <= 0;
        last_rxd_strb             <= (others => '1');
      else
        if (rxs_axistream_current_state = READ_STATUS_WORD1) then
          rxs_status_word_1  <= axi_str_rxs_dpmem_rd_data_d1;
          frame_length_bytes <= axi_str_rxs_dpmem_rd_data_d1(31 downto 16);
          case axi_str_rxs_dpmem_rd_data_d1(17 downto 16) is
            when "00" =>
              frame_length_words  <= conv_integer(axi_str_rxs_dpmem_rd_data_d1(31 downto 18));
              last_rxd_strb       <= x"f";
            when "01" =>
              frame_length_words  <= conv_integer(axi_str_rxs_dpmem_rd_data_d1(31 downto 18)) + 1;
              last_rxd_strb       <= x"1";
            when "10" =>
              frame_length_words  <= conv_integer(axi_str_rxs_dpmem_rd_data_d1(31 downto 18)) + 1;
              last_rxd_strb       <= x"3";
            when "11" =>
              frame_length_words  <= conv_integer(axi_str_rxs_dpmem_rd_data_d1(31 downto 18)) + 1;
              last_rxd_strb       <= x"7";
            -- coverage off
            when others => null;
            -- coverage on
          end case;
        end if;
        if (rxs_axistream_current_state = READ_STATUS_WORD2) then
          rxs_status_word_2  <= AXI_STR_RXS_DPMEM_RD_DATA;
        end if;
        if (rxs_axistream_current_state = READ_STATUS_WORD3) then
          rxs_status_word_3  <= AXI_STR_RXS_DPMEM_RD_DATA;
        end if;
        if (rxs_axistream_current_state = READ_STATUS_WORD4) then
          rxs_status_word_4  <= AXI_STR_RXS_DPMEM_RD_DATA;
        end if;
        if (rxs_axistream_current_state = READ_STATUS_WORD5) then
          rxs_status_word_5  <= AXI_STR_RXS_DPMEM_RD_DATA;
        end if;
        if (rxs_axistream_current_state = READ_STATUS_WORD6) then
          rxs_status_word_6  <= AXI_STR_RXS_DPMEM_RD_DATA;
        end if;
      end if;
    end if;
  end process;

  INC_RXS_MEM_LAST_READ_OUT: process (AXI_STR_RXS_ACLK)
  begin
    if rising_edge(AXI_STR_RXS_ACLK) then
      if RESET2AXI_STR_RXS = '1' then
        rxs_mem_last_read_out_ptr_plus_one <= (others => '1');
      else
        if (rxs_mem_last_read_out_ptr_cmb = rxs_mem_full_mask)then
          rxs_mem_last_read_out_ptr_plus_one <= rxs_mem_four_mask;
        else
          rxs_mem_last_read_out_ptr_plus_one <= rxs_mem_last_read_out_ptr_cmb + 1;
        end if;
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------
  -- receive status AXIStream State Machine
  -- RXSTSSM_REGS_PROCESS: registered process of the state machine
  -- RXSTSSM_CMB_PROCESS:  combinatorial next-state logic
  --------------------------------------------------------------------------

  RXSTSSM_REGS_PROCESS: process (AXI_STR_RXS_ACLK)
  begin
    if rising_edge(AXI_STR_RXS_ACLK) then
      if RESET2AXI_STR_RXS = '1' then
        rxs_axistream_current_state            <= RESET_INIT_1;
        rxd_mem_last_read_out_ptr_reg          <= (others => '0');
        rxs_mem_last_read_out_ptr_reg          <= (others => '0');
        rxs_mem_last_read_out_ptr_true_reg     <= (others => '0');
        rxd_mem_next_available4write_ptr_reg   <= (others => '0');
        rxs_mem_next_available4write_ptr_reg   <= (others => '0');
        rxs_mem_next_available4write_ptr_1_reg <= (others => '0');
        rxd_mem_next_available4write_ptr_1_reg <= (others => '0');
      else
        rxs_axistream_current_state            <= rxs_axistream_next_state;
        rxd_mem_last_read_out_ptr_reg          <= rxd_mem_last_read_out_ptr_cmb;
        rxs_mem_last_read_out_ptr_reg          <= rxs_mem_last_read_out_ptr_cmb;
        rxs_mem_last_read_out_ptr_true_reg     <= rxs_mem_last_read_out_ptr_true_cmb;
        rxs_mem_next_available4write_ptr_reg   <= rxs_mem_next_available4write_ptr_cmb;
        rxd_mem_next_available4write_ptr_reg   <= rxd_mem_next_available4write_ptr_cmb;
        rxs_mem_next_available4write_ptr_1_reg <= rxs_mem_next_available4write_ptr_1_cmb;
        rxd_mem_next_available4write_ptr_1_reg <= rxd_mem_next_available4write_ptr_1_cmb;
      end if;
    end if;
  end process;

  RXSTSSM_CMB_PROCESS: process (
    rxs_axistream_current_state,
    AXI_STR_RXS_DPMEM_RD_DATA,
    rxd2rxs_frame_done,
    AXI_STR_RXS_READY,
    rxs_mem_last_read_out_ptr_reg,
    rxs_mem_last_read_out_ptr_cmb,
    rxs_mem_last_read_out_ptr_true_reg,
    rxs_mem_last_read_out_ptr_true_cmb,
    rxd_mem_last_read_out_ptr_reg,
    rxd_mem_last_read_out_ptr_cmb,
    rxs_mem_next_available4write_ptr_reg,
    rxs_mem_next_available4write_ptr_cmb,
    rxd_mem_next_available4write_ptr_reg,
    rxd_mem_next_available4write_ptr_cmb,
    rxs_mem_empty_mask,
    rxs_mem_three_mask,
    rxs_mem_full_mask,
    rxd_addr_cntr_en,
    rxd_mem_addr_cntr,
    rxs_mem_two_mask,
    rxs_mem_one_mask,
    rxs_mem_four_mask,
    rxs_mem_last_read_out_ptr_plus_one,
    rxs_status_word_2,
    rxs_status_word_3,
    rxs_status_word_4,
    rxs_status_word_5,
    rxs_status_word_6,
    axi_str_rxs_dpmem_rd_data_d1,
    rxs_mem_next_available4write_ptr_1_reg,
    rxd_mem_next_available4write_ptr_1_reg,
    rxs_mem_next_available4write_ptr_1_cmb,
    rxd_mem_next_available4write_ptr_1_cmb
    )
  begin
    rxs_mem_last_read_out_ptr_cmb        <= rxs_mem_last_read_out_ptr_reg;
    rxd_mem_last_read_out_ptr_cmb        <= rxd_mem_last_read_out_ptr_reg;
    rxs_mem_last_read_out_ptr_true_cmb   <= rxs_mem_last_read_out_ptr_true_reg;
    rxs_mem_next_available4write_ptr_cmb <= rxs_mem_next_available4write_ptr_reg;
    rxd_mem_next_available4write_ptr_cmb <= rxd_mem_next_available4write_ptr_reg;

    rxs_mem_next_available4write_ptr_1_cmb <= rxs_mem_next_available4write_ptr_1_reg;
    rxd_mem_next_available4write_ptr_1_cmb <= rxd_mem_next_available4write_ptr_1_reg;

    AXI_STR_RXD_DPMEM_WR_DATA            <= (others => '0');
    AXI_STR_RXD_DPMEM_WR_EN              <= (others => '0');
    AXI_STR_RXS_DPMEM_WR_DATA            <= (others => '0');
    AXI_STR_RXS_DPMEM_WR_EN              <= (others => '0');
    AXI_STR_RXS_DPMEM_ADDR               <= rxs_mem_three_mask; -- rxs_mem_last_read_out_ptr
    rxs2rxd_frame_ready                  <= '0';
    AXI_STR_RXS_VALID                    <= '0';
    AXI_STR_RXS_LAST                     <= '0';
    AXI_STR_RXS_STRB                     <= X"F";
    AXI_STR_RXS_DATA                     <= (others => '0');

    case rxs_axistream_current_state is

      when RESET_INIT_1 =>
      -- we must wait until the rx client interface has initialized the ptrs in dpmem;
      --  2 consecutive reads in case of write/read collision
        if (axi_str_rxs_dpmem_rd_data_d1 = rxs_mem_full_mask) then
          rxs_axistream_next_state <= RESET_INIT_2; -- good to go fro second read
          AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_three_mask; --  rxs_mem_last_read_out_ptr rxs mem last
                                                          --  read out for write should be all 1's
        else
          rxs_axistream_next_state <= RESET_INIT_1; -- not init yet
          AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_three_mask; -- rxs_mem_last_read_out_ptr
        end if;

      when RESET_INIT_2 =>
      -- we must wait until the rx client interface has initialized the ptrs in dpmem
        if (axi_str_rxs_dpmem_rd_data_d1 = rxs_mem_full_mask) then
          rxs_axistream_next_state <= READ_RXD_MEM_NEXT_AVAILABLE4WRITE_PTR_1; -- good to go
          AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_empty_mask; -- set address up for next state; read rxd_mem_next_available4write_ptr
        else
          rxs_axistream_next_state <= RESET_INIT_1; --  write/read collision may have occurred because we didn't
                                                    --  get same value twice
          AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_three_mask; -- rxs_mem_last_read_out_ptr
        end if;

      when READ_RXD_MEM_NEXT_AVAILABLE4WRITE_PTR_1 =>
        rxd_mem_next_available4write_ptr_1_cmb <= axi_str_rxs_dpmem_rd_data_d1(C_RXD_MEM_ADDR_WIDTH downto 0);
        rxs_axistream_next_state <= READ_RXD_MEM_NEXT_AVAILABLE4WRITE_PTR_2;
        AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_empty_mask; -- set address up for next state read; rxd_mem_next_available4write_ptr

      when READ_RXD_MEM_NEXT_AVAILABLE4WRITE_PTR_2 =>
        if (axi_str_rxs_dpmem_rd_data_d1 = rxd_mem_next_available4write_ptr_1_reg) then -- good to go
          rxd_mem_next_available4write_ptr_cmb <= axi_str_rxs_dpmem_rd_data_d1(C_RXD_MEM_ADDR_WIDTH downto 0);
          rxs_axistream_next_state <= ADDR_SETUP_PAUSE_1;
          AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_two_mask; -- set address up for next state read;rxs_mem_next_available4write_ptr
        else
          AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_empty_mask; -- set address up for next state read; rxd_mem_next_available4write_ptr
          rxs_axistream_next_state <= READ_RXD_MEM_NEXT_AVAILABLE4WRITE_PTR_1; -- write/read collision may have occurred
                                                                               -- because we didn't get same value twice
        end if;

      when ADDR_SETUP_PAUSE_1 =>
        rxs_axistream_next_state <= READ_RXS_MEM_NEXT_AVAILABLE4WRITE_PTR_1;
        AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_two_mask; -- set address up for next state read;rxs_mem_next_available4write_ptr

      when READ_RXS_MEM_NEXT_AVAILABLE4WRITE_PTR_1 =>
        rxs_mem_next_available4write_ptr_1_cmb <= axi_str_rxs_dpmem_rd_data_d1(C_RXS_MEM_ADDR_WIDTH downto 0);
        rxs_axistream_next_state <= READ_RXS_MEM_NEXT_AVAILABLE4WRITE_PTR_2;
        AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_two_mask; -- set address up for next state read;rxs_mem_next_available4write_ptr

      when READ_RXS_MEM_NEXT_AVAILABLE4WRITE_PTR_2 =>
        if (axi_str_rxs_dpmem_rd_data_d1 = rxs_mem_next_available4write_ptr_1_reg) then -- good to go
          rxs_mem_next_available4write_ptr_cmb <= axi_str_rxs_dpmem_rd_data_d1(C_RXS_MEM_ADDR_WIDTH downto 0);
          rxs_axistream_next_state <= ADDR_SETUP_PAUSE_2;
          AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_three_mask; -- set address up for next state read; rxs_mem_last_read_out_ptr
        else
          AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_two_mask; -- set address up for next state read;rxs_mem_next_available4write_ptr
          rxs_axistream_next_state <= READ_RXS_MEM_NEXT_AVAILABLE4WRITE_PTR_1;  --  write/read collision may have occurred
                                                                                --  because we didn't get same value twice
        end if;

      when ADDR_SETUP_PAUSE_2 =>
        rxs_axistream_next_state <= READ_RXS_MEM_LAST_READ_OUT_PTR;
        AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_three_mask; -- set address up for next state read; rxs_mem_last_read_out_ptr

      when READ_RXS_MEM_LAST_READ_OUT_PTR =>
      -- no need to double read this ptr, the other side does not write this location in memory
        if (axi_str_rxs_dpmem_rd_data_d1(C_RXS_MEM_ADDR_WIDTH downto 0) = rxs_mem_full_mask) then
          rxs_mem_last_read_out_ptr_cmb      <= rxs_mem_four_mask;
          rxs_mem_last_read_out_ptr_true_cmb <= rxs_mem_full_mask;
        else
          rxs_mem_last_read_out_ptr_cmb      <= axi_str_rxs_dpmem_rd_data_d1(C_RXS_MEM_ADDR_WIDTH downto 0) + 1;
          rxs_mem_last_read_out_ptr_true_cmb <= axi_str_rxs_dpmem_rd_data_d1(C_RXS_MEM_ADDR_WIDTH downto 0);
        end if;
        rxs_axistream_next_state  <= ADDR_SETUP_PAUSE_3;
        AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_one_mask; -- set address up for next state read; rxd_mem_last_read_out_ptr

      when ADDR_SETUP_PAUSE_3 =>
          rxs_axistream_next_state  <= READ_RXD_MEM_LAST_READ_OUT_PTR;
          AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_one_mask; -- set address up for next state read; rxd_mem_last_read_out_ptr

      when READ_RXD_MEM_LAST_READ_OUT_PTR =>
      -- no need to double read this ptr, the other side does not write this location in memory
        rxd_mem_last_read_out_ptr_cmb <= axi_str_rxs_dpmem_rd_data_d1(C_RXD_MEM_ADDR_WIDTH downto 0);
        if (rxs_mem_last_read_out_ptr_true_reg = rxs_mem_full_mask)then -- check to see if rxs mem is empty or ready to process
          if (rxs_mem_next_available4write_ptr_reg = rxs_mem_four_mask) then -- rxs mem is empty
            rxs_axistream_next_state <= READ_RXD_MEM_NEXT_AVAILABLE4WRITE_PTR_1;
            AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_empty_mask; -- set address up for next state read; rxd_mem_next_available4write_ptr
          else -- rxs mem has a frame ready
            rxs_axistream_next_state <= PAUSE_READ_STATUS_WORD1;
            AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_last_read_out_ptr_reg; -- set address up for next state read; status word 1
          end if;
        else
          if (rxs_mem_next_available4write_ptr_reg = (rxs_mem_last_read_out_ptr_true_reg + 1)) then -- rxs mem is empty
            rxs_axistream_next_state <= READ_RXD_MEM_NEXT_AVAILABLE4WRITE_PTR_1;
            AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_empty_mask; -- set address up for next state read; rxd_mem_next_available4write_ptr
          else -- rxs mem has a frame ready
            rxs_axistream_next_state <= PAUSE_READ_STATUS_WORD1;
            AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_last_read_out_ptr_reg; -- set address up for next state read; status word 1
          end if;
        end if;

      when PAUSE_READ_STATUS_WORD1 => -- delay so we can use register output of BRAM
         rxs_axistream_next_state <= READ_STATUS_WORD1;
         AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_last_read_out_ptr_reg; -- set address up for next state read; status word 1

      when READ_STATUS_WORD1 =>
        rxs_axistream_next_state  <= READ_STATUS_WORD2;
        rxs_mem_last_read_out_ptr_cmb <= rxs_mem_last_read_out_ptr_plus_one;
        rxs_mem_last_read_out_ptr_true_cmb <= rxs_mem_last_read_out_ptr_reg;
        AXI_STR_RXS_DPMEM_ADDR    <= rxs_mem_last_read_out_ptr_plus_one; -- set address up for next state read

      when READ_STATUS_WORD2 =>
        rxs_axistream_next_state  <= READ_STATUS_WORD3;
        rxs_mem_last_read_out_ptr_cmb <= rxs_mem_last_read_out_ptr_plus_one;
        rxs_mem_last_read_out_ptr_true_cmb <= rxs_mem_last_read_out_ptr_reg;
        AXI_STR_RXS_DPMEM_ADDR    <= rxs_mem_last_read_out_ptr_plus_one; -- set address up for next state read

      when READ_STATUS_WORD3 =>
        rxs_axistream_next_state  <= READ_STATUS_WORD4;
        rxs_mem_last_read_out_ptr_cmb <= rxs_mem_last_read_out_ptr_plus_one;
        rxs_mem_last_read_out_ptr_true_cmb <= rxs_mem_last_read_out_ptr_reg;
        AXI_STR_RXS_DPMEM_ADDR    <= rxs_mem_last_read_out_ptr_plus_one; -- set address up for next state read

      when READ_STATUS_WORD4 =>
        rxs_axistream_next_state  <= READ_STATUS_WORD5;
        rxs_mem_last_read_out_ptr_cmb <= rxs_mem_last_read_out_ptr_plus_one;
        rxs_mem_last_read_out_ptr_true_cmb <= rxs_mem_last_read_out_ptr_reg;
        AXI_STR_RXS_DPMEM_ADDR    <= rxs_mem_last_read_out_ptr_plus_one; -- set address up for next state read

      when READ_STATUS_WORD5 =>
        rxs_axistream_next_state  <= READ_STATUS_WORD6;
        rxs_mem_last_read_out_ptr_cmb <= rxs_mem_last_read_out_ptr_plus_one;
        rxs_mem_last_read_out_ptr_true_cmb <= rxs_mem_last_read_out_ptr_reg;
        AXI_STR_RXS_DPMEM_ADDR    <= rxs_mem_last_read_out_ptr_plus_one; -- set address up for next state read

      when READ_STATUS_WORD6 =>
        rxs_axistream_next_state  <= UPDATE_RXS_MEM_LAST_READ_OUT_PTR;
        AXI_STR_RXS_DPMEM_ADDR    <= rxs_mem_three_mask; -- set address up for next state read

      when UPDATE_RXS_MEM_LAST_READ_OUT_PTR =>
        rxs_axistream_next_state  <= SEND_STATUS_WORD1;
        AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_three_mask;
        AXI_STR_RXS_DPMEM_WR_DATA(35 downto C_RXS_MEM_ADDR_WIDTH + 1) <= (others => '0');
        AXI_STR_RXS_DPMEM_WR_DATA(C_RXS_MEM_ADDR_WIDTH downto 0) <= rxs_mem_last_read_out_ptr_cmb;
        AXI_STR_RXS_DPMEM_WR_EN(0)<= '1';
        rxs2rxd_frame_ready <= '1';

      when SEND_STATUS_WORD1 =>
        AXI_STR_RXS_VALID <= '1';
        AXI_STR_RXS_DATA  <= X"50000000";  --Set the flag,  all other bits are reserved
        rxs2rxd_frame_ready       <= '1';
        --  adding the following lines in case they process rxd before rxs and we end up stuck here,
        --  we update the pointers and memory
        if (rxd_addr_cntr_en = '1') then  --  update the read pointer for RXD memeory to free spaces up
                                          --  and as we send them over the RXD AXIStream
          rxd_mem_last_read_out_ptr_cmb <= rxd_mem_addr_cntr;
        end if;

        if (AXI_STR_RXS_READY = '1') then
          rxs_axistream_next_state  <= SEND_STATUS_WORD2;
        else
          rxs_axistream_next_state  <= SEND_STATUS_WORD1;
        end if;

      when SEND_STATUS_WORD2 =>
        AXI_STR_RXS_VALID <= '1';
        AXI_STR_RXS_DATA  <= rxs_status_word_2(31 downto 0);
        rxs2rxd_frame_ready       <= '1';

        --  adding the following lines in case they process rxd before rxs and we end up stuck here,
        --  we update the pointers and memory
        if (rxd_addr_cntr_en = '1') then  --  update the read pointer for RXD memeory to free spaces
                                          --  up and as we send them over the RXD AXIStream
          rxd_mem_last_read_out_ptr_cmb <= rxd_mem_addr_cntr;
        end if;

        if (AXI_STR_RXS_READY = '1') then
          rxs_axistream_next_state  <= SEND_STATUS_WORD3;
        else
          rxs_axistream_next_state  <= SEND_STATUS_WORD2;
        end if;

      when SEND_STATUS_WORD3 =>
        AXI_STR_RXS_VALID <= '1';
        AXI_STR_RXS_DATA  <= rxs_status_word_3(31 downto 0);
        rxs2rxd_frame_ready       <= '1';

        --  adding the following lines in case they process rxd before rxs and we end up stuck here,
        --  we update the pointers and memory
        if (rxd_addr_cntr_en = '1') then  --  update the read pointer for RXD memeory to free spaces
                                          --  up and as we send them over the RXD AXIStream
          rxd_mem_last_read_out_ptr_cmb <= rxd_mem_addr_cntr;
        end if;

        if (AXI_STR_RXS_READY = '1') then
          rxs_axistream_next_state  <= SEND_STATUS_WORD4;
        else
          rxs_axistream_next_state  <= SEND_STATUS_WORD3;
        end if;

      when SEND_STATUS_WORD4 =>
        AXI_STR_RXS_VALID <= '1';
        AXI_STR_RXS_DATA  <= rxs_status_word_4(31 downto 0);
        rxs2rxd_frame_ready       <= '1';

        --  adding the following  lines in case they process rxd before rxs and we end up stuck here,
        --  we update the pointers and memory
        if (rxd_addr_cntr_en = '1') then  --  update the read pointer for RXD memeory to free spaces up and
                                          --  as we send them over the RXD AXIStream
          rxd_mem_last_read_out_ptr_cmb <= rxd_mem_addr_cntr;
        end if;

        if (AXI_STR_RXS_READY = '1') then
          rxs_axistream_next_state  <= SEND_STATUS_WORD5;
        else
          rxs_axistream_next_state  <= SEND_STATUS_WORD4;
        end if;

      when SEND_STATUS_WORD5 =>
        AXI_STR_RXS_VALID <= '1';
        AXI_STR_RXS_DATA  <= rxs_status_word_5(31 downto 0);
        rxs2rxd_frame_ready       <= '1';

        --  adding the following lines in case they process rxd before rxs and we end up stuck here,
        --  we update the pointers and memory
        if (rxd_addr_cntr_en = '1') then  --  update the read pointer for RXD memeory to free spaces up and
                                          --  as we send them over the RXD AXIStream
          rxd_mem_last_read_out_ptr_cmb <= rxd_mem_addr_cntr;
        end if;

        if (AXI_STR_RXS_READY = '1') then
          rxs_axistream_next_state  <= SEND_STATUS_WORD6;
        else
          rxs_axistream_next_state  <= SEND_STATUS_WORD5;
        end if;

      when SEND_STATUS_WORD6 =>
        AXI_STR_RXS_VALID <= '1';
        AXI_STR_RXS_DATA  <= rxs_status_word_6(31 downto 0);
        AXI_STR_RXS_LAST  <= '1';
        rxs2rxd_frame_ready       <= '1';

        --  adding the following lines in case they process rxd before rxs and we end up stuck here,
        --  we update the pointers and memory
        if (rxd_addr_cntr_en = '1') then  --  update the read pointer for RXD memeory to free spaces up and
                                          --  as we send them over the RXD AXIStream
          rxd_mem_last_read_out_ptr_cmb <= rxd_mem_addr_cntr;
        end if;

        if (AXI_STR_RXS_READY = '1') then
          rxs_axistream_next_state  <= WAIT_FRAME_DONE;
        else
          rxs_axistream_next_state  <= SEND_STATUS_WORD6;
        end if;

      when WAIT_FRAME_DONE =>
        rxs2rxd_frame_ready <= '1';
        if (rxd_addr_cntr_en = '1') then  --  update the read pointer for RXD memeory to free spaces up and
                                          --  as we send them over the RXD AXIStream
          rxd_mem_last_read_out_ptr_cmb <= rxd_mem_addr_cntr;
        end if;
        if (rxd2rxs_frame_done = '0') then
          rxs_axistream_next_state  <= WAIT_FRAME_DONE;
        else
          rxs_axistream_next_state  <= UPDATE_RXD_MEM_LAST_READ_OUT_PTR;
        end if;

      when UPDATE_RXD_MEM_LAST_READ_OUT_PTR =>
        rxs_axistream_next_state <= REPEAT_AGAIN;

      when REPEAT_AGAIN =>
        rxs_axistream_next_state <= READ_RXD_MEM_NEXT_AVAILABLE4WRITE_PTR_1;
        AXI_STR_RXS_DPMEM_ADDR   <= rxs_mem_empty_mask; -- set address up for next state read

      when others   =>
        rxs_axistream_next_state         <= RESET_INIT_1;
    end case;
  end process;


    --------------------------------------------------------------------------
    -- receive data AXIStream State Machine
    -- RXDTSSM_REGS_PROCESS: registered process of the state machine
    -- RXDTSSM_CMB_PROCESS:  combinatorial next-state logic
    --------------------------------------------------------------------------

    RXDTSSM_REGS_PROCESS: process (AXI_STR_RXD_ACLK)
    begin
      if rising_edge(AXI_STR_RXD_ACLK) then
        if(RESET2AXI_STR_RXD='1' or RESET2AXI_STR_RXS='1') then
          rxd_axistream_current_state <= IDLE;
        else
          rxd_axistream_current_state <= rxd_axistream_next_state;
        end if;
      end if;
    end process;

    RXDTSSM_CMB_PROCESS: process (
      rxd_axistream_current_state,
      rxs2rxd_frame_ready,
      AXI_STR_RXD_READY,
      frame_length_words,
      rxd_word_cnt,
      rxd_addr_cntr_load,
      fifoEmpty,
      fifoAlmostFull,
      rxd2rxs_frame_done,
      rxs2rxd_frame_done
      )
    begin

    case rxd_axistream_current_state is

      when IDLE =>
        if(rxs2rxd_frame_ready = '1'and rxd2rxs_frame_done = '0') then
          rxd_axistream_next_state <= PRIME;
        else
          rxd_axistream_next_state <= IDLE;
        end if;

      when PRIME =>
        rxd_axistream_next_state <= RD_FRAME_FROM_MEM;

      when RD_FRAME_FROM_MEM =>
        if ((rxd_word_cnt = frame_length_words - 1)  and fifoEmpty = '0') then
          rxd_axistream_next_state <= WAIT_END_FRAME;
        elsif (fifoAlmostFull = '1') then
          rxd_axistream_next_state <= ALMOST_FULL_WAIT1;
        else
          rxd_axistream_next_state <= RD_FRAME_FROM_MEM;
        end if;

      when ALMOST_FULL_WAIT1 =>
        rxd_axistream_next_state <= ALMOST_FULL_WAIT2;

      when ALMOST_FULL_WAIT2 =>
        if (fifoAlmostFull = '0') then
          rxd_axistream_next_state <= ALMOST_FULL_WAIT3;
        else
          rxd_axistream_next_state <= ALMOST_FULL_WAIT2;
        end if;

      when ALMOST_FULL_WAIT3 =>
        rxd_axistream_next_state <= ALMOST_FULL_WAIT4;

      when ALMOST_FULL_WAIT4 =>
        rxd_axistream_next_state <= RD_FRAME_FROM_MEM;

      when WAIT_END_FRAME =>
        if (fifoEmpty = '1') then --  remove ready as a term because it is not needed and
                                  --  causes lock up if ready goes away right after TLAST
--        if (AXI_STR_RXD_READY = '1' and fifoEmpty = '1') then
          rxd_axistream_next_state <= PRE_IDLE;
        else
          rxd_axistream_next_state <= WAIT_END_FRAME;
        end if;

      when PRE_IDLE =>
        if (rxs2rxd_frame_done = '0') then
          rxd_axistream_next_state  <= PRE_IDLE;
        else
          rxd_axistream_next_state  <= IDLE;
        end if;

      when others   =>
        rxd_axistream_next_state <= IDLE;

    end case;
  end process;

  rxd_addr_cntr_en    <= '1' when ((rxd_axistream_current_state = RD_FRAME_FROM_MEM) and (fifoAlmostFull = '0') and
                                   (rxd_word_cnt < frame_length_words - 1)) else
                         '1' when ((rxd_axistream_current_state = ALMOST_FULL_WAIT4) and (fifoAlmostFull = '0') and
                                   (rxd_word_cnt < frame_length_words - 1)) else
                         '1' when ((rxd_axistream_current_state = PRIME)) else
                         '0';

  AXI_STR_RXD_DPMEM_ADDR <= rxd_mem_addr_cntr;

  fifoWrEn            <= '1' when (rxd_axistream_current_state = RD_FRAME_FROM_MEM) else
                         '0';

  fifoDataIn          <= AXI_STR_RXD_DPMEM_RD_DATA(35 downto 0);

  rxd2rxs_frame_done  <= '1' when (rxd_axistream_current_state = PRE_IDLE) else
                         '0';

  rxs2rxd_frame_done  <= '1' when (rxs_axistream_current_state = WAIT_FRAME_DONE) else
                         '0';

  rxd_addr_cntr_load  <= '1' when (rxd_axistream_current_state = IDLE) else
                         '0';

  fifoRdEn            <= AXI_STR_RXD_READY or RESET2AXI_STR_RXD;
  AXI_STR_RXD_DATA    <= fifoDataOut(4 to 35);
  AXI_STR_RXD_VALID   <= not(fifoEmpty);
  AXI_STR_RXD_STRB    <= fifoDataOut(0 to 3);
  AXI_STR_RXD_LAST    <= '1' when (rxd_axistream_current_state = WAIT_END_FRAME and fifoDataCount = 1) else
                         '0';
  COUNT_RXD_WORDS_READ : process (AXI_STR_RXD_ACLK)
  begin
    if rising_edge(AXI_STR_RXD_ACLK) then
      if RESET2AXI_STR_RXD = '1' then
        rxd_word_cnt   <= 0;
      else
        if (rxd_axistream_current_state = IDLE) then
          rxd_word_cnt   <= 0;
        elsif (fifoWrEn = '1') then
          rxd_word_cnt <= rxd_word_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  DETECT_FIFO_ALMOST_FULL : process(fifoDataCount, fifoEmpty)
  begin
    fifoAlmostFull  <= '0';
    if(conv_integer(fifoDataCount)>28 and fifoEmpty='0') then
      fifoAlmostFull <= '1';
    end if;
  end process;

  ELASTIC_FIFO : entity proc_common_v3_00_a.basic_sfifo_fg
  generic map(
    C_DWIDTH                      => 36,
      -- FIFO data Width (Read and write data ports are symetric)
    C_DEPTH                       => 32,
      -- FIFO Depth (set to power of 2)
    C_HAS_DATA_COUNT              => 1,
      -- 0 = DataCount not used
      -- 1 = Data Count used 
    C_DATA_COUNT_WIDTH            => 6,
    -- Data Count bit width (Max value is log2(C_DEPTH))
    C_IMPLEMENTATION_TYPE         => 0, 
      --  0 = Common Clock BRAM / Distributed RAM (Synchronous FIFO)
      --  1 = Common Clock Shift Register (Synchronous FIFO)
    C_MEMORY_TYPE                 => 2,
      --   0 = Any
      --   1 = BRAM
      --   2 = Distributed Memory  
      --   3 = Shift Registers
    C_PRELOAD_REGS                => 1, 
      -- 0 = normal            
      -- 1 for FWFT
    C_PRELOAD_LATENCY             => 0,              
      -- 0 for FWFT
      -- 1 = normal            
    C_USE_FWFT_DATA_COUNT         => 1, 
      -- 0 = normal            
      -- 1 for FWFT
    C_FAMILY                      =>  C_FAMILY
  
    )
  port map(
    CLK                           =>  AXI_STR_RXD_ACLK,
    DIN                           =>  fifoDataIn,
    RD_EN                         =>  fifoRdEn,
    SRST                          =>  RESET2AXI_STR_RXD,
    WR_EN                         =>  fifoWrEn,
    DATA_COUNT                    =>  fifoDataCount,
    DOUT                          =>  fifoDataOut,
    EMPTY                         =>  fifoEmpty,
    FULL                          =>  fifoFull
    );

end rtl;
