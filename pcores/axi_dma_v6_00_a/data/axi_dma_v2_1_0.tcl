############################################################################
## DISCLAIMER OF LIABILITY
##
## (c) Copyright 2010,2011 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
###############################################################################
##
## Name     : axi_dma_v2_1_0.tcl
## Desc     : USF TCL File
##
###############################################################################


proc platgen_update  {mhsinst} {
    generate_corelevel_ucf $mhsinst
    generate_corelevel_xdc $mhsinst
}

proc generate_corelevel_ucf {mhsinst} {
    set filePath [xget_ncf_dir $mhsinst]
    file mkdir $filePath

    # specify file name
    set    instname   [xget_hw_parameter_value $mhsinst "INSTANCE"]
    set    name_lower [string   tolower   $instname]

    set    fileName   $name_lower
    append fileName   "_wrapper.ucf"
    append filePath   $fileName

    # Open a file for writing
    set outputFile [open $filePath "w"]

    set prmry_is_async [xget_hw_parameter_value $mhsinst "C_PRMRY_IS_ACLK_ASYNC"]    
    set include_sg [xget_hw_parameter_value $mhsinst "C_INCLUDE_SG"]
    set include_mm2s [xget_hw_parameter_value $mhsinst "C_INCLUDE_MM2S"]
    set include_s2mm [xget_hw_parameter_value $mhsinst "C_INCLUDE_S2MM"]
   
    set lite_aclk_freq [xget_hw_parameter_value $mhsinst "C_S_AXI_LITE_ACLK_FREQ_HZ"]    
    set lite_aclk_period_ps [expr 1000000000000 / $lite_aclk_freq]

    set sg_aclk_freq [xget_hw_parameter_value $mhsinst "C_M_AXI_SG_ACLK_FREQ_HZ"]    
    set sg_aclk_period_ps [expr 1000000000000 / $sg_aclk_freq]

    set mm2s_aclk_freq [xget_hw_parameter_value $mhsinst "C_M_AXI_MM2S_ACLK_FREQ_HZ"]    
    set mm2s_aclk_period_ps [expr 1000000000000 / $mm2s_aclk_freq]

    set s2mm_aclk_freq [xget_hw_parameter_value $mhsinst "C_M_AXI_S2MM_ACLK_FREQ_HZ"]    
    set s2mm_aclk_period_ps [expr 1000000000000 / $s2mm_aclk_freq]

    ## Create datapath only constraints depending on async or sync mode  
    if { $prmry_is_async == 0} {
   	puts $outputFile "## INFO: No clock crossing in ${instname}"
    } else {
        puts $outputFile "## INFO: CDC Crossing in ${instname} between clocks"
        puts $outputFile "INST \"${instname}/*cdc_from*\" TNM = FFS \"TNM_${instname}_clock_one\";"
        puts $outputFile "INST \"${instname}/*cdc_to*\" TNM = FFS \"TNM_${instname}_clock_other\";"
        puts $outputFile "TIMESPEC TS_${instname}_clock_cross = FROM \"TNM_${instname}_clock_one\" TO \"TNM_${instname}_clock_other\" TIG;"
 
##    	if { $include_sg == 0} {
##        	puts $outputFile "NET \"s_axi_lite_aclk\" TNM_NET = \"s_axi_lite_aclk\";"
##
##		if {$include_mm2s == 1} {
##	        	puts $outputFile "NET \"m_axi_mm2s_aclk\" TNM_NET = \"m_axi_mm2s_aclk\";"
##	        	puts $outputFile "TIMESPEC TS_${instname}_MM2S_AXIS_S2P = FROM \"s_axi_lite_aclk\" TO \"m_axi_mm2s_aclk\" ${mm2s_aclk_period_ps} PS DATAPATHONLY;"
##			puts $outputFile "TIMESPEC TS_${instname}_MM2S_AXIS_P2S = FROM \"m_axi_mm2s_aclk\" TO \"s_axi_lite_aclk\" ${lite_aclk_period_ps} PS DATAPATHONLY;"
##		}
##		if {$include_s2mm == 1} {
##	        	puts $outputFile "NET \"m_axi_s2mm_aclk\" TNM_NET = \"m_axi_s2mm_aclk\";"
##			puts $outputFile "TIMESPEC TS_${instname}_S2MM_AXIS_S2P = FROM \"s_axi_lite_aclk\" TO \"m_axi_s2mm_aclk\" ${s2mm_aclk_period_ps} PS DATAPATHONLY;"
##			puts $outputFile "TIMESPEC TS_${instname}_S2MM_AXIS_P2S = FROM \"m_axi_s2mm_aclk\" TO \"s_axi_lite_aclk\" ${lite_aclk_period_ps} PS DATAPATHONLY;"
##		}
##        } else {
##        	puts $outputFile "NET \"s_axi_lite_aclk\" TNM_NET = \"s_axi_lite_aclk\";"
##        	puts $outputFile "NET \"m_axi_sg_aclk\" TNM_NET = \"m_axi_sg_aclk\";"
##        	puts $outputFile "TIMESPEC TS_${instname}_LITE_AXI_S2P = FROM \"s_axi_lite_aclk\" TO \"m_axi_sg_aclk\" ${sg_aclk_period_ps} PS DATAPATHONLY;"
##        	puts $outputFile "TIMESPEC TS_${instname}_LITE_AXI_P2S = FROM \"m_axi_sg_aclk\" TO \"s_axi_lite_aclk\" ${lite_aclk_period_ps} PS DATAPATHONLY;"
##
##		if {$include_mm2s == 1} {
##	        	puts $outputFile "NET \"m_axi_mm2s_aclk\" TNM_NET = \"m_axi_mm2s_aclk\";"
##	        	puts $outputFile "TIMESPEC TS_${instname}_MM2S_AXIS_S2P = FROM \"m_axi_sg_aclk\" TO \"m_axi_mm2s_aclk\" ${mm2s_aclk_period_ps} PS DATAPATHONLY;"
##			puts $outputFile "TIMESPEC TS_${instname}_MM2S_AXIS_P2S = FROM \"m_axi_mm2s_aclk\" TO \"m_axi_sg_aclk\" ${sg_aclk_period_ps} PS DATAPATHONLY;"
##		}
##		if {$include_s2mm == 1} {
##	        	puts $outputFile "NET \"m_axi_s2mm_aclk\" TNM_NET = \"m_axi_s2mm_aclk\";"
##			puts $outputFile "TIMESPEC TS_${instname}_S2MM_AXIS_S2P = FROM \"m_axi_sg_aclk\" TO \"m_axi_s2mm_aclk\" ${s2mm_aclk_period_ps} PS DATAPATHONLY;"
##			puts $outputFile "TIMESPEC TS_${instname}_S2MM_AXIS_P2S = FROM \"m_axi_s2mm_aclk\" TO \"m_axi_sg_aclk\" ${sg_aclk_period_ps} PS DATAPATHONLY;"
##		}
####        }
    }
    puts $outputFile "#"
    puts $outputFile "#"
    puts $outputFile "\n"       

    # Close the file
    close $outputFile
}


