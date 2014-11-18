   reg [31:0] 		      cycle_now;
   reg [31:0] 		      cycle_start;
   always @(posedge sys_clk)
     begin
	if (sys_rst_n == 0)
	  begin
	     cycle_now <= #1 32'h0;
	  end
	else
	  begin
	     cycle_now <= #1 cycle_now + 1'b1;
	  end
     end // always @ (posedge sys_clk)
   parameter PCIE_DEVCTRL_REG_ADDR = 8'h88;
   parameter MAX_PAYLOAD = 128;
   
`include "pkg_xbfm_defines.h"

//`define BFM pldawrap_pipe

   reg [15:0] csr;
   reg [32767:0] databuf;

   parameter C_BAR0 = 64'h1110_0000;
   parameter C_INTC = C_BAR0 + 32'h0000_0000;
   parameter C_IER  = C_INTC + 32'h08;
   parameter C_MER  = C_INTC + 32'h1C;
   
   parameter C_DMA0 = C_BAR0 + 32'h0001_0000;

   parameter C_MM2S_DMACR    = 32'h00 + C_DMA0;
   parameter C_MM2S_DMASR    = 32'h04 + C_DMA0;
   parameter C_MM2S_CURDESC  = 32'h08 + C_DMA0;
   parameter C_MM2S_TAILDESC = 32'h10 + C_DMA0;
   parameter C_SG_CTL        = 32'h2C + C_DMA0;
   parameter C_S2MM_DMACR    = 32'h30 + C_DMA0;
   parameter C_S2MM_DMASR    = 32'h34 + C_DMA0;
   parameter C_S2MM_CURDESC  = 32'h38 + C_DMA0;
   parameter C_S2MM_TAILDESC = 32'h40 + C_DMA0;
   initial
     begin
		//-----------------------------------------------------
		// Initialise BFM
		//-----------------------------------------------------
		 #1_000_000;
	 	`BFM.xbfm_print_comment ("### Initialise BFM");
		`BFM.xbfm_init (32'h00000000,32'h8000_0000,64'h0000_0000_0000_0000);
		`BFM.xbfm_set_requesterid (16'h0008);
		`BFM.xbfm_set_maxpayload  (MAX_PAYLOAD);

		// Wait for link to get initialised then disable PIPE logging
	  	`BFM.xbfm_wait_linkup;
	  	`BFM.xbfm_configure_log(`XBFM_LOG_NOPIPE);

		`BFM.xbfm_dword (`XBFM_CFGRD0,{24'h000000,PCIE_DEVCTRL_REG_ADDR},4'hF,{16'h0000,csr});

	 	//-----------------------------------------------------
	 	// Initialise reference design configuration
	 	//-----------------------------------------------------
                #500;
		
		`BFM.xbfm_print_comment ("### Initialise Reference Design configuration");
		`BFM.xbfm_dword (`XBFM_CFGRD0,32'h00000000,4'hF,32'h010610ee);	// Device & vendor ID
		`BFM.xbfm_dword (`XBFM_CFGWR0,32'h00000010,4'hF,32'h1110_0000);	// BAR0 --64bits
		`BFM.xbfm_dword (`XBFM_CFGWR0,32'h00000004,4'hF,32'h000001FF);	// Control/Status

		`BFM.xbfm_dword (`XBFM_CFGRD0,32'h00000010,4'hF,32'h1110_0000);
		`BFM.xbfm_wait;
	
                #50_000;
		// enable IRQ
		`BFM.xbfm_dword (`XBFM_MWR,C_IER,4'hF,32'hFFFF_FFFF);
		`BFM.xbfm_dword (`XBFM_MWR,C_MER,4'hF,32'h0000_0003);

		 //-----------------------------------------------------
		 // DMA0/1 : program direct DMA transfers
		 //-----------------------------------------------------
		 // src 32'h8010_0000
		 // dst 32'h8040_0000
		 // src desc 32'h8020_000
		 // dst desc 32'h8030_000
		 #200;
		 // Fill BFM 64-bit memory space with a ramp
		`BFM.xbfm_buffer_fill (4096,databuf);
		`BFM.xbfm_memory_write (`XBFM_MEM32,32'h0010_0000,4096,databuf);
		`BFM.xbfm_memory_write (`XBFM_MEM32,32'h0011_0000,4096,databuf);
		`BFM.xbfm_memory_write (`XBFM_MEM32,32'h0012_0000,4096,databuf);
		`BFM.xbfm_memory_write (`XBFM_MEM32,32'h0013_0000,4096,databuf);
		`BFM.xbfm_memory_write (`XBFM_MEM32,32'h0014_0000,4096,databuf);

		databuf[32*0+:32] = 32'h8020_1000; // Next Desc
		databuf[32*1+:32] = 32'h0000_0000; // Reserved 
		databuf[32*2+:32] = 32'h8010_0000; // Buf address
		databuf[32*3+:32] = 32'h0000_0000; // Reserved 
		databuf[32*4+:32] = 32'h0000_0000; // Reserved 
		databuf[32*5+:32] = 32'h0000_0000; // Reserved 
		databuf[32*6+:32] = {1'b1, 1'b0, 3'b000, 23'h1000};
		databuf[32*7+:32] = 32'h0000_0000; // Status
		databuf[32*8+:32] = 32'h0000_0000; // App0
		databuf[32*9+:32] = 32'h0000_0000; // App1
		databuf[32*10+:32]= 32'h0000_0000; // App2
		databuf[32*11+:32]= 32'h0000_0000; // App3
		databuf[32*12+:32]= 32'h0000_0000; // App4

		// TX descriptor #1
		databuf[32*0+:32] = 32'h8020_1000; // Next Desc
		databuf[32*2+:32] = 32'h8010_0000; // Buf address
		databuf[32*6+:32] = {1'b1, 1'b0, 3'b000, 23'h1000};
		`BFM.xbfm_memory_write (`XBFM_MEM32,32'h0020_0000,64,databuf);
	
		// TX descriptor #2
		databuf[32*0+:32] = 32'h8020_2000; // Next Desc
		databuf[32*2+:32] = 32'h8011_0000; // Buf address
		databuf[32*6+:32] = {1'b0, 1'b0, 3'b000, 23'h1000};
		`BFM.xbfm_memory_write (`XBFM_MEM32,32'h0020_1000,64,databuf);
	
		// TX descriptor #3
		databuf[32*0+:32] = 32'h0000_0000; // Next Desc
		databuf[32*2+:32] = 32'h8012_0000; // Buf address
		databuf[32*6+:32] = {1'b0, 1'b1, 3'b000, 23'h1000};
		`BFM.xbfm_memory_write (`XBFM_MEM32,32'h0020_2000,64,databuf);
	
		// RX descriptor #1
		databuf[32*0+:32] = 32'h8030_1000; // Next Desc
		databuf[32*2+:32] = 32'h8040_0000; // Buf address
		databuf[32*6+:32] = {1'b0, 1'b0, 3'b000, 23'h1000};
		`BFM.xbfm_memory_write (`XBFM_MEM32,32'h0030_0000,64,databuf);
	
		// RX descriptor #2
		databuf[32*0+:32] = 32'h8030_2000; // Next Desc
		databuf[32*2+:32] = 32'h8041_0000; // Buf address
		databuf[32*6+:32] = {1'b0, 1'b0, 3'b000, 23'h1000};
		`BFM.xbfm_memory_write (`XBFM_MEM32,32'h0030_1000,64,databuf);
	
		// RX descriptor #3
		databuf[32*0+:32] = 32'h0000_0000; // Next Desc
		databuf[32*2+:32] = 32'h8042_0000; // Buf address
		databuf[32*6+:32] = {1'b0, 1'b0, 3'b000, 23'h1000};
		`BFM.xbfm_memory_write (`XBFM_MEM32,32'h0030_2000,64,databuf);

		// Read have some issues
		//`BFM.xbfm_dword (`XBFM_MRD,C_S2MM_CURDESC ,4'hF,32'h8030_0000);

		// RX 
		`BFM.xbfm_dword (`XBFM_MWR,C_S2MM_CURDESC ,4'hF,32'h8030_0000);
		`BFM.xbfm_dword (`XBFM_MWR,C_S2MM_DMACR,   4'hF,32'h0000_1001);
		`BFM.xbfm_dword (`XBFM_MWR,C_S2MM_TAILDESC,4'hF,32'h8030_2000);
		`BFM.xbfm_wait;

		// TX 
		`BFM.xbfm_dword (`XBFM_MWR,C_MM2S_CURDESC ,4'hF,32'h8020_0000);
		`BFM.xbfm_dword (`XBFM_MWR,C_MM2S_DMACR,   4'hF,32'h0000_0001);
		`BFM.xbfm_dword (`XBFM_MWR,C_MM2S_TAILDESC,4'hF,32'h8020_2000);

	         cycle_start = cycle_now;
	
		`BFM.xbfm_wait;

		//-----------------------------------------------------------------
		// Interrupt : wait for interrupt that indicates the end of a DMA
		//-----------------------------------------------------------------
		// Wait for "INTA pin asserted" message
		`BFM.xbfm_wait_event(`XBFM_INTAA_RCVD);

 		// Read interrupt register content
		//`BFM.xbfm_print_comment ("### Interrupt : read & clear interrupt register");
		// databuf[31:0]=32'h00000001;
	        //`BFM.xbfm_burst (`XBFM_MRD,64'h1111111111110034,4,databuf,3'b000,2'b00);
	        $display("DMA cycle ", cycle_now - cycle_start);
	

		#200;
     end
