-------------------------------------------------------------------------------
-- axi_dma_lite_if
-------------------------------------------------------------------------------
--
-- *************************************************************************
--
-- (c) Copyright 2010, 2011 Xilinx, Inc. All rights reserved.
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
--
-- *************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:          axi_dma_lite_if.vhd
-- Description: This entity is AXI Lite Interface Module for the AXI DMA
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--                  axi_dma.vhd
--                   |- axi_dma_pkg.vhd
--                   |- axi_dma_rst_module.vhd
--                   |- axi_dma_reg_module.vhd
--                   |   |- axi_dma_lite_if.vhd
--                   |   |- axi_dma_register.vhd (mm2s)
--                   |   |- axi_dma_register.vhd (s2mm)
--                   |- axi_dma_mm2s_mngr.vhd
--                   |   |- axi_dma_mm2s_sg_if.vhd
--                   |   |- axi_dma_mm2s_sm.vhd
--                   |   |- axi_dma_mm2s_cmdsts_if.vhd
--                   |   |- axi_dma_mm2s_cntrl_strm.vhd
--                   |       |- axi_dma_skid_buf.vhd
--                   |       |- axi_dma_strm_rst.vhd
--                   |- axi_dma_s2mm_mngr.vhd
--                   |   |- axi_dma_s2mm_sg_if.vhd
--                   |   |- axi_dma_s2mm_sm.vhd
--                   |   |- axi_dma_s2mm_cmdsts_if.vhd
--                   |   |- axi_dma_s2mm_sts_strm.vhd
--                   |       |- axi_dma_skid_buf.vhd
--                   |- axi_datamover_v2_00_a.axi_data_mover.vhd (FULL)
--                   |- axi_dma_strm_rst.vhd
--                   |- axi_dma_skid_buf.vhd
--                   |- axi_sg_v3_00_a.axi_sg.vhd
--
-------------------------------------------------------------------------------
-- Author:      Gary Burch
-- History:
--  GAB     3/19/10    v1_00_a
-- ^^^^^^
--  - Initial Release
-- ~~~~~~
--  GAB     9/03/10    v2_00_a
-- ^^^^^^
--  - Updated libraries to v2_00_a
-- ~~~~~~
--  GAB     9/30/10     v2_00_a
-- ^^^^^^
-- CR576999 - Modified to assert back to back read/write address requests, i.e.
--            requests where arvalid or awvalid do not de-assert between requests
--            and back to back write data valid.
-- ~~~~~~
--  GAB     10/15/10    v3_00_a
-- ^^^^^^
--  - Updated libraries to v3_00_a
--  - Added asynchronous mode
-- ~~~~~~
--  GAB     2/15/11     v4_00_a
-- ^^^^^^
--  Updated libraries to v4_00_a
-- ~~~~~~
--  GAB     4/12/11     v4_00_a
-- ^^^^^^
-- CR605883 (CDC) need to provide pure register output to synchronizers
-- ~~~~~~
--  GAB     4/14/11     v4_00_a
-- ^^^^^^
-- CR606122 - Align awvalid_re pulse and wvalid_re pulse for proper async writes
-- ~~~~~~
--  GAB     4/14/11     v4_00_a
-- ^^^^^^
-- CR607165 - asynch operation allowed acceptance of 2nd read address prior
--          to completion of the previous reads.  CR Fixed.
-- ~~~~~~
--  GAB     6/21/11    v5_00_a
-- ^^^^^^
--  Updated to axi_dma_v6_00_a
-- ~~~~~~
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

library axi_dma_v6_00_a;
use axi_dma_v6_00_a.axi_dma_pkg.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.clog2;


-------------------------------------------------------------------------------
entity  axi_dma_lite_if is
    generic(
        C_NUM_CE                    : integer                := 8           ;
        C_AXI_LITE_IS_ASYNC         : integer range 0 to 1   := 0           ;
        C_S_AXI_LITE_ADDR_WIDTH     : integer range 32 to 32 := 32          ;
        C_S_AXI_LITE_DATA_WIDTH     : integer range 32 to 32 := 32
    );
    port (
        -- Async clock input
        ip2axi_aclk                 : in  std_logic                         ;          --
        ip2axi_aresetn              : in  std_logic                         ;          --

        -----------------------------------------------------------------------
        -- AXI Lite Control Interface
        -----------------------------------------------------------------------
        s_axi_lite_aclk             : in  std_logic                         ;          --
        s_axi_lite_aresetn          : in  std_logic                         ;          --
                                                                                       --
        -- AXI Lite Write Address Channel                                              --
        s_axi_lite_awvalid          : in  std_logic                         ;          --
        s_axi_lite_awready          : out std_logic                         ;          --
        s_axi_lite_awaddr           : in  std_logic_vector                             --
                                        (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0);          --
                                                                                       --
        -- AXI Lite Write Data Channel                                                 --
        s_axi_lite_wvalid           : in  std_logic                         ;          --
        s_axi_lite_wready           : out std_logic                         ;          --
        s_axi_lite_wdata            : in  std_logic_vector                             --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);          --
                                                                                       --
        -- AXI Lite Write Response Channel                                             --
        s_axi_lite_bresp            : out std_logic_vector(1 downto 0)      ;          --
        s_axi_lite_bvalid           : out std_logic                         ;          --
        s_axi_lite_bready           : in  std_logic                         ;          --
                                                                                       --
        -- AXI Lite Read Address Channel                                               --
        s_axi_lite_arvalid          : in  std_logic                         ;          --
        s_axi_lite_arready          : out std_logic                         ;          --
        s_axi_lite_araddr           : in  std_logic_vector                             --
                                        (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0);          --
        s_axi_lite_rvalid           : out std_logic                         ;          --
        s_axi_lite_rready           : in  std_logic                         ;          --
        s_axi_lite_rdata            : out std_logic_vector                             --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);          --
        s_axi_lite_rresp            : out std_logic_vector(1 downto 0)      ;          --
                                                                                       --
        -- User IP Interface                                                           --
        axi2ip_wrce                 : out std_logic_vector                             --
                                        (C_NUM_CE-1 downto 0)               ;          --
        axi2ip_wrdata               : out std_logic_vector                             --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);          --
                                                                                       --
        axi2ip_rdce                 : out std_logic_vector                             --
                                        (C_NUM_CE-1 downto 0)               ;          --

        axi2ip_rdaddr               : out std_logic_vector                             --
                                        (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0);          --
        ip2axi_rddata               : in std_logic_vector                              --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0)           --
    );
