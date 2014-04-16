if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
set path "/ifm_tb"

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -asc}

eval add wave -noupdate -divider {"top"}
eval add wave -noupdate $binopt $path${ps}s2mm_clk

eval add wave -noupdate $binopt $path${ps}rx_reset
eval add wave -noupdate $binopt $path${ps}rx_clk

eval add wave -noupdate $hexopt $path${ps}rx_axis_mac_tdata
eval add wave -noupdate $hexopt $path${ps}rx_axis_mac_tkeep
eval add wave -noupdate $binopt $path${ps}rx_axis_mac_tlast
eval add wave -noupdate $binopt $path${ps}rx_axis_mac_tuser
eval add wave -noupdate $binopt $path${ps}rx_axis_mac_tvalid
eval add wave -noupdate $binopt $path${ps}rx_axis_mac_tready

eval add wave -noupdate -divider {"in fsm"}
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_in_fsm${ps}rx_clk
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_in_fsm${ps}rx_reset

eval add wave -noupdate $hexopt $path${ps}axi_eth_ifm${ps}ifm_in_fsm${ps}state

eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_in_fsm${ps}data_fifo_afull
eval add wave -noupdate $hexopt $path${ps}axi_eth_ifm${ps}ifm_in_fsm${ps}data_fifo_wdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_in_fsm${ps}data_fifo_wren

eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_in_fsm${ps}info_fifo_wdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_in_fsm${ps}info_fifo_wren

eval add wave -noupdate -divider {"out fsm"}
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}s2mm_clk
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}s2mm_resetn

eval add wave -noupdate $hexopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}state

eval add wave -noupdate $hexopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}data_fifo_rdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}data_fifo_rden

eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}info_fifo_empty
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}info_fifo_rdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}info_fifo_rden

eval add wave -noupdate $hexopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}good_fifo_wdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}good_fifo_wren
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}good_fifo_afull
eval add wave -noupdate $hexopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}good_fifo_byte
eval add wave -noupdate $hexopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}bytecnt

eval add wave -noupdate $hexopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}ctrl_fifo_wdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}ctrl_fifo_wren
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}ctrl_fifo_afull

eval add wave -noupdate -divider {"out frame"}
eval add wave -noupdate $binopt $path${ps}s2mm_clk
eval add wave -noupdate $hexopt $path${ps}rxd_tdata
eval add wave -noupdate $hexopt $path${ps}rxd_tkeep
eval add wave -noupdate $binopt $path${ps}rxd_tlast
eval add wave -noupdate $binopt $path${ps}rxd_tvalid
eval add wave -noupdate $binopt $path${ps}rxd_tready

eval add wave -noupdate $hexopt $path${ps}rxs_tdata
eval add wave -noupdate $hexopt $path${ps}rxs_tkeep
eval add wave -noupdate $binopt $path${ps}rxs_tlast
eval add wave -noupdate $binopt $path${ps}rxs_tvalid
eval add wave -noupdate $binopt $path${ps}rxs_tready

configure  wave -justifyvalue          right
configure  wave -signalnamewidth       1
