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
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE, CFG0, (1<<6)|(19));
#if 0	
	/* reset the phy 1.0.15 */
	res = mdio_write_reg(reg_base, 0x0, 0x3, 0x0, 1<<15);
	if (res != 0) {
		printk("%s: mdio write 3.0.15 reg failed\n", __func__);
	}
	res = mdio_write_reg(reg_base, 0x0, 0x1, 0x0, 1<<15);
	if (res != 0) {
		printk("%s: mdio write 1.0.15 reg failed\n", __func__);
	}
#endif
	return 0;
}

int axitemac_exit(void *reg_base)
{
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE, CFG0, 0x0);
}

int axitemac_start(void *reg_base)
{
	int res;

	/* tx disable 1.9.0 */
	res = mdio_write_reg(reg_base, 0x0, 0x1, 0x9, 0);
	if (res != 0) {
		printk("%s: mdio write reg failed\n", __func__);
	}

	return 0;
}

int axitemac_stop(void *reg_base)
{
	int res;

	/* tx disable 1.9.0 */
	res = mdio_write_reg(reg_base, 0x0, 0x1, 0x9, 1);
	if (res != 0) {
		printk("%s: mdio write reg failed\n", __func__);
	}

	return 0;
}
