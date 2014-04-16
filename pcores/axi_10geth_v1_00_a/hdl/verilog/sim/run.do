vlib work
vmap work work

vlog -work work ifm_tb.v
vlog -work work ../axi_eth_ifm.v
vlog -work work ../ifm_in_fsm.v
vlog -work work ../ifm_out_fsm.v
vlog -work work ../ifm_fifo.v
vlog -work work ../small_async_fifo.v

vcom -work work ../../vhdl/axi_async_fifo.vhd

#vsim -L unisims_ver -L secureip -t ps work.ifm_tb work.glbl -novopt 
vsim -L unisims_ver -L secureip -t ps work.ifm_tb -novopt 

do wave_mti.do

run 5us
