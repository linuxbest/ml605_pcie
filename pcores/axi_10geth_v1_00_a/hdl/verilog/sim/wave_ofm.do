if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
set path "/ofm_tb"

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -asc}

eval add wave -noupdate -divider {"top"}
eval add wave -noupdate $binopt $path${ps}mm2s_clk
eval add wave -noupdate $binopt $path${ps}mm2s_resetn

eval add wave -noupdate $binopt $path${ps}tx_reset
eval add wave -noupdate $binopt $path${ps}tx_clk


eval add wave -noupdate -divider {"in fsm"}
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}mm2s_clk
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}mm2s_resetn

eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}state

eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txc_tdata
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txc_tkeep
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txc_tvalid
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txc_tready
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txc_tlast

eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txd_tdata
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txd_tkeep
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txd_tvalid
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txd_tready
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}txd_tlast

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}data_fifo_afull
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}data_fifo_wdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}data_fifo_wren

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}ctrl_fifo_afull
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}ctrl_fifo_wdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}ctrl_fifo_wren

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}TxFlag
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}tx_ok
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}tx_ok
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}TxCsCntrl
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}TxCsBegin
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}TxCsInsert
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_in_fsm${ps}TxCsInit

eval add wave -noupdate -divider {"out fsm"}
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}tx_reset
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}tx_clk

eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}state

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}data_fifo_empty
eval add wave -noupdate $hexopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}data_fifo_rdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}data_fifo_rden

eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}ctrl_fifo_empty
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}ctrl_fifo_rdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ofm${ps}ofm_out_fsm${ps}ctrl_fifo_rden

eval add wave -noupdate $hexopt $path${ps}tx_axis_mac_tdata
eval add wave -noupdate $hexopt $path${ps}tx_axis_mac_tkeep
eval add wave -noupdate $binopt $path${ps}tx_axis_mac_tlast
eval add wave -noupdate $binopt $path${ps}tx_axis_mac_tuser
eval add wave -noupdate $binopt $path${ps}tx_axis_mac_tvalid
eval add wave -noupdate $binopt $path${ps}tx_axis_mac_tready

configure  wave -justifyvalue          right
configure  wave -signalnamewidth       1
