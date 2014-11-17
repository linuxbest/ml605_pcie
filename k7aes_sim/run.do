do k7sim_setup.do

vlog -novopt -work k7_tlp_v1_00_a  ../../pcores/axi_tlp_v1_00_a/hdl/verilog/*.v
vlog -novopt -work axi_tlp_v1_00_a ../../pcores/axi_tlp_v1_00_a/hdl/verilog/*.v

vlog -novopt -incr -work k7_tlp_v1_00_a "../../pciebfm_lib/*.v" {+incdir+../../pciebfm_lib/}
vlog -novopt -incr -work k7_tlp_v1_00_a "../../k7aes_sim/*.v" {+incdir+../../pciebfm_lib/}

vlog -novopt -incr -work work "k7sim_tb.v" {+incdir+../../pciebfm_lib/}

#vsim -novopt -t ps -L xilinxcorelib_ver -L secureip -L unisims_ver +notimingchecks -L unimacro_ver k7sim_tb glbl
vsim -voptargs="+acc" +notimingchecks -L xilinxcorelib_ver -L secureip -L unisims_ver +notimingchecks -L unimacro_ver k7sim_tb glbl

#s
w

#add wave sim:/k7sim_tb/dut/PCI_Express/PCI_Express/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/genblk1/pcie_7x_v1_9_inst/gt_ges/gt_top_i/*
#add wave sim:/k7sim_tb/dut/PCI_Express/PCI_Express/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/genblk1/pcie_7x_v1_9_inst/gt_ges/gt_top_i/pldawrap_pipe/bfm/transactor/*
#add wave sim:/k7sim_tb/dut/PCI_Express/PCI_Express/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/genblk1/pcie_7x_v1_9_inst/gt_ges/gt_top_i/pldawrap_pipe/bfm/transactor/barram/*

do ../../k7aes_sim/wave_all.do

log -r /*

run 80us
