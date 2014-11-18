//-----------------------------------------------------------------------------
// k7sim_gt_tb.v
//-----------------------------------------------------------------------------

`timescale 1 ps / 100 fs

`uselib lib=unisims_ver

// START USER CODE (Do not remove this line)

// User: Put your directives here. Code in this
//       section will not be overwritten.

// END USER CODE (Do not remove this line)

module k7sim_gt_tb
  (
  );

  // START USER CODE (Do not remove this line)

  // User: Put your signals here. Code in this
  //       section will not be overwritten.

  // END USER CODE (Do not remove this line)

  real CLK_PERIOD = 10000.000000;
  real PCIe_Diff_Clk_P_PERIOD = 10000.000000;
  real PCIe_Diff_Clk_N_PERIOD = 10000.000000;
  real refclk_p_PERIOD = 6400.000000;
  real RESET_LENGTH = 160000;
  real PCIe_perstn_LENGTH = 160000;

  // Internal signals

  reg CLK;
  reg [7:0] PCI_Express_pci_exp_rxn;
  reg [7:0] PCI_Express_pci_exp_rxp;
  wire [7:0] PCI_Express_pci_exp_txn;
  wire [7:0] PCI_Express_pci_exp_txp;
  reg PCIe_Diff_Clk_N;
  reg PCIe_Diff_Clk_P;
  reg PCIe_perstn;
  reg RESET;
  reg refclk_n;
  reg refclk_p;

  k7sim_gt
    dut (
      .RESET ( RESET ),
      .CLK ( CLK ),
      .PCI_Express_pci_exp_txp ( PCI_Express_pci_exp_txp ),
      .PCI_Express_pci_exp_txn ( PCI_Express_pci_exp_txn ),
      .PCI_Express_pci_exp_rxp ( PCI_Express_pci_exp_rxp ),
      .PCI_Express_pci_exp_rxn ( PCI_Express_pci_exp_rxn ),
      .PCIe_Diff_Clk_P ( PCIe_Diff_Clk_P ),
      .PCIe_Diff_Clk_N ( PCIe_Diff_Clk_N ),
      .PCIe_perstn ( PCIe_perstn ),
      .refclk_p ( refclk_p ),
      .refclk_n ( refclk_n )
    );

  // Clock generator for CLK

  initial
    begin
      CLK = 1'b0;
      forever #(CLK_PERIOD/2.00)
        CLK = ~CLK;
    end

  // Clock generator for PCIe_Diff_Clk_P

  initial
    begin
      PCIe_Diff_Clk_P = 1'b0;
      forever #(PCIe_Diff_Clk_P_PERIOD/2.00)
        PCIe_Diff_Clk_P = ~PCIe_Diff_Clk_P;
    end

  // Clock generator for PCIe_Diff_Clk_N

  initial
    begin
      PCIe_Diff_Clk_N = 1'b0;
      forever #(PCIe_Diff_Clk_N_PERIOD/2.00)
        PCIe_Diff_Clk_N = ~PCIe_Diff_Clk_N;
    end

  // Clock generator for refclk_p

  initial
    begin
      refclk_p = 1'b0;
      forever #(refclk_p_PERIOD/2.00)
        refclk_p = ~refclk_p;
    end

  // Reset Generator for RESET

  initial
    begin
      RESET = 1'b0;
      #(RESET_LENGTH) RESET = ~RESET;
    end

  // Reset Generator for PCIe_perstn

  initial
    begin
      PCIe_perstn = 1'b0;
      #(PCIe_perstn_LENGTH) PCIe_perstn = ~PCIe_perstn;
    end

  // START USER CODE (Do not remove this line)

  // User: Put your stimulus here. Code in this
  //       section will not be overwritten.
   parameter BFM_ID     = 0;
   parameter BFM_TYPE   = 0;
   parameter BFM_LANES  = 8;
   parameter BFM_WIDTH  = 1;
   parameter IO_SIZE    = 16;
   parameter MEM32_SIZE = 16;
   parameter MEM64_SIZE = 16;

   wire tx_rate;
   wire chk_txval;
   wire [63:0] chk_txdata;
   wire [7:0]  chk_txdatak;
   wire        chk_rxval;
   wire [63:0] chk_rxdata;
   wire [7:0]  chk_rxdatak;
   wire [4:0]  chk_ltssm;
   wire [7:0]  rx_val;

   reg 	       clk125;
   reg 	       clk250;
   reg 	       bfm_rstn;
   reg [7:0]   tx_val;

   // tx_rate 
   //  0: 2.5Gps, clk125 125Mhz, clk250 250Mhz
   //  1: 5.0Gps, clk125 250Mhz, clk250 500Mhz
   initial
     begin
	clk125   <= 1'b0;
	clk250   <= 1'b0;
	bfm_rstn <= 1'b0;
	tx_val   <= 8'h0;

	#500;
	bfm_rstn <= 1'b1;
     end
   always
     begin
	if (tx_rate)
	  begin
	     #1;
	  end
	else
	  begin
	     #2;
	  end
	clk250 <= ~clk250;
     end // always begin
   always
     begin
	if (tx_rate)
	  begin
	     #2;
	  end
	else
	  begin
	     #4;
	  end
	clk125 <= ~clk125;
     end

   wire [7:0] rx_data;
   wire [7:0] tx_data;
   assign tx_data = PCI_Express_pci_exp_txn;
   always @(*)
     begin
	PCI_Express_pci_exp_rxp = rx_data;
	PCI_Express_pci_exp_rxn =~rx_data;
     end

   /* pldawrap_link AUTO_TEMPLATE (
    .rx_out\([0-9]+\) (rx_data[\1]),
    .tx_in\([0-9]+\)  (tx_data[\1]),
    .rstn             (bfm_rstn),
    );
    */
   pldawrap_link  #(/*AUTOINSTPARAM*/
		    // Parameters
		    .BFM_ID		(BFM_ID),
		    .BFM_TYPE		(BFM_TYPE),
		    .BFM_LANES		(BFM_LANES),
		    .BFM_WIDTH		(BFM_WIDTH),
		    .IO_SIZE		(IO_SIZE),
		    .MEM32_SIZE		(MEM32_SIZE),
		    .MEM64_SIZE		(MEM64_SIZE))
   pldawrap_link (/*AUTOINST*/
		  // Outputs
		  .tx_rate		(tx_rate),
		  .rx_val		(rx_val[7:0]),
		  .rx_out0		(rx_data[0]),		 // Templated
		  .rx_out1		(rx_data[1]),		 // Templated
		  .rx_out2		(rx_data[2]),		 // Templated
		  .rx_out3		(rx_data[3]),		 // Templated
		  .rx_out4		(rx_data[4]),		 // Templated
		  .rx_out5		(rx_data[5]),		 // Templated
		  .rx_out6		(rx_data[6]),		 // Templated
		  .rx_out7		(rx_data[7]),		 // Templated
		  .chk_txval		(chk_txval),
		  .chk_txdata		(chk_txdata[63:0]),
		  .chk_txdatak		(chk_txdatak[7:0]),
		  .chk_rxval		(chk_rxval),
		  .chk_rxdata		(chk_rxdata[63:0]),
		  .chk_rxdatak		(chk_rxdatak[7:0]),
		  .chk_ltssm		(chk_ltssm[4:0]),
		  // Inputs
		  .clk125		(clk125),
		  .clk250		(clk250),
		  .rstn			(bfm_rstn),		 // Templated
		  .tx_val		(tx_val[7:0]),
		  .tx_in0		(tx_data[0]),		 // Templated
		  .tx_in1		(tx_data[1]),		 // Templated
		  .tx_in2		(tx_data[2]),		 // Templated
		  .tx_in3		(tx_data[3]),		 // Templated
		  .tx_in4		(tx_data[4]),		 // Templated
		  .tx_in5		(tx_data[5]),		 // Templated
		  .tx_in6		(tx_data[6]),		 // Templated
		  .tx_in7		(tx_data[7]));		 // Templated
  wire sys_clk;
  wire sys_rst_n;
  assign sys_clk   = PCIe_Diff_Clk_P;
  assign sys_rst_n = PCIe_perstn;

`define BFM k7aes_tb.pldawrap_link
`include "../../k7aes_sim/pipe_axidma_tb.h"

  // END USER CODE (Do not remove this line)

endmodule

