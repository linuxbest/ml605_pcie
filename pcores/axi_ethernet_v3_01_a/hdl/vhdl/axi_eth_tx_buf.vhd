library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library axi_ethernet_v3_01_a;
use axi_ethernet_v3_01_a.all;

entity axi_eth_tx_buf is
  port (
    clk			     : in  std_logic;
    reset                    : in  std_logic;

    AXI_STR_TXD_TVALID       : in  std_logic;                           --  AXI-Stream Transmit Data Valid
    AXI_STR_TXD_TREADY       : out std_logic;                           --  AXI-Stream Transmit Data Ready
    AXI_STR_TXD_TLAST        : in  std_logic;                           --  AXI-Stream Transmit Data Last
    AXI_STR_TXD_TKEEP        : in  std_logic_vector(7 downto 0);        --  AXI-Stream Transmit Data Keep
    AXI_STR_TXD_TDATA        : in  std_logic_vector(63 downto 0);       --  AXI-Stream Transmit Data Data

    AXI_STR_TXC_TVALID       : in  std_logic;                           --  AXI-Stream Transmit Control Valid
    AXI_STR_TXC_TREADY       : out std_logic;                           --  AXI-Stream Transmit Control Ready
    AXI_STR_TXC_TLAST        : in  std_logic;                           --  AXI-Stream Transmit Control Last
    AXI_STR_TXC_TKEEP        : in  std_logic_vector(3 downto 0);        --  AXI-Stream Transmit Control Keep
    AXI_STR_TXC_TDATA        : in  std_logic_vector(31 downto 0);       --  AXI-Stream Transmit Control Data

    AXIS_ETH_TXD_TVALID      : out std_logic;                           --  AXIS Ethernet Transmit Data Valid
    AXIS_ETH_TXD_TREADY      : in  std_logic;                           --  AXIS Ethernet Transmit Data Ready
    AXIS_ETH_TXD_TLAST       : out std_logic;                           --  AXIS Ethernet Transmit Data Last
    AXIS_ETH_TXD_TKEEP       : out std_logic_vector(7 downto 0);        --  AXIS Ethernet Transmit Data Keep
    AXIS_ETH_TXD_TDATA       : out std_logic_vector(63 downto 0);       --  AXIS Ethernet Transmit Data Data

    AXIS_ETH_TXC_TVALID      : out std_logic;                           --  AXIS Ethernet Transmit Control Valid
    AXIS_ETH_TXC_TREADY      : in  std_logic;                           --  AXIS Ethernet Transmit Control Ready
    AXIS_ETH_TXC_TLAST       : out std_logic;                           --  AXIS Ethernet Transmit Control Last
    AXIS_ETH_TXC_TKEEP       : out std_logic_vector(3 downto 0);        --  AXIS Ethernet Transmit Control Keep
    AXIS_ETH_TXC_TDATA       : out std_logic_vector(31 downto 0)        --  AXIS Ethernet Transmit Control Data
  );
end axi_eth_tx_buf;

architecture rtl of axi_eth_tx_buf is

component txd_fifo
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (72 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (72 DOWNTO 0)
	);
end component;

component txc_fifo
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (36 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (36 DOWNTO 0)
	);
end component;

signal	txd_fifo_data		:	std_logic_vector(72 downto 0);
signal	txd_fifo_rdreq		:	std_logic;
signal	txd_fifo_wrreq		:	std_logic;
signal	txd_fifo_empty		:	std_logic;
signal	txd_fifo_full		:	std_logic;
signal	txd_fifo_q		:	std_logic_vector(72 downto 0);
signal	txc_fifo_data		:	std_logic_vector(36 downto 0);
signal	txc_fifo_rdreq		:	std_logic;
signal	txc_fifo_wrreq		:	std_logic;
signal	txc_fifo_empty		:	std_logic;
signal	txc_fifo_full		:	std_logic;
signal	txc_fifo_q		:	std_logic_vector(36 downto 0);

signal  TXC_TXDn_flag		:	std_logic;
signal  AXIS_ETH_TXD_TVALID_int	:	std_logic;
signal  AXIS_ETH_TXC_TVALID_int :	std_logic;
signal  AXIS_ETH_TXD_TLAST_int	:	std_logic;
signal  AXIS_ETH_TXC_TLAST_int  :	std_logic;

