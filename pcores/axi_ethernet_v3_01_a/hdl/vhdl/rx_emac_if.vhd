------------------------------------------------------------------------------
-- rx_emac_if.vhd
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
-- Filename:        rx_emac_if.vhd
-- Version:         v1.00a
-- Description:     Receive interface between AXIStream and 10GE MAC
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
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.coregen_comp_defs.all;
use proc_common_v3_00_a.proc_common_pkg.log2;
use proc_common_v3_00_a.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

-------------------------------------------------------------------------------
-- Definition of Generics :
-------------------------------------------------------------------------------
-- System generics
--  C_FAMILY              -- Xilinx FPGA Family
--
-- Ethernet generics
--  C_RXD_MEM_BYTES               -- Depth of RX memory in Bytes
--  C_RXCSUM
--     0  No checksum offloading
--     1  Partial (legacy) checksum offloading
--     2  Full checksum offloading
--  C_RXVLAN_TRAN         -- Enable RX enhanced VLAN translation
--  C_RXVLAN_TAG          -- Enable RX enhanced VLAN taging
--  C_RXVLAN_STRP         -- Enable RX enhanced VLAN striping

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Definition of Ports :
-------------------------------------------------------------------------------
--    BUS2IP_CLK
--    BUS2IP_RESET
--
--    AXI_STR_RXD_ACLK
--    AXI_STR_RXD_ARESET
--    AXI_STR_RXD_VALID
--    AXI_STR_RXD_READY
--    AXI_STR_RXD_LAST
--    AXI_STR_RXD_STRB
--    AXI_STR_RXD_DATA
--
--    AXI_STR_RXS_ACLK
--    AXI_STR_RXS_ARESET
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
--
--    RX_CLIENT_CLK
--
--    RTAGREGDATA
--    TPID0REGDATA
--    TPID1REGDATA
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

entity rx_emac_if is
  generic (
    C_RXVLAN_WIDTH        : integer                       := 12;
    C_RXD_MEM_BYTES       : integer                       := 4096;
    C_RXD_MEM_ADDR_WIDTH  : integer                       := 9;
    C_RXS_MEM_BYTES       : integer                       := 2048;
    C_RXS_MEM_ADDR_WIDTH  : integer                       := 9;
    C_FAMILY              : string                        := "virtex6";
    C_RXCSUM              : integer range 0 to 2          := 0;
      -- 0 - No checksum offloading
      -- 1 - Partial (legacy) checksum offloading
      -- 2 - Full checksum offloading
    C_RXVLAN_TRAN         : integer range 0 to 1          := 0;
    C_RXVLAN_TAG          : integer range 0 to 1          := 0;
    C_RXVLAN_STRP         : integer range 0 to 1          := 0
    );

  port    (
    end_of_frame_reset_in           : in  std_logic;                        -- end of frame reset base on last from rx axistream
                                                                        
    rx_mac_aclk                     : in  std_logic;                        -- Rx axistream clock from 10GE MAC
    rx_reset                        : in  std_logic;                        -- Rx axistream reset from 10GE MAC
    derived_rxd                     : in  std_logic_vector(63 downto 0);    -- Rx axistream data from 10GE MAC
    derived_sof			    : in  std_logic;
    derived_eof          	    : in  std_logic;                                                              
    derived_rx_good_frame           : in  std_logic;                        -- derived good indicator
    derived_rx_bad_frame            : in  std_logic;                        -- derived bad indicator
    derived_rxd_vld                 : in  std_logic_vector(7 downto 0);     -- derived data valid indicator
    rx_empty			    : in  std_logic_vector(2 downto 0);     -- Avalon ST Emtpy
    derived_rx_clk_enbl             : in  std_logic;			    -- derived RX Clock Enable

    RX_CL_CLK_RX_TAG_REG_DATA       : in  std_logic_vector(0 to 31);        --  Receive VLAN TAG
    RX_CL_CLK_TPID0_REG_DATA        : in  std_logic_vector(0 to 31);        --  Receive VLAN TPID 0
    RX_CL_CLK_TPID1_REG_DATA        : in  std_logic_vector(0 to 31);        --  Receive VLAN TPID 1

    RX_CL_CLK_VLAN_ADDR             : out std_logic_vector(0 to 11);        --  Receive VLAN Memory Address
    RX_CL_CLK_VLAN_RD_DATA          : in  std_logic_vector(18 to 31);       --  Receive VLAN Memory Read Data
    RX_CL_CLK_VLAN_BRAM_EN_A        : out std_logic;                        --  Receive VLAN Memory Enable

    RX_CL_CLK_NEW_FNC_ENBL          : in  std_logic;                        --  Receive New Function Enable
    RX_CL_CLK_VSTRP_MODE            : in  std_logic_vector(0 to 1);         --  Receive VLAN Strip Mode
    RX_CL_CLK_VTAG_MODE             : in  std_logic_vector(0 to 1);         --  Receive VLAN TAG Mode

    RX_CLIENT_RXD_DPMEM_WR_DATA     : out std_logic_vector(71 downto 0);                    --  Receive Data Memory Write Data
    RX_CLIENT_RXD_DPMEM_RD_DATA     : in  std_logic_vector(71 downto 0);                    --  Receive Data Memory Read Data
    RX_CLIENT_RXD_DPMEM_WR_EN       : out std_logic_vector(0 downto 0);                     --  Receive Data Memory Write Enable
    RX_CLIENT_RXD_DPMEM_ADDR        : out std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);  --  Receive Data Memory Address
    RX_CLIENT_RXS_DPMEM_WR_DATA     : out std_logic_vector(35 downto 0);                    --  Receive Status Memory Write Data
    RX_CLIENT_RXS_DPMEM_RD_DATA     : in  std_logic_vector(35 downto 0);                    --  Receive Status Memory Read Data
    RX_CLIENT_RXS_DPMEM_WR_EN       : out std_logic_vector(0 downto 0);                     --  Receive Status Memory Write Enable
    RX_CLIENT_RXS_DPMEM_ADDR        : out std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);  --  Receive Status Memory Address

    AXI_STR_RXS_MEM_LAST_READ_OUT_PTR_GRAY : in std_logic_vector(35 downto 0);    --  Receive Status Gray code pointer
    AXI_STR_RXD_MEM_LAST_READ_OUT_PTR_GRAY : in std_logic_vector(71 downto 0)     --  Receive Data Gray code pointer
  );