end axi_dma_lite_if;


-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_dma_lite_if is

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------
-- Register I/F Address offset
constant ADDR_OFFSET    : integer := clog2(C_S_AXI_LITE_DATA_WIDTH/8);
-- Register I/F CE number
constant CE_ADDR_SIZE   : integer := clog2(C_NUM_CE);

-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
-- AXI Lite slave interface signals
signal awvalid              : std_logic := '0';
signal awaddr               : std_logic_vector
                                (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0) := (others => '0');
signal wvalid               : std_logic := '0';
signal wdata                : std_logic_vector
                                (C_S_AXI_LITE_DATA_WIDTH-1 downto 0) := (others => '0');


signal arvalid              : std_logic := '0';
signal araddr               : std_logic_vector
                                (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0) := (others => '0');
signal awvalid_d1           : std_logic := '0';
signal awvalid_re           : std_logic := '0';
signal awready_i            : std_logic := '0';
signal wvalid_d1            : std_logic := '0';
signal wvalid_re            : std_logic := '0';
signal wready_i             : std_logic := '0';
signal bvalid_i             : std_logic := '0';

signal wr_addr_cap          : std_logic := '0';
signal wr_data_cap          : std_logic := '0';

-- AXI to IP interface signals
signal axi2ip_wraddr_i      : std_logic_vector
                                (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0) := (others => '0');
signal axi2ip_wrdata_i      : std_logic_vector
                                (C_S_AXI_LITE_DATA_WIDTH-1 downto 0) := (others => '0');
signal axi2ip_wren          : std_logic := '0';
signal wrce                 : std_logic_vector(C_NUM_CE-1 downto 0);

signal rdce                 : std_logic_vector(C_NUM_CE-1 downto 0) := (others => '0');
signal arvalid_d1           : std_logic := '0';
signal arvalid_re           : std_logic := '0';
signal arvalid_re_d1        : std_logic := '0';
signal arvalid_i            : std_logic := '0';
signal arready_i            : std_logic := '0';
signal rvalid               : std_logic := '0';
signal axi2ip_rdaddr_i      : std_logic_vector
                                (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0) := (others => '0');

signal s_axi_lite_rvalid_i  : std_logic := '0';
signal read_in_progress     : std_logic := '0'; -- CR607165
signal rst_rvalid_re        : std_logic := '0'; -- CR576999
signal rst_wvalid_re        : std_logic := '0'; -- CR576999



-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

--*****************************************************************************
--** AXI LITE READ
--*****************************************************************************

s_axi_lite_wready   <= wready_i;
s_axi_lite_awready  <= awready_i;
s_axi_lite_arready  <= arready_i;

s_axi_lite_bvalid   <= bvalid_i;

-------------------------------------------------------------------------------
-- Register AXI Inputs
-------------------------------------------------------------------------------
REG_INPUTS : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
                awvalid <=  '0'                 ;
                awaddr  <=  (others => '0')     ;
                wvalid  <=  '0'                 ;
                wdata   <=  (others => '0')     ;
                arvalid <=  '0'                 ;
                araddr  <=  (others => '0')     ;
            else
                awvalid <= s_axi_lite_awvalid   ;
                awaddr  <= s_axi_lite_awaddr    ;
                wvalid  <= s_axi_lite_wvalid    ;
                wdata   <= s_axi_lite_wdata     ;
                arvalid <= s_axi_lite_arvalid   ;
                araddr  <= s_axi_lite_araddr    ;
            end if;
        end if;
    end process REG_INPUTS;

-------------------------------------------------------------------------------
-- Assert Write Adddress Ready Handshake
-- Capture rising edge of valid and register out as ready.  This creates
-- a 3 clock cycle address phase but also registers all inputs and outputs.
-- Note : Single clock cycle address phase can be accomplished using
-- combinatorial logic.
-------------------------------------------------------------------------------
REG_AWVALID : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0' or rst_wvalid_re = '1')then
                awvalid_d1  <= '0';
                awvalid_re  <= '0';                             -- CR605883
            else
                awvalid_d1  <= awvalid;
                awvalid_re  <= awvalid and not awvalid_d1;      -- CR605883
            end if;
        end if;
    end process REG_AWVALID;

-- CR605883 (CDC) need to provide pure register output to synchronizers
--awvalid_re  <= awvalid and not awvalid_d1 and not rst_wvalid_re;


REG_AWREADY : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0' or wr_addr_cap = '1')then
                awready_i <= '0';
            else
                awready_i <= awvalid_re;
            end if;
        end if;
    end process REG_AWREADY;