begin

process (clk, reset)
begin
	if (reset = '1') then
		TXC_TXDn_flag   <=   '1';
	elsif (clk'event and clk='1') then
		if (AXIS_ETH_TXC_TVALID_int='1' and AXIS_ETH_TXC_TREADY='1' and AXIS_ETH_TXC_TLAST_int='1') then
			TXC_TXDn_flag   <=   '0';
		elsif (AXIS_ETH_TXD_TVALID_int='1' and AXIS_ETH_TXD_TREADY='1' and AXIS_ETH_TXD_TLAST_int='1') then
			TXC_TXDn_flag   <=   '1';
		end if;
	end if;
end process;

-- AXI Stream TXD Write Data Path
AXI_STR_TXD_TREADY		<=   not txd_fifo_full;
txd_fifo_wrreq			<=   AXI_STR_TXD_TVALID and (not txd_fifo_full);
txd_fifo_data(72)		<=   AXI_STR_TXD_TLAST;
txd_fifo_data(71 downto 64)	<=   AXI_STR_TXD_TKEEP;
txd_fifo_data(63 downto 0)	<=   AXI_STR_TXD_TDATA;

-- AXI Ethernet Stream TXD Read Data Path
AXIS_ETH_TXD_TVALID      	<=   AXIS_ETH_TXD_TVALID_int;
AXIS_ETH_TXD_TVALID_int		<=   (not txd_fifo_empty) and (not TXC_TXDn_flag);
txd_fifo_rdreq			<=   AXIS_ETH_TXD_TVALID_int and AXIS_ETH_TXD_TREADY;
AXIS_ETH_TXD_TLAST		<=   AXIS_ETH_TXD_TLAST_int;
AXIS_ETH_TXD_TLAST_int       	<=   txd_fifo_q(72);
AXIS_ETH_TXD_TKEEP       	<=   txd_fifo_q(71 downto 64);
AXIS_ETH_TXD_TDATA		<=   txd_fifo_q(63 downto 0);

Inst_txd_fifo : txd_fifo PORT MAP (
		aclr	 	=> 	reset,
		clock	 	=> 	clk,
		data	 	=> 	txd_fifo_data,
		rdreq	 	=> 	txd_fifo_rdreq,
		wrreq	 	=> 	txd_fifo_wrreq,
		empty	 	=> 	txd_fifo_empty,
		full	 	=> 	txd_fifo_full,
		q	 	=> 	txd_fifo_q
	);

-- AXI Stream TXC Write Data Path
AXI_STR_TXC_TREADY		<=   not txc_fifo_full;
txc_fifo_wrreq			<=   AXI_STR_TXC_TVALID and (not txc_fifo_full);
txc_fifo_data(36)		<=   AXI_STR_TXC_TLAST;
txc_fifo_data(35 downto 32)	<=   AXI_STR_TXC_TKEEP;
txc_fifo_data(31 downto 0)	<=   AXI_STR_TXC_TDATA;

-- AXI Ethernet Stream TXC Read Data Path
AXIS_ETH_TXC_TVALID      	<=   AXIS_ETH_TXC_TVALID_int;
AXIS_ETH_TXC_TVALID_int  	<=   (not txc_fifo_empty) and TXC_TXDn_flag;
txc_fifo_rdreq		 	<=   AXIS_ETH_TXC_TVALID_int and AXIS_ETH_TXC_TREADY;
AXIS_ETH_TXC_TLAST		<=   AXIS_ETH_TXC_TLAST_int;
AXIS_ETH_TXC_TLAST_int       	<=   txc_fifo_q(36);
AXIS_ETH_TXC_TKEEP       	<=   txc_fifo_q(35 downto 32);
AXIS_ETH_TXC_TDATA       	<=   txc_fifo_q(31 downto 0);

Inst_txc_fifo : txc_fifo PORT MAP (
		aclr	 	=> 	reset,
		clock	 	=> 	clk,
		data	 	=> 	txc_fifo_data,
		rdreq	 	=> 	txc_fifo_rdreq,
		wrreq	 	=> 	txc_fifo_wrreq,
		empty	 	=> 	txc_fifo_empty,
		full	 	=> 	txc_fifo_full,
		q	 	=> 	txc_fifo_q
	);

end rtl;
