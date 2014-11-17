set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -ascii}

#eval add wave -noupdate -divider {"${title}"}
#eval add wave -noupdate $binopt ${axi_bus}${ps}axi_aclk
#eval add wave -noupdate $binopt ${axi_bus}${ps}axi_aresetn

onerror { resume }

# AW
eval add wave -noupdate -divider {"${title} Write Address"}
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_AWID     
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_AWADDR   
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_AWREGION 
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_AWLEN    
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_AWSIZE   
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_AWBURST  
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_AWVALID  
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_AWREADY  
                                                                
# W                                                             
eval add wave -noupdate -divider {"${title} Write Data"}
eval add wave -noupdate $hexopt \"${axi_bus}${ps}${name}_WDATA(127 downto 96)\"    
eval add wave -noupdate $hexopt \"${axi_bus}${ps}${name}_WDATA(95 downto 64)\"    
eval add wave -noupdate $hexopt \"${axi_bus}${ps}${name}_WDATA(63 downto 32)\"    
eval add wave -noupdate $hexopt \"${axi_bus}${ps}${name}_WDATA(31 downto 0)\"    
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_WSTRB    
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_WLAST    
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_WVALID   
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_WREADY   
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_WID
                                                                
# BID                                                           
eval add wave -noupdate -divider {"${title} Write Rsp"}
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_BID      
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_BRESP    
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_BVALID   
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_BREADY   
                                                                
# AR                                                            
eval add wave -noupdate -divider {"${title} Read Address"}
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_ARID     
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_ARADDR   
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_ARREGION 
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_ARLEN    
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_ARSIZE   
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_ARBURST  
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_ARVALID  
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_ARREADY  
                                                                
# R                                                             
eval add wave -noupdate -divider {"${title} Read Data"}
eval add wave -noupdate $hexopt ${axi_bus}${ps}${name}_RID      
eval add wave -noupdate $hexopt \"${axi_bus}${ps}${name}_RDATA(127 downto 96)\"    
eval add wave -noupdate $hexopt \"${axi_bus}${ps}${name}_RDATA(95 downto 64)\"    
eval add wave -noupdate $hexopt \"${axi_bus}${ps}${name}_RDATA(63 downto 32)\"    
eval add wave -noupdate $hexopt \"${axi_bus}${ps}${name}_RDATA(31 downto 0)\"    
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_RLAST    
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_RRESP    
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_RVALID   
eval add wave -noupdate $binopt ${axi_bus}${ps}${name}_RREADY   

onerror { abort }