-------------------------------------------------------------------------------
-- Capture assertion of awvalid to indicate that we have captured
-- a valid address
-------------------------------------------------------------------------------
WRADDR_CAP_FLAG : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0' or rst_wvalid_re = '1')then
                wr_addr_cap <= '0';
            elsif(awvalid_re = '1')then
                wr_addr_cap <= '1';
            end if;
        end if;
    end process WRADDR_CAP_FLAG;

-------------------------------------------------------------------------------
-- Assert Write Data Ready Handshake
-- Capture rising edge of valid and register out as ready.  This creates
-- a 3 clock cycle address phase but also registers all inputs and outputs.
-- Note : Single clock cycle address phase can be accomplished using
-- combinatorial logic.
-------------------------------------------------------------------------------
REG_WVALID : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0' or rst_wvalid_re = '1')then
                wvalid_d1   <= '0';
                wvalid_re   <= '0';
            else
                wvalid_d1   <= wvalid;
                wvalid_re   <= wvalid and not wvalid_d1; -- CR605883
            end if;
        end if;
    end process REG_WVALID;

-- CR605883 (CDC) provide pure register output to synchronizers
--wvalid_re  <= wvalid and not wvalid_d1 and not rst_wvalid_re;

REG_WREADY : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0' or  wr_data_cap = '1')then
                wready_i <= '0';
            else
                wready_i <= wvalid_re;
            end if;
        end if;
    end process REG_WREADY;

-------------------------------------------------------------------------------
-- Capture assertion of wvalid to indicate that we have captured
-- valid data
-------------------------------------------------------------------------------
WRDATA_CAP_FLAG : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0' or rst_wvalid_re = '1')then
                wr_data_cap <= '0';
            elsif(wvalid_re = '1')then
                wr_data_cap <= '1';
            end if;
        end if;
    end process WRDATA_CAP_FLAG;


-- s_axi_lite_aclk is synchronous to ip clock
GEN_SYNC_WRITE : if C_AXI_LITE_IS_ASYNC = 0 generate
begin

    -------------------------------------------------------------------------------
    -- Capture Write Address
    -------------------------------------------------------------------------------
    REG_WRITE_ADDRESS : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    axi2ip_wraddr_i   <= (others => '0');

                -- Register address on valid
                elsif(awvalid_re = '1')then
                    axi2ip_wraddr_i   <= awaddr;

                end if;
            end if;
        end process REG_WRITE_ADDRESS;

    -------------------------------------------------------------------------------
    -- Capture Write Data
    -------------------------------------------------------------------------------
    REG_WRITE_DATA : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    axi2ip_wrdata_i     <= (others => '0');

                -- Register address and assert ready
                elsif(wvalid_re = '1')then
                    axi2ip_wrdata_i     <= wdata;

                end if;
            end if;
        end process REG_WRITE_DATA;

    -------------------------------------------------------------------------------
    -- Must have both a valid address and valid data before updating
    -- a register.  Note in AXI write address can come before or
    -- after AXI write data.
    axi2ip_wren <= '1' when wr_data_cap = '1' and wr_addr_cap = '1'
                else '0';

    -------------------------------------------------------------------------------
    -- Decode and assert proper chip enable per captured axi lite write address
    -------------------------------------------------------------------------------
    WRCE_GEN: for j in 0 to C_NUM_CE - 1 generate

    constant BAR    : std_logic_vector(CE_ADDR_SIZE-1 downto 0) :=
                    std_logic_vector(to_unsigned(j,CE_ADDR_SIZE));
    begin

        wrce(j) <= axi2ip_wren when axi2ip_wraddr_i
                                    ((CE_ADDR_SIZE + ADDR_OFFSET) - 1
                                                        downto ADDR_OFFSET)

                                    = BAR(CE_ADDR_SIZE-1 downto 0)
              else '0';

    end generate WRCE_GEN;

    -------------------------------------------------------------------------------
    -- register write ce's and data out to axi dma register module
    -------------------------------------------------------------------------------
    REG_WR_OUT : process(s_axi_lite_aclk)
        begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
                axi2ip_wrce     <= (others => '0');
                axi2ip_wrdata   <= (others => '0');
            else
                axi2ip_wrce     <= wrce;
                axi2ip_wrdata   <= axi2ip_wrdata_i;
            end if;
        end if;
    end process REG_WR_OUT;

    -------------------------------------------------------------------------------
    -- Write Response
    -------------------------------------------------------------------------------
    s_axi_lite_bresp    <= OKAY_RESP;

    WRESP_PROCESS : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    bvalid_i        <= '0';
                    rst_wvalid_re   <= '0';     -- CR576999
                -- If response issued and target indicates ready then
                -- clear response
                elsif(bvalid_i = '1' and s_axi_lite_bready = '1')then
                    bvalid_i        <= '0';
                    rst_wvalid_re   <= '0';     -- CR576999
                -- Issue a resonse on write
                elsif(axi2ip_wren = '1')then
                    bvalid_i        <= '1';
                    rst_wvalid_re   <= '1';     -- CR576999
                end if;
            end if;
        end process WRESP_PROCESS;


end generate GEN_SYNC_WRITE;


-- s_axi_lite_aclk is asynchronous to ip clock
GEN_ASYNC_WRITE : if C_AXI_LITE_IS_ASYNC = 1 generate
-- Data support
signal ip_wvalid_d1_cdc_to     : std_logic := '0';
signal ip_wvalid_d2     : std_logic := '0';
signal ip_wvalid_re     : std_logic := '0';
signal wr_wvalid_re_cdc_from     : std_logic := '0';
signal wr_data_cdc_from          : std_logic_vector                                              -- CR605883
                            (C_S_AXI_LITE_DATA_WIDTH-1 downto 0) := (others => '0');    -- CR605883
