
vcom -novopt -93 -work axi_master_lite_sc_v2_00_a "../../pcores/axi_master_lite_sc_v2_00_a/hdl/vhdl/axi_master_lite.vhd"

sccom -work axi_master_lite_sc_v2_00_a ../../tb/dma/axi_master_systemc.cpp

sccom -work axi_master_lite_sc_v2_00_a -link

do dma_tb_setup.do

s

