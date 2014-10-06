if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists pcie] } { set pcie "/k7sim_tb/dut/PCI_Express" }

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -ascii}

eval add wave -noupdate -divider {"S AXI"}
eval add wave -noupdate $binopt $pcie${ps}axi_aclk
eval add wave -noupdate $binopt $pcie${ps}axi_aresetn

# AW
eval add wave -noupdate $hexopt $pcie${ps}s_axi_awid
eval add wave -noupdate $hexopt $pcie${ps}s_axi_awaddr
eval add wave -noupdate $hexopt $pcie${ps}s_axi_awregion
eval add wave -noupdate $hexopt $pcie${ps}s_axi_awlen
eval add wave -noupdate $hexopt $pcie${ps}s_axi_awsize
eval add wave -noupdate $hexopt $pcie${ps}s_axi_awburst
eval add wave -noupdate $binopt $pcie${ps}s_axi_awvalid
eval add wave -noupdate $binopt $pcie${ps}s_axi_awready

# W
eval add wave -noupdate $hexopt $pcie${ps}s_axi_wdata
eval add wave -noupdate $hexopt $pcie${ps}s_axi_wstrb
eval add wave -noupdate $binopt $pcie${ps}s_axi_wlast
eval add wave -noupdate $binopt $pcie${ps}s_axi_wvalid
eval add wave -noupdate $binopt $pcie${ps}s_axi_wready

# BID
eval add wave -noupdate $hexopt $pcie${ps}s_axi_bid
eval add wave -noupdate $binopt $pcie${ps}s_axi_bresp
eval add wave -noupdate $binopt $pcie${ps}s_axi_bvalid
eval add wave -noupdate $binopt $pcie${ps}s_axi_bready

# AR
eval add wave -noupdate $hexopt $pcie${ps}s_axi_arid
eval add wave -noupdate $hexopt $pcie${ps}s_axi_araddr
eval add wave -noupdate $hexopt $pcie${ps}s_axi_arregion
eval add wave -noupdate $hexopt $pcie${ps}s_axi_arlen
eval add wave -noupdate $hexopt $pcie${ps}s_axi_arsize
eval add wave -noupdate $hexopt $pcie${ps}s_axi_arburst
eval add wave -noupdate $binopt $pcie${ps}s_axi_arvalid
eval add wave -noupdate $binopt $pcie${ps}s_axi_arready

# R
eval add wave -noupdate $hexopt $pcie${ps}s_axi_rid
eval add wave -noupdate $hexopt $pcie${ps}s_axi_rdata
eval add wave -noupdate $binopt $pcie${ps}s_axi_rlast
eval add wave -noupdate $binopt $pcie${ps}s_axi_rresp
eval add wave -noupdate $binopt $pcie${ps}s_axi_rvalid
eval add wave -noupdate $binopt $pcie${ps}s_axi_rready

eval add wave -noupdate -divider {"M AXI"}
eval add wave -noupdate $binopt $pcie${ps}axi_aclk
eval add wave -noupdate $binopt $pcie${ps}axi_aresetn

# AW
#eval add wave -noupdate $hexopt $pcie${ps}m_axi_awid
eval add wave -noupdate $hexopt $pcie${ps}m_axi_awaddr
#eval add wave -noupdate $hexopt $pcie${ps}m_axi_awregion
eval add wave -noupdate $hexopt $pcie${ps}m_axi_awlen
eval add wave -noupdate $hexopt $pcie${ps}m_axi_awsize
eval add wave -noupdate $hexopt $pcie${ps}m_axi_awburst
eval add wave -noupdate $binopt $pcie${ps}m_axi_awvalid
eval add wave -noupdate $binopt $pcie${ps}m_axi_awready

# W
eval add wave -noupdate $hexopt $pcie${ps}m_axi_wdata
eval add wave -noupdate $hexopt $pcie${ps}m_axi_wstrb
eval add wave -noupdate $binopt $pcie${ps}m_axi_wlast
eval add wave -noupdate $binopt $pcie${ps}m_axi_wvalid
eval add wave -noupdate $binopt $pcie${ps}m_axi_wready

# BID
#eval add wave -noupdate $hexopt $pcie${ps}m_axi_bid
eval add wave -noupdate $binopt $pcie${ps}m_axi_bresp
eval add wave -noupdate $binopt $pcie${ps}m_axi_bvalid
eval add wave -noupdate $binopt $pcie${ps}m_axi_bready

# AR
#eval add wave -noupdate $hexopt $pcie${ps}m_axi_arid
eval add wave -noupdate $hexopt $pcie${ps}m_axi_araddr
#eval add wave -noupdate $hexopt $pcie${ps}m_axi_arregion
eval add wave -noupdate $hexopt $pcie${ps}m_axi_arlen
eval add wave -noupdate $hexopt $pcie${ps}m_axi_arsize
eval add wave -noupdate $hexopt $pcie${ps}m_axi_arburst
eval add wave -noupdate $binopt $pcie${ps}m_axi_arvalid
eval add wave -noupdate $binopt $pcie${ps}m_axi_arready

# R
#eval add wave -noupdate $hexopt $pcie${ps}m_axi_rid
eval add wave -noupdate $hexopt $pcie${ps}m_axi_rdata
eval add wave -noupdate $binopt $pcie${ps}m_axi_rlast
eval add wave -noupdate $binopt $pcie${ps}m_axi_rresp
eval add wave -noupdate $binopt $pcie${ps}m_axi_rvalid
eval add wave -noupdate $binopt $pcie${ps}m_axi_rready