signal wdata_d1_cdc_to         : std_logic_vector
                            (C_S_AXI_LITE_DATA_WIDTH-1 downto 0) := (others => '0');
signal wdata_d2         : std_logic_vector
                            (C_S_AXI_LITE_DATA_WIDTH-1 downto 0) := (others => '0');
signal ip_data_cap      : std_logic := '0';

-- Address support
signal ip_awvalid_d1_cdc_to    : std_logic := '0';
signal ip_awvalid_d2    : std_logic := '0';
signal ip_awvalid_re    : std_logic := '0';
signal wr_awvalid_re_cdc_from    : std_logic := '0';
signal wr_addr_cdc_from          : std_logic_vector                                              -- CR605883
                            (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0) := (others => '0');    -- CR605883
signal awaddr_d1_cdc_to        : std_logic_vector
                            (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0) := (others => '0');
signal awaddr_d2        : std_logic_vector
                            (C_S_AXI_LITE_ADDR_WIDTH-1 downto 0) := (others => '0');
signal ip_addr_cap      : std_logic := '0';

-- Bvalid support
signal lite_data_cap_d1 : std_logic := '0';
signal lite_data_cap_d2 : std_logic := '0';
signal lite_addr_cap_d1 : std_logic := '0';
signal lite_addr_cap_d2 : std_logic := '0';
signal lite_axi2ip_wren : std_logic := '0';

begin

    --*************************************************************************
    --** Write Address Support
    --*************************************************************************

    -------------------------------------------------------------------------------
    -- Capture write address (CR605883)
    -------------------------------------------------------------------------------
    WRADDR_S_H : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    wr_addr_cdc_from <= (others => '0');
                elsif(awvalid_re = '1')then
                    wr_addr_cdc_from <= awaddr;
                end if;
            end if;
        end process WRADDR_S_H;

    -------------------------------------------------------------------------------
    -- CR606122 - Align awvalid_re pulse to above wr_addr
    -- This will force the assertion of ip_awvalid_re (below) to align with
    -- axi2ip_wraddr_i and ultimatly drive axi2ip_wren 1 clock after wraddr
    -- transisition giving a solid decode for the wrce.
    -------------------------------------------------------------------------------
    WRAVALID_ALIGN : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    wr_awvalid_re_cdc_from <= '0';
                else
                    wr_awvalid_re_cdc_from <= awvalid_re;
                end if;
            end if;
        end process WRAVALID_ALIGN;


    -- Register awready into IP clock domain.
    REG_AVALID_TO_IPCLK : process(ip2axi_aclk)
        begin
            if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
                if(ip2axi_aresetn = '0')then
                    ip_awvalid_d1_cdc_to <= '0';
                    ip_awvalid_d2 <= '0';
                else
                    --ip_awvalid_d1_cdc_to <= awvalid_re;              -- CR606122
                    ip_awvalid_d1_cdc_to <= wr_awvalid_re_cdc_from;             -- CR606122
                    ip_awvalid_d2 <= ip_awvalid_d1_cdc_to;
                end if;
            end if;
        end process REG_AVALID_TO_IPCLK;

    ip_awvalid_re <= ip_awvalid_d2;

    -- Double register address in
    REG_WADDR_TO_IPCLK : process(ip2axi_aclk)
        begin
            if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
                if(ip2axi_aresetn = '0')then
                    awaddr_d1_cdc_to           <= (others => '0');
                    --awaddr_d2           <= (others => '0');   -- CR605883
                    axi2ip_wraddr_i     <= (others => '0');
                else
                    --awaddr_d1_cdc_to           <= s_axi_lite_awaddr; -- CR605883
                    --awaddr_d2           <= awaddr_d1_cdc_to;         -- CR605883
                    --axi2ip_wraddr_i     <= awaddr_d2;         -- CR605883
                    awaddr_d1_cdc_to           <= wr_addr_cdc_from;
                    axi2ip_wraddr_i     <= awaddr_d1_cdc_to;           -- CR605883
                end if;
            end if;
        end process REG_WADDR_TO_IPCLK;
