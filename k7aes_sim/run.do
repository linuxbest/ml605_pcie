#do k7sim_setup.do

vlog -novopt -work k7_tlp_v1_00_a  ../../pcores/axi_tlp_v1_00_a/hdl/verilog/*.v
vlog -novopt -work axi_tlp_v1_00_a ../../pcores/axi_tlp_v1_00_a/hdl/verilog/*.v

vlog -novopt -incr -work k7_tlp_v1_00_a "../../pciebfm_lib/*.v" {+incdir+../../pciebfm_lib/}
vlog -novopt -incr -work work           "../../pciebfm_lib/*.v" {+incdir+../../pciebfm_lib/}
vlog -novopt -incr -work k7_tlp_v1_00_a "../../k7aes_sim/*.v" {+incdir+../../pciebfm_lib/}

vlog -novopt -incr -work work "k7sim_tb.v" {+incdir+../../pciebfm_lib/}

s
w

do ../../k7aes_sim/wave_all.do

log -r /*

run 80us
