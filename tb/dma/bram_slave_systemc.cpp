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

	void bram_a(void);
	void bram_b(void);
	
	SC_CTOR(bram_slave_systemc)
	{
		SC_METHOD(bram_a);
		sensitive_pos << BRAM_Clk_A;

		SC_METHOD(bram_b);
		sensitive_pos << BRAM_Clk_B;
	}

	~bram_slave_systemc()
	{
	}
};

uint32_t bram_ops(uint32_t addr, uint32_t be, uint32_t wo)
{
	uint32_t *p = (uint32_t *)(base0 + (addr & (mem_size - 1)));
	if (be) {
		/* TODO be */
		*p = wo;
	}
	return *p;
}

void bram_slave_systemc::bram_a(void)
{
	if (BRAM_Rst_A.read()) {
		BRAM_Din_A.write(0);
		return;
	}
	if (BRAM_EN_A.read() == 0) {
		return;
	}
	BRAM_Din_A.write(bram_ops(BRAM_Addr_A.read(),
				BRAM_WEN_A.read(),
				BRAM_Dout_A.read()));
}

void bram_slave_systemc::bram_b(void)
{
	if (BRAM_Rst_B.read()) {
		BRAM_Din_B.write(0);
		return;
	}
	if (BRAM_EN_B.read() == 0) {
		return;
	}
	BRAM_Din_B.write(bram_ops(BRAM_Addr_B.read(),
				BRAM_WEN_B.read(),
				BRAM_Dout_B.read()));
}

SC_MODULE_EXPORT(bram_slave_systemc);