-- CR606122
--    -- Sample and hold address
--    REG_AWADDR_PROCESS : process(ip2axi_aclk)
--        begin
--            if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
--                if(ip2axi_aresetn = '0')then
--                    axi2ip_wraddr_i <= (others => '0');
--                elsif(ip_awvalid_re = '1')then
--                    axi2ip_wraddr_i <= awaddr_d2;
--                end if;
--            end if;
--        end process REG_AWADDR_PROCESS;

    -- Flag that address has been captured
    REG_IP_ADDR_CAP : process(ip2axi_aclk)
        begin
            if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
                if(ip2axi_aresetn = '0' or axi2ip_wren = '1')then
                    ip_addr_cap <= '0';
                elsif(ip_awvalid_re = '1')then
                    ip_addr_cap <= '1';
                end if;
            end if;
        end process REG_IP_ADDR_CAP;


    --*************************************************************************
    --** Write Data Support
    --*************************************************************************

    -------------------------------------------------------------------------------
    -- Capture write data
    -------------------------------------------------------------------------------
    WRDATA_S_H : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    wr_data_cdc_from <= (others => '0');
                elsif(wvalid_re = '1')then
                    wr_data_cdc_from <= wdata;
                end if;
            end if;
        end process WRDATA_S_H;

    -------------------------------------------------------------------------------
    -- CR606122 - Align wvalid_re pulse to above wr_data
    -- This will force the assertion of ip_wvalid_re (below) to align
    -- axi2ip_wrdata_i with wrce assertion
    -------------------------------------------------------------------------------
    WRVALID_ALIGN : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    wr_wvalid_re_cdc_from <= '0';
                else
                    wr_wvalid_re_cdc_from <= wvalid_re;
                end if;
            end if;
        end process WRVALID_ALIGN;


    -- Register wready into IP clock domain.
    REG_VALID_TO_IPCLK : process(ip2axi_aclk)
        begin
            if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
                if(ip2axi_aresetn = '0')then
                    ip_wvalid_d1_cdc_to <= '0';
                    ip_wvalid_d2 <= '0';
                else
                    ---ip_wvalid_d1_cdc_to <= wvalid_re;           -- CR606122
                    ip_wvalid_d1_cdc_to <= wr_wvalid_re_cdc_from;           -- CR606122
                    ip_wvalid_d2 <= ip_wvalid_d1_cdc_to;
                end if;
            end if;
        end process REG_VALID_TO_IPCLK;

    ip_wvalid_re <= ip_wvalid_d2;

    -- Double register data in
    REG_WDATA_TO_IPCLK : process(ip2axi_aclk)
        begin
            if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
                if(ip2axi_aresetn = '0')then
                    wdata_d1_cdc_to        <= (others => '0');
                    --wdata_d2        <= (others => '0');
                    axi2ip_wrdata_i <= (others => '0');         -- CR605883
                else
                    --wdata_d1_cdc_to           <= s_axi_lite_wdata;   -- CR605883
                    --wdata_d2        <= wdata_d1_cdc_to;              -- CR605883
                    wdata_d1_cdc_to        <= wr_data_cdc_from;                 -- CR605883
                    axi2ip_wrdata_i <= wdata_d1_cdc_to;                -- CR605883
                end if;
            end if;
        end process REG_WDATA_TO_IPCLK;

    -- CR605883
    --    -- Sample and hold data
    --    REG_WDATA_PROCESS : process(ip2axi_aclk)
    --        begin
    --            if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
    --                if(ip2axi_aresetn = '0')then
    --                    axi2ip_wrdata_i <= (others => '0');
    --                elsif(ip_wvalid_re = '1')then
    --                    axi2ip_wrdata_i <= wdata_d2;
    --                end if;
    --            end if;
    --        end process REG_WDATA_PROCESS;

    -- Flag that data has been captured
    REG_IP_DATA_CAP : process(ip2axi_aclk)
        begin
            if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
                if(ip2axi_aresetn = '0' or axi2ip_wren = '1')then
                    ip_data_cap <= '0';
                elsif(ip_wvalid_re = '1')then
                    ip_data_cap <= '1';
                end if;
            end if;
        end process REG_IP_DATA_CAP;

    -- Must have both a valid address and valid data before updating
    -- a register.  Note in AXI write address can come before or
    -- after AXI write data.
    axi2ip_wren <= '1' when ip_data_cap = '1' and ip_addr_cap = '1'
                else '0';

    -------------------------------------------------------------------------------
    -- Decode and assert proper chip enable per captured axi lite write address
    -------------------------------------------------------------------------------
    WRCE_GEN: for j in 0 to C_NUM_CE - 1 generate

    constant BAR    : std_logic_vector(CE_ADDR_SIZE-1 downto 0) :=
                    std_logic_vector(to_unsigned(j,CE_ADDR_SIZE));
    begin

        wrce(j) <= axi2ip_wren when axi2ip_wraddr_i
                                    ((CE_ADDR_SIZE + ADDR_OFFSET) - 1
                                                        downto ADDR_OFFSET)

                                    = BAR(CE_ADDR_SIZE-1 downto 0)
              else '0';

    end generate WRCE_GEN;

    -------------------------------------------------------------------------------
    -- register write ce's and data out to axi dma register module
    -------------------------------------------------------------------------------
    REG_WR_OUT : process(ip2axi_aclk)
        begin
        if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
            if(ip2axi_aresetn = '0')then
                axi2ip_wrce     <= (others => '0');
                axi2ip_wrdata   <= (others => '0');
            else
                axi2ip_wrce     <= wrce;
                axi2ip_wrdata   <= axi2ip_wrdata_i;
            end if;
        end if;
    end process REG_WR_OUT;

    --*************************************************************************
    --** Write Response Support
    --*************************************************************************

    -- Minimum of 2 IP clocks for addr and data capture, therefore delaying
    -- Lite clock addr and data capture by 2 Lite clocks will guarenttee bvalid
    -- responce occurs after write data acutally written.
    REG_ALIGN_CAP : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    lite_data_cap_d1 <= '0';
                    lite_data_cap_d2 <= '0';

                    lite_addr_cap_d1 <= '0';
                    lite_addr_cap_d2 <= '0';
                else
                    lite_data_cap_d1 <= wr_data_cap;
                    lite_data_cap_d2 <= lite_data_cap_d1;

                    lite_addr_cap_d1 <= wr_addr_cap;
                    lite_addr_cap_d2 <= lite_addr_cap_d1;
                end if;
            end if;
        end process REG_ALIGN_CAP;

    -- Pseudo write enable used simply to assert bvalid
    lite_axi2ip_wren <= '1' when wr_data_cap = '1' and wr_addr_cap = '1'
                else '0';

    WRESP_PROCESS : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    bvalid_i        <= '0';
                    rst_wvalid_re   <= '0';     -- CR576999
                -- If response issued and target indicates ready then
                -- clear response
                elsif(bvalid_i = '1' and s_axi_lite_bready = '1')then
                    bvalid_i        <= '0';
                    rst_wvalid_re   <= '0';     -- CR576999
                -- Issue a resonse on write
                elsif(lite_axi2ip_wren = '1')then
                    bvalid_i        <= '1';
                    rst_wvalid_re   <= '1';     -- CR576999
                end if;
            end if;
        end process WRESP_PROCESS;

    s_axi_lite_bresp    <= OKAY_RESP;


