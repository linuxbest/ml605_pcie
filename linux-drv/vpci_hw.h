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
	IRQ_ISR = 0x00,
	IRQ_IPR = 0x04,
	IRQ_IER = 0x08,
	IRQ_IAR = 0x0C,
	IRQ_MER = 0x1C,
};

#endif
