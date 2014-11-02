set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -ascii}

eval add wave -noupdate $binopt $path${ps}${prefix}WaitRequest
eval add wave -noupdate $binopt $path${ps}${prefix}Read
eval add wave -noupdate $binopt $path${ps}${prefix}Write
eval add wave -noupdate $hexopt $path${ps}${prefix}Address
eval add wave -noupdate $hexopt $path${ps}${prefix}BurstCount
eval add wave -noupdate $hexopt $path${ps}${prefix}ByteEnable
eval add wave -noupdate $hexopt \"$path${ps}${prefix}WriteData(127 downto 96)\"
eval add wave -noupdate $hexopt \"$path${ps}${prefix}WriteData(95 downto 64)\"
eval add wave -noupdate $hexopt \"$path${ps}${prefix}WriteData(63 downto 32)\"
eval add wave -noupdate $hexopt \"$path${ps}${prefix}WriteData(31 downto 0)\"

eval add wave -noupdate $binopt $path${ps}${prefix}ReadDataValid
eval add wave -noupdate $hexopt \"$path${ps}${prefix}ReadData(127 downto 96)\"
eval add wave -noupdate $hexopt \"$path${ps}${prefix}ReadData(95 downto 64)\"
eval add wave -noupdate $hexopt \"$path${ps}${prefix}ReadData(63 downto 32)\"
eval add wave -noupdate $hexopt \"$path${ps}${prefix}ReadData(31 downto 0)\"
