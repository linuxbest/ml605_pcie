set binopt {-logic}
set hexopt {-literal -hex}
set ascopt {-literal -ascii}
if { [info exists PathSeparator] } { set ps $PathSeparator } else { set ps "/" }
if { ![info exists aespath] } { set aespath "/dma_tb_tb${ps}dut/axi_aes_0/axi_aes_0" }

 eval add wave -noupdate -divider {"axi_aes_0 lite "}
 eval add wave -noupdate $binopt $aespath${ps}s_axi_lite_aclk
 eval add wave -noupdate $binopt $aespath${ps}m_axi_mm2s_aclk
 eval add wave -noupdate $binopt $aespath${ps}m_axi_s2mm_aclk
 eval add wave -noupdate $binopt $aespath${ps}axi_resetn
 eval add wave -noupdate $binopt $aespath${ps}s_axi_lite_awvalid
 eval add wave -noupdate $binopt $aespath${ps}s_axi_lite_awready
 eval add wave -noupdate $hexopt $aespath${ps}s_axi_lite_awaddr
 eval add wave -noupdate $binopt $aespath${ps}s_axi_lite_wvalid
 eval add wave -noupdate $binopt $aespath${ps}s_axi_lite_wready
 eval add wave -noupdate $hexopt $aespath${ps}s_axi_lite_wdata
 eval add wave -noupdate $hexopt $aespath${ps}s_axi_lite_bresp
 eval add wave -noupdate $binopt $aespath${ps}s_axi_lite_bvalid
 eval add wave -noupdate $binopt $aespath${ps}s_axi_lite_bready
 eval add wave -noupdate $binopt $aespath${ps}s_axi_lite_arvalid
 eval add wave -noupdate $binopt $aespath${ps}s_axi_lite_arready
 eval add wave -noupdate $hexopt $aespath${ps}s_axi_lite_araddr
 eval add wave -noupdate $binopt $aespath${ps}s_axi_lite_rvalid
 eval add wave -noupdate $binopt $aespath${ps}s_axi_lite_rready
 eval add wave -noupdate $hexopt $aespath${ps}s_axi_lite_rdata
 eval add wave -noupdate $hexopt $aespath${ps}s_axi_lite_rresp
 
 eval add wave -noupdate -divider {"axi_aes_0 mm2s "}
 eval add wave -noupdate $binopt $aespath${ps}mm2s_prmry_reset_out_n
 eval add wave -noupdate $hexopt $aespath${ps}m_axis_mm2s_tdata
 eval add wave -noupdate $hexopt $aespath${ps}m_axis_mm2s_tkeep
 eval add wave -noupdate $binopt $aespath${ps}m_axis_mm2s_tvalid
 eval add wave -noupdate $binopt $aespath${ps}m_axis_mm2s_tready
 eval add wave -noupdate $binopt $aespath${ps}m_axis_mm2s_tlast
 eval add wave -noupdate $hexopt $aespath${ps}m_axis_mm2s_tuser
 eval add wave -noupdate $hexopt $aespath${ps}m_axis_mm2s_tid
 eval add wave -noupdate $hexopt $aespath${ps}m_axis_mm2s_tdest
 
 eval add wave -noupdate -divider {"axi_aes_0 mm2s cntrl "}
 eval add wave -noupdate $binopt $aespath${ps}mm2s_cntrl_reset_out_n
 eval add wave -noupdate $hexopt $aespath${ps}m_axis_mm2s_cntrl_tdata
 eval add wave -noupdate $hexopt $aespath${ps}m_axis_mm2s_cntrl_tkeep
 eval add wave -noupdate $binopt $aespath${ps}m_axis_mm2s_cntrl_tvalid
 eval add wave -noupdate $binopt $aespath${ps}m_axis_mm2s_cntrl_tready
 eval add wave -noupdate $binopt $aespath${ps}m_axis_mm2s_cntrl_tlast

 eval add wave -noupdate -divider {"axi_aes_0 s2mm"}
 eval add wave -noupdate $binopt $aespath${ps}s2mm_prmry_reset_out_n
 eval add wave -noupdate $hexopt $aespath${ps}s_axis_s2mm_tdata
 eval add wave -noupdate $hexopt $aespath${ps}s_axis_s2mm_tkeep
 eval add wave -noupdate $binopt $aespath${ps}s_axis_s2mm_tvalid
 eval add wave -noupdate $binopt $aespath${ps}s_axis_s2mm_tready
 eval add wave -noupdate $binopt $aespath${ps}s_axis_s2mm_tlast
 eval add wave -noupdate $hexopt $aespath${ps}s_axis_s2mm_tuser
 eval add wave -noupdate $hexopt $aespath${ps}s_axis_s2mm_tid
 eval add wave -noupdate $hexopt $aespath${ps}s_axis_s2mm_tdest
 
 eval add wave -noupdate -divider {"axi_aes_0 s2mm sts"}
 eval add wave -noupdate $binopt $aespath${ps}s2mm_sts_reset_out_n
 eval add wave -noupdate $hexopt $aespath${ps}s_axis_s2mm_sts_tdata
 eval add wave -noupdate $hexopt $aespath${ps}s_axis_s2mm_sts_tkeep
 eval add wave -noupdate $binopt $aespath${ps}s_axis_s2mm_sts_tvalid
 eval add wave -noupdate $binopt $aespath${ps}s_axis_s2mm_sts_tready
 eval add wave -noupdate $binopt $aespath${ps}s_axis_s2mm_sts_tlast

 eval add wave -noupdate -divider {"aes "}
 eval add wave -noupdate $binopt $aespath${ps}aes_mm2s${ps}aes_256${ps}clk
 eval add wave -noupdate $hexopt $aespath${ps}aes_mm2s${ps}aes_256${ps}key
 eval add wave -noupdate $hexopt $aespath${ps}aes_mm2s${ps}aes_256${ps}state
 eval add wave -noupdate $hexopt $aespath${ps}aes_mm2s${ps}aes_256${ps}out

 eval add wave -noupdate $hexopt $aespath${ps}aes_mm2s${ps}aes_out
 eval add wave -noupdate $binopt $aespath${ps}aes_mm2s${ps}sfifo_o
 eval add wave -noupdate $binopt $aespath${ps}aes_mm2s${ps}lfifo_o
 eval add wave -noupdate $binopt $aespath${ps}aes_mm2s${ps}aes_s2mm_eof
 
 eval add wave -noupdate $binopt $aespath${ps}aes_mm2s${ps}mm2s_handshake
 eval add wave -noupdate $hexopt $aespath${ps}aes_mm2s${ps}aes_din_i
 eval add wave -noupdate $binopt $aespath${ps}aes_mm2s${ps}din_rd_last
 eval add wave -noupdate $hexopt $aespath${ps}aes_mm2s${ps}din_rd_data
 
 eval add wave -noupdate -divider {"aes sts fms"}
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}m_axi_mm2s_aclk
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}s2mm_sts_reset_out_n
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}state
 eval add wave -noupdate $ascopt $aespath${ps}aes_sts_fsm${ps}state_ascii
 
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}aes_s2mm_eof_empty
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}aes_s2mm_eof_full
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}aes_s2mm_eof_rd
 
 eval add wave -noupdate $hexopt $aespath${ps}aes_sts_fsm${ps}sts_cnt
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}sts_eof_fi
 
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}sts_wr_en
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}sts_wr_last
 eval add wave -noupdate $hexopt $aespath${ps}aes_sts_fsm${ps}sts_wr_din
 
 eval add wave -noupdate -divider {"aes out fifo"}
 eval add wave -noupdate $binopt $aespath${ps}aes_mm2s${ps}aes_fifo${ps}wr_clk
 eval add wave -noupdate $binopt $aespath${ps}aes_mm2s${ps}aes_fifo${ps}rst

 eval add wave -noupdate $hexopt $aespath${ps}aes_mm2s${ps}aes_fifo${ps}din
 eval add wave -noupdate $binopt $aespath${ps}aes_mm2s${ps}aes_fifo${ps}wr_en
 
 eval add wave -noupdate $binopt $aespath${ps}aes_mm2s${ps}aes_fifo${ps}rd_en
 eval add wave -noupdate $hexopt $aespath${ps}aes_mm2s${ps}aes_fifo${ps}dout
 eval add wave -noupdate $binopt $aespath${ps}aes_mm2s${ps}aes_fifo${ps}full
 eval add wave -noupdate $binopt $aespath${ps}aes_mm2s${ps}aes_fifo${ps}empty
 eval add wave -noupdate $binopt $aespath${ps}aes_mm2s${ps}aes_fifo${ps}prog_full
 
 eval add wave -noupdate -divider {"aes sts fifo"}
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}sts_fifo${ps}wr_clk
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}sts_fifo${ps}rst

 eval add wave -noupdate $hexopt $aespath${ps}aes_sts_fsm${ps}sts_fifo${ps}din
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}sts_fifo${ps}wr_en
 
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}sts_fifo${ps}rd_en
 eval add wave -noupdate $hexopt $aespath${ps}aes_sts_fsm${ps}sts_fifo${ps}dout
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}sts_fifo${ps}full
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}sts_fifo${ps}empty
 eval add wave -noupdate $binopt $aespath${ps}aes_sts_fsm${ps}sts_fifo${ps}prog_full

