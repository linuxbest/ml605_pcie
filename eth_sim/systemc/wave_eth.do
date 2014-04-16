
if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
set ethpath "/system_tb/dut/ETHERNET/ETHERNET/"
set txpath "/system_tb/dut/ETHERNET/ETHERNET/I_EMBEDDED_TOP${ps}TX_INTFCE_I"
set rxpath "/system_tb/dut/ETHERNET/ETHERNET/I_AXI_ETH_RX"
set macpath "/system_tb/dut/ten_mac_phy/ten_mac_phy"

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -asc}

eval add wave -noupdate -divider {"mdc"}
eval add wave -noupdate $binopt $macpath${ps}xgmac${ps}mdc
eval add wave -noupdate $binopt $macpath${ps}xgmac${ps}mdio_out
eval add wave -noupdate $binopt $macpath${ps}xgmac${ps}mdio_in

