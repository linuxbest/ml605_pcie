#include <systemc.h>
#include <stdint.h>
#include "osChip.h"

SC_MODULE(bram_slave_systemc)
{
public:
	sc_in <bool> BRAM_Rst_A;
	sc_in <bool> BRAM_Clk_A;
	sc_in <bool> BRAM_EN_A;
	sc_in  < sc_uint<4>  > BRAM_WEN_A;
	sc_in  < sc_uint<32> > BRAM_Addr_A;
	sc_out < sc_uint<32> > BRAM_Din_A;
	sc_in  < sc_uint<32> > BRAM_Dout_A;

	sc_in <bool> BRAM_Rst_B;
	sc_in <bool> BRAM_Clk_B;
	sc_in <bool> BRAM_EN_B;
	sc_in  < sc_uint<4>  > BRAM_WEN_B;
	sc_in  < sc_uint<32> > BRAM_Addr_B;
	sc_out < sc_uint<32> > BRAM_Din_B;
	sc_in  < sc_uint<32> > BRAM_Dout_B;

	void bram_model(void);
	
	SC_CTOR(bram_slave_systemc)
	{
		SC_THREAD(bram_model);
	}

	~bram_slave_systemc()
	{
	}
};

void bram_slave_systemc::bram_model(void)
{
	printf("bram model init, %d\n", mem_size);

	int i;

	for (i = 0; i < 1000; i ++) {
		wait (BRAM_Clk_A->posedge_event());
	}

	for (i = 0; ; i ++) {
		wait (BRAM_Clk_A->posedge_event());

		//base0[0] = i;

		BRAM_Din_A.write(i);
	}
}

SC_MODULE_EXPORT(bram_slave_systemc);
