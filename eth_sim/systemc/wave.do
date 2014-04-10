
if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists dmapath] } { set scpath "/system_tb${ps}dut${ps}axi_systemc_0${ps}axi_systemc_0" }
if { ![info exists dmapath] } { set txpath "/system_tb/dut/ETHERNET/ETHERNET/I_EMBEDDED_TOP/TX_INTFCE_I/GEN_TXDIF_MEM_PARAM_V6V7A7K7CLIENT8/GEN_TXCIF_MEM_PARAM_V6V7A7K7" }

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -asc}

eval add wave -noupdate -divider {"read req"}
eval add wave -noupdate $hexopt $scpath${ps}s_axi_arid
eval add wave -noupdate $hexopt $scpath${ps}s_axi_araddr
eval add wave -noupdate $hexopt $scpath${ps}s_axi_arlen
eval add wave -noupdate $hexopt $scpath${ps}s_axi_arsize
eval add wave -noupdate $binopt $scpath${ps}s_axi_arburst
eval add wave -noupdate $binopt $scpath${ps}s_axi_arlock
eval add wave -noupdate $binopt $scpath${ps}s_axi_arcache
eval add wave -noupdate $binopt $scpath${ps}s_axi_arprot
eval add wave -noupdate $binopt $scpath${ps}s_axi_arvalid
eval add wave -noupdate $binopt $scpath${ps}s_axi_arready

eval add wave -noupdate -divider {"read rsp"}
eval add wave -noupdate $hexopt $scpath${ps}s_axi_arid
eval add wave -noupdate $hexopt $scpath${ps}s_axi_rdata
eval add wave -noupdate $hexopt $scpath${ps}s_axi_rresp
eval add wave -noupdate $binopt $scpath${ps}s_axi_rlast
eval add wave -noupdate $binopt $scpath${ps}s_axi_rvalid
eval add wave -noupdate $binopt $scpath${ps}s_axi_rready

eval add wave -noupdate -divider {"write req"}
eval add wave -noupdate $hexopt $scpath${ps}s_axi_awid
eval add wave -noupdate $hexopt $scpath${ps}s_axi_awaddr
eval add wave -noupdate $hexopt $scpath${ps}s_axi_awlen
eval add wave -noupdate $hexopt $scpath${ps}s_axi_awsize
eval add wave -noupdate $binopt $scpath${ps}s_axi_awburst
eval add wave -noupdate $binopt $scpath${ps}s_axi_awlock
eval add wave -noupdate $binopt $scpath${ps}s_axi_awcache
eval add wave -noupdate $binopt $scpath${ps}s_axi_awprot
eval add wave -noupdate $binopt $scpath${ps}s_axi_awvalid
eval add wave -noupdate $binopt $scpath${ps}s_axi_awready

eval add wave -noupdate -divider {"write data"}
eval add wave -noupdate $hexopt $scpath${ps}s_axi_wdata
eval add wave -noupdate $hexopt $scpath${ps}s_axi_wstrb
eval add wave -noupdate $binopt $scpath${ps}s_axi_wlast
eval add wave -noupdate $binopt $scpath${ps}s_axi_wvalid
eval add wave -noupdate $binopt $scpath${ps}s_axi_wready

eval add wave -noupdate -divider {"write rsp"}
eval add wave -noupdate $hexopt $scpath${ps}s_axi_bid
eval add wave -noupdate $hexopt $scpath${ps}s_axi_bresp
eval add wave -noupdate $binopt $scpath${ps}s_axi_bvalid
eval add wave -noupdate $binopt $scpath${ps}s_axi_bready

eval add wave -noupdate -divider {"BRAM A port"}
eval add wave -noupdate $binopt $scpath${ps}BRAM_Rst_A
eval add wave -noupdate $binopt $scpath${ps}BRAM_Clk_A
eval add wave -noupdate $binopt $scpath${ps}BRAM_En_A
eval add wave -noupdate $hexopt $scpath${ps}BRAM_Addr_A
eval add wave -noupdate $binopt $scpath${ps}BRAM_WE_A
eval add wave -noupdate $hexopt $scpath${ps}BRAM_WrData_A
eval add wave -noupdate $hexopt $scpath${ps}BRAM_RdData_A

