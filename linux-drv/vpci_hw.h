#ifndef _VPCI_HW_H_
#define _VPCI_HW_H_

/* 
 * bar1: control register
 *  0x00: version
 *  0x04: irq pending
 *  0x08: irq en
 *  0x0C: irq sts
 */
enum {
	HW_VER   = 0x00,
	IRQ_PEND = 0x04,
	IRQ_EN   = 0x08,
	IRQ_STS  = 0x0C,
};

#endif
