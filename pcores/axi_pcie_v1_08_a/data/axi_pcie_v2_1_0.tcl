#############################################################################
##
## Copyright (c) 2011 Xilinx, Inc. All Rights Reserved.
##
## axi_pcie_v2_1_0.tcl
##
#############################################################################




#***--------------------------------***-----------------------------------***
#
#			     IPLEVEL_UPDATE_VALUE_PROC
#
#***--------------------------------***-----------------------------------***



#***--------------------------------***-----------------------------------***
#
#			     UPDATE_ACLK_OUT
#
#***--------------------------------***-----------------------------------***


proc update_aclk_out {param_handle} {

  set mhsinst [xget_hw_parent_handle $param_handle]

  set ref_clk_freq [xget_hw_parameter_value $mhsinst "C_REF_CLK_FREQ"]
  
  if { $ref_clk_freq == 0 } {
     	set ref_clk_freq_hz 100000000
  } elseif { $ref_clk_freq == 1 } {
     	set ref_clk_freq_hz 125000000
  } elseif {$ref_clk_freq == 2} {
     	set ref_clk_freq_hz 250000000
  } else {
 	set ref_clk_freq_hz 100000000
  }
 
 return $ref_clk_freq_hz
 
}


#***--------------------------------***-----------------------------------***
#
#			     IPLEVEL_DRC_PROC
#
#***--------------------------------***-----------------------------------***

  
proc check_iplevel_settings {mhsinst} {
  
      # Check no addresses overlap on memory mapping
      check_memory_bank_overlap $mhsinst
      
      # Check parameter settings based on C_FAMILY
      check_family_parameter_settings $mhsinst
      
      set include_rc   		[xget_hw_parameter_value $mhsinst "C_INCLUDE_RC"]
      set cap_slot_imp   	[xget_hw_parameter_value $mhsinst "C_PCIE_CAP_SLOT_IMPLEMENTED"]
      set pciebar_num   	[xget_hw_parameter_value $mhsinst "C_PCIBAR_NUM"]

      if { $include_rc != 1 && $cap_slot_imp == 1} {
         error "\n PCIe Capabilities Register Slot only valid for Root Complex\n" "" "mdt_error"
      }
      
      if { $include_rc == 1 && $pciebar_num > 1} {
         error "\n Number of PCIE BARS can only be 1 for RootPort configuration\n" "" "mdt_error"
      }
  
  }
  
  
  

# Check C_FAMILY parameter settings
#
# Spartan-6 can only be x1 Gen1 and 32-bit AXI
# Virtex-6 can only be x1/x2/x4 Gen1 or x1/x2 Gen2 and 64-bit AXI
# 7-Series can only be x1/x2/x4/x8 Gen1 or x1/x2/x4 Gen2 and 64-bit or 128-bit AXI
# 7-Series includes Kintex-7, Virtex-7, Artix-7, and Zynq FPGA architectures.