if { ![info exists dmapath] } { set dmapath "/dma_tb_tb${ps}dut/axi_dma_0/axi_dma_0" }
eval add wave -noupdate -divider {"axi dma data move"}
eval add wave -noupdate $binopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}m_axi_mm2s_aclk
eval add wave -noupdate $binopt $dmapath${ps}s_axis_s2mm_cmd_tvalid_split
eval add wave -noupdate $binopt $dmapath${ps}s_axis_s2mm_cmd_tvalid 
eval add wave -noupdate $binopt $dmapath${ps}I_S2MM_DMA_MNGR${ps}s_axis_s2mm_cmd_tvalid
eval add wave -noupdate $binopt $dmapath${ps}I_S2MM_DMA_MNGR${ps}s2mm_cmnd_wr
eval add wave -noupdate $binopt $dmapath${ps}I_S2MM_DMA_MNGR${ps}s2mm_cmnd_data

#eval add wave -noupdate $binopt $dmapath${ps}I_S2MM_DMA_MNGR${ps}I_S2MM_SM${ps}s2mm_cs

eval add wave -noupdate -divider {"axi dma data move mm2s user command "}
eval add wave -noupdate $binopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}s_axis_mm2s_cmd_tvalid
eval add wave -noupdate $binopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}s_axis_mm2s_cmd_tready
eval add wave -noupdate $hexopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}s_axis_mm2s_cmd_tdata

