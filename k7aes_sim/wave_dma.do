if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists dma] } { set dma "${top}/dut/axi_dma_0" }

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -ascii}

eval add wave -noupdate -divider {"SG AXI"}
eval add wave -noupdate $binopt $dma${ps}m_axi_sg_aclk

set axi_bus $dma
set name    m_axi_sg
do ../../k7aes_sim/wave_axi.do

eval add wave -noupdate -divider {"MM2S AXI"}
eval add wave -noupdate $binopt $dma${ps}m_axi_mm2s_aclk

set axi_bus $dma
set name    m_axi_mm2s
do ../../k7aes_sim/wave_axi.do

eval add wave -noupdate -divider {"S2MM AXI"}
eval add wave -noupdate $binopt $dma${ps}m_axi_s2mm_aclk

set axi_bus $dma
set name    m_axi_s2mm
do ../../k7aes_sim/wave_axi.do
