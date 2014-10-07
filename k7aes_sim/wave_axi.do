set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -ascii}

#eval add wave -noupdate -divider {"${title}"}
#eval add wave -noupdate $binopt ${axi_bus}${ps}axi_aclk
#eval add wave -noupdate $binopt ${axi_bus}${ps}axi_aresetn

onerror { resume }

# AW
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_awid
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_awaddr
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_awregion
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_awlen
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_awsize
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_awburst
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_awvalid
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_awready

# W
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_wdata
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_wstrb
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_wlast
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_wvalid
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_wready

# BID
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_bid
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_bresp
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_bvalid
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_bready

# AR
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_arid
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_araddr
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_arregion
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_arlen
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_arsize
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_arburst
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_arvalid
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_arready

# R
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_rid
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_rdata
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_rlast
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_rresp
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_rvalid
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_rready

onerror { abort }
