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
use ieee.std_logic_arith.conv_std_logic_vector;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.coregen_comp_defs.all;
use proc_common_v3_00_a.proc_common_pkg.log2;
use proc_common_v3_00_a.all;

-- synopsys translate_off
library XilinxCoreLib;
-- synopsys translate_on

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
--    rx_statistics_vector     
--
--    RTAGREGDATA
--    TPID0REGDATA
--    TPID1REGDATA
--    RX_CL_CLK_UAWL_REG_DATA
--    RX_CL_CLK_UAWU_REG_DATA
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

entity rx_emac_if is
  generic (
    C_RXVLAN_WIDTH        : integer                       := 12;
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
    C_AVB                 : integer range 0 to 1          := 0;
    C_STATS               : integer range 0 to 1          := 0
    );

  port    (
    RX_FRAME_RECEIVED_INTRPT        : out std_logic;                        --  Frame received interrupt
    RX_FRAME_REJECTED_INTRPT        : out std_logic;                        --  Frame rejected interrupt
    RX_BUFFER_MEM_OVERFLOW_INTRPT   : out std_logic;                        --  Memory overflow interrupt

    rx_statistics_vector            : in  std_logic_vector(27 downto 0);    -- RX statistics from TEMAC
    rx_statistics_valid             : in  std_logic;                        -- Rx stats valid from TEMAC
    end_of_frame_reset_in           : in  std_logic;                        -- end of frame reset base on last from rx axistream
                                                                        
    rx_mac_aclk                     : in  std_logic;                        -- Rx axistream clock from TEMAC
    rx_reset                        : in  std_logic;                        -- Rx axistream reset from TEMAC
    derived_rxd                     : in  std_logic_vector(7 downto 0);     -- Rx axistream data from TEMAC
                                                                        
    derived_rx_good_frame           : in  std_logic;                        -- derived good indicator
    derived_rx_bad_frame            : in  std_logic;                        -- derived bad indicator
    derived_rxd_vld                 : in  std_logic;                        -- derived data valid indicator
    derived_rx_clk_enbl             : in  std_logic;                        -- TEMAC clock domain enable

    RX_CL_CLK_RX_TAG_REG_DATA       : in  std_logic_vector(0 to 31);        --  Receive VLAN TAG
    RX_CL_CLK_TPID0_REG_DATA        : in  std_logic_vector(0 to 31);        --  Receive VLAN TPID 0
    RX_CL_CLK_TPID1_REG_DATA        : in  std_logic_vector(0 to 31);        --  Receive VLAN TPID 1
    RX_CL_CLK_UAWL_REG_DATA         : in  std_logic_vector(0 to 31);        --  Receive Unicast Address Word Lower
    RX_CL_CLK_UAWU_REG_DATA         : in  std_logic_vector(16 to 31);       --  Receive Unicast Address Word Upper

    RX_CL_CLK_MCAST_ADDR            : out std_logic_vector(0 to 14);        --  Receive Multicast Memory Address
    RX_CL_CLK_MCAST_EN              : out std_logic;                        --  Receive Multicast Memory Address Enable
    RX_CL_CLK_MCAST_RD_DATA         : in  std_logic_vector(0 to 0);         --  Receive Multicast Memory Address Read Data

    RX_CL_CLK_VLAN_ADDR             : out std_logic_vector(0 to 11);        --  Receive VLAN Memory Address
    RX_CL_CLK_VLAN_RD_DATA          : in  std_logic_vector(18 to 31);       --  Receive VLAN Memory Read Data
    RX_CL_CLK_VLAN_BRAM_EN_A        : out std_logic;                        --  Receive VLAN Memory Enable

    RX_CL_CLK_BAD_FRAME_ENBL        : in  std_logic;                        --  Receive Bad Frame Enable
    RX_CL_CLK_EMULTI_FLTR_ENBL      : in  std_logic;                        --  Receive Extended Multicast Address Filter Enable
    RX_CL_CLK_NEW_FNC_ENBL          : in  std_logic;                        --  Receive New Function Enable
    RX_CL_CLK_BRDCAST_REJ           : in  std_logic;                        --  Receive Broadcast Reject
    RX_CL_CLK_MULCAST_REJ           : in  std_logic;                        --  Receive Multicast Reject
    RX_CL_CLK_VSTRP_MODE            : in  std_logic_vector(0 to 1);         --  Receive VLAN Strip Mode
    RX_CL_CLK_VTAG_MODE             : in  std_logic_vector(0 to 1);         --  Receive VLAN TAG Mode

    RX_CLIENT_RXD_DPMEM_WR_DATA     : out std_logic_vector(35 downto 0);                    --  Receive Data Memory Write Data
    RX_CLIENT_RXD_DPMEM_RD_DATA     : in  std_logic_vector(35 downto 0);                    --  Receive Data Memory Read Data
    RX_CLIENT_RXD_DPMEM_WR_EN       : out std_logic_vector(0 downto 0);                     --  Receive Data Memory Write Enable
    RX_CLIENT_RXD_DPMEM_ADDR        : out std_logic_vector(C_RXD_MEM_ADDR_WIDTH downto 0);  --  Receive Data Memory Address
    RX_CLIENT_RXS_DPMEM_WR_DATA     : out std_logic_vector(35 downto 0);                    --  Receive Status Memory Write Data
    RX_CLIENT_RXS_DPMEM_RD_DATA     : in  std_logic_vector(35 downto 0);                    --  Receive Status Memory Read Data
    RX_CLIENT_RXS_DPMEM_WR_EN       : out std_logic_vector(0 downto 0);                     --  Receive Status Memory Write Enable
    RX_CLIENT_RXS_DPMEM_ADDR        : out std_logic_vector(C_RXS_MEM_ADDR_WIDTH downto 0);  --  Receive Status Memory Address

    AXI_STR_RXS_MEM_LAST_READ_OUT_PTR_GRAY : in std_logic_vector(35 downto 0);    --  Receive Status Gray code pointer
    AXI_STR_RXD_MEM_LAST_READ_OUT_PTR_GRAY : in std_logic_vector(35 downto 0)     --  Receive Data Gray code pointer
  );
end rx_emac_if;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of rx_emac_if is

signal EMAC_CLIENT_RXD_LEGACY          : std_logic_vector(7 downto  0);
signal EMAC_CLIENT_RXD_VLD_LEGACY      : std_logic;
signal EMAC_CLIENT_RX_GOODFRAME_LEGACY : std_logic;
signal EMAC_CLIENT_RX_BADFRAME_LEGACY  : std_logic;
signal EMAC_CLIENT_RX_FRAMEDROP        : std_logic;
signal LEGACY_RX_FILTER_MATCH          : std_logic_vector(7 downto 0);

signal RX_CLIENT_CLK                   : std_logic;
signal RX_CLIENT_CLK_ENBL              : std_logic;
signal RESET2RX_CLIENT                 : std_logic;

signal EMAC_CLIENT_RX_STATS            : std_logic_vector(6  downto  0);
signal EMAC_CLIENT_RX_STATS_VLD        : std_logic;
signal EMAC_CLIENT_RX_STATS_BYTE_VLD   : std_logic;
signal EMAC_CLIENT_RXD_VLD_2STATS      : std_logic;
signal SOFT_EMAC_CLIENT_RX_STATS       : std_logic_vector(27 downto 0);

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

type type_rx_data_words_array    is array (1 to 4) of std_logic_vector(31 downto 0);
type type_rx_data_valid_array    is array (1 to 4) of std_logic_vector(3 downto 0);
type type_start_of_frame_array   is array (1 to 52) of std_logic;
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
signal first_tag_is_vlan_TPID_0_d15     : std_logic;
signal first_tag_is_vlan_TPID_1_d15     : std_logic;
signal first_tag_is_vlan_TPID_2_d15     : std_logic;
signal first_tag_is_vlan_TPID_3_d15     : std_logic;
signal second_tag_is_vlan_TPID_0_d19    : std_logic;
signal second_tag_is_vlan_TPID_1_d19    : std_logic;
signal second_tag_is_vlan_TPID_2_d19    : std_logic;
signal second_tag_is_vlan_TPID_3_d19    : std_logic;
signal frame_is_vlan_8100_d15           : std_logic;
signal frame_has_valid_length_field_d22 : std_logic;
signal frame_has_type_0800_d22          : std_logic;
signal frame_is_snap_d30                : std_logic;
signal frame_is_ip_protocol_d31         : std_logic;
signal frame_has_ip_hdr_length_d31      : std_logic;
signal frame_has_no_ip_frags_d38        : std_logic;
signal frame_has_udp_protocol_d38       : std_logic;
signal frame_has_tcp_protocol_d38       : std_logic;
signal pack_high_1_pack_low_0           : std_logic;
signal rxd_packed_16bits                : std_logic_vector(15 downto 0);
signal enable_ip_hdr_sum_1              : std_logic;
signal ip_header_sum_1                  : std_logic_vector(16 downto 0);
signal enable_ip_hdr_sum_2              : std_logic;
signal ip_header_sum_2                  : std_logic_vector(16 downto 0);
signal enable_ip_hdr_sum_3              : std_logic;
signal ip_header_sum_3                  : std_logic_vector(16 downto 0);
signal enable_ip_hdr_sum_4              : std_logic;
signal ip_header_sum_4                  : std_logic_vector(16 downto 0);
signal ip_header_csum_1_ok              : std_logic;
signal ip_header_csum_2_ok              : std_logic;
signal ip_header_csum_3_ok              : std_logic;
signal ip_header_csum_4_ok              : std_logic;
signal frame_ip_csum_checked            : std_logic;
signal frame_udp_csum_checked           : std_logic;
signal frame_tcp_csum_checked           : std_logic;
signal frame_is_e2                      : std_logic;
signal frame_is_e2_vlan                 : std_logic;
signal frame_is_snap                    : std_logic;
signal frame_is_snap_vlan               : std_logic;
signal frame_ip_csum_ok                 : std_logic;
signal frame_udp_csum_ok                : std_logic;
signal frame_tcp_csum_ok                : std_logic;
signal receive_checksum_status          : std_logic_vector(2 downto 0);
signal receive_checksum_status_i        : std_logic_vector(2 downto 0);

signal enable_udp_hdr_sum_1             : std_logic;
signal udp_header_sum_1                 : std_logic_vector(16 downto 0);
signal udp_header_csum_1_ok             : std_logic;
signal save_udp_hdr_length_1            : std_logic_vector(15 downto 0);
signal enable_udp_hdr_sum_2             : std_logic;
signal udp_header_sum_2                 : std_logic_vector(16 downto 0);
signal udp_header_csum_2_ok             : std_logic;
signal save_udp_hdr_length_2            : std_logic_vector(15 downto 0);
signal enable_udp_hdr_sum_3             : std_logic;
signal udp_header_sum_3                 : std_logic_vector(16 downto 0);
signal udp_header_csum_3_ok             : std_logic;
signal save_udp_hdr_length_3            : std_logic_vector(15 downto 0);
signal enable_udp_hdr_sum_4             : std_logic;
signal udp_header_sum_4                 : std_logic_vector(16 downto 0);
signal udp_header_csum_4_ok             : std_logic;
signal save_udp_hdr_length_4            : std_logic_vector(15 downto 0);

signal save_tcp_length_1                : std_logic_vector(15 downto 0);
signal enable_tcp_hdr_sum_1             : std_logic;
signal tcp_header_sum_1                 : std_logic_vector(16 downto 0);
signal tcp_header_csum_1_ok             : std_logic;
signal save_tcp_length_2                : std_logic_vector(15 downto 0);
signal enable_tcp_hdr_sum_2             : std_logic;
signal tcp_header_sum_2                 : std_logic_vector(16 downto 0);
signal tcp_header_csum_2_ok             : std_logic;
signal save_tcp_length_3                : std_logic_vector(15 downto 0);
signal enable_tcp_hdr_sum_3             : std_logic;
signal tcp_header_sum_3                 : std_logic_vector(16 downto 0);
signal tcp_header_csum_3_ok             : std_logic;
signal save_tcp_length_4                : std_logic_vector(15 downto 0);
signal enable_tcp_hdr_sum_4             : std_logic;
signal tcp_header_sum_4                 : std_logic_vector(16 downto 0);
signal tcp_header_csum_4_ok             : std_logic;

signal rx_data_packed_word              : std_logic_vector(31 downto 0);
signal rx_data_vld_packed_word          : std_logic_vector(3 downto 0);
signal rx_data_packed_state             : std_logic_vector(1 downto 0);
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
signal frame_drop                       : std_logic;
signal not_enough_rxs_memory            : std_logic;

signal rxCsum                           : std_logic_vector(15 downto 0);
signal rxCsumVld                        : std_logic;

signal extendedMulticastReject          : std_logic;
signal saveExtendedMulticastReject : std_logic;

