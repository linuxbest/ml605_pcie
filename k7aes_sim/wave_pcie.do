if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists pcie] } { set pcie "/k7sim_tb/dut/PCI_Express" }

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -ascii}

eval add wave -noupdate -divider {"PCIE_S AXI"}
eval add wave -noupdate $binopt $pcie${ps}axi_aclk
eval add wave -noupdate $binopt $pcie${ps}axi_aresetn

set axi_bus $pcie
set name    s_axi
do ../../k7aes_sim/wave_axi.do

eval add wave -noupdate -divider {"PCIE Slave AXIS Write Request"}
eval add wave -noupdate $binopt $pcie${ps}axi_aclk
eval add wave -noupdate $binopt $pcie${ps}axi_aresetn
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rw_tdata(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rw_tdata(95  downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rw_tdata(63  downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rw_tdata(31  downto  0)\"
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rw_tstrb
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rw_tlast
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rw_tvalid
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rw_tready

eval add wave -noupdate -divider {"PCIE Slave AXIS Read Request"}
eval add wave -noupdate $binopt $pcie${ps}axi_aclk
eval add wave -noupdate $binopt $pcie${ps}axi_aresetn
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rr_tdata(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rr_tdata(95  downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rr_tdata(63  downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rr_tdata(31  downto  0)\"
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rr_tstrb
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rr_tlast
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rr_tvalid
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_rr_tready

eval add wave -noupdate -divider {"PCIE Slave AXIS Complete Request"}
eval add wave -noupdate $binopt $pcie${ps}axi_aclk
eval add wave -noupdate $binopt $pcie${ps}axi_aresetn
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_rc_tdata(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_rc_tdata(95  downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_rc_tdata(63  downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_rc_tdata(31  downto  0)\"
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_rc_tstrb
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_rc_tlast
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_rc_tvalid
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_rc_tready


eval add wave -noupdate -divider {"PCIE_M AXI"}
eval add wave -noupdate $binopt $pcie${ps}axi_aclk
eval add wave -noupdate $binopt $pcie${ps}axi_aresetn
set axi_bus $pcie
set name    m_axi
do ../../k7aes_sim/wave_axi.do

eval add wave -noupdate -divider {"PCIE Master AXIS Write Complete"}
eval add wave -noupdate $binopt $pcie${ps}axi_aclk
eval add wave -noupdate $binopt $pcie${ps}axi_aresetn
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cw_tdata(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cw_tdata(95  downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cw_tdata(63  downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cw_tdata(31  downto  0)\"
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cw_tstrb
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cw_tlast
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cw_tvalid
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cw_tready

eval add wave -noupdate -divider {"PCIE Master AXIS Read Complete"}
eval add wave -noupdate $binopt $pcie${ps}axi_aclk
eval add wave -noupdate $binopt $pcie${ps}axi_aresetn
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cr_tdata(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cr_tdata(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cr_tdata(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cr_tdata(31 downto 0)\"
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cr_tstrb
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cr_tlast
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cr_tvalid
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}s_axis_cr_tready

eval add wave -noupdate -divider {"PCIE Master AXIS Complete Complete"}
eval add wave -noupdate $binopt $pcie${ps}axi_aclk
eval add wave -noupdate $binopt $pcie${ps}axi_aresetn
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_cc_tdata(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_cc_tdata(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_cc_tdata(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_cc_tdata(31 downto 0)\"
eval add wave -noupdate $hexopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_cc_tstrb
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_cc_tlast
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_cc_tvalid
eval add wave -noupdate $binopt $pcie${ps}PCI_Express${ps}comp_axi_pcie_mm_s${ps}m_axis_cc_tready
