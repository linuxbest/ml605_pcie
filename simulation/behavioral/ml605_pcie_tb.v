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

  // END USER CODE (Do not remove this line)

endmodule

