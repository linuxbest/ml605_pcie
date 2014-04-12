/***************************** Include Files *********************************/
#include "axitemac.h"
#include "xaxidma_hw.h"

#if 0
int axitemac_start(void *reg_base)
{
		/*Read BCM8727 CHIP ID*/
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE + 0x10000, 0x84, 0xC8020001);
	mdelay(50);
	printk("BCM8727 CHIP ID:%x\n", XAxiDma_ReadReg((u32)reg_base +
				MAC_ADDR_BASE + 0x10000, 0x80));
	mdelay(50);
	
	/*Set MAC Primary ADDR
	*osti_reg_writel((u32)sstg->reg_base + MAC_ADDR_BASE, RX_FRAME_ADDR1_REG, 0x0000C5C4);
	*osti_reg_writel((u32)sstg->reg_base + MAC_ADDR_BASE, RX_FRAME_ADDR0_REG, 0xC3C2C1C0);
	*/
	
	/*MAC RX PAD CRC Control*/
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE, RX_PADCRC_CTL_REG, 3);
	
	/*Set MAC Clear Status*/
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE, TX_STATS_CLS_REG, 0x01);
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE, RX_STATS_CLS_REG, 0x01);

	
	/*Set BCM8727 XAUI LANE SWAP*/
	/*Set RXLANE SWAP*/
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE + 0x10000, 0x84, 0x81000004);
	mdelay(50);
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE + 0x10000, 0x80, 0x0000C8E4);
	mdelay(50);

	/*Set TXLANE SWAP*/
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE + 0x10000, 0x84, 0x81010004);
	mdelay(50);
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE + 0x10000, 0x80, 0x000080E4);
	mdelay(50);

	/*READ MAC RX PAD CRC Control*/
	printk("RX PAD CRC CONTROL: %x\n", 
		XAxiDma_ReadReg((u32)reg_base + MAC_ADDR_BASE, RX_PADCRC_CTL_REG));

	/*READ RXLANE SWAP REG*/
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE + 0x10000, 0x84, 0x81000004);
	mdelay(50);
	printk("RXLANE SWAP REG: %x\n",
		XAxiDma_ReadReg((u32)reg_base + MAC_ADDR_BASE + 0x10000, 0x80));
	mdelay(50);
	/*READ TXLANE SWAP REG*/
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE + 0x10000, 0x84, 0x81010004);
	mdelay(50);
	printk("TXLANE SWAP REG: %x\n",
		XAxiDma_ReadReg((u32)reg_base + MAC_ADDR_BASE + 0x10000, 0x80));
	return 0;
}
#else

int axitemac_start(void *reg_base)
{
	//Read AEL2020 CHIP ID, Address: 1.C205, CHIP ID should be 0x0211
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE + 0x10000, 0x84, 0xC2050001);
	mdelay(50);
	printk("AEL2020 CHIP ID:%x\n", XAxiDma_ReadReg((u32)reg_base + 
				MAC_ADDR_BASE + 0x10000,0x80));
	mdelay(50);

	/*MAC RX PAD CRC Control*/
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE, RX_PADCRC_CTL_REG, 3);
	
	/*Set MAC Clear Status*/
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE, TX_STATS_CLS_REG, 0x01);
	XAxiDma_WriteReg((u32)reg_base + MAC_ADDR_BASE, RX_STATS_CLS_REG, 0x01);

	return 0;	
}
#endif

