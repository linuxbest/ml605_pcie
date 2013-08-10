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

#define dev_trace(dev, fmt, arg...) \
	if (dev) pr_debug("%s:%d " fmt, __func__, __LINE__, ##arg)

#define DRIVER_NAME "AES10G"
#define TX_BD_NUM 16384
#define RX_BD_NUM 16384

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
	struct pci_dev *pdev;

	u32 base;
	u32 blen;
	void __iomem *reg;

	XAxiDma AxiDma;

	/* tx desc */
	XAxiDma_Bd *tx_bd_v;
	dma_addr_t tx_bd_p;
	u32 tx_bd_size;
	
	/* rx desc */
	XAxiDma_Bd *rx_bd_v;
	dma_addr_t rx_bd_p;
	u32 rx_bd_size;

	spinlock_t hw_lock;

	struct list_head desc_head;
	int desc_free;
};

static struct kmem_cache *aes_desc_cache;

enum {
	DMA_TYPE_SG,
	DMA_TYPE_ADDR,
};

typedef struct {
	int type;
	union {
		struct dma_buf_sg {
			struct scatterlist *sg;
			int cnt, sz;
			struct scatterlist *_sg;
			int _i, _len;
		} sg;
		struct dma_buf_addr {
			dma_addr_t dma;
			int len;
		} addr;
	};
} dma_buf_t;


static int
sg_cnt_update(struct scatterlist *sg_list, int sg_cnt, int tsz)
{
	struct scatterlist *sg;
	int i = 0, j = 0;
	for_each_sg(sg_list, sg, sg_cnt, i) {
		int len = min_t(int, sg_dma_len(sg), tsz);
		tsz -= len;
		j ++;
		if (tsz == 0)
			break;
	}
	return j;
}

static int
dma_buf_sg_init(dma_buf_t *buf, struct scatterlist *sg_list, int cnt, int sz)
{
	int i;
	int sg_cnt = sg_cnt_update(sg_list, cnt, sz);
	struct sg_table st;
	struct scatterlist *sg, *src_sg = sg_list;

	if (sg_alloc_table(&st, sg_cnt, GFP_ATOMIC))
		return -ENOMEM;

	buf->type = DMA_TYPE_SG;
	buf->sg.sg = sg = st.sgl;
	buf->sg.cnt= sg_cnt;
	buf->sg.sz = sz;

	for (i = 0; i < sg_cnt; i++, sg = sg_next(sg)) {
		sg_dma_address(sg) = sg_dma_address(src_sg);
		sg_dma_len(sg)     = sg_dma_len(src_sg);
		src_sg = sg_next(src_sg);
	}

	return 0;
}

static int
dma_buf_list_init(dma_buf_t *buf, dma_addr_t *dma, int cnt, int len)
{
	int i;
	int sg_cnt = cnt;
	struct sg_table st;
	struct scatterlist *sg;

	if (sg_alloc_table(&st, sg_cnt, GFP_ATOMIC))
		return -ENOMEM;

	buf->type = DMA_TYPE_SG;
	buf->sg.sg = sg = st.sgl;
	buf->sg.cnt= sg_cnt;
	buf->sg.sz = len * cnt;

	for (i = 0; i < sg_cnt; i++, sg = sg_next(sg)) {
		sg_dma_address(sg) = dma[i];
		sg_dma_len(sg)     = len;
	}

	return 0;
}

static int
dma_buf_addr_init(dma_buf_t *buf, dma_addr_t dma, int len)
{
	buf->type = DMA_TYPE_ADDR;
	buf->addr.dma = dma;
	buf->addr.len = len;
	return 0;
}

static void
dma_buf_sg_clean(dma_buf_t *buf)
{
	struct sg_table st;
	st.sgl = buf->sg.sg;
	st.orig_nents = buf->sg.cnt;
	sg_free_table(&st);
}

static void
dma_buf_clean(dma_buf_t *buf)
{
	if (buf->type == DMA_TYPE_SG)
		dma_buf_sg_clean(buf);
}

static int
dma_buf_cnt(dma_buf_t *buf)
{
	int res = 0;
	switch (buf->type) {
	case DMA_TYPE_ADDR:
		res = 1;
		break;
	case DMA_TYPE_SG:
		res = buf->sg.cnt;
		break;
	}
	return res;
}

static int
dma_buf_first(dma_buf_t *buf, dma_addr_t *addr)
{
	int res = 0;
	switch (buf->type) {
	case DMA_TYPE_ADDR:
		res = buf->addr.len;
		*addr = buf->addr.dma;
		break;
	case DMA_TYPE_SG:
		buf->sg._sg = buf->sg.sg;
		buf->sg._i  = 0;
		buf->sg._len= buf->sg.sz;
		res = sg_dma_len(buf->sg._sg);
		res = min_t(int, res, buf->sg._len);
		*addr = sg_dma_address(buf->sg._sg);
		buf->sg._i  ++;
		buf->sg._len -= res;
		break;
	}
	return res;
}

static int
dma_buf_next(dma_buf_t *buf, dma_addr_t *addr)
{
	int res = 0;
	switch (buf->type) {
	case DMA_TYPE_ADDR:
		break;
	case DMA_TYPE_SG:
		if (buf->sg._i < buf->sg.cnt) {
			buf->sg._sg = sg_next(buf->sg._sg);
			res = sg_dma_len(buf->sg._sg);
			res = min_t(int, res, buf->sg._len);
			*addr = sg_dma_address(buf->sg._sg);
			buf->sg._i  ++;
			buf->sg._len -= res;
		}
		break;
	}
	return res;
}