proc check_family_parameter_settings {mhsinst} {
  
     set family             	[xget_hw_parameter_value $mhsinst "C_FAMILY"]
     set mhs_family            	$family
     set no_of_lanes        	[xget_hw_parameter_value $mhsinst "C_NO_OF_LANES"]
     set max_link_spd        	[xget_hw_parameter_value $mhsinst "C_MAX_LINK_SPEED"]
     set ref_clk_freq        	[xget_hw_parameter_value $mhsinst "C_REF_CLK_FREQ"]
     set maxi_dwidth 		[xget_hw_parameter_value $mhsinst "C_M_AXI_DATA_WIDTH"]
     set saxi_dwidth 		[xget_hw_parameter_value $mhsinst "C_S_AXI_DATA_WIDTH"]
     set include_rc   		[xget_hw_parameter_value $mhsinst "C_INCLUDE_RC"]
     set gt_use_mode   		[xget_hw_parameter_value $mhsinst "C_PCIE_USE_MODE"]


     # Set up derivative family checks.

     # Virtex-6L
     if { [string compare -nocase "virtex6l" $family] == 0 } {
     	set family "virtex6"
     
     # QVirtex-6
     } elseif { [string compare -nocase "qvirtex6" $family] == 0 } {
     	set family "virtex6"
     	
     # Spartan-6L
     } elseif { [string compare -nocase "spartan6l" $family] == 0 } {
     	set family "spartan6"
     
     # QSpartan-6
     } elseif { [string compare -nocase "qspartan6" $family] == 0 } {
     	set family "spartan6"

     # Kintex-7
     } elseif { [string compare -nocase "kintex7" $family] == 0 } {
     	set family "7series"

     # Kintex-7L
     } elseif { [string compare -nocase "kintex7l" $family] == 0 } {
     	set family "7series"
     	set mhs_family "kintex7"

     # Virtex-7
     } elseif { [string compare -nocase "virtex7" $family] == 0 } {
     	set family "7series"
     
     # Virtex-7L
     } elseif { [string compare -nocase "virtex7l" $family] == 0 } {
     	set family "7series"
     	set mhs_family "virtix7"

     # Artix-7
     } elseif { [string compare -nocase "artix7" $family] == 0 } {
     	set family "7series"

     # Artix-7L
     } elseif { [string compare -nocase "artix7l" $family] == 0 } {
     	set family "7series"
     	set mhs_family "artix7"

     # Zynq
     } elseif { [string compare -nocase "zynq" $family] == 0 } {
     	set family "7series"
     }



     
     # Spartan-6
     if { [string compare -nocase "spartan6" $family] == 0 } {
     
        if { $no_of_lanes != 1 } {
           error "\n Spartan-6 only supports x1 Gen1 configuration.\n" "" "mdt_error" 
        }
        
        if { $maxi_dwidth != 32 } {
           error "\n Spartan-6 only supports 32-bit data width.\n" "" "mdt_error"
        }

        if { $saxi_dwidth != 32 } {
           error "\n Spartan-6 only supports 32-bit data width.\n" "" "mdt_error"
        }        
        
        if { $max_link_spd != 0 } {
           error "\n Spartan-6 only supports 2.5 GT/s PCIe link speed.\n" "" "mdt_error"
        }        

        if { $include_rc != 0 } {
           error "\n Spartan-6 does not support Root Complex.\n" "" "mdt_error"
        }        

        if { $ref_clk_freq == 2 } {
           error "\n Spartan-6 does not support a 250 MHz REFCLK input.\n" "" "mdt_error"
        }        


     # Virtex-6
     } elseif { [string compare -nocase "virtex6" $family] == 0 } {
     
        if { $no_of_lanes == 4 && $max_link_spd == 1 } {
           error "\n Virtex-6 does not support a x4 Gen2 configuration.\n" "" "mdt_error" 
        }             

        if { $no_of_lanes == 8 && $max_link_spd == 0 } {
           error "\n Virtex-6 does not support a x8 Gen1 configuration.\n" "" "mdt_error" 
        }             

        if { $no_of_lanes == 8 && $max_link_spd == 1 } {
           error "\n Virtex-6 does not support a x8 Gen2 configuration.\n" "" "mdt_error" 
        }             
           
        if { $maxi_dwidth != 64 } {
           error "\n Virtex-6 only supports 64-bit data width.\n" "" "mdt_error"
        }  
        
        if { $saxi_dwidth != 64 } {
           error "\n Virtex-6 only supports 64-bit data width.\n" "" "mdt_error"
        }      
        
        if { $ref_clk_freq == 1 } {
           error "\n Virtex-6 does not support a 125 MHz REFCLK input.\n" "" "mdt_error"
        }        


     # 7-Series 
     # Print error message with $mhs_family string.
     } elseif { [string compare -nocase "7series" $family] == 0 } {

        if { $no_of_lanes == 8 && $max_link_spd == 1 } {
           error "\n $mhs_family does not support a x8 Gen2 configuration\n" "" "mdt_error" 
        }             

	# Check 128-bit S_AXI data width settings
	if {$saxi_dwidth != 128} {
	
		if { $no_of_lanes == 8 && $max_link_spd == 0 } {
		   error "\n S_AXI data width must be 128-bit with a x8 Gen1 configuration.\n" "" "mdt_error" 
		}             

		if { $no_of_lanes == 4 && $max_link_spd == 1 } {
		   error "\n S_AXI data width must be 128-bit with a x4 Gen2 configuration.\n" "" "mdt_error" 
		}            
	}
        
        if { $maxi_dwidth == 32 } {
           error "\n $mhs_family only supports 64-bit or 128-bit data width.\n" "" "mdt_error"
        }  

        if { $saxi_dwidth == 32 } {
           error "\n $mhs_family only supports 64-bit or 128-bit data width.\n" "" "mdt_error"
        }     
        



	# Check GT mode usage for 7-Series (K7, V7 and A7) ONLY
	
	# Kintex-7
	if { [string compare -nocase "kintex7" $mhs_family] == 0 } {
	
		if { [string compare -nocase "1.1" $gt_use_mode] == 0 } {
           	    error "\n $mhs_family does not support C_PCIE_USE_MODE = \"$gt_use_mode\".\n" "" "mdt_error" 
		}
		
	# Virtex-7
	} elseif { [string compare -nocase "virtex7" $mhs_family] == 0 } {
	
		if { [string compare -nocase "1.0" $gt_use_mode] == 0 } {
           	    error "\n $mhs_family does not support C_PCIE_USE_MODE = \"$gt_use_mode\".\n" "" "mdt_error" 
		}
	

	# Artix-7
	} elseif { [string compare -nocase "artix7" $mhs_family] == 0 } {
	
		if { [string compare -nocase "1.0" $gt_use_mode] == 0 } {
           	    error "\n $mhs_family does not support C_PCIE_USE_MODE = \"$gt_use_mode\".\n" "" "mdt_error" 
		} elseif { [string compare -nocase "1.1" $gt_use_mode] == 0 } {
           	    error "\n $mhs_family does not support C_PCIE_USE_MODE = \"$gt_use_mode\".\n" "" "mdt_error" 
		}
	
	}
	
     }

} 
     
  
  