end rx_emac_if;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of rx_emac_if is

signal EMAC_CLIENT_RXD_LEGACY          : std_logic_vector(63 downto  0);
signal EMAC_CLIENT_RXD_VLD_LEGACY      : std_logic_vector(7 downto 0);
signal EMAC_CLIENT_RX_GOODFRAME_LEGACY : std_logic;
signal EMAC_CLIENT_RX_BADFRAME_LEGACY  : std_logic;

signal RX_CLIENT_CLK                   : std_logic;
signal RX_CLIENT_CLK_ENBL              : std_logic;
signal RESET2RX_CLIENT                 : std_logic;

---------------------------------------------------------------------
-- Functions
---------------------------------------------------------------------

-- Convert a gray code value into binary
function gray_to_bin (
   gray : std_logic_vector)
   return std_logic_vector is

   variable binary : std_logic_vector(gray'range);

begin

   for i in gray'high downto gray'low loop
      if i = gray'high then
         binary(i) := gray(i);
      else
         binary(i) := binary(i+1) xor gray(i);
      end if;
   end loop;  -- i

   return binary;

end gray_to_bin;

------------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------------


------------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------------

type type_rx_data_words_array    is array (1 to 4) of std_logic_vector(63 downto 0);
type type_rx_data_valid_array    is array (1 to 4) of std_logic_vector(7 downto 0);
type type_start_of_frame_array   is array (1 to 14) of std_logic;
type type_end_of_frame_array     is array (1 to 4) of std_logic;

type RECEIVE_FRAME_TYPE is (
       RESET_INIT_MEM_PTR_1,
       RESET_INIT_MEM_PTR_2,
       RESET_INIT_MEM_PTR_3,
       RESET_INIT_MEM_PTR_4,
       WAIT_FOR_START_OF_FRAME,
       RECEIVING_FRAME,
       CHECK_RXS_MEM_AVAIL1,
       CHECK_RXS_MEM_AVAIL2,
       END_OF_FRAME_CHECK_GOOD_BAD,
       UPDATE_MEM_PTR_1,
       UPDATE_STATUS_FIFO_WORD_1,
       UPDATE_STATUS_FIFO_WORD_2,
       UPDATE_STATUS_FIFO_WORD_3,
       UPDATE_STATUS_FIFO_WORD_4,
       UPDATE_STATUS_FIFO_WORD_5,
       UPDATE_STATUS_FIFO_WORD_6,
       UPDATE_MEM_PTR_2
     );

signal receive_frame_current_state : RECEIVE_FRAME_TYPE;
signal receive_frame_next_state    : RECEIVE_FRAME_TYPE;

signal rx_data_words_array    : type_rx_data_words_array;
signal rx_data_valid_array    : type_rx_data_valid_array;
signal start_of_frame_array   : type_start_of_frame_array;
signal end_of_frame_array     : type_end_of_frame_array;

signal start_of_frame_d1    : std_logic;
signal save_rx_goodframe    : std_logic;
signal save_rx_badframe     : std_logic;

signal frame_is_multicast_d10           : std_logic;
signal frame_is_ip_multicast_d4         : std_logic;
signal frame_is_broadcast_d10           : std_logic;
signal receive_checksum_status          : std_logic_vector(2 downto 0);

signal rx_data_packed_word              : std_logic_vector(63 downto 0);
signal rx_data_vld_packed_word          : std_logic_vector(7 downto 0);
signal rx_data_packed_ready             : std_logic;

signal frame_length_bytes               : std_logic_vector(15 downto 0);

signal rxd_mem_next_available4write_ptr_cmb : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);
signal rxd_mem_next_available4write_ptr_reg : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);
signal rxd_mem_last_read_out_ptr_cmb        : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);
signal rxd_mem_last_read_out_ptr_reg        : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_next_available4write_ptr_cmb : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_next_available4write_ptr_reg : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);

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

