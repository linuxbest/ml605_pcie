eval add wave -noupdate $binopt ${scfifo}${ps}rst_n
eval add wave -noupdate $binopt ${scfifo}${ps}clk

eval add wave -noupdate $binopt ${scfifo}${ps}wr_en
eval add wave -noupdate $binopt ${scfifo}${ps}full
eval add wave -noupdate $hexopt ${scfifo}${ps}din

eval add wave -noupdate $binopt ${scfifo}${ps}rd_en
eval add wave -noupdate $hexopt ${scfifo}${ps}dout
eval add wave -noupdate $binopt ${scfifo}${ps}empty
eval add wave -noupdate $hexopt ${scfifo}${ps}data_count