proc generate_corelevel_xdc {mhsinst} {
    set filePath [xget_ncf_dir $mhsinst]
    file mkdir $filePath

    # specify file name
    set    instname   [xget_hw_parameter_value $mhsinst "INSTANCE"]
    set    name_lower [string   tolower   $instname]

    set    fileName   $name_lower
    append fileName   ".xdc"
    append filePath   $fileName

    # Open a file for writing
    set outputFile [open $filePath "w"]

    set prmry_is_async [xget_hw_parameter_value $mhsinst "C_PRMRY_IS_ACLK_ASYNC"]    
    set include_sg [xget_hw_parameter_value $mhsinst "C_INCLUDE_SG"]
    set include_mm2s [xget_hw_parameter_value $mhsinst "C_INCLUDE_MM2S"]
    set include_s2mm [xget_hw_parameter_value $mhsinst "C_INCLUDE_S2MM"]
   
    set lite_aclk_freq [xget_hw_parameter_value $mhsinst "C_S_AXI_LITE_ACLK_FREQ_HZ"]    
    set lite_aclk_period_ps [expr 1000000000000 / $lite_aclk_freq]

    set sg_aclk_freq [xget_hw_parameter_value $mhsinst "C_M_AXI_SG_ACLK_FREQ_HZ"]    
    set sg_aclk_period_ps [expr 1000000000000 / $sg_aclk_freq]

    set mm2s_aclk_freq [xget_hw_parameter_value $mhsinst "C_M_AXI_MM2S_ACLK_FREQ_HZ"]    
    set mm2s_aclk_period_ps [expr 1000000000000 / $mm2s_aclk_freq]

    set s2mm_aclk_freq [xget_hw_parameter_value $mhsinst "C_M_AXI_S2MM_ACLK_FREQ_HZ"]    
    set s2mm_aclk_period_ps [expr 1000000000000 / $s2mm_aclk_freq]

    ## Create datapath only constraints depending on async or sync mode  
    if { $prmry_is_async == 0} {
   	puts $outputFile "## INFO: No clock crossing in ${instname}"
    } else {
        puts $outputFile "## INFO: CDC Crossing between clocks"
        puts $outputFile "set_false_path -from \[get_cells -hier -regexp {.*cdc_from.*}] -to \[get_cells  -hier -regexp {.*cdc_to.*}]"
 
##    	if { $include_sg == 0} {
##        	puts $outputFile "NET \"s_axi_lite_aclk\" TNM_NET = \"s_axi_lite_aclk\";"
##
##		if {$include_mm2s == 1} {
##	        	puts $outputFile "NET \"m_axi_mm2s_aclk\" TNM_NET = \"m_axi_mm2s_aclk\";"
##	        	puts $outputFile "TIMESPEC TS_${instname}_MM2S_AXIS_S2P = FROM \"s_axi_lite_aclk\" TO \"m_axi_mm2s_aclk\" ${mm2s_aclk_period_ps} PS DATAPATHONLY;"
##			puts $outputFile "TIMESPEC TS_${instname}_MM2S_AXIS_P2S = FROM \"m_axi_mm2s_aclk\" TO \"s_axi_lite_aclk\" ${lite_aclk_period_ps} PS DATAPATHONLY;"
##		}
##		if {$include_s2mm == 1} {
##	        	puts $outputFile "NET \"m_axi_s2mm_aclk\" TNM_NET = \"m_axi_s2mm_aclk\";"
##			puts $outputFile "TIMESPEC TS_${instname}_S2MM_AXIS_S2P = FROM \"s_axi_lite_aclk\" TO \"m_axi_s2mm_aclk\" ${s2mm_aclk_period_ps} PS DATAPATHONLY;"
##			puts $outputFile "TIMESPEC TS_${instname}_S2MM_AXIS_P2S = FROM \"m_axi_s2mm_aclk\" TO \"s_axi_lite_aclk\" ${lite_aclk_period_ps} PS DATAPATHONLY;"
##		}
##        } else {
##        	puts $outputFile "NET \"s_axi_lite_aclk\" TNM_NET = \"s_axi_lite_aclk\";"
##        	puts $outputFile "NET \"m_axi_sg_aclk\" TNM_NET = \"m_axi_sg_aclk\";"
##        	puts $outputFile "TIMESPEC TS_${instname}_LITE_AXI_S2P = FROM \"s_axi_lite_aclk\" TO \"m_axi_sg_aclk\" ${sg_aclk_period_ps} PS DATAPATHONLY;"
##        	puts $outputFile "TIMESPEC TS_${instname}_LITE_AXI_P2S = FROM \"m_axi_sg_aclk\" TO \"s_axi_lite_aclk\" ${lite_aclk_period_ps} PS DATAPATHONLY;"
##
##		if {$include_mm2s == 1} {
##	        	puts $outputFile "NET \"m_axi_mm2s_aclk\" TNM_NET = \"m_axi_mm2s_aclk\";"
##	        	puts $outputFile "TIMESPEC TS_${instname}_MM2S_AXIS_S2P = FROM \"m_axi_sg_aclk\" TO \"m_axi_mm2s_aclk\" ${mm2s_aclk_period_ps} PS DATAPATHONLY;"
##			puts $outputFile "TIMESPEC TS_${instname}_MM2S_AXIS_P2S = FROM \"m_axi_mm2s_aclk\" TO \"m_axi_sg_aclk\" ${sg_aclk_period_ps} PS DATAPATHONLY;"
##		}
##		if {$include_s2mm == 1} {
##	        	puts $outputFile "NET \"m_axi_s2mm_aclk\" TNM_NET = \"m_axi_s2mm_aclk\";"
##			puts $outputFile "TIMESPEC TS_${instname}_S2MM_AXIS_S2P = FROM \"m_axi_sg_aclk\" TO \"m_axi_s2mm_aclk\" ${s2mm_aclk_period_ps} PS DATAPATHONLY;"
##			puts $outputFile "TIMESPEC TS_${instname}_S2MM_AXIS_P2S = FROM \"m_axi_s2mm_aclk\" TO \"m_axi_sg_aclk\" ${sg_aclk_period_ps} PS DATAPATHONLY;"
##		}
####        }
    }
    puts $outputFile "#"
    puts $outputFile "#"
    puts $outputFile "\n"       

    # Close the file
    close $outputFile
}

