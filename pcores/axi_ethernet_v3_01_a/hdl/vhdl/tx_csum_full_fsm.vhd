-------------------------------------------------------------------------------
-- tx_csum_full_fsm - entity/architecture pair
-------------------------------------------------------------------------------
--
-- (c) Copyright 2010 - 2010 Xilinx, Inc. All rights reserved.
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
-------------------------------------------------------------------------------
-- Filename:        tx_csum_full_fsm.vhd
-- Version:         v1.00a
-- Description:     top level of embedded ip Ethernet MAC interface
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:   This section shows the hierarchical structure of axi_ethernet.
--
--              axi_ethernet.vhd
--                axi_ethernt_soft_temac_wrap.vhd
--                axi_lite_ipif.vhd
--                embedded_top.vhd
--                  tx_if.vhd
--                    tx_axistream_if.vhd
--                      tx_basic_if.vhd
--                      tx_csum_if.vhd
--                        tx_csum_full_if.vhd
--          ->              tx_csum_full_fsm.vhd
--                          tx_csum_full_calc_if.vhd
--                        tx_partial_csum_if.vhd
--                          tx_csum_partial_calc_if.vhd
--                      tx_vlan_if.vhd
--                    tx_mem_if
--                    tx_emac_if.vhd
--
-------------------------------------------------------------------------------
-- Author:          MW
--
--  MW     07/01/10
-- ^^^^^^
--  - Initial release of v1.00.a
-- ~~~~~~
-------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;



-------------------------------------------------------------------------------
--                  Entity Section
-------------------------------------------------------------------------------

entity tx_csum_full_fsm is
  generic (
    C_S_AXI_DATA_WIDTH     : integer range 32 to 32     := 32;
    c_TxD_addrb_width      : integer range  0 to 13     := 10
  );
  port (

    AXI_STR_TXD_ACLK  : in  std_logic;                                        --  Clock
    reset2axi_str_txd : in  std_logic;                                        --  Reset

    txd_strbs         : in  std_logic_vector(3 downto 0);                     --  AXI-Stream Tx Data Strobes
    do_csum           : in  std_logic;                                        --  axi_flag must = 0xA for this to be enabled
    abort_csum        : out std_logic;                                        --  All conditions were not met to complete csum
    txd_tlast         : in  std_logic;                                        --  AXI-Stream Tx Data Last
    csum_calc_en      : in  std_logic;                                        --  axi_str_txd_tvalid_dly0 and
                                                                              --  axi_str_txd_tready_int_dly;
    clr_csums         : out std_logic;                                        --  Clear CSUM flags and calculations
    tcp_ptcl          : out std_logic;                                        --  TCP Protocol Indicator
    udp_ptcl          : out std_logic;                                        --  UDP Protocol Indicator
    en_ipv4_hdr_b32   : out std_logic_vector( 1 downto 0);                    --  bytes 3 and 2 of din
    en_ipv4_hdr_b10   : out std_logic_vector( 1 downto 0);                    --  bytes 1 and 0 of din
    last_ipv4_hdr_cnt : out std_logic;                                        --  last data for IPv4 Header Calculation
    fsm_csum_en_b32   : out std_logic_vector( 1 downto 0);                    --  bytes 3 and 2 of din
    fsm_csum_en_b10   : out std_logic_vector( 1 downto 0);                    --  bytes 1 and 0 of din
    add_psdo_wd       : out std_logic;                                        --  last data for TCP/UDP Calculation
    ptcl_csum_cmplt   : in  std_logic;                                        --  indicates the TCP/UDP csum calculation is complete
    zeroes_en         : out std_logic_vector( 1 downto 0);                    --  stalls the CSUM calculations for one clock so
                                                                              --  Zeroes do not need muxed in
    din               : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1  downto 0); --  AXI Stream Tx Data
    csum_din          : out std_logic_vector(C_S_AXI_DATA_WIDTH-1  downto 0); --  Mux out of pseudo data or axi_str_txd_tdata_dly0
    do_ipv4hdr        : out std_logic;                                        --  only do the ipv4 header csum
    not_tcp_udp       : out std_logic;                                        --  only do the ipv4 header csum - no TCP/UDP protocol
    do_full_csum      : out std_logic;                                        --  do the ipv4 headr and TCP/UDP csum
    hdr_csum_cmplt    : in  std_logic;                                        --  Header CSUM Calculation is complete
    wr_hdr_csum       : out std_logic;                                        --  Enable to Write the Header CSUM to Memory
    wr_ptcl_csum      : out std_logic;                                        --  Enable to Write the EthII/Snap Ipv4 TCP/UDP CSUM

    csum_strt_addr    : in  std_logic_vector(c_TxD_addrb_width-1   downto 0); --  Start Address to start the CSUM ccalculation
    csum_ipv4_hdr_addr: out std_logic_vector(c_TxD_addrb_width-1   downto 0); --  IPv4 Header Start Address
    csum_ipv4_hdr_we  : out std_logic_vector( 3 downto 0);                    --  IPv4 Header Write Enable to Memory
    csum_ptcl_addr    : out std_logic_vector(c_TxD_addrb_width-1   downto 0); --  Address to Write the EthII/Snap Ipv4 TCP/UDP CSUM
    csum_ptcl_we      : out std_logic_vector( 3 downto 0)                     --  Enables to Write the EthII/Snap Ipv4 TCP/UDP CSUM


  );

