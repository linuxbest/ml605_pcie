// axi_10g_mac_phy.v --- 
// 
// Filename: axi_10g_mac_phy.v
// Description: 
// Author: Hu Gang
// Maintainer: 
// Created: Sun Apr  6 14:10:54 2014 (-0700)
// Version: 
// Last-Updated: 
//           By: 
//     Update #: 0
// URL: 
// Keywords: 
// Compatibility: 
// 
// 

// Commentary: 
// 
// 
// 
// 

// Change log:
// 
// 
// 

// -------------------------------------
// Naming Conventions:
// 	active low signals                 : "*_n"
// 	clock signals                      : "clk", "clk_div#", "clk_#x"
// 	reset signals                      : "rst", "rst_n"
// 	generics                           : "C_*"
// 	user defined types                 : "*_TYPE"
// 	state machine next state           : "*_ns"
// 	state machine current state        : "*_cs"
// 	combinatorial signals              : "*_com"
// 	pipelined or register delay signals: "*_d#"
// 	counter signals                    : "*cnt*"
// 	clock enable signals               : "*_ce"
// 	internal version of output port    : "*_i"
// 	device pins                        : "*_pin"
// 	ports                              : - Names begin with Uppercase
// Code:
module axi_10gmacphy (/*AUTOARG*/
   // Outputs
   xgmii_txd_dbg, xgmii_txc_dbg, xgmii_rxd_dbg, xgmii_rxc_dbg,
   xgmacint, txp, txn, tx_reset, tx_mac_aclk, tx_disable,
   tx_axis_tready, sfp_rs, rx_reset, rx_mac_aclk, rx_axis_tvalid,
   rx_axis_tuser, rx_axis_tlast, rx_axis_tkeep, rx_axis_tdata,
   resetdone, linkup, ip2bus_wrack, ip2bus_rdack, ip2bus_error,
   ip2bus_data, core_clk156_out,
   // Inputs
   tx_fault, tx_axis_tvalid, tx_axis_tuser, tx_axis_tlast,
   tx_axis_tkeep, tx_axis_tdata, signal_detect, rxp, rxn,
   rx_axis_tready, reset, refclk_p, refclk_n, bus2ip_rnw,
   bus2ip_reset, bus2ip_data, bus2ip_cs, bus2ip_clk, bus2ip_addr
   );
   parameter C_FAMILY = "";
   parameter C_MDIO_ADDR = 5'h0;
   parameter EXAMPLE_SIM_GTRESET_SPEEDUP = "FALSE";
   parameter C_DBG_PORT = 0;
   
   input [31:0]		bus2ip_addr;		// To xgmac of xgmac.v
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input		bus2ip_clk;		// To xgmac of xgmac.v
   input		bus2ip_cs;		// To xgmac of xgmac.v
   input [31:0]		bus2ip_data;		// To xgmac of xgmac.v
   input		bus2ip_reset;		// To xgmac of xgmac.v
   input		bus2ip_rnw;		// To xgmac of xgmac.v
   input		refclk_n;		// To xphy_block of xphy_block.v
   input		refclk_p;		// To xphy_block of xphy_block.v
   input		reset;			// To xgmac of xgmac.v, ...
   input		rx_axis_tready;		// To xphy_int of xphy_int.v
   input		rxn;			// To xphy_block of xphy_block.v
   input		rxp;			// To xphy_block of xphy_block.v
   input		signal_detect;		// To xphy_block of xphy_block.v, ...
   input [63:0]		tx_axis_tdata;		// To xgmac of xgmac.v
   input [7:0]		tx_axis_tkeep;		// To xgmac of xgmac.v
   input		tx_axis_tlast;		// To xgmac of xgmac.v
   input [127:0]	tx_axis_tuser;		// To xgmac of xgmac.v
   input		tx_axis_tvalid;		// To xgmac of xgmac.v
   input		tx_fault;		// To xphy_block of xphy_block.v, ...
   // End of automatics
   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output		core_clk156_out;	// From xphy_int of xphy_int.v
   output [31:0]	ip2bus_data;		// From xgmac of xgmac.v
   output		ip2bus_error;		// From xgmac of xgmac.v
   output		ip2bus_rdack;		// From xgmac of xgmac.v
   output		ip2bus_wrack;		// From xgmac of xgmac.v
   output		linkup;			// From xphy_int of xphy_int.v
   output		resetdone;		// From xphy_int of xphy_int.v
   output [63:0]	rx_axis_tdata;		// From xgmac of xgmac.v
   output [7:0]		rx_axis_tkeep;		// From xgmac of xgmac.v
   output		rx_axis_tlast;		// From xgmac of xgmac.v
   output		rx_axis_tuser;		// From xgmac of xgmac.v
   output		rx_axis_tvalid;		// From xgmac of xgmac.v
   output		rx_mac_aclk;		// From xphy_int of xphy_int.v
   output		rx_reset;		// From xphy_int of xphy_int.v
   output		sfp_rs;			// From xphy_int of xphy_int.v
   output		tx_axis_tready;		// From xgmac of xgmac.v
   output		tx_disable;		// From xphy_block of xphy_block.v
   output		tx_mac_aclk;		// From xphy_int of xphy_int.v
   output		tx_reset;		// From xphy_int of xphy_int.v
   output		txn;			// From xphy_block of xphy_block.v
   output		txp;			// From xphy_block of xphy_block.v
   output		xgmacint;		// From xgmac of xgmac.v
   output [7:0]		xgmii_rxc_dbg;		// From xphy_int of xphy_int.v
   output [63:0]	xgmii_rxd_dbg;		// From xphy_int of xphy_int.v
   output [7:0]		xgmii_txc_dbg;		// From xphy_int of xphy_int.v
   output [63:0]	xgmii_txd_dbg;		// From xphy_int of xphy_int.v
   // End of automatics

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			areset;			// From xphy_int of xphy_int.v
   wire			clk156;			// From xphy_block of xphy_block.v
   wire			core_reset_tx;		// From xphy_int of xphy_int.v
   wire [7:0]		core_status;		// From xphy_block of xphy_block.v
   wire			dclk;			// From xphy_block of xphy_block.v
   wire			dclk_reset;		// From xphy_int of xphy_int.v
   wire			mdc;			// From xgmac of xgmac.v
   wire			pause_req;		// From xgmac_int of xgmac_int.v
   wire [15:0]		pause_val;		// From xgmac_int of xgmac_int.v
   wire [4:0]		prtad;			// From xphy_int of xphy_int.v
   wire			rx_axis_aresetn;	// From xphy_int of xphy_int.v
   wire			rx_clk0;		// From xgmac_int of xgmac_int.v
   wire			rx_dcm_lock;		// From xphy_int of xphy_int.v
   wire			rx_resetdone;		// From xphy_block of xphy_block.v
   wire			rx_statistics_valid;	// From xgmac of xgmac.v
   wire [29:0]		rx_statistics_vector;	// From xgmac of xgmac.v
   wire			rxclk322;		// From xphy_block of xphy_block.v
   wire			rxreset322;		// From xphy_int of xphy_int.v
   wire			tx_axis_aresetn;	// From xphy_int of xphy_int.v
   wire			tx_clk0;		// From xgmac_int of xgmac_int.v
   wire			tx_dcm_lock;		// From xphy_int of xphy_int.v
   wire [7:0]		tx_ifg_delay;		// From xphy_int of xphy_int.v
   wire			tx_resetdone;		// From xphy_block of xphy_block.v
   wire			tx_statistics_valid;	// From xgmac of xgmac.v
   wire [25:0]		tx_statistics_vector;	// From xgmac of xgmac.v
   wire			txclk322;		// From xphy_block of xphy_block.v
   wire			txreset322;		// From xphy_int of xphy_int.v
   wire [7:0]		xgmii_rxc;		// From xphy_int of xphy_int.v
   wire [7:0]		xgmii_rxc_int;		// From xphy_block of xphy_block.v
   wire [63:0]		xgmii_rxd;		// From xphy_int of xphy_int.v
   wire [63:0]		xgmii_rxd_int;		// From xphy_block of xphy_block.v
   wire [7:0]		xgmii_txc;		// From xgmac of xgmac.v
   wire [7:0]		xgmii_txc_int;		// From xphy_int of xphy_int.v
   wire [63:0]		xgmii_txd;		// From xgmac of xgmac.v
   wire [63:0]		xgmii_txd_int;		// From xphy_int of xphy_int.v
   // End of automatics

   wire 		mdio_in_int;
   wire 		mdio_out_int;
   /* xgmac AUTO_TEMPLATE (
    .mdio_in                   (mdio_in_int),
    .mdio_out                  (mdio_out_int),
    .mdio_tri                  (),    
    );*/
   xgmac
     xgmac (/*AUTOINST*/
	    // Outputs
	    .tx_axis_tready		(tx_axis_tready),
	    .tx_statistics_valid	(tx_statistics_valid),
	    .rx_axis_tvalid		(rx_axis_tvalid),
	    .rx_axis_tuser		(rx_axis_tuser),
	    .rx_axis_tlast		(rx_axis_tlast),
	    .rx_statistics_valid	(rx_statistics_valid),
	    .ip2bus_rdack		(ip2bus_rdack),
	    .ip2bus_wrack		(ip2bus_wrack),
	    .ip2bus_error		(ip2bus_error),
	    .xgmacint			(xgmacint),
	    .mdc			(mdc),
	    .mdio_out			(mdio_out_int),		 // Templated
	    .mdio_tri			(),			 // Templated
	    .tx_statistics_vector	(tx_statistics_vector[25:0]),
	    .rx_axis_tdata		(rx_axis_tdata[63:0]),
	    .rx_axis_tkeep		(rx_axis_tkeep[7:0]),
	    .rx_statistics_vector	(rx_statistics_vector[29:0]),
	    .ip2bus_data		(ip2bus_data[31:0]),
	    .xgmii_txd			(xgmii_txd[63:0]),
	    .xgmii_txc			(xgmii_txc[7:0]),
	    // Inputs
	    .reset			(reset),
	    .tx_axis_aresetn		(tx_axis_aresetn),
	    .tx_axis_tvalid		(tx_axis_tvalid),
	    .tx_axis_tlast		(tx_axis_tlast),
	    .rx_axis_aresetn		(rx_axis_aresetn),
	    .pause_req			(pause_req),
	    .bus2ip_clk			(bus2ip_clk),
	    .bus2ip_reset		(bus2ip_reset),
	    .bus2ip_rnw			(bus2ip_rnw),
	    .bus2ip_cs			(bus2ip_cs),
	    .tx_clk0			(tx_clk0),
	    .tx_dcm_lock		(tx_dcm_lock),
	    .rx_clk0			(rx_clk0),
	    .rx_dcm_lock		(rx_dcm_lock),
	    .mdio_in			(mdio_in_int),		 // Templated
	    .tx_axis_tdata		(tx_axis_tdata[63:0]),
	    .tx_axis_tuser		(tx_axis_tuser[127:0]),
	    .tx_ifg_delay		(tx_ifg_delay[7:0]),
	    .tx_axis_tkeep		(tx_axis_tkeep[7:0]),
	    .pause_val			(pause_val[15:0]),
	    .bus2ip_addr		(bus2ip_addr[10:0]),
	    .bus2ip_data		(bus2ip_data[31:0]),
	    .xgmii_rxd			(xgmii_rxd[63:0]),
	    .xgmii_rxc			(xgmii_rxc[7:0]));

   xgmac_int
     xgmac_int (/*AUTOINST*/
		// Outputs
		.pause_req		(pause_req),
		.pause_val		(pause_val[15:0]),
		.tx_clk0		(tx_clk0),
		.rx_clk0		(rx_clk0),
		// Inputs
		.rx_statistics_valid	(rx_statistics_valid),
		.rx_statistics_vector	(rx_statistics_vector[29:0]),
		.tx_statistics_valid	(tx_statistics_valid),
		.tx_statistics_vector	(tx_statistics_vector[25:0]),
		.clk156			(clk156));

   /* xphy_block AUTO_TEMPLATE (
    .mdio_in               (mdio_out_int),
    .mdio_out              (mdio_in_int),
    .mdio_tri              (),
    .xgmii_rxd             (xgmii_rxd_int[]),
    .xgmii_rxc             (xgmii_rxc_int[]),
    .xgmii_txd             (xgmii_txd_int[]),
    .xgmii_txc             (xgmii_txc_int[]),
    .reset		   (core_reset_tx),
    );*/
   xphy_block  #(/*AUTOINSTPARAM*/
		 // Parameters
		 .EXAMPLE_SIM_GTRESET_SPEEDUP(EXAMPLE_SIM_GTRESET_SPEEDUP))
     xphy_block (/*AUTOINST*/
		 // Outputs
		 .clk156		(clk156),
		 .txclk322		(txclk322),
		 .rxclk322		(rxclk322),
		 .dclk			(dclk),
		 .txp			(txp),
		 .txn			(txn),
		 .xgmii_rxd		(xgmii_rxd_int[63:0]),	 // Templated
		 .xgmii_rxc		(xgmii_rxc_int[7:0]),	 // Templated
		 .mdio_out		(mdio_in_int),		 // Templated
		 .mdio_tri		(),			 // Templated
		 .core_status		(core_status[7:0]),
		 .tx_resetdone		(tx_resetdone),
		 .rx_resetdone		(rx_resetdone),
		 .tx_disable		(tx_disable),
		 // Inputs
		 .refclk_n		(refclk_n),
		 .refclk_p		(refclk_p),
		 .areset		(areset),
		 .reset			(core_reset_tx),	 // Templated
		 .txreset322		(txreset322),
		 .rxreset322		(rxreset322),
		 .dclk_reset		(dclk_reset),
		 .rxp			(rxp),
		 .rxn			(rxn),
		 .xgmii_txd		(xgmii_txd_int[63:0]),	 // Templated
		 .xgmii_txc		(xgmii_txc_int[7:0]),	 // Templated
		 .mdc			(mdc),
		 .mdio_in		(mdio_out_int),		 // Templated
		 .prtad			(prtad[4:0]),
		 .signal_detect		(signal_detect),
		 .tx_fault		(tx_fault));

   xphy_int   #(/*AUTOINSTPARAM*/
		// Parameters
		.C_MDIO_ADDR		(C_MDIO_ADDR),
		.EXAMPLE_SIM_GTRESET_SPEEDUP(EXAMPLE_SIM_GTRESET_SPEEDUP))
     xphy_int  (/*AUTOINST*/
		// Outputs
		.areset			(areset),
		.dclk_reset		(dclk_reset),
		.resetdone		(resetdone),
		.rx_axis_aresetn	(rx_axis_aresetn),
		.tx_axis_aresetn	(tx_axis_aresetn),
		.core_clk156_out	(core_clk156_out),
		.core_reset_tx		(core_reset_tx),
		.txreset322		(txreset322),
		.rxreset322		(rxreset322),
		.xgmii_txd_int		(xgmii_txd_int[63:0]),
		.xgmii_txc_int		(xgmii_txc_int[7:0]),
		.xgmii_rxd		(xgmii_rxd[63:0]),
		.xgmii_rxc		(xgmii_rxc[7:0]),
		.xgmii_txd_dbg		(xgmii_txd_dbg[63:0]),
		.xgmii_rxd_dbg		(xgmii_rxd_dbg[63:0]),
		.xgmii_txc_dbg		(xgmii_txc_dbg[7:0]),
		.xgmii_rxc_dbg		(xgmii_rxc_dbg[7:0]),
		.rx_dcm_lock		(rx_dcm_lock),
		.tx_dcm_lock		(tx_dcm_lock),
		.prtad			(prtad[4:0]),
		.tx_ifg_delay		(tx_ifg_delay[7:0]),
		.sfp_rs			(sfp_rs),
		.tx_mac_aclk		(tx_mac_aclk),
		.tx_reset		(tx_reset),
		.rx_mac_aclk		(rx_mac_aclk),
		.rx_reset		(rx_reset),
		.linkup			(linkup),
		// Inputs
		.reset			(reset),
		.dclk			(dclk),
		.tx_resetdone		(tx_resetdone),
		.rx_resetdone		(rx_resetdone),
		.clk156			(clk156),
		.tx_fault		(tx_fault),
		.signal_detect		(signal_detect),
		.txclk322		(txclk322),
		.xgmii_txd		(xgmii_txd[63:0]),
		.xgmii_txc		(xgmii_txc[7:0]),
		.xgmii_rxd_int		(xgmii_rxd_int[63:0]),
		.xgmii_rxc_int		(xgmii_rxc_int[7:0]),
		.rxclk322		(rxclk322),
		.core_status		(core_status[7:0]),
		.rx_axis_tready		(rx_axis_tready));

   wire [35:0] 		CONTROL0;
   wire [35:0] 		CONTROL1;
   wire [35:0] 		CONTROL2;   
   wire [255:0] 	c_dbg;
   wire [15:0] 		c_trig;
   wire [255:0] 	t_dbg;
   wire [15:0] 		t_trig;
   wire [255:0] 	r_dbg;
   wire [15:0] 		r_trig;
   assign c_trig[7:0] = core_status; 
   assign c_dbg[7:0]  = core_status;
   assign c_dbg[8]    = reset;
   assign c_dbg[9]    = signal_detect;
   assign c_dbg[10]   = tx_fault;
   assign c_dbg[11]   = resetdone;
   assign c_dbg[12]   = rx_reset;
   assign c_dbg[13]   = tx_reset;
   assign c_dbg[14]   = sfp_rs;
   assign c_dbg[15]   = tx_disable;
   assign c_dbg[16]   = xgmacint;
   assign c_dbg[17]   = 1'b0;
   assign c_dbg[18]   = dclk_reset;
   assign c_dbg[19]   = rx_resetdone;
   assign c_dbg[20]   = tx_resetdone;

   assign r_trig[0]   = rx_axis_tvalid;
   assign r_trig[1]   = rx_axis_tlast;
   assign r_trig[2]   = rx_axis_tready;
   
   assign r_dbg[0]     = rx_axis_tvalid;
   assign r_dbg[1]     = rx_axis_tlast;
   assign r_dbg[2]     = rx_axis_tready;
   assign r_dbg[3]     = rx_axis_tuser;
   assign r_dbg[23:16] = rx_axis_tkeep;
   assign r_dbg[87:24] = rx_axis_tdata;
   assign r_dbg[95:88] = xgmii_rxc_int;
   assign r_dbg[159:96]= xgmii_rxd_int;

   assign t_trig[0]   = tx_axis_tvalid;
   assign t_trig[1]   = tx_axis_tlast;
   assign t_trig[2]   = tx_axis_tready;
   
   assign t_dbg[0]     = tx_axis_tvalid;
   assign t_dbg[1]     = tx_axis_tlast;
   assign t_dbg[2]     = tx_axis_tready;
   assign t_dbg[3]     = tx_axis_tuser;
   assign t_dbg[23:16] = tx_axis_tkeep;
   assign t_dbg[87:24] = tx_axis_tdata;
   assign t_dbg[95:88] = xgmii_txc_int;
   assign t_dbg[159:96]= xgmii_txd_int;

   generate if (C_DBG_PORT == 1) 
     begin
	icon3     icon3 (/*AUTOINST*/
			 // Inouts
			 .CONTROL0		(CONTROL0[35:0]),
			 .CONTROL1		(CONTROL1[35:0]),
			 .CONTROL2		(CONTROL2[35:0]));
	ila256_16 ila_c (
			 // Inouts
			 .CONTROL		(CONTROL0[35:0]),
			 // Inputs
			 .CLK			(clk156),
			 .DATA			(c_dbg[255:0]),
			 .TRIG0			(c_trig[15:0]));
	ila256_16 ila_t (
			 // Inouts
			 .CONTROL		(CONTROL1[35:0]),
			 // Inputs
			 .CLK			(clk156),
			 .DATA			(t_dbg[255:0]),
			 .TRIG0			(t_trig[15:0]));
	ila256_16 ila_r (
			 // Inouts
			 .CONTROL		(CONTROL2[35:0]),
			 // Inputs
			 .CLK			(clk156),
			 .DATA			(r_dbg[255:0]),
			 .TRIG0			(r_trig[15:0]));
     end
   endgenerate
endmodule // axi_10gmacphy
// Local Variables:
// verilog-library-directories:("../../loopback" ".")
// verilog-library-files:("")
// verilog-library-extensions:(".v" ".h")
// End:
// 
// axi_10g_mac_phy.v ends here
