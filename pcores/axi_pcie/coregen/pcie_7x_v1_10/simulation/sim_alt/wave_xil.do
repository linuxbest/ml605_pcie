if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
set pcie "/board/EP/app/PIO"

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -ascii}

eval add wave -noupdate -divider {"PCIE stream RX"}
eval add wave -noupdate $binopt $pcie${ps}user_clk
eval add wave -noupdate $binopt $pcie${ps}user_reset

eval add wave -noupdate $binopt $pcie${ps}m_axis_rx_tready
eval add wave -noupdate $binopt $pcie${ps}m_axis_rx_tvalid
eval add wave -noupdate $binopt $pcie${ps}m_axis_rx_tlast
eval add wave -noupdate $binopt $pcie${ps}m_axis_rx_tuser
eval add wave -noupdate $binopt \"$pcie${ps}m_axis_rx_tuser(14 downto 10)\"
eval add wave -noupdate $binopt \"$pcie${ps}m_axis_rx_tuser(21 downto 17)\"
eval add wave -noupdate $hexopt \"$pcie${ps}m_axis_rx_tdata(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}m_axis_rx_tdata(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}m_axis_rx_tdata(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}m_axis_rx_tdata(31 downto 0)\"
eval add wave -noupdate $hexopt $pcie${ps}m_axis_rx_tkeep

eval add wave -noupdate -divider {"PCIE stream TX"}
eval add wave -noupdate $binopt $pcie${ps}user_clk
eval add wave -noupdate $binopt $pcie${ps}user_reset

eval add wave -noupdate $binopt $pcie${ps}s_axis_tx_tready
eval add wave -noupdate $binopt $pcie${ps}s_axis_tx_tvalid
eval add wave -noupdate $binopt $pcie${ps}s_axis_tx_tlast
eval add wave -noupdate $binopt $pcie${ps}tx_src_dsc
eval add wave -noupdate $hexopt \"$pcie${ps}s_axis_tx_tdata(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}s_axis_tx_tdata(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}s_axis_tx_tdata(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}s_axis_tx_tdata(31 downto 0)\"
eval add wave -noupdate $hexopt $pcie${ps}s_axis_tx_tkeep

eval add wave -noupdate $hexopt $pcie${ps}cfg_completer_id

eval add wave -noupdate $hexopt $pcie${ps}fc_cpld
eval add wave -noupdate $hexopt $pcie${ps}fc_cplh
eval add wave -noupdate $hexopt $pcie${ps}fc_npd
eval add wave -noupdate $hexopt $pcie${ps}fc_nph
eval add wave -noupdate $hexopt $pcie${ps}fc_pd
eval add wave -noupdate $hexopt $pcie${ps}fc_ph
eval add wave -noupdate $hexopt $pcie${ps}fc_sel

eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_cpld_ava
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_cplh_ava
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_npd_ava
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_nph_ava
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_pd_ava
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_ph_ava

eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_cpld_lmt
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_cplh_lmt
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_npd_lmt
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_nph_lmt
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_pd_lmt
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_ph_lmt

eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_cpld_con
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_cplh_con
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_npd_con
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_nph_con
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_pd_con
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}rx_fc_ph_con

eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_cpld_ava
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_cplh_ava
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_npd_ava
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_nph_ava
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_pd_ava
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_ph_ava

eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_cpld_lmt
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_cplh_lmt
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_npd_lmt
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_nph_lmt
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_pd_lmt
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_ph_lmt

eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_cpld_con
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_cplh_con
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_npd_con
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_nph_con
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_pd_con
eval add wave -noupdate $hexopt $pcie${ps}altpcie_avl${ps}altpcie_stub${ps}tx_fc_ph_con

eval add wave -noupdate -divider {"Slave"}
eval add wave -noupdate $binopt $pcie${ps}user_clk
eval add wave -noupdate $binopt $pcie${ps}user_reset
set prefix s_
set path ${pcie}
do wave_ibus.do

eval add wave -noupdate -divider {"Master"}
eval add wave -noupdate $binopt $pcie${ps}user_clk
eval add wave -noupdate $binopt $pcie${ps}user_reset
set prefix m_
set path ${pcie}
do wave_ibus.do