#***--------------------------------***-----------------------------------***
#
#			     IPLEVEL_UPDATE_PROC
#
#***--------------------------------***-----------------------------------***
## This procedure sets the mm2s issuing based on burst size parameter
proc iplevel_update_mm2s_issuing {param_handle} {
  set mhsinst [xget_hw_parent_handle $param_handle]
  set burst_size [xget_hw_parameter_value $mhsinst "C_MM2S_BURST_SIZE"]
  set sf_included [xget_hw_parameter_value $mhsinst "C_INCLUDE_MM2S_SF"]

  if {$sf_included == 0} {
	  if {$burst_size == 16} {
	    return 4
	  } elseif {$burst_size == 32} {
	    return 4
	  } elseif {$burst_size == 64} {
	    return 4
	  } elseif {$burst_size == 128} {
	    return 2
	  } else {
	    return 1
	  }
   } else {
     return 4
   }
}

## This procedure sets the s2mm issuing based on burst size parameter
proc iplevel_update_s2mm_issuing {param_handle} {
  set mhsinst [xget_hw_parent_handle $param_handle]
  set burst_size [xget_hw_parameter_value $mhsinst "C_S2MM_BURST_SIZE"]
  set sf_included [xget_hw_parameter_value $mhsinst "C_INCLUDE_S2MM_SF"]

  if {$sf_included == 0} {
	  if {$burst_size == 16} {
	    return 4
	  } elseif {$burst_size == 32} {
	    return 4
	  } elseif {$burst_size == 64} {
	    return 4
	  } elseif {$burst_size == 128} {
	    return 2
	  } else {
	    return 1
	  }
   } else {
     return 4
   }
}