end generate GEN_ASYNC_WRITE;





--*****************************************************************************
--** AXI LITE READ
--*****************************************************************************

-------------------------------------------------------------------------------
-- Assert Read Adddress Ready Handshake
-- Capture rising edge of valid and register out as ready.  This creates
-- a 3 clock cycle address phase but also registers all inputs and outputs.
-- Note : Single clock cycle address phase can be accomplished using
-- combinatorial logic.
-------------------------------------------------------------------------------
REG_ARVALID : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0' or rst_rvalid_re = '1')then
                arvalid_d1 <= '0';
            else
                arvalid_d1 <= arvalid;
            end if;
        end if;
    end process REG_ARVALID;

arvalid_re  <= arvalid and not arvalid_d1
                and not rst_rvalid_re and not read_in_progress; -- CR607165

-- register for proper alignment
REG_ARREADY : process(s_axi_lite_aclk)
    begin
        if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
            if(s_axi_lite_aresetn = '0')then
                arready_i <= '0';
            else
                arready_i <= arvalid_re;
            end if;
        end if;
    end process REG_ARREADY;

-- Always respond 'okay' axi lite read
s_axi_lite_rresp    <= OKAY_RESP;
s_axi_lite_rvalid   <= s_axi_lite_rvalid_i;


-- s_axi_lite_aclk is synchronous to ip clock
GEN_SYNC_READ : if C_AXI_LITE_IS_ASYNC = 0 generate
begin

    read_in_progress <= '0'; --Not used for sync mode (CR607165)

    -------------------------------------------------------------------------------
    -- Capture Read Address
    -------------------------------------------------------------------------------
    REG_READ_ADDRESS : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    axi2ip_rdaddr_i   <= (others => '0');

                -- Register address on valid
                elsif(arvalid_re = '1')then
                    axi2ip_rdaddr_i   <= araddr;

                end if;
            end if;
        end process REG_READ_ADDRESS;



    -------------------------------------------------------------------------------
    -- Generate RdCE based on address match to address bar
    -------------------------------------------------------------------------------
    RDCE_GEN: for j in 0 to C_NUM_CE - 1 generate

    constant BAR    : std_logic_vector(CE_ADDR_SIZE-1 downto 0) :=
                    std_logic_vector(to_unsigned(j,CE_ADDR_SIZE));
    begin

      rdce(j) <= arvalid_re_d1
        when axi2ip_rdaddr_i((CE_ADDR_SIZE + ADDR_OFFSET) - 1
                              downto ADDR_OFFSET)
             = BAR(CE_ADDR_SIZE-1 downto 0)
        else '0';

    end generate RDCE_GEN;

    -------------------------------------------------------------------------------
    -- Register out to IP
    -------------------------------------------------------------------------------
    REG_RDCNTRL_OUT : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    --axi2ip_rdce     <= (others => '0');
                    axi2ip_rdaddr   <= (others => '0');
                else
                    --axi2ip_rdce     <= rdce;
                    axi2ip_rdaddr   <= axi2ip_rdaddr_i;
                end if;
            end if;
        end process REG_RDCNTRL_OUT;

    -- Sample and hold rdce value until rvalid assertion
    REG_RDCE_OUT : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0' or rst_rvalid_re = '1')then
                    axi2ip_rdce     <= (others => '0');
                elsif(arvalid_re_d1 = '1')then
                    axi2ip_rdce     <= rdce;
                end if;
            end if;
        end process REG_RDCE_OUT;

    -- Register for proper alignment
    REG_RVALID : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    arvalid_re_d1   <= '0';
                    rvalid          <= '0';
                else
                    arvalid_re_d1   <= arvalid_re;
                    rvalid          <= arvalid_re_d1;
                end if;
            end if;
        end process REG_RVALID;

    -------------------------------------------------------------------------------
    -- Drive read data and read data valid out on capture of valid address.
    -------------------------------------------------------------------------------
    REG_RD_OUT : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    s_axi_lite_rdata    <= (others => '0');
                    s_axi_lite_rvalid_i <= '0';
                    rst_rvalid_re       <= '0';                 -- CR576999

                -- If rvalid driving out to target and target indicates ready
                -- then de-assert rvalid. (structure guarentees min 1 clock of rvalid)
                elsif(s_axi_lite_rvalid_i = '1' and s_axi_lite_rready = '1')then
                    s_axi_lite_rdata    <= (others => '0');
                    s_axi_lite_rvalid_i <= '0';
                    rst_rvalid_re       <= '0';                 -- CR576999

                -- If read cycle then assert rvalid and rdata out to target
                elsif(rvalid = '1')then
                    s_axi_lite_rdata    <= ip2axi_rddata;
                    s_axi_lite_rvalid_i <= '1';
                    rst_rvalid_re       <= '1';                 -- CR576999

                end if;
            end if;
        end process REG_RD_OUT;


end generate GEN_SYNC_READ;



-- s_axi_lite_aclk is asynchronous to ip clock
GEN_ASYNC_READ : if C_AXI_LITE_IS_ASYNC = 1 generate
signal ip_arvalid_d1        : std_logic := '0';
signal ip_arvalid_d2        : std_logic := '0';
signal ip_arvalid_d3        : std_logic := '0';
signal ip_arvalid_re        : std_logic := '0';

signal araddr_d1_cdc_to            : std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0) :=(others => '0');
signal araddr_d2            : std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0) :=(others => '0');
signal araddr_d3            : std_logic_vector(C_S_AXI_LITE_ADDR_WIDTH-1 downto 0) :=(others => '0');

