/***************************** Include Files *********************************/
#include "axitemac.h"
#include "xaxidma_hw.h"

int axitemac_start(void *reg_base)
{
	printk("MAC version: %08x\n", XAxiDma_ReadReg((u32)reg_base + MAC_ADDR_BASE, 0x4F8));
	return 0;	
}

