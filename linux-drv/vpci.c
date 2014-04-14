/*
 * Copyright (c) 2014 Hu Gang <hugang@soulinfo.com>
 *
 * base on drivers/net/ethernet/intel/e100.c
 */
#include <linux/init.h>
#include <linux/interrupt.h>
#include <linux/module.h>
#include <linux/kernel.h>

#include <linux/pci.h>
#include <linux/list.h>
#include <linux/ioport.h>

#include "vpci.h"
#include "vpci_hw.h"

struct list_head virt_head;

#if 1
#define VPCI_READ(offest)		readl(offest)
#define VPCI_WRITE(val, offest)		writel((val), (offest));
#else
#define VPCI_READ(offest)		be32_to_cpu(readl(offest))
#define VPCI_WRITE(val, offest)		writel(cpu_to_be32(val), (offest));
#endif 

struct virt_device {
	struct list_head entry;
	struct vpci_id id;
	void __iomem *mmio;
	int mmio_len;
	struct resource res[5]; /* 0 MEM, 1,2,3,4 IRQ */
	irq_handler_t irqs[4];
	void *irqs_priv[4];
	struct vpci_device *vp;
	struct platform_driver *drv;
	struct platform_device *pd;
	int port;
};

struct vpci_device {
	void __iomem *mmio;
	void __iomem *ctrl;
	struct virt_device *vd[8];
	struct pci_dev *pdev;
};

int
vpci_driver_register(struct platform_driver *drv)
{
	struct virt_device *vd;
	int rc;

	rc = platform_driver_register(drv);
	if (rc)
		return rc;

	list_for_each_entry(vd, &virt_head, entry) {
		struct vpci_id *id = (void *)drv->id_table->driver_data;
		struct platform_device *pd;

		pr_debug("vd %p, id %p\n", vd, id);
		if (id == NULL)
			continue;
		pr_debug("drv %08x:%08x, vd %08x:%08x, drv %p\n",
				id->vendor, id->device,
				vd->id.vendor, vd->id.device,
				vd->drv);
		if (vd->id.vendor != id->vendor &&
		    vd->id.device != id->device)
			continue;
		if (vd->drv)
			continue;

		pd = platform_device_alloc(drv->driver.name, vd->port);
		if (pd == NULL) {
			/* TODO free other resource */
			return -ENOMEM;
		}
		printk("Port%d  alloc pd(%p) ok\n", vd->port, pd);

		vd->drv = drv;
		vd->pd = pd;
		pd->dev.parent = NULL;
		pd->dev.dma_mask = vd->vp->pdev->dev.dma_mask;
		pd->dev.coherent_dma_mask = DMA_BIT_MASK(64);
		if (!pd->dev.coherent_dma_mask && pd->dev.dma_mask)
			dev_warn(&pd->dev, "coherent dma mask is unset\n");

		rc = platform_device_add_resources(pd, vd->res, 2);
		if (rc) {
			/* TODO free other resource */
			return -ENOMEM;
		}

		rc = platform_device_add(pd);
		pr_debug("vd %p, pd %p, rc %d\n", vd, pd, rc);
		if (rc) {
			/* TODO free other resource */
			return rc;
		}
	}
	return 0;
}

int 
vpci_driver_unregister(struct platform_driver *drv)
{
	struct virt_device *vd;
	list_for_each_entry(vd, &virt_head, entry) {
		if (vd->drv == drv) {
			platform_device_unregister(vd->pd);
			vd->drv = NULL;
			vd->pd = NULL;
		}
	}
	platform_driver_unregister(drv);
	return 0;
}

void vpci_free_irq(struct platform_device *pdev, unsigned int irq)
{
	struct virt_device *vd = (void *) platform_get_resource(
			pdev, IORESOURCE_BUS, 0)->start;
	u32 irq_en;
	
	if (irq > 3)
		return;
	vd->irqs[irq]      = NULL;
	vd->irqs_priv[irq] = NULL;

	/* disable the IRQ line */
	irq_en = VPCI_READ(vd->vp->ctrl + IRQ_EN);
	dev_dbg(&pdev->dev, "irq_en %08x, port %d, irq %d\n",
			irq_en, vd->port, irq);
	irq_en &= ~(0x1 << (irq + (vd->port<<2)));
	VPCI_WRITE(irq_en, vd->vp->ctrl + IRQ_EN);
}

int vpci_request_irq(struct platform_device *pdev, 
		unsigned int irq, irq_handler_t handler, unsigned long flags,
		const char *name, void *dev)
{
	struct virt_device *vd = (void *) platform_get_resource(
			pdev, IORESOURCE_BUS, 0)->start;
	u32 irq_en;

	if (irq > 3)
		return -EINVAL;
	if (vd->irqs[irq] != NULL)
		return -EBUSY;
	vd->irqs[irq] = handler;
	vd->irqs_priv[irq] = dev;
	
	/* enable the IRQ line */
	irq_en = VPCI_READ(vd->vp->ctrl + IRQ_EN);
	dev_dbg(&pdev->dev, "irq_en %08x, port %d, irq %d",
			irq_en, vd->port, irq);
	irq_en |= (0x1 << (irq + (vd->port<<2)));
	VPCI_WRITE(irq_en, vd->vp->ctrl + IRQ_EN);
	
	return 0;
}

