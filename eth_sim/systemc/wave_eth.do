
if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
set ethpath "/system_tb/dut/ten_eth_axis/ten_eth_axis"
set macpath "/system_tb/dut/ten_mac_phy/ten_mac_phy"

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -asc}

eval add wave -noupdate -divider {"mdc"}
eval add wave -noupdate $binopt $macpath${ps}xgmac${ps}mdc
eval add wave -noupdate $binopt $macpath${ps}xgmac${ps}mdio_out
eval add wave -noupdate $binopt $macpath${ps}xgmac${ps}mdio_in

eval add wave -noupdate -divider {"eth tx"}
eval add wave -noupdate $binopt $ethpath${ps}mm2s_clk
eval add wave -noupdate $binopt $ethpath${ps}mm2s_resetn

eval add wave -noupdate $binopt $ethpath${ps}txd_tready
eval add wave -noupdate $binopt $ethpath${ps}txd_tvalid
eval add wave -noupdate $binopt $ethpath${ps}txd_tlast
eval add wave -noupdate $hexopt $ethpath${ps}txd_tdata
eval add wave -noupdate $hexopt $ethpath${ps}txd_tkeep

eval add wave -noupdate $binopt $ethpath${ps}txc_tready
eval add wave -noupdate $binopt $ethpath${ps}txc_tvalid
eval add wave -noupdate $binopt $ethpath${ps}txc_tlast
eval add wave -noupdate $hexopt $ethpath${ps}txc_tdata
eval add wave -noupdate $hexopt $ethpath${ps}txc_tkeep

eval add wave -noupdate $binopt $ethpath${ps}tx_clk
eval add wave -noupdate $binopt $ethpath${ps}tx_reset

eval add wave -noupdate $binopt $ethpath${ps}tx_axis_mac_tready
eval add wave -noupdate $binopt $ethpath${ps}tx_axis_mac_tvalid
eval add wave -noupdate $binopt $ethpath${ps}tx_axis_mac_tlast
eval add wave -noupdate $binopt $ethpath${ps}tx_axis_mac_tuser
eval add wave -noupdate $hexopt $ethpath${ps}tx_axis_mac_tdata
eval add wave -noupdate $hexopt $ethpath${ps}tx_axis_mac_tkeep


eval add wave -noupdate -divider {"eth rx"}
eval add wave -noupdate $binopt $ethpath${ps}s2mm_clk
eval add wave -noupdate $binopt $ethpath${ps}s2mm_resetn

eval add wave -noupdate $binopt $ethpath${ps}rxd_tready
eval add wave -noupdate $binopt $ethpath${ps}rxd_tvalid
eval add wave -noupdate $binopt $ethpath${ps}rxd_tlast
eval add wave -noupdate $hexopt $ethpath${ps}rxd_tdata
eval add wave -noupdate $hexopt $ethpath${ps}rxd_tkeep

eval add wave -noupdate $binopt $ethpath${ps}rxs_tready
eval add wave -noupdate $binopt $ethpath${ps}rxs_tvalid
eval add wave -noupdate $binopt $ethpath${ps}rxs_tlast
eval add wave -noupdate $hexopt $ethpath${ps}rxs_tdata
eval add wave -noupdate $hexopt $ethpath${ps}rxs_tkeep

eval add wave -noupdate $binopt $ethpath${ps}rx_clk
eval add wave -noupdate $binopt $ethpath${ps}rx_reset

eval add wave -noupdate $binopt $ethpath${ps}rx_axis_mac_tready
eval add wave -noupdate $binopt $ethpath${ps}rx_axis_mac_tvalid
eval add wave -noupdate $binopt $ethpath${ps}rx_axis_mac_tlast
eval add wave -noupdate $binopt $ethpath${ps}rx_axis_mac_tuser
eval add wave -noupdate $hexopt $ethpath${ps}rx_axis_mac_tdata
eval add wave -noupdate $hexopt $ethpath${ps}rx_axis_mac_tkeep
