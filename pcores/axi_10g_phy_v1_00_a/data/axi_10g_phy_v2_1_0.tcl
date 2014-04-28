####
#
#

xload_xilinx_library libmXMLTclIf

proc generate_xgcore_ucf {instname idx outputFile} {
	puts $outputFile "#"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?TXWORD?TxMGTData_o*\"    TNM=FFS \"${instname}_${idx}_TxMGTData\";"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?TXWORD?TxMGTWordIsK_o*\" TNM=FFS \"${instname}_${idx}_TxMGTDataIsK\";"
	puts $outputFile "TIMESPEC \"TS_${idx}_TXregs1_to_${instname}\" = FROM \"${instname}_${idx}_TxMGTData\"    TO \"${instname}_gtx_dual_i\" 4000 ps;"
	puts $outputFile "TIMESPEC \"TS_${idx}_TXregs2_to_${instname}\" = FROM \"${instname}_${idx}_TxMGTDataIsK\" TO \"${instname}_gtx_dual_i\" 4000 ps;"

	puts $outputFile "#"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?NRxData*\"     TNM=FFS \"${instname}_${idx}_NRxData\";"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?NRxParity*\"   TNM=FFS \"${instname}_${idx}_NRxParity\";"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?NRxWordIsK*\"  TNM=FFS \"${instname}_${idx}_NRxWordIsK\";"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?NLinkStatus\"  TNM=FFS \"${instname}_${idx}_NLinkStatus\";"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?NLOS\"         TNM=FFS \"${instname}_${idx}_NLOS\";"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?NCRCError\"    TNM=FFS \"${instname}_${idx}_NCRCError\";"
	
	puts $outputFile "#"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?IntData*\"     TNM=FFS \"${instname}_${idx}_IntData\";"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?IntParity*\"   TNM=FFS \"${instname}_${idx}_IntParity\";"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?IntWordIsK*\"  TNM=FFS \"${instname}_${idx}_IntWordIsK\";"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?IntLS\"        TNM=FFS \"${instname}_${idx}_IntLS\";"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?IntLOS\"       TNM=FFS \"${instname}_${idx}_IntLOS\";"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?IntCRCError\"  TNM=FFS \"${instname}_${idx}_IntCRCError\";"
	
	puts $outputFile "#"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?RxState*\"     TNM=FFS \"${instname}_${idx}_rxstate_addr\";"
	
	puts $outputFile "#"
	puts $outputFile "TIMESPEC \"TS_${idx}_rxstate_to_${instname}_intdata\"    = FROM \"${instname}_${idx}_rxstate_addr\" TO \"${instname}_${idx}_IntData\"     2000 ps;"
	puts $outputFile "TIMESPEC \"TS_${idx}_rxstate_to_${instname}_intparity\"  = FROM \"${instname}_${idx}_rxstate_addr\" TO \"${instname}_${idx}_IntParity\"   2000 ps;"
	puts $outputFile "TIMESPEC \"TS_${idx}_rxstate_to_${instname}_intwordisk\" = FROM \"${instname}_${idx}_rxstate_addr\" TO \"${instname}_${idx}_IntWordIsK\"  2000 ps;"
	puts $outputFile "TIMESPEC \"TS_${idx}_rxstate_to_${instname}_intls\"      = FROM \"${instname}_${idx}_rxstate_addr\" TO \"${instname}_${idx}_IntLS\"       2000 ps;"
	puts $outputFile "TIMESPEC \"TS_${idx}_rxstate_to_${instname}_intlos\"     = FROM \"${instname}_${idx}_rxstate_addr\" TO \"${instname}_${idx}_IntLOS\"      2000 ps;"
	puts $outputFile "TIMESPEC \"TS_${idx}_rxstate_to_${instname}_intcrcerr\"  = FROM \"${instname}_${idx}_rxstate_addr\" TO \"${instname}_${idx}_IntCRCError\" 2000 ps;"
	
	puts $outputFile "#"
	puts $outputFile "TIMESPEC \"TS_${idx}_intdata_to_${instname}_nrxdata\"       = FROM \"${instname}_${idx}_IntData\"     TO \"${instname}_${idx}_NRxData\"     1000 ps;"
	puts $outputFile "TIMESPEC \"TS_${idx}_intparity_to_${instname}_nrxparity\"   = FROM \"${instname}_${idx}_IntParity\"   TO \"${instname}_${idx}_NRxParity\"   1000 ps;"
	puts $outputFile "TIMESPEC \"TS_${idx}_intwordisk_to_${instname}_nrxwordisk\" = FROM \"${instname}_${idx}_IntWordIsK\"  TO \"${instname}_${idx}_NRxWordIsK\"  1000 ps;"
	puts $outputFile "TIMESPEC \"TS_${idx}_intls_to_${instname}_nls\"             = FROM \"${instname}_${idx}_IntLS\"       TO \"${instname}_${idx}_NLinkStatus\" 1000 ps;"
	puts $outputFile "TIMESPEC \"TS_${idx}_intlos_to_${instname}_nlos\"           = FROM \"${instname}_${idx}_IntLOS\"      TO \"${instname}_${idx}_NLOS\"        1000 ps;"
	puts $outputFile "TIMESPEC \"TS_${idx}_intcrcerror_to_${instname}_ncrcerror\" = FROM \"${instname}_${idx}_IntCRCError\" TO \"${instname}_${idx}_NCRCError\" 1000 ps;"

	puts $outputFile "#"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?DataOutA*\"  TNM=FFS \"${instname}_${idx}_DataOutA\";"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?KOutA*\"     TNM=FFS \"${instname}_${idx}_KOutA\";"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?StatusA*\"   TNM=FFS \"${instname}_${idx}_StatusA\";"
	puts $outputFile "INST \"${instname}/*ty_core${idx}/*LINK?RXWORD?CommaOutA*\" TNM=FFS \"${instname}_${idx}_CommaOutA\";"
	
	puts $outputFile "#"
	puts $outputFile "TIMESPEC  \"TS_GT_to_${instname}_${idx}_RXregs1\" = FROM \"${instname}_gtx_dual_i\" TO \"${instname}_${idx}_DataOutA\"  4000 ps;"
	puts $outputFile "TIMESPEC  \"TS_GT_to_${instname}_${idx}_RXregs2\" = FROM \"${instname}_gtx_dual_i\" TO \"${instname}_${idx}_KOutA\"     4000 ps;"
	puts $outputFile "TIMESPEC  \"TS_GT_to_${instname}_${idx}_RXregs3\" = FROM \"${instname}_gtx_dual_i\" TO \"${instname}_${idx}_StatusA\"   4000 ps;"
	puts $outputFile "TIMESPEC  \"TS_GT_to_${instname}_${idx}_RXregs4\" = FROM \"${instname}_gtx_dual_i\" TO \"${instname}_${idx}_CommaOutA\" 4000 ps;"
}