static void vd_isr(struct virt_device *vd, uint8_t irq)
{
	int i;

	if (vd == NULL)
		return;
	for (i = 0; i < 4; i ++) {
		dev_dbg(&vd->pd->dev, "i %d, irq %02x, cb %p, prv %p\n",
				i, irq, vd->irqs[i], vd->irqs_priv[i]);
		if ((irq & (1<<i)) == 0)
			continue;
		if (vd->irqs[i] == NULL) {
			dev_err(&vd->pd->dev, "no irq handler\n");
			return;
		}
		vd->irqs[i](i, vd->irqs_priv[i]);
	}
}

EXPORT_SYMBOL(vpci_driver_register);
EXPORT_SYMBOL(vpci_driver_unregister);
EXPORT_SYMBOL(vpci_request_irq);
EXPORT_SYMBOL(vpci_free_irq);

int vpci_spi_flash_open(struct platform_device *pdev)
{
	/* TODO */
	return 0;
}

int vpci_spi_flash_close(struct platform_device *pdev)
{
	/* TODO */
	return 0;
}

int vpci_spi_flash_read(struct platform_device *pdev,
		uint32_t offset, void *buf, int bytes)
{
	/* TODO */
	return 0;
}

int vpci_spi_flash_write(struct platform_device *pdev,
		uint32_t offset, void *buf, int bytes)
{
	/* TODO */
	return 0;
}

EXPORT_SYMBOL(vpci_spi_flash_open);
EXPORT_SYMBOL(vpci_spi_flash_close);
EXPORT_SYMBOL(vpci_spi_flash_read);
EXPORT_SYMBOL(vpci_spi_flash_write);

static irqreturn_t vpci_isr(int irq, void *dev_id)
{
	struct vpci_device *vp = dev_id;
	u32 irq_en, irq_sts, irq_pending;
	int i;

	irq_en      = VPCI_READ(vp->ctrl + IRQ_EN);
	irq_sts     = VPCI_READ(vp->ctrl + IRQ_STS);
	irq_pending = VPCI_READ(vp->ctrl + IRQ_PEND);
	
	if (irq_pending == 0)
		return IRQ_NONE;

	dev_dbg(&vp->pdev->dev, "vp %p, en %08x, sts %08x, pend %08x\n",
			vp, irq_en, irq_sts, irq_pending);

	for (i = 0; i < 8; i ++) {
		if (irq_pending == 0)
			break;
		vd_isr(vp->vd[i], irq_pending);
		irq_pending = irq_pending >> 4;
	}
	

	return IRQ_HANDLED;
}

static DEFINE_PCI_DEVICE_TABLE(vpci_id_table) = {
	{ 0x10ee, 0x0106, PCI_ANY_ID, PCI_ANY_ID, }, 
	{ 0, },
};

static struct vpci_struct {
	uint32_t subsystem_vendor;
	uint32_t subsystem_device;
} vpci_funs [] = {
	[0] = {
		.subsystem_vendor = 0x0,
		.subsystem_device = 0x1,
	},
};

static int  __init vpci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
{
	struct vpci_device *vp;
	int rc, bar_size, fun_num, i;
	u32 port_num = 0;

	dev_dbg(&pdev->dev, "probe\n");
	
	/* acquire resources */
	rc = pcim_enable_device(pdev);
	if (rc)
		return rc;
	
	rc = pcim_iomap_regions_request_all(pdev, 0x3, "vpci");
	if (rc == -EBUSY)
		pcim_pin_device(pdev);
	if (rc)
		return rc;

	vp = devm_kzalloc(&pdev->dev, sizeof(*vp), GFP_KERNEL);
	if (vp == NULL)
		return -ENOMEM;
	vp->pdev = pdev;
	vp->mmio = pcim_iomap_table(pdev)[0];
	vp->ctrl = pcim_iomap_table(pdev)[1];
	dev_dbg(&pdev->dev, "vp %p, mmio %p, ctrl %p\n",
			vp, vp->mmio, vp->ctrl);

	bar_size = 0x4000;
	dev_dbg(&pdev->dev, "vp %p, fun reg %08x, hw version %08x\n",
			vp, bar_size, VPCI_READ(vp->ctrl + HW_VER));
	fun_num  = sizeof(vpci_funs)/sizeof(vpci_funs[0]);

	for (i = 0; i < fun_num; i ++) {
		struct virt_device *vd;
		vd = kzalloc(sizeof(*vd), GFP_KERNEL);
		if (vd == NULL) {
			/* TODO free other resource */
			return -ENOMEM;
		}
		vp->vd[i]     = vd;
		vd->id.vendor = vpci_funs[i].subsystem_vendor;
		vd->id.device = vpci_funs[i].subsystem_device;
		vd->mmio      = vp->mmio + i * bar_size;
		vd->mmio_len  = bar_size;
		vd->vp        = vp;
		vd->port      = i;
		list_add_tail(&vd->entry, &virt_head);
		dev_dbg(&pdev->dev, "vd %p, %08x:%08x mmio %p, %d\n", vd,
				vd->id.vendor, vd->id.device,
				vd->mmio, vd->mmio_len);
		vd->res[0].start = (u64)vd->mmio;
		vd->res[0].end   = (u64)vd->mmio + vd->mmio_len;
		vd->res[0].flags = IORESOURCE_DMA;
		vd->res[0].name  = "mmio";
		vd->res[1].start = (u64)vd;
		vd->res[1].flags = IORESOURCE_BUS;
		vd->res[2].name  = "reg";
	}
	if (request_irq(pdev->irq, vpci_isr, IRQF_SHARED, "vpci", vp)) {
		dev_err(&pdev->dev, "request_irq %d failed\n", pdev->irq);
		/* TODO clean the resources */
		return -ENODEV;
	}
	dev_set_drvdata(&pdev->dev, vp);

	return 0;
}

