all: mac_loopback.bit

PRJ=mac_loopback.prj
DEV=xc7k325t-ffg900-2

export XIL_PAR_DESIGN_CHECK_VERBOSE=1

# NGC
mac_loopback.ngc: ../mac_loopback.v 
	xst -ifn mac_loopback.scr -ofn mac_loopback.syr -intstyle ise

# TRANSLATE
mac_loopback.ngd: mac_loopback.ngc ../mac_loopback.ucf 
	ngdbuild -intstyle ise -sd ../../netlist -dd . -nt timestamp -uc ../mac_loopback.ucf -p ${DEV} mac_loopback.ngc mac_loopback.ngd

# MAP
mac_loopback_map.ncd: mac_loopback.ngd
	map -intstyle ise -p ${DEV} -w -pr b -ol high -timing -detail -o mac_loopback_map.ncd mac_loopback.ngd mac_loopback.pcf

# PAR
mac_loopback.ncd: mac_loopback_map.ncd
	par -w -intstyle ise -ol high mac_loopback_map.ncd mac_loopback.ncd mac_loopback.pcf

# TRACE
mac_loopback.twr: mac_loopback.ncd
	trce -intstyle ise -v 3 -fastpaths -xml mac_loopback mac_loopback.ncd -o mac_loopback.twr mac_loopback.pcf

# BIT
mac_loopback.bit: ${CGS} mac_loopback.ncd mac_loopback.twr
	bitgen -w -intstyle ise mac_loopback.ncd
