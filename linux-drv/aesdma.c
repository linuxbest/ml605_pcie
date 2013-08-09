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

struct aes_local {
	struct device *dev;
	struct pci_dev *pdev;

	u32 base;
	u32 base_len;
	void __iomem *reg_base;

	XAxiDma AxiDma;


	spinlock_t hw_lock;
};

static int aes_probe(struct pci_dev *pdev, 
		const struct pci_device_id *id)
{
	/* TODO */
	return 0;
}

static void aes_remove(struct pci_dev *pdev)
{
	/* TODO */
}

static struct pci_driver aes_driver = {
	.name     = DRIVER_NAME,
	.id_table = aes_pci_table,
	.probe    = aes_probe,
	.remove   = aes_remove,
};

static int __init aes_init(void)
{
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
