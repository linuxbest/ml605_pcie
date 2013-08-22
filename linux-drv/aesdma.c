/*******************************************************************************
 AXI Base AES PCIe Linux Driver
 
 Hu Gang <linuxbest@gmail.com> 
*******************************************************************************/
#define DEBUG 1
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

#include "aesdma.h"

#define dev_trace(dev, fmt, arg...) \
	if (dev) pr_debug("%s:%d " fmt, __func__, __LINE__, ##arg)

#define DRIVER_NAME "AES10G"
#define TX_BD_NUM 16
#define RX_BD_NUM 16

static char *git_version = GITVERSION;

static spinlock_t tx_lock, tx_bh_lock;
static spinlock_t rx_lock, rx_bh_lock;
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
	struct list_head tx_entry;

	/* rx desc */
	XAxiDma_Bd *rx_bd_v;
	dma_addr_t rx_bd_p;
	u32 rx_bd_size;
	struct list_head rx_entry;

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
	struct aes_dev *dma;
	struct list_head desc_entry;
	XAxiDma_Bd *tx_BdPtr;
	XAxiDma_Bd *rx_BdPtr;
	struct kref kref;
	dma_buf_t src_buf;
	dma_buf_t dst_buf;
	void *priv;
	void (*cb)(void *priv);
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
	sw->dma = dev;

	return sw;
}

static void aes_unmap_buf(struct aes_dev *dma, dma_buf_t *buf, int dir)
{
	switch (buf->type) {
	case DMA_TYPE_ADDR:
		dma_unmap_single(&dma->pdev->dev, buf->addr.dma, buf->addr.len, dir);
		break;
	case DMA_TYPE_SG:
		dma_unmap_sg(&dma->pdev->dev, buf->sg.sg, buf->sg.cnt, dir);
		break;
	}
}

static void aes_free_desc(struct kref *kref)
{
	struct aes_desc *sw = container_of(kref, struct aes_desc, kref);
	struct aes_dev *dma = sw->dma;
	unsigned long flags;

	dev_trace(&dma->pdev->dev, "dev %p, sw %p, %d\n", 
			dma, sw, dma->desc_free);

	aes_unmap_buf(dma, &sw->src_buf, DMA_TO_DEVICE);
	aes_unmap_buf(dma, &sw->dst_buf, DMA_FROM_DEVICE);

	if (sw->cb) {
		sw->cb(sw->priv);
		sw->cb = NULL;
	}

	spin_lock_irqsave(&dma->hw_lock, flags);
	list_add_tail(&sw->desc_entry, &dma->desc_head);
	dma->desc_free ++;
	spin_unlock_irqrestore(&dma->hw_lock, flags);
	
}

static void ring_dump(XAxiDma_BdRing *bd_ring, char *prefix);

static int _aes_desc_to_hw(struct aes_dev *dma, dma_buf_t *dbuf,
	XAxiDma_Bd **bd, XAxiDma_BdRing *ring, char *name, struct aes_desc *sw)
{
	XAxiDma_Bd *first_bd_ptr;
	XAxiDma_Bd *last_bd_ptr;
	XAxiDma_Bd *bd_ptr;

	int len, res, tcnt = 0, cnt = 0;
	dma_addr_t addr = 0;
	u32 sts = XAXIDMA_BD_CTRL_TXSOF_MASK;

	cnt = dma_buf_cnt(dbuf);
	res = XAxiDma_BdRingAlloc(ring, cnt, bd);
	if (res != XST_SUCCESS) {
		dev_err(&dma->pdev->dev, "XAxiDma: BdRingAlloc unsuccessful (%d,%d)\n",
				cnt, res);
		return res;
	}
	dev_trace(&dma->pdev->dev, "dev %p, bd %p, cnt %d, ring %p\n",
			dma, *bd, cnt, ring);

	bd_ptr = last_bd_ptr = first_bd_ptr = *bd;
	len = dma_buf_first(dbuf, &addr);
	do {
		last_bd_ptr = bd_ptr;
		dev_trace(&dma->pdev->dev, "dev %p, bd %p, addr %x, len %x, sw %p\n",
				dma, bd_ptr, (u32)addr, len, sw);
		XAxiDma_BdSetBufAddr(bd_ptr, addr);
		XAxiDma_BdSetLength(bd_ptr, len, ring->MaxTransferLen);
		XAxiDma_BdSetCtrl(bd_ptr, 0);
		XAxiDma_BdSetId(bd_ptr, (u32)sw);

		tcnt ++;
		kref_get(&sw->kref);
		len = dma_buf_next(dbuf, &addr);
		bd_ptr = XAxiDma_mBdRingNext(ring, bd_ptr);
	} while (len > 0);

	if (first_bd_ptr == last_bd_ptr) 
		sts |= XAXIDMA_BD_CTRL_TXEOF_MASK;
	else
		XAxiDma_BdSetCtrl(last_bd_ptr, XAXIDMA_BD_CTRL_TXEOF_MASK);
	XAxiDma_BdSetCtrl(first_bd_ptr, sts);
		
	return XAxiDma_BdRingToHw(ring, tcnt, first_bd_ptr, 0);
}

