if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
set pcie "/k7sim_tb${ps}dut${ps}k7_tlp_0${ps}k7_tlp_0"

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -ascii}
set intopt {-literal -signed}

eval add wave -noupdate -divider {"K7 TLP ext_clk"}
eval add wave -noupdate $binopt $pcie${ps}ext_clk${ps}pipe_clock_i${ps}CLK_CLK
eval add wave -noupdate $binopt $pcie${ps}ext_clk${ps}pipe_clock_i${ps}CLK_TXOUTCLK
eval add wave -noupdate $binopt $pcie${ps}ext_clk${ps}pipe_clock_i${ps}CLK_RXOUTCLK_IN
eval add wave -noupdate $binopt $pcie${ps}ext_clk${ps}pipe_clock_i${ps}CLK_RST_N
eval add wave -noupdate $binopt $pcie${ps}ext_clk${ps}pipe_clock_i${ps}CLK_PCLK_SEL
eval add wave -noupdate $binopt $pcie${ps}ext_clk${ps}pipe_clock_i${ps}CLK_GEN3

eval add wave -noupdate $binopt $pcie${ps}ext_clk${ps}pipe_clock_i${ps}CLK_PCLK
eval add wave -noupdate $binopt $pcie${ps}ext_clk${ps}pipe_clock_i${ps}CLK_RXUSRCLK
eval add wave -noupdate $binopt $pcie${ps}ext_clk${ps}pipe_clock_i${ps}CLK_RXOUTCLK_OUT
eval add wave -noupdate $binopt $pcie${ps}ext_clk${ps}pipe_clock_i${ps}CLK_DCLK
eval add wave -noupdate $binopt $pcie${ps}ext_clk${ps}pipe_clock_i${ps}CLK_OOBCLK
eval add wave -noupdate $binopt $pcie${ps}ext_clk${ps}pipe_clock_i${ps}CLK_USERCLK1
eval add wave -noupdate $binopt $pcie${ps}ext_clk${ps}pipe_clock_i${ps}CLK_USERCLK2
eval add wave -noupdate $binopt $pcie${ps}ext_clk${ps}pipe_clock_i${ps}CLK_MMCM_LOCK