static void __exit vpci_remove(struct pci_dev *pdev)
{
	struct vpci_device *vp = dev_get_drvdata(&pdev->dev);
	/* TODO */
	free_irq(pdev->irq, vp);
	pci_set_drvdata(pdev, NULL);
	pci_release_regions(pdev);
	pci_disable_device(pdev);
}

static void vpci_shutdown(struct pci_dev *pdev)
{
	pci_save_state(pdev);
	/* TODO */
	dev_info(&pdev->dev, "%s: TODO\n", __func__);
	pci_disable_device(pdev);
}

#ifdef CONFIG_PM
static int vpci_suspend(struct pci_dev *pdev, pm_message_t state)
{
	dev_info(&pdev->dev, "%s: TODO\n", __func__);
	return 0;
}
static int vpci_resume(struct pci_dev *pdev)
{
	pci_set_power_state(pdev, PCI_D0);
	pci_restore_state(pdev);
	/* ack any pending wake events, disable PME */
	pci_enable_wake(pdev, 0, 0);

	/* TODO */
	dev_info(&pdev->dev, "%s: TODO\n", __func__);

	return 0;
}
#endif

/* ------------------ PCI Error Recovery infrastructure  -------------- */
/**
 * vpci_io_error_detected - call when PCI error is deteced.
 * @pdev: Pointer to PCI device 
 * @state: The current pci connect state
 */
static pci_ers_result_t vpci_io_error_detected(struct pci_dev *pdev,
		pci_channel_state_t state)
{
	if (state == pci_channel_io_perm_failure)
		return PCI_ERS_RESULT_DISCONNECT;

	/* TODO */
	dev_info(&pdev->dev, "%s: TODO\n", __func__);

	pci_disable_device(pdev);

	/* Request a slot reset. */
	return PCI_ERS_RESULT_NEED_RESET;
}

/**
 * vpci_io_slot_reset - called after the pci bus has been reset.
 * @pdev: Pointer to PCI device
 *
 * Restart the card from scratch.
 */
static pci_ers_result_t vpci_io_slot_reset(struct pci_dev *pdev)
{
	if (pci_enable_device(pdev)) {
		pr_err("Cannot re-enable PCI device after reset\n");
		return PCI_ERS_RESULT_DISCONNECT;
	}
	pci_set_master(pdev);

	/* TODO */
	dev_info(&pdev->dev, "%s: TODO\n", __func__);

	return PCI_ERS_RESULT_RECOVERED;
}

/**
 * vpci_io_resume - resume normal operations
 * @pdev: pointer to PCI device 
 *
 * Resume normal operations after error recovery
 * sequence has been complete.
 */
static void vpci_io_resume(struct pci_dev *pdev)
{
	/* ack any pending wake event, disable PME */
	pci_enable_wake(pdev, 0, 0);

	/* TODO */
	dev_info(&pdev->dev, "%s: TODO\n", __func__);
}

static struct pci_error_handlers vpci_err_handler = {
	.error_detected = vpci_io_error_detected,
	.slot_reset     = vpci_io_slot_reset,
	.resume         = vpci_io_resume,
};

static struct pci_driver vpci_driver = {
	.name     = "vpci_driver",
	.id_table = vpci_id_table,
	.probe    = vpci_probe,
	.remove   = vpci_remove,
#ifdef CONFIG_PM 
	.suspend  = vpci_suspend,
	.resume   = vpci_resume,
#endif
	.shutdown = vpci_shutdown,
	.err_handler = &vpci_err_handler,
};

static int __init vpci_init(void)
{
	INIT_LIST_HEAD(&virt_head);
	return pci_register_driver(&vpci_driver);
}

static void __exit vpci_exit(void)
{
	/* TODO 
	 * clean the virt_head 
	 */
	pci_unregister_driver(&vpci_driver);
}

module_init(vpci_init);
module_exit(vpci_exit);

MODULE_AUTHOR("HuGang");
MODULE_LICENSE("GPL");