static int  aes_desc_to_hw(struct aes_dev *dma, struct aes_desc *sw)
{
	int res;
	unsigned long flags;

	/* aes_desc_to_hw rx/tx */
	spin_lock_irqsave(&rx_lock, flags);
	res = _aes_desc_to_hw(dma, &sw->dst_buf, &sw->rx_BdPtr,
			XAxiDma_GetRxRing(&dma->AxiDma, 0), "RX", sw);
	spin_unlock_irqrestore(&rx_lock, flags);
	if (res != 0) {
		dev_err(&dma->pdev->dev, "desc_to_hw dst err %d\n", res);
		return res;
	}

	spin_lock_irqsave(&tx_lock, flags);
	res = _aes_desc_to_hw(dma, &sw->src_buf, &sw->tx_BdPtr,
			XAxiDma_GetTxRing(&dma->AxiDma), "TX", sw);
	spin_unlock_irqrestore(&tx_lock, flags);
	if (res != 0) {
		dev_err(&dma->pdev->dev, "desc_to_hw src err %d\n", res);
		return res;
	}
	
	kref_put(&sw->kref, aes_free_desc);

	return 0;
}

static void aes_self_cb(void *priv)
{
	struct completion *done = priv;
	pr_debug("%s: done\n", __func__);
	complete(done);
}