proc iplevel_update_protocol {param_handle} {
  set mhsinst [xget_hw_parent_handle $param_handle]
  set generic_size [xget_hw_parameter_value $mhsinst "C_GENERIC"]

  if {$generic_size == 1} {
     return "GENERIC"      
   } else {
     return "XIL_AXI_STREAM_ETH_DATA"
   }
}

## This procedure sets the mm2s fifo depth to 512 if store and forward is turned off.
## users can overide this by explicitly setting fifo depth in the system.mhs
proc iplevel_update_mm2s_fifo_depth {param_handle} {
  set mhsinst [xget_hw_parent_handle $param_handle]
  set sf_included [xget_hw_parameter_value $mhsinst "C_INCLUDE_MM2S_SF"]
  if {$sf_included == 0} {
      return 512
  } else {
      return 0
  }
}
## This procedure sets the s2mm fifo depth to 512 if store and forward is turned off.
## users can overide this by explicitly setting fifo depth in the system.mhs
proc iplevel_update_s2mm_fifo_depth {param_handle} {
  set mhsinst [xget_hw_parent_handle $param_handle]
  set sf_included [xget_hw_parameter_value $mhsinst "C_INCLUDE_S2MM_SF"]
  if {$sf_included == 0} {
      return 512
  } else {
      return 0
  }
}
## This procedure sets the mm2s stream data width equal to the memory data width
##proc iplevel_update_mm2s_tdata_width { param_handle } {
##  set mhsinst [xget_hw_parent_handle $param_handle]
##  set strm_width [xget_hw_parameter_value $mhsinst "C_M_AXI_MM2S_DATA_WIDTH"]
##  return $strm_width
##}
##
#### This procedure sets the s2mm stream data width equal to the memory data width
##proc iplevel_update_s2mm_tdata_width { param_handle } {
##  set mhsinst [xget_hw_parent_handle $param_handle]
##  set strm_width [xget_hw_parameter_value $mhsinst "C_M_AXI_S2MM_DATA_WIDTH"]
##  return $strm_width
##}

