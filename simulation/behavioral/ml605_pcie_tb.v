//-----------------------------------------------------------------------------
// ml605_pcie_tb.v
//-----------------------------------------------------------------------------

`timescale 1 ps / 100 fs

`uselib lib=unisims_ver

// START USER CODE (Do not remove this line)

// User: Put your directives here. Code in this
//       section will not be overwritten.

// END USER CODE (Do not remove this line)

module ml605_pcie_tb
  (
  );

  // START USER CODE (Do not remove this line)

  // User: Put your signals here. Code in this
  //       section will not be overwritten.

  // END USER CODE (Do not remove this line)

  real CLK_P_PERIOD = 5000.000000;
  real CLK_N_PERIOD = 5000.000000;
  real RESET_LENGTH = 80000;

  // Internal signals

  reg CLK_N;
  reg CLK_P;
  reg [3:0] PCI_Express_pci_exp_rxn;
  reg [3:0] PCI_Express_pci_exp_rxp;
  wire [3:0] PCI_Express_pci_exp_txn;
  wire [3:0] PCI_Express_pci_exp_txp;
  reg PCIe_Diff_Clk_N;
  reg PCIe_Diff_Clk_P;
  reg PCIe_perstn;
  reg RESET;

  ml605_pcie
    dut (
      .RESET ( RESET ),
      .PCI_Express_pci_exp_txp ( PCI_Express_pci_exp_txp ),
      .PCI_Express_pci_exp_txn ( PCI_Express_pci_exp_txn ),
      .PCI_Express_pci_exp_rxp ( PCI_Express_pci_exp_rxp ),
      .PCI_Express_pci_exp_rxn ( PCI_Express_pci_exp_rxn ),
      .CLK_P ( CLK_P ),
      .CLK_N ( CLK_N ),
      .PCIe_Diff_Clk_P ( PCIe_Diff_Clk_P ),
      .PCIe_Diff_Clk_N ( PCIe_Diff_Clk_N ),
      .PCIe_perstn ( PCIe_perstn )
    );

  // Clock generator for CLK_P

  initial
    begin
      CLK_P = 1'b0;
      forever #(CLK_P_PERIOD/2.00)
        CLK_P = ~CLK_P;
    end

  // Clock generator for CLK_N

  initial
    begin
      CLK_N = 1'b1;
      forever #(CLK_N_PERIOD/2.00)
        CLK_N = ~CLK_N;
    end

  // Reset Generator for RESET
  initial
    begin
      RESET = 1'b1;
      #(RESET_LENGTH) RESET = ~RESET;
    end

  // START USER CODE (Do not remove this line)

  // User: Put your stimulus here. Code in this
  //       section will not be overwritten.

   //
   // PCI-Express Model Root Port Instance
   //
   xilinx_pcie_2_0_rport_v6 
     # (.REF_CLK_FREQ(0),
	.PL_FAST_TRAIN("TRUE"),
	.LINK_CAP_MAX_LINK_WIDTH(6'h01),
	.DEVICE_ID(16'h6011),
	.ALLOW_X8_GEN2("FALSE"),
	.LINK_CAP_MAX_LINK_SPEED(4'h1),
	.LINK_CTRL2_TARGET_LINK_SPEED(4'h1),
	.DEV_CAP_MAX_PAYLOAD_SUPPORTED(3'h2),
	.VC0_TX_LASTPACKET(29),
	.VC0_RX_RAM_LIMIT(13'h7FF),
	.VC0_CPL_INFINITE("TRUE"),
	.VC0_TOTAL_CREDITS_PD(308),
	.VC0_TOTAL_CREDITS_CD(308),
	.USER_CLK_FREQ(1))
   RP (// SYS Inteface
       .sys_clk    (CLK_P),
       .sys_reset_n(~RESET),
       
       // PCI-Express Interface
       .pci_exp_txn(PCI_Express_pci_exp_txn), // OUTPUT
       .pci_exp_txp(PCI_Express_pci_exp_txp), // OUTPUT
       .pci_exp_rxn(PCI_Express_pci_exp_rxn), // INPUT
       .pci_exp_rxp(PCI_Express_pci_exp_rxp)); // INPUT
   
  // END USER CODE (Do not remove this line)

endmodule

