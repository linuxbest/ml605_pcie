vlib work
vmap work work

vlog -work work ofm_tb.v
vlog -work work ../axi_eth_ofm.v
vlog -work work ../ofm_in_fsm.v
vlog -work work ../ofm_out_fsm.v
vlog -work work ../ofm_fifo.v
vlog -work work ../small_async_fifo.v
vlog -work work ../afifo73_512.v
vlog -work work ../fifo73_512.v
vlog -work work ../fifo37_512.v

vlog -work work FIFO_GENERATOR_V9_3.v

vcom -work work ../../vhdl/axi_async_fifo.vhd

vsim -L unisims_ver -L secureip -t ps work.ofm_tb -novopt 

do wave_ofm.do

run 5us