signal lite_rdata_cdc_from           : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0) :=(others => '0');
signal lite_rdata_d1_cdc_to        : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0) :=(others => '0');
signal lite_rdata_d2        : std_logic_vector(C_S_AXI_LITE_DATA_WIDTH-1 downto 0) :=(others => '0');

signal p_pulse_s_h          : std_logic := '0';
signal p_pulse_s_h_clr      : std_logic := '0';
signal s_pulse_d1           : std_logic := '0';
signal s_pulse_d2           : std_logic := '0';
signal s_pulse_d3           : std_logic := '0';
signal s_pulse_re           : std_logic := '0';

signal p_pulse_re_d1        : std_logic := '0';
signal p_pulse_re_d2        : std_logic := '0';
signal p_pulse_re_d3        : std_logic := '0';

signal arready_d1           : std_logic := '0'; -- CR605883
signal arready_d2           : std_logic := '0'; -- CR605883
signal arready_d3           : std_logic := '0'; -- CR605883
signal arready_d4           : std_logic := '0'; -- CR605883
signal arready_d5           : std_logic := '0'; -- CR605883
signal arready_d6           : std_logic := '0'; -- CR605883

begin

    -- CR607165
    -- Flag to prevent overlapping reads
    RD_PROGRESS : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0' or rst_rvalid_re = '1')then
                    read_in_progress <= '0';

                elsif(arvalid_re = '1')then
                    read_in_progress <= '1';
                end if;
            end if;
        end process RD_PROGRESS;


    -- Double register address in
    REG_RADDR_TO_IPCLK : process(ip2axi_aclk)
        begin
            if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
                if(ip2axi_aresetn = '0')then
                    araddr_d1_cdc_to           <= (others => '0');
                    araddr_d2           <= (others => '0');
                    araddr_d3           <= (others => '0');
                else
                    araddr_d1_cdc_to           <= s_axi_lite_araddr;
                    araddr_d2           <= araddr_d1_cdc_to;
                    araddr_d3           <= araddr_d2;
                end if;
            end if;
        end process REG_RADDR_TO_IPCLK;

    -- Latch and hold read address
    REG_ARADDR_PROCESS : process(ip2axi_aclk)
        begin
            if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
                if(ip2axi_aresetn = '0')then
                    axi2ip_rdaddr_i <= (others => '0');
                elsif(ip_arvalid_re = '1')then
                    axi2ip_rdaddr_i <= araddr_d3;
                end if;
            end if;
        end process REG_ARADDR_PROCESS;

    axi2ip_rdaddr   <= axi2ip_rdaddr_i;

    -- Register awready into IP clock domain.  awready
    -- is a 1 axi_lite clock delay of the rising edge of
    -- arvalid.  This provides a signal that asserts when
    -- araddr is known to be stable.
    REG_ARVALID_TO_IPCLK : process(ip2axi_aclk)
        begin
            if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
                if(ip2axi_aresetn = '0')then
                    ip_arvalid_d1 <= '0';
                    ip_arvalid_d2 <= '0';
                    ip_arvalid_d3 <= '0';
                else
                    ip_arvalid_d1 <= arready_i;
                    ip_arvalid_d2 <= ip_arvalid_d1;
                    ip_arvalid_d3 <= ip_arvalid_d2;
                end if;
            end if;
        end process REG_ARVALID_TO_IPCLK;

    ip_arvalid_re <= ip_arvalid_d2 and not ip_arvalid_d3;

    -------------------------------------------------------------------------------
    -- Generate Read CE's
    -------------------------------------------------------------------------------
    RDCE_GEN: for j in 0 to C_NUM_CE - 1 generate

    constant BAR    : std_logic_vector(CE_ADDR_SIZE-1 downto 0) :=
                    std_logic_vector(to_unsigned(j,CE_ADDR_SIZE));
    begin

      rdce(j) <= ip_arvalid_re
        when araddr_d3((CE_ADDR_SIZE + ADDR_OFFSET) - 1
                              downto ADDR_OFFSET)
             = BAR(CE_ADDR_SIZE-1 downto 0)
        else '0';

    end generate RDCE_GEN;

    -------------------------------------------------------------------------------
    -- Register RDCE and RD Data out to IP
    -------------------------------------------------------------------------------
