-------------------------------------------------------------------------------
--  AXI Lite IP Interface (IPIF) - entity/architecture pair
-------------------------------------------------------------------------------
--
-- ************************************************************************
-- ** DISCLAIMER OF LIABILITY                                            **
-- **                                                                    **
-- ** This file contains proprietary and confidential information of     **
-- ** Xilinx, Inc. ("Xilinx"), that is distributed under a license       **
-- ** from Xilinx, and may be used, copied and/or disclosed only         **
-- ** pursuant to the terms of a valid license agreement with Xilinx.    **
-- **                                                                    **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION              **
-- ** ("MATERIALS") "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER         **
-- ** EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING WITHOUT                **
-- ** LIMITATION, ANY WARRANTY WITH RESPECT TO NONINFRINGEMENT,          **
-- ** MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE. Xilinx      **
-- ** does not warrant that functions included in the Materials will     **
-- ** meet the requirements of Licensee, or that the operation of the    **
-- ** Materials will be uninterrupted or error-free, or that defects     **
-- ** in the Materials will be corrected. Furthermore, Xilinx does       **
-- ** not warrant or make any representations regarding use, or the      **
-- ** results of the use, of the Materials in terms of correctness,      **
-- ** accuracy, reliability or otherwise.                                **
-- **                                                                    **
-- ** Xilinx products are not designed or intended to be fail-safe,      **
-- ** or for use in any application requiring fail-safe performance,     **
-- ** such as life-support or safety devices or systems, Class III       **
-- ** medical devices, nuclear facilities, applications related to       **
-- ** the deployment of airbags, or any other applications that could    **
-- ** lead to death, personal injury or severe property or               **
-- ** environmental damage (individually and collectively, "critical     **
-- ** applications"). Customer assumes the sole risk and liability       **
-- ** of any use of Xilinx products in critical applications,            **
-- ** subject only to applicable laws and regulations governing          **
-- ** limitations on product liability.                                  **
-- **                                                                    **
-- ** Copyright 2009 Xilinx, Inc.                                        **
-- ** All rights reserved.                                               **
-- **                                                                    **
-- ** This disclaimer and copyright notice must be retained as part      **
-- ** of this file at all times.                                         **
-- ************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:        axi_pcie_test_system.vhd
-- Version:         v1.04.a
-- Description:     This is the top level design file for the axi_pcie_test_system
--                  function. It provides a standardized slave interface
--                  between the IP and the AXI. This version supports
--                  single read/write transfers only.  It does not provide
--                  address pipelining or simultaneous read and write
--                  operations.
-------------------------------------------------------------------------------
-- Structure:   This section shows the hierarchical structure of axi_pcie_test_system.
--
--              --axi_lite_ipif.vhd
--                    --slave_attachment.vhd
--                       --address_decoder.vhd
-------------------------------------------------------------------------------
-- Author:      BSB
--
-- History:
--
--  BSB      06/25/09      -- First version
-- ~~~~~~
--  - Created the first version v1.00.a
-- ^^^^^^
-------------------------------------------------------------------------------
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
--      internal version of output port         "*_i"
--      device pins:                            "*_pin"
--      ports:                                  - Names begin with Uppercase
--      processes:                              "*_PROCESS"
--      component instantiations:               "<ENTITY_>I_<#|FUNC>
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;
use proc_common_v3_00_a.proc_common_pkg.clog2;
use proc_common_v3_00_a.proc_common_pkg.max2;
use proc_common_v3_00_a.family_support.all;
use proc_common_v3_00_a.ipif_pkg.all;

library axi_lite_ipif_v1_01_a;
use axi_lite_ipif_v1_01_a.all;

library axi_pcie_mm_s_v1_04_a;

-------------------------------------------------------------------------------
--                     Definition of Generics
-------------------------------------------------------------------------------
-- C_S_AXI_DATA_WIDTH    -- AXI data bus width
-- C_S_AXI_ADDR_WIDTH    -- AXI address bus width
-- C_S_AXI_MIN_SIZE      -- Minimum address range of the IP
-- C_USE_WSTRB           -- Use write strobs or not
-- C_DPHASE_TIMEOUT      -- Data phase time out counter
-- C_ARD_ADDR_RANGE_ARRAY-- Base /High Address Pair for each Address Range
-- C_ARD_NUM_CE_ARRAY    -- Desired number of chip enables for an address range
-- C_FAMILY              -- Target FPGA family
-------------------------------------------------------------------------------
--                  Definition of Ports
-------------------------------------------------------------------------------
-- S_AXI_ACLK            -- AXI Clock
-- S_AXI_ARESET          -- AXI Reset
-- S_AXI_AWADDR          -- AXI Write address
-- S_AXI_AWVALID         -- Write address valid
-- S_AXI_AWREADY         -- Write address ready
-- S_AXI_WDATA           -- Write data
-- S_AXI_WSTRB           -- Write strobes
-- S_AXI_WVALID          -- Write valid
-- S_AXI_WREADY          -- Write ready
-- S_AXI_BRESP           -- Write response
-- S_AXI_BVALID          -- Write response valid
-- S_AXI_BREADY          -- Response ready
-- S_AXI_ARADDR          -- Read address
-- S_AXI_ARVALID         -- Read address valid
-- S_AXI_ARREADY         -- Read address ready
-- S_AXI_RDATA           -- Read data
-- S_AXI_RRESP           -- Read response
-- S_AXI_RVALID          -- Read valid
-- S_AXI_RREADY          -- Read ready
-- Bus2IP_Clk            -- Synchronization clock provided to User IP
-- Bus2IP_Reset          -- Active high reset for use by the User IP
-- Bus2IP_Addr           -- Desired address of read or write operation
-- Bus2IP_RNW            -- Read or write indicator for the transaction
-- Bus2IP_BE             -- Byte enables for the data bus
-- Bus2IP_CS             -- Chip select for the transcations
-- Bus2IP_RdCE           -- Chip enables for the read
-- Bus2IP_WrCE           -- Chip enables for the write
-- Bus2IP_Data           -- Write data bus to the User IP
-- IP2Bus_Data           -- Input Read Data bus from the User IP
-- IP2Bus_WrAck          -- Active high Write Data qualifier from the IP
-- IP2Bus_RdAck          -- Active high Read Data qualifier from the IP
-- IP2Bus_Error          -- Error signal from the IP
-------------------------------------------------------------------------------

entity axi_pcie_test_system is
   generic (
      C_BASEADDR                    : std_logic_vector:=x"FFFF_FFFF";
      C_FAMILY                      : string  :="virtex6";
      C_S_AXI_ID_WIDTH              : integer := 4;
      --C_M_AXI_THREAD_ID_WIDTH       : integer; -- := 4;
      C_S_AXI_ADDR_WIDTH            : integer := 32;
      C_S_AXI_DATA_WIDTH            : integer; -- := 32;
      C_M_AXI_ADDR_WIDTH            : integer := 32;
      C_M_AXI_DATA_WIDTH            : integer; -- := 32;
      C_S_AXIS_DATA_WIDTH           : integer; -- := 32;
      C_M_AXIS_DATA_WIDTH           : integer; -- := 32;
      C_COMP_TIMEOUT                : integer := 0;
      C_S_AXI_SUPPORTS_NARROW_BURST : integer := 1;
      C_INCLUDE_BAROFFSET_REG       : integer := 1;
      C_AXIBAR_NUM                  : integer := 6;
      C_AXIBAR2PCIEBAR_0            : std_logic_vector:=x"00000000";
      C_AXIBAR2PCIEBAR_1            : std_logic_vector:=x"00000000";
      C_AXIBAR2PCIEBAR_2            : std_logic_vector:=x"00000000";
      C_AXIBAR2PCIEBAR_3            : std_logic_vector:=x"00000000";
      C_AXIBAR2PCIEBAR_4            : std_logic_vector:=x"00000000";
      C_AXIBAR2PCIEBAR_5            : std_logic_vector:=x"00000000";
      C_AXIBAR_AS_0                 : integer := 0;
      C_AXIBAR_AS_1                 : integer := 0;
      C_AXIBAR_AS_2                 : integer := 0;
      C_AXIBAR_AS_3                 : integer := 0;
      C_AXIBAR_AS_4                 : integer := 0;
      C_AXIBAR_AS_5                 : integer := 0;
      C_AXIBAR_0                    : std_logic_vector := x"FFFF_FFFF";
      C_AXIBAR_HIGHADDR_0           : std_logic_vector := x"0000_0000";
      C_AXIBAR_1                    : std_logic_vector := x"FFFF_FFFF";
      C_AXIBAR_HIGHADDR_1           : std_logic_vector := x"0000_0000";
      C_AXIBAR_2                    : std_logic_vector := x"FFFF_FFFF";
      C_AXIBAR_HIGHADDR_2           : std_logic_vector := x"0000_0000";
      C_AXIBAR_3                    : std_logic_vector := x"FFFF_FFFF";
      C_AXIBAR_HIGHADDR_3           : std_logic_vector := x"0000_0000";
      C_AXIBAR_4                    : std_logic_vector := x"FFFF_FFFF";
      C_AXIBAR_HIGHADDR_4           : std_logic_vector := x"0000_0000";
      C_AXIBAR_5                    : std_logic_vector := x"FFFF_FFFF";
      C_AXIBAR_HIGHADDR_5           : std_logic_vector := x"0000_0000";
      C_PCIEBAR_NUM                 : integer := 3;
      C_PCIEBAR_AS                  : integer := 1;
      C_PCIEBAR_LEN_0               : integer := 16;
      C_PCIEBAR2AXIBAR_0            : std_logic_vector:=x"00000000";
      C_PCIEBAR_LEN_1               : integer := 16;
      C_PCIEBAR2AXIBAR_1            : std_logic_vector:=x"00000000";
      C_PCIEBAR_LEN_2               : integer := 16;
      C_PCIEBAR2AXIBAR_2            : std_logic_vector:=x"00000000";
      C_S_AXIS_USER_WIDTH           : integer := 12
      --C_M_AXI_AWUSER_WIDTH    : integer;
      --C_M_AXI_WUSER_WIDTH     : integer
      
      );
   port (
      -- AXI Global
      axi_aclk                : in  std_logic;
      reset                   : in  std_logic;

      -- AXI Slave Write Address Channel
      s_axi_awid              : in  std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
      s_axi_awaddr            : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      s_axi_awregion          : in  std_logic_vector(3 downto 0);
      s_axi_awlen             : in  std_logic_vector(7 downto 0);
      s_axi_awsize            : in  std_logic_vector(2 downto 0);
      s_axi_awburst           : in  std_logic_vector(1 downto 0);
      s_axi_awvalid           : in  std_logic;
      s_axi_awready           : out std_logic;

      -- AXI Slave Write Data Channel
      s_axi_wdata             : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      s_axi_wstrb             : in  std_logic_vector(C_S_AXI_DATA_WIDTH/8-1 downto 0);
      s_axi_wlast             : in  std_logic;
      s_axi_wvalid            : in  std_logic;
      s_axi_wready            : out std_logic;

      -- AXI Slave Write Response Channel
      s_axi_bid               : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
      s_axi_bresp             : out std_logic_vector(1 downto 0);
      s_axi_bvalid            : out std_logic;
      s_axi_bready            : in  std_logic;

      -- AXI Slave Read Address Channel
      s_axi_arid              : in  std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
      s_axi_araddr            : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      s_axi_arregion          : in  std_logic_vector(3 downto 0);
      s_axi_arlen             : in  std_logic_vector(7 downto 0);
      s_axi_arsize            : in  std_logic_vector(2 downto 0);
      s_axi_arburst           : in  std_logic_vector(1 downto 0);
      s_axi_arvalid           : in  std_logic;
      s_axi_arready           : out std_logic;

      -- AXI Slave Read Data Channel
      s_axi_rid               : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
      s_axi_rdata             : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      s_axi_rresp             : out std_logic_vector(1 downto 0);
      s_axi_rlast             : out std_logic;
      s_axi_rvalid            : out std_logic;
      s_axi_rready            : in  std_logic;

      -- AXIS Write Requester Channel
      m_axis_rw_tdata         : out std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0);
      m_axis_rw_tstrb         : out std_logic_vector(C_M_AXIS_DATA_WIDTH/8-1 downto 0);
      m_axis_rw_tlast         : out std_logic;
      m_axis_rw_tvalid        : out std_logic;
      m_axis_rw_tready        : in  std_logic;

      -- AXIS Read Requester Channel
      m_axis_rr_tid           : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
      m_axis_rr_tdata         : out std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0);
      m_axis_rr_tstrb         : out std_logic_vector(C_M_AXIS_DATA_WIDTH/8-1 downto 0);
      m_axis_rr_tlast         : out std_logic;
      m_axis_rr_tvalid        : out std_logic;
      m_axis_rr_tready        : in  std_logic;

      -- AXIS Completion Requester Channel
      s_axis_rc_tdata         : in  std_logic_vector(C_M_AXIS_DATA_WIDTH-1 downto 0);
      s_axis_rc_tstrb         : in  std_logic_vector(C_M_AXIS_DATA_WIDTH/8-1 downto 0);
      s_axis_rc_tlast         : in  std_logic;
      s_axis_rc_tvalid        : in  std_logic;
      s_axis_rc_tready        : out std_logic;

      -- AXI Master Write Address Channel
      m_axi_awaddr            : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
      m_axi_awlen             : out std_logic_vector(7 downto 0);
      m_axi_awsize            : out std_logic_vector(2 downto 0);
      m_axi_awburst           : out std_logic_vector(1 downto 0);
      m_axi_awprot            : out std_logic_vector(2 downto 0);
      m_axi_awvalid           : out std_logic;
      m_axi_awready           : in  std_logic;
      --m_axi_awid              : out std_logic_vector(C_M_AXI_THREAD_ID_WIDTH-1 downto 0);
      m_axi_awlock            : out std_logic;
      m_axi_awcache           : out std_logic_vector(3 downto 0);

      -- AXI Master Write Data Channel
      m_axi_wdata             : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
      m_axi_wstrb             : out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
      m_axi_wlast             : out std_logic;
      m_axi_wvalid            : out std_logic;
      m_axi_wready            : in  std_logic;

      -- AXI Master Write Response Channel
      m_axi_bresp             : in  std_logic_vector(1 downto 0);
      m_axi_bvalid            : in  std_logic;
      m_axi_bready            : out std_logic;

      -- AXI Master Read Address Channel
      --m_axi_arid              : out std_logic_vector(C_M_AXI_THREAD_ID_WIDTH-1 downto 0);
      m_axi_araddr            : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
      m_axi_arlen             : out std_logic_vector(7 downto 0);
      m_axi_arsize            : out std_logic_vector(2 downto 0);
      m_axi_arburst           : out std_logic_vector(1 downto 0);
      m_axi_arprot            : out std_logic_vector(2 downto 0);
      m_axi_arvalid           : out std_logic;
      m_axi_arready           : in  std_logic;
      m_axi_arlock            : out std_logic;
      m_axi_arcache           : out std_logic_vector(3 downto 0);

      -- AXI Master Read Data Channel
      m_axi_rdata             : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
      m_axi_rresp             : in  std_logic_vector(1 downto 0);
      m_axi_rlast             : in  std_logic;
      m_axi_rvalid            : in  std_logic;
      m_axi_rready            : out std_logic;

      -- AXIS Write Completer Channel
      s_axis_cw_tdata         : in  std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
      s_axis_cw_tstrb         : in  std_logic_vector(C_S_AXIS_DATA_WIDTH/8-1 downto 0);
      s_axis_cw_tlast         : in  std_logic;
      s_axis_cw_tvalid        : in  std_logic;
      s_axis_cw_tready        : out std_logic;
      s_axis_cw_tuser         : in  std_logic_vector(C_S_AXIS_USER_WIDTH-1 downto 0);

      -- AXIS Read Completer Channel
      s_axis_cr_tdata         : in  std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
      s_axis_cr_tstrb         : in  std_logic_vector(C_S_AXIS_DATA_WIDTH/8-1 downto 0);
      s_axis_cr_tlast         : in  std_logic;
      s_axis_cr_tvalid        : in  std_logic;
      s_axis_cr_tready        : out std_logic;
      s_axis_cr_tuser         : in  std_logic_vector(C_S_AXIS_USER_WIDTH-1 downto 0);

      -- AXIS Completion Completer Channel
      m_axis_cc_tdata         : out std_logic_vector(C_S_AXIS_DATA_WIDTH-1 downto 0);
      m_axis_cc_tstrb         : out std_logic_vector(C_S_AXIS_DATA_WIDTH/8-1 downto 0);
      m_axis_cc_tlast         : out std_logic;
      m_axis_cc_tvalid        : out std_logic;
      m_axis_cc_tready        : in  std_logic;
      m_axis_cc_tuser         : out std_logic_vector(C_S_AXIS_USER_WIDTH-1 downto 0);

      -- AXI-Lite signals
      s_axi_al_awaddr         : in  std_logic_vector(31 downto 0);
      s_axi_al_awvalid        : in  std_logic;
      s_axi_al_awready        : out std_logic;
      s_axi_al_wdata          : in  std_logic_vector(31 downto 0);
      s_axi_al_wstrb          : in  std_logic_vector((32/8)-1 downto 0);
      s_axi_al_wvalid         : in  std_logic;
      s_axi_al_wready         : out std_logic;
      s_axi_al_bresp          : out std_logic_vector(1 downto 0);
      s_axi_al_bvalid         : out std_logic;
      s_axi_al_bready         : in  std_logic;
      s_axi_al_araddr         : in  std_logic_vector(31 downto 0);
      s_axi_al_arvalid        : in  std_logic;
      s_axi_al_arready        : out std_logic;
      s_axi_al_rdata          : out std_logic_vector(31 downto 0);
      s_axi_al_rresp          : out std_logic_vector(1 downto 0);
      s_axi_al_rvalid         : out std_logic;
      s_axi_al_rready         : in  std_logic;

      -- AXI-S Block Interface
      blk_lnk_up              : in  std_logic;
      blk_bus_number          : in  std_logic_vector(7 downto 0);
      blk_device_number       : in  std_logic_vector(4 downto 0);
      blk_function_number     : in  std_logic_vector(2 downto 0);
      blk_command             : in  std_logic_vector(15 downto 0);
      blk_dcontrol            : in  std_logic_vector(15 downto 0);
      blk_lstatus             : in  std_logic_vector(15 downto 0);

      --Interrupt Strobes
      SUR_int                 : out std_logic;
      SUC_int                 : out std_logic;
      SCT_int                 : out std_logic;
      SEP_int                 : out std_logic;
      SCA_int                 : out std_logic;
      SIB_int                 : out std_logic;
      MDE_int                 : out std_logic; -- Master DECERR interrupt
      MSE_int                 : out std_logic; -- Master SLVERR interrupt
      MEP_int                 : out std_logic -- Slave Error Poison interrupt
      --MLE_int                 : out std_logic; -- Link Down interrupt
      --MEC_int                 : out std_logic
      );  -- ECRC Error interrupt      

