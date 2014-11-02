eval add wave -noupdate $binopt ${scfifo}${ps}clock0
eval add wave -noupdate $binopt ${scfifo}${ps}wren_a
eval add wave -noupdate $hexopt ${scfifo}${ps}address_a
eval add wave -noupdate $hexopt ${scfifo}${ps}data_a
eval add wave -noupdate $hexopt ${scfifo}${ps}q_a

eval add wave -noupdate $binopt ${scfifo}${ps}clock1
eval add wave -noupdate $binopt ${scfifo}${ps}wren_b
eval add wave -noupdate $hexopt ${scfifo}${ps}address_b
eval add wave -noupdate $hexopt ${scfifo}${ps}data_b
eval add wave -noupdate $hexopt ${scfifo}${ps}q_b