eval add wave -noupdate -divider {"BRAM B port"}
eval add wave -noupdate $binopt $scpath${ps}BRAM_Rst_B
eval add wave -noupdate $binopt $scpath${ps}BRAM_Clk_B
eval add wave -noupdate $binopt $scpath${ps}BRAM_En_B
eval add wave -noupdate $hexopt $scpath${ps}BRAM_Addr_B
eval add wave -noupdate $binopt $scpath${ps}BRAM_WE_B
eval add wave -noupdate $hexopt $scpath${ps}BRAM_WrData_B
eval add wave -noupdate $hexopt $scpath${ps}BRAM_RdData_B

eval add wave -noupdate -divider {"ethernet tx stream if"}
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}reset2axi_str_txd
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}AXI_STR_TXD_ACLK
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}AXI_STR_TXD_TVALID
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}AXI_STR_TXD_TREADY
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}AXI_STR_TXD_TLAST
eval add wave -noupdate $hexopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}AXI_STR_TXD_TSTRB
eval add wave -noupdate $hexopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}AXI_STR_TXD_TDATA

eval add wave -noupdate $hexopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}Axi_Str_TxD_2_Mem_Din
eval add wave -noupdate $hexopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}Axi_Str_TxD_2_Mem_Addr
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}Axi_Str_TxD_2_Mem_En
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}Axi_Str_TxD_2_Mem_We
eval add wave -noupdate $hexopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}Axi_Str_TxD_2_Mem_Dout

eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}reset2axi_str_txc
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}AXI_STR_TXC_ACLK
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}AXI_STR_TXC_TVALID
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}AXI_STR_TXC_TREADY
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}AXI_STR_TXC_TLAST
eval add wave -noupdate $hexopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}AXI_STR_TXC_TSTRB
eval add wave -noupdate $hexopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}AXI_STR_TXC_TDATA

eval add wave -noupdate $hexopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}Axi_Str_TxC_2_Mem_Din
eval add wave -noupdate $hexopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}Axi_Str_TxC_2_Mem_Addr
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}Axi_Str_TxC_2_Mem_En
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}Axi_Str_TxC_2_Mem_We
eval add wave -noupdate $hexopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}Axi_Str_TxC_2_Mem_Dout

eval add wave -noupdate $hexopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}tx_vlan_bram_addr
eval add wave -noupdate $hexopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}tx_vlan_bram_din
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}tx_vlan_bram_en

eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}enable_newFncEn
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}transMode_cross
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}tagMode_cross
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}strpMode_cross

eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}tpid0_cross
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}tpid1_cross
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}tpid2_cross
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}tpid3_cross

eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}newTagData_cross
eval add wave -noupdate $binopt $txpath${ps}TX_AXISTREAM_INTERFACE${ps}tx_init_in_prog

eval add wave -noupdate -divider {"ethernet tx mem if"}
eval add wave -noupdate $binopt $txpath${ps}TX_MEM_INTERFACE${ps}TX_CLIENT_CLK
eval add wave -noupdate $binopt $txpath${ps}TX_MEM_INTERFACE${ps}reset2tx_client

eval add wave -noupdate $hexopt $txpath${ps}TX_MEM_INTERFACE${ps}Tx_Client_TxD_2_Mem_Din
eval add wave -noupdate $hexopt $txpath${ps}TX_MEM_INTERFACE${ps}Tx_Client_TxD_2_Mem_Addr
eval add wave -noupdate $binopt $txpath${ps}TX_MEM_INTERFACE${ps}Tx_Client_TxD_2_Mem_En
eval add wave -noupdate $binopt $txpath${ps}TX_MEM_INTERFACE${ps}Tx_Client_TxD_2_Mem_We
eval add wave -noupdate $hexopt $txpath${ps}TX_MEM_INTERFACE${ps}Tx_Client_TxD_2_Mem_Dout