signal rxs_status_word_1_cmb            : std_logic_vector(35 downto 0);
signal rxs_status_word_1_reg            : std_logic_vector(35 downto 0);
signal rxs_status_word_2                : std_logic_vector(35 downto 0);
signal rxs_status_word_3                : std_logic_vector(35 downto 0);
signal rxs_status_word_4                : std_logic_vector(35 downto 0);
signal rxs_status_word_5                : std_logic_vector(35 downto 0);
signal rxs_status_word_6_cmb            : std_logic_vector(35 downto 0);
signal rxs_status_word_6_reg            : std_logic_vector(35 downto 0);

signal rxd_addr_cntr_en                 : std_logic;
signal rxs_addr_cntr_en                 : std_logic;
signal rxd_mem_addr_cntr                : std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);
signal rxs_mem_addr_cntr                : std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);
signal rxd_addr_cntr_load               : std_logic;
signal rxs_addr_cntr_load               : std_logic;

signal multicast_addr_upper_d10         : std_logic_vector(15 downto 0);
signal multicast_addr_lower_d10         : std_logic_vector(31 downto 0);
signal bytes_12_and_13_d19              : std_logic_vector(15 downto 0);
signal bytes_14_and_15_d19              : std_logic_vector(15 downto 0);

signal raw_checksum                     : std_logic_vector(15 downto 0);

signal statistics_vector                : std_logic_vector(25 downto 0);
signal not_enough_rxs_memory            : std_logic;

signal rxCsum                           : std_logic_vector(15 downto 0);
signal rxCsumVld                        : std_logic;

signal rxclclk_rxd_mem_last_read_out_ptr           : std_logic_vector(71 downto 0);
signal rxclclk_rxd_mem_last_read_out_ptr_d1        : std_logic_vector(71 downto 0);
signal sync_rxd_mem_last_read_out_ptr_gray_d2      : std_logic_vector(71 downto 0);
signal sync_rxd_mem_last_read_out_ptr_gray_d1      : std_logic_vector(71 downto 0);

signal rxclclk_rxs_mem_last_read_out_ptr           : std_logic_vector(35 downto 0);
signal rxclclk_rxs_mem_last_read_out_ptr_d1        : std_logic_vector(35 downto 0);
signal sync_rxs_mem_last_read_out_ptr_gray_d2      : std_logic_vector(35 downto 0);
signal sync_rxs_mem_last_read_out_ptr_gray_d1      : std_logic_vector(35 downto 0);

signal eof_reset : std_logic;
signal rx_cnt	 : std_logic_vector(15 downto 0);
signal rx_data   : std_logic_vector(63 downto 0);

