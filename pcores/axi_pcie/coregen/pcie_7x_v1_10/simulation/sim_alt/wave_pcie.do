if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }

set pcie "/board/EP/app/PIO/altpcie_avl/altpciexpav128_app"

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -ascii}

eval add wave -noupdate -divider {"PCIE stream RX"}
eval add wave -noupdate $binopt $pcie${ps}rx${ps}Clk_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}Rstn_i

eval add wave -noupdate $binopt $pcie${ps}rx${ps}RxStReady_o
eval add wave -noupdate $binopt $pcie${ps}rx${ps}RxStMask_o
eval add wave -noupdate $binopt $pcie${ps}rx${ps}RxStSop_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}RxStEop_i
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}RxStData_i(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}RxStData_i(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}RxStData_i(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}RxStData_i(31 downto 0)\"
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}RxStBe_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}RxStEmpty_i
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}RxStBarDec1_i
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}RxStBarDec2_i

eval add wave -noupdate -divider {"PCIE stream RXM0"}
eval add wave -noupdate $binopt $pcie${ps}AvlClk_i
eval add wave -noupdate $binopt $pcie${ps}Rstn_i

eval add wave -noupdate $binopt $pcie${ps}RxmRead_0_o
eval add wave -noupdate $binopt $pcie${ps}RxmWrite_0_o
eval add wave -noupdate $hexopt $pcie${ps}RxmAddress_0_o
eval add wave -noupdate $hexopt \"$pcie${ps}RxmWriteData_0_o(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}RxmWriteData_0_o(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}RxmWriteData_0_o(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}RxmWriteData_0_o(31 downto 0)\"
eval add wave -noupdate $hexopt $pcie${ps}RxmByteEnable_0_o
eval add wave -noupdate $hexopt $pcie${ps}RxmBurstCount_0_o
eval add wave -noupdate $binopt $pcie${ps}RxmWaitRequest_0_i

eval add wave -noupdate $binopt $pcie${ps}RxmReadDataValid_0_i
eval add wave -noupdate $hexopt \"$pcie${ps}RxmReadData_0_i(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}RxmReadData_0_i(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}RxmReadData_0_i(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}RxmReadData_0_i(31 downto 0)\"

eval add wave -noupdate -divider {"PCIE stream Rx Data"}
eval add wave -noupdate $binopt $pcie${ps}rx${ps}Clk_i
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}TxReadData_o(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}TxReadData_o(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}TxReadData_o(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}TxReadData_o(31 downto 0)\"
eval add wave -noupdate $binopt $pcie${ps}rx${ps}TxReadDataValid_o

eval add wave -noupdate -divider {"PCIE RX CNTRL"}
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}Clk_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}Rstn_i

eval add wave -noupdate $ascopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rx_state0_ascii

eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}input_fifo_wrusedw
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}pndgrd_fifo_ok_reg

eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}is_cpl_fifo
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rx_address_lsb_fifo
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}is_cpl_wd_fifo
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}is_msg_wod_fifo
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}is_msg_wd_fifo
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}wr_1dw_fbe_eq_0_fifo
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}is_wr_fifo
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}is_uns_wr_size_fifo
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}is_cpl_wd_fifo
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}is_rd_fifo
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}is_flush_fifo
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}is_uns_rd_size_fifo
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}cpl_tag_fifo

eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}is_wr_hdrreg_0
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}is_rd_hdrreg_0
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}is_cpl_wd_reg_0

eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}cpl_buff_ok
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}is_rx_lite_core
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}is_read_bar_changed
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}TxRespIdle_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}RxRdInProgress_i

eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rx_dw_count_0
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_wait_req

eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_wait_req_fall
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}over_rd_sreg

eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}previous_bar_read
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}bar_hit_reg

eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rx_address_lsb_fifo
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}first_data_phase
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rx_dwlen_fifo
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}tail_mask
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}input_fifo_be_out
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rx_tlp_be_reg

eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}first_data_phase
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}tlp_3dw_header
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_data_reg_clk_ena

eval add wave -noupdate -divider {"RXM adapter"}
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}Clk_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}Rstn_i

eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}state
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}rxm_sop
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}rxm_eop
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}rxm_write
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}rxm_read

eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}fifo_wrreq
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}fifo_rdreq
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}fifo_rdreq_int
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}fifo_wr_data
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}fifo_data_out
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}fifo_count

eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}CoreRxmWrite_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}CoreRxmWriteSOP_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}CoreRxmWriteEOP_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}CoreRxmRead_i
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}CoreRxmBarHit_i
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}CoreRxmAddress_i
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}CoreRxmWriteData_i(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}CoreRxmWriteData_i(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}CoreRxmWriteData_i(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}CoreRxmWriteData_i(31 downto 0)\"
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}CoreRxmByteEnable_i
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}CoreRxmBurstCount_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}CoreRxmWaitRequest_o

#eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}FabricRxmWrite_o
#eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}FabricRxmRead_o
#eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}FabricRxmBarHit_o
#eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}FabricRxmAddress_o
#eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}FabricRxmWriteData_o(127 downto 96)\"
#eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}FabricRxmWriteData_o(95 downto 64)\"
#eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}FabricRxmWriteData_o(63 downto 32)\"
#eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}FabricRxmWriteData_o(31 downto 0)\"
#eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}FabricRxmByteEnable_o
#eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}FabricRxmBurstCount_o
#eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}FabricRxmWaitRequest_i

set axi_bus $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_axi${ps}
set title "RXM AXI"
set name M
do wave_AXI.do

################################
eval add wave -noupdate -divider {"PCIE stream TX"}
eval add wave -noupdate $binopt $pcie${ps}tx${ps}Clk_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}Rstn_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxsRstn_i

eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxStReady_i
#eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxStErr_o
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxStSop_o
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxStEop_o
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxStData_o(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxStData_o(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxStData_o(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxStData_o(31 downto 0)\"
#eval add wave -noupdate $hexopt $pcie${ps}tx${ps}TxStParity_o
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxStEmpty_o
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxAdapterFifoEmpty_i
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}DevCsr_i
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}BusDev_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}CplPending_o

eval add wave -noupdate -divider {"PCIE tx cntrl"}
eval add wave -noupdate $binopt $pcie${ps}tx${ps}tx_cntrl${ps}Clk_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}tx_cntrl${ps}Rstn_i

eval add wave -noupdate $binopt $pcie${ps}tx${ps}tx_cntrl${ps}tlp_dw2_sel
eval add wave -noupdate $binopt $pcie${ps}tx${ps}tx_cntrl${ps}tlp_dw3_sel
eval add wave -noupdate $binopt $pcie${ps}tx${ps}tx_cntrl${ps}is_cpl
eval add wave -noupdate $binopt $pcie${ps}tx${ps}tx_cntrl${ps}tlp_3dw_header
eval add wave -noupdate $binopt $pcie${ps}tx${ps}tx_cntrl${ps}tlp_data_sel
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}tx_cntrl${ps}tx_address_lsb

eval add wave -noupdate $ascopt $pcie${ps}tx${ps}tx_cntrl${ps}tx_state_ascii
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}tx_cntrl${ps}dw_len

eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}tx_cntrl${ps}tx_data(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}tx_cntrl${ps}tx_data(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}tx_cntrl${ps}tx_data(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}tx_cntrl${ps}tx_data(31 downto 0)\"

eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}tx_cntrl${ps}tlp_holding_reg(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}tx_cntrl${ps}tlp_holding_reg(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}tx_cntrl${ps}tlp_holding_reg(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}tx_cntrl${ps}tlp_holding_reg(31 downto 0)\"

eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}tx_cntrl${ps}tlp_buff_data(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}tx_cntrl${ps}tlp_buff_data(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}tx_cntrl${ps}tlp_buff_data(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}tx_cntrl${ps}tlp_buff_data(31 downto 0)\"

eval add wave -noupdate $hexopt $pcie${ps}tx${ps}tx_cntrl${ps}req_header2
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}tx_cntrl${ps}req_header1

eval add wave -noupdate $hexopt $pcie${ps}tx${ps}tx_cntrl${ps}cpl_header2
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}tx_cntrl${ps}cpl_header1

eval add wave -noupdate $hexopt $pcie${ps}tx${ps}tx_cntrl${ps}cmd_header2
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}tx_cntrl${ps}cmd_header1

eval add wave -noupdate $binopt $pcie${ps}tx${ps}tx_cntrl${ps}is_rd
eval add wave -noupdate $binopt $pcie${ps}tx${ps}tx_cntrl${ps}np_header_avail_reg
eval add wave -noupdate $binopt $pcie${ps}tx${ps}tx_cntrl${ps}tag_available_reg
eval add wave -noupdate $binopt $pcie${ps}tx${ps}tx_cntrl${ps}RdBypassFifoEmpty_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}tx_cntrl${ps}output_fifo_ok_reg
eval add wave -noupdate $binopt $pcie${ps}tx${ps}tx_cntrl${ps}is_wr
eval add wave -noupdate $binopt $pcie${ps}tx${ps}tx_cntrl${ps}is_cpl

eval add wave -noupdate -divider {"PCIE stream TXM"}
eval add wave -noupdate $binopt $pcie${ps}tx${ps}Clk_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}Rstn_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxsRstn_i

eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxChipSelect_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxRead_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxWrite_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxWaitRequest_o
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}TxBurstCount_i
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}TxAddress_i

