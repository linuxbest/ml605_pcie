if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists pcie] } { set pcie "/k7sim_tb/dut/PCI_Express" }

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -ascii}

eval add wave -noupdate -divider {"S AXI"}
eval add wave -noupdate $binopt $pcie${ps}axi_aclk
eval add wave -noupdate $binopt $pcie${ps}axi_aresetn

set axi_bus $pcie
set name    s_axi
do ../../k7aes_sim/wave_axi.do

eval add wave -noupdate -divider {"AXIS Write Request"}
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rw_tdata
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rw_tstrb
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rw_tlast
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rw_tvalid
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rw_tready

eval add wave -noupdate -divider {"AXIS Read Request"}
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rr_tdata
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rr_tstrb
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rr_tlast
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rr_tvalid
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rr_tready

eval add wave -noupdate -divider {"AXIS Complete Request"}
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_rc_tdata
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_rc_tstrb
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_rc_tlast
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_rc_tvalid
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_rc_tready

eval add wave -noupdate -divider {"AXIS Write Complete"}
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cw_tdata
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cw_tstrb
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cw_tlast
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cw_tvalid
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cw_tready

eval add wave -noupdate -divider {"AXIS Read Complete"}
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cr_tdata
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cr_tstrb
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cr_tlast
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cr_tvalid
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cr_tready

eval add wave -noupdate -divider {"AXIS Complete Complete"}
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_cc_tdata
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_cc_tstrb
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_cc_tlast
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_cc_tvalid
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_cc_tready
