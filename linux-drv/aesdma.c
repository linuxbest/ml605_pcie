/*******************************************************************************
 AXI Base AES PCIe Linux Driver
 
 Hu Gang <linuxbest@gmail.com> 
*******************************************************************************/

#include <linux/hardirq.h>
#include <linux/interrupt.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/kernel.h>
#include <linux/types.h>
#include <linux/sched.h>
#include <linux/slab.h>
#include <linux/delay.h>
#include <linux/init.h>
#include <linux/pci.h>
#include <linux/dma-mapping.h>
#include <linux/dmapool.h>
#include <linux/netdevice.h>

#include "xaxidma.h"
#include "xaxidma_bdring.h"
#include "xaxidma.h"
#include "xaxidma_hw.h"
#include "xdebug.h"

#define DRIVER_NAME "AES10G"


static char *git_version = GITVERSION;

static spinlock_t tx_lock;
static spinlock_t rx_lock;
static LIST_HEAD(rx_head);
static LIST_HEAD(tx_head);

static DEFINE_PCI_DEVICE_TABLE(aes_pci_table) = {
	{0x10ee, 0x0505, PCI_ANY_ID, PCI_ANY_ID, 0x0, 0x0, 0x0},

	{0},
};
MODULE_DEVICE_TABLE(pci, aes_pci_table);

struct aes_dev {
	struct device *dev;
	struct pci_dev *pdev;

	u32 base;
	u32 blen;
	void __iomem *reg;

	XAxiDma AxiDma;


	spinlock_t hw_lock;
};

static void AxiDma_Stop(void __iomem *base)
{
	uint32_t reg;

	reg = XAxiDma_ReadReg(base, XAXIDMA_TX_OFFSET + XAXIDMA_CR_OFFSET);
	reg &= ~XAXIDMA_CR_RUNSTOP_MASK;
	XAxiDma_WriteReg(base, XAXIDMA_TX_OFFSET + XAXIDMA_CR_OFFSET, reg);

	reg = XAxiDma_ReadReg(base, XAXIDMA_RX_OFFSET + XAXIDMA_CR_OFFSET);
	reg &= ~XAXIDMA_CR_RUNSTOP_MASK;
	XAxiDma_WriteReg(base, XAXIDMA_RX_OFFSET + XAXIDMA_CR_OFFSET, reg);
}

static int aes_probe(struct pci_dev *pdev, 
		const struct pci_device_id *id)
{
	int err;
	struct aes_dev *dma;

	err = pci_enable_device(pdev);
	if (err) {
		dev_err(&pdev->dev, "PCI device enable failed, err=%d\n",
				err);
		return err;
	}

	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
	if (!err) {
		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
	} else {
		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
		if (!err) 
			err = pci_set_consistent_dma_mask(pdev,
					DMA_BIT_MASK(32));
	}
	if (err) {
		dev_err(&pdev->dev, "No usable DMA configration.\n");
		goto err_dma_mask;
	}

	err = pci_request_regions(pdev, DRIVER_NAME);
	if (err) {
		dev_err(&pdev->dev, "PCI device get region failed, err=%d\n",
				err);
		goto err_request_regions;
	}
	pci_set_master(pdev);

	dma = devm_kzalloc(&pdev->dev, sizeof(*dma), GFP_KERNEL);
	if (!dma) {
		dev_err(&pdev->dev, "Could not alloc dma device.\n");
		goto err_alloc_dmadev;
	}
	pci_set_drvdata(pdev, dma);
	dma->pdev = pdev;
	dma->dev  = &pdev->dev;

	dma->base = pci_resource_start(pdev, 0);
	dma->blen = pci_resource_len(pdev, 0);
	dma->reg  = ioremap_nocache(dma->base, dma->blen);
	if (!dma->reg) {
		dev_err(&pdev->dev, "ioremap reg base error.\n");
		goto err_ioremap;
	}
	dev_info(&pdev->dev, "Base 0x%08x, size 0x%x, mmr 0x%p, irq %d\n",
			dma->base, dma->blen, dma->reg,
			dma->pdev->irq);

	return 0;

err_ioremap:
	kfree(dma);
err_alloc_dmadev:
	pci_release_regions(pdev);
err_request_regions:
err_dma_mask:
	pci_disable_device(pdev);
	return err;
}

static void aes_remove(struct pci_dev *pdev)
{
	struct aes_dev *dma = dev_get_drvdata(&pdev->dev);

	AxiDma_Stop(dma->reg);
	iounmap(dma->reg);
	pci_release_regions(pdev);
	pci_set_drvdata(pdev, NULL);
	pci_disable_device(pdev);
}

static struct pci_driver aes_driver = {
	.name     = DRIVER_NAME,
	.id_table = aes_pci_table,
	.probe    = aes_probe,
	.remove   = aes_remove,
};

static int __init aes_init(void)
{
	pr_debug(DRIVER_NAME ": Linux DMA Driver 0.1 %s\n", 
			git_version);

	spin_lock_init(&tx_lock);
	spin_lock_init(&rx_lock);

	INIT_LIST_HEAD(&tx_head);
	INIT_LIST_HEAD(&rx_head);

	return pci_register_driver(&aes_driver);
}

static void __exit aes_exit(void)
{
	pci_unregister_driver(&aes_driver);
}

module_init(aes_init);
module_exit(aes_exit);

MODULE_DESCRIPTION("AES10G HBA Linux driver");
MODULE_AUTHOR("Hu Gang");
MODULE_LICENSE("GPL");
MODULE_VERSION(GITVERSION);
