if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
set path "/ifm_tb"

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -asc}

eval add wave -noupdate -divider {"top"}
eval add wave -noupdate $binopt $path${ps}sys_clk

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
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}sys_clk
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}rx_reset

eval add wave -noupdate $hexopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}state

eval add wave -noupdate $hexopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}data_fifo_rdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}data_fifo_rden

eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}info_fifo_empty
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}info_fifo_rdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}info_fifo_rden

eval add wave -noupdate $hexopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}good_fifo_wdata
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}good_fifo_wren
eval add wave -noupdate $binopt $path${ps}axi_eth_ifm${ps}ifm_out_fsm${ps}good_fifo_afull

eval add wave -noupdate -divider {"out good frame"}
eval add wave -noupdate $binopt $path${ps}sys_clk
eval add wave -noupdate $hexopt $path${ps}mac_tdata
eval add wave -noupdate $hexopt $path${ps}mac_tkeep
eval add wave -noupdate $binopt $path${ps}mac_tlast
eval add wave -noupdate $binopt $path${ps}mac_tvalid
eval add wave -noupdate $binopt $path${ps}mac_tready

configure  wave -justifyvalue          right
configure  wave -signalnamewidth       1
