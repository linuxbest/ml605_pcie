
vcom -novopt -93 -work axi_master_lite_sc_v2_00_a "../../pcores/axi_master_lite_sc_v2_00_a/hdl/vhdl/axi_master_lite.vhd"

sccom -work axi_master_lite_sc_v2_00_a  ../../tb/dma/axi_master_systemc.cpp
sccom -work axi_master_lite_sc_v2_00_a  ../../tb/dma/bram_slave_systemc.cpp
sccom -work axi_master_lite_sc_v2_00_a  ../../tb/dma/axi_dma.c
sccom -work axi_master_lite_sc_v2_00_a  -link


#vlog -novopt -incr -work work "../../tb/dma/dma_tb_bram_block_0_wrapper.v"

do dma_tb_setup.do

s
w

do ../../tb/dma/wave_aes.do

run 80us