-- CR605883
--    REG_RDCNTRL_OUT : process(ip2axi_aclk)
--        begin
--            if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
--                if(ip2axi_aresetn = '0' or p_pulse_s_h_clr = '1')then
--                    axi2ip_rdce     <= (others => '0');
--                elsif(ip_arvalid_re = '1')then
--                    axi2ip_rdce     <= rdce;
--                end if;
--            end if;
--        end process REG_RDCNTRL_OUT;
    REG_RDCNTRL_OUT : process(ip2axi_aclk)
        begin
            if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
                if(ip2axi_aresetn = '0')then
                    axi2ip_rdce     <= (others => '0');
                elsif(ip_arvalid_re = '1')then
                    axi2ip_rdce     <= rdce;
                else
                    axi2ip_rdce     <= (others => '0');
                end if;
            end if;
        end process REG_RDCNTRL_OUT;

    -- Generate sample and hold pulse to capture read data from IP
    REG_RVALID : process(ip2axi_aclk)
        begin
            if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
                if(ip2axi_aresetn = '0')then
                    rvalid          <= '0';
                else
                    rvalid          <= ip_arvalid_re;
                end if;
            end if;
        end process REG_RVALID;

    -------------------------------------------------------------------------------
    -- Sample and hold read data from IP
    -------------------------------------------------------------------------------
    S_H_READ_DATA : process(ip2axi_aclk)
        begin
            if(ip2axi_aclk'EVENT and ip2axi_aclk = '1')then
                if(ip2axi_aresetn = '0')then
                    lite_rdata_cdc_from    <= (others => '0');

                -- If read cycle then assert rvalid and rdata out to target
                elsif(rvalid = '1')then
                    lite_rdata_cdc_from    <= ip2axi_rddata;

                end if;
            end if;
        end process S_H_READ_DATA;

    -- Cross read data to axi_lite clock domain
    REG_DATA2LITE_CLOCK : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    lite_rdata_d1_cdc_to   <= (others => '0');
                    lite_rdata_d2   <= (others => '0');
                else
                    lite_rdata_d1_cdc_to   <= lite_rdata_cdc_from;
                    lite_rdata_d2   <= lite_rdata_d1_cdc_to;
                end if;
            end if;
        end process REG_DATA2LITE_CLOCK;

-- CR605883
--    -------------------------------------------------------------------
--    -- Cross pulse from ip2axi_aclk (fast clock) to s_axi_lite_aclk
--    -- slow clock
--    -------------------------------------------------------------------
--    -- Sample and hold secondary pulse
--    S_H_PULSE : process(ip2axi_aclk)
--        begin
--            if(ip2axi_aclk'EVENT and ip2axi_aclk ='1')then
--                -- clear on reset or s_h clear
--                if(ip2axi_aresetn = '0' or p_pulse_s_h_clr='1')then
--                    p_pulse_s_h <= '0';
--                -- On read valid
--                elsif(rvalid = '1')then
--                    p_pulse_s_h <= '1';
--                end if;
--            end if;
--        end process S_H_PULSE;
--
--
--    -- Cross scndry pulse over to primary clock domain
--    CROSS2SCNDRY : process(s_axi_lite_aclk)
--        begin
--            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk ='1')then
--                if(s_axi_lite_aresetn = '0')then
--                    s_pulse_d1  <= '0';
--                    s_pulse_d2  <= '0';
--                    s_pulse_d3  <= '0';
--                else
--                    s_pulse_d1  <= p_pulse_s_h;
--                    s_pulse_d2  <= s_pulse_d1;
--                    s_pulse_d3  <= s_pulse_d2;
--                end if;
--            end if;
--        end process CROSS2SCNDRY;
--
--    -- CR605883 (CDC) provide pure register output for synchronizer
--    -- s_pulse_re <= s_pulse_d2 and not s_pulse_d3;
--
--    -- Cross secondary pulse re back over to primary to use
--    -- as clear for sample and hold.
--    CROSS_2PRMRY : process(ip2axi_aclk)
--        begin
--            if(ip2axi_aclk'EVENT and ip2axi_aclk ='1')then
--                if(ip2axi_aresetn = '0')then
--                    p_pulse_re_d1   <= '0';
--                    p_pulse_re_d2   <= '0';
--                    p_pulse_re_d3   <= '0';
--                else
--                    p_pulse_re_d1   <= s_pulse_re;
--                    p_pulse_re_d2   <= p_pulse_re_d1;
--                    p_pulse_re_d3   <= p_pulse_re_d2;
--                end if;
--            end if;
--        end process CROSS_2PRMRY;
--
--    -- Create sample and hold clear off rising edge
--    p_pulse_s_h_clr <= p_pulse_re_d2 and not p_pulse_re_d3;


    -- CR605883 (CDC) modified to remove
    -- Because axi_lite_aclk must be less than or equal to ip2axi_aclk
    -- then read data will appear a maximum 6 clocks from assertion
    -- of arready.
    REG_ALIGN_RDATA_LATCH : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    arready_d1 <= '0';
                    arready_d2 <= '0';
                    arready_d3 <= '0';
                    arready_d4 <= '0';
                    arready_d5 <= '0';
                    arready_d6 <= '0';
                else
                    arready_d1 <= arready_i;
                    arready_d2 <= arready_d1;
                    arready_d3 <= arready_d2;
                    arready_d4 <= arready_d3;
                    arready_d5 <= arready_d4;
                    arready_d6 <= arready_d5;
                end if;
            end if;
        end process REG_ALIGN_RDATA_LATCH;

    -------------------------------------------------------------------------------
    -- Drive read data and read data valid out on capture of valid address.
    -------------------------------------------------------------------------------
    REG_RD_OUT : process(s_axi_lite_aclk)
        begin
            if(s_axi_lite_aclk'EVENT and s_axi_lite_aclk = '1')then
                if(s_axi_lite_aresetn = '0')then
                    s_axi_lite_rdata    <= (others => '0');
                    s_axi_lite_rvalid_i <= '0';
                    rst_rvalid_re       <= '0';                 -- CR576999

                -- If rvalid driving out to target and target indicates ready
                -- then de-assert rvalid. (structure guarentees min 1 clock of rvalid)
                elsif(s_axi_lite_rvalid_i = '1' and s_axi_lite_rready = '1')then
                    s_axi_lite_rdata    <= (others => '0');
                    s_axi_lite_rvalid_i <= '0';
                    rst_rvalid_re       <= '0';                 -- CR576999

                -- If read cycle then assert rvalid and rdata out to target
                -- CR605883
                --elsif(s_pulse_re = '1')then
                elsif(arready_d6 = '1')then
                    s_axi_lite_rdata    <= lite_rdata_d2;
                    s_axi_lite_rvalid_i <= '1';
                    rst_rvalid_re       <= '1';                 -- CR576999

                end if;
            end if;
        end process REG_RD_OUT;


end generate GEN_ASYNC_READ;

end implementation;


