do k7sim_setup.do

vlog -novopt -incr -work axi_pcie_v1_08_a "../../pciebfm_lib/*.v" {+incdir+../../pciebfm_lib/}
vlog -novopt -incr -work axi_pcie_v1_08_a "../../k7aes_sim/*.v" {+incdir+../../pciebfm_lib/}

vlog -novopt -incr -work work "k7sim_tb.v" {+incdir+../../pciebfm_lib/}

#vsim -novopt -t ps -L xilinxcorelib_ver -L secureip -L unisims_ver +notimingchecks -L unimacro_ver k7sim_tb glbl
#vsim -voptargs="+acc" +notimingchecks -L xilinxcorelib_ver -L secureip -L unisims_ver +notimingchecks -L unimacro_ver k7sim_tb glbl

s
w

run 50us