## This procedure sets the C_PRMRY_IS_ACLK_ASYNC parameter
proc iplevel_update_prmry_is_async { param_handle } {
    # Get mhs instance
    set mhsinst [xget_hw_parent_handle $param_handle]

    # Get signal connected to the following clock ports
    set lite_clk [xget_hw_port_value   $mhsinst "s_axi_lite_aclk"]
    set sg_clk [xget_hw_port_value   $mhsinst "m_axi_sg_aclk"]
    set mm2s_clk [xget_hw_port_value   $mhsinst "m_axi_mm2s_aclk"]
    set s2mm_clk [xget_hw_port_value   $mhsinst "m_axi_s2mm_aclk"]
    
    set include_sg [xget_hw_parameter_value $mhsinst "C_INCLUDE_SG"]
    set include_mm2s [xget_hw_parameter_value $mhsinst "C_INCLUDE_MM2S"]
    set include_s2mm [xget_hw_parameter_value $mhsinst "C_INCLUDE_S2MM"]



    ## If the same clock is connected to s_axi_lite_aclk, m_axi_sg_aclk, m_axi_mm2s_aclk, and m_axi_s2mm_aclk then set C_PRMRY_IS_ACLK_ASYNC = 0
    ## Otherwise set C_PRMRY_IS_ACLK_ASYNC = 1
    ## Note: comparisons depend on inclusion or exclusion of sg engine, mm2s channel, and s2mm channel
    if {$include_sg == 1} {
    	if {$include_mm2s == 1} {
    		if {$include_s2mm == 1} {
		    if {[string compare -nocase $lite_clk $sg_clk] == 0 && [string compare -nocase $lite_clk $mm2s_clk] == 0 && [string compare -nocase $lite_clk $s2mm_clk] == 0} {
			return 0
		    } else {
			return 1
		    }
		} else {
		    if {[string compare -nocase $lite_clk $sg_clk] == 0 && [string compare -nocase $lite_clk $mm2s_clk] == 0} {
			return 0
		    } else {
			return 1
		    }
		}
	} else {
	    if {[string compare -nocase $lite_clk $sg_clk] == 0 && [string compare -nocase $lite_clk $s2mm_clk] == 0} {
		return 0
	    } else {
		return 1
	    }
	}
    } else {
    	if {$include_mm2s == 1} {
    		if {$include_s2mm == 1} {
		    if {[string compare -nocase $lite_clk $mm2s_clk] == 0 && [string compare -nocase $lite_clk $s2mm_clk] == 0} {
			return 0
		    } else {
			return 1
		    }
		} else {
		    if {[string compare -nocase $lite_clk $mm2s_clk] == 0} {
			return 0
		    } else {
			return 1
		    }
		}
	} else {
	    if {[string compare -nocase $lite_clk $s2mm_clk] == 0} {
		return 0
	    } else {
		return 1
	    }
	}
    }
}
proc iplevel_drc_mm2s_tdata_width {param_handle} {

  set mhsinst [xget_hw_parent_handle $param_handle]
  set data_width [xget_hw_parameter_value $mhsinst "C_M_AXI_MM2S_DATA_WIDTH"]
  set tdata_width [xget_hw_parameter_value $mhsinst "C_M_AXIS_MM2S_TDATA_WIDTH"]

  if {$tdata_width > $data_width} {
	error "\n Stream Data Width should be less than or equal to Memory Map Data Width.\n" 
  }
}