# Check no address overlap within memory 
# C_BASEADDR/C_HIGHADDR  and
# C_AXIBAR_x, C_AXIBAR_HIGHADDR_x; x = 0 to C_AXIBAR_NUM - 1
#
proc check_memory_bank_overlap {mhsinst} {

   set baseList ""
   set highList ""
   set allList  ""

   # C_BASEADDR/C_HIGHADDR
   set base_value [xget_hw_parameter_value $mhsinst "C_BASEADDR"]
   set high_value [xget_hw_parameter_value $mhsinst "C_HIGHADDR"]
   
   if {[update_addr_list $base_value $high_value] != 1} {

	lappend baseList $base_value 
	lappend highList $high_value
	lappend allList  $base_value $high_value

   }

   # C_AXIBAR_x/C_AXIBAR_HIGHADDR_x
   set num_banks [xget_hw_parameter_value $mhsinst "C_AXIBAR_NUM"]

   for {set i 0} {$i < $num_banks} {incr i} {

	set base_param [concat C_AXIBAR_${i}]
	set high_param [concat C_AXIBAR_HIGHADDR_${i}]

	# convert to hexadecimal format
	set base_value [xget_hw_parameter_value $mhsinst $base_param]
	set high_value [xget_hw_parameter_value $mhsinst $high_param]

   	if {[update_addr_list $base_value $high_value] != 1} {

	    lappend baseList $base_value 
	    lappend highList $high_value
	    lappend allList  $base_value $high_value

 	}
   }

   set newList [lsort $allList]

   for {set i 0} {$i < [llength $baseList]} {incr i} {

	set i_base [lsearch $newList [lindex $baseList $i]]
	set i_high [lsearch $newList [lindex $highList $i]]

	if { [expr $i_high - $i_base] != 1 } {

	    error "\n Check address overlap within banks of memory\n" "" "mdt_error"

	}
    
   }
   
}


# If base/high address pair has been set, add them to the address list
# to check memory overlap

proc update_addr_list {base_value high_value} {

    set base_value  [get_hex_addr $base_value]
    set high_value  [get_hex_addr $high_value]

    set int_base    [expr int($base_value)]
    set int_high    [expr int($high_value)]

    return [compare_unsigned_int_values $int_base $int_high]

}



proc get_hex_addr {addr_value} {

    if {[string match -nocase 0b* $addr_value]} {
	return [xconvert_binary_to_hex $addr_value]
    } else {
        return [format "0x%08X" $addr_value]
    }    
}





#***--------------------------------***-----------------------------------***
#
#			     SYSLEVEL_UPDATE_VALUE_PROC
#
#***--------------------------------***-----------------------------------***




#***--------------------------------***------------------------------------***
#
#			     SYSLEVEL_DRC_PROC
#
#***--------------------------------***------------------------------------***

proc check_syslevel_settings { mhsinst } {

}