signal rxclclk_rxd_mem_last_read_out_ptr           : std_logic_vector(35 downto 0);
signal rxclclk_rxd_mem_last_read_out_ptr_d1        : std_logic_vector(35 downto 0);
signal sync_rxd_mem_last_read_out_ptr_gray_d2      : std_logic_vector(35 downto 0);
signal sync_rxd_mem_last_read_out_ptr_gray_d1      : std_logic_vector(35 downto 0);

signal rxclclk_rxs_mem_last_read_out_ptr           : std_logic_vector(35 downto 0);
signal rxclclk_rxs_mem_last_read_out_ptr_d1        : std_logic_vector(35 downto 0);
signal sync_rxs_mem_last_read_out_ptr_gray_d2      : std_logic_vector(35 downto 0);
signal sync_rxs_mem_last_read_out_ptr_gray_d1      : std_logic_vector(35 downto 0);

signal eof_reset : std_logic;

begin

  EMAC_CLIENT_RXD_VLD_LEGACY      <= derived_rxd_vld;
  RX_CLIENT_CLK_ENBL              <= derived_rx_clk_enbl;

  EMAC_CLIENT_RX_GOODFRAME_LEGACY <= derived_rx_good_frame;
  EMAC_CLIENT_RX_BADFRAME_LEGACY  <= derived_rx_bad_frame;
  EMAC_CLIENT_RX_STATS_VLD        <= rx_statistics_valid;
  SOFT_EMAC_CLIENT_RX_STATS       <= rx_statistics_vector;
  RX_CLIENT_CLK                   <= rx_mac_aclk;
  RESET2RX_CLIENT                 <= rx_reset;
  EMAC_CLIENT_RXD_LEGACY          <= derived_rxd;

  eof_reset <= end_of_frame_reset_in;

  NO_FULL_CSUM_OFFLOAD: if(not(C_RXCSUM = 2)) generate
  begin
    receive_checksum_status  <= "000";
  end generate NO_FULL_CSUM_OFFLOAD;

  YES_FULL_CSUM_OFFLOAD: if (C_RXCSUM = 2) generate
  begin
    receive_checksum_status_i <= "000" when frame_ip_csum_checked  = '0' else
                                 "001" when frame_ip_csum_checked  = '1' and frame_ip_csum_ok = '1' and
                                            frame_udp_csum_checked = '0' and frame_tcp_csum_checked = '0' else
                                 "010" when frame_ip_csum_checked  = '1' and frame_ip_csum_ok = '1' and
                                            frame_tcp_csum_checked = '1' and frame_tcp_csum_ok = '1' else
                                 "011" when frame_ip_csum_checked  = '1' and frame_ip_csum_ok = '1' and
                                            frame_udp_csum_checked = '1' and frame_udp_csum_ok = '1' else
                                 "101" when frame_ip_csum_checked  = '1' and frame_ip_csum_ok = '0' else
                                 "110" when frame_ip_csum_checked  = '1' and frame_ip_csum_ok = '1' and
                                            frame_tcp_csum_checked = '1' and frame_tcp_csum_ok = '0' else
                                 "111" when frame_ip_csum_checked  = '1' and frame_ip_csum_ok = '1' and
                                            frame_udp_csum_checked = '1' and frame_udp_csum_ok = '0' else
                                 "100"; -- should never get this value!

    REG_CSUM_STATUS_PROCESS: process (RX_CLIENT_CLK)
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          receive_checksum_status  <= "000";
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if(eof_reset = '1') then
            receive_checksum_status  <= "000";
          else
            receive_checksum_status  <= receive_checksum_status_i;
          end if;
         end if;
        end if;
      end if;
    end process;

    IP_CSUM_CHECKED_PROCESS: process (RX_CLIENT_CLK)
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_ip_csum_checked  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if(eof_reset = '1') then
            frame_ip_csum_checked  <= '0';
          elsif (frame_has_type_0800_d22 = '1' or frame_is_snap_d30 = '1') and frame_has_ip_hdr_length_d31 = '1' and
                frame_is_ip_protocol_d31 = '1' and frame_has_no_ip_frags_d38 = '1' then
            frame_ip_csum_checked  <= '1';
          end if;
         end if;
        end if;
      end if;
    end process;

    UDP_CSUM_CHECKED_PROCESS: process (RX_CLIENT_CLK)
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_udp_csum_checked  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if(eof_reset = '1') then
            frame_udp_csum_checked  <= '0';
          elsif frame_ip_csum_checked = '1' and frame_has_udp_protocol_d38 = '1' and frame_ip_csum_checked = '1' and
                frame_ip_csum_ok = '1' then
            frame_udp_csum_checked  <= '1';
          end if;
         end if;
        end if;
      end if;
    end process;

    TCP_CSUM_CHECKED_PROCESS: process (RX_CLIENT_CLK)
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_tcp_csum_checked  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if(eof_reset = '1') then
            frame_tcp_csum_checked  <= '0';
          elsif frame_ip_csum_checked = '1' and frame_has_tcp_protocol_d38 = '1' and frame_ip_csum_checked = '1' and
                frame_ip_csum_ok = '1' then
            frame_tcp_csum_checked  <= '1';
          end if;
         end if;
        end if;
      end if;
    end process;

    FRAME_IS_ETHERNET_2_PROCESS: process (RX_CLIENT_CLK)
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_is_e2  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if(eof_reset = '1') then
            frame_is_e2  <= '0';
          elsif frame_has_type_0800_d22 = '1' and frame_is_vlan_8100_d15 = '0' then
            frame_is_e2  <= '1';
          end if;
         end if;
        end if;
      end if;
    end process;

    FRAME_IS_ETHERNET_2VLAN_PROCESS: process (RX_CLIENT_CLK)
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_is_e2_vlan  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if(eof_reset = '1') then
            frame_is_e2_vlan  <= '0';
          elsif frame_has_type_0800_d22 = '1' and frame_is_vlan_8100_d15 = '1' then
            frame_is_e2_vlan  <= '1';
          end if;
         end if;
        end if;
      end if;
    end process;

    FRAME_IS_SNAP_PROCESS: process (RX_CLIENT_CLK)
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_is_snap  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if(eof_reset = '1') then
            frame_is_snap  <= '0';
          elsif frame_is_snap_d30 = '1' and frame_is_vlan_8100_d15 = '0' then
            frame_is_snap  <= '1';
          end if;
         end if;
        end if;
      end if;
    end process;

    FRAME_IS_SNAPVLAN_PROCESS: process (RX_CLIENT_CLK)
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_is_snap_vlan  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if(eof_reset = '1') then
            frame_is_snap_vlan  <= '0';
          elsif frame_is_snap_d30 = '1' and frame_is_vlan_8100_d15 = '1' then
            frame_is_snap_vlan  <= '1';
          end if;
         end if;
        end if;
      end if;
    end process;

    IP_CSUM_IS_OK_PROCESS: process (RX_CLIENT_CLK)
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_ip_csum_ok  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if(eof_reset = '1') then
            frame_ip_csum_ok  <= '0';
          elsif frame_ip_csum_checked = '1' and ((frame_is_e2 = '1'        and ip_header_csum_1_ok = '1') or
                                                 (frame_is_e2_vlan = '1'   and ip_header_csum_2_ok = '1') or
                                                 (frame_is_snap = '1'      and ip_header_csum_3_ok = '1') or
                                                 (frame_is_snap_vlan = '1' and ip_header_csum_4_ok = '1')) then
            frame_ip_csum_ok  <= '1';
          end if;
         end if;
        end if;
      end if;
    end process;

    UDP_CSUM_IS_OK_PROCESS: process (RX_CLIENT_CLK)
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_udp_csum_ok  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if(eof_reset = '1') then
            frame_udp_csum_ok  <= '0';
          elsif frame_udp_csum_checked = '1' and ((frame_is_e2 = '1'        and udp_header_csum_1_ok = '1') or
                                                  (frame_is_e2_vlan = '1'   and udp_header_csum_2_ok = '1') or
                                                  (frame_is_snap = '1'      and udp_header_csum_3_ok = '1') or
                                                  (frame_is_snap_vlan = '1' and udp_header_csum_4_ok = '1')) then
            frame_udp_csum_ok  <= '1';
          end if;
         end if;
        end if;
      end if;
    end process;

    TCP_CSUM_IS_OK_PROCESS: process (RX_CLIENT_CLK)
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_tcp_csum_ok  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if(eof_reset = '1') then
            frame_tcp_csum_ok  <= '0';
          elsif frame_tcp_csum_checked = '1' and ((frame_is_e2 = '1'        and tcp_header_csum_1_ok = '1') or
                                                  (frame_is_e2_vlan = '1'   and tcp_header_csum_2_ok = '1') or
                                                  (frame_is_snap = '1'      and tcp_header_csum_3_ok = '1') or
                                                  (frame_is_snap_vlan = '1' and tcp_header_csum_4_ok = '1')) then
            frame_tcp_csum_ok  <= '1';
          end if;
         end if;
        end if;
      end if;
    end process;

    SUM_IP_HDR_1_PROCESS: process (RX_CLIENT_CLK) -- no vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          ip_header_sum_1  <=(others => '0');
          ip_header_csum_1_ok <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (eof_reset = '1') then
            ip_header_csum_1_ok <= '0';
          elsif (ip_header_sum_1(15 downto 0) = X"FFFF" and ip_header_sum_1(16) = '0' and enable_ip_hdr_sum_1 = '0') then
            ip_header_csum_1_ok <= '1';
          else
            ip_header_csum_1_ok <= '0';
          end if;

          if (eof_reset = '1') then
            ip_header_sum_1  <=(others => '0');
          elsif (enable_ip_hdr_sum_1 = '1' and pack_high_1_pack_low_0 = '1') then
            ip_header_sum_1(16 downto 0)  <= ('0'&ip_header_sum_1(15 downto 0)) + ('0'&rxd_packed_16bits(15 downto 0));
          elsif (enable_ip_hdr_sum_1 = '1' and pack_high_1_pack_low_0 = '0') then
            -- wrap previous carry back in
            ip_header_sum_1(16 downto 0)  <= ('0'&ip_header_sum_1(15 downto 0)) + (X"0000"&ip_header_sum_1(16));
          end if;
         end if;
        end if;
      end if;
    end process;

    ENABLE_IP_HEADER_SUM_1_PROCESS: process (RX_CLIENT_CLK) -- no vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          enable_ip_hdr_sum_1  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(15) = '1') then
            enable_ip_hdr_sum_1  <= '1';
          elsif(start_of_frame_array(35) = '1') then
            enable_ip_hdr_sum_1  <= '0';
          end if;
         end if;
        end if;
      end if;
    end process;

    SUM_IP_HDR_2_PROCESS: process (RX_CLIENT_CLK) -- yes vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          ip_header_sum_2  <=(others => '0');
          ip_header_csum_2_ok <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (eof_reset = '1') then
            ip_header_csum_2_ok <= '0';
          elsif (ip_header_sum_2(15 downto 0) = X"FFFF" and ip_header_sum_2(16) = '0' and enable_ip_hdr_sum_2 = '0') then
            ip_header_csum_2_ok <= '1';
          else
            ip_header_csum_2_ok <= '0';
          end if;

          if (eof_reset = '1') then
            ip_header_sum_2  <=(others => '0');
          elsif (enable_ip_hdr_sum_2 = '1' and pack_high_1_pack_low_0 = '1') then
            ip_header_sum_2(16 downto 0)  <= ('0'&ip_header_sum_2(15 downto 0)) + ('0'&rxd_packed_16bits(15 downto 0));
          elsif (enable_ip_hdr_sum_2 = '1' and pack_high_1_pack_low_0 = '0') then
            -- wrap previous carry back in
            ip_header_sum_2(16 downto 0)  <= ('0'&ip_header_sum_2(15 downto 0)) + (X"0000"&ip_header_sum_2(16));
          end if;
         end if;
        end if;
      end if;
    end process;

    ENABLE_IP_HEADER_SUM_2_PROCESS: process (RX_CLIENT_CLK) -- yes vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          enable_ip_hdr_sum_2 <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(19) = '1') then
            enable_ip_hdr_sum_2  <= '1';
          elsif(start_of_frame_array(39) = '1') then
            enable_ip_hdr_sum_2  <= '0';
          end if;
         end if;
        end if;
      end if;
    end process;

    SUM_IP_HDR_3_PROCESS: process (RX_CLIENT_CLK) -- no vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          ip_header_sum_3  <=(others => '0');
          ip_header_csum_3_ok <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (eof_reset = '1') then
            ip_header_csum_3_ok <= '0';
          elsif (ip_header_sum_3(15 downto 0) = X"FFFF" and ip_header_sum_3(16) = '0' and enable_ip_hdr_sum_3 = '0') then
            ip_header_csum_3_ok <= '1';
          else
            ip_header_csum_3_ok <= '0';
          end if;

          if (eof_reset = '1') then
            ip_header_sum_3  <=(others => '0');
          elsif (enable_ip_hdr_sum_3 = '1' and pack_high_1_pack_low_0 = '1') then
            ip_header_sum_3(16 downto 0)  <= ('0'&ip_header_sum_3(15 downto 0)) + ('0'&rxd_packed_16bits(15 downto 0));
          elsif (enable_ip_hdr_sum_3 = '1' and pack_high_1_pack_low_0 = '0') then
            -- wrap previous carry back in
            ip_header_sum_3(16 downto 0)  <= ('0'&ip_header_sum_3(15 downto 0)) + (X"0000"&ip_header_sum_3(16));
          end if;
         end if;
        end if;
      end if;
    end process;

    ENABLE_IP_HEADER_SUM_3_PROCESS: process (RX_CLIENT_CLK) -- no vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          enable_ip_hdr_sum_3  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(23) = '1') then
            enable_ip_hdr_sum_3  <= '1';
          elsif(start_of_frame_array(43) = '1') then
            enable_ip_hdr_sum_3  <= '0';
          end if;
         end if;
        end if;
      end if;
    end process;

    SUM_IP_HDR_4_PROCESS: process (RX_CLIENT_CLK) -- yes vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          ip_header_sum_4  <=(others => '0');
          ip_header_csum_4_ok <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (eof_reset = '1') then
            ip_header_csum_4_ok <= '0';
          elsif (ip_header_sum_4(15 downto 0) = X"FFFF" and ip_header_sum_4(16) = '0' and enable_ip_hdr_sum_4 = '0') then
            ip_header_csum_4_ok <= '1';
          else
            ip_header_csum_4_ok <= '0';
          end if;

          if (eof_reset = '1') then
            ip_header_sum_4  <=(others => '0');
          elsif (enable_ip_hdr_sum_4 = '1' and pack_high_1_pack_low_0 = '1') then
            ip_header_sum_4(16 downto 0)  <= ('0'&ip_header_sum_4(15 downto 0)) + ('0'&rxd_packed_16bits(15 downto 0));
          elsif (enable_ip_hdr_sum_4 = '1' and pack_high_1_pack_low_0 = '0') then
            -- wrap previous carry back in
            ip_header_sum_4(16 downto 0)  <= ('0'&ip_header_sum_4(15 downto 0)) + (X"0000"&ip_header_sum_4(16));
          end if;
         end if;
        end if;
      end if;
    end process;

    ENABLE_IP_HEADER_SUM_4_PROCESS: process (RX_CLIENT_CLK) -- yes vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          enable_ip_hdr_sum_4  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(27) = '1') then
            enable_ip_hdr_sum_4  <= '1';
          elsif(start_of_frame_array(47) = '1') then
            enable_ip_hdr_sum_4  <= '0';
          end if;
         end if;
        end if;
      end if;
    end process;

    SUM_UDP_HDR_1_PROCESS: process (RX_CLIENT_CLK) -- no vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          udp_header_sum_1  <=(others => '0');
          udp_header_csum_1_ok <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (eof_reset = '1') then
            udp_header_csum_1_ok <= '0';
          elsif ((udp_header_sum_1(15 downto 0) + save_udp_hdr_length_1) = X"FFFF" and udp_header_sum_1(16) = '0' and
                  enable_udp_hdr_sum_1 = '0') then
            udp_header_csum_1_ok <= '1';
          elsif ((udp_header_sum_1(15 downto 0) + save_udp_hdr_length_1) = X"FFFE" and udp_header_sum_1(16) = '1' and
                  enable_udp_hdr_sum_1 = '0') then
            udp_header_csum_1_ok <= '1';
          else
            udp_header_csum_1_ok <= '0';
          end if;

          if (eof_reset = '1') then
            udp_header_sum_1  <=(others => '0');
          elsif (enable_udp_hdr_sum_1 = '1' and pack_high_1_pack_low_0 = '1') then
            if (start_of_frame_array(24) = '1') then -- mask Time to live filed from protocol in Ip header
              udp_header_sum_1(16 downto 0)  <= ('0'&udp_header_sum_1(15 downto 0)) + ("000000000"&rxd_packed_16bits(7 downto 0));
            elsif (start_of_frame_array(26) = '1') then -- mask IP header csum
              udp_header_sum_1(16 downto 0)  <= ('0'&udp_header_sum_1(15 downto 0)) + ("00000000000000000");
            else
              udp_header_sum_1(16 downto 0)  <= ('0'&udp_header_sum_1(15 downto 0)) + ('0'&rxd_packed_16bits(15 downto 0));
            end if;
          elsif (enable_udp_hdr_sum_1 = '1' and pack_high_1_pack_low_0 = '0') then
            -- wrap previous carry back in
            udp_header_sum_1(16 downto 0)  <= ('0'&udp_header_sum_1(15 downto 0)) + (X"0000"&udp_header_sum_1(16));
          end if;
         end if;
        end if;
      end if;
    end process;

    SAVE_UDP_HEADER_LENGTH_1_PROCESS: process (RX_CLIENT_CLK) -- no vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          save_udp_hdr_length_1  <= (others => '0');
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(40) = '1') then
            save_udp_hdr_length_1  <= rxd_packed_16bits;
          elsif(eof_reset = '1') then
            save_udp_hdr_length_1  <= (others => '0');
          end if;
         end if;
        end if;
      end if;
    end process;

    ENABLE_UDP_HEADER_SUM_1_PROCESS: process (RX_CLIENT_CLK) -- no vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          enable_udp_hdr_sum_1  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(23) = '1') then
            enable_udp_hdr_sum_1  <= '1';
          elsif(start_of_frame_d1 = '0') then
            enable_udp_hdr_sum_1  <= '0';
          end if;
         end if;
        end if;
      end if;
    end process;

    SUM_UDP_HDR_2_PROCESS: process (RX_CLIENT_CLK) -- yes vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          udp_header_sum_2  <=(others => '0');
          udp_header_csum_2_ok <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (eof_reset = '1') then
            udp_header_csum_2_ok <= '0';
          elsif ((udp_header_sum_2(15 downto 0) + save_udp_hdr_length_2) = X"FFFF" and udp_header_sum_2(16) = '0' and
                  enable_udp_hdr_sum_2 = '0') then
            udp_header_csum_2_ok <= '1';
          elsif ((udp_header_sum_2(15 downto 0) + save_udp_hdr_length_2) = X"FFFE" and udp_header_sum_2(16) = '1' and
                  enable_udp_hdr_sum_2 = '0') then
            udp_header_csum_2_ok <= '1';
          else
            udp_header_csum_2_ok <= '0';
          end if;

          if (eof_reset = '1') then
            udp_header_sum_2  <=(others => '0');
          elsif (enable_udp_hdr_sum_2 = '1' and pack_high_1_pack_low_0 = '1') then
            if (start_of_frame_array(28) = '1') then -- mask Time to live filed from protocol in Ip header
              udp_header_sum_2(16 downto 0)  <= ('0'&udp_header_sum_2(15 downto 0)) + ("000000000"&rxd_packed_16bits(7 downto 0));
            elsif (start_of_frame_array(30) = '1') then -- mask IP header csum
              udp_header_sum_2(16 downto 0)  <= ('0'&udp_header_sum_2(15 downto 0)) + ("00000000000000000");
            else
              udp_header_sum_2(16 downto 0)  <= ('0'&udp_header_sum_2(15 downto 0)) + ('0'&rxd_packed_16bits(15 downto 0));
            end if;
          elsif (enable_udp_hdr_sum_2 = '1' and pack_high_1_pack_low_0 = '0') then
            -- wrap previous carry back in
            udp_header_sum_2(16 downto 0)  <= ('0'&udp_header_sum_2(15 downto 0)) + (X"0000"&udp_header_sum_2(16));
          end if;
         end if;
        end if;
      end if;
    end process;

    SAVE_UDP_HEADER_LENGTH_2_PROCESS: process (RX_CLIENT_CLK) -- yes vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          save_udp_hdr_length_2  <= (others => '0');
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(44) = '1') then
            save_udp_hdr_length_2  <= rxd_packed_16bits;
          elsif(eof_reset = '1') then
            save_udp_hdr_length_2  <= (others => '0');
          end if;
         end if;
        end if;
      end if;
    end process;

    ENABLE_UDP_HEADER_SUM_2_PROCESS: process (RX_CLIENT_CLK) -- yes vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          enable_udp_hdr_sum_2  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(27) = '1') then
            enable_udp_hdr_sum_2  <= '1';
          elsif(start_of_frame_d1 = '0') then
            enable_udp_hdr_sum_2  <= '0';
          end if;
         end if;
        end if;
      end if;
    end process;

    SUM_UDP_HDR_3_PROCESS: process (RX_CLIENT_CLK) -- no vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          udp_header_sum_3  <=(others => '0');
          udp_header_csum_3_ok <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (eof_reset = '1') then
            udp_header_csum_3_ok <= '0';
          elsif ((udp_header_sum_3(15 downto 0) + save_udp_hdr_length_3) = X"FFFF" and udp_header_sum_3(16) = '0' and
                  enable_udp_hdr_sum_3 = '0') then
            udp_header_csum_3_ok <= '1';
          elsif ((udp_header_sum_3(15 downto 0) + save_udp_hdr_length_3) = X"FFFE" and udp_header_sum_3(16) = '1' and
                  enable_udp_hdr_sum_3 = '0') then
            udp_header_csum_3_ok <= '1';
          else
            udp_header_csum_3_ok <= '0';
          end if;

          if (eof_reset = '1') then
            udp_header_sum_3  <=(others => '0');
          elsif (enable_udp_hdr_sum_3 = '1' and pack_high_1_pack_low_0 = '1') then
            if (start_of_frame_array(32) = '1') then -- mask Time to live filed from protocol in Ip header
              udp_header_sum_3(16 downto 0)  <= ('0'&udp_header_sum_3(15 downto 0)) + ("000000000"&rxd_packed_16bits(7 downto 0));
            elsif (start_of_frame_array(34) = '1') then -- mask IP header csum
              udp_header_sum_3(16 downto 0)  <= ('0'&udp_header_sum_3(15 downto 0)) + ("00000000000000000");
            else
              udp_header_sum_3(16 downto 0)  <= ('0'&udp_header_sum_3(15 downto 0)) + ('0'&rxd_packed_16bits(15 downto 0));
            end if;
          elsif (enable_udp_hdr_sum_3 = '1' and pack_high_1_pack_low_0 = '0') then
            -- wrap previous carry back in
            udp_header_sum_3(16 downto 0)  <= ('0'&udp_header_sum_3(15 downto 0)) + (X"0000"&udp_header_sum_3(16));
          end if;
         end if;
        end if;
      end if;
    end process;

    SAVE_UDP_HEADER_LENGTH_3_PROCESS: process (RX_CLIENT_CLK) -- no vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          save_udp_hdr_length_3  <= (others => '0');
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(48) = '1') then
            save_udp_hdr_length_3  <= rxd_packed_16bits;
          elsif(eof_reset = '1') then
            save_udp_hdr_length_3  <= (others => '0');
          end if;
         end if;
        end if;
      end if;
    end process;

    ENABLE_UDP_HEADER_SUM_3_PROCESS: process (RX_CLIENT_CLK) -- no vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          enable_udp_hdr_sum_3  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(31) = '1') then
            enable_udp_hdr_sum_3  <= '1';
          elsif(start_of_frame_d1 = '0') then
            enable_udp_hdr_sum_3  <= '0';
          end if;
         end if;
        end if;
      end if;
    end process;

    SUM_UDP_HDR_4_PROCESS: process (RX_CLIENT_CLK) -- yes vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          udp_header_sum_4  <=(others => '0');
          udp_header_csum_4_ok <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (eof_reset = '1') then
            udp_header_csum_4_ok <= '0';
          elsif ((udp_header_sum_4(15 downto 0) + save_udp_hdr_length_4) = X"FFFF" and udp_header_sum_4(16) = '0' and
                  enable_udp_hdr_sum_4 = '0') then
            udp_header_csum_4_ok <= '1';
          elsif ((udp_header_sum_4(15 downto 0) + save_udp_hdr_length_4) = X"FFFE" and udp_header_sum_4(16) = '1' and
                  enable_udp_hdr_sum_4 = '0') then
            udp_header_csum_4_ok <= '1';
          else
            udp_header_csum_4_ok <= '0';
          end if;

          if (eof_reset = '1') then
            udp_header_sum_4  <=(others => '0');
          elsif (enable_udp_hdr_sum_4 = '1' and pack_high_1_pack_low_0 = '1') then
            if (start_of_frame_array(36) = '1') then -- mask Time to live filed from protocol in Ip header
              udp_header_sum_4(16 downto 0)  <= ('0'&udp_header_sum_4(15 downto 0)) + ("000000000"&rxd_packed_16bits(7 downto 0));
            elsif (start_of_frame_array(38) = '1') then -- mask IP header csum
              udp_header_sum_4(16 downto 0)  <= ('0'&udp_header_sum_4(15 downto 0)) + ("00000000000000000");
            else
              udp_header_sum_4(16 downto 0)  <= ('0'&udp_header_sum_4(15 downto 0)) + ('0'&rxd_packed_16bits(15 downto 0));
            end if;
          elsif (enable_udp_hdr_sum_4 = '1' and pack_high_1_pack_low_0 = '0') then
            -- wrap previous carry back in
            udp_header_sum_4(16 downto 0)  <= ('0'&udp_header_sum_4(15 downto 0)) + (X"0000"&udp_header_sum_4(16));
          end if;
         end if;
        end if;
      end if;
    end process;

    SAVE_UDP_HEADER_LENGTH_4_PROCESS: process (RX_CLIENT_CLK) -- yes vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          save_udp_hdr_length_4  <= (others => '0');
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(52) = '1') then
            save_udp_hdr_length_4  <= rxd_packed_16bits;
          elsif(eof_reset = '1') then
            save_udp_hdr_length_4  <= (others => '0');
          end if;
         end if;
        end if;
      end if;
    end process;

    ENABLE_UDP_HEADER_SUM_4_PROCESS: process (RX_CLIENT_CLK) -- yes vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          enable_udp_hdr_sum_4  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(35) = '1') then
            enable_udp_hdr_sum_4  <= '1';
          elsif(start_of_frame_d1 = '0') then
            enable_udp_hdr_sum_4  <= '0';
          end if;
         end if;
        end if;
      end if;
    end process;

    SAVE_TCP_LENGTH_1_PROCESS: process (RX_CLIENT_CLK) -- no vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          save_tcp_length_1  <= (others => '0');
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(18) = '1') then
            save_tcp_length_1  <= rxd_packed_16bits - X"0014";
          elsif(eof_reset = '1') then
            save_tcp_length_1  <= (others => '0');
          end if;
         end if;
        end if;
      end if;
    end process;

    ENABLE_TCP_HEADER_SUM_1_PROCESS: process (RX_CLIENT_CLK) -- no vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          enable_tcp_hdr_sum_1  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(23) = '1') then
            enable_tcp_hdr_sum_1  <= '1';
          elsif(start_of_frame_d1 = '0') then
            enable_tcp_hdr_sum_1  <= '0';
          end if;
         end if;
        end if;
      end if;
    end process;

    SUM_TCP_HDR_1_PROCESS: process (RX_CLIENT_CLK) -- no vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          tcp_header_sum_1  <=(others => '0');
          tcp_header_csum_1_ok <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (eof_reset = '1') then
            tcp_header_csum_1_ok <= '0';
          elsif ((tcp_header_sum_1(15 downto 0) + save_tcp_length_1) = X"FFFF" and tcp_header_sum_1(16) = '0' and
                  enable_tcp_hdr_sum_1 = '0') then
            tcp_header_csum_1_ok <= '1';
          elsif ((tcp_header_sum_1(15 downto 0) + save_tcp_length_1) = X"FFFE" and tcp_header_sum_1(16) = '1' and
                  enable_tcp_hdr_sum_1 = '0') then
            tcp_header_csum_1_ok <= '1';
          else
            tcp_header_csum_1_ok <= '0';
          end if;

          if (eof_reset = '1') then
            tcp_header_sum_1  <=(others => '0');
          elsif (enable_tcp_hdr_sum_1 = '1' and pack_high_1_pack_low_0 = '1') then
            if (start_of_frame_array(24) = '1') then -- mask Time to live filed from protocol in Ip header
              tcp_header_sum_1(16 downto 0)  <= ('0'&tcp_header_sum_1(15 downto 0)) + ("000000000"&rxd_packed_16bits(7 downto 0));
            elsif (start_of_frame_array(26) = '1') then -- mask IP header csum
              tcp_header_sum_1(16 downto 0)  <= ('0'&tcp_header_sum_1(15 downto 0)) + ("00000000000000000");
            else
              tcp_header_sum_1(16 downto 0)  <= ('0'&tcp_header_sum_1(15 downto 0)) + ('0'&rxd_packed_16bits(15 downto 0));
            end if;
          elsif (enable_tcp_hdr_sum_1 = '1' and pack_high_1_pack_low_0 = '0') then
            -- wrap previous carry back in
            tcp_header_sum_1(16 downto 0)  <= ('0'&tcp_header_sum_1(15 downto 0)) + (X"0000"&tcp_header_sum_1(16));
          end if;
         end if;
        end if;
      end if;
    end process;

    SAVE_TCP_LENGTH_2_PROCESS: process (RX_CLIENT_CLK) -- yes vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          save_tcp_length_2  <= (others => '0');
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(22) = '1') then
            save_tcp_length_2  <= rxd_packed_16bits - X"0014";
          elsif(eof_reset = '1') then
            save_tcp_length_2  <= (others => '0');
          end if;
         end if;
        end if;
      end if;
    end process;

    ENABLE_TCP_HEADER_SUM_2_PROCESS: process (RX_CLIENT_CLK) -- yes vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          enable_tcp_hdr_sum_2  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(27) = '1') then
            enable_tcp_hdr_sum_2  <= '1';
          elsif(start_of_frame_d1 = '0') then
            enable_tcp_hdr_sum_2  <= '0';
          end if;
         end if;
        end if;
      end if;
    end process;

    SUM_TCP_HDR_2_PROCESS: process (RX_CLIENT_CLK) -- yes vlan no snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          tcp_header_sum_2  <=(others => '0');
          tcp_header_csum_2_ok <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (eof_reset = '1') then
            tcp_header_csum_2_ok <= '0';
          elsif ((tcp_header_sum_2(15 downto 0) + save_tcp_length_2) = X"FFFF" and tcp_header_sum_2(16) = '0' and
                  enable_tcp_hdr_sum_2 = '0') then
            tcp_header_csum_2_ok <= '1';
          elsif ((tcp_header_sum_2(15 downto 0) + save_tcp_length_2) = X"FFFE" and tcp_header_sum_2(16) = '1' and
                  enable_tcp_hdr_sum_2 = '0') then
            tcp_header_csum_2_ok <= '1';
          else
            tcp_header_csum_2_ok <= '0';
          end if;

          if (eof_reset = '1') then
            tcp_header_sum_2  <=(others => '0');
          elsif (enable_tcp_hdr_sum_2 = '1' and pack_high_1_pack_low_0 = '1') then
            if (start_of_frame_array(28) = '1') then -- mask Time to live filed from protocol in Ip header
              tcp_header_sum_2(16 downto 0)  <= ('0'&tcp_header_sum_2(15 downto 0)) + ("000000000"&rxd_packed_16bits(7 downto 0));
            elsif (start_of_frame_array(30) = '1') then -- mask IP header csum
              tcp_header_sum_2(16 downto 0)  <= ('0'&tcp_header_sum_2(15 downto 0)) + ("00000000000000000");
            else
              tcp_header_sum_2(16 downto 0)  <= ('0'&tcp_header_sum_2(15 downto 0)) + ('0'&rxd_packed_16bits(15 downto 0));
            end if;
          elsif (enable_tcp_hdr_sum_2 = '1' and pack_high_1_pack_low_0 = '0') then
            -- wrap previous carry back in
            tcp_header_sum_2(16 downto 0)  <= ('0'&tcp_header_sum_2(15 downto 0)) + (X"0000"&tcp_header_sum_2(16));
          end if;
         end if;
        end if;
      end if;
    end process;

    SAVE_TCP_LENGTH_3_PROCESS: process (RX_CLIENT_CLK) -- no vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          save_tcp_length_3  <= (others => '0');
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(26) = '1') then
            save_tcp_length_3  <= rxd_packed_16bits - X"0014";
          elsif(eof_reset = '1') then
            save_tcp_length_3  <= (others => '0');
          end if;
        end if;
       end if;
      end if;
    end process;

    ENABLE_TCP_HEADER_SUM_3_PROCESS: process (RX_CLIENT_CLK) -- no vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          enable_tcp_hdr_sum_3  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(31) = '1') then
            enable_tcp_hdr_sum_3  <= '1';
          elsif(start_of_frame_d1 = '0') then
            enable_tcp_hdr_sum_3  <= '0';
          end if;
        end if;
       end if;
      end if;
    end process;

    SUM_TCP_HDR_3_PROCESS: process (RX_CLIENT_CLK) -- no vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          tcp_header_sum_3  <=(others => '0');
          tcp_header_csum_3_ok <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (eof_reset = '1') then
            tcp_header_csum_3_ok <= '0';
          elsif ((tcp_header_sum_3(15 downto 0) + save_tcp_length_3) = X"FFFF" and tcp_header_sum_3(16) = '0' and
                  enable_tcp_hdr_sum_3 = '0') then
            tcp_header_csum_3_ok <= '1';
          elsif ((tcp_header_sum_3(15 downto 0) + save_tcp_length_3) = X"FFFE" and tcp_header_sum_3(16) = '1' and
                  enable_tcp_hdr_sum_3 = '0') then
            tcp_header_csum_3_ok <= '1';
          else
            tcp_header_csum_3_ok <= '0';
          end if;

          if (eof_reset = '1') then
            tcp_header_sum_3  <=(others => '0');
          elsif (enable_tcp_hdr_sum_3 = '1' and pack_high_1_pack_low_0 = '1') then
            if (start_of_frame_array(32) = '1') then -- mask Time to live filed from protocol in Ip header
              tcp_header_sum_3(16 downto 0)  <= ('0'&tcp_header_sum_3(15 downto 0)) + ("000000000"&rxd_packed_16bits(7 downto 0));
            elsif (start_of_frame_array(34) = '1') then -- mask IP header csum
              tcp_header_sum_3(16 downto 0)  <= ('0'&tcp_header_sum_3(15 downto 0)) + ("00000000000000000");
            else
              tcp_header_sum_3(16 downto 0)  <= ('0'&tcp_header_sum_3(15 downto 0)) + ('0'&rxd_packed_16bits(15 downto 0));
            end if;
          elsif (enable_tcp_hdr_sum_3 = '1' and pack_high_1_pack_low_0 = '0') then
            -- wrap previous carry back in
            tcp_header_sum_3(16 downto 0)  <= ('0'&tcp_header_sum_3(15 downto 0)) + (X"0000"&tcp_header_sum_3(16));

          end if;
         end if;
        end if;
      end if;
    end process;

    SAVE_TCP_LENGTH_4_PROCESS: process (RX_CLIENT_CLK) -- yes vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          save_tcp_length_4  <= (others => '0');
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(30) = '1') then
            save_tcp_length_4  <= rxd_packed_16bits - X"0014";
          elsif(eof_reset = '1') then
            save_tcp_length_4  <= (others => '0');
          end if;
        end if;
       end if;
      end if;
    end process;

    ENABLE_TCP_HEADER_SUM_4_PROCESS: process (RX_CLIENT_CLK) -- yes vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          enable_tcp_hdr_sum_4  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(35) = '1') then
            enable_tcp_hdr_sum_4  <= '1';
          elsif(start_of_frame_d1 = '0') then
            enable_tcp_hdr_sum_4  <= '0';
          end if;
         end if;
        end if;
      end if;
    end process;

    SUM_TCP_HDR_4_PROCESS: process (RX_CLIENT_CLK) -- yes vlan yes snap
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          tcp_header_sum_4  <=(others => '0');
          tcp_header_csum_4_ok <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (eof_reset = '1') then
            tcp_header_csum_4_ok <= '0';
          elsif ((tcp_header_sum_4(15 downto 0) + save_tcp_length_4) = X"FFFF" and tcp_header_sum_4(16) = '0' and
                  enable_tcp_hdr_sum_4 = '0') then
            tcp_header_csum_4_ok <= '1';
          elsif ((tcp_header_sum_4(15 downto 0) + save_tcp_length_4) = X"FFFE" and tcp_header_sum_4(16) = '1' and
                  enable_tcp_hdr_sum_4 = '0') then
            tcp_header_csum_4_ok <= '1';
          else
            tcp_header_csum_4_ok <= '0';
          end if;

          if (eof_reset = '1') then
            tcp_header_sum_4  <=(others => '0');
          elsif (enable_tcp_hdr_sum_4 = '1' and pack_high_1_pack_low_0 = '1') then
            if (start_of_frame_array(36) = '1') then -- mask Time to live filed from protocol in Ip header
              tcp_header_sum_4(16 downto 0)  <= ('0'&tcp_header_sum_4(15 downto 0)) + ("000000000"&rxd_packed_16bits(7 downto 0));
            elsif (start_of_frame_array(38) = '1') then -- mask IP header csum
              tcp_header_sum_4(16 downto 0)  <= ('0'&tcp_header_sum_4(15 downto 0)) + ("00000000000000000");
            else
              tcp_header_sum_4(16 downto 0)  <= ('0'&tcp_header_sum_4(15 downto 0)) + ('0'&rxd_packed_16bits(15 downto 0));
            end if;
          elsif (enable_tcp_hdr_sum_4 = '1' and pack_high_1_pack_low_0 = '0') then
            -- wrap previous carry back in
            tcp_header_sum_4(16 downto 0)  <= ('0'&tcp_header_sum_4(15 downto 0)) + (X"0000"&tcp_header_sum_4(16));
          end if;
         end if;
        end if;
      end if;
    end process;

    CONTROL_16BIT_PACK_PROCESS: process (RX_CLIENT_CLK)
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          pack_high_1_pack_low_0  <= '0';
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (start_of_frame_array(1) = '1') then
            pack_high_1_pack_low_0  <= '1';
          else
            pack_high_1_pack_low_0  <= not(pack_high_1_pack_low_0);
          end if;
         end if;
        end if;
      end if;
    end process;

    RXD_16BIT_PACK_PROCESS: process (RX_CLIENT_CLK)
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          rxd_packed_16bits  <= (others => '0');
        else
         if (RX_CLIENT_CLK_ENBL = '1') then
          if (pack_high_1_pack_low_0 = '1' and EMAC_CLIENT_RXD_VLD_LEGACY = '1') then
            rxd_packed_16bits(15 downto 8) <= EMAC_CLIENT_RXD_LEGACY;
            rxd_packed_16bits(7 downto 0)  <= (others => '0');
          elsif (pack_high_1_pack_low_0 = '0' and EMAC_CLIENT_RXD_VLD_LEGACY = '1') then
            rxd_packed_16bits(7 downto 0)  <= EMAC_CLIENT_RXD_LEGACY;
          end if;
         end if;
        end if;
      end if;
    end process;

    -------------------------------------------------------------------------
    -- detect if the frame is a IPv4 Ethernet II frame with type 0800
    -------------------------------------------------------------------------

    DETECT_TYPE_0800 : process(RX_CLIENT_CLK)
    -- delay this check by one pipeline stage so we can detect vlan first valid by byte 22 when vlan
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_has_type_0800_d22   <= '0';
        else
          if (RX_CLIENT_CLK_ENBL = '1') then
            if (frame_is_vlan_8100_d15 = '0') then -- no vlan
              if (((rx_data_words_array(1)(7 downto 0) & rx_data_words_array(1)(15 downto 8)) = X"0800") and
                    start_of_frame_array(17) = '1') then
                      frame_has_type_0800_d22 <= '1';
              elsif (eof_reset = '1') then
                frame_has_type_0800_d22 <= '0';
              end if;
            else -- vlan
              if (((rx_data_words_array(1)(7 downto 0) & rx_data_words_array(1)(15 downto 8)) = X"0800") and
                    start_of_frame_array(21) = '1') then
                frame_has_type_0800_d22 <= '1';
              elsif (eof_reset = '1') then
                frame_has_type_0800_d22 <= '0';
              end if;
            end if;
          end if;
        end if;
      end if;
    end process;

    -------------------------------------------------------------------------
    -- detect if the frame has a valid length field
    -------------------------------------------------------------------------

    DETECT_VALID_LENGTH_FIELD : process(RX_CLIENT_CLK)
    -- delay this check by one pipeline stage so we can detect vlan first valid by byte 22 when vlan
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_has_valid_length_field_d22   <= '0';
        else
          if (RX_CLIENT_CLK_ENBL = '1') then
            if (frame_is_vlan_8100_d15 = '0') then -- no vlan
              if (((rx_data_words_array(1)(7 downto 0) & rx_data_words_array(1)(15 downto 8)) < X"0601") and
                    start_of_frame_array(17) = '1') then
                frame_has_valid_length_field_d22 <= '1';
              elsif (eof_reset = '1') then
                frame_has_valid_length_field_d22 <= '0';
              end if;
            else -- vlan
              if (((rx_data_words_array(1)(7 downto 0) & rx_data_words_array(1)(15 downto 8)) < X"0601") and
                    start_of_frame_array(21) = '1') then
                frame_has_valid_length_field_d22 <= '1';
              elsif (eof_reset = '1') then
                frame_has_valid_length_field_d22 <= '0';
              end if;
            end if;
          end if;
        end if;
      end if;
    end process;

    -------------------------------------------------------------------------
    -- detect if the frame has an IPv4 protocol field value of 4
    -------------------------------------------------------------------------

    DETECT_IP_PROTO_FIELD : process(RX_CLIENT_CLK)
    -- delay this check by pipeline stages so we can detect snap first. valid by byte 31
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_is_ip_protocol_d31   <= '0';
        else
          if (RX_CLIENT_CLK_ENBL = '1') then
            if (frame_is_vlan_8100_d15 = '0' and frame_is_snap_d30 = '0' and start_of_frame_array(30) = '1') then
            -- no vlan and no snap
              if (((rx_data_words_array(4)(23 downto 20)) = X"4")) then
                frame_is_ip_protocol_d31 <= '1';
              end if;
            elsif (frame_is_vlan_8100_d15 = '1' and frame_is_snap_d30 = '0' and start_of_frame_array(30) = '1') then
            -- yes vlan and no snap
              if (((rx_data_words_array(3)(23 downto 20)) = X"4")) then
                frame_is_ip_protocol_d31 <= '1';
              end if;
            elsif (frame_is_vlan_8100_d15 = '1' and frame_is_snap_d30 = '1' and start_of_frame_array(30) = '1') then
            -- yes vlan and yes snap
              if (((rx_data_words_array(1)(23 downto 20)) = X"4")) then
                frame_is_ip_protocol_d31 <= '1';
              end if;
            elsif (frame_is_vlan_8100_d15 = '0' and frame_is_snap_d30 = '1' and start_of_frame_array(30) = '1') then
            -- no vlan and yes snap
              if (((rx_data_words_array(2)(23 downto 20)) = X"4")) then
                frame_is_ip_protocol_d31 <= '1';
              end if;
            else
              if (eof_reset = '1') then
                frame_is_ip_protocol_d31 <= '0';
              end if;
            end if;
          end if;
        end if;
      end if;
    end process;

    -------------------------------------------------------------------------
    -- detect if the frame has an IPv4 header length field value of 5
    -------------------------------------------------------------------------

    DETECT_IP_HDR_LEN_FIELD : process(RX_CLIENT_CLK)
    -- delay this check by pipeline stages so we can detect snap first. valid by byte 31
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_has_ip_hdr_length_d31   <= '0';
        else
          if (RX_CLIENT_CLK_ENBL = '1') then
            if (frame_is_vlan_8100_d15 = '0' and frame_is_snap_d30 = '0' and start_of_frame_array(30) = '1') then
            -- no vlan and no snap
              if (((rx_data_words_array(4)(19 downto 16)) = X"5")) then
                frame_has_ip_hdr_length_d31 <= '1';
              end if;
            elsif (frame_is_vlan_8100_d15 = '1' and frame_is_snap_d30 = '0' and start_of_frame_array(30) = '1') then
            -- yes vlan and no snap
              if (((rx_data_words_array(3)(19 downto 16)) = X"5")) then
                frame_has_ip_hdr_length_d31 <= '1';
              end if;
            elsif (frame_is_vlan_8100_d15 = '1' and frame_is_snap_d30 = '1' and start_of_frame_array(30) = '1') then
            -- yes vlan and yes snap
              if (((rx_data_words_array(1)(19 downto 16)) = X"5")) then
                frame_has_ip_hdr_length_d31 <= '1';
              end if;
            elsif (frame_is_vlan_8100_d15 = '0' and frame_is_snap_d30 = '1' and start_of_frame_array(30) = '1') then
            -- no vlan and yes snap
              if (((rx_data_words_array(2)(19 downto 16)) = X"5")) then
                frame_has_ip_hdr_length_d31 <= '1';
              end if;
            else
              if (eof_reset = '1') then
                frame_has_ip_hdr_length_d31 <= '0';
              end if;
            end if;
          end if;
        end if;
      end if;
    end process;

    -------------------------------------------------------------------------
    -- detect if the frame has a IPv4 fragments
    -------------------------------------------------------------------------

    DETECT_IP_FRAGS : process(RX_CLIENT_CLK)
    -- delay this check by pipeline stages so we can detect IP protocol and IP header length first. valid by byte 38
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_has_no_ip_frags_d38   <= '0';
          frame_has_udp_protocol_d38  <= '0';
          frame_has_tcp_protocol_d38  <= '0';
        else
          if (RX_CLIENT_CLK_ENBL = '1') then
            if (frame_is_vlan_8100_d15 = '0' and frame_is_snap_d30 = '0' and frame_has_ip_hdr_length_d31= '1' and
                frame_is_ip_protocol_d31 = '1' and start_of_frame_array(32) = '1') then -- no vlan and no snap
              if (((rx_data_words_array(2)(5 downto 0)) = "000000") and ((rx_data_words_array(2)(15 downto 7)) = "000000000")) then
              -- skip bit 6 which is don't framement flag which is allowed to be set
                frame_has_no_ip_frags_d38 <= '1';
              end if;
              if (((rx_data_words_array(2)(31 downto 24)) = X"11")) then
                frame_has_udp_protocol_d38 <= '1';
                frame_has_tcp_protocol_d38 <= '0';
              end if;
              if (((rx_data_words_array(2)(31 downto 24)) = X"06")) then
                frame_has_udp_protocol_d38 <= '0';
                frame_has_tcp_protocol_d38 <= '1';
              end if;
            elsif (frame_is_vlan_8100_d15 = '1' and frame_is_snap_d30 = '0' and frame_has_ip_hdr_length_d31= '1' and
                    frame_is_ip_protocol_d31 = '1' and start_of_frame_array(32) = '1') then -- yes vlan and no snap
              if (((rx_data_words_array(1)(5 downto 0)) = "000000") and ((rx_data_words_array(1)(15 downto 7)) = "000000000")) then
              -- skip bit 6 which is don't framement flag which is allowed to be set
                frame_has_no_ip_frags_d38 <= '1';
              end if;
              if (((rx_data_words_array(1)(31 downto 24)) = X"11")) then
                frame_has_udp_protocol_d38 <= '1';
                frame_has_tcp_protocol_d38 <= '0';
              end if;
              if (((rx_data_words_array(1)(31 downto 24)) = X"06")) then
                frame_has_udp_protocol_d38 <= '0';
                frame_has_tcp_protocol_d38 <= '1';
              end if;
            elsif (frame_is_vlan_8100_d15 = '1' and frame_is_snap_d30 = '1' and frame_has_ip_hdr_length_d31= '1' and
                    frame_is_ip_protocol_d31 = '1' and start_of_frame_array(40) = '1') then -- yes vlan and yes snap
              if (((rx_data_words_array(1)(5 downto 0)) = "000000") and ((rx_data_words_array(1)(15 downto 7)) = "000000000")) then
              -- skip bit 6 which is don't framement flag which is allowed to be set
                frame_has_no_ip_frags_d38 <= '1';
              end if;
              if (((rx_data_words_array(1)(31 downto 24)) = X"11")) then
                frame_has_udp_protocol_d38 <= '1';
                frame_has_tcp_protocol_d38 <= '0';
              end if;
              if (((rx_data_words_array(1)(31 downto 24)) = X"06")) then
                frame_has_udp_protocol_d38 <= '0';
                frame_has_tcp_protocol_d38 <= '1';
              end if;
            elsif (frame_is_vlan_8100_d15 = '0' and frame_is_snap_d30 = '1' and frame_has_ip_hdr_length_d31= '1' and
                    frame_is_ip_protocol_d31 = '1' and start_of_frame_array(36) = '1') then -- no vlan and yes snap
              if (((rx_data_words_array(1)(5 downto 0)) = "000000") and ((rx_data_words_array(1)(15 downto 7)) = "000000000")) then
              -- skip bit 6 which is don't framement flag which is allowed to be set
                frame_has_no_ip_frags_d38 <= '1';
              end if;
              if (((rx_data_words_array(1)(31 downto 24)) = X"11")) then
                frame_has_udp_protocol_d38 <= '1';
                frame_has_tcp_protocol_d38 <= '0';
              end if;
              if (((rx_data_words_array(1)(31 downto 24)) = X"06")) then
                frame_has_udp_protocol_d38 <= '0';
                frame_has_tcp_protocol_d38 <= '1';
              end if;
            else
              if (eof_reset = '1') then
                frame_has_no_ip_frags_d38 <= '0';
                frame_has_udp_protocol_d38 <= '0';
                frame_has_tcp_protocol_d38 <= '0';
              end if;
            end if;
          end if;
        end if;
      end if;
    end process;

    -------------------------------------------------------------------------
    -- detect if the frame has a IPv4 Ethernet SNAP frame with type 0800
    -------------------------------------------------------------------------

    DETECT_SNAP : process(RX_CLIENT_CLK)
    -- delay this check by one pipeline stage so we can detect vlan first valid by byte 30 when vlan
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          frame_is_snap_d30   <= '0';
        else
          if (RX_CLIENT_CLK_ENBL = '1') then
            if (frame_is_vlan_8100_d15 = '0') then -- no vlan
              if ((rx_data_words_array(3)(31 downto 16) = X"AAAA") and
                   (rx_data_words_array(2)(31 downto 0) =  X"00000003") and
                   (rx_data_words_array(1)(15 downto 0) =  X"0008") and
                   start_of_frame_array(25) = '1') and (frame_has_valid_length_field_d22 = '1') then
                     frame_is_snap_d30 <= '1';
              elsif (eof_reset = '1') then
                frame_is_snap_d30 <= '0';
              end if;
            else -- vlan
              if ((rx_data_words_array(3)(31 downto 16) = X"AAAA") and
                   (rx_data_words_array(2)(31 downto 0) =  X"00000003") and
                   (rx_data_words_array(1)(15 downto 0) =  X"0008") and
                   start_of_frame_array(29) = '1') and (frame_has_valid_length_field_d22 = '1') then
                     frame_is_snap_d30 <= '1';
              elsif (eof_reset = '1') then
                frame_is_snap_d30 <= '0';
              end if;
            end if;
          end if;
        end if;
      end if;
    end process;
  end generate YES_FULL_CSUM_OFFLOAD;

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

  -------------------------------------------------------------------------
  -- pack the 8 bit wide client receive data into 32 bit wide
  -------------------------------------------------------------------------

  RX_DATA_8_TO_32_PACK : process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        rx_data_packed_word      <= (others => '0');
        rx_data_vld_packed_word  <= (others => '0');
        rx_data_packed_state     <= (others => '0');
        rx_data_packed_ready     <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (EMAC_CLIENT_RXD_VLD_LEGACY = '1') then -- word full and ready to use
            if (rx_data_packed_state = "11") then
              rx_data_packed_state <= (others => '0');
              rx_data_packed_ready <= '1';
            else
              rx_data_packed_state <= rx_data_packed_state + 1;
              rx_data_packed_ready <= '0';
            end if;
            if (rx_data_packed_state = "00") then
              rx_data_vld_packed_word(3)        <= EMAC_CLIENT_RXD_VLD_LEGACY;
              rx_data_packed_word(31 downto 24) <= EMAC_CLIENT_RXD_LEGACY;
            elsif(rx_data_packed_state = "01") then
              rx_data_vld_packed_word(3 downto 2) <= EMAC_CLIENT_RXD_VLD_LEGACY & rx_data_vld_packed_word(3);
              rx_data_packed_word(31 downto 16)   <= EMAC_CLIENT_RXD_LEGACY & rx_data_packed_word(31 downto 24);
            elsif(rx_data_packed_state = "10") then
              rx_data_vld_packed_word(3 downto 1) <= EMAC_CLIENT_RXD_VLD_LEGACY & rx_data_vld_packed_word(3 downto 2);
              rx_data_packed_word(31 downto 8)    <= EMAC_CLIENT_RXD_LEGACY     & rx_data_packed_word(31 downto 16);
            elsif(rx_data_packed_state = "11") then
              rx_data_vld_packed_word(3 downto 0) <= EMAC_CLIENT_RXD_VLD_LEGACY & rx_data_vld_packed_word(3 downto 1);
              rx_data_packed_word(31 downto 0)    <= EMAC_CLIENT_RXD_LEGACY     & rx_data_packed_word(31 downto 8);
            end if;
          elsif (EMAC_CLIENT_RXD_VLD_LEGACY = '0' and rx_data_valid_array(1)(0) = '1') then
            if(rx_data_packed_state = "01") then
              rx_data_vld_packed_word(3 downto 0) <= "000" & rx_data_vld_packed_word(3);
              rx_data_packed_word(31 downto 0)    <= "000000000000000000000000" & rx_data_packed_word(31 downto 24);
              rx_data_packed_ready <= '1';
              rx_data_packed_state     <= (others => '0');
            elsif(rx_data_packed_state = "10") then
              rx_data_vld_packed_word(3 downto 0) <= "00" & rx_data_vld_packed_word(3 downto 2);
              rx_data_packed_word(31 downto 0)    <= "0000000000000000" & rx_data_packed_word(31 downto 16);
              rx_data_packed_ready <= '1';
              rx_data_packed_state     <= (others => '0');
            elsif(rx_data_packed_state = "11") then
              rx_data_vld_packed_word(3 downto 0) <= '0' & rx_data_vld_packed_word(3 downto 1);
              rx_data_packed_word(31 downto 0)    <= "00000000" & rx_data_packed_word(31 downto 8);
              rx_data_packed_ready <= '1';
              rx_data_packed_state     <= (others => '0');
            else
              rx_data_packed_word      <= (others => '0');
              rx_data_vld_packed_word  <= (others => '0');
              rx_data_packed_state     <= (others => '0');
              rx_data_packed_ready     <= '0';
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- calculate the partial checksum or not
  -------------------------------------------------------------------------

  INCLUDE_RX_CSUM: if(C_RXCSUM = 1) generate
    signal emacClientRxdLegacy_d1    : std_logic_vector(7 downto 0);
    signal rxd16bits                 : std_logic_vector(15 downto 0);
    signal emacClientRxdVldLegacy_d1 : std_logic;
    signal emacClientRxdVldWord      : std_logic;
  begin
    process(RX_CLIENT_CLK)
      begin
        if(rising_edge(RX_CLIENT_CLK)) then
          if(RESET2RX_CLIENT='1') then
            emacClientRxdLegacy_d1   <= (others => '0');
            emacClientRxdVldWord<= '0';
          else
            if(RX_CLIENT_CLK_ENBL='1') then
              emacClientRxdLegacy_d1   <= EMAC_CLIENT_RXD_LEGACY;
              emacClientRxdVldLegacy_d1<= EMAC_CLIENT_RXD_VLD_LEGACY;
              if (EMAC_CLIENT_RXD_VLD_LEGACY = '1' or emacClientRxdVldLegacy_d1 = '1') then
                emacClientRxdVldWord <= NOT(emacClientRxdVldWord);
              else
                emacClientRxdVldWord<= '0';
              end if;
            end if;
          end if;
        end if;
    end process;

    rxd16bits <= emacClientRxdLegacy_d1 & EMAC_CLIENT_RXD_LEGACY when EMAC_CLIENT_RXD_VLD_LEGACY = '1' else
                 emacClientRxdLegacy_d1 & X"00";

    I_RX_CSUM : entity axi_ethernet_v3_01_a.rx_csum_if
      port map(
        CLK       => RX_CLIENT_CLK,
        CLK_ENBL  => RX_CLIENT_CLK_ENBL,
        RST       => RESET2RX_CLIENT,
        INTRFRMRST=> eof_reset,
        CALC_ENBL => emacClientRxdVldLegacy_d1,
        WORD_ENBL => emacClientRxdVldWord,
        DATA_IN   => rxd16bits,
        CSUM_VLD  => rxCsumVld,
        CSUM      => rxCsum
        );
  end generate INCLUDE_RX_CSUM;

  EXCLUDE_RX_CSUM: if (not (C_RXCSUM = 1)) generate
  begin
    rxCsum <= (others => '0');
  end generate EXCLUDE_RX_CSUM;

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
          if (eof_reset = '1') then -- clear at end of frame
            raw_checksum <= (others => '0');
          elsif (rxCsumVld = '1') then
            raw_checksum <= rxCsum;
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- capture the statistics which is different for soft and hard TEMAC
  -------------------------------------------------------------------------