proc iplevel_drc_s2mm_tdata_width {param_handle} {

  set mhsinst [xget_hw_parent_handle $param_handle]
  set data_width [xget_hw_parameter_value $mhsinst "C_M_AXI_S2MM_DATA_WIDTH"]
  set tdata_width [xget_hw_parameter_value $mhsinst "C_S_AXIS_S2MM_TDATA_WIDTH"]

  if {$tdata_width > $data_width} {
	error "\n Stream Data Width should be less than or equal to Memory Map Data Width.\n" 
  }
}

proc iplevel_drc_mm2s_dre {param_handle} {

  set mhsinst [xget_hw_parent_handle $param_handle]
  set dre_value [xget_hw_parameter_value $mhsinst "C_INCLUDE_MM2S_DRE"]
  set tdata_width [xget_hw_parameter_value $mhsinst "C_M_AXIS_MM2S_TDATA_WIDTH"]

  if { $dre_value == 1 && $tdata_width > 64 } {
      error "\n DRE is available only when Stream data width is 64 and less\n" 
  } 
}

proc iplevel_drc_s2mm_dre {param_handle} {

  set mhsinst [xget_hw_parent_handle $param_handle]
  set dre_value [xget_hw_parameter_value $mhsinst "C_INCLUDE_S2MM_DRE"]
  set tdata_width [xget_hw_parameter_value $mhsinst "C_S_AXIS_S2MM_TDATA_WIDTH"]

  if { $dre_value == 1 && $tdata_width > 64 } {
      error "\n DRE is available only when Stream data width is 64 and less\n" 
  } 

}

proc iplevel_drc_s2mm_channels { param_handle } {
    # Get mhs instance
    set mhsinst [xget_hw_parent_handle $param_handle]
    set cache_value [xget_hw_parameter_value $mhsinst "C_ENABLE_MULTI_CHANNEL"] 
    set s2mm_ch [xget_hw_parameter_value $mhsinst "C_NUM_S2MM_CHANNELS"] 

    if {$cache_value == 0 && $s2mm_ch > 1} {
      error "\n Number of channels cannot be more than 1 if Cache is not enabled\n" 
    }

}

proc iplevel_drc_mm2s_channels { param_handle } {
    # Get mhs instance
    set mhsinst [xget_hw_parent_handle $param_handle]
    set cache_value [xget_hw_parameter_value $mhsinst "C_ENABLE_MULTI_CHANNEL"] 
    set mm2s_ch [xget_hw_parameter_value $mhsinst "C_NUM_MM2S_CHANNELS"] 

    if {$cache_value == 0 && $mm2s_ch > 1} {
      error "\n Number of channels cannot be more than 1 if Cache is not enabled\n" 
    }

}

proc iplevel_drc_stscntrl {param_handle} {
    set mhsinst [xget_hw_parent_handle $param_handle]
    set cache_value [xget_hw_parameter_value $mhsinst "C_ENABLE_MULTI_CHANNEL"] 
    set stscntrl [xget_hw_parameter_value $mhsinst "C_SG_INCLUDE_STSCNTRL_STRM"] 
    
    if {$cache_value == 1 && $stscntrl == 1} {
      error "\n Cannot enable the StsCntrl stream in multi channel mode\n" 
    }

}

proc iplevel_drc_queue {param_handle} {
    set mhsinst [xget_hw_parent_handle $param_handle]
    set cache_value [xget_hw_parameter_value $mhsinst "C_ENABLE_MULTI_CHANNEL"] 
    set queue [xget_hw_parameter_value $mhsinst "C_SG_INCLUDE_DESC_QUEUE"] 
    
    if {$cache_value == 1 && $queue == 1} {
      error "\n Cannot enable the Descriptor queue in multi channel mode\n" 
    }
}


proc iplevel_drc_stsapp {param_handle} {
    set mhsinst [xget_hw_parent_handle $param_handle]
    set cache_value [xget_hw_parameter_value $mhsinst "C_ENABLE_MULTI_CHANNEL"] 
    set stsapp [xget_hw_parameter_value $mhsinst "C_SG_USE_STSAPP_LENGTH"] 
    
    if {$cache_value == 1 && $stsapp == 1} {
      error "\n Cannot enable the StsCntrl App stream in multi channel mode\n" 
    }
}
