vlog -work work \
        +define+SIMULATION \
	+incdir+../../tb/ml605/ \
	+incdir+../../tb/dsport/ \
        $env(XILINX)/verilog/src/glbl.v \
      -f ../../tb/ml605/board.f

vlog -novopt -incr -work work "ml605_pcie_tb.v"