proc generate_corelevel_ucf {mhsinst} {
	############################
	set  filePath [xget_ncf_dir $mhsinst]
	file mkdir    $filePath

	# specify file name
	set    instname   [xget_hw_parameter_value $mhsinst "INSTANCE"]
	set    ipname     [xget_hw_option_value    $mhsinst "IPNAME"]
	set    name_lower [string   tolower   $instname]
	set    fileName   $name_lower
	append fileName   "_wrapper.ucf"
	append filePath   $fileName

	# Open a file for writing
	set    outputFile [open $filePath "w"]
	puts   $outputFile "################################################################################ "

	puts $outputFile "NET *q1_clk0_refclk_i TNM_NET=refclk;";
	puts $outputFile "TIMESPEC TS_refclk = PERIOD refclk 6400 ps;";
	puts $outputFile "#";

	puts $outputFile "NET *clk156_buf* TNM_NET=clk156;";
	puts $outputFile "TIMESPEC TS_clk156 = PERIOD clk156 6400 ps;";
	puts $outputFile "#";

	puts $outputFile "NET *gt0_rxoutclk_i TNM_NET=rxoutclk;";
	puts $outputFile "TIMESPEC TS_rxoutclk = PERIOD rxoutclk 3103 ps;";
	puts $outputFile "#";

	puts $outputFile "NET *gt0_txoutclk_i TNM_NET=txoutclk;";
	puts $outputFile "TIMESPEC TS_txoutclk = PERIOD txoutclk 3103 ps;";
	puts $outputFile "#";

	puts $outputFile "NET *txclk322 TNM_NET=txclk322;";
	puts $outputFile "TIMESPEC TS_txclk322 = PERIOD txclk322 3103 ps;";
	puts $outputFile "#";

	puts $outputFile "NET *rxclk322 TNM_NET=rxusrclk2;";
	puts $outputFile "TIMESPEC TS_rxusrclk2 = PERIOD rxusrclk2 3103 ps;";
	puts $outputFile "#";

	puts $outputFile "NET *rxusrclk2_en156* TNM_NET = FFS rxusrclk_en_grp;";
	puts $outputFile "TIMESPEC TS_rx_multiclk = FROM rxusrclk_en_grp to rxusrclk_en_grp TS_rxusrclk2*2;";
	puts $outputFile "#";

	puts $outputFile "NET *dclk_buf TNM_NET=dclk;";
	puts $outputFile "TIMESPEC TS_dclk = PERIOD dclk TS_clk156*2;";

	puts $outputFile "#"
	# Close the file
	close $outputFile

	puts [xget_ncf_loc_info $mhsinst]
}
