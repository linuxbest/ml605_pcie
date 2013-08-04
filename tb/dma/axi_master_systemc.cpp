#include <systemc.h>
#include <stdint.h>

SC_MODULE(axi_master_systemc)
{
public:
	sc_in <bool> bus2ip_clk;
	sc_in <bool> bus2ip_reset;

	sc_out <bool> ip2bus_mstrd_req;
	sc_out <bool> ip2bus_mstwr_req;
	sc_out < sc_uint<32> > ip2bus_mst_addr;
	sc_out < sc_uint<4> > ip2bus_mst_be;
	sc_out <bool> ip2bus_mst_lock;

	sc_in  <bool> bus2ip_mst_cmdack;
	sc_in  <bool> bus2ip_mst_cmplt;
	sc_in  <bool> bus2ip_msg_error;
	sc_in  <bool> bus2ip_msg_rearbitrate;
	sc_in  <bool> bus2ip_mst_cmd_timeout;

	sc_in  < sc_uint<32> > bus2ip_mstrd_d;
	sc_in  <bool> bus2ip_mstrd_src_rdy_n;

	sc_out < sc_uint<32> > ip2bus_mstwr_d;
	sc_in  <bool> bus2ip_mstwr_dst_rdy_n;

	void master_init();
	void iomem_out32(uint32_t off, uint32_t val);
	uint32_t iomem_in32(uint32_t off);

	SC_CTOR(axi_master_systemc)
	{
		SC_THREAD(master_init);

	}

	~axi_master_systemc()
	{
	}
};

void axi_master_systemc::iomem_out32(uint32_t off, uint32_t val)
{
	ip2bus_mstwr_req.write(1);
	ip2bus_mst_addr.write(off);
	ip2bus_mst_be.write(0xf);

	ip2bus_mstwr_d.write(val);

	for(;;) {
		if (bus2ip_mst_cmdack.read()) 
			break;
		wait (bus2ip_clk->posedge_event());
	}
	ip2bus_mstwr_req.write(0);
	for(;;) {
		if (bus2ip_mst_cmplt.read())
				break;
		wait (bus2ip_clk->posedge_event());
	}
}

uint32_t axi_master_systemc::iomem_in32(uint32_t off)
{
	uint32_t val;
	ip2bus_mstrd_req.write(1);
	ip2bus_mst_addr.write(off);
	ip2bus_mst_be.write(0);

	for(;;) {
		if (bus2ip_mst_cmdack.read()) 
			break;
		wait (bus2ip_clk->posedge_event());
	}
	ip2bus_mstrd_req.write(0);
	for (;;) {
		if (bus2ip_mstrd_src_rdy_n.read() == 0)
			break;
		wait (bus2ip_clk->posedge_event());
	}
	return bus2ip_mstrd_d.read();
}

static axi_master_systemc * obj;

#include "osChip.h"

static uint32_t base = 0xC4001000;

uint32_t osChipRegRead(uint32_t addr)
{
	return obj->iomem_in32(addr);
}

void osChipRegWrite(uint32_t addr, uint32_t val)
{
	obj->iomem_out32(addr, val);
}

void systemc_stop(void)
{
	sc_core::sc_stop();
}

void axi_master_systemc::master_init(void)
{
	int i;

	obj = this;

	for (i = 0; i < 100; i ++) 
		wait (bus2ip_clk->posedge_event());

	osChip_init(base);

	for (;;) {
		wait (bus2ip_clk->posedge_event());
	}
}


SC_MODULE_EXPORT(axi_master_systemc);
