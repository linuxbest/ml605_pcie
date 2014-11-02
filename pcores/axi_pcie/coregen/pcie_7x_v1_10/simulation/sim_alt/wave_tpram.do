eval add wave -noupdate $binopt ${scfifo}${ps}clk_a
eval add wave -noupdate $binopt ${scfifo}${ps}we_a
eval add wave -noupdate $hexopt ${scfifo}${ps}addr_a
eval add wave -noupdate $hexopt ${scfifo}${ps}di_a
eval add wave -noupdate $hexopt ${scfifo}${ps}do_a

eval add wave -noupdate $binopt ${scfifo}${ps}clk_b
eval add wave -noupdate $binopt ${scfifo}${ps}we_b
eval add wave -noupdate $hexopt ${scfifo}${ps}addr_b
eval add wave -noupdate $hexopt ${scfifo}${ps}di_b
eval add wave -noupdate $hexopt ${scfifo}${ps}do_b
