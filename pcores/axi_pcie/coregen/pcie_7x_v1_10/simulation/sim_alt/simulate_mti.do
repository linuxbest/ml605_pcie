
vlib work
vmap work

# Include +define+ENABLE_GT to run the simulations in GT mode

vlog -work work +incdir+../.+../../example_design \
        +define+SIMULATION \
	+incdir+.+../dsport+../tests \
	$env(XILINX)/verilog/src/glbl.v \
      -f board.f

vlog -work work -f ../alt/alt.f
vlog -work work -f ../alt/alt_vmm.f

vlog -incr -work work ../../../../../../pciebfm_lib/*.v {+incdir+../../../../../../pciebfm_lib/}
vlog -incr -work work pcie_7x_v1_10_gt_top_pipe_mode.v {+incdir+../../../../../../pciebfm_lib/}

# Load and run simulation
vsim -voptargs="+acc" +notimingchecks +TESTNAME=pio_writeReadBack_test0 -L work -L secureip -L unisims_ver -L unimacro_ver \
     work.board glbl +dump_all

add log -r /*

do wave.do

run -all