end tx_csum_full_fsm;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture rtl of tx_csum_full_fsm is

  signal din_big_end           : std_logic_vector(0 to C_S_AXI_DATA_WIDTH-1);

  type   FULL_CSUM_FSM_TYPE is (
           IDLE,
           DST,     --  Destination Address
           DST_SRC, --  Destination and Source Address
           SRC,     --  Source Address
           IDF,     --  Identify Frame Type
           SNAP,    --  SNAP Frame
           OUI,     --  SNAP OUI
           IPV4_HDR,--  IPv4 Header
           PCOL_HDR,--  Protocol of the packet - TCP or UDP
           DATA,    --  Data
           WAIT_TLAST,
           WR_HDR_ONLY,
           WAIT_DELAY,
           WAIT_COMPLETE,
           WR_HDR,  --  Write Header CSUM
           WR_CSUM  --  Write TCP/UDP CSUM
           );
  signal fcsum_wr_cs, fcsum_wr_ns             : FULL_CSUM_FSM_TYPE;

  signal store_hdr_length     : std_logic;
  signal hdr_length           : std_logic_vector( 5 downto 0);

  signal en_ipv4_hdr_cnt      : std_logic;
  signal en_ipv4_hdr_b10_int  : std_logic_vector(1 downto 0);
  signal en_ipv4_hdr_b32_int  : std_logic_vector(1 downto 0);



  signal clr_hdr_cnt          : std_logic;
  signal last_ipv4_hdr_cnt_int: std_logic;
  signal en_pcol_hdr_cnt      : std_logic;
  signal hdr_cnt              : std_logic_vector( 2 downto 0);
  signal store_version        : std_logic;
  signal version              : std_logic_vector( 3 downto 0);
  signal calc_frm_length      : std_logic;
  signal frm_length           : std_logic_vector(0 to 15);
  signal fsm_csum_en          : std_logic;
  signal fsm_csum_en_b32_int  : std_logic_vector(1 downto 0);
  signal fsm_csum_en_b10_int  : std_logic_vector(1 downto 0);

  signal csum_ipv4_hdr_addr_int : std_logic_vector(c_TxD_addrb_width-1   downto 0);
  signal csum_ipv4_hdr_we_int : std_logic_vector( 3 downto 0);
  signal csum_ptcl_addr_int   : std_logic_vector(c_TxD_addrb_width-1   downto 0);
  signal csum_ptcl_we_int     : std_logic_vector( 3 downto 0);

  signal store_sa_da          : std_logic;
  signal sa0                  : std_logic_vector(15 downto 0); --Source Address Half word - Little End
  signal sa1                  : std_logic_vector(15 downto 0); --Source Address Half word - Little End
  signal da0                  : std_logic_vector(15 downto 0); --Destination Address Half word - Little End
  signal da1                  : std_logic_vector(15 downto 0); --Destination Address Half word - Little End
  signal clr_csums_int        : std_logic;



  signal set_eth2             : std_logic;
  signal eth2                 : std_logic;
  signal set_snap             : std_logic;
  signal snap_hit             : std_logic;
  signal set_oui_hit          : std_logic;
  signal oui_hit              : std_logic;
  signal set_vlan             : std_logic;
  signal vlan                 : std_logic;
  signal set_ipv4             : std_logic;
  signal ipv4                 : std_logic;
  signal set_ptcl             : std_logic;
  signal tcp_ptcl_int         : std_logic;
  signal udp_ptcl_int         : std_logic;
  signal set_ipv4hdr_only     : std_logic;
  signal do_ipv4_int          : std_logic;

  signal set_fragment         : std_logic;
  signal fragment             : std_logic;

  signal do_full_csum_int     : std_logic;
  signal add_psdo_wd_int      : std_logic;
  signal pseudo_data          : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal zeroes_en_int        : std_logic_vector(1 downto 0);

  signal abort_csum_int       : std_logic;

  signal set_not_tcp_udp      : std_logic;
  signal not_tcp_udp_int      : std_logic;

  begin

    clr_csums           <= clr_csums_int;
    tcp_ptcl            <= tcp_ptcl_int;
    udp_ptcl            <= udp_ptcl_int;
    do_ipv4hdr          <= do_ipv4_int;
    not_tcp_udp         <= not_tcp_udp_int;
    do_full_csum        <= do_full_csum_int;

    en_ipv4_hdr_b32     <= en_ipv4_hdr_b32_int;
    en_ipv4_hdr_b10     <= en_ipv4_hdr_b10_int;
    last_ipv4_hdr_cnt   <= last_ipv4_hdr_cnt_int;
    fsm_csum_en_b32     <= fsm_csum_en_b32_int;
    fsm_csum_en_b10     <= fsm_csum_en_b10_int;
    add_psdo_wd         <= add_psdo_wd_int;
    zeroes_en           <= zeroes_en_int;

    csum_ipv4_hdr_addr  <= csum_ipv4_hdr_addr_int;
    csum_ipv4_hdr_we    <= csum_ipv4_hdr_we_int;
    csum_ptcl_addr      <= csum_ptcl_addr_int;
    csum_ptcl_we        <= csum_ptcl_we_int;

    -- Little endian to Big Endian
    din_big_end( 0 to  7) <= din( 7 downto  0);
    din_big_end( 8 to 15) <= din(15 downto  8);
    din_big_end(16 to 23) <= din(23 downto 16);
    din_big_end(24 to 31) <= din(31 downto 24);



    -----------------------------------------------------------------------
    --  FSM used to control the Full Checksum calculation
    -----------------------------------------------------------------------
    FSM_FULL_CSUM_CMB : process(fcsum_wr_cs,csum_calc_en,do_csum,
      din,din_big_end,
      vlan,hdr_cnt,ipv4,eth2,snap_hit,oui_hit,
      udp_ptcl_int,tcp_ptcl_int,fragment,
      txd_tlast,ptcl_csum_cmplt,txd_strbs,hdr_csum_cmplt,
      not_tcp_udp_int,do_ipv4_int
      )

    begin

      store_hdr_length     <= '0';
      en_ipv4_hdr_cnt      <= '0';
      en_ipv4_hdr_b10_int  <= "00";
      en_ipv4_hdr_b32_int  <= "00";

      last_ipv4_hdr_cnt_int<= '0';
      en_pcol_hdr_cnt      <= '0';
      clr_hdr_cnt          <= '0';
      store_version        <= '0';
      calc_frm_length      <= '0';
      fsm_csum_en          <= '0';
      fsm_csum_en_b32_int  <= "00";
      fsm_csum_en_b10_int  <= "00";

      store_sa_da          <= '0';
      wr_hdr_csum          <= '0';
      wr_ptcl_csum         <= '0';
      clr_csums_int        <= '0';

      set_eth2             <= '0';
      set_snap             <= '0';
      set_oui_hit          <= '0';
      set_vlan             <= '0';
      set_ipv4             <= '0';
      set_ptcl             <= '0';
      set_ipv4hdr_only     <= '0';

      set_fragment         <= '0';
      zeroes_en_int        <= "00";

      add_psdo_wd_int      <= '0';

      abort_csum_int       <= '0';

      set_not_tcp_udp      <= '0';

      case fcsum_wr_cs is
        when IDLE      =>
          if do_csum = '1' and csum_calc_en = '1' then
          --  Flag is set and tvalid/tready are HIGH
          --  If csum calc is aborted because all conditions are not met
          --    (not IPv4, not TCP, not UDP, etc) then do_csum is cleared
          --    which will prevent the FSM from starting again until the next packet
            fcsum_wr_ns <= DST;
          else
            fcsum_wr_ns <= IDLE;
          end if;
        when DST      =>
          if csum_calc_en = '1' then
          --  tvalid/tready are HIGH
            fcsum_wr_ns <= DST_SRC;
          else
            fcsum_wr_ns <= DST;
          end if;
        when DST_SRC  =>
          if csum_calc_en = '1' then
          --  tvalid/tready are HIGH
            fcsum_wr_ns <= SRC;
          else
            fcsum_wr_ns <= DST_SRC;
          end if;
        when SRC      =>
          if txd_tlast = '1' and csum_calc_en = '1' then
            --  Tlast was received so exit
            clr_csums_int       <= '0';
            abort_csum_int      <= '0';
            add_psdo_wd_int     <= '1';         --  pseudo word is not done, but this needs to set
                                                --  ptcl_csum_cmplt and exit tx_csum_full_if.vhd FSMs
            fcsum_wr_ns         <= WAIT_COMPLETE;
          elsif csum_calc_en = '1' then
            if din(15 downto 0) = X"0081" then
            --  It is VLAN
              set_vlan         <= '1';
              set_snap         <= '0';
              set_eth2         <= '0';
              store_hdr_length <= '0';
              en_ipv4_hdr_cnt  <= '0';
              store_version    <= '0';
              set_ipv4         <= '0';
              fcsum_wr_ns      <= IDF;
            elsif din_big_end(0 to 15) <= X"0600" and   --Length is less than 0x600 and
                  din(23 downto 16)  = X"AA" and din(31 downto 24) = X"AA"  then --DSAP and SSAP
            --  It is SNAP
              set_vlan         <= '0';
              set_snap         <= '1';
              set_eth2         <= '0';
              store_hdr_length <= '0';
              en_ipv4_hdr_cnt  <= '0';
              store_version    <= '0';
              set_ipv4         <= '0';
              fcsum_wr_ns      <= IDF;  --
            elsif din(15 downto  0) = X"0008" and -- TYPE is 0x0800 (IPv4) and
                  din(23 downto 16) = X"45" then  -- Version = 0x4 (IPv4) and HDR Length = 5
            -- It is Ethernet II IPv4 with 5 word header  -- IPv4 header options are not supported
              set_vlan             <= '0';
              set_snap             <= '0';
              set_eth2             <= '1';
              store_hdr_length     <= '1';  --  length of packet starting from here, to the end (+4 words for EII, +1+ vlan, +2 snap
              en_ipv4_hdr_cnt      <= '1';
              en_ipv4_hdr_b10_int  <= "00";
              en_ipv4_hdr_b32_int  <= "11";
              store_version        <= '1';
              set_ipv4             <= '1';
              fcsum_wr_ns          <= IPV4_HDR;


            else -- Not all conditions were met to perform CSUM
              set_vlan             <= '0';
              set_snap             <= '0';
              set_eth2             <= '0';
              store_hdr_length     <= '0';
              en_ipv4_hdr_cnt      <= '0';
              en_ipv4_hdr_b10_int  <= "00";
              en_ipv4_hdr_b32_int  <= "00";
              store_version        <= '0';
              set_ipv4             <= '0';
              clr_csums_int        <= '0';
              abort_csum_int       <= '0';
              fcsum_wr_ns          <= WAIT_TLAST;--WAIT_COMPLETE;
            end if;
          else
            set_vlan             <= '0';
            set_snap             <= '0';
            set_eth2             <= '0';
            store_hdr_length     <= '0';
            en_ipv4_hdr_cnt      <= '0';
            en_ipv4_hdr_b10_int  <= "00";
            en_ipv4_hdr_b32_int  <= "00";
            store_version        <= '0';
            set_ipv4             <= '0';
            fcsum_wr_ns          <= SRC;
          end if;
        when IDF =>
          if txd_tlast = '1' and csum_calc_en = '1' then
            --  Tlast was received so exit
            clr_csums_int       <= '0';
            abort_csum_int      <= '0';
            add_psdo_wd_int     <= '1';         --  pseudo word is not done, but this needs to set
                                                --  ptcl_csum_cmplt and exit tx_csum_full_if.vhd FSMs
            fcsum_wr_ns         <= WAIT_COMPLETE;
          elsif csum_calc_en = '1' then
            if vlan = '1' then
              if din(15 downto 0) = X"0008" and  -- TYPE is 0x0800 (IPv4) and
                 din(23 downto 16) = X"45" then  -- Version = 0x4 (IPv4) and HDR Length = 5
                -- It is Ethernet II IPv4 with 5 word header
                store_hdr_length     <= '1';
                en_ipv4_hdr_cnt      <= '1';
                en_ipv4_hdr_b10_int  <= "00";
                en_ipv4_hdr_b32_int  <= "11";
                store_version        <= '1';
                set_eth2             <= '1';
                set_ipv4             <= '1';
                set_snap             <= '0';
                fcsum_wr_ns          <= IPV4_HDR;
              elsif din_big_end(0 to 15) <= X"0600" and  -- Length is less than 0x600 and
                  din(23 downto 16) = X"AA" and din(31 downto 24) = X"AA" then --DSAP and SSAP
                -- It is Ethernet SNAP
                store_hdr_length <= '0';
                en_ipv4_hdr_cnt  <= '0';
                store_version    <= '0';
                set_eth2         <= '0';
                set_ipv4         <= '0';
                set_snap         <= '1';
                fcsum_wr_ns      <= SNAP;  -- SNAP detected so check OUI
              else
                store_hdr_length <= '0';
                en_ipv4_hdr_cnt  <= '0';
                store_version    <= '0';
                set_eth2         <= '0';
                set_ipv4         <= '0';
                set_snap         <= '0';
                clr_csums_int    <= '0';
                abort_csum_int   <= '0';
                fcsum_wr_ns      <= WAIT_TLAST;--WAIT_COMPLETE;  -- Do not do CSUM
              end if;
            else -- eth_snap_xsap_hit = '1' then
              if din( 7 downto  0) = X"03" and  -- Endian Swap  -- Control
                 din(15 downto  8) = X"00" and  -- Endian Swap  -- OUI
                 din(23 downto 16) = X"00" and  -- Endian Swap  -- OUI
                 din(31 downto 24) = X"00" then -- Endian Swap  -- OUI
                store_hdr_length <= '0';
                en_ipv4_hdr_cnt  <= '0';
                store_version    <= '0';
                set_eth2         <= '0';
                set_ipv4         <= '0';
                set_snap         <= '0';
                set_oui_hit      <= '1';
                fcsum_wr_ns      <= OUI;
              else
                store_hdr_length <= '0';
                en_ipv4_hdr_cnt  <= '0';
                store_version    <= '0';
                set_eth2         <= '0';
                set_ipv4         <= '0';
                set_snap         <= '0';
                set_oui_hit      <= '0';
                clr_csums_int    <= '0';
                abort_csum_int   <= '0';
                fcsum_wr_ns      <= WAIT_TLAST;--WAIT_COMPLETE;
              end if;
            end if;
          else
            set_eth2         <= '0';
            set_ipv4         <= '0';
            set_snap         <= '0';
            set_oui_hit      <= '0';
            fcsum_wr_ns      <= IDF;
          end if;
        when SNAP =>
          if txd_tlast = '1' and csum_calc_en = '1' then
            --  Tlast was received so exit
            clr_csums_int       <= '0';
            abort_csum_int      <= '0';
            add_psdo_wd_int     <= '1';         --  pseudo word is not done, but this needs to set
                                                --  ptcl_csum_cmplt and exit tx_csum_full_if.vhd FSMs
            fcsum_wr_ns         <= WAIT_COMPLETE;
          elsif csum_calc_en = '1' then
            if din( 7 downto  0) = X"03" and  -- Control
               din(15 downto  8) = X"00" and  -- OUI
               din(23 downto 16) = X"00" and  -- OUI
               din(31 downto 24) = X"00" then -- OUI
              set_oui_hit      <= '1';
              fcsum_wr_ns      <= OUI;
            else --was not OUI hit or last was received so exit
              set_oui_hit      <= '0';
              clr_csums_int    <= '0';
              abort_csum_int   <= '0';
              fcsum_wr_ns      <= WAIT_TLAST;--WAIT_COMPLETE;
            end if;
          else
            set_oui_hit      <= '0';
            fcsum_wr_ns      <= SNAP;
          end if;
        when OUI =>
          if txd_tlast = '1' and csum_calc_en = '1' then
            --  Tlast was received so exit
            clr_csums_int       <= '0';
            abort_csum_int      <= '0';
            add_psdo_wd_int     <= '1';         --  pseudo word is not done, but this needs to set
                                                --  ptcl_csum_cmplt and exit tx_csum_full_if.vhd FSMs
            fcsum_wr_ns         <= WAIT_COMPLETE;
          elsif csum_calc_en = '1' then

            if din(15 downto 0) = X"0008" and  -- TYPE is 0x0800 (IPv4) and
               din(23 downto 16) = X"45" then    -- It is SNAP IPv4 with 5 word header
              store_hdr_length     <= '1';
              en_ipv4_hdr_cnt      <= '1';
              en_ipv4_hdr_b10_int  <= "00";
              en_ipv4_hdr_b32_int  <= "11";
              store_version        <= '1';
              set_ipv4             <= '1';
              clr_csums_int        <= '0';
              abort_csum_int       <= '0';
              fcsum_wr_ns          <= IPV4_HDR;
            else --  Not ipv4 so go to idle
              store_hdr_length     <= '0';
              en_ipv4_hdr_cnt      <= '0';
              en_ipv4_hdr_b10_int  <= "00";
              en_ipv4_hdr_b32_int  <= "00";
              store_version        <= '0';
              set_ipv4             <= '0';
              clr_csums_int        <= '0';
              abort_csum_int       <= '0';
              fcsum_wr_ns          <= WAIT_TLAST;--WAIT_COMPLETE;
            end if;

          else
            store_hdr_length     <= '0';
            en_ipv4_hdr_cnt      <= '0';
            en_ipv4_hdr_b10_int  <= "00";
            en_ipv4_hdr_b32_int  <= "00";
            store_version        <= '0';
            set_ipv4             <= '0';
            clr_csums_int        <= '0';
            abort_csum_int       <= '0';
            fcsum_wr_ns          <= OUI;
          end if;
        when IPV4_HDR =>
          if csum_calc_en = '1' then
            case hdr_cnt is
              when "001" => calc_frm_length     <= '1';
                            set_ptcl            <= '0';
                            store_sa_da         <= '0';
                            fsm_csum_en         <= '0';
                            en_ipv4_hdr_cnt     <= '1';
                            en_ipv4_hdr_b10_int <= "11";
                            en_ipv4_hdr_b32_int <= "11";
                            clr_hdr_cnt         <= '0';
                            fcsum_wr_ns         <= IPV4_HDR;
              when "010" => calc_frm_length     <= '0';
                            set_ptcl            <= '1';
                            store_sa_da         <= '0';
                            fsm_csum_en         <= '0';
                            en_ipv4_hdr_cnt     <= '1';
                            en_ipv4_hdr_b10_int <= "11";
                            en_ipv4_hdr_b32_int <= "11";
                            clr_hdr_cnt         <= '0';
                            fcsum_wr_ns         <= IPV4_HDR;
                            if --din(6) = '1' and --  Don't Fragment (DF) = '1'
                               din(5) = '0' and --  More Fragment (MF) Flag = '0'
                               din(4) = '0' and               -- Fragment Offset
                               din(3 downto 0) = X"0" and     -- Fragment Offset
                               din(15 downto  8) = X"00" then -- Fragment Offset
                              set_fragment <= '0';
                            else
                              set_fragment <= '1';
                            end if;
              when "011" => --  mw 1220 --  if ipv4 = '1' and
                            --  mw 1220 --     (eth2 = '1' or (snap_hit = '1' and oui_hit = '1')) then --and
                -- two types of ipv4 frames Ethernet II and SNAP
                            --  Check to ensure all conditions are met before
                            --  continuing with csum
                              calc_frm_length     <= '0';
                              set_ptcl            <= '0';
                              store_sa_da         <= '1';
                              fsm_csum_en         <= '1';
                              fsm_csum_en_b32_int <= "11";
                              fsm_csum_en_b10_int <= "00";
                              en_ipv4_hdr_cnt     <= '1';
                              en_ipv4_hdr_b10_int <= "11";
                              en_ipv4_hdr_b32_int <= "11";
                              zeroes_en_int       <= "01";  -- Set enable for ipv4 header csum to insert zeroes into calculation
                              clr_hdr_cnt         <= '0';
                              clr_csums_int       <= '0';
                              abort_csum_int      <= '0';
                              fcsum_wr_ns         <= IPV4_HDR;
             when "100" =>  calc_frm_length       <= '0';
                            set_ptcl              <= '0';
                            store_sa_da           <= '1';
                            fsm_csum_en           <= '1';
                            fsm_csum_en_b32_int   <= "11";
                            fsm_csum_en_b10_int   <= "11";
                            en_ipv4_hdr_cnt       <= '1';
                            en_ipv4_hdr_b10_int   <= "11";
                            en_ipv4_hdr_b32_int   <= "11";
                            last_ipv4_hdr_cnt_int <= '0';
                            clr_hdr_cnt           <= '1';
                            if (tcp_ptcl_int = '1' or udp_ptcl_int = '1') and fragment = '0' then
                              set_ipv4hdr_only <= '0';
                              set_not_tcp_udp  <= '0';
                              fcsum_wr_ns      <= PCOL_HDR;
                            else -- Only perform the IPv4 Header CSUM -- Only IPv4 is set
                              set_ipv4hdr_only <= '1';
                              set_not_tcp_udp  <= '1';
                              fcsum_wr_ns      <= WAIT_TLAST;--WR_HDR_ONLY;
                           end if;
              when others=> calc_frm_length       <= '0';
                            set_ptcl              <= '0';
                            store_sa_da           <= '0';
                            fsm_csum_en           <= '0';
                            fsm_csum_en_b32_int   <= "00";
                            fsm_csum_en_b10_int   <= "00";
                            en_ipv4_hdr_cnt       <= '0';
                            en_ipv4_hdr_b10_int   <= "00";
                            en_ipv4_hdr_b32_int   <= "00";
                            clr_hdr_cnt           <= '0';
                            fcsum_wr_ns           <= IPV4_HDR;
            end case;
          else
            calc_frm_length     <= '0';
            set_ptcl            <= '0';
            store_sa_da         <= '0';
            fsm_csum_en         <= '0';
            fsm_csum_en_b32_int <= "00";
            fsm_csum_en_b10_int <= "00";
            en_ipv4_hdr_cnt     <= '0';
            en_ipv4_hdr_b10_int <= "00";
            en_ipv4_hdr_b32_int <= "00";
            clr_hdr_cnt         <= '0';
            fcsum_wr_ns         <= IPV4_HDR;
          end if;
        when PCOL_HDR =>

          if csum_calc_en = '1' then
            fsm_csum_en         <= '1';
            fsm_csum_en_b32_int <= "11";
            fsm_csum_en_b10_int <= "11";
            case hdr_cnt is
            --  when TCP this count will reset after "100"
            --  when udp this count will reset after "001"
              when "000" => calc_frm_length       <= '0';
                            store_sa_da           <= '1';
                            en_ipv4_hdr_cnt       <= '0';
                            en_ipv4_hdr_b10_int   <= "11";
                            en_ipv4_hdr_b32_int   <= "00";
                            last_ipv4_hdr_cnt_int <= '1';
                            en_pcol_hdr_cnt       <= '1';
                            zeroes_en_int         <= "00";
                            fcsum_wr_ns           <= PCOL_HDR;
              when "001" => if udp_ptcl_int = '1' then --and fragment = '0' then
                              en_pcol_hdr_cnt <= '0';
                              clr_hdr_cnt     <= '1';
                              calc_frm_length <= '1';
                              zeroes_en_int   <= "00";
                              fcsum_wr_ns     <= DATA;
                            elsif tcp_ptcl_int = '1' then --and fragment = '0' then --has to be TCP
                              en_pcol_hdr_cnt <= '1';
                              clr_hdr_cnt     <= '0';
                              calc_frm_length <= '0';
                              zeroes_en_int   <= "00";
                              fcsum_wr_ns     <= PCOL_HDR;
                            else -- it was not IPv4, tcp/udp, and fragments /= 0
                              en_pcol_hdr_cnt <= '0';
                              clr_hdr_cnt     <= '0';
                              zeroes_en_int   <= "00";
                              clr_csums_int   <= '0';
                              abort_csum_int  <= '0';
                              fcsum_wr_ns     <= WAIT_TLAST;--WAIT_COMPLETE;
                            end if;
              when "100" => en_pcol_hdr_cnt <= '0';
                            clr_hdr_cnt     <= '1';
                            zeroes_en_int   <= "10";  -- Set enable for data csum to insert zeroes into calculation
                            fcsum_wr_ns     <= DATA;

              when others=> en_pcol_hdr_cnt <= '1';
                            clr_hdr_cnt     <= '0';
                            zeroes_en_int   <= "00";
                            fcsum_wr_ns     <= PCOL_HDR;
            end case;
          else
            en_pcol_hdr_cnt     <= '0';
            clr_hdr_cnt         <= '0';
            zeroes_en_int       <= "00";
            fsm_csum_en         <= '0';
            fsm_csum_en_b32_int <= "00";
            fsm_csum_en_b10_int <= "00";
            fcsum_wr_ns         <= PCOL_HDR;
          end if;

        when DATA     =>
          if csum_calc_en = '1' and udp_ptcl_int = '1' and hdr_cnt = "000" then
            zeroes_en_int   <= "01";
            en_pcol_hdr_cnt <= '1';
          else
            zeroes_en_int   <= "00";
            en_pcol_hdr_cnt <= '0';
          end if;

          if txd_tlast = '1' and csum_calc_en = '1' then
            fsm_csum_en         <= '1';
            fsm_csum_en_b32_int <= txd_strbs(3 downto 2);
            fsm_csum_en_b10_int <= txd_strbs(1 downto 0);
            fcsum_wr_ns         <= WR_HDR;
          elsif txd_tlast = '0' and csum_calc_en = '1' then
            fsm_csum_en         <= '1';
            fsm_csum_en_b32_int <= "11";
            fsm_csum_en_b10_int <= "11";
            fcsum_wr_ns         <= DATA;
          else
            fsm_csum_en         <= '0';
            fsm_csum_en_b32_int <= "00";
            fsm_csum_en_b10_int <= "00";
            fcsum_wr_ns         <= DATA;
          end if;

        when WAIT_TLAST =>
          --  Need to wait for TLAST before completing the CSUM
          if csum_calc_en = '1' then
            case hdr_cnt is
              --  need to assert the header csum enable to include the last bytes
              when "000" =>
                calc_frm_length       <= '0';
                store_sa_da           <= '1';
                en_ipv4_hdr_cnt       <= '0';
                en_ipv4_hdr_b10_int   <= "11";
                en_ipv4_hdr_b32_int   <= "00";
                last_ipv4_hdr_cnt_int <= '1';
                en_pcol_hdr_cnt       <= '1';
                zeroes_en_int         <= "00";
                clr_hdr_cnt           <= '0';
                clr_csums_int         <= '0';
                abort_csum_int        <= '0';
              when others =>
                calc_frm_length       <= '0';
                store_sa_da           <= '0';
                en_ipv4_hdr_cnt       <= '0';
                en_ipv4_hdr_b10_int   <= "00";
                en_ipv4_hdr_b32_int   <= "00";
                last_ipv4_hdr_cnt_int <= '0';
                en_pcol_hdr_cnt       <= '0';
                zeroes_en_int         <= "00";
                clr_hdr_cnt           <= '0';
                clr_csums_int         <= '0';
                abort_csum_int        <= '0';
            end case;
          else
            calc_frm_length       <= '0';
            store_sa_da           <= '0';
            en_ipv4_hdr_cnt       <= '0';
            en_ipv4_hdr_b10_int   <= "00";
            en_ipv4_hdr_b32_int   <= "00";
            last_ipv4_hdr_cnt_int <= '0';
            en_pcol_hdr_cnt       <= '0';
            zeroes_en_int         <= "00";
            clr_hdr_cnt           <= '0';
            clr_csums_int         <= '0';
            abort_csum_int        <= '0';
          end if;

          if txd_tlast = '1' and csum_calc_en = '1' then
          --  Do one of two branches depending upon if the ipv4 header csum was calculated or not
            if do_ipv4_int = '1' then
              add_psdo_wd_int     <= '0';
              fcsum_wr_ns         <= WAIT_DELAY;
            else
              add_psdo_wd_int     <= '1';         --  pseudo word is not done, but this needs to set
                                                  --  ptcl_csum_cmplt and exit tx_csum_full_if.vhd FSMs
              fcsum_wr_ns         <= WAIT_COMPLETE;
            end if;
          else
            fcsum_wr_ns         <= WAIT_TLAST;
          end if;

        when WAIT_DELAY =>
        --  need to delay 1 clock so inc_txd_wr_one does not occur with wr_hdr_csum
          fcsum_wr_ns         <= WR_HDR_ONLY;

        when WR_HDR_ONLY =>
--          --  Got here from IPV4_HDR state so need to enable en_ipv4_hdr_b10_int for last IPv4 header data
--          case hdr_cnt is
--            when "000" =>
--              calc_frm_length       <= '0';
--              store_sa_da           <= '1';
--              en_ipv4_hdr_cnt       <= '0';
--              en_ipv4_hdr_b10_int   <= "11";
--              en_ipv4_hdr_b32_int   <= "00";
--              last_ipv4_hdr_cnt_int <= '1';
--              en_pcol_hdr_cnt       <= '1';
--              zeroes_en_int         <= "00";
--              clr_hdr_cnt           <= '0';
--              clr_csums_int         <= '0';
--              abort_csum_int        <= '0';
--            when others =>
--              calc_frm_length       <= '0';
--              store_sa_da           <= '0';
--              en_ipv4_hdr_cnt       <= '0';
--              en_ipv4_hdr_b10_int   <= "00";
--              en_ipv4_hdr_b32_int   <= "00";
--              last_ipv4_hdr_cnt_int <= '0';
--              en_pcol_hdr_cnt       <= '0';
--              zeroes_en_int         <= "00";
--              clr_hdr_cnt           <= '0';
--              clr_csums_int         <= '0';
--              abort_csum_int        <= '0';
--          end case;

          if hdr_csum_cmplt = '1' then
            wr_hdr_csum         <= '1';
            clr_hdr_cnt         <= '0';
            clr_csums_int       <= '0';
            add_psdo_wd_int     <= '1';           --  pseudo word is not done, but this needs to set
                                                  --  ptcl_csum_cmplt and exit tx_csum_full_if.vhd FSMs
            fcsum_wr_ns         <= WAIT_COMPLETE;
          else
            wr_hdr_csum         <= '0';
            clr_hdr_cnt         <= '0';
            add_psdo_wd_int     <= '0';
            clr_csums_int       <= '0';
            fcsum_wr_ns         <= WR_HDR_ONLY;
          end if;

        when WAIT_COMPLETE   =>
--          if ipv4 = '1' and hdr_cnt = "000" then
--          --  true if got here from IPV4_HDR state
--          --    so enable en_ipv4_hdr_b10_int to get last IPv4 header data
--            calc_frm_length       <= '0';
--            store_sa_da           <= '1';
--            en_ipv4_hdr_cnt       <= '0';
--            en_ipv4_hdr_b10_int   <= "11";
--            en_ipv4_hdr_b32_int   <= "00";
--            last_ipv4_hdr_cnt_int <= '1';
--            en_pcol_hdr_cnt       <= '1';
--            zeroes_en_int         <= "00";
--            clr_hdr_cnt           <= '0';
--            clr_csums_int         <= '0';
--            abort_csum_int        <= '0';
--            fcsum_wr_ns           <= WAIT_COMPLETE;
--          elsif ptcl_csum_cmplt = '1' then
          if ptcl_csum_cmplt = '1' then
            clr_hdr_cnt   <= '1';
            clr_csums_int <= '1';
            abort_csum_int<= '1';
            fcsum_wr_ns   <= IDLE;
          else
            clr_hdr_cnt   <= '0';
            clr_csums_int <= '0';
            abort_csum_int<= '0';
            fcsum_wr_ns   <= WAIT_COMPLETE;
          end if;
        when WR_HDR   =>
          if hdr_csum_cmplt = '1' and (tcp_ptcl_int = '1' or udp_ptcl_int = '1') and fragment = '0' then
            wr_hdr_csum         <= '1';
            clr_csums_int       <= '0';
            add_psdo_wd_int     <= '1';
            fsm_csum_en         <= '1';
            fsm_csum_en_b32_int <= "11";
            fsm_csum_en_b10_int <= "11";
            fcsum_wr_ns         <= WR_CSUM;
          else
            wr_hdr_csum         <= '0';
            clr_csums_int       <= '0';
            add_psdo_wd_int     <= '0';
            fsm_csum_en         <= '0';
            fsm_csum_en_b32_int <= "00";
            fsm_csum_en_b10_int <= "00";
            fcsum_wr_ns         <= WR_HDR;
          end if;
        when WR_CSUM  =>
          if ptcl_csum_cmplt = '1' then
            clr_hdr_cnt  <= '1';
            wr_ptcl_csum <= '1';
            clr_csums_int<= '1';
            fcsum_wr_ns  <= IDLE;
          else
            clr_hdr_cnt  <= '0';
            wr_ptcl_csum <= '0';
            clr_csums_int<= '0';
            fcsum_wr_ns  <= WR_CSUM;
          end if;
        when others =>
          fcsum_wr_ns  <= IDLE;
      end case;
    end process;

    -----------------------------------------------------------------------
    --  FSM Sequencer
    -----------------------------------------------------------------------
    FSM_FULL_CSUM_SEQ : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' then
          fcsum_wr_cs <= IDLE;
        else
          fcsum_wr_cs <= fcsum_wr_ns;
        end if;
      end if;
    end process;



    ---------------------------------------------------------------------------
    --  At store_hdr_length, din contains the header length in words...
    --  Convert it to bytes
    --    IPv4 Header options are not currently supported, so this must
    --    equal 0x5wds (0x14bytes) for the CSUM to be calculated
    ---------------------------------------------------------------------------
    ETHERNET_HEADER_LENGTH_REG : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          hdr_length <= (others => '0');
        else
          if store_hdr_length = '1' then
            hdr_length <= din(19 downto  16) & "00";
            -- converted to bytes from words
          else
            hdr_length <= hdr_length;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Store the version
    --    IPv4 = 0x4
    ---------------------------------------------------------------------------
    ETHERNET_VERSION_REG : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          version <= (others => '0');
        else
          if store_version = '1' then
            version <= din(23 downto  20);
          else
            version <= version;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Counter used for micsellaneous functions in the FSM
    ---------------------------------------------------------------------------
    ETHERNET_HEADER_CNT: process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_hdr_cnt = '1' then
          hdr_cnt <= (others => '0');
        else
          if en_ipv4_hdr_cnt  = '1' or en_pcol_hdr_cnt = '1' then
            hdr_cnt <= hdr_cnt + 1;
          else
            hdr_cnt <= hdr_cnt;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  For TCP length for the Pseudo header
    --    At calc_frm_length, din_big_end contains the total length of
    --      the packet starting from the IPv4 header to the end of the packet.
    --      Subtract off the IPv4 Header Length (should be 5 words / 20 bytes
    --      to get the TCP Length for the pseudo header
    ---------------------------------------------------------------------------
    ETHERNET_FRAME_LENGTH: process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          frm_length <= (others => '0');
        else
          if calc_frm_length = '1' then
          -- This is asserted for both TCP and UDP
          -- This is stored BIG Endian
            frm_length <= din_big_end(0 to 15) - hdr_length;
          else
            frm_length <= frm_length;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Store this information for the Pseudo Header
    --    Pseudo Header:   ________________________________
    --              Wd 0  |______ IP Source Address ______|
    --              Wd 1  |___ IP Destination Address ____|
    --              Wd 2  |__ 0 __|_PCOL _|_ TCP Length __|
    --
    ---------------------------------------------------------------------------
    ETHERNET_SA0: process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          sa0 <= (others => '0');
        else
          if store_sa_da = '1' and hdr_cnt = "011" then
            sa0 <= din(31 downto 16);
          else
            sa0 <= sa0;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Store this information for the Pseudo Header
    --    Pseudo Header:   ________________________________
    --              Wd 0  |______ IP Source Address ______|
    --              Wd 1  |___ IP Destination Address ____|
    --              Wd 2  |__ 0 __|_PCOL _|_ TCP Length __|
    --
    ---------------------------------------------------------------------------
    ETHERNET_SA1_DA0: process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          sa1 <= (others => '0');
          da0 <= (others => '0');
        else
          if store_sa_da = '1' and hdr_cnt = "100" then
            sa1 <= din(15 downto  0);
            da0 <= din(31 downto 16);
          else
            sa1 <= sa1;
            da0 <= da0;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Store this information for the Pseudo Header which is 32-bits x 3 deep
    --    Pseudo Header:   ________________________________
    --              Wd 0  |______ IP Source Address ______|
    --              Wd 1  |___ IP Destination Address ____|
    --              Wd 2  |__ 0 __|_PCOL _|_ TCP Length __|
    --
    ---------------------------------------------------------------------------
    ETHERNET_DA_HALF: process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          da1 <= (others => '0');
        else
          if store_sa_da = '1' and hdr_cnt = "000" then
            da1 <= din(15 downto  0);
          else
            da1 <= da1;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Set and hold the Pseudo Header information
    --    Big Endian Pseudo Header:    ________________________________
    --                          Wd 0  |______ IP Source Address ______|
    --                          Wd 1  |___ IP Destination Address ____|
    --                          Wd 2  |__ 0 __|_PCOL _|_ TCP Length __|
    --                  Wd 2 Example {| 0x00  | 0x06  | 0x01  | 0xFF  | }
    --
    --    Little Endian Pseudo Header: ________________________________
    --                          Wd 0  |______ IP Source Address ______|
    --                          Wd 1  |___ IP Destination Address ____|
    --                          Wd 2  |_ TCP Length __|_PCOL _|__ 0 __|
    --                  Wd 2 Example {| 0xFF  | 0x01  | 0x06  | 0x00  | }
    --
    --
    ---------------------------------------------------------------------------
    PSEUDO_HDR_WD2 : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          pseudo_data        <= (others => '0');
        else
          if tcp_ptcl_int = '1' then
          --  put back to little endian before write to BRAM
            pseudo_data       <= frm_length(8 to 15) & frm_length(0 to 7) &  X"06" & X"00";
          elsif udp_ptcl_int = '1' and calc_frm_length = '1' then
            pseudo_data       <= din(31 downto 16) & X"11" & X"00";
          else
            pseudo_data       <= pseudo_data;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  At the end of the packet, mux in the Pseudo data Wd 2 to be calculated
    --  in the CSUM.  The CSUM Actually starts with IP Source Address,
    --  but adds this word in last.
    --
    --  This is done last for commanality between TCP and UDP, since for UDP
    --  the Length is provided in the UDP Header which occurs after the CSUM
    --  starts.  In both TCP and UDP the CSUM starts at the IP Source Address
    --    Pseudo Header:   ________________________________
    --              Wd 0  |______ IP Source Address ______|
    --              Wd 1  |___ IP Destination Address ____|
    --              Wd 2  |__ 0 __|_PCOL _|_ TCP Length __|
    --
    ---------------------------------------------------------------------------
    CMB_CSUM_DIN_MUX : process (add_psdo_wd_int,pseudo_data,din)
    begin

      if add_psdo_wd_int = '1' and not_tcp_udp_int = '0' then
        csum_din <= pseudo_data;
      else
        csum_din <= din;
      end if;
    end process;


    ---------------------------------------------------------------------------
    --  Set the Ethernet II flag indicator which is used to determine if
    --  the Full CSUM will be calculated.
    ---------------------------------------------------------------------------
    ETHERNET_II_REG : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          eth2 <= '0';
        else
          if set_eth2 = '1' then
            eth2 <= '1';
          else
            eth2 <= eth2;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Set the Subnetwork Access Protocol (SNAP) Frame flag indicator which
    --  is used to determine if the Full CSUM will be calculated.
    ---------------------------------------------------------------------------
    ETHERNET_SNAP_REG : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          snap_hit <= '0';
        else
          if set_snap = '1' then
            snap_hit <= '1';
          else
            snap_hit <= snap_hit;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Set the SNAP Frame Organizationally Unique Identifier (OUI) flag
    --  indicator which is used to determine if the Full CSUM will be
    --  calculated.
    ---------------------------------------------------------------------------
    ETHERNET_SNAP_OUI_REG : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          oui_hit <= '0';
        else
          if set_oui_hit = '1' then
            oui_hit <= '1';
          else
            oui_hit <= oui_hit;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Set the VLAN flag indicator which is used to determine if the Full
    --  CSUM will be calculated.
    ---------------------------------------------------------------------------
    ETHERNET_VLAN_REG : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          vlan <= '0';
        else
          if set_vlan = '1' then
            vlan <= '1';
          else
            vlan <= vlan;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Set the IPv4 protocol flag indicator which is used to determine if the
    --  Full CSUM will be calculated.
    ---------------------------------------------------------------------------
    ETHERNET_IPV4_REG : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          ipv4 <= '0';
        else
          if set_ipv4 = '1' then
            ipv4 <= '1';
          else
            ipv4 <= ipv4;
          end if;
        end if;
      end if;
    end process;


    ---------------------------------------------------------------------------
    --  Set the enable to write the IPv4 header CSUM when it is time.
    ---------------------------------------------------------------------------
    DO_IPV4_HEADER : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          do_ipv4_int <= '0';
        else
          if set_ipv4hdr_only = '1' then --or do_full_csum_int = '1' then
            do_ipv4_int <= '1';
          else
            do_ipv4_int <= do_ipv4_int;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Set flag to do IPv4 header csum even though there is not a tcp or udp
    --  protocol
    ---------------------------------------------------------------------------
    IPV4_HDRCSUM_NO_PTCL : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          not_tcp_udp_int <= '0';
        elsif set_not_tcp_udp = '1' then
          not_tcp_udp_int <= '1';
        else
          not_tcp_udp_int <= not_tcp_udp_int;
        end if;
      end if;
    end process;


    ---------------------------------------------------------------------------
    --  Set the TCP protocol flag indicator which is used to determine if the
    --  Full CSUM will be calculated.
    ---------------------------------------------------------------------------
    ETHERNET_TCP_REG : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          tcp_ptcl_int <= '0';
        else
          if set_ptcl = '1' and din(31 downto 24) = X"06" then
            tcp_ptcl_int <= '1';
          else
            tcp_ptcl_int <= tcp_ptcl_int;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Set the UDP protocol flag indicator which is used to determine if the
    --  Full CSUM will be calculated.
    ---------------------------------------------------------------------------
    ETHERNET_UDP_REG : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          udp_ptcl_int <= '0';
        else
          if set_ptcl = '1' and din(31 downto  24) = X"11" then
            udp_ptcl_int <= '1';
          else
            udp_ptcl_int <= udp_ptcl_int;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Set the Fragment flag indicator which is used to determine if the
    --  Full CSUM will be calculated.
    --    Fragment currrently are not supported
    ---------------------------------------------------------------------------
    ETHERNET_FRAGMENT : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          fragment <= '0';
        else
          if set_fragment = '1' then
            fragment <= '1';
          else
            fragment <= fragment;
          end if;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Indicates all of the conditions were not met to perform the CSUM
    ---------------------------------------------------------------------------
--    ABORT_CHECKSUM : process(AXI_STR_TXD_ACLK)
--    begin

--      if rising_edge(AXI_STR_TXD_ACLK) then
        abort_csum <= abort_csum_int;
--      end if;
--    end process;



    ---------------------------------------------------------------------------
    --  Calculate the IPv4 Header CSUM address offsets
    --    Numerous flags are used to determine the offset
    --    Also set the BRAM write enable appropriately
    ---------------------------------------------------------------------------
    CSUM_IPV4HDR_ADDR : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          csum_ipv4_hdr_addr_int <= (others => '0');
          csum_ipv4_hdr_we_int   <= (others => '0');
        elsif clr_hdr_cnt = '1' and store_sa_da = '1' and ipv4 = '1' then
          if vlan = '1' and eth2 = '1' then
            csum_ipv4_hdr_addr_int <= csum_strt_addr + 7;
            csum_ipv4_hdr_we_int   <= "0011";
          elsif vlan = '1' and snap_hit = '1' and oui_hit = '1' then
            csum_ipv4_hdr_addr_int <= csum_strt_addr + 9;
            csum_ipv4_hdr_we_int   <= "0011";
          elsif vlan = '0' and eth2 = '1' then
            csum_ipv4_hdr_addr_int <= csum_strt_addr + 6;
            csum_ipv4_hdr_we_int   <= "0011";
          elsif vlan = '0' and snap_hit = '1' and oui_hit = '1' then
            csum_ipv4_hdr_addr_int <= csum_strt_addr + 8;
            csum_ipv4_hdr_we_int   <= "0011";
          else
            csum_ipv4_hdr_addr_int <= csum_ipv4_hdr_addr_int;
            csum_ipv4_hdr_we_int   <= csum_ipv4_hdr_we_int;
          end if;
        else
          csum_ipv4_hdr_addr_int <= csum_ipv4_hdr_addr_int;
          csum_ipv4_hdr_we_int   <= csum_ipv4_hdr_we_int;
        end if;
      end if;
    end process;

    ---------------------------------------------------------------------------
    --  Calculate the IPv4 TCP/UDP CSUM address offsets
    --    Numerous flags are used to determine the offset
    --    Also set the BRAM write enable appropriately
    ---------------------------------------------------------------------------
    CSUM_IPV4PTCL_ADDR : process(AXI_STR_TXD_ACLK)
    begin

      if rising_edge(AXI_STR_TXD_ACLK) then
        if reset2axi_str_txd = '1' or clr_csums_int = '1' then
          do_full_csum_int       <= '0';
          csum_ptcl_addr_int     <= (others => '0');
          csum_ptcl_we_int       <= (others => '0');
        elsif clr_hdr_cnt = '1' and store_sa_da = '1' and ipv4 = '1' then
          if vlan = '1' and eth2 = '1' and tcp_ptcl_int = '1' and
             fragment = '0' then
            do_full_csum_int       <= '1';
            csum_ptcl_addr_int     <= csum_strt_addr + 13;
            csum_ptcl_we_int       <= "1100";
          elsif vlan = '1' and eth2 = '1' and udp_ptcl_int = '1' and
                fragment = '0' then
            do_full_csum_int       <= '1';
            csum_ptcl_addr_int     <= csum_strt_addr + 11;
            csum_ptcl_we_int       <= "0011";
          elsif vlan = '1' and snap_hit = '1' and oui_hit = '1' and tcp_ptcl_int = '1' and
                fragment = '0' then
            do_full_csum_int       <= '1';
            csum_ptcl_addr_int     <= csum_strt_addr + 15;
            csum_ptcl_we_int       <= "1100";
          elsif vlan = '1' and snap_hit = '1' and oui_hit = '1' and udp_ptcl_int = '1' and
                fragment = '0' then
            do_full_csum_int       <= '1';
            csum_ptcl_addr_int     <= csum_strt_addr + 13;
            csum_ptcl_we_int       <= "0011";
          elsif vlan = '0' and eth2 = '1' and tcp_ptcl_int = '1' and
                fragment = '0' then
            do_full_csum_int       <= '1';
            csum_ptcl_addr_int     <= csum_strt_addr + 12;
            csum_ptcl_we_int       <= "1100";
          elsif vlan = '0' and eth2 = '1' and udp_ptcl_int = '1' and
                fragment = '0' then
            do_full_csum_int       <= '1';
            csum_ptcl_addr_int     <= csum_strt_addr + 10;
            csum_ptcl_we_int       <= "0011";
          elsif vlan = '0' and snap_hit = '1' and oui_hit = '1' and tcp_ptcl_int = '1' and
                fragment = '0' then
            do_full_csum_int       <= '1';
            csum_ptcl_addr_int     <= csum_strt_addr + 14;
            csum_ptcl_we_int       <= "1100";
          elsif vlan = '0' and snap_hit = '1' and oui_hit = '1' and udp_ptcl_int = '1' and
                fragment = '0' then
            do_full_csum_int       <= '1';
            csum_ptcl_addr_int     <= csum_strt_addr + 12;
            csum_ptcl_we_int       <= "0011";
          else
            do_full_csum_int       <= do_full_csum_int;
            csum_ptcl_addr_int     <= csum_ptcl_addr_int;
            csum_ptcl_we_int       <= csum_ptcl_we_int;
          end if;
        else
          do_full_csum_int       <= do_full_csum_int;
          csum_ptcl_addr_int     <= csum_ptcl_addr_int;
          csum_ptcl_we_int       <= csum_ptcl_we_int;
        end if;
      end if;
    end process;


end rtl;
