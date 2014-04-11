do system_setup.do

# todo, try to figure out why need compile two times.
sccom -work axi_systemc_v1_00_a -ggdb -I ../../systemc/ ../../systemc/axi_mm_systemc.cpp
#sccom -work work -ggdb -I ../../systemc/ ../../systemc/axi_mm_systemc.cpp

sccom -work work -ggdb ../../systemc/osChip.c
sccom -work work -ggdb ../../systemc/xaxidma_bd.c
sccom -work work -ggdb ../../systemc/xaxidma.c
sccom -work work -ggdb ../../systemc/xaxidma_bdring.c

sccom -link -lib axi_systemc_v1_00_a -lib work

s
w

do ../../systemc/wave_eth.do

run 10000ns