begin

  EMAC_CLIENT_RXD_VLD_LEGACY      <= derived_rxd_vld;
  RX_CLIENT_CLK_ENBL              <= derived_rx_clk_enbl;

  EMAC_CLIENT_RX_GOODFRAME_LEGACY <= derived_rx_good_frame;
  EMAC_CLIENT_RX_BADFRAME_LEGACY  <= derived_rx_bad_frame;
  RX_CLIENT_CLK                   <= rx_mac_aclk;
  RESET2RX_CLIENT                 <= rx_reset;
  EMAC_CLIENT_RXD_LEGACY          <= derived_rxd;

  eof_reset <= end_of_frame_reset_in;

  receive_checksum_status  <= "000";

  -------------------------------------------------------------------------
  -- Synchronize gray encoded last processed pointer from AXIStream clock
  -- domain to the receive client clock domain.
  -------------------------------------------------------------------------
  SYNC_RXS_LAST_READ_GRAY_PROCESS: process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        sync_rxs_mem_last_read_out_ptr_gray_d1  <= (others => '0');
        sync_rxs_mem_last_read_out_ptr_gray_d2  <= (others => '0');
      else
        sync_rxs_mem_last_read_out_ptr_gray_d1  <= AXI_STR_RXS_MEM_LAST_READ_OUT_PTR_GRAY;
        sync_rxs_mem_last_read_out_ptr_gray_d2  <= sync_rxs_mem_last_read_out_ptr_gray_d1;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- Convert gray encoded last processed pointer back to binary encoded
  -------------------------------------------------------------------------
  rxclclk_rxs_mem_last_read_out_ptr <= gray_to_bin(sync_rxs_mem_last_read_out_ptr_gray_d2);

  -------------------------------------------------------------------------
  -- Register binary encoded last processed pointer from local link
  -- interface
  -------------------------------------------------------------------------
  RX_CL_CLK_REG_RXS_LAST_READ_PROCESS: process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        rxclclk_rxs_mem_last_read_out_ptr_d1  <= (others => '0');
      else
        rxclclk_rxs_mem_last_read_out_ptr_d1  <= rxclclk_rxs_mem_last_read_out_ptr;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- Synchronize gray encoded last processed pointer from AXIStream clock
  -- domain to the receive client clock domain.
  -------------------------------------------------------------------------
  SYNC_RXD_LAST_READ_GRAY_PROCESS: process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        sync_rxd_mem_last_read_out_ptr_gray_d1  <= (others => '0');
        sync_rxd_mem_last_read_out_ptr_gray_d2  <= (others => '0');
      else
        sync_rxd_mem_last_read_out_ptr_gray_d1  <= AXI_STR_RXD_MEM_LAST_READ_OUT_PTR_GRAY;
        sync_rxd_mem_last_read_out_ptr_gray_d2  <= sync_rxd_mem_last_read_out_ptr_gray_d1;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- Convert gray encoded last processed pointer back to binary encoded
  -------------------------------------------------------------------------
  rxclclk_rxd_mem_last_read_out_ptr <= gray_to_bin(sync_rxd_mem_last_read_out_ptr_gray_d2);

  -------------------------------------------------------------------------
  -- Register binary encoded last processed pointer from local link
  -- interface
  -------------------------------------------------------------------------
  RX_CL_CLK_REG_RXD_LAST_READ_PROCESS: process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        rxclclk_rxd_mem_last_read_out_ptr_d1  <= (others => '0');
      else
        rxclclk_rxd_mem_last_read_out_ptr_d1  <= rxclclk_rxd_mem_last_read_out_ptr;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  statistics_vector   <= (others => '0');

  rxs_status_word_2               <= X"00000" & multicast_addr_upper_d10;
  rxs_status_word_3               <= X"0" & multicast_addr_lower_d10;
  rxs_status_word_4               <= X"0" & statistics_vector & receive_checksum_status & frame_is_broadcast_d10 &
                                          frame_is_ip_multicast_d4 & frame_is_multicast_d10;
  rxs_status_word_5               <= X"0" & bytes_12_and_13_d19 & raw_checksum;
  rxs_status_word_6_cmb(35 downto 16) <= X"0" & bytes_14_and_15_d19;

  RX_CL_CLK_VLAN_ADDR         <= (others => '0');
  RX_CL_CLK_VLAN_BRAM_EN_A    <= '0';

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

  process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        rx_data_packed_word      <= (others => '0');
        rx_data_vld_packed_word  <= (others => '0');
        rx_data_packed_ready     <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          rx_data_packed_word 	    <= EMAC_CLIENT_RXD_LEGACY;
          rx_data_vld_packed_word   <= EMAC_CLIENT_RXD_VLD_LEGACY;
          if (derived_sof = '1') then
              rx_data_packed_ready 	<= '1';
          elsif (end_of_frame_array(3) = '1') then
              rx_data_packed_ready 	<= '0';	
	  end if;
	end if;
      end if;
    end if;
  end process;

  EXCLUDE_RX_CSUM: if (not (C_RXCSUM = 2)) generate
  begin
    rxCsum <= (others => '0');
  end generate EXCLUDE_RX_CSUM;

  -- Ethernet Packet Counter
  process (RESET2RX_CLIENT, RX_CLIENT_CLK)
  begin
	if (RESET2RX_CLIENT = '1') then
		rx_cnt <= (others => '0');
	elsif (RX_CLIENT_CLK'event and RX_CLIENT_CLK='1') then
		if (end_of_frame_array(3) = '1') then
			rx_cnt <= x"0000";
		elsif (EMAC_CLIENT_RXD_VLD_LEGACY(0) = '1') then
			if (derived_sof = '1') then
				rx_cnt <= x"0008";
			elsif (derived_eof = '1') then
				rx_cnt <= rx_cnt + x"0008" - (x"000"&'0'&rx_empty);
			else
				rx_cnt <= rx_cnt + x"0008"; 
			end if;
		end if;
	end if;
  end process;

  rx_data( 7 downto  0) <= EMAC_CLIENT_RXD_LEGACY(63 downto 56);
  rx_data(15 downto  8) <= EMAC_CLIENT_RXD_LEGACY(55 downto 48);
  rx_data(23 downto 16) <= EMAC_CLIENT_RXD_LEGACY(47 downto 40);
  rx_data(31 downto 24) <= EMAC_CLIENT_RXD_LEGACY(39 downto 32);
  rx_data(39 downto 32) <= EMAC_CLIENT_RXD_LEGACY(31 downto 24);
  rx_data(47 downto 40) <= EMAC_CLIENT_RXD_LEGACY(23 downto 16);
  rx_data(55 downto 48) <= EMAC_CLIENT_RXD_LEGACY(15 downto  8);
  rx_data(63 downto 56) <= EMAC_CLIENT_RXD_LEGACY( 7 downto  0);

  INCLUDE_RX_CSUM: if (C_RXCSUM = 2) generate
  begin

--	Inst_rx_csum_top: entity axi_ethernet_v3_01_a.rx_csum_top(rtl)
--		port map (
--			reset		=>	RESET2RX_CLIENT,
--			clk		=>	RX_CLIENT_CLK,
--			enable		=>	'1',
--			rx_data		=>	rx_data,
--	       		rx_valid	=>	EMAC_CLIENT_RXD_VLD_LEGACY(0),
--			rx_sop		=>	derived_sof,
--			rx_eop		=>	derived_eof,
--			rx_empty	=>	rx_empty,
--			rx_cnt		=>	rx_cnt(10 downto 0),
--			cs_raw		=>	rxCsum,
--			cs_valid	=>	rxCsumVld
--		);
--
  end generate INCLUDE_RX_CSUM;

  -------------------------------------------------------------------------
  -- save partial csum value once calculated
  -------------------------------------------------------------------------

  SAVE_PARTIAL_CSUM_VAL : process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        raw_checksum <= (others => '0');
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (derived_sof = '1') then
            raw_checksum <= (others => '0');
          elsif (rxCsumVld = '1') then
            raw_checksum <= rxCsum;
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- count the number of bytes in the frame being received
  -------------------------------------------------------------------------

  COUNT_FRAME_RX_BYTES : process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        frame_length_bytes <= (others => '0');
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (eof_reset = '1') then -- clear at end of frame
            frame_length_bytes <= (others => '0');
          else
	    case  EMAC_CLIENT_RXD_VLD_LEGACY  is
	      when  "11111111"  =>
                frame_length_bytes <= frame_length_bytes + 8;
              when  "01111111"  =>
                frame_length_bytes <= frame_length_bytes + 7;
	      when  "00111111"  =>
                frame_length_bytes <= frame_length_bytes + 6;
              when  "00011111"  =>
                frame_length_bytes <= frame_length_bytes + 5;
	      when  "00001111"  =>
                frame_length_bytes <= frame_length_bytes + 4;
              when  "00000111"  =>
                frame_length_bytes <= frame_length_bytes + 3;
	      when  "00000011"  =>
                frame_length_bytes <= frame_length_bytes + 2;
              when  "00000001"  =>
                frame_length_bytes <= frame_length_bytes + 1;
              when  others  =>
                frame_length_bytes <= frame_length_bytes;
            end case;
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- save the good frame pulse so we can check it later
  -------------------------------------------------------------------------

  SAVE_GOOD_FRAME : process(RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        save_rx_goodframe   <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (EMAC_CLIENT_RX_GOODFRAME_LEGACY = '1') then
                save_rx_goodframe <= '1';
          elsif (eof_reset = '1') then
            save_rx_goodframe <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- save the bad frame pulse so we can check it later
  -------------------------------------------------------------------------

  SAVE_BAD_FRAME : process(RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        save_rx_badframe   <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (EMAC_CLIENT_RX_BADFRAME_LEGACY = '1') then
                save_rx_badframe <= '1';
          elsif (eof_reset = '1') then
            save_rx_badframe <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- check for not enough rxs memory
  -------------------------------------------------------------------------

  CHECK_RXS_MEM_AVAIL : process(RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        not_enough_rxs_memory   <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          -- rxs_mem_last_read_out_ptr_cmb being read out of rxs memory during state END_OF_FRAME_CHECK_GOOD_BAD
          if (rxs_mem_addr_cntr   = rxclclk_rxs_mem_last_read_out_ptr_d1(C_RXS_MEM_ADDR_WIDTH downto 0) or
              rxs_mem_addr_cntr+1 = rxclclk_rxs_mem_last_read_out_ptr_d1(C_RXS_MEM_ADDR_WIDTH downto 0) or
              rxs_mem_addr_cntr+2 = rxclclk_rxs_mem_last_read_out_ptr_d1(C_RXS_MEM_ADDR_WIDTH downto 0) or
              rxs_mem_addr_cntr+3 = rxclclk_rxs_mem_last_read_out_ptr_d1(C_RXS_MEM_ADDR_WIDTH downto 0) or
              rxs_mem_addr_cntr+4 = rxclclk_rxs_mem_last_read_out_ptr_d1(C_RXS_MEM_ADDR_WIDTH downto 0) or
              rxs_mem_addr_cntr+5 = rxclclk_rxs_mem_last_read_out_ptr_d1(C_RXS_MEM_ADDR_WIDTH downto 0)) then
                not_enough_rxs_memory <= '1';
          else
            not_enough_rxs_memory <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- create a pipeline of receive data, receive data valid, start of frame
  -- end of frame
  -------------------------------------------------------------------------

  PIPE_RX_INPUTS_4 : process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        rx_data_words_array   <= (others => (others => '0'));
        rx_data_valid_array   <= (others => (others => '0'));
        end_of_frame_array    <= (others => '0');
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          end_of_frame_array (1)      <= derived_eof;
          if (rx_data_packed_ready = '1') then
            rx_data_words_array (1)     <= rx_data_packed_word;
            rx_data_valid_array (1)     <= rx_data_vld_packed_word;
          end if;
          for i in 1 to 3 loop
            end_of_frame_array (i+1)     <= end_of_frame_array (i);
            if (rx_data_packed_ready = '1') then
              rx_data_words_array (i+1)  <= rx_data_words_array (i);
              rx_data_valid_array (i+1)  <= rx_data_valid_array (i);
            end if;
          end loop;
        end if;
      end if;
    end if;
  end process;

  start_of_frame_d1   <=   rx_data_packed_ready;
  PIPE_RX_INPUTS_100_12 : process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        start_of_frame_array  <= (others => '0');
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          start_of_frame_array (1)    <= derived_sof;
          if (EMAC_CLIENT_RXD_VLD_LEGACY(0) = '1') then
            for i in 1 to 13 loop
              start_of_frame_array (i+1)   <= start_of_frame_array (i);
            end loop;
	  end if;
        end if;
      end if;
    end if;
  end process;

  frame_is_broadcast_d10     <= '0';
  frame_is_ip_multicast_d4   <= '0';
  frame_is_multicast_d10     <= '0';

  -------------------------------------------------------------------------
  -- save the destination (multicast) address for AXIStream status words
  -------------------------------------------------------------------------

  SAVE_DEST_ADDR : process(RX_CLIENT_CLK) -- valid by byte 10
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        multicast_addr_upper_d10   <= (others => '0');
        multicast_addr_lower_d10   <= (others => '0');
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (EMAC_CLIENT_RXD_VLD_LEGACY(0) = '1' and rx_cnt = x"0000") then
            multicast_addr_upper_d10 <= EMAC_CLIENT_RXD_LEGACY(47 downto 32);
            multicast_addr_lower_d10 <= EMAC_CLIENT_RXD_LEGACY(31 downto 0);
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- save the bytes 12 thru 15 for AXIStream status words
  -------------------------------------------------------------------------

  SAVE_BYTES_12_TO_14 : process(RX_CLIENT_CLK) -- valid by byte 19
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        bytes_12_and_13_d19   <= (others => '0');
        bytes_14_and_15_d19   <= (others => '0');
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (EMAC_CLIENT_RXD_VLD_LEGACY(0) = '1' and rx_cnt = x"0008") then
            bytes_12_and_13_d19 <= EMAC_CLIENT_RXD_LEGACY(47 downto 32);
            bytes_14_and_15_d19 <= EMAC_CLIENT_RXD_LEGACY(63 downto 48);
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- Initialize the dual port address for the RXD memory
  -------------------------------------------------------------------------
  RXD_ADDR_CNTR: process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        rxd_mem_addr_cntr  <= rxd_mem_empty_mask;
      elsif (rxd_addr_cntr_load = '1') then
        rxd_mem_addr_cntr  <= rxd_mem_next_available4write_ptr_cmb;
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (rxd_addr_cntr_en = '1' and rx_data_packed_ready = '1' and rx_data_valid_array(1)(0) = '1') then
            rxd_mem_addr_cntr  <= rxd_mem_addr_cntr + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- Initialize the dual port address for the RXS memory
  -------------------------------------------------------------------------
  RXS_ADDR_CNTR: process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        rxs_mem_addr_cntr  <= rxs_mem_four_mask;
      elsif (rxs_addr_cntr_load = '1') then
        rxs_mem_addr_cntr  <= rxs_mem_next_available4write_ptr_cmb;
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (rxs_addr_cntr_en = '1' and not(rxs_mem_addr_cntr = rxs_mem_full_mask)) then
            rxs_mem_addr_cntr  <= rxs_mem_addr_cntr + 1;
          elsif (rxs_addr_cntr_en = '1' and rxs_mem_addr_cntr = rxs_mem_full_mask) then
            rxs_mem_addr_cntr  <= rxs_mem_four_mask;
          end if;
        end if;
      end if;
    end if;
  end process;

  RX_CLIENT_RXS_DPMEM_ADDR(C_RXS_MEM_ADDR_WIDTH downto 0) <=
    rxs_mem_one_mask   when receive_frame_current_state = RESET_INIT_MEM_PTR_2 else
    rxs_mem_two_mask   when receive_frame_current_state = RESET_INIT_MEM_PTR_3 else
    rxs_mem_three_mask when receive_frame_current_state = RESET_INIT_MEM_PTR_4 else
    rxs_mem_two_mask   when receive_frame_current_state = UPDATE_MEM_PTR_2 else
    rxs_mem_addr_cntr;

  RX_CLIENT_RXS_DPMEM_WR_EN(0) <=
    '1'  when receive_frame_current_state = RESET_INIT_MEM_PTR_2 else
    '1'  when receive_frame_current_state = RESET_INIT_MEM_PTR_3 else
    '1'  when receive_frame_current_state = RESET_INIT_MEM_PTR_4 else
    '1'  when receive_frame_current_state = UPDATE_STATUS_FIFO_WORD_1 else
    '1'  when receive_frame_current_state = UPDATE_STATUS_FIFO_WORD_2 else
    '1'  when receive_frame_current_state = UPDATE_STATUS_FIFO_WORD_3 else
    '1'  when receive_frame_current_state = UPDATE_STATUS_FIFO_WORD_4 else
    '1'  when receive_frame_current_state = UPDATE_STATUS_FIFO_WORD_5 else
    '1'  when receive_frame_current_state = UPDATE_STATUS_FIFO_WORD_6 else
    '1'  when receive_frame_current_state = UPDATE_MEM_PTR_2 else
    '0';

  RX_CLIENT_RXS_DPMEM_WR_DATA(35 downto 0) <=
    zero_extend_rxd_mask36 & rxd_mem_last_read_out_ptr_cmb        when receive_frame_current_state = RESET_INIT_MEM_PTR_2 else
    zero_extend_rxs_mask36 & rxs_mem_next_available4write_ptr_cmb when receive_frame_current_state = RESET_INIT_MEM_PTR_3 else
    zero_extend_rxs_mask36 & rxs_mem_full_mask                    when receive_frame_current_state = RESET_INIT_MEM_PTR_4 else
    zero_extend_rxs_mask36 & rxs_mem_next_available4write_ptr_cmb when receive_frame_current_state = UPDATE_MEM_PTR_2 else
    rxs_status_word_1_cmb                                         when receive_frame_current_state = UPDATE_STATUS_FIFO_WORD_1 else
    rxs_status_word_2                                         when receive_frame_current_state = UPDATE_STATUS_FIFO_WORD_2 else
    rxs_status_word_3                                         when receive_frame_current_state = UPDATE_STATUS_FIFO_WORD_3 else
    rxs_status_word_4                                         when receive_frame_current_state = UPDATE_STATUS_FIFO_WORD_4 else
    rxs_status_word_5                                         when receive_frame_current_state = UPDATE_STATUS_FIFO_WORD_5 else
    rxs_status_word_6_cmb                                     when receive_frame_current_state = UPDATE_STATUS_FIFO_WORD_6 else
    (others => '0');

  --RX_CLIENT_RXD_DPMEM_WR_EN(0) <= rx_data_packed_ready when receive_frame_current_state = RECEIVING_FRAME else '0';
  RX_CLIENT_RXD_DPMEM_WR_EN(0) <= rx_data_valid_array(1)(0) when receive_frame_current_state = RECEIVING_FRAME else '0';

  RX_CLIENT_RXD_DPMEM_ADDR(C_RXD_MEM_ADDR_WIDTH downto 0) <= rxd_mem_addr_cntr;

  RX_CLIENT_RXD_DPMEM_WR_DATA(71 downto 0) <= rx_data_valid_array(1) & rx_data_words_array(1);

  --------------------------------------------------------------------------
  -- receive frame State Machine
  -- RXFRMSM_REGS_PROCESS: registered process of the state machine
  -- RXFRMSM_CMB_PROCESS:  combinatorial next-state logic
  --------------------------------------------------------------------------

  RXFRMSM_REGS_PROCESS: process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        receive_frame_current_state          <= RESET_INIT_MEM_PTR_1;
        rxd_mem_next_available4write_ptr_reg <= rxd_mem_empty_mask;
        rxd_mem_last_read_out_ptr_reg        <= rxd_mem_full_mask;
        rxs_mem_next_available4write_ptr_reg <= rxs_mem_four_mask;
        rxs_status_word_1_reg                <= (others => '0');
        rxs_status_word_6_reg                <= (others => '0');
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          receive_frame_current_state          <= receive_frame_next_state;
          rxd_mem_next_available4write_ptr_reg <= rxd_mem_next_available4write_ptr_cmb;
          rxd_mem_last_read_out_ptr_reg        <= rxd_mem_last_read_out_ptr_cmb;
          rxs_mem_next_available4write_ptr_reg <= rxs_mem_next_available4write_ptr_cmb;
          rxs_status_word_1_reg                <= rxs_status_word_1_cmb;
          rxs_status_word_6_reg                <= rxs_status_word_6_cmb;
        end if;
      end if;
    end if;
  end process;

  RXFRMSM_CMB_PROCESS: process (
    receive_frame_current_state,
    start_of_frame_array,
    end_of_frame_array,
    rxs_mem_addr_cntr,
    EMAC_CLIENT_RX_GOODFRAME_LEGACY,
    EMAC_CLIENT_RX_BADFRAME_LEGACY,
    save_rx_goodframe,
    save_rx_badframe,
    rxd_mem_next_available4write_ptr_reg,
    rxd_mem_next_available4write_ptr_cmb,
    rx_data_packed_ready,
    rxd_mem_last_read_out_ptr_reg,
    rxd_mem_last_read_out_ptr_cmb,
    rxs_mem_next_available4write_ptr_reg,
    rxs_mem_next_available4write_ptr_cmb,
    rxs_status_word_1_reg,
    rxs_status_word_1_cmb,
    rxs_status_word_6_reg,
    rxs_status_word_6_cmb,
    rxd_mem_addr_cntr,
    not_enough_rxs_memory,
    frame_is_broadcast_d10,
    frame_is_multicast_d10,
    rxd_mem_empty_mask,
    rxd_mem_full_mask,
    rxs_mem_four_mask,
    rxs_mem_full_mask,
    rxclclk_rxd_mem_last_read_out_ptr_d1,
    rxclclk_rxs_mem_last_read_out_ptr_d1,
    RX_CLIENT_RXS_DPMEM_RD_DATA,
    frame_length_bytes
    )
  begin

    rxd_addr_cntr_en              <= '0';
    rxs_addr_cntr_en              <= '0';
    rxd_addr_cntr_load            <= '0';
    rxs_addr_cntr_load            <= '0';

    rxd_mem_next_available4write_ptr_cmb <= rxd_mem_next_available4write_ptr_reg;
    rxd_mem_last_read_out_ptr_cmb        <= rxd_mem_last_read_out_ptr_reg;
    rxs_mem_next_available4write_ptr_cmb <= rxs_mem_next_available4write_ptr_reg;
    rxs_status_word_1_cmb                <= rxs_status_word_1_reg;
    rxs_status_word_6_cmb(15 downto 0)   <= rxs_status_word_6_reg(15 downto 0);

    case receive_frame_current_state is

      when RESET_INIT_MEM_PTR_1 =>
        receive_frame_next_state             <= RESET_INIT_MEM_PTR_2;
        rxd_mem_next_available4write_ptr_cmb <= rxd_mem_empty_mask;
        rxd_mem_last_read_out_ptr_cmb        <= rxd_mem_full_mask;
        rxs_mem_next_available4write_ptr_cmb <= rxs_mem_four_mask;
        rxs_status_word_1_cmb                <= (others => '0');

      when RESET_INIT_MEM_PTR_2 =>
        receive_frame_next_state         <= RESET_INIT_MEM_PTR_3;

      when RESET_INIT_MEM_PTR_3 =>
        receive_frame_next_state         <= RESET_INIT_MEM_PTR_4;

      when RESET_INIT_MEM_PTR_4 =>
        receive_frame_next_state         <= WAIT_FOR_START_OF_FRAME;

      when WAIT_FOR_START_OF_FRAME =>
        rxd_mem_last_read_out_ptr_cmb    <= rxclclk_rxd_mem_last_read_out_ptr_d1(C_RXD_MEM_ADDR_WIDTH downto 0);
        rxd_addr_cntr_load               <= '1';
        rxs_addr_cntr_load               <= '1';
        if (start_of_frame_array (1) = '1') then
          receive_frame_next_state       <= RECEIVING_FRAME;
        else
          receive_frame_next_state       <= WAIT_FOR_START_OF_FRAME;
        end if;

      when RECEIVING_FRAME =>
        rxd_mem_last_read_out_ptr_cmb    <= rxclclk_rxd_mem_last_read_out_ptr_d1(C_RXD_MEM_ADDR_WIDTH downto 0);
        rxs_status_word_1_cmb(15 downto C_RXD_MEM_ADDR_WIDTH+1) <= (others => '0');
        rxs_status_word_1_cmb(C_RXD_MEM_ADDR_WIDTH downto 0)    <= rxd_mem_next_available4write_ptr_cmb;
        rxd_addr_cntr_en                 <= '1';
        if (rxd_mem_addr_cntr = rxd_mem_last_read_out_ptr_cmb and rx_data_packed_ready = '1') then -- RXD memory overflow
          receive_frame_next_state       <= WAIT_FOR_START_OF_FRAME;
        elsif (end_of_frame_array (3) = '0') then
          receive_frame_next_state       <= RECEIVING_FRAME;
        else
          receive_frame_next_state       <= CHECK_RXS_MEM_AVAIL1;
        end if;

      when CHECK_RXS_MEM_AVAIL1 =>
        receive_frame_next_state         <= CHECK_RXS_MEM_AVAIL2;

      when CHECK_RXS_MEM_AVAIL2 =>
        receive_frame_next_state         <= END_OF_FRAME_CHECK_GOOD_BAD;

      when END_OF_FRAME_CHECK_GOOD_BAD =>
        rxs_status_word_1_cmb(35 downto 32)  <= (others => '0');
        rxs_status_word_1_cmb(31 downto 16)  <= frame_length_bytes;
        rxs_status_word_6_cmb(15 downto 0)   <= frame_length_bytes;
        if (not_enough_rxs_memory = '1') then  -- RXS memory overflow
          receive_frame_next_state       <= WAIT_FOR_START_OF_FRAME;
        elsif ((save_rx_goodframe = '1') or (save_rx_badframe = '1'))  then
          --if ((frame_is_broadcast_d10 = '1') or
          --    (frame_is_multicast_d10 = '1'))then
          --  receive_frame_next_state       <= WAIT_FOR_START_OF_FRAME;
          --else
            rxd_mem_next_available4write_ptr_cmb <= rxd_mem_addr_cntr;
            receive_frame_next_state       <= UPDATE_STATUS_FIFO_WORD_1;
          --end if;
        elsif (save_rx_badframe = '1') then
          receive_frame_next_state       <= WAIT_FOR_START_OF_FRAME;
        else
          receive_frame_next_state       <= END_OF_FRAME_CHECK_GOOD_BAD;
        end if;

      when UPDATE_STATUS_FIFO_WORD_1 =>
        receive_frame_next_state         <= UPDATE_STATUS_FIFO_WORD_2;
        rxs_addr_cntr_en                 <= '1';

      when UPDATE_STATUS_FIFO_WORD_2 =>
        receive_frame_next_state         <= UPDATE_STATUS_FIFO_WORD_3;
        rxs_addr_cntr_en                 <= '1';

      when UPDATE_STATUS_FIFO_WORD_3 =>
        receive_frame_next_state         <= UPDATE_STATUS_FIFO_WORD_4;
        rxs_addr_cntr_en                 <= '1';

      when UPDATE_STATUS_FIFO_WORD_4 =>
        receive_frame_next_state         <= UPDATE_STATUS_FIFO_WORD_5;
        rxs_addr_cntr_en                 <= '1';

      when UPDATE_STATUS_FIFO_WORD_5 =>
        receive_frame_next_state         <= UPDATE_STATUS_FIFO_WORD_6;
        rxs_addr_cntr_en                 <= '1';

      when UPDATE_STATUS_FIFO_WORD_6 =>
        receive_frame_next_state         <= UPDATE_MEM_PTR_1;
        rxs_addr_cntr_en                 <= '1';

      when UPDATE_MEM_PTR_1 =>
        receive_frame_next_state         <= UPDATE_MEM_PTR_2;
        rxs_mem_next_available4write_ptr_cmb <= rxs_mem_addr_cntr;

      when UPDATE_MEM_PTR_2 =>
        receive_frame_next_state         <= WAIT_FOR_START_OF_FRAME;

      when others   =>
        receive_frame_next_state         <= RESET_INIT_MEM_PTR_1;
    end case;
  end process;

end rtl;