eval add wave -noupdate $hexopt $pcie${ps}tx${ps}TxByteEnable_i
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxWriteData_i(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxWriteData_i(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxWriteData_i(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxWriteData_i(31 downto 0)\"

eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxReadDataValid_i
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxReadData_i(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxReadData_i(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxReadData_i(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxReadData_i(31 downto 0)\"

eval add wave -noupdate $binopt $pcie${ps}tx${ps}RxmIrq_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}MasterEnable_i

eval add wave -noupdate -divider {"PCIE txavl cntrl "}
eval add wave -noupdate $binopt $pcie${ps}tx${ps}txavl${ps}AvlClk_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}txavl${ps}Rstn_i

eval add wave -noupdate $ascopt $pcie${ps}tx${ps}txavl${ps}txavl_state_ascii

eval add wave -noupdate $binopt $pcie${ps}tx${ps}txavl${ps}AvlAddrVld_o
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}txavl${ps}AvlAddr_o

eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}txavl${ps}pci_exp_address(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}txavl${ps}pci_exp_address(31 downto 0)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}txavl${ps}PCIeAddr_i(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}txavl${ps}PCIeAddr_i(31 downto 0)\"
eval add wave -noupdate $binopt $pcie${ps}tx${ps}txavl${ps}AddrTransDone_i

eval add wave -noupdate -divider {"Avalon Master"}
eval add wave -noupdate $binopt $pcie${ps}TxsClk_i
eval add wave -noupdate $binopt $pcie${ps}TxsRstn_i

eval add wave -noupdate $binopt $pcie${ps}TxsChipSelect_i
eval add wave -noupdate $binopt $pcie${ps}TxsRead_i
eval add wave -noupdate $binopt $pcie${ps}TxsWrite_i
eval add wave -noupdate $binopt $pcie${ps}TxsWaitRequest_o
eval add wave -noupdate $hexopt $pcie${ps}TxsBurstCount_i
eval add wave -noupdate $hexopt $pcie${ps}TxsAddress_i

eval add wave -noupdate $hexopt $pcie${ps}TxsByteEnable_i
eval add wave -noupdate $hexopt \"$pcie${ps}TxsWriteData_i(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}TxsWriteData_i(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}TxsWriteData_i(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}TxsWriteData_i(31 downto 0)\"

eval add wave -noupdate $binopt $pcie${ps}TxsReadDataValid_o
eval add wave -noupdate $hexopt \"$pcie${ps}TxsReadData_o(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}TxsReadData_o(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}TxsReadData_o(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}TxsReadData_o(31 downto 0)\"

set axi_bus $pcie${ps}
set title "AXI Slave "
set name S
do wave_AXI.do

#eval add wave -noupdate -divider {"PCIE pndgtxrd_fifo"}
#set scfifo $pcie${ps}rx${ps}pndgtxrd_fifo${ps}pndgtxrd_fifo
#do wave_scfifo.do

#eval add wave -noupdate -divider {"PCIE pndgtxrd_fifo"}
#set scfifo $pcie${ps}rx${ps}pndgtxrd_fifo${ps}pndgtxrd_sc_fifo
#do wave_sc_fifo.do

#eval add wave -noupdate -divider {"PCIE cpl ram"}
#set scfifo $pcie${ps}rx${ps}cpl_ram${ps}cpl_ram
#do wave_asyncram.do

#eval add wave -noupdate -divider {"PCIE cpl tpram"}
#set scfifo $pcie${ps}rx${ps}cpl_ram${ps}cpl_tpram
#do wave_tpram.do

#eval add wave -noupdate -divider {"PCIE txcmd_fifo"}
#set scfifo $pcie${ps}tx${ps}txcmd_fifo
#do wave_scfifo.do

eval add wave -noupdate -divider {"PCIE txcmd_sc_fifo"}
set scfifo $pcie${ps}tx${ps}txcmd_sc_fifo
do wave_sc_fifo.do

#eval add wave -noupdate -divider {"PCIE wrdat_fifo"}
#set scfifo $pcie${ps}tx${ps}wrdat_fifo${ps}wrdat_fifo
#do wave_scfifo.do

#eval add wave -noupdate -divider {"PCIE wrdat_sc_fifo"}
#set scfifo $pcie${ps}tx${ps}wrdat_fifo${ps}wrdat_sc_fifo
#do wave_sc_fifo.do

#eval add wave -noupdate -divider {"PCIE rd_bypass_fifo"}
#set scfifo $pcie${ps}tx${ps}rd_bypass_fifo${ps}rd_bypass_fifo
#do wave_scfifo.do

#eval add wave -noupdate -divider {"PCIE rd_bypass_sc_fifo"}
#set scfifo $pcie${ps}tx${ps}rd_bypass_fifo${ps}rd_bypass_sc_fifo
#do wave_sc_fifo.do

#eval add wave -noupdate -divider {"PCIE cpl ram"}
#set scfifo $pcie${ps}tx${ps}tx_cpl_buff${ps}tx_cpl_buff
#do wave_asyncram.do

#eval add wave -noupdate -divider {"PCIE cpl tpram"}
#set scfifo $pcie${ps}tx${ps}tx_cpl_buff${ps}tx_cpl_tpram
#do wave_tpram.do

eval add wave -noupdate -divider {"PCIE tx_output_fifo"}
set scfifo $pcie${ps}tx${ps}tx_cntrl${ps}tx_output_fifo
do wave_sc_fifo.do