#***--------------------------------***-----------------------------------***
#
#			     CORE_LEVEL_CONSTRAINTS
#
#***--------------------------------***-----------------------------------***




#***--------------------------------***-----------------------------------***
#
#     			PLATGEN_SYSLEVEL_UPDATE_PROC
#
#***--------------------------------***-----------------------------------***


# Entry point for PLATGEN_SYSLEVEL_UPDATE_PROC TCL functions

proc platgen_update {mhsinst} {
    generate_corelevel_ucf $mhsinst
    generate_corelevel_xdc $mhsinst
}



#***--------------------------------***-----------------------------------***
#
#     			GENERATE_CORELEVEL_UCF
#
#***--------------------------------***-----------------------------------***

# Generate UCF constraints for IP

proc generate_corelevel_ucf { mhsinst } {

    # Open UCF file for writing
    set filePath [xget_ncf_dir $mhsinst]
    file mkdir $filePath

    # Specify file name
    set instname [xget_hw_parameter_value $mhsinst "INSTANCE"]
    set name_lower [string tolower $instname]

    set fileName $name_lower
    append fileName "_wrapper.ucf"
    append filePath $fileName

    # Open a file for writing
    set outputFile [open $filePath "w"]

    # Create local variables
    set family [xget_hw_parameter_value $mhsinst "C_FAMILY"]
    set mhs_family $family
    set pcie_gen [xget_hw_parameter_value $mhsinst "C_MAX_LINK_SPEED"]
    set pcie_width [xget_hw_parameter_value $mhsinst "C_NO_OF_LANES"]
    set is_rc [xget_hw_parameter_value $mhsinst "C_INCLUDE_RC"]
    set ref_clk [xget_hw_parameter_value $mhsinst "C_REF_CLK_FREQ"]
    set gt_use_mode [xget_hw_parameter_value $mhsinst "C_PCIE_USE_MODE"]
    set gt_path ""
    if {$gt_use_mode == 1.0 || $gt_use_mode == 1.1} {
       set gt_path "gt_ies.gt_top_i"
     } else {
       set gt_path "gt_ges.gt_top_i"
     }


    set ref_clk_sig [xget_hw_port_value $mhsinst "REFCLK"]


     # Set derivative C_FAMILY

     # Virtex-6
     if { [string compare -nocase "virtex6" $family] == 0 } {
     	set family "virtex6"

     # Virtex-6L
     } elseif { [string compare -nocase "virtex6l" $family] == 0 } {
     	set family "virtex6"
     
     # QVirtex-6
     } elseif { [string compare -nocase "qvirtex6" $family] == 0 } {
     	set family "virtex6"
     	
     # Spartan-6L
     } elseif { [string compare -nocase "spartan6l" $family] == 0 } {
     	set family "spartan6"

     # QSpartan-6
     } elseif { [string compare -nocase "qspartan6" $family] == 0 } {
     	set family "spartan6"
     
     # Kintex-7
     } elseif { [string compare -nocase "kintex7" $family] == 0 } {
     	set family "7series"

     # Kintex-7L
     } elseif { [string compare -nocase "kintex7l" $family] == 0 } {
     	set family "7series"

     # Virtex-7
     } elseif { [string compare -nocase "virtex7" $family] == 0 } {
     	set family "7series"
     
     # Virtex-7L
     } elseif { [string compare -nocase "virtex7l" $family] == 0 } {
     	set family "7series"

     # Artix-7
     } elseif { [string compare -nocase "artix7" $family] == 0 } {
     	set family "7series"

     # Zynq
     } elseif { [string compare -nocase "zynq" $family] == 0 } {
     	set family "7series"
     }


		
    puts $outputFile "\n"
    puts $outputFile "# AXI PCIe UCF: Timing Constraints ONLY"
    puts $outputFile "\n"

    # Kintex-7
    if { [xstrncmp $family "7series"] } {
    
    	if { [xstrncmp $mhs_family "zynq"] } {
    		puts $outputFile "# AXI PCIe UCF: Base family is Zynq"
    	} else {
    		puts $outputFile "# AXI PCIe UCF: Base family is 7-Series"
    	}
    	puts $outputFile "\n"

	if { $ref_clk == 0 } {
    		puts $outputFile "# AXI PCIe UCF: Reference Clock is 100 MHz"
    		puts $outputFile "NET \"$ref_clk_sig\" TNM_NET = \"SYSCLK\";"
    		puts $outputFile "TIMESPEC \"TS_SYSCLK\" = PERIOD 100.00 MHz HIGH 50 %;"
		if { [xstrncmp $family "7series"] } {
		puts $outputFile "NET \"*/axi_pcie_enhanced_core_top_i/pcie_7x_v1_9_inst/${gt_path}/pipe_wrapper_i/pipe_lane\[0\].gt_wrapper_i/gtx_channel.gtxe2_channel_i/TXOUTCLK\" TNM_NET = \"TXOUTCLK\";"
		puts $outputFile "TIMESPEC \"TS_TXOUTCLK\" = PERIOD 100.00 MHz HIGH 50 %;"
		}
	
	} elseif { $ref_clk == 1 } {
    		puts $outputFile "# AXI PCIe UCF: Reference Clock is 125 MHz"
    		puts $outputFile "# AXI PCIe UCF: Not supported C_REF_CLK_FREQ for 7-Series"
	
	} elseif { $ref_clk == 2 } {
    		puts $outputFile "# AXI PCIe UCF: Reference Clock is 250 MHz"
    		puts $outputFile "NET \"$ref_clk_sig\" TNM_NET = \"SYSCLK\";"
    		puts $outputFile "TIMESPEC \"TS_SYSCLK\" = PERIOD 250.00 MHz HIGH 50 %;"
		if { [xstrncmp $family "7series"] } {
		puts $outputFile "NET \"*/axi_pcie_enhanced_core_top_i/pcie_7x_v1_9_inst/${gt_path}/pipe_wrapper_i/pipe_lane\[0\].gt_wrapper_i/gtx_channel.gtxe2_channel_i/TXOUTCLK\" TNM_NET = \"TXOUTCLK\";"
		puts $outputFile "TIMESPEC \"TS_TXOUTCLK\" = PERIOD 250.00 MHz HIGH 50 %;"
		}
    	}
    	puts $outputFile "\n"

	puts $outputFile "NET \"*pipe_clock_i/clk_125mhz\" 	TNM_NET = \"CLK_125\" ;"
	puts $outputFile "NET \"*pipe_clock_i/clk_250mhz\" 	TNM_NET = \"CLK_250\" ;"
	puts $outputFile "NET \"*pipe_clock_i/userclk1\" 	TNM_NET = \"CLK_USERCLK\" ;"
	puts $outputFile "NET \"*pipe_clock_i/userclk2\" 	TNM_NET = \"CLK_USERCLK2\" ;"

	puts $outputFile "\n"
    	    	
        if { $pcie_gen == 0} {
            puts $outputFile "# AXI PCIe UCF: Gen1 Constraints"
            if { $ref_clk == 2 } { 
		puts $outputFile "TIMESPEC \"TS_CLK_125\" = PERIOD \"CLK_125\" TS_SYSCLK*0.5 HIGH 50 % PRIORITY 1 ;"
	    	puts $outputFile "TIMESPEC \"TS_CLK_250\" = PERIOD \"CLK_250\" TS_SYSCLK*1 HIGH 50 % PRIORITY 2;"
	    	puts $outputFile "TIMESPEC \"TS_CLK_USERCLK\" = PERIOD \"CLK_USERCLK\" TS_SYSCLK*0.5 HIGH 50 %;"
	    	puts $outputFile "TIMESPEC \"TS_CLK_USERCLK2\" = PERIOD \"CLK_USERCLK2\" TS_SYSCLK*0.5 HIGH 50 %;"
           } else {
		puts $outputFile "TIMESPEC \"TS_CLK_125\" = PERIOD \"CLK_125\" TS_SYSCLK*1.25 HIGH 50 % PRIORITY 1 ;"
	    	puts $outputFile "TIMESPEC \"TS_CLK_250\" = PERIOD \"CLK_250\" TS_SYSCLK*2.5 HIGH 50 % PRIORITY 2;"
	    	puts $outputFile "TIMESPEC \"TS_CLK_USERCLK\" = PERIOD \"CLK_USERCLK\" TS_SYSCLK*1.25 HIGH 50 %;"
	    	puts $outputFile "TIMESPEC \"TS_CLK_USERCLK2\" = PERIOD \"CLK_USERCLK2\" TS_SYSCLK*1.25 HIGH 50 %;"
	   }
        } else {
            puts $outputFile "# AXI PCIe UCF: Gen2 Constraints"
	    if { $ref_clk == 2 } {
		puts $outputFile "TIMESPEC \"TS_CLK_125\"  = PERIOD \"CLK_125\" TS_SYSCLK*0.5 HIGH 50 % PRIORITY 2 ;"
	    	puts $outputFile "TIMESPEC \"TS_CLK_250\" = PERIOD \"CLK_250\" TS_SYSCLK*1 HIGH 50 % PRIORITY 1;"
	    	puts $outputFile "TIMESPEC \"TS_CLK_USERCLK\" = PERIOD \"CLK_USERCLK\" TS_SYSCLK*1 HIGH 50 %;"
	    	puts $outputFile "TIMESPEC \"TS_CLK_USERCLK2\" = PERIOD \"CLK_USERCLK2\" TS_SYSCLK*0.5 HIGH 50 %;"
	    } else {
		puts $outputFile "TIMESPEC \"TS_CLK_125\"  = PERIOD \"CLK_125\" TS_SYSCLK*1.25 HIGH 50 % PRIORITY 2 ;"
	    	puts $outputFile "TIMESPEC \"TS_CLK_250\" = PERIOD \"CLK_250\" TS_SYSCLK*2.5 HIGH 50 % PRIORITY 1;"
	    	puts $outputFile "TIMESPEC \"TS_CLK_USERCLK\" = PERIOD \"CLK_USERCLK\" TS_SYSCLK*2.5 HIGH 50 %;"
	    	puts $outputFile "TIMESPEC \"TS_CLK_USERCLK2\" = PERIOD \"CLK_USERCLK2\" TS_SYSCLK*1.25 HIGH 50 %;"
	    }
        }
        
	puts $outputFile "\n"
	puts $outputFile "# AXI PCIe UCF: Timing Ignore Constraints"
	
	puts $outputFile "PIN \"*pipe_clock_i/mmcm_i.RST\" TIG;"
	puts $outputFile "NET \"*pipe_clock_i/pclk_sel\" TIG;"
	# puts $outputFile "NET \"*pipe_clock_i/clk_125mhz\" TIG;"

	puts $outputFile "\n"
	puts $outputFile "NET \"*pcie_7x*/*gt_top_i/pipe_wrapper_i/*user_resetdone*\" TIG;"
	puts $outputFile "NET \"*pcie_7x*/*gt_top_i/pipe_wrapper_i/*pipe_reset_i/*cpllreset\" TIG;"
	puts $outputFile "NET \"*pcie_7x*/*gt_top_i/pipe_wrapper_i/pipe_lane\[*\]*pipe_rate_i/*\" TIG;"
	puts $outputFile "\n"
	
	puts $outputFile "NET \"*/sig_blk_dcontrol<12>\" TIG;"
	puts $outputFile "NET \"*/sig_blk_dcontrol<13>\" TIG;"
	puts $outputFile "NET \"*/sig_blk_dcontrol<14>\" TIG;"
	

  
        
    # Virtex-6
    } elseif { [xstrncmp $family "virtex6"] } {
    
    	puts $outputFile "# AXI PCIe UCF: Base family is Virtex-6"
    	puts $outputFile "# Please use Base System Builder in EDK to generate core constraints."
    
    
    
    # Spartan-6
    } elseif { [xstrncmp $family "spartan6"] } {

    	puts $outputFile "# AXI PCIe UCF: Base family is Spartan-6"
    	puts $outputFile "# Please use Base System Builder in EDK to generate core constraints."


    } else {
    
    	puts $outputFile "# AXI PCIe UCF: Unsupported C_FAMILY"
    
    }
    
    puts $outputFile "\n"
    puts $outputFile "\n"
    puts $outputFile "# AXI PCIe UCF: End of Constraints"
    puts $outputFile "\n"

    # Close the file
    close $outputFile
}


