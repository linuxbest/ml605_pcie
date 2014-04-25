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
eval add wave -noupdate $binopt DUT/core_status0
eval add wave -noupdate $binopt DUT/tx_resetdone0
eval add wave -noupdate $binopt DUT/rx_resetdone0

eval add wave -noupdate -divider {"xphy phy 0"}
eval add wave -noupdate $hexopt DUT/phy_0/xgmii_txd
eval add wave -noupdate $hexopt DUT/phy_0/xgmii_txc
eval add wave -noupdate $hexopt DUT/phy_0/xgmii_rxd
eval add wave -noupdate $hexopt DUT/phy_0/xgmii_rxc

eval add wave -noupdate $binopt DUT/phy_0/mdc
eval add wave -noupdate $binopt DUT/phy_0/mdio_in
eval add wave -noupdate $binopt DUT/phy_0/mdio_out
eval add wave -noupdate $binopt DUT/phy_0/mdio_tri
eval add wave -noupdate $binopt DUT/phy_0/core_status

eval add wave -noupdate $binopt DUT/phy_0/tx_resetdone
eval add wave -noupdate $binopt DUT/phy_0/rx_resetdone
eval add wave -noupdate $binopt DUT/phy_0/signal_detect
eval add wave -noupdate $binopt DUT/phy_0/tx_fault
eval add wave -noupdate $binopt DUT/phy_0/tx_disable

eval add wave -noupdate $binopt DUT/phy_0/hw_reset
eval add wave -noupdate $binopt DUT/phy_0/dclk
eval add wave -noupdate $binopt DUT/phy_0/clk156
eval add wave -noupdate $binopt DUT/phy_0/mmcm_locked
eval add wave -noupdate $binopt DUT/phy_0/gt0_qplllock_i

eval add wave -noupdate -divider {"xphy phy drp"}
eval add wave -noupdate $binopt DUT/phy_0/DRPCLK_IN
eval add wave -noupdate $hexopt DUT/phy_0/DRPADDR_IN
eval add wave -noupdate $hexopt DUT/phy_0/DRPDI_IN
eval add wave -noupdate $hexopt DUT/phy_0/DRPDO_OUT
eval add wave -noupdate $binopt DUT/phy_0/DRPEN_IN
eval add wave -noupdate $binopt DUT/phy_0/DRPRDY_OUT
eval add wave -noupdate $binopt DUT/phy_0/DRPWE_IN

eval add wave -noupdate $binopt DUT/phy_0/EYESCANDATAERROR_OUT
eval add wave -noupdate $binopt DUT/phy_0/LOOPBACK_IN

eval add wave -noupdate -divider {"xphy phy recv"}
eval add wave -noupdate $binopt DUT/phy_0/RXUSERRDY_IN
eval add wave -noupdate $binopt DUT/phy_0/RXDATAVALID_OUT
eval add wave -noupdate $binopt DUT/phy_0/RXHEADER_OUT
eval add wave -noupdate $binopt DUT/phy_0/RXHEADERVALID_OUT
eval add wave -noupdate $binopt DUT/phy_0/RXGEARBOXSLIP_IN

eval add wave -noupdate $binopt DUT/phy_0/RXPRBSCNTRESET_IN
eval add wave -noupdate $binopt DUT/phy_0/RXPRBSSEL_IN
eval add wave -noupdate $binopt DUT/phy_0/RXPRBSERR_OUT

eval add wave -noupdate $binopt DUT/phy_0/GTRXRESET_IN
eval add wave -noupdate $hexopt DUT/phy_0/RXDATA_OUT
eval add wave -noupdate $binopt DUT/phy_0/RXOUTCLK_OUT
eval add wave -noupdate $binopt DUT/phy_0/RXPCSRESET_IN
eval add wave -noupdate $binopt DUT/phy_0/RXUSRCLK_IN
eval add wave -noupdate $binopt DUT/phy_0/RXUSRCLK2_IN

eval add wave -noupdate $binopt DUT/phy_0/RXCDRLOCK_OUT
eval add wave -noupdate $binopt DUT/phy_0/RXELECIDLE_OUT
eval add wave -noupdate $binopt DUT/phy_0/RXLPMEN_IN

eval add wave -noupdate $binopt DUT/phy_0/RXBUFRESET_IN
eval add wave -noupdate $binopt DUT/phy_0/RXBUFSTATUS_OUT

eval add wave -noupdate $binopt DUT/phy_0/RXRESETDONE_OUT

eval add wave -noupdate -divider {"xphy phy tx "}
eval add wave -noupdate $binopt DUT/phy_0/TXUSERRDY_IN

eval add wave -noupdate $binopt DUT/phy_0/TXHEADER_IN
eval add wave -noupdate $binopt DUT/phy_0/TXSEQUENCE_IN

eval add wave -noupdate $binopt DUT/phy_0/GTTXRESET_IN
eval add wave -noupdate $binopt DUT/phy_0/GTTXRESET_i

eval add wave -noupdate $hexopt DUT/phy_0/TXDATA_IN
eval add wave -noupdate $binopt DUT/phy_0/TXOUTCLK_OUT
eval add wave -noupdate $binopt DUT/phy_0/TXOUTCLKFABRIC_OUT
eval add wave -noupdate $binopt DUT/phy_0/TXOUTCLKPCS_OUT
eval add wave -noupdate $binopt DUT/phy_0/TXPCSRESET_IN
eval add wave -noupdate $binopt DUT/phy_0/TXUSRCLK_IN
eval add wave -noupdate $binopt DUT/phy_0/TXUSRCLK2_IN

eval add wave -noupdate $binopt DUT/phy_0/TXINHIBIT_IN
eval add wave -noupdate $binopt DUT/phy_0/TXPRECURSOR_IN
eval add wave -noupdate $binopt DUT/phy_0/TXPOSTCURSOR_IN
eval add wave -noupdate $binopt DUT/phy_0/TXMAINCURSOR_IN

eval add wave -noupdate $binopt DUT/phy_0/TXRESETDONE_OUT

eval add wave -noupdate $binopt DUT/phy_0/TXPRBSSEL_IN

eval add wave -noupdate $binopt DUT/phy_0/QPLLRESET_IN

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
