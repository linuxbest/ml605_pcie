#do k7sim_setup.do

vlog -work k7_tlp_v1_00_a  ../../pcores/k7_tlp_v1_00_a/hdl/verilog/*.v
vlog -work axi_tlp_v1_00_a ../../pcores/axi_tlp_v1_00_a/hdl/verilog/*.v

vlog -incr -work k7_tlp_v1_00_a "../../pciebfm_lib/*.v" {+incdir+../../pciebfm_lib/}
vlog -incr -work k7_tlp_v1_00_a "../../k7aes_sim/pcie_7x_v1_10_gt_top_pipe_mode.v" {+incdir+../../pciebfm_lib/}
vlog -incr -work k7_tlp_v1_00_a "../../k7aes_sim/pcie_7x_v1_10.v"                  {+incdir+../../pciebfm_lib/}

vlog -incr -work work "k7sim_tb.v" {+incdir+../../pciebfm_lib/}

s
#vsim -novopt -t ps -L xilinxcorelib_ver -L secureip -L unisims_ver +notimingchecks -L unimacro_ver k7sim_tb glbl
#vsim -voptargs="+acc" +notimingchecks -L xilinxcorelib_ver -L secureip -L unisims_ver +notimingchecks -L unimacro_ver k7sim_tb glbl
#vsim -voptargs="+acc" +notimingchecks -L xilinxcorelib_ver -L secureip -L unisims_ver +notimingchecks -L unimacro_ver k7sim_gt_tb glbl

w

set top k7sim_tb
do ../../k7aes_sim/wave_all.do

#log -r /*

run 80us
