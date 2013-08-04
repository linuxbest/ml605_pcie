vlog -work work \
        +define+SIMULATION \
	+incdir+../../tb/ml605/ \
	+incdir+../../tb/dsport/ \
        $env(XILINX)/verilog/src/glbl.v \
      -f ../../tb/ml605/board.f

vlog -novopt -work axi_aes_v1_00_a ../../pcores/axi_aes_v1_00_a/hdl/verilog/axi_lite_write.v
vlog -novopt -work axi_aes_v1_00_a ../../pcores/axi_aes_v1_00_a/hdl/verilog/axi_lite_slave.v
vlog -novopt -work axi_aes_v1_00_a ../../pcores/axi_aes_v1_00_a/hdl/verilog/axi_aes.v

vlog -novopt -work work "ml605_pcie_tb.v"

do ml605_pcie_setup.do

s
w

run -all
