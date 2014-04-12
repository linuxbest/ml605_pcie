//-----------------------------------------------------------------------------
// system_tb.v
//-----------------------------------------------------------------------------

`timescale 1 ps / 100 fs

`uselib lib=unisims_ver

// START USER CODE (Do not remove this line)

// User: Put your directives here. Code in this
//       section will not be overwritten.

// END USER CODE (Do not remove this line)

module system_tb
  (
  );

  // START USER CODE (Do not remove this line)

  // User: Put your signals here. Code in this
  //       section will not be overwritten.

  // END USER CODE (Do not remove this line)

  real CLK_P_PERIOD = 5000.000000;
  real CLK_N_PERIOD = 5000.000000;
  real refclk_p_PERIOD = 6400.000000;
  real RESET_LENGTH = 96000;

  // Internal signals

  reg CLK_N;
  reg CLK_P;
  reg RESET;
  reg refclk_n;
  reg refclk_p;
  reg rxn;
  reg rxp;
  reg sfp_rs;
  reg sfp_sgd;
  wire sfp_txd;
  reg sfp_txf;
  wire txn;
  wire txp;

  system
    dut (
      .RESET ( RESET ),
      .CLK_P ( CLK_P ),
      .CLK_N ( CLK_N ),
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
      RESET = 1'b1;
      #(RESET_LENGTH) RESET = ~RESET;
    end

  // START USER CODE (Do not remove this line)

  // User: Put your stimulus here. Code in this
  //       section will not be overwritten.
  always @(*) 
  begin
	  refclk_n = ~refclk_p;
	  sfp_sgd  = 1;
	  sfp_txf  = 0;
	  rxp = txp;
	  rxn = txn;
  end
   

  // END USER CODE (Do not remove this line)

endmodule