eval add wave -noupdate $binopt $txpath${ps}TX_MEM_INTERFACE${ps}AXI_STR_TXD_ACLK
eval add wave -noupdate $binopt $txpath${ps}TX_MEM_INTERFACE${ps}reset2axi_str_txd
eval add wave -noupdate $hexopt $txpath${ps}TX_MEM_INTERFACE${ps}Axi_Str_TxD_2_Mem_Din
eval add wave -noupdate $hexopt $txpath${ps}TX_MEM_INTERFACE${ps}Axi_Str_TxD_2_Mem_Addr
eval add wave -noupdate $binopt $txpath${ps}TX_MEM_INTERFACE${ps}Axi_Str_TxD_2_Mem_En
eval add wave -noupdate $binopt $txpath${ps}TX_MEM_INTERFACE${ps}Axi_Str_TxD_2_Mem_We
eval add wave -noupdate $hexopt $txpath${ps}TX_MEM_INTERFACE${ps}Axi_Str_TxD_2_Mem_Dout

eval add wave -noupdate $hexopt $txpath${ps}TX_MEM_INTERFACE${ps}Tx_Client_TxC_2_Mem_Din
eval add wave -noupdate $hexopt $txpath${ps}TX_MEM_INTERFACE${ps}Tx_Client_TxC_2_Mem_Addr
eval add wave -noupdate $binopt $txpath${ps}TX_MEM_INTERFACE${ps}Tx_Client_TxC_2_Mem_En
eval add wave -noupdate $binopt $txpath${ps}TX_MEM_INTERFACE${ps}Tx_Client_TxC_2_Mem_We
eval add wave -noupdate $hexopt $txpath${ps}TX_MEM_INTERFACE${ps}Tx_Client_TxC_2_Mem_Dout

eval add wave -noupdate $binopt $txpath${ps}TX_MEM_INTERFACE${ps}AXI_STR_TXC_ACLK
eval add wave -noupdate $binopt $txpath${ps}TX_MEM_INTERFACE${ps}reset2axi_str_txc
eval add wave -noupdate $hexopt $txpath${ps}TX_MEM_INTERFACE${ps}Axi_Str_TxC_2_Mem_Din
eval add wave -noupdate $hexopt $txpath${ps}TX_MEM_INTERFACE${ps}Axi_Str_TxC_2_Mem_Addr
eval add wave -noupdate $binopt $txpath${ps}TX_MEM_INTERFACE${ps}Axi_Str_TxC_2_Mem_En
eval add wave -noupdate $binopt $txpath${ps}TX_MEM_INTERFACE${ps}Axi_Str_TxC_2_Mem_We
eval add wave -noupdate $hexopt $txpath${ps}TX_MEM_INTERFACE${ps}Axi_Str_TxC_2_Mem_Dout

eval add wave -noupdate -divider {"ethernet tx emac if"}
eval add wave -noupdate $binopt $txpath${ps}TX_EMAC_INTERFACE${ps}tx_axi_clk
eval add wave -noupdate $binopt $txpath${ps}TX_EMAC_INTERFACE${ps}tx_reset_out

eval add wave -noupdate $hexopt $txpath${ps}TX_EMAC_INTERFACE${ps}tx_axis_mac_tdata
eval add wave -noupdate $binopt $txpath${ps}TX_EMAC_INTERFACE${ps}tx_axis_mac_tvalid
eval add wave -noupdate $binopt $txpath${ps}TX_EMAC_INTERFACE${ps}tx_axis_mac_tlast
eval add wave -noupdate $binopt $txpath${ps}TX_EMAC_INTERFACE${ps}tx_axis_mac_tuser
eval add wave -noupdate $binopt $txpath${ps}TX_EMAC_INTERFACE${ps}tx_axis_mac_tready
eval add wave -noupdate $binopt $txpath${ps}TX_EMAC_INTERFACE${ps}tx_collision
eval add wave -noupdate $binopt $txpath${ps}TX_EMAC_INTERFACE${ps}tx_retransmit
eval add wave -noupdate $binopt $txpath${ps}TX_EMAC_INTERFACE${ps}tx_cmplt
eval add wave -noupdate $binopt $txpath${ps}TX_EMAC_INTERFACE${ps}tx_init_in_prog_cross

#  Wave window configuration information
#
configure  wave -justifyvalue          right
configure  wave -signalnamewidth       1

TreeUpdate [SetDefaultTree]

#  Wave window setup complete
#
echo  "Wave window display setup done."
