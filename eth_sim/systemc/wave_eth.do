
if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
set ethpath "/system_tb/dut/ETHERNET/ETHERNET/"
set txpath "/system_tb/dut/ETHERNET/ETHERNET/I_EMBEDDED_TOP${ps}TX_INTFCE_I"
set rxpath "/system_tb/dut/ETHERNET/ETHERNET/I_AXI_ETH_RX"
set macpath "/system_tb/dut/ten_mac_phy/ten_mac_phy"

set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -asc}

eval add wave -noupdate -divider {"eth tx"}
eval add wave -noupdate $binopt $ethpath${ps}axitxd_aclk
eval add wave -noupdate $binopt $ethpath${ps}AXI_STR_TXD_ARESETN

eval add wave -noupdate $binopt $ethpath${ps}AXI_STR_TXD_TVALID
eval add wave -noupdate $binopt $ethpath${ps}AXI_STR_TXD_TREADY
eval add wave -noupdate $binopt $ethpath${ps}AXI_STR_TXD_TLAST
eval add wave -noupdate $hexopt $ethpath${ps}AXI_STR_TXD_TKEEP
eval add wave -noupdate $hexopt $ethpath${ps}AXI_STR_TXD_TDATA

eval add wave -noupdate $binopt $ethpath${ps}AXI_STR_TXC_TVALID
eval add wave -noupdate $binopt $ethpath${ps}AXI_STR_TXC_TREADY
eval add wave -noupdate $binopt $ethpath${ps}AXI_STR_TXC_TLAST
eval add wave -noupdate $hexopt $ethpath${ps}AXI_STR_TXC_TKEEP
eval add wave -noupdate $hexopt $ethpath${ps}AXI_STR_TXC_TDATA

eval add wave -noupdate $binopt $ethpath${ps}tx_mac_aclk
eval add wave -noupdate $binopt $ethpath${ps}tx_reset
eval add wave -noupdate $binopt $ethpath${ps}tx_axis_mac_tvalid
eval add wave -noupdate $binopt $ethpath${ps}tx_axis_mac_tready
eval add wave -noupdate $binopt $ethpath${ps}tx_axis_mac_tuser
eval add wave -noupdate $binopt $ethpath${ps}tx_axis_mac_tlast
eval add wave -noupdate $hexopt $ethpath${ps}tx_axis_mac_tkeep
eval add wave -noupdate $hexopt $ethpath${ps}tx_axis_mac_tdata

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

eval add wave -noupdate -divider {"ethernet rx"}
eval add wave -noupdate $binopt $ethpath${ps}AXI_STR_RXD_ACLK

eval add wave -noupdate $binopt $ethpath${ps}AXI_STR_RXD_TVALID
eval add wave -noupdate $binopt $ethpath${ps}AXI_STR_RXD_TREADY
eval add wave -noupdate $binopt $ethpath${ps}AXI_STR_RXD_TLAST
eval add wave -noupdate $hexopt $ethpath${ps}AXI_STR_RXD_TKEEP
eval add wave -noupdate $hexopt $ethpath${ps}AXI_STR_RXD_TDATA

eval add wave -noupdate $binopt $ethpath${ps}AXI_STR_RXS_TVALID
eval add wave -noupdate $binopt $ethpath${ps}AXI_STR_RXS_TREADY
eval add wave -noupdate $binopt $ethpath${ps}AXI_STR_RXS_TLAST
eval add wave -noupdate $hexopt $ethpath${ps}AXI_STR_RXS_TKEEP
eval add wave -noupdate $hexopt $ethpath${ps}AXI_STR_RXS_TDATA

eval add wave -noupdate $binopt $ethpath${ps}rx_mac_aclk
eval add wave -noupdate $binopt $ethpath${ps}rx_reset

eval add wave -noupdate $hexopt $ethpath${ps}rx_axis_mac_tdata
eval add wave -noupdate $hexopt $ethpath${ps}rx_axis_mac_tkeep
eval add wave -noupdate $binopt $ethpath${ps}rx_axis_mac_tlast
eval add wave -noupdate $binopt $ethpath${ps}rx_axis_mac_tvalid
eval add wave -noupdate $binopt $ethpath${ps}rx_axis_mac_tuser

eval add wave -noupdate $hexopt $ethpath${ps}rx_mac_tdata
eval add wave -noupdate $hexopt $ethpath${ps}rx_mac_tkeep
eval add wave -noupdate $binopt $ethpath${ps}rx_mac_tlast
eval add wave -noupdate $binopt $ethpath${ps}rx_mac_tvalid
eval add wave -noupdate $binopt $ethpath${ps}rx_mac_tready

eval add wave -noupdate -divider {"mdc"}
eval add wave -noupdate $binopt $macpath${ps}xgmac${ps}mdc
eval add wave -noupdate $binopt $macpath${ps}xgmac${ps}mdio_out
eval add wave -noupdate $binopt $macpath${ps}xgmac${ps}mdio_in

