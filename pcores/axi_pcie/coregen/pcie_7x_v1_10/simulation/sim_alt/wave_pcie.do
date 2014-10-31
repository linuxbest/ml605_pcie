if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }

set pcie "/board/EP/app/PIO/altpciexpav128_app"

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
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}Clk_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}Rstn_i

eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}rxm_adp_state
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}fifo_empty
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}rxm_eop

eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}fifo_wrreq
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}fifo_wr_data
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}fabric_transmit
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}fifo_data_out
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}fifo_count

eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}CoreRxmWrite_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}CoreRxmWriteSOP_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}CoreRxmWriteEOP_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}CoreRxmRead_i
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}CoreRxmBarHit_i
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}CoreRxmAddress_i
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}CoreRxmWriteData_i(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}CoreRxmWriteData_i(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}CoreRxmWriteData_i(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}CoreRxmWriteData_i(31 downto 0)\"
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}CoreRxmByteEnable_i
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}CoreRxmBurstCount_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}CoreRxmWaitRequest_o

eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}FabricRxmWrite_o
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}FabricRxmRead_o
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}FabricRxmBarHit_o
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}FabricRxmAddress_o
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}FabricRxmWriteData_o(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}FabricRxmWriteData_o(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}FabricRxmWriteData_o(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}FabricRxmWriteData_o(31 downto 0)\"
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}FabricRxmByteEnable_o
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}FabricRxmBurstCount_o
eval add wave -noupdate $binopt $pcie${ps}rx${ps}rx_pcie_cntrl${ps}rxm_0${ps}altpciexpav128_rxm_adapter${ps}FabricRxmWaitRequest_i


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

eval add wave -noupdate $hexopt $pcie${ps}tx${ps}tx_cntrl${ps}tx_data

eval add wave -noupdate $hexopt $pcie${ps}tx${ps}tx_cntrl${ps}req_header2
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}tx_cntrl${ps}req_header1

eval add wave -noupdate $hexopt $pcie${ps}tx${ps}tx_cntrl${ps}cpl_header2
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}tx_cntrl${ps}cpl_header1

eval add wave -noupdate $hexopt $pcie${ps}tx${ps}tx_cntrl${ps}cmd_header2
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}tx_cntrl${ps}cmd_header1

eval add wave -noupdate -divider {"PCIE stream TXM"}
eval add wave -noupdate $binopt $pcie${ps}tx${ps}Clk_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}Rstn_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxsRstn_i

eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxChipSelect_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxRead_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxWrite_i
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
