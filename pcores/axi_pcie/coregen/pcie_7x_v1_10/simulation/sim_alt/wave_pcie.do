if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }

set pcie "/board/EP/app/PIO/altpciexpav128_app"

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -ascii}

eval add wave -noupdate -divider {"PCIE stream RX"}
eval add wave -noupdate $binopt $pcie${ps}rx${ps}Clk_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}Rstn_i

eval add wave -noupdate $binopt $pcie${ps}rx${ps}RxStReady_o
eval add wave -noupdate $binopt $pcie${ps}rx${ps}RxStMask_o
eval add wave -noupdate $binopt $pcie${ps}rx${ps}RxStSop_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}RxStEop_i
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}RxStData_i(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}RxStData_i(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}RxStData_i(64 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}RxStData_i(31 downto 0)\"
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}RxStBe_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}RxStEmpty_i
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}RxStBarDec1_i
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}RxStBarDec2_i

eval add wave -noupdate -divider {"PCIE stream RXM0"}
eval add wave -noupdate $binopt $pcie${ps}rx${ps}Clk_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}Rstn_i

eval add wave -noupdate $binopt $pcie${ps}rx${ps}RxmWrite_0_o
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}RxmAddress_0_o
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}RxmWriteData_0_o
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}RxmByteEnable_0_o
eval add wave -noupdate $hexopt $pcie${ps}rx${ps}RxmBurstCount_0_o
eval add wave -noupdate $binopt $pcie${ps}rx${ps}RxmWaitRequest_0_i
eval add wave -noupdate $binopt $pcie${ps}rx${ps}RxmRead_0_o

eval add wave -noupdate -divider {"PCIE stream Rx Data"}
eval add wave -noupdate $binopt $pcie${ps}rx${ps}Clk_i
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}TxReadData_o(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}TxReadData_o(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}TxReadData_o(63 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}rx${ps}TxReadData_o(31 downto 0)\"
eval add wave -noupdate $binopt $pcie${ps}rx${ps}TxReadDataValid_o


################################
eval add wave -noupdate -divider {"PCIE stream TX"}
eval add wave -noupdate $binopt $pcie${ps}tx${ps}Clk_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}Rstn_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxsRstn_i

eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxStReady_i
#eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxStErr_o
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxStSop_o
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxStEop_o
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxStData_o(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxStData_o(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxStData_o(64 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxStData_o(31 downto 0)\"
#eval add wave -noupdate $hexopt $pcie${ps}tx${ps}TxStParity_o
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxStEmpty_o
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxAdapterFifoEmpty_i
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}DevCsr_i
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}BusDev_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}CplPending_o

eval add wave -noupdate -divider {"PCIE stream TXM"}
eval add wave -noupdate $binopt $pcie${ps}tx${ps}Clk_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}Rstn_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxsRstn_i

eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxChipSelect_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxRead_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxWrite_i
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}TxBurstCount_i
eval add wave -noupdate $hexopt $pcie${ps}tx${ps}TxAddress_i

eval add wave -noupdate $hexopt $pcie${ps}tx${ps}TxByteEnable_i
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxWriteData_i(127 downto 96)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxWriteData_i(95 downto 64)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxWriteData_i(64 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxWriteData_i(31 downto 0)\"

eval add wave -noupdate $binopt $pcie${ps}tx${ps}TxReadDataValid_i
#eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxReadData_i(127 downto 96)\"
#eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxReadData_i(95 downto 64)\"
#eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxReadData_i(64 downto 32)\"
eval add wave -noupdate $hexopt \"$pcie${ps}tx${ps}TxReadData_i(31 downto 0)\"

eval add wave -noupdate $binopt $pcie${ps}tx${ps}RxmIrq_i
eval add wave -noupdate $binopt $pcie${ps}tx${ps}MasterEnable_i
