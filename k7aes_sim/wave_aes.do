if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists aes] } { set aes "/k7sim_tb/dut/axi_aes_0" }

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -ascii}

eval add wave -noupdate -divider {"MM2S DATA"}
eval add wave -noupdate $binopt $aes${ps}m_axi_mm2s_aclk

eval add wave -noupdate $hexopt $aes${ps}m_axis_mm2s_tdata
eval add wave -noupdate $hexopt $aes${ps}m_axis_mm2s_tkeep
eval add wave -noupdate $binopt $aes${ps}m_axis_mm2s_tlast
eval add wave -noupdate $binopt $aes${ps}m_axis_mm2s_tvalid
eval add wave -noupdate $binopt $aes${ps}m_axis_mm2s_tready
eval add wave -noupdate $hexopt $aes${ps}m_axis_mm2s_tuser
eval add wave -noupdate $hexopt $aes${ps}m_axis_mm2s_tid
eval add wave -noupdate $hexopt $aes${ps}m_axis_mm2s_tdest

eval add wave -noupdate -divider {"MM2S CTRL"}
eval add wave -noupdate $binopt $aes${ps}m_axi_mm2s_aclk

eval add wave -noupdate $hexopt $aes${ps}m_axis_mm2s_cntrl_tdata
eval add wave -noupdate $hexopt $aes${ps}m_axis_mm2s_cntrl_tkeep
eval add wave -noupdate $binopt $aes${ps}m_axis_mm2s_cntrl_tlast
eval add wave -noupdate $binopt $aes${ps}m_axis_mm2s_cntrl_tvalid
eval add wave -noupdate $binopt $aes${ps}m_axis_mm2s_cntrl_tready

eval add wave -noupdate -divider {"S2MM DATA"}
eval add wave -noupdate $binopt $aes${ps}m_axi_s2mm_aclk

eval add wave -noupdate $hexopt $aes${ps}s_axis_s2mm_tdata
eval add wave -noupdate $hexopt $aes${ps}s_axis_s2mm_tkeep
eval add wave -noupdate $binopt $aes${ps}s_axis_s2mm_tlast
eval add wave -noupdate $binopt $aes${ps}s_axis_s2mm_tvalid
eval add wave -noupdate $binopt $aes${ps}s_axis_s2mm_tready
eval add wave -noupdate $hexopt $aes${ps}s_axis_s2mm_tuser
eval add wave -noupdate $hexopt $aes${ps}s_axis_s2mm_tid
eval add wave -noupdate $hexopt $aes${ps}s_axis_s2mm_tdest

eval add wave -noupdate -divider {"S2MM STATUS"}
eval add wave -noupdate $binopt $aes${ps}m_axi_s2mm_aclk

eval add wave -noupdate $hexopt $aes${ps}s_axis_s2mm_sts_tdata
eval add wave -noupdate $hexopt $aes${ps}s_axis_s2mm_sts_tkeep
eval add wave -noupdate $binopt $aes${ps}s_axis_s2mm_sts_tlast
eval add wave -noupdate $binopt $aes${ps}s_axis_s2mm_sts_tvalid
eval add wave -noupdate $binopt $aes${ps}s_axis_s2mm_sts_tready


