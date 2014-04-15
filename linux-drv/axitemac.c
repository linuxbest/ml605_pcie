/***************************** Include Files *********************************/
#include "axitemac.h"
#include "xaxidma_hw.h"

enum {
	CFG0 = 0x500,
	CFG1 = 0x504,
	TXD  = 0x508,
	RXD  = 0x50C,
};

static int mdio_wait(void *reg)
{
	uint32_t res, retry = 10000;
	do {
		res = XAxiDma_ReadReg((u32)reg + MAC_ADDR_BASE, CFG1);
		retry --;
		if (retry == 0)
			return -1;
	} while ((res & (1<<7)) == 0);
	return 0;
}

static int mdio_write_reg(void *reg, uint32_t prtad, uint32_t devad, 
		uint32_t regad, uint32_t val)
{
	uint32_t cr = (devad<<16) | (prtad<<24);

	XAxiDma_WriteReg((u32)reg + MAC_ADDR_BASE, TXD,  regad);
	XAxiDma_WriteReg((u32)reg + MAC_ADDR_BASE, CFG1, 0x0800 | cr);
	if (mdio_wait(reg) != 0) 
		return -1;

	XAxiDma_WriteReg((u32)reg + MAC_ADDR_BASE, TXD,  val);
	XAxiDma_WriteReg((u32)reg + MAC_ADDR_BASE, CFG1, 0x4800 | cr);
	return mdio_wait(reg);
}

int axitemac_init(void *reg_base)
{
	XAxiDma_WriteReg((u32)reg_base + 0x1000, 0x0, 0x1);
	return 0;
}

int axitemac_exit(void *reg_base)
{
	XAxiDma_WriteReg((u32)reg_base + 0x1000, 0x0, 0x1);
	return 0;
}

int axitemac_start(void *reg_base)
{
	XAxiDma_WriteReg((u32)reg_base + 0x1000, 0x0, 0x0);
	return 0;
}

int axitemac_stop(void *reg_base)
{
	XAxiDma_WriteReg((u32)reg_base + 0x1000, 0x0, 0x1);
	return 0;
}
