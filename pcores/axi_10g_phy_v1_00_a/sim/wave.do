if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -asc}

eval add wave -noupdate -divider {"top"}
eval add wave -noupdate $binopt /refclk_p
eval add wave -noupdate $binopt /refclk_n
eval add wave -noupdate $binopt /reset

eval add wave -noupdate $binopt /core_status0
eval add wave -noupdate $binopt /core_status1
eval add wave -noupdate $binopt /core_status2
eval add wave -noupdate $binopt /core_status3

eval add wave -noupdate $binopt /txp
eval add wave -noupdate $binopt /rxp

eval add wave -noupdate -divider {"DUT"}
eval add wave -noupdate $binopt DUT/hw_reset
eval add wave -noupdate $binopt DUT/clk156

eval add wave -noupdate $hexopt DUT/xgmii_rxc0
eval add wave -noupdate $hexopt DUT/xgmii_rxd0
eval add wave -noupdate $hexopt DUT/xgmii_txc0
eval add wave -noupdate $hexopt DUT/xgmii_txd0
eval add wave -noupdate $binopt DUT/core_status0
eval add wave -noupdate $binopt DUT/tx_resetdone0
eval add wave -noupdate $binopt DUT/rx_resetdone0

proc wave_phy_add {id} {
set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -asc}
eval add wave -noupdate -divider {"xphy phy ${id}"}
eval add wave -noupdate $hexopt DUT/phy_${id}/xgmii_txd
eval add wave -noupdate $hexopt DUT/phy_${id}/xgmii_txc
eval add wave -noupdate $hexopt DUT/phy_${id}/xgmii_rxd
eval add wave -noupdate $hexopt DUT/phy_${id}/xgmii_rxc

eval add wave -noupdate $binopt DUT/phy_${id}/mdc
eval add wave -noupdate $binopt DUT/phy_${id}/mdio_in
eval add wave -noupdate $binopt DUT/phy_${id}/mdio_out
eval add wave -noupdate $binopt DUT/phy_${id}/mdio_tri
eval add wave -noupdate $binopt DUT/phy_${id}/core_status

eval add wave -noupdate $binopt DUT/phy_${id}/tx_resetdone
eval add wave -noupdate $binopt DUT/phy_${id}/rx_resetdone
eval add wave -noupdate $binopt DUT/phy_${id}/signal_detect
eval add wave -noupdate $binopt DUT/phy_${id}/tx_fault
eval add wave -noupdate $binopt DUT/phy_${id}/tx_disable

eval add wave -noupdate $binopt DUT/phy_${id}/hw_reset
eval add wave -noupdate $binopt DUT/phy_${id}/dclk
eval add wave -noupdate $binopt DUT/phy_${id}/clk156
eval add wave -noupdate $binopt DUT/phy_${id}/mmcm_locked
eval add wave -noupdate $binopt DUT/phy_${id}/gt0_qplllock_i

eval add wave -noupdate -divider {"xphy phy ${id} drp"}
eval add wave -noupdate $binopt DUT/phy_${id}/DRPCLK_IN
eval add wave -noupdate $hexopt DUT/phy_${id}/DRPADDR_IN
eval add wave -noupdate $hexopt DUT/phy_${id}/DRPDI_IN
eval add wave -noupdate $hexopt DUT/phy_${id}/DRPDO_OUT
eval add wave -noupdate $binopt DUT/phy_${id}/DRPEN_IN
eval add wave -noupdate $binopt DUT/phy_${id}/DRPRDY_OUT
eval add wave -noupdate $binopt DUT/phy_${id}/DRPWE_IN

eval add wave -noupdate $binopt DUT/phy_${id}/EYESCANDATAERROR_OUT
eval add wave -noupdate $binopt DUT/phy_${id}/LOOPBACK_IN

