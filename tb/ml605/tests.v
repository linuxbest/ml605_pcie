else if(testname == "pio_writeReadBack_test0")
begin

ml605_pcie_tb.RP.tx_usrapp.TSK_SIMULATION_TIMEOUT(10050);
ml605_pcie_tb.RP.tx_usrapp.TSK_SYSTEM_INITIALIZATION;
ml605_pcie_tb.RP.tx_usrapp.TSK_BAR_INIT;

$display("[%t] : PCIE Init Done", $realtime);

// Enable Mem, BusMstr in the Command Register
ml605_pcie_tb.RP.cfg_usrapp.TSK_READ_CFG_DW(32'h00000001);
ml605_pcie_tb.RP.cfg_usrapp.TSK_WRITE_CFG_DW(32'h00000001, 32'h00000007, 4'b1110);
ml605_pcie_tb.RP.cfg_usrapp.TSK_READ_CFG_DW(32'h00000001);

// WRITE AXI DMA SPACE
ml605_pcie_tb.RP.tx_usrapp.DATA_STORE[0] = 8'h04;
ml605_pcie_tb.RP.tx_usrapp.DATA_STORE[1] = 8'h03;
ml605_pcie_tb.RP.tx_usrapp.DATA_STORE[2] = 8'h02;
ml605_pcie_tb.RP.tx_usrapp.DATA_STORE[3] = 8'h01;

ml605_pcie_tb.RP.tx_usrapp.TSK_TX_MEMORY_WRITE_32(
	ml605_pcie_tb.RP.tx_usrapp.DEFAULT_TAG,
	ml605_pcie_tb.RP.tx_usrapp.DEFAULT_TC, 
	10'd1,
	ml605_pcie_tb.RP.tx_usrapp.BAR_INIT_P_BAR[0][31:0]+8'h10,
	4'h0,
	4'hF,
	1'b0);

ml605_pcie_tb.RP.tx_usrapp.TSK_TX_CLK_EAT(10);
ml605_pcie_tb.RP.tx_usrapp.DEFAULT_TAG = ml605_pcie_tb.RP.tx_usrapp.DEFAULT_TAG + 1;

// READ AXI DMA SPACE
ml605_pcie_tb.RP.tx_usrapp.P_READ_DATA = 32'hffff_ffff;
fork
	ml605_pcie_tb.RP.tx_usrapp.TSK_TX_MEMORY_READ_32(
		ml605_pcie_tb.RP.tx_usrapp.DEFAULT_TAG,
		ml605_pcie_tb.RP.tx_usrapp.DEFAULT_TC, 10'd1,
		ml605_pcie_tb.RP.tx_usrapp.BAR_INIT_P_BAR[0][31:0]+8'h10, 
		4'h0, 
		4'hF);
	ml605_pcie_tb.RP.tx_usrapp.TSK_WAIT_FOR_READ_DATA;
join

$display("[%t] : %x", ml605_pcie_tb.RP.tx_usrapp.P_READ_DATA, $realtime);

ml605_pcie_tb.RP.tx_usrapp.TSK_TX_CLK_EAT(10);
ml605_pcie_tb.RP.tx_usrapp.DEFAULT_TAG = ml605_pcie_tb.RP.tx_usrapp.DEFAULT_TAG + 1;

// WRITE AXI AES MEM 
ml605_pcie_tb.RP.tx_usrapp.TSK_TX_MEMORY_WRITE_32(
	ml605_pcie_tb.RP.tx_usrapp.DEFAULT_TAG,
	ml605_pcie_tb.RP.tx_usrapp.DEFAULT_TC, 
	10'd1,
	ml605_pcie_tb.RP.tx_usrapp.BAR_INIT_P_BAR[0][31:0]+8'h1_000,
	4'h0,
	4'hF,
	1'b0);
ml605_pcie_tb.RP.tx_usrapp.TSK_TX_CLK_EAT(10);
ml605_pcie_tb.RP.tx_usrapp.DEFAULT_TAG = ml605_pcie_tb.RP.tx_usrapp.DEFAULT_TAG + 1;

ml605_pcie_tb.RP.tx_usrapp.TSK_TX_CLK_EAT(100);
$display("[%t] : Test done", $realtime);
$finish(0);

end
