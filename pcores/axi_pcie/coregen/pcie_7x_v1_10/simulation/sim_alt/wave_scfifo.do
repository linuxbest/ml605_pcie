eval add wave -noupdate $binopt ${scfifo}${ps}aclr
eval add wave -noupdate $binopt ${scfifo}${ps}sclr
eval add wave -noupdate $binopt ${scfifo}${ps}clock

eval add wave -noupdate $binopt ${scfifo}${ps}wrreq
eval add wave -noupdate $binopt ${scfifo}${ps}full
eval add wave -noupdate $hexopt ${scfifo}${ps}data

eval add wave -noupdate $binopt ${scfifo}${ps}rdreq
eval add wave -noupdate $binopt ${scfifo}${ps}empty
eval add wave -noupdate $hexopt ${scfifo}${ps}q

eval add wave -noupdate $hexopt ${scfifo}${ps}usedw
