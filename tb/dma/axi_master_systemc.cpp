#include <systemc.h>

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

	void mem_model();

	SC_CTOR(axi_master_systemc)
	{
		SC_THREAD(mem_model);

	}

	~axi_master_systemc()
	{
	}
};

void axi_master_systemc::mem_model(void)
{
}


SC_MODULE_EXPORT(axi_master_systemc);
