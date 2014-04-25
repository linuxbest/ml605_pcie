if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -asc}

eval add wave -noupdate -divider {"top"}
eval add wave -noupdate $binopt /refclk_p
eval add wave -noupdate $binopt /refclk_n
eval add wave -noupdate $binopt /reset

eval add wave -noupdate $binopt /txp
eval add wave -noupdate $binopt /rxp

eval add wave -noupdate -divider {"DUT"}
eval add wave -noupdate $binopt DUT/hw_reset
eval add wave -noupdate $binopt DUT/clk156

eval add wave -noupdate $hexopt DUT/xgmii_rxc0
eval add wave -noupdate $hexopt DUT/xgmii_rxd0
eval add wave -noupdate $hexopt DUT/xgmii_txc0
eval add wave -noupdate $hexopt DUT/xgmii_txd0
eval add wave -noupdate $hexopt DUT/core_status0
eval add wave -noupdate $binopt DUT/tx_resetdone0
eval add wave -noupdate $binopt DUT/rx_resetdone0

eval add wave -noupdate -divider {"xphy block clk"}
eval add wave -noupdate $binopt DUT/xphy_block_clk/refclk_p
eval add wave -noupdate $binopt DUT/xphy_block_clk/refclk_n

eval add wave -noupdate $binopt DUT/xphy_block_clk/mmcm_locked
eval add wave -noupdate $binopt DUT/xphy_block_clk/dclk
eval add wave -noupdate $binopt DUT/xphy_block_clk/clk156

eval add wave -noupdate $binopt DUT/xphy_block_clk/q1_clk0_refclk_i
eval add wave -noupdate $binopt DUT/xphy_block_clk/q1_clk0_refclk_i_bufh

#eval add wave -noupdate $hexopt DUT/xgmii_rxc1
#eval add wave -noupdate $hexopt DUT/xgmii_rxd1
#eval add wave -noupdate $hexopt DUT/xgmii_txc1
#eval add wave -noupdate $hexopt DUT/xgmii_txd1
#eval add wave -noupdate $binopt DUT/core_status1
#eval add wave -noupdate $binopt DUT/tx_resetdone1
#eval add wave -noupdate $binopt DUT/rx_resetdone1
#
#eval add wave -noupdate $hexopt DUT/xgmii_rxc2
#eval add wave -noupdate $hexopt DUT/xgmii_rxd2
#eval add wave -noupdate $hexopt DUT/xgmii_txc2
#eval add wave -noupdate $hexopt DUT/xgmii_txd2
#eval add wave -noupdate $binopt DUT/core_status2
#eval add wave -noupdate $binopt DUT/tx_resetdone2
#eval add wave -noupdate $binopt DUT/rx_resetdone2
#
#eval add wave -noupdate $hexopt DUT/xgmii_rxc3
#eval add wave -noupdate $hexopt DUT/xgmii_rxd3
#eval add wave -noupdate $hexopt DUT/xgmii_txc3
#eval add wave -noupdate $hexopt DUT/xgmii_txd3
#eval add wave -noupdate $binopt DUT/core_status3
#eval add wave -noupdate $binopt DUT/tx_resetdone3
#eval add wave -noupdate $binopt DUT/rx_resetdone3

#  Wave window configuration information
#
configure  wave -justifyvalue          right
configure  wave -signalnamewidth       1

TreeUpdate [SetDefaultTree]

#  Wave window setup complete
#
echo  "Wave window display setup done."