#***--------------------------------***-----------------------------------***
#
#     			 GENERATE_CORELEVEL_XDC
#
#***--------------------------------***-----------------------------------***


# Generate core level XDC constraints for use with 
# 2012.2 Xilinx and later Vivado releases.

proc generate_corelevel_xdc {mhsinst} {


    # Open XDC file for writing
    set  filePath [xget_ncf_dir $mhsinst]
    file mkdir $filePath
    
    # Specify file name
    set instname [xget_hw_parameter_value $mhsinst "INSTANCE"]
    set name_lower [string tolower $instname]
    set fileName $name_lower
    # (no _wrapper in file name) append fileName "_wrapper.xdc"
    append fileName ".xdc"
    append filePath $fileName
    
    file delete -force ${filePath}
    set outputFile [open $filePath "w"]
    

    # Create local variables
    set family [xget_hw_parameter_value $mhsinst "C_FAMILY"]
    set mhs_family $family
    set max_lnk_spd_int [xget_hw_parameter_value $mhsinst "C_MAX_LINK_SPEED"]
    set max_lnk_wdt_int [xget_hw_parameter_value $mhsinst "C_NO_OF_LANES"]
    set is_rc [xget_hw_parameter_value $mhsinst "C_INCLUDE_RC"]
    set ref_clk [xget_hw_parameter_value $mhsinst "C_REF_CLK_FREQ"]
    set gt_use_mode [xget_hw_parameter_value $mhsinst "C_PCIE_USE_MODE"]

    set ref_clk_sig [xget_hw_port_value $mhsinst "REFCLK"]
    


     # Set derivative C_FAMILY

     # Virtex-6
     if { [string compare -nocase "virtex6" $family] == 0 } {
     	set family "virtex6"

     # Virtex-6L
     } elseif { [string compare -nocase "virtex6l" $family] == 0 } {
     	set family "virtex6"
     
     # QVirtex-6
     } elseif { [string compare -nocase "qvirtex6" $family] == 0 } {
     	set family "virtex6"
     	
     # Spartan-6L
     } elseif { [string compare -nocase "spartan6l" $family] == 0 } {
     	set family "spartan6"

     # QSpartan-6
     } elseif { [string compare -nocase "qspartan6" $family] == 0 } {
     	set family "spartan6"
     
     # Kintex-7
     } elseif { [string compare -nocase "kintex7" $family] == 0 } {
     	set family "7series"

     # Kintex-7L
     } elseif { [string compare -nocase "kintex7l" $family] == 0 } {
     	set family "7series"

     # Virtex-7
     } elseif { [string compare -nocase "virtex7" $family] == 0 } {
     	set family "7series"
     
     # Virtex-7L
     } elseif { [string compare -nocase "virtex7l" $family] == 0 } {
     	set family "7series"

     # Artix-7
     } elseif { [string compare -nocase "artix7" $family] == 0 } {
     	set family "7series"

     # Zynq
     } elseif { [string compare -nocase "zynq" $family] == 0 } {
     	set family "7series"
     }


     #---------------------------------- 
     # Set up the design path variables  
     #---------------------------------- 
     set ip_path "U0"
     set design_path "comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v1_9_inst"
     set pcie_path "pcie_top_i/pcie_7x_i"
     set bram_path "pcie_top_i/pcie_7x_i/pcie_bram_top"
     set ramb_path_xdc "use_tdp.ramb36/genblk*.bram36_tdp_bl.bram36_tdp_bl"
     set gt_path ""
     if {$gt_use_mode == 1.0 || $gt_use_mode == 1.1} {
       set gt_path "gt_ies.gt_top_i"
     } else {
       set gt_path "gt_ges.gt_top_i"
     }


     #----------------------------------- 
     # Set up link width/speed variables  
     #----------------------------------- 
     set x1g1 [expr {(false)?true:false}] 
     set x1g2 [expr {(false)?true:false}] 
     set x2g1 [expr {(false)?true:false}]  
     set x2g2 [expr {(false)?true:false}]  
     set x4g1 [expr {(false)?true:false}]  
     set x4g2 [expr {(false)?true:false}]  
     set x8g1 [expr {(false)?true:false}]  
     if {$max_lnk_wdt_int == 8} {  
     set x8g1 [expr {(true)?true:false}]  
     } 
     if {$max_lnk_wdt_int == 4} {  
     if {$max_lnk_spd_int == 1} {  
       set x4g2 [expr {(true)?true:false}]  
     } else { 
     set x4g1 [expr {(true)?true:false}]  
     } 
     } 
     if {$max_lnk_wdt_int == 2} {  
     if {$max_lnk_spd_int == 1} {  
       set x2g2 [expr {(true)?true:false}]  
     } else { 
       set x2g1 [expr {(true)?true:false}]  
     } 
     } 
     if {$max_lnk_wdt_int == 1} {  
     if {$max_lnk_spd_int == 1} {  
      set x1g2 [expr {(true)?true:false}]  
     } else { 
      set x1g1 [expr {(true)?true:false}]  
     } 
     } 
		
    puts $outputFile "\n"
    puts $outputFile "# AXI PCIe XDC: Timing Constraints ONLY"
    puts $outputFile "\n"

    # Kintex-7
    if { [xstrncmp $family "7series"] } {
    
    	if { [xstrncmp $mhs_family "zynq"] } {
    		puts $outputFile "# AXI PCIe XDC: Base family is Zynq"
    	} else {
    		puts $outputFile "# AXI PCIe XDC: Base family is 7-Series"
    	}
    	puts $outputFile "\n"

	   if { $ref_clk == 0 } {
    		puts $outputFile "# AXI PCIe XDC: Reference Clock is 100 MHz"
         puts $outputFile "create_clock -name txoutclk -period 10  \[get_pins ${design_path}/${gt_path}/pipe_wrapper_i/pipe_lane\[0\].gt_wrapper_i/gtx_channel.gtxe2_channel_i/TXOUTCLK\]"	
	   } elseif { $ref_clk == 1 } {
    		puts $outputFile "# AXI PCIe XDC: Reference Clock is 125 MHz"
    		puts $outputFile "# AXI PCIe XDC: Not supported C_REF_CLK_FREQ for 7-Series"
	
	   } elseif { $ref_clk == 2 } {
    		puts $outputFile "# AXI PCIe XDC: Reference Clock is 250 MHz"
         puts $outputFile "create_clock -name txoutclk -period 4  \[get_pins ${design_path}/${gt_path}/pipe_wrapper_i/pipe_lane\[0\].gt_wrapper_i/gtx_channel.gtxe2_channel_i/TXOUTCLK\]"	
    	}

        #Set a false path through the select line of the BUFGMUX. :>
        puts $outputFile "set_false_path -to \[get_pins {${design_path}/${gt_path}/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S*}\]"

        if {$x1g1 || $x2g1 || $x4g1 || $x8g1} { 
        puts $outputFile "set_case_analysis 1 \[get_pins {${design_path}/${gt_path}/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S0}\]"
        puts $outputFile "set_case_analysis 0 \[get_pins {${design_path}/${gt_path}/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S1}\]"
        } else { 
        puts $outputFile "#The following constraints are used to constrain the output of the BUFGMUX."
        puts $outputFile "#This constraint is set for 250MHz because when the PCIe core is operating in Gen2"
        puts $outputFile "#mode, the 250MHz clock is selected.  Without these constraints, it is possible that"
        puts $outputFile "#static timing analysis could anayze the design using the 125MHz clock instead of the"
        puts $outputFile "#250MHz clock."
        puts $outputFile "create_generated_clock -name clk_125mhz_mux \
                        -source \[get_pins ${design_path}/${gt_path}/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I0\] \
                        -divide_by 1 \
                        \[get_pins ${design_path}/${gt_path}/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/O\]"

        puts $outputFile "create_generated_clock -name clk_250mhz_mux \
                        -source \
                        \[get_pins ${design_path}/${gt_path}/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1\] \
                        -divide_by 1 -add \
                        -master_clock \
                        \[get_clocks -of \[get_pins ${design_path}/${gt_path}/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/I1\]\] \
                        \[get_pins ${design_path}/${gt_path}/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/O\]"

        puts $outputFile "set_clock_groups -name pcieclkmux -physically_exclusive -group clk_125mhz_mux -group clk_250mhz_mux"

        } 
  
        
    # Virtex-6
    } elseif { [xstrncmp $family "virtex6"] } {
    
    	puts $outputFile "# AXI PCIe XDC: Base family is Virtex-6"
    	puts $outputFile "# Please use Base System Builder in EDK to generate core constraints."
    
    
    
    # Spartan-6
    } elseif { [xstrncmp $family "spartan6"] } {

    	puts $outputFile "# AXI PCIe XDC: Base family is Spartan-6"
    	puts $outputFile "# Please use Base System Builder in EDK to generate core constraints."


    } else {
    
    	puts $outputFile "# AXI PCIe XDC: Unsupported C_FAMILY"
    
    }
    
    puts $outputFile "\n"
    puts $outputFile "\n"
    puts $outputFile "# AXI PCIe XDC: End of Constraints"
    puts $outputFile "\n"


    close $outputFile
}


