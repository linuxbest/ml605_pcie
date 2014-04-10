
if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists dmapath] } { set scpath "/system_tb${ps}dut${ps}axi_systemc_0${ps}axi_systemc_0" }

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -asc}

eval add wave -noupdate -divider {"read req"}
eval add wave -noupdate $hexopt $scpath${ps}s_axi_arid
eval add wave -noupdate $hexopt $scpath${ps}s_axi_araddr
eval add wave -noupdate $hexopt $scpath${ps}s_axi_arlen
eval add wave -noupdate $hexopt $scpath${ps}s_axi_arsize
eval add wave -noupdate $binopt $scpath${ps}s_axi_arburst
eval add wave -noupdate $binopt $scpath${ps}s_axi_arlock
eval add wave -noupdate $binopt $scpath${ps}s_axi_arcache
eval add wave -noupdate $binopt $scpath${ps}s_axi_arprot
eval add wave -noupdate $binopt $scpath${ps}s_axi_arvalid
eval add wave -noupdate $binopt $scpath${ps}s_axi_arready

eval add wave -noupdate -divider {"read rsp"}
eval add wave -noupdate $hexopt $scpath${ps}s_axi_arid
eval add wave -noupdate $hexopt $scpath${ps}s_axi_rdata
eval add wave -noupdate $hexopt $scpath${ps}s_axi_rresp
eval add wave -noupdate $binopt $scpath${ps}s_axi_rlast
eval add wave -noupdate $binopt $scpath${ps}s_axi_rvalid
eval add wave -noupdate $binopt $scpath${ps}s_axi_rready

eval add wave -noupdate -divider {"write req"}
eval add wave -noupdate $hexopt $scpath${ps}s_axi_awid
eval add wave -noupdate $hexopt $scpath${ps}s_axi_awaddr
eval add wave -noupdate $hexopt $scpath${ps}s_axi_awlen
eval add wave -noupdate $hexopt $scpath${ps}s_axi_awsize
eval add wave -noupdate $binopt $scpath${ps}s_axi_awburst
eval add wave -noupdate $binopt $scpath${ps}s_axi_awlock
eval add wave -noupdate $binopt $scpath${ps}s_axi_awcache
eval add wave -noupdate $binopt $scpath${ps}s_axi_awprot
eval add wave -noupdate $binopt $scpath${ps}s_axi_awvalid
eval add wave -noupdate $binopt $scpath${ps}s_axi_awready

eval add wave -noupdate -divider {"write data"}
eval add wave -noupdate $hexopt $scpath${ps}s_axi_wdata
eval add wave -noupdate $hexopt $scpath${ps}s_axi_wstrb
eval add wave -noupdate $binopt $scpath${ps}s_axi_wlast
eval add wave -noupdate $binopt $scpath${ps}s_axi_wvalid
eval add wave -noupdate $binopt $scpath${ps}s_axi_wready

eval add wave -noupdate -divider {"write rsp"}
eval add wave -noupdate $hexopt $scpath${ps}s_axi_bid
eval add wave -noupdate $hexopt $scpath${ps}s_axi_bresp
eval add wave -noupdate $binopt $scpath${ps}s_axi_bvalid
eval add wave -noupdate $binopt $scpath${ps}s_axi_bready

eval add wave -noupdate -divider {"BRAM A port"}
eval add wave -noupdate $binopt $scpath${ps}BRAM_Rst_A
eval add wave -noupdate $binopt $scpath${ps}BRAM_Clk_A
eval add wave -noupdate $binopt $scpath${ps}BRAM_En_A
eval add wave -noupdate $hexopt $scpath${ps}BRAM_Addr_A
eval add wave -noupdate $binopt $scpath${ps}BRAM_WE_A
eval add wave -noupdate $hexopt $scpath${ps}BRAM_WrData_A
eval add wave -noupdate $hexopt $scpath${ps}BRAM_RdData_A

eval add wave -noupdate -divider {"BRAM B port"}
eval add wave -noupdate $binopt $scpath${ps}BRAM_Rst_B
eval add wave -noupdate $binopt $scpath${ps}BRAM_Clk_B
eval add wave -noupdate $binopt $scpath${ps}BRAM_En_B
eval add wave -noupdate $hexopt $scpath${ps}BRAM_Addr_B
eval add wave -noupdate $binopt $scpath${ps}BRAM_WE_B
eval add wave -noupdate $hexopt $scpath${ps}BRAM_WrData_B
eval add wave -noupdate $hexopt $scpath${ps}BRAM_RdData_B

#  Wave window configuration information
#
configure  wave -justifyvalue          right
configure  wave -signalnamewidth       1

TreeUpdate [SetDefaultTree]

#  Wave window setup complete
#
echo  "Wave window display setup done."