static int aes_self_test(struct aes_dev *dma)
{
	char *src, *dst;
	dma_addr_t src_dma, dst_dma;
	struct aes_desc *sw;
	int res, i;
	unsigned long flags;
	struct completion done;

	/* alloc test memory */
	src = kzalloc(PAGE_SIZE, GFP_KERNEL);
	dst = kzalloc(PAGE_SIZE, GFP_KERNEL);
	if (src == NULL || dst == NULL) 
		return -ENOMEM;
	for (i = 0; i < PAGE_SIZE; i ++) 
		src[i] = i;

	src_dma = dma_map_single(&dma->pdev->dev, src, PAGE_SIZE, DMA_TO_DEVICE);
	dst_dma = dma_map_single(&dma->pdev->dev, dst, PAGE_SIZE, DMA_FROM_DEVICE);

	/* alloc desc */
	sw = aes_alloc_desc(dma);
	dev_trace(&dma->pdev->dev, "dev %p, sw %p, src %p/%x, dst %p/%x\n",
			dma, sw, src, (u32)src_dma, dst, (u32)dst_dma);

	init_completion(&done);
	sw->cb = aes_self_cb;
	sw->priv = (void *)&done;

	/* dma_buf_addr_init tx/rx */
	dma_buf_addr_init(&sw->src_buf, src_dma, 512);
	dma_buf_addr_init(&sw->dst_buf, dst_dma, PAGE_SIZE);

	aes_desc_to_hw(dma, sw);
	wait_for_completion(&done);

#if 0
	/* moving into aes_free_desc now, we need better way to handle it */
	dma_unmap_single(&dma->pdev->dev, src_dma, PAGE_SIZE, DMA_TO_DEVICE);
	dma_unmap_single(&dma->pdev->dev, dst_dma, PAGE_SIZE, DMA_FROM_DEVICE);
#endif

	print_hex_dump(KERN_DEBUG, "TX ", DUMP_PREFIX_ADDRESS, 16, 1,
			src, 256, 1);
	print_hex_dump(KERN_DEBUG, "RX ", DUMP_PREFIX_ADDRESS, 16, 1,
			dst, 256, 1);
	ring_dump(XAxiDma_GetRxRing(&dma->AxiDma, 0), "RX");
	ring_dump(XAxiDma_GetTxRing(&dma->AxiDma), "TX");

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

	dev_dbg(&dma->pdev->dev, "Tx:phy: 0x%llx, virt: %p, size: 0x%x\n",
			(uint64_t)dma->tx_bd_p, dma->tx_bd_v, dma->tx_bd_size);
	dev_dbg(&dma->pdev->dev, "Rx:phy: 0x%llx, virt: %p, size: 0x%x\n",
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

static void ring_dump(XAxiDma_BdRing *bd_ring, char *prefix)
{
	unsigned long flags;
	int num_bds = bd_ring->AllCnt;
	u32 *cur_bd_ptr = (u32 *) bd_ring->FirstBdAddr;
	int idx;
	
	/*spin_lock_irqsave(&ETH_spinlock, flags);*/
	printk("%s  ChanBase   : %p\n", prefix, (void *) bd_ring->ChanBase);
	printk("FirstBdPhysAddr: %p\n", (void *) bd_ring->FirstBdPhysAddr);
	printk("FirstBdAddr    : %p\n", (void *) bd_ring->FirstBdAddr);
	printk("LastBdAddr     : %p\n", (void *) bd_ring->LastBdAddr);
	printk("Length         : %d (0x%0x)\n", bd_ring->Length, bd_ring->Length);
	printk("RunState       : %d (0x%0x)\n", bd_ring->RunState, bd_ring->RunState);
	printk("Separation     : %d (0x%0x)\n", bd_ring->Separation, bd_ring->Separation);
	printk("BD Count       : %d\n", bd_ring->AllCnt);
	printk("\n");

	printk("FreeHead       : %p\n", (void *) bd_ring->FreeHead);
	printk("PreHead        : %p\n", (void *) bd_ring->PreHead);
	printk("HwHead         : %p\n", (void *) bd_ring->HwHead);
	printk("HwTail         : %p\n", (void *) bd_ring->HwTail);
	printk("PostHead       : %p\n", (void *) bd_ring->PostHead);
	printk("BdaRestart     : %p\n", (void *) bd_ring->BdaRestart);

	printk("\n");
	printk("CR             : %08x\n", XAxiDma_ReadReg(bd_ring->ChanBase, XAXIDMA_CR_OFFSET));
	printk("SR             : %08x\n", XAxiDma_ReadReg(bd_ring->ChanBase, XAXIDMA_SR_OFFSET));
	printk("CDESC          : %08x\n", XAxiDma_ReadReg(bd_ring->ChanBase, XAXIDMA_CDESC_OFFSET));
	printk("TDESC          : %08x\n", XAxiDma_ReadReg(bd_ring->ChanBase, XAXIDMA_TDESC_OFFSET));

	printk("\n");
	printk("Ring Contents:\n");

	dma_cache_sync(NULL, cur_bd_ptr, bd_ring->Length, DMA_FROM_DEVICE);
/*
* Buffer Descriptr
* word byte    description
* 0    0h      next ptr
* 1    4h      buffer addr
* 2    8h      buffer len
* 3    ch      sts/ctrl | app data (0) [tx csum enable (bit 31 LSB)]
* 4    10h     app data (1) [tx csum begin (bits 0-15 MSB) | csum insert (bits 16-31 LSB)]
* 5    14h     app data (2) [tx csum seed (bits 16-31 LSB)]
* 6    18h     app data (3) [rx raw csum (bits 16-31 LSB)]
* 7    1ch     app data (4) [rx recv length (bits 18-31 LSB)]
* 8    20h     sw app data (0) [id]
*/
	printk("Idx  NextBD  BuffAddr   CRTL    STATUS    APP0     APP1     APP2     APP3     APP4      ID\n");
	printk("--- -------- -------- -------- -------- -------- -------- -------- -------- -------- --------\n");
	for (idx = 0; idx < num_bds; idx++) {
	printk("%3d %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
		idx,
		cur_bd_ptr[XAXIDMA_BD_NDESC_OFFSET / sizeof(*cur_bd_ptr)],
		cur_bd_ptr[XAXIDMA_BD_BUFA_OFFSET / sizeof(*cur_bd_ptr)],
		cur_bd_ptr[XAXIDMA_BD_CTRL_LEN_OFFSET / sizeof(*cur_bd_ptr)],
		cur_bd_ptr[XAXIDMA_BD_STS_OFFSET / sizeof(*cur_bd_ptr)],
		cur_bd_ptr[XAXIDMA_BD_USR0_OFFSET / sizeof(*cur_bd_ptr)],
		cur_bd_ptr[XAXIDMA_BD_USR1_OFFSET / sizeof(*cur_bd_ptr)],
		cur_bd_ptr[XAXIDMA_BD_USR2_OFFSET / sizeof(*cur_bd_ptr)],
		cur_bd_ptr[XAXIDMA_BD_USR3_OFFSET / sizeof(*cur_bd_ptr)],
		cur_bd_ptr[XAXIDMA_BD_USR4_OFFSET / sizeof(*cur_bd_ptr)],
		cur_bd_ptr[XAXIDMA_BD_ID_OFFSET / sizeof(*cur_bd_ptr)]);
		cur_bd_ptr += bd_ring->Separation / sizeof(int);
	}
	printk("--------------------------------------- Done ---------------------------------------\n");	
	/*spin_unlock_irqrestore(&ETH_spinlock, flags);*/
}

static void _aes_tx_clean_bh(struct aes_dev *dma, XAxiDma_Bd *bd)
{
	struct aes_desc *sw = (struct aes_desc *)XAxiDma_BdGetId(bd);
	dev_trace(&dma->pdev->dev, "dma %p, bd %p, sw %p\n", dma, bd, sw);
	kref_put(&sw->kref, aes_free_desc);
}

static void _aes_rx_clean_bh(struct aes_dev *dma, XAxiDma_Bd *bd)
{
	struct aes_desc *sw = (struct aes_desc *)XAxiDma_BdGetId(bd);
	dev_trace(&dma->pdev->dev, "dma %p, bd %p, sw %p\n", dma, bd, sw);
	kref_put(&sw->kref, aes_free_desc);
}

static void tx_handle_bh(unsigned long p)
{
	struct aes_dev *dma;
	XAxiDma_Bd *BdPtr, *BdCurPtr;
	XAxiDma_BdRing *ring;
	unsigned long flags;
	int bd_processed, bd_processed_save, res;

	while (1) {
		spin_lock_irqsave(&tx_bh_lock, flags);
		if (list_empty(&tx_head)) {
			spin_unlock_irqrestore(&tx_bh_lock, flags);
			break;
		}

		dma = list_entry(tx_head.next, struct aes_dev, tx_entry);
		ring = XAxiDma_GetTxRing(&dma->AxiDma);

		list_del_init(&dma->tx_entry);
		spin_unlock_irqrestore(&tx_bh_lock, flags);
		
		spin_lock_irqsave(&tx_lock, flags);
		bd_processed_save = 0;
		while ((bd_processed = XAxiDma_BdRingFromHw(ring, TX_BD_NUM, &BdPtr)) > 0) {
			dev_trace(&dma->pdev->dev, "bd_processed %d, %p\n", bd_processed, BdPtr);

			bd_processed_save = bd_processed;
			BdCurPtr = BdPtr;
			do {
				_aes_tx_clean_bh(dma, BdCurPtr);

				XAxiDma_BdSetId(BdCurPtr, NULL);
				BdCurPtr = XAxiDma_mBdRingNext(ring, BdCurPtr);
				bd_processed = 0;
			} while (bd_processed > 0);

			res = XAxiDma_BdRingFree(ring, bd_processed_save, BdPtr);
			if (res != XST_SUCCESS) {
				dev_err(&dma->pdev->dev, "XAxiDma: BdRingFree err %d\n", res);
				/* TODO */
			}
		}

		XAxiDma_mBdRingIntEnable(ring, XAXIDMA_IRQ_ALL_MASK);
		spin_unlock_irqrestore(&tx_lock, flags);
	}
}

static void rx_handle_bh(unsigned long p)
{
	struct aes_dev *dma;
	XAxiDma_Bd *BdPtr, *BdCurPtr;
	XAxiDma_BdRing *ring;
	unsigned long flags;
	int bd_processed, bd_processed_save, res;

	while (1) {
		spin_lock_irqsave(&rx_bh_lock, flags);
		if (list_empty(&rx_head)) {
			spin_unlock_irqrestore(&rx_bh_lock, flags);
			break;
		}

		dma = list_entry(rx_head.next, struct aes_dev, rx_entry);
		ring = XAxiDma_GetRxRing(&dma->AxiDma, 0);

		list_del_init(&dma->rx_entry);
		spin_unlock_irqrestore(&rx_bh_lock, flags);
		
		spin_lock_irqsave(&rx_lock, flags);
		bd_processed_save = 0;
		while ((bd_processed = XAxiDma_BdRingFromHw(ring, RX_BD_NUM, &BdPtr)) > 0) {
			dev_trace(&dma->pdev->dev, "bd_processed %d, %p\n", bd_processed, BdPtr);

			bd_processed_save = bd_processed;
			BdCurPtr = BdPtr;
			do {
				_aes_rx_clean_bh(dma, BdCurPtr);

				XAxiDma_BdSetId(BdCurPtr, NULL);
				BdCurPtr = XAxiDma_mBdRingNext(ring, BdCurPtr);
				bd_processed = 0;
			} while (bd_processed > 0);

			res = XAxiDma_BdRingFree(ring, bd_processed_save, BdPtr);
			if (res != XST_SUCCESS) {
				dev_err(&dma->pdev->dev, "XAxiDma: BdRingFree err %d\n", res);
				/* TODO */
			}
		}

		XAxiDma_mBdRingIntEnable(ring, XAXIDMA_IRQ_ALL_MASK);
		spin_unlock_irqrestore(&rx_lock, flags);
	}
}

DECLARE_TASKLET(tx_bh, tx_handle_bh, 0);
DECLARE_TASKLET(rx_bh, rx_handle_bh, 0);

static int aes_tx_isr(struct aes_dev *dma, u32 sts)
{
	XAxiDma_BdRing *ring = XAxiDma_GetTxRing(&dma->AxiDma);
	XAxiDma_BdRing *rx_ring = XAxiDma_GetRxRing(&dma->AxiDma, 0);
	
	/* clear ring irq */
	XAxiDma_mBdRingAckIrq(ring, sts);
	if (sts & XAXIDMA_ERR_ALL_MASK) {
		dev_err(&dma->pdev->dev, "TXIRQ error sts %08x\n", sts);
		ring_dump(rx_ring, "RX");
		ring_dump(ring,    "TX");
		/* TODO */
		return IRQ_HANDLED;
	}

	if (sts & (XAXIDMA_IRQ_DELAY_MASK | XAXIDMA_IRQ_IOC_MASK)) {
		unsigned long flags;
		struct list_head *cur_dma;

		spin_lock_irqsave(&tx_bh_lock, flags);
		list_for_each(cur_dma, &tx_head) {
			if (cur_dma == &(dma->tx_entry))
				break;
		}
		if (cur_dma != &(dma->tx_entry)) {
			list_add_tail(&dma->tx_entry, &tx_head);
			XAxiDma_mBdRingIntDisable(ring, XAXIDMA_IRQ_ALL_MASK);
			tasklet_schedule(&tx_bh);
		}
		
		spin_unlock_irqrestore(&tx_bh_lock, flags);
	}

	return IRQ_HANDLED;
}

static int aes_rx_isr(struct aes_dev *dma, u32 sts)
{
	XAxiDma_BdRing *ring = XAxiDma_GetRxRing(&dma->AxiDma, 0);
	XAxiDma_BdRing *tx_ring = XAxiDma_GetTxRing(&dma->AxiDma);
	
	/* clear ring irq */
	XAxiDma_mBdRingAckIrq(ring, sts);
	if (sts & XAXIDMA_ERR_ALL_MASK) {
		dev_err(&dma->pdev->dev, "RXIRQ error sts %08x\n", sts);
		ring_dump(ring,    "RX");
		ring_dump(tx_ring, "TX");
		/* TODO */
		return IRQ_HANDLED;
	}

	if (sts & (XAXIDMA_IRQ_DELAY_MASK | XAXIDMA_IRQ_IOC_MASK)) {
		unsigned long flags;
		struct list_head *cur_dma;

		spin_lock_irqsave(&rx_bh_lock, flags);
		list_for_each(cur_dma, &rx_head) {
			if (cur_dma == &(dma->rx_entry))
				break;
		}
		if (cur_dma != &(dma->rx_entry)) {
			list_add_tail(&dma->rx_entry, &rx_head);
			XAxiDma_mBdRingIntDisable(ring, XAXIDMA_IRQ_ALL_MASK);
			tasklet_schedule(&rx_bh);
		}
		
		spin_unlock_irqrestore(&rx_bh_lock, flags);
	}

	return IRQ_HANDLED;
}

static irqreturn_t aes_isr(int irq, void *dev_id)
{
	struct aes_dev *dma = (struct aes_dev *)dev_id;
	XAxiDma_BdRing *RxRing, *TxRing;
	u32 IrqStsTx, IrqStsRx;
	irqreturn_t res = IRQ_NONE;

	RxRing = XAxiDma_GetRxRing(&dma->AxiDma, 0);
	TxRing = XAxiDma_GetTxRing(&dma->AxiDma);
	IrqStsTx = XAxiDma_ReadReg(TxRing->ChanBase, XAXIDMA_SR_OFFSET);
	IrqStsRx = XAxiDma_ReadReg(RxRing->ChanBase, XAXIDMA_SR_OFFSET);

	dev_trace(&dma->pdev->dev, "IrqSts: %08x/%08x.\n",IrqStsTx, IrqStsRx);
	if (((IrqStsTx | IrqStsRx) & XAXIDMA_IRQ_ALL_MASK) == 0) 
		goto out;

	if (IrqStsTx & XAXIDMA_IRQ_ALL_MASK) 
		res = aes_tx_isr(dma, IrqStsTx);

	if (IrqStsRx & XAXIDMA_IRQ_ALL_MASK) 
		res = aes_rx_isr(dma, IrqStsRx);

out:
	return res;
}

/* TODO only support one pcie device for now */
static struct aes_dev *_dma;

int aes_submit(struct scatterlist *src_sg, int src_cnt, int src_sz,
		struct scatterlist *dst_sg, int dst_cnt, int dst_sz,
		aes_cb_t cb, char *priv, uint32_t *key)
{	
	struct aes_desc *sw;
	struct aes_dev *dma = _dma;
	int cnt;
	unsigned long flags;

	pr_debug("%s: _dma %p\n", __func__, _dma);
	if (_dma == NULL)
		return -ENODEV;

	cnt = dma_map_sg(&dma->pdev->dev, src_sg, src_cnt, DMA_TO_DEVICE);
	if (cnt == 0) {
		dev_err(&dma->pdev->dev, "dma_map_sg src failed, %d,%d\n",
				src_cnt, cnt);
		return -ENOMEM;
	}
	cnt = dma_map_sg(&dma->pdev->dev, dst_sg, dst_cnt, DMA_FROM_DEVICE);
	if (cnt == 0) {
		dev_err(&dma->pdev->dev, "dma_map_sg dst failed, %d,%d\n",
				dst_cnt, cnt);
		return -ENOMEM;
	}
	sw = aes_alloc_desc(dma);
	dev_trace(&dma->pdev->dev, "dev %p, sw %p, src %p/%d, dst %p/%d\n",
			dma, sw, src_sg, src_cnt, dst_sg, dst_cnt);
	sw->cb = cb;
	sw->priv = priv;

	dma_buf_sg_init(&sw->src_buf, src_sg, src_cnt, src_sz);
	dma_buf_sg_init(&sw->dst_buf, dst_sg, dst_cnt, dst_sz);

	return aes_desc_to_hw(dma, sw);
}

EXPORT_SYMBOL(aes_submit);

static int aes_probe(struct pci_dev *pdev, 
		const struct pci_device_id *id)
{
	int err;
	struct aes_dev *dma;
	XAxiDma_Config Config;

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

	Config.BaseAddr   = dma->reg;
	Config.DeviceId   = 0xe001;
	Config.HasMm2S    = 1;
	Config.HasMm2SDRE = 0;
	Config.HasS2Mm    = 1;
	Config.HasS2MmDRE = 0;
	Config.HasSg      = 1;
	Config.HasStsCntrlStrm = 1;
	Config.Mm2SDataWidth   = 128;
	Config.Mm2sNumChannels = 1;
	Config.S2MmDataWidth   = 128;
	Config.S2MmNumChannels = 1;

	XAxiDma_WriteReg(dma->reg, XAXIDMA_TX_OFFSET + XAXIDMA_CR_OFFSET, XAXIDMA_CR_RESET_MASK);
	XAxiDma_WriteReg(dma->reg, XAXIDMA_RX_OFFSET + XAXIDMA_CR_OFFSET, XAXIDMA_CR_RESET_MASK);

	err = XAxiDma_CfgInitialize(&dma->AxiDma, &Config);
	if (err != XST_SUCCESS) {
		dev_err(&pdev->dev, "Cfg initialize failed %d\n", err);
		goto err_ioremap;
	}

	err = aes_desc_init(dma);
	if (err != 0) 
		goto err_ioremap;

	err = request_irq(dma->pdev->irq, aes_isr, IRQF_SHARED, DRIVER_NAME,
			dma);
	if (err) {
		dev_err(&pdev->dev, "request irq failed %d\n", err);
		goto err_ioremap;
	}


	XAxiDma_mBdRingIntEnable(XAxiDma_GetRxRing(&dma->AxiDma, 0), XAXIDMA_IRQ_ALL_MASK);
	XAxiDma_mBdRingIntEnable(XAxiDma_GetTxRing(&dma->AxiDma), XAXIDMA_IRQ_ALL_MASK);
	err = XAxiDma_BdRingStart(XAxiDma_GetRxRing(&dma->AxiDma, 0), 0);
	if (err != XST_SUCCESS) {
		dev_err(&pdev->dev, "start rx ring failed %d\n", err);
		goto err_ioremap;
	}

	err = XAxiDma_BdRingStart(XAxiDma_GetTxRing(&dma->AxiDma), 0);
	if (err != XST_SUCCESS) {
		dev_err(&pdev->dev, "start tx ring failed %d\n", err);
		goto err_ioremap;
	}

	aes_self_test(dma);
	_dma = dma;

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

	XAxiDma_mBdRingIntDisable(XAxiDma_GetTxRing(&dma->AxiDma), XAXIDMA_IRQ_ALL_MASK);
	XAxiDma_mBdRingIntDisable(XAxiDma_GetRxRing(&dma->AxiDma, 0), XAXIDMA_IRQ_ALL_MASK);

	AxiDma_Stop(dma->reg);
	free_irq(pdev->irq, dma);
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
	spin_lock_init(&tx_bh_lock);
	spin_lock_init(&rx_bh_lock);

	INIT_LIST_HEAD(&tx_head);
	INIT_LIST_HEAD(&rx_head);

	aes_desc_cache = kmem_cache_create("aes_desc_cache",
			sizeof(struct aes_desc),
			0, 0, NULL);

	return pci_register_driver(&aes_driver);
}

static void __exit aes_exit(void)
{
	pci_unregister_driver(&aes_driver);
	kmem_cache_destroy(aes_desc_cache);
}

module_init(aes_init);
module_exit(aes_exit);

MODULE_DESCRIPTION("AES10G HBA Linux driver");
MODULE_AUTHOR("Hu Gang");
MODULE_LICENSE("GPL");
MODULE_VERSION(GITVERSION);