eval add wave -noupdate -divider {"xphy phy ${id} rx"}
eval add wave -noupdate $binopt DUT/phy_${id}/RXUSERRDY_IN
eval add wave -noupdate $binopt DUT/phy_${id}/RXDATAVALID_OUT
eval add wave -noupdate $binopt DUT/phy_${id}/RXHEADER_OUT
eval add wave -noupdate $binopt DUT/phy_${id}/RXHEADERVALID_OUT
eval add wave -noupdate $binopt DUT/phy_${id}/RXGEARBOXSLIP_IN

eval add wave -noupdate $binopt DUT/phy_${id}/RXPRBSCNTRESET_IN
eval add wave -noupdate $binopt DUT/phy_${id}/RXPRBSSEL_IN
eval add wave -noupdate $binopt DUT/phy_${id}/RXPRBSERR_OUT

eval add wave -noupdate $binopt DUT/phy_${id}/GTRXRESET_IN
eval add wave -noupdate $hexopt DUT/phy_${id}/RXDATA_OUT
eval add wave -noupdate $binopt DUT/phy_${id}/RXOUTCLK_OUT
eval add wave -noupdate $binopt DUT/phy_${id}/RXPCSRESET_IN
eval add wave -noupdate $binopt DUT/phy_${id}/RXUSRCLK_IN
eval add wave -noupdate $binopt DUT/phy_${id}/RXUSRCLK2_IN

eval add wave -noupdate $binopt DUT/phy_${id}/RXCDRLOCK_OUT
eval add wave -noupdate $binopt DUT/phy_${id}/RXELECIDLE_OUT
eval add wave -noupdate $binopt DUT/phy_${id}/RXLPMEN_IN

eval add wave -noupdate $binopt DUT/phy_${id}/RXBUFRESET_IN
eval add wave -noupdate $binopt DUT/phy_${id}/RXBUFSTATUS_OUT

eval add wave -noupdate $binopt DUT/phy_${id}/RXRESETDONE_OUT

eval add wave -noupdate -divider {"xphy phy ${id} tx"}
eval add wave -noupdate $binopt DUT/phy_${id}/TXUSERRDY_IN

eval add wave -noupdate $binopt DUT/phy_${id}/TXHEADER_IN
eval add wave -noupdate $binopt DUT/phy_${id}/TXSEQUENCE_IN

eval add wave -noupdate $binopt DUT/phy_${id}/GTTXRESET_IN
eval add wave -noupdate $binopt DUT/phy_${id}/GTTXRESET_i

eval add wave -noupdate $hexopt DUT/phy_${id}/TXDATA_IN
eval add wave -noupdate $binopt DUT/phy_${id}/TXOUTCLK_OUT
eval add wave -noupdate $binopt DUT/phy_${id}/TXOUTCLKFABRIC_OUT
eval add wave -noupdate $binopt DUT/phy_${id}/TXOUTCLKPCS_OUT
eval add wave -noupdate $binopt DUT/phy_${id}/TXPCSRESET_IN
eval add wave -noupdate $binopt DUT/phy_${id}/TXUSRCLK_IN
eval add wave -noupdate $binopt DUT/phy_${id}/TXUSRCLK2_IN

eval add wave -noupdate $binopt DUT/phy_${id}/TXINHIBIT_IN
eval add wave -noupdate $binopt DUT/phy_${id}/TXPRECURSOR_IN
eval add wave -noupdate $binopt DUT/phy_${id}/TXPOSTCURSOR_IN
eval add wave -noupdate $binopt DUT/phy_${id}/TXMAINCURSOR_IN

eval add wave -noupdate $binopt DUT/phy_${id}/TXRESETDONE_OUT

eval add wave -noupdate $binopt DUT/phy_${id}/TXPRBSSEL_IN

eval add wave -noupdate $binopt DUT/phy_${id}/QPLLRESET_IN
}

wave_phy_add 0
wave_phy_add 1
wave_phy_add 2
wave_phy_add 3

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