--  SOFT_STATS: if((C_TYPE = 0) or (C_TYPE = 1)) generate
--  begin
    frame_drop <= (EMAC_CLIENT_RX_STATS_VLD and not (rx_statistics_vector(27)));

    CAPTURE_STATS : process (RX_CLIENT_CLK)
    begin
      if rising_edge(RX_CLIENT_CLK) then
        if RESET2RX_CLIENT = '1' then
          statistics_vector <= (others => '0');
        else
          if (RX_CLIENT_CLK_ENBL = '1') then
            if (EMAC_CLIENT_RX_STATS_VLD = '1') then
              statistics_vector(25 downto 22) <= rx_statistics_vector(26 downto 23);
              statistics_vector(21 downto 0) <= rx_statistics_vector(21 downto 0);
            end if;
          end if;
        end if;
      end if;
    end process;
--  end generate SOFT_STATS;

--  HARD_STATS: if(C_TYPE = 2) generate
--    signal emac_client_rx_stats_vld_d1  : std_logic;
--    signal emac_client_rx_stats_vld_d2  : std_logic;
--    signal emac_client_rx_stats_vld_d3  : std_logic;
--    signal emac_client_rx_stats_vld_d4  : std_logic;
--  begin
--
--    PIPE_STATS_VALID: process (RX_CLIENT_CLK)
--    begin
--      if rising_edge(RX_CLIENT_CLK) then
--        if (RESET2RX_CLIENT = '1') then
--          emac_client_rx_stats_vld_d1 <= '0';
--          emac_client_rx_stats_vld_d2 <= '0';
--          emac_client_rx_stats_vld_d3 <= '0';
--          emac_client_rx_stats_vld_d4 <= '0';
--        else
--          if (RX_CLIENT_CLK_ENBL = '1') then
--            emac_client_rx_stats_vld_d1 <= EMAC_CLIENT_RX_STATS_VLD;
--            emac_client_rx_stats_vld_d2 <= emac_client_rx_stats_vld_d1;
--            emac_client_rx_stats_vld_d3 <= emac_client_rx_stats_vld_d2;
--            emac_client_rx_stats_vld_d4 <= emac_client_rx_stats_vld_d3;
--          end if;
--        end if;
--      end if;
--    end process;
--
--    STATS_DEMUX: process (RX_CLIENT_CLK)
--    begin
--      if rising_edge(RX_CLIENT_CLK) then
--        if (RESET2RX_CLIENT = '1') then
--          statistics_vector(6 downto 0) <= (others => '0');
--        else
--          if (RX_CLIENT_CLK_ENBL = '1') then
--            if (EMAC_CLIENT_RX_STATS_VLD = '1' and emac_client_rx_stats_vld_d1 = '0') then
--              statistics_vector(6 downto 0) <= EMAC_CLIENT_RX_STATS;
--            end if;
--          end if;
--        end if;
--      end if;
--
--      if rising_edge(RX_CLIENT_CLK) then
--        if (RESET2RX_CLIENT = '1') then
--          statistics_vector(13 downto 7) <= (others => '0');
--        else
--          if (RX_CLIENT_CLK_ENBL = '1') then
--            if (emac_client_rx_stats_vld_d1 = '1' and emac_client_rx_stats_vld_d2 = '0') then
--              statistics_vector(13 downto 7) <= EMAC_CLIENT_RX_STATS;
--            end if;
--          end if;
--        end if;
--      end if;
--
--      if rising_edge(RX_CLIENT_CLK) then
--        if (RESET2RX_CLIENT = '1') then
--          statistics_vector(20 downto 14) <= (others => '0');
--        else
--          if (RX_CLIENT_CLK_ENBL = '1') then
--            if (emac_client_rx_stats_vld_d2 = '1' and emac_client_rx_stats_vld_d3 = '0') then
--              statistics_vector(20 downto 14) <= EMAC_CLIENT_RX_STATS;
--            end if;
--          end if;
--        end if;
--      end if;
--
--      if rising_edge(RX_CLIENT_CLK) then
--        if (RESET2RX_CLIENT = '1') then
--          statistics_vector(25 downto 21) <= (others => '0');
--        else
--          if (RX_CLIENT_CLK_ENBL = '1') then
--            if (emac_client_rx_stats_vld_d3 = '1' and emac_client_rx_stats_vld_d4 = '0') then
--              statistics_vector(25 downto 22) <= EMAC_CLIENT_RX_STATS(5 downto 2);
--              statistics_vector(21) <= EMAC_CLIENT_RX_STATS(0);
--            end if;
--          end if;
--        end if;
--      end if;
--    end process;
--  end generate HARD_STATS;

  -------------------------------------------------------------------------
  -- count the number of bytes in the frame being received for 8 bit interface
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
          elsif (EMAC_CLIENT_RXD_VLD_LEGACY = '1') then
            frame_length_bytes <= frame_length_bytes + 1;
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
          end_of_frame_array (1)      <= start_of_frame_d1 and not(EMAC_CLIENT_RXD_VLD_LEGACY);
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

  PIPE_RX_INPUTS_100_12 : process (RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        start_of_frame_d1     <= '0';
        start_of_frame_array  <= (others => '0');
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          start_of_frame_d1           <= EMAC_CLIENT_RXD_VLD_LEGACY;
          start_of_frame_array (1)    <= EMAC_CLIENT_RXD_VLD_LEGACY and not(start_of_frame_d1);
          for i in 1 to 51 loop
            start_of_frame_array (i+1)   <= start_of_frame_array (i);
          end loop;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- detect if the destination address is broadcast
  -------------------------------------------------------------------------

  DETECT_BROADCAST : process(RX_CLIENT_CLK) -- valid by byte 10
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        frame_is_broadcast_d10   <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (rx_data_words_array(1)(15 downto 0)  = X"FFFF" and
              rx_data_words_array(2)(31 downto 0) = X"FFFFFFFF" and
              start_of_frame_array(9) = '1') then
                frame_is_broadcast_d10 <= '1';
          elsif (eof_reset = '1') then
            frame_is_broadcast_d10 <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- detect if the destination address is IP multicast
  -------------------------------------------------------------------------

  DETECT_IP_MULTICAST : process(RX_CLIENT_CLK) -- valid by byte 4
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        frame_is_ip_multicast_d4   <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (rx_data_packed_word(31 downto 24) = X"5E" and
              rx_data_packed_word(23 downto 16) = X"00" and
              rx_data_packed_word(15 downto 8)  = X"01" and
              start_of_frame_array(3) = '1') then
                frame_is_ip_multicast_d4 <= '1';
          elsif (eof_reset = '1') then
            frame_is_ip_multicast_d4 <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- detect if the destination address is any multicast
  -------------------------------------------------------------------------

  DETECT_MULTICAST : process(RX_CLIENT_CLK) -- valid by byte 10
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        frame_is_multicast_d10   <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (rx_data_words_array(2)(0) = '1' and
              not((rx_data_words_array(1)(15 downto 0)  = X"FFFF")and
                  (rx_data_words_array(2)(31 downto 0) = X"FFFFFFFF"))and
              start_of_frame_array(9) = '1') then
                frame_is_multicast_d10 <= '1';
          elsif (eof_reset = '1') then
            frame_is_multicast_d10 <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

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
          if (start_of_frame_array(9) = '1') then
            multicast_addr_upper_d10 <= rx_data_words_array(1)(15 downto 0);
            multicast_addr_lower_d10 <= rx_data_words_array(2)(31 downto 0);
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
          if (start_of_frame_array(18) = '1') then
            bytes_12_and_13_d19 <= rx_data_words_array(1)(15 downto 0);
            bytes_14_and_15_d19 <= rx_data_words_array(1)(31 downto 16);
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- detect if the frame is a VLAN with type 8100
  -------------------------------------------------------------------------

  DETECT_VLAN_8100 : process(RX_CLIENT_CLK) -- valid by byte 15
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        frame_is_vlan_8100_d15   <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (((rx_data_packed_word(23 downto 16) & rx_data_packed_word(31 downto 24)) = X"8100") and
              start_of_frame_array(14) = '1') then
                frame_is_vlan_8100_d15 <= '1';
          elsif (eof_reset = '1') then
            frame_is_vlan_8100_d15 <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- detect if the frame has a first VLAN tag with type TPID 0
  -------------------------------------------------------------------------

  DETECT_FIRST_VLAN_TAG_TPID_0 : process(RX_CLIENT_CLK) -- valid by byte 15
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        first_tag_is_vlan_TPID_0_d15   <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (((rx_data_packed_word(23 downto 16) & rx_data_packed_word(31 downto 24)) = RX_CL_CLK_TPID0_REG_DATA(16 to 31)) and
              start_of_frame_array(14) = '1') then
                first_tag_is_vlan_TPID_0_d15 <= '1';
          elsif (eof_reset = '1') then
            first_tag_is_vlan_TPID_0_d15 <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- detect if the frame has a first VLAN tag with type TPID 1
  -------------------------------------------------------------------------

  DETECT_FIRST_VLAN_TAG_TPID_1 : process(RX_CLIENT_CLK) -- valid by byte 15
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        first_tag_is_vlan_TPID_1_d15   <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (((rx_data_packed_word(23 downto 16) & rx_data_packed_word(31 downto 24)) = RX_CL_CLK_TPID0_REG_DATA(0 to 15)) and
              start_of_frame_array(14) = '1') then
                first_tag_is_vlan_TPID_1_d15 <= '1';
          elsif (eof_reset = '1') then
            first_tag_is_vlan_TPID_1_d15 <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- detect if the frame has a first VLAN tag with type TPID 2
  -------------------------------------------------------------------------

  DETECT_FIRST_VLAN_TAG_TPID_2 : process(RX_CLIENT_CLK) -- valid by byte 15
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        first_tag_is_vlan_TPID_2_d15   <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (((rx_data_packed_word(23 downto 16) & rx_data_packed_word(31 downto 24)) = RX_CL_CLK_TPID1_REG_DATA(16 to 31)) and
              start_of_frame_array(14) = '1') then
                first_tag_is_vlan_TPID_2_d15 <= '1';
          elsif (eof_reset = '1') then
            first_tag_is_vlan_TPID_2_d15 <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- detect if the frame has a first VLAN tag with type TPID 3
  -------------------------------------------------------------------------

  DETECT_FIRST_VLAN_TAG_TPID_3 : process(RX_CLIENT_CLK) -- valid by byte 15
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        first_tag_is_vlan_TPID_3_d15   <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (((rx_data_packed_word(23 downto 16) & rx_data_packed_word(31 downto 24)) = RX_CL_CLK_TPID1_REG_DATA(0 to 15)) and
              start_of_frame_array(14) = '1') then
                first_tag_is_vlan_TPID_3_d15 <= '1';
          elsif (eof_reset = '1') then
            first_tag_is_vlan_TPID_3_d15 <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- detect if the frame has a second VLAN tag with type TPID 0
  -------------------------------------------------------------------------

  DETECT_SECOND_VLAN_TAG_TPID_0 : process(RX_CLIENT_CLK) -- valid by byte 19
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        second_tag_is_vlan_TPID_0_d19   <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (((rx_data_packed_word(23 downto 16) & rx_data_packed_word(31 downto 24)) = RX_CL_CLK_TPID0_REG_DATA(16 to 31)) and
              start_of_frame_array(18) = '1') then
                second_tag_is_vlan_TPID_0_d19 <= '1';
          elsif (eof_reset = '1') then
            second_tag_is_vlan_TPID_0_d19 <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- detect if the frame has a second VLAN tag with type TPID 1
  -------------------------------------------------------------------------

  DETECT_SECOND_VLAN_TAG_TPID_1 : process(RX_CLIENT_CLK) -- valid by byte 19
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        second_tag_is_vlan_TPID_1_d19   <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (((rx_data_packed_word(23 downto 16) & rx_data_packed_word(31 downto 24)) = RX_CL_CLK_TPID0_REG_DATA(0 to 15)) and
              start_of_frame_array(18) = '1') then
                second_tag_is_vlan_TPID_1_d19 <= '1';
          elsif (eof_reset = '1') then
            second_tag_is_vlan_TPID_1_d19 <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- detect if the frame has a second VLAN tag with type TPID 2
  -------------------------------------------------------------------------

  DETECT_SECOND_VLAN_TAG_TPID_2 : process(RX_CLIENT_CLK) -- valid by byte 19
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        second_tag_is_vlan_TPID_2_d19   <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (((rx_data_packed_word(23 downto 16) & rx_data_packed_word(31 downto 24)) = RX_CL_CLK_TPID1_REG_DATA(16 to 31)) and
              start_of_frame_array(18) = '1') then
                second_tag_is_vlan_TPID_2_d19 <= '1';
          elsif (eof_reset = '1') then
            second_tag_is_vlan_TPID_2_d19 <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- detect if the frame has a second VLAN tag with type TPID 3
  -------------------------------------------------------------------------

  DETECT_SECOND_VLAN_TAG_TPID_3 : process(RX_CLIENT_CLK) -- valid by byte 19
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        second_tag_is_vlan_TPID_3_d19   <= '0';
      else
        if (RX_CLIENT_CLK_ENBL = '1') then
          if (((rx_data_packed_word(23 downto 16) & rx_data_packed_word(31 downto 24)) = RX_CL_CLK_TPID1_REG_DATA(0 to 15)) and
              start_of_frame_array(18) = '1') then
                second_tag_is_vlan_TPID_3_d19 <= '1';
          elsif (eof_reset = '1') then
            second_tag_is_vlan_TPID_3_d19 <= '0';
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
          if (rxd_addr_cntr_en = '1' and rx_data_packed_ready = '1') then
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

  RX_CLIENT_RXD_DPMEM_WR_EN(0) <=
    rx_data_packed_ready when receive_frame_current_state = RECEIVING_FRAME else
    '0';

  RX_CLIENT_RXD_DPMEM_ADDR(C_RXD_MEM_ADDR_WIDTH downto 0) <= rxd_mem_addr_cntr;

  RX_CLIENT_RXD_DPMEM_WR_DATA(35 downto 0) <= rx_data_vld_packed_word & rx_data_packed_word;

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
    RX_CL_CLK_BRDCAST_REJ,
    RX_CL_CLK_MULCAST_REJ,
    frame_is_broadcast_d10,
    frame_is_multicast_d10,
    saveExtendedMulticastReject,
    extendedMulticastReject,
    rxd_mem_empty_mask,
    rxd_mem_full_mask,
    rxs_mem_four_mask,
    rxs_mem_full_mask,
    rxclclk_rxd_mem_last_read_out_ptr_d1,
    rxclclk_rxs_mem_last_read_out_ptr_d1,
    RX_CLIENT_RXS_DPMEM_RD_DATA,
    frame_length_bytes,
    RX_CL_CLK_BAD_FRAME_ENBL
    )
  begin

    rxd_addr_cntr_en              <= '0';
    rxs_addr_cntr_en              <= '0';
    rxd_addr_cntr_load            <= '0';
    rxs_addr_cntr_load            <= '0';
    RX_FRAME_RECEIVED_INTRPT      <= '0';
    RX_FRAME_REJECTED_INTRPT      <= '0';
    RX_BUFFER_MEM_OVERFLOW_INTRPT <= '0';

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
          RX_BUFFER_MEM_OVERFLOW_INTRPT  <= '1';
        elsif (end_of_frame_array (1) = '0') then
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
          RX_BUFFER_MEM_OVERFLOW_INTRPT  <= '1';
        elsif ((save_rx_goodframe = '1') or (save_rx_badframe = '1' and RX_CL_CLK_BAD_FRAME_ENBL = '1'))  then
          if ((frame_is_broadcast_d10 = '1' and RX_CL_CLK_BRDCAST_REJ = '1') or
              (frame_is_multicast_d10 = '1' and RX_CL_CLK_MULCAST_REJ = '1') or
              (saveExtendedMulticastReject = '1'))then
            receive_frame_next_state       <= WAIT_FOR_START_OF_FRAME;
            RX_FRAME_REJECTED_INTRPT       <= '1';
          else
            rxd_mem_next_available4write_ptr_cmb <= rxd_mem_addr_cntr;
            receive_frame_next_state       <= UPDATE_STATUS_FIFO_WORD_1;
            RX_FRAME_RECEIVED_INTRPT       <= '1';
          end if;
        elsif (save_rx_badframe = '1') then
          receive_frame_next_state       <= WAIT_FOR_START_OF_FRAME;
          RX_FRAME_REJECTED_INTRPT       <= '1';
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

  -------------------------------------------------------------------------
  -- check enhanced multicast address filtering or not
  -------------------------------------------------------------------------

  EXTENDED_MULTICAST: if(C_MCAST_EXTEND = 1) generate

    type EMCFLTRSM_TYPE is (
      WAIT_FRAME_START,
      GET_SECOND_BYTE,
      GET_THIRD_BYTE,
      GET_FORTH_BYTE,
      GET_FIFTH_BYTE,
      READ_TABLE_ENTRY,
      READ_TABLE_ENTRY2,
      GET_UNI_ADDRESS,
      CHECK_UNI_ADDRESS,
      GET_BRDCAST_ADDRESS,
      CHECK_BRDCAST_ADDRESS,
      ACCEPT_AND_WAIT_TILL_END,
      REJECT_AND_WAIT_TILL_END
    );

    signal eMcFltrSM_Cs           : EMCFLTRSM_TYPE;
    signal eMcFltrSM_Ns           : EMCFLTRSM_TYPE;
    signal tempDestAddr           : std_logic_vector(0 to 47);
    signal unicastMatch           : std_logic;
    signal broadcastMatch         : std_logic;
    signal emacClientRxdLegacy_d1 : std_logic_vector(7 downto 0);

    signal rxClClkMcastEn_i        : std_logic;
    signal rxClClkMcastAddr_i      : std_logic_vector(0 to 14);
    signal rxClClkMcastAddr_i_d    : std_logic_vector(0 to 14);
    signal rx_cl_clk_mcast_rd_data_d1 : std_logic;

  begin

  RX_CL_CLK_MCAST_EN   <= rxClClkMcastEn_i;
  RX_CL_CLK_MCAST_ADDR <= rxClClkMcastAddr_i;

    process(RX_CLIENT_CLK)
      begin
        if(rising_edge(RX_CLIENT_CLK)) then
          if(RESET2RX_CLIENT='1') then
            emacClientRxdLegacy_d1     <= (others => '0');
            rx_cl_clk_mcast_rd_data_d1 <= '0';
          else
            rx_cl_clk_mcast_rd_data_d1 <= RX_CL_CLK_MCAST_RD_DATA(0);
            if(RX_CLIENT_CLK_ENBL='1') then
              emacClientRxdLegacy_d1   <= EMAC_CLIENT_RXD_LEGACY;
            end if;
          end if;
        end if;
    end process;

    COMPARE_UNICAST_ADDR_PROCESS: process (RX_CLIENT_CLK)
    begin
      if (RX_CLIENT_CLK'event and RX_CLIENT_CLK = '1') then
        if (RESET2RX_CLIENT = '1') then
          unicastMatch <= '0';
        else
          if (tempDestAddr(0 to 7)   = RX_CL_CLK_UAWL_REG_DATA(24 to 31) and
              tempDestAddr(8 to 15)  = RX_CL_CLK_UAWL_REG_DATA(16 to 23) and
              tempDestAddr(16 to 23) = RX_CL_CLK_UAWL_REG_DATA(8 to 15) and
              tempDestAddr(24 to 31) = RX_CL_CLK_UAWL_REG_DATA(0 to 7) and
              tempDestAddr(32 to 39) = RX_CL_CLK_UAWU_REG_DATA(24 to 31) and
              tempDestAddr(40 to 47) = RX_CL_CLK_UAWU_REG_DATA(16 to 23))then
            unicastMatch <= '1';
          else
            unicastMatch <= '0';
          end if;
        end if;
      end if;
    end process;

    COMPARE_BROADCAST_ADDR_PROCESS: process (RX_CLIENT_CLK)
    begin
      if (RX_CLIENT_CLK'event and RX_CLIENT_CLK = '1') then
        if (RESET2RX_CLIENT = '1') then
          broadcastMatch <= '0';
        else
          if (tempDestAddr=x"ffffffffffff") then
            broadcastMatch <= '1';
          else
            broadcastMatch <= '0';
          end if;
        end if;
      end if;
    end process;

    CAPTURE_TEMPDESTADDR_PROCESS: process (RX_CLIENT_CLK)
    begin
      if (RX_CLIENT_CLK'event and RX_CLIENT_CLK = '1') then
        if (RESET2RX_CLIENT = '1') then
          tempDestAddr    <= (others => '0');
        else
          if (RX_CLIENT_CLK_ENBL = '1') then
            if (start_of_frame_array (1) = '1') then
              tempDestAddr(0 to 7)   <= emacClientRxdLegacy_d1(7 downto 0);
              tempDestAddr(8 to 47)  <= (others => '0');
            elsif (start_of_frame_array (2) = '1') then
              tempDestAddr(0 to 7)   <= tempDestAddr(0 to 7);
              tempDestAddr(8 to 15)  <= emacClientRxdLegacy_d1(7 downto 0);
              tempDestAddr(16 to 47) <= (others => '0');
            elsif (start_of_frame_array (3) = '1') then
              tempDestAddr(0 to 15)  <= tempDestAddr(0 to 15);
              tempDestAddr(16 to 23) <= emacClientRxdLegacy_d1(7 downto 0);
              tempDestAddr(24 to 47) <= (others => '0');
            elsif (start_of_frame_array (4) = '1') then
              tempDestAddr(0 to 23)  <= tempDestAddr(0 to 23);
              tempDestAddr(24 to 31) <= emacClientRxdLegacy_d1(7 downto 0);
              tempDestAddr(32 to 47) <= (others => '0');
            elsif (start_of_frame_array (5) = '1') then
              tempDestAddr(0 to 31)  <= tempDestAddr(0 to 31);
              tempDestAddr(32 to 39) <= emacClientRxdLegacy_d1(7 downto 0);
              tempDestAddr(40 to 47) <= (others => '0');
            elsif (start_of_frame_array (6) = '1') then
              tempDestAddr(0 to 39)  <= tempDestAddr(0 to 39);
              tempDestAddr(40 to 47) <= emacClientRxdLegacy_d1(7 downto 0);
            else
              tempDestAddr(0 to 47)  <= tempDestAddr(0 to 47);
            end if;
          end if;
        end if;
      end if;
    end process;

  -------------------------------------------------------------------------
  -- save the indication that we had an extended multicast reject
  -------------------------------------------------------------------------

  SAVE_EXTENDED_MULTICAST_REJECT : process(RX_CLIENT_CLK)
  begin
    if rising_edge(RX_CLIENT_CLK) then
      if RESET2RX_CLIENT = '1' then
        saveExtendedMulticastReject   <= '0';
      else
        if (eof_reset = '1') then
          saveExtendedMulticastReject <= '0';
        elsif (extendedMulticastReject = '1') then
              saveExtendedMulticastReject <= '1';
        end if;
      end if;
    end if;
  end process;

    EMCFLTRSM_REGS_PROCESS: process (RX_CLIENT_CLK )
    begin
      if (RX_CLIENT_CLK'event and RX_CLIENT_CLK = '1') then
        if (RESET2RX_CLIENT = '1') then
          eMcFltrSM_Cs     <= WAIT_FRAME_START;
          rxClClkMcastAddr_i_d <= (others => '0');
        else
          if (RX_CLIENT_CLK_ENBL = '1') then
            eMcFltrSM_Cs <= eMcFltrSM_Ns;
            rxClClkMcastAddr_i_d <= rxClClkMcastAddr_i;
          end if;
        end if;
      end if;
    end process;

    EMCFLTRSM_CMB_PROCESS: process (
       eMcFltrSM_Cs,
       start_of_frame_array (1),
       end_of_frame_array (1),
       RX_CL_CLK_NEW_FNC_ENBL,
       RX_CL_CLK_EMULTI_FLTR_ENBL,
       emacClientRxdLegacy_d1,
       RX_CL_CLK_MCAST_RD_DATA,
       rx_cl_clk_mcast_rd_data_d1,
       tempDestAddr,
       RX_CL_CLK_UAWL_REG_DATA,
       RX_CL_CLK_UAWU_REG_DATA,
       start_of_frame_array (8),
       unicastMatch,
       rxClClkMcastAddr_i_d,
       rxClClkMcastAddr_i,
       broadcastMatch,
       eof_reset
     )
    begin

      extendedMulticastReject   <= '0';
      rxClClkMcastEn_i          <= '0';
      rxClClkMcastAddr_i        <= rxClClkMcastAddr_i_d;

      case eMcFltrSM_Cs is

        when WAIT_FRAME_START =>
          rxClClkMcastAddr_i <= (others => '0');
          if (RX_CL_CLK_NEW_FNC_ENBL = '1' and RX_CL_CLK_EMULTI_FLTR_ENBL = '1') then
            if (start_of_frame_array (1) = '1')then
              if (emacClientRxdLegacy_d1=X"01")then
                eMcFltrSM_Ns <= GET_SECOND_BYTE; -- looks like IP generated multicast so far
              elsif (emacClientRxdLegacy_d1(0)='0')then
                eMcFltrSM_Ns <= GET_UNI_ADDRESS; -- it's a unicast address that we need to compare
              elsif (emacClientRxdLegacy_d1=X"FF")then
                eMcFltrSM_Ns <= GET_BRDCAST_ADDRESS; -- looks like broadcast so far
              else
                eMcFltrSM_Ns <= REJECT_AND_WAIT_TILL_END; -- must be multicast but non-IP generated
                extendedMulticastReject <= '1';
              end if;
            else
              eMcFltrSM_Ns <= WAIT_FRAME_START; -- a new frame hasn't started yet
            end if;
          else
            eMcFltrSM_Ns <= WAIT_FRAME_START; -- extended multicast filtering not enabled
          end if;

        when GET_SECOND_BYTE =>
          if (emacClientRxdLegacy_d1=X"00")then
            eMcFltrSM_Ns <= GET_THIRD_BYTE; -- still looks like IP generated multicast so far
          else
            eMcFltrSM_Ns <= REJECT_AND_WAIT_TILL_END; -- must be multicast but non-IP generated
            extendedMulticastReject <= '1';
          end if;

        when GET_THIRD_BYTE =>
          if (emacClientRxdLegacy_d1=X"5e")then
            eMcFltrSM_Ns <= GET_FORTH_BYTE; -- it is an IP generated multicast so let get the rest and look it up
          else
            eMcFltrSM_Ns <= REJECT_AND_WAIT_TILL_END; -- must be multicast but non-IP generated
            extendedMulticastReject <= '1';
          end if;

        when GET_FORTH_BYTE =>
          rxClClkMcastAddr_i(0 to 6) <= emacClientRxdLegacy_d1(6 downto 0);
          eMcFltrSM_Ns <= GET_FIFTH_BYTE;

        when GET_FIFTH_BYTE =>
          rxClClkMcastAddr_i(7 to 14) <= emacClientRxdLegacy_d1(7 downto 0);
          rxClClkMcastEn_i            <= '1';
          eMcFltrSM_Ns <= READ_TABLE_ENTRY;

        when READ_TABLE_ENTRY =>
          --rxClClkMcastAddr_i(7 to 14) <= emacClientRxdLegacy_d1(7 downto 0);
          rxClClkMcastEn_i            <= '1';
          eMcFltrSM_Ns <= READ_TABLE_ENTRY2;

        when READ_TABLE_ENTRY2 =>
          rxClClkMcastEn_i            <= '1';
          if (rx_cl_clk_mcast_rd_data_d1 ='0')then
            eMcFltrSM_Ns <= REJECT_AND_WAIT_TILL_END;
            extendedMulticastReject  <= '1';
          else
            eMcFltrSM_Ns <= ACCEPT_AND_WAIT_TILL_END;
          end if;

        when GET_UNI_ADDRESS =>
          if (start_of_frame_array (8)='1')then
            eMcFltrSM_Ns <= CHECK_UNI_ADDRESS;
          else
            eMcFltrSM_Ns <= GET_UNI_ADDRESS;
          end if;

        when GET_BRDCAST_ADDRESS =>
          if (start_of_frame_array (8)='1')then
            eMcFltrSM_Ns <= CHECK_BRDCAST_ADDRESS;
          else
            eMcFltrSM_Ns <= GET_BRDCAST_ADDRESS;
          end if;

        when CHECK_BRDCAST_ADDRESS =>
          if (broadcastMatch='1')then
            eMcFltrSM_Ns <= ACCEPT_AND_WAIT_TILL_END;
          else
            eMcFltrSM_Ns <= REJECT_AND_WAIT_TILL_END;
            extendedMulticastReject  <= '1';
          end if;

        when CHECK_UNI_ADDRESS =>
          if (unicastMatch = '1')then
            eMcFltrSM_Ns <= ACCEPT_AND_WAIT_TILL_END;
          else
            eMcFltrSM_Ns <= REJECT_AND_WAIT_TILL_END;
            extendedMulticastReject  <= '1';
          end if;

        when REJECT_AND_WAIT_TILL_END =>
          if (eof_reset = '1' )then
            eMcFltrSM_Ns <= WAIT_FRAME_START;
            extendedMulticastReject  <= '0';
          else
            eMcFltrSM_Ns <= REJECT_AND_WAIT_TILL_END;
            extendedMulticastReject  <= '1';
          end if;

        when ACCEPT_AND_WAIT_TILL_END =>
          extendedMulticastReject  <= '0';
          if (eof_reset = '1' )then
            eMcFltrSM_Ns <= WAIT_FRAME_START;
          else
            eMcFltrSM_Ns <= ACCEPT_AND_WAIT_TILL_END;
          end if;

        when others   =>
          eMcFltrSM_Ns <= WAIT_FRAME_START;
      end case;
    end process;


  end generate EXTENDED_MULTICAST;

  NO_EXTENDED_MULTICAST: if(C_MCAST_EXTEND = 0) generate
  begin
    extendedMulticastReject <= '0';
    RX_CL_CLK_MCAST_ADDR    <= (others => '0');
    RX_CL_CLK_MCAST_EN      <= '0';
  end generate NO_EXTENDED_MULTICAST;

end rtl;
