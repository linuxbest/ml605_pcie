#ifndef _VIRTUAL_PCI_H_
#define _VIRTUAL_PCI_H_

#include <linux/platform_device.h>

struct vpci_id {
	uint32_t vendor;
	uint32_t device;
};

extern int vpci_driver_register(struct platform_driver *);
extern int vpci_driver_unregister(struct platform_driver *);

extern void vpci_free_irq(struct platform_device *pdev, unsigned int);
extern int vpci_request_irq(struct platform_device *pdev, 
		unsigned int irq, irq_handler_t handler, unsigned long flags,
		const char *name, void *dev);

#define VPCI_FPGA_VENDOR 0xAA55
#define VPCI_AES_DEVICE  0x2013
#define VPCI_10G_DEVICE  0x2014

#if 0
extern int vpci_spi_flash_open(struct platform_device *pdev);
extern int vpci_spi_flash_close(struct platform_device *pdev);
extern int vpci_spi_flash_read(struct platform_device *pdev,
		uint32_t offset, void *buf, int bytes);
extern int vpci_spi_flash_write(struct platform_device *pdev,
		uint32_t offset, void *buf, int bytes);
#endif

#endif