struct aes_desc {
	struct list_head desc_entry;
	XAxiDma_Bd *tx_BdPtr;
	XAxiDma_Bd *rx_BdPtr;
	struct kref kref;
	dma_buf_t src_buf;
	dma_buf_t dst_buf;
};

static void AxiDma_Stop(u32 base)
{
	uint32_t reg;

	reg = XAxiDma_ReadReg(base, XAXIDMA_TX_OFFSET + XAXIDMA_CR_OFFSET);
	reg &= ~XAXIDMA_CR_RUNSTOP_MASK;
	XAxiDma_WriteReg(base, XAXIDMA_TX_OFFSET + XAXIDMA_CR_OFFSET, reg);

	reg = XAxiDma_ReadReg(base, XAXIDMA_RX_OFFSET + XAXIDMA_CR_OFFSET);
	reg &= ~XAXIDMA_CR_RUNSTOP_MASK;
	XAxiDma_WriteReg(base, XAXIDMA_RX_OFFSET + XAXIDMA_CR_OFFSET, reg);
}

static struct aes_desc *aes_alloc_desc(struct aes_dev *dev)
{
	struct aes_desc *sw;
	unsigned long flags;
	int reused = 0;

	spin_lock_irqsave(&dev->hw_lock, flags);
	if (dev->desc_free > RX_BD_NUM) {
		struct list_head *list = &dev->desc_head;
		sw = list_entry(list->next, struct aes_desc, desc_entry);
		list_del(&sw->desc_entry);
		dev->desc_free --;
		reused = 1;
	} else {
		sw = kmem_cache_alloc(aes_desc_cache, GFP_ATOMIC);
	}
	spin_unlock_irqrestore(&dev->hw_lock, flags);

	dev_trace(&dev->pdev->dev, "dev %p, sw %p, %d/%d\n",
			dev, sw, dev->desc_free, reused);
	memset(sw, 0, sizeof(*sw));
	kref_init(&sw->kref);

	return sw;
}

static int aes_self_test(struct aes_dev *dma)
{
	return 0;
}

static int aes_init_channel(struct aes_dev *dma, XAxiDma_BdRing *ring,
		u32 phy, u32 virt, int cnt)
{
	int res, free_bd_cnt, i;
	XAxiDma_Bd BdTemplate;

	res = XAxiDma_BdRingCreate(ring, phy, virt, XAXIDMA_BD_MINIMUM_ALIGNMENT, cnt);
	if (res != XST_SUCCESS) {
		dev_err(&dma->pdev->dev, "XAxiDma: DMA Ring Create, err=%d\n", res);
		return -ENOMEM;
	}
	XAxiDma_BdClear(&BdTemplate);
	res = XAxiDma_BdRingClone(ring, &BdTemplate);
	if (res != XST_SUCCESS) {
		dev_err(&dma->pdev->dev, "Failed clone\n");
		return -ENOMEM;
	}

	free_bd_cnt = XAxiDma_mBdRingGetFreeCnt(ring);
	for (i = 0; i < free_bd_cnt; i ++) {
	}

	return 0;
}

static int aes_desc_init(struct aes_dev *dma)
{
	int recvsize, sendsize;
	int res;
	int RingIndex = 0;
	XAxiDma_BdRing *RxRingPtr, *TxRingPtr;

	RxRingPtr = XAxiDma_GetRxRing(&dma->AxiDma, RingIndex);
	TxRingPtr = XAxiDma_GetTxRing(&dma->AxiDma);

	/* calc size of descriptor space pool; alloc from non-cached memory */
	sendsize =  XAxiDma_mBdRingMemCalc(XAXIDMA_BD_MINIMUM_ALIGNMENT, TX_BD_NUM);
	dma->tx_bd_v = dma_alloc_coherent(&dma->pdev->dev, sendsize, 
			&dma->tx_bd_p, GFP_KERNEL);
	dma->tx_bd_size = sendsize;

	recvsize = XAxiDma_mBdRingMemCalc(XAXIDMA_BD_MINIMUM_ALIGNMENT, RX_BD_NUM);
	dma->rx_bd_v = dma_alloc_coherent(&dma->pdev->dev, recvsize, 
			&dma->rx_bd_p, GFP_KERNEL);
	dma->rx_bd_size = recvsize;

	dev_dbg(&dma->pdev->dev, "Tx:phy: 0x%llx, virt: %p, size: 0x%x\n"
			"Rx:phy: 0x%llx, virt: %p, size 0x%x\n",
			(uint64_t)dma->tx_bd_p, dma->tx_bd_v, dma->tx_bd_size,
			(uint64_t)dma->rx_bd_p, dma->rx_bd_v, dma->rx_bd_size);
	if (dma->tx_bd_v == NULL || dma->rx_bd_v == NULL) {
		/* TODO */
		return -ENOMEM;
	}

	res = aes_init_channel(dma, TxRingPtr, (u32)dma->tx_bd_p, (u32)dma->tx_bd_v, TX_BD_NUM);
	if (res != 0)
		return res;

	res = aes_init_channel(dma, RxRingPtr, (u32)dma->rx_bd_p, (u32)dma->rx_bd_v, RX_BD_NUM);
	if (res != 0)
		return res;

	INIT_LIST_HEAD(&dma->desc_head);
	dma->desc_free = 0;

	return 0;
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

	err = aes_desc_init(dma);
	if (err != 0) 
		goto err_ioremap;

	aes_self_test(dma);

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
