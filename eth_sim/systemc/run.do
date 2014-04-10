do system_setup.do

vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/srl_fifo.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/axi_bram_ctrl_funcs.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/axi_lite_if.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/checkbit_handler_64.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/checkbit_handler.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/correct_one_bit_64.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/correct_one_bit.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/xor18.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/parity.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/ecc_gen.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/lite_ecc_reg.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/axi_lite.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/sng_port_arb.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/ua_narrow.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/wrap_brst.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/rd_chnl.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/wr_chnl.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/full_axi.vhd
vcom -work axi_systemc_v1_00_a ../../pcores/axi_systemc_v1_00_a/hdl/vhdl/axi_bram_ctrl.vhd

#sccom -work axi_systemc_v1_00_a -ggdb -I ../../systemc/ ../../systemc/axi_mm_systemc.cpp

sccom -work work -ggdb -I ../../systemc/ ../../systemc/axi_mm_systemc.cpp

sccom -ggdb ../../systemc/osChip.c
sccom -ggdb ../../systemc/xaxidma_bd.c
sccom -ggdb ../../systemc/xaxidma.c
sccom -ggdb ../../systemc/xaxidma_bdring.c

sccom -link

s
w

do ../../systemc/wave.do

run 10000ns
