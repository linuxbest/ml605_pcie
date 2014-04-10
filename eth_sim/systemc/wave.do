
if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists dmapath] } { set scpath "/system_tb${ps}dut${ps}axi_systemc_0${ps}axi_systemc_0" }

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -asc}

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
