if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
set path "/ofm_tb"

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -asc}

eval add wave -noupdate -divider {"top"}
eval add wave -noupdate $binopt $path${ps}mm2s_clk
eval add wave -noupdate $binopt $path${ps}sys_rst

#eval add wave -noupdate $binopt $path${ps}tx_reset
eval add wave -noupdate $binopt $path${ps}tx_clk


eval add wave -noupdate -divider {"in fsm"}
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}mm2s_clk
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}sys_rst

eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}state

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txc_tvalid
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txc_tdata
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txc_tkeep
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txc_tready
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txc_tlast

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txd_tvalid
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txd_tdata
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txd_tkeep
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txd_tready
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txd_tlast

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}data_fifo_afull
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}data_fifo_wdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}data_fifo_wren

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}ctrl_fifo_afull
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}ctrl_fifo_wdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}ctrl_fifo_wren

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}TxFlag
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}TxCsCntrl
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}TxCsBegin
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}TxCsInsert
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}TxCsInit

eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}TxSum
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}TxSum_valid

eval add wave -noupdate -divider {"out csum"}
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}clk
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}rst

eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}CsBegin
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}CsInit
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}TxSum
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}Sum_valid

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}tvalid
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}tdata
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}tkeep

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}sof

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}begin_hit_reg
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}begin_hit
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}end_hit
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}end_hit_reg

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}csum_mask
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}csum_mask_begin_bcnt
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}csum_mask_begin
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}cur_sum_int

eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}bcnt
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}tdata_d1
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}tkeep_d1
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}tdata_bcnt
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}next_bcnt

eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}cur_sum
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}cur_sum_en

eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_csum${ps}sum

eval add wave -noupdate -divider {"out fsm"}
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}sys_rst
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}tx_clk

eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}state

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}data_fifo_empty
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}data_fifo_rdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}data_fifo_rden

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}ctrl_fifo_empty
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}ctrl_fifo_rdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}ctrl_fifo_rden

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}TxCsCntrl
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}TxCsSum
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}TxCsInsert

eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}fifo_rdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}fifo_rden
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}bcnt

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}insert_hit
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}insert_hit_reg
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}insert_mask_bcnt
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}insert_mask

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}tx_fifo_afull
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}tx_fifo_wdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}tx_fifo_wren

eval add wave -noupdate $binopt $path${ps}tx_axis_mac_tvalid
eval add wave -noupdate $hexopt $path${ps}tx_axis_mac_tdata
eval add wave -noupdate $hexopt $path${ps}tx_axis_mac_tkeep
eval add wave -noupdate $binopt $path${ps}tx_axis_mac_tlast
eval add wave -noupdate $binopt $path${ps}tx_axis_mac_tuser
eval add wave -noupdate $binopt $path${ps}tx_axis_mac_tready

configure  wave -justifyvalue          right
configure  wave -signalnamewidth       1
