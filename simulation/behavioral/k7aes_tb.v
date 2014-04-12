//-----------------------------------------------------------------------------
// k7aes_tb.v
//-----------------------------------------------------------------------------

`timescale 1 ps / 100 fs

`uselib lib=unisims_ver

// START USER CODE (Do not remove this line)

// User: Put your directives here. Code in this
//       section will not be overwritten.

// END USER CODE (Do not remove this line)

module k7aes_tb
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
  reg rxn;
  reg rxp;
  wire sfp_rs;
  reg sfp_sgd;
  wire sfp_txd;
  reg sfp_txf;
  wire txn;
  wire txp;

  k7aes
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
      .sfp_sgd ( sfp_sgd ),
      .sfp_txf ( sfp_txf ),
      .sfp_rs ( sfp_rs ),
      .sfp_txd ( sfp_txd ),
      .txp ( txp ),
      .txn ( txn ),
      .rxp ( rxp ),
      .rxn ( rxn ),
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
  always @(*)
    begin
       refclk_n = ~refclk_p;
       PCIe_Diff_Clk_N = ~PCIe_Diff_Clk_P;
       rxp = txp;
       rxn = txn;
       sfp_sgd = 1'b1;
       sfp_txf = 1'b0;
    end 
  // END USER CODE (Do not remove this line)

endmodule