eval add wave -noupdate -divider {"axi dma data move mm2s user sts"}
eval add wave -noupdate $binopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}m_axis_mm2s_sts_tvalid
eval add wave -noupdate $binopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}m_axis_mm2s_sts_tready
eval add wave -noupdate $hexopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}m_axis_mm2s_sts_tdata
eval add wave -noupdate $hexopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}m_axis_mm2s_sts_tkeep
eval add wave -noupdate $binopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}m_axis_mm2s_sts_tlast

eval add wave -noupdate -divider {"axi dma data move s2mm user command "}
eval add wave -noupdate $binopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}s_axis_s2mm_cmd_tvalid
eval add wave -noupdate $binopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}s_axis_s2mm_cmd_tready
eval add wave -noupdate $hexopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}s_axis_s2mm_cmd_tdata

eval add wave -noupdate -divider {"axi dma data move s2mm user sts"}
eval add wave -noupdate $binopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}m_axis_s2mm_sts_tvalid
eval add wave -noupdate $binopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}m_axis_s2mm_sts_tready
eval add wave -noupdate $hexopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}m_axis_s2mm_sts_tdata
eval add wave -noupdate $hexopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}m_axis_s2mm_sts_tkeep
eval add wave -noupdate $binopt $dmapath${ps}I_PRMRY_DATAMOVER${ps}m_axis_s2mm_sts_tlast