end axi_pcie_test_system;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------

architecture rtl of axi_pcie_test_system is

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------

   constant C_DUMMYADDR            : std_logic_vector:=x"0000_0000";
   constant C_ARD_ADDR_RANGE_ARRAY : SLV64_ARRAY_TYPE   := (
                             C_BASEADDR + X"0000_0000_0000_0000",
                             C_BASEADDR + X"0000_0000_0000_0FFF",
                             C_DUMMYADDR + X"0000_0000_0000_0000",
                             C_DUMMYADDR + X"0000_0000_0000_0FFF"
                             );
   constant C_ARD_NUM_CE_ARRAY     : INTEGER_ARRAY_TYPE := (1, 1);

   signal Bus2IP_Clk    : std_logic;
   signal Bus2IP_Reset  : std_logic;
   signal IP2Bus_Data   : std_logic_vector(31 downto 0);
   signal IP2Bus_WrAck  : std_logic;
   signal IP2Bus_RdAck  : std_logic;
   signal IP2Bus_Error  : std_logic;
   signal Bus2IP_Addr   : std_logic_vector(31 downto 0);
   signal Bus2IP_Data   : std_logic_vector(31 downto 0);
   signal Bus2IP_RNW    : std_logic;
   signal Bus2IP_BE     : std_logic_vector(32/8-1 downto 0);
   signal Bus2IP_CS     : std_logic_vector(C_ARD_ADDR_RANGE_ARRAY'LENGTH/2-1 downto 0);

begin

-------------------------------------------------------------------------------
-- AXI-lite IPIF
-------------------------------------------------------------------------------


comp_axi_lite_ipif : entity axi_lite_ipif_v1_01_a.axi_lite_ipif
   generic map(
      C_ARD_ADDR_RANGE_ARRAY    => C_ARD_ADDR_RANGE_ARRAY,
      C_ARD_NUM_CE_ARRAY        => C_ARD_NUM_CE_ARRAY,
      C_S_AXI_ADDR_WIDTH        => 32,
      C_S_AXI_DATA_WIDTH        => 32,
      C_USE_WSTRB               => 0,
      C_DPHASE_TIMEOUT          => 16,
      C_S_AXI_MIN_SIZE          => x"000001FF",
      C_FAMILY                  => C_FAMILY
   )
   port map(
      -- AXI-Lite signals
      S_AXI_ACLK          => axi_aclk,
      S_AXI_ARESETN       => reset,
      S_AXI_AWADDR        => s_axi_al_awaddr,
      S_AXI_AWVALID       => s_axi_al_awvalid,
      S_AXI_AWREADY       => s_axi_al_awready,
      S_AXI_WDATA         => s_axi_al_wdata,
      S_AXI_WSTRB         => s_axi_al_wstrb,
      S_AXI_WVALID        => s_axi_al_wvalid,
      S_AXI_WREADY        => s_axi_al_wready,
      S_AXI_BRESP         => s_axi_al_bresp,
      S_AXI_BVALID        => s_axi_al_bvalid,
      S_AXI_BREADY        => s_axi_al_bready,
      S_AXI_ARADDR        => s_axi_al_araddr,
      S_AXI_ARVALID       => s_axi_al_arvalid,
      S_AXI_ARREADY       => s_axi_al_arready,
      S_AXI_RDATA         => s_axi_al_rdata,
      S_AXI_RRESP         => s_axi_al_rresp,
      S_AXI_RVALID        => s_axi_al_rvalid,
      S_AXI_RREADY        => s_axi_al_rready,
      -- IPIC signals
      Bus2IP_Clk          => Bus2IP_Clk,
      Bus2IP_Resetn       => Bus2IP_Reset,
      Bus2IP_Addr         => Bus2IP_Addr,
      Bus2IP_RNW          => Bus2IP_RNW,
      Bus2IP_BE           => Bus2IP_BE,
      Bus2IP_CS           => Bus2IP_CS,
      Bus2IP_Data         => Bus2IP_Data,
      IP2Bus_Data         => IP2Bus_Data,
      IP2Bus_WrAck        => IP2Bus_WrAck,
      IP2Bus_RdAck        => IP2Bus_RdAck,
      IP2Bus_Error        => IP2Bus_Error
   );


comp_axi_pcie_mm_s : entity axi_pcie_mm_s_v1_04_a.axi_pcie_mm_s
   generic map(
      C_FAMILY                      => C_FAMILY,
      C_S_AXI_ID_WIDTH              => C_S_AXI_ID_WIDTH,
      C_S_AXI_ADDR_WIDTH            => C_S_AXI_ADDR_WIDTH,
      C_S_AXI_DATA_WIDTH            => C_S_AXI_DATA_WIDTH,
      C_M_AXI_ADDR_WIDTH            => C_M_AXI_ADDR_WIDTH,
      C_M_AXI_DATA_WIDTH            => C_M_AXI_DATA_WIDTH,
      C_S_AXIS_DATA_WIDTH           => C_S_AXIS_DATA_WIDTH,
      C_M_AXIS_DATA_WIDTH           => C_M_AXIS_DATA_WIDTH,
      C_COMP_TIMEOUT                => C_COMP_TIMEOUT,
      C_S_AXI_SUPPORTS_NARROW_BURST => C_S_AXI_SUPPORTS_NARROW_BURST,
      C_INCLUDE_BAROFFSET_REG       => C_INCLUDE_BAROFFSET_REG,
      C_AXIBAR_NUM                  => C_AXIBAR_NUM,
      C_AXIBAR2PCIEBAR_0            => C_AXIBAR2PCIEBAR_0,
      C_AXIBAR2PCIEBAR_1            => C_AXIBAR2PCIEBAR_1,
      C_AXIBAR2PCIEBAR_2            => C_AXIBAR2PCIEBAR_2,
      C_AXIBAR2PCIEBAR_3            => C_AXIBAR2PCIEBAR_3,
      C_AXIBAR2PCIEBAR_4            => C_AXIBAR2PCIEBAR_4,
      C_AXIBAR2PCIEBAR_5            => C_AXIBAR2PCIEBAR_5,
      C_AXIBAR_AS_0                 => C_AXIBAR_AS_0,
      C_AXIBAR_AS_1                 => C_AXIBAR_AS_1,
      C_AXIBAR_AS_2                 => C_AXIBAR_AS_2,
      C_AXIBAR_AS_3                 => C_AXIBAR_AS_3,
      C_AXIBAR_AS_4                 => C_AXIBAR_AS_4,
      C_AXIBAR_AS_5                 => C_AXIBAR_AS_5,
      C_AXIBAR_0                    => C_AXIBAR_0,
      C_AXIBAR_HIGHADDR_0           => C_AXIBAR_HIGHADDR_0,
      C_AXIBAR_1                    => C_AXIBAR_1,
      C_AXIBAR_HIGHADDR_1           => C_AXIBAR_HIGHADDR_1,
      C_AXIBAR_2                    => C_AXIBAR_2,
      C_AXIBAR_HIGHADDR_2           => C_AXIBAR_HIGHADDR_2,
      C_AXIBAR_3                    => C_AXIBAR_3,
      C_AXIBAR_HIGHADDR_3           => C_AXIBAR_HIGHADDR_3,
      C_AXIBAR_4                    => C_AXIBAR_4,
      C_AXIBAR_HIGHADDR_4           => C_AXIBAR_HIGHADDR_4,
      C_AXIBAR_5                    => C_AXIBAR_5,
      C_AXIBAR_HIGHADDR_5           => C_AXIBAR_HIGHADDR_5,
      C_PCIEBAR_NUM                 => C_PCIEBAR_NUM,
      C_PCIEBAR_AS                  => C_PCIEBAR_AS,
      C_PCIEBAR_LEN_0               => C_PCIEBAR_LEN_0,
      C_PCIEBAR2AXIBAR_0            => C_PCIEBAR2AXIBAR_0,
      C_PCIEBAR_LEN_1               => C_PCIEBAR_LEN_1,
      C_PCIEBAR2AXIBAR_1            => C_PCIEBAR2AXIBAR_1,
      C_PCIEBAR_LEN_2               => C_PCIEBAR_LEN_2,
      C_PCIEBAR2AXIBAR_2            => C_PCIEBAR2AXIBAR_2,
      C_S_AXIS_USER_WIDTH           => C_S_AXIS_USER_WIDTH
      --C_M_AXI_AWUSER_WIDTH      => C_M_AXI_AWUSER_WIDTH,
      --C_M_AXI_WUSER_WIDTH       => C_M_AXI_WUSER_WIDTH
      
   )
   port map(
      -- AXI Global	      
      axi_aclk            => axi_aclk,
      reset               => reset,

      -- AXI Slave Write Address Channel
      s_axi_awid          => s_axi_awid,
      s_axi_awaddr        => s_axi_awaddr,
      s_axi_awregion      => s_axi_awregion,
      s_axi_awlen         => s_axi_awlen,
      s_axi_awsize        => s_axi_awsize,
      s_axi_awburst       => s_axi_awburst,
      s_axi_awvalid       => s_axi_awvalid,
      s_axi_awready       => s_axi_awready,

      -- AXI Slave Write Data Channel
      s_axi_wdata         => s_axi_wdata,
      s_axi_wstrb         => s_axi_wstrb,
      s_axi_wlast         => s_axi_wlast,
      s_axi_wvalid        => s_axi_wvalid,
      s_axi_wready        => s_axi_wready,

      -- AXI Slave Write Response Channel
      s_axi_bid           => s_axi_bid,
      s_axi_bresp         => s_axi_bresp,
      s_axi_bvalid        => s_axi_bvalid,
      s_axi_bready        => s_axi_bready,

      -- AXI Slave Read Address Channel
      s_axi_arid          => s_axi_arid,
      s_axi_araddr        => s_axi_araddr,
      s_axi_arregion      => s_axi_arregion,
      s_axi_arlen         => s_axi_arlen,
      s_axi_arsize        => s_axi_arsize,
      s_axi_arburst       => s_axi_arburst,
      s_axi_arvalid       => s_axi_arvalid,
      s_axi_arready       => s_axi_arready,

      -- AXI Slave Read Data Channel
      s_axi_rid           => s_axi_rid,
      s_axi_rdata         => s_axi_rdata,
      s_axi_rresp         => s_axi_rresp,
      s_axi_rlast         => s_axi_rlast,
      s_axi_rvalid        => s_axi_rvalid,
      s_axi_rready        => s_axi_rready,

      -- AXIS Write Requester Channel
      m_axis_rw_tdata     => m_axis_rw_tdata,
      m_axis_rw_tstrb     => m_axis_rw_tstrb,
      m_axis_rw_tlast     => m_axis_rw_tlast,
      m_axis_rw_tvalid    => m_axis_rw_tvalid,
      m_axis_rw_tready    => m_axis_rw_tready,

      -- AXIS Read Requester Channel
      m_axis_rr_tid       => m_axis_rr_tid,
      m_axis_rr_tdata     => m_axis_rr_tdata,
      m_axis_rr_tstrb     => m_axis_rr_tstrb,
      m_axis_rr_tlast     => m_axis_rr_tlast,
      m_axis_rr_tvalid    => m_axis_rr_tvalid,
      m_axis_rr_tready    => m_axis_rr_tready,

      -- AXIS Completion Requester Channel
      s_axis_rc_tdata     => s_axis_rc_tdata,
      s_axis_rc_tstrb     => s_axis_rc_tstrb,
      s_axis_rc_tlast     => s_axis_rc_tlast,
      s_axis_rc_tvalid    => s_axis_rc_tvalid,
      s_axis_rc_tready    => s_axis_rc_tready,

      -- AXI Master Write Address Channel
      m_axi_awaddr        => m_axi_awaddr,
      m_axi_awlen         => m_axi_awlen,
      m_axi_awsize        => m_axi_awsize,
      m_axi_awburst       => m_axi_awburst,
      m_axi_awprot        => m_axi_awprot,
      m_axi_awvalid       => m_axi_awvalid,
      m_axi_awready       => m_axi_awready,
      --m_axi_awid          => m_axi_awid,
      m_axi_awlock        => m_axi_awlock,
      m_axi_awcache       => m_axi_awcache,

      -- AXI Master Write Data Channel
      m_axi_wdata         => m_axi_wdata,
      m_axi_wstrb         => m_axi_wstrb,
      m_axi_wlast         => m_axi_wlast,
      m_axi_wvalid        => m_axi_wvalid,
      m_axi_wready        => m_axi_wready,

      -- AXI Master Write Response Channel
      m_axi_bresp         => m_axi_bresp,
      m_axi_bvalid        => m_axi_bvalid,
      m_axi_bready        => m_axi_bready,

      -- AXI Master Read Address Channel
      --m_axi_arid          => m_axi_arid,
      m_axi_araddr        => m_axi_araddr,
      m_axi_arlen         => m_axi_arlen,
      m_axi_arsize        => m_axi_arsize,
      m_axi_arburst       => m_axi_arburst,
      m_axi_arprot        => m_axi_arprot,
      m_axi_arvalid       => m_axi_arvalid,
      m_axi_arready       => m_axi_arready,
      m_axi_arlock        => m_axi_arlock,
      m_axi_arcache       => m_axi_arcache,

      -- AXI Master Read Data Channel
      m_axi_rdata         => m_axi_rdata,
      m_axi_rresp         => m_axi_rresp,
      m_axi_rlast         => m_axi_rlast,
      m_axi_rvalid        => m_axi_rvalid,
      m_axi_rready        => m_axi_rready,

      -- AXIS Write Completer Channel
      s_axis_cw_tdata     => s_axis_cw_tdata,
      s_axis_cw_tstrb     => s_axis_cw_tstrb,
      s_axis_cw_tlast     => s_axis_cw_tlast,
      s_axis_cw_tvalid    => s_axis_cw_tvalid,
      s_axis_cw_tready    => s_axis_cw_tready,
      s_axis_cw_tuser     => s_axis_cw_tuser,

      -- AXIS Read Completer Channel
      s_axis_cr_tdata     => s_axis_cr_tdata,
      s_axis_cr_tstrb     => s_axis_cr_tstrb,
      s_axis_cr_tlast     => s_axis_cr_tlast,
      s_axis_cr_tvalid    => s_axis_cr_tvalid,
      s_axis_cr_tready    => s_axis_cr_tready,
      s_axis_cr_tuser     => s_axis_cr_tuser,

      -- AXIS Completion Completer Channel
      m_axis_cc_tdata     => m_axis_cc_tdata,
      m_axis_cc_tstrb     => m_axis_cc_tstrb,
      m_axis_cc_tlast     => m_axis_cc_tlast,
      m_axis_cc_tvalid    => m_axis_cc_tvalid,
      m_axis_cc_tready    => m_axis_cc_tready,
      m_axis_cc_tuser     => m_axis_cc_tuser,

      -- AXI-Lite Slave IPIC
      IP2Bus_Data         => IP2Bus_Data,
      IP2Bus_WrAck        => IP2Bus_WrAck,
      IP2Bus_RdAck        => IP2Bus_RdAck,
      IP2Bus_Error        => IP2Bus_Error,
      Bus2IP_Addr         => Bus2IP_Addr,
      Bus2IP_Data         => Bus2IP_Data,
      Bus2IP_RNW          => Bus2IP_RNW,
      Bus2IP_BE           => Bus2IP_BE,
      Bus2IP_CS           => Bus2IP_CS(0),

      -- AXI-S Block Interface
      blk_lnk_up              => blk_lnk_up,
      blk_bus_number          => blk_bus_number,
      blk_device_number       => blk_device_number,
      blk_function_number     => blk_function_number,
      blk_command             => blk_command,
      blk_dcontrol            => blk_dcontrol,
      blk_lstatus             => blk_lstatus,
      np_cpl_pending          => open,

      --Interrupt Strobes
      SUR_int                 => SUR_int,
      SUC_int                 => SUC_int,
      SCT_int                 => SCT_int,
      SEP_int                 => SEP_int,
      SCA_int                 => SCA_int,
      SIB_int                 => SIB_int,
      MDE_int                 => MDE_int,
      MSE_int                 => MSE_int,
      MEP_int                 => MEP_int
      --MLE_int                 => MLE_int,
      --MEC_int                 => MEC_int
   );

end rtl;
