#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <malloc.h>
#include <stdarg.h>
#include <arpa/inet.h>

#include "oschip_api.h"
#include "xil_types.h"
#include "xbasic_types.h"
#include "xaxidma.h"
#include "xaxidma_bdring.h"
#include "xdebug.h"

#include "axi_mm_systemc.h"

typedef uint32_t __le32;

//#include "mu_hw.h"

#define fmTraceFuncEnter(I)						\
	fprintf(tfile, "%s %8s:%04d enter %s\n", systemc_time(), __FILE__,  __LINE__, __FUNCTION__); \
	fflush(tfile)
#define fmTraceFuncExit(R,I)  \
	fprintf(tfile, "%s %8s:%04d exit %s(%c)\n",systemc_time(), __FILE__, __LINE__, __FUNCTION__, R); \
	fflush(tfile);
#define fmTrace(U,V) \
	fprintf(tfile, "%s %8s:%04d %s %08x\n", systemc_time(), __FILE__, __LINE__, #V, (uint32_t)V); \
	fflush(tfile);

FILE *tfile;
FILE *sfile;

unsigned char *mem0;
size_t mem_size;

static int rdma_test(uint32_t base);
/* Timeout loop counter for reset
 */
#define RESET_TIMEOUT_COUNTER	10000

#define MAX_PKT_LEN		0x100

#define PKTS_TO_TRANSFER			30

#define NUMBER_OF_BDS_PER_PKT		1
#define NUMBER_OF_PKTS_TO_TRANSFER 	2
#define NUMBER_OF_BDS_TO_TRANSFER	(NUMBER_OF_PKTS_TO_TRANSFER * \
						NUMBER_OF_BDS_PER_PKT)
#define TIME 	20
#define TOTAL_NUM 1

/* The interrupt coalescing threshold and delay timer threshold
 * Valid range is 1 to 255
 *
 * We set the coalescing threshold to be the total number of packets.
 * The receive side will only get one completion interrupt for this example.
 */
#define COALESCING_COUNT		1
#define DELAY_TIMER_COUNT		1

#define TX_BD_CNT	10
#define RX_BD_CNT	10
#define SIZE 		256

enum {
	IRQ_ISR = 0x00,
	IRQ_IPR = 0x04,
	IRQ_IER = 0x08,
	IRQ_IAR = 0x0C,
	IRQ_MER = 0x1C,
};
static uint32_t intc_base = 0x42000000;

volatile int TxDone;
volatile int RxDone;
volatile int Error;

typedef struct axi_dma_device axi_dma_device;
struct axi_dma_device {

	XAxiDma AxiDma;

	u32 axi_base;
	u32 axi_len;
	u32 *reg_base;
	int irq;

	u32 *tx_desc_virt;
	u32 tx_desc_phys;
	int tx_desc_size;
	
	u32 *rx_desc_virt;
	u32 rx_desc_phys;
	int rx_desc_size;

	u32 *page_src[TX_BD_CNT];
	u32 *page_dst[RX_BD_CNT];
	u32 dma_src[TX_BD_CNT];
	u32 dma_dst[RX_BD_CNT];	
};

static XAxiDma_Config *AxiDma_Config(u32 reg_base)
{
	static XAxiDma_Config Cfg;
	XAxiDma_Config *CfgPtr = &Cfg;
	
	CfgPtr->BaseAddr = reg_base;
	CfgPtr->DeviceId = 0x0004;
	CfgPtr->HasMm2S = 1;
	CfgPtr->HasMm2SDRE = 1;
	CfgPtr->HasS2Mm = 1;
	CfgPtr->HasS2MmDRE = 1;
	CfgPtr->HasSg = 1;
	CfgPtr->HasStsCntrlStrm = 1;
	CfgPtr->Mm2SDataWidth = 64;
	CfgPtr->Mm2sNumChannels = 1;
	CfgPtr->S2MmDataWidth = 64;
	CfgPtr->S2MmNumChannels = 1;

	return CfgPtr;
}

static int axi_dma_mem_alloc(struct axi_dma_device *dma_dev);
static int TxSetup(struct axi_dma_device *dma_dev);
static int RxSetup(struct axi_dma_device *dma_dev);
static int SendPacket(struct axi_dma_device *dma_dev);

static int SendArp(struct axi_dma_device *dma_dev);

enum {
	MDIO_CFG0 = 0x500,
	MDIO_CFG1 = 0x504,
	MDIO_TXD  = 0x508,
	MDIO_RXD  = 0x50C,
};

static uint32_t mac_base = 0x41250000;

static int mdio_write_reg(uint32_t prtad, uint32_t devad, uint32_t regad, uint32_t val)
{
	int res;
	axi_mm_out32(mac_base + MDIO_TXD,  regad);
	axi_mm_out32(mac_base + MDIO_CFG1, 0x0800 |(devad<<16)|(prtad<<24));
	do {
		res = axi_mm_in32 (mac_base + MDIO_CFG1);
		printf("poll bit7 %08x\n", res);
	} while ((res & (1<<7)) == 0);
	axi_mm_out32(mac_base + MDIO_TXD,  0xffff);
	axi_mm_out32(mac_base + MDIO_CFG1, 0x4800 |(devad<<16)|(prtad<<24));
	do {
		res = axi_mm_in32 (mac_base + MDIO_CFG1);
		printf("poll bit7 %08x\n", res);
	} while ((res & (1<<7)) == 0);
}

int osChip_init(uint32_t base)
{
	int err = 0, res;
	mem_size = 32*1024*1024;
	mem0 = (unsigned char*)memalign(mem_size, mem_size);
	tfile = fopen("rdma.log", "w+b");

	axi_dma_device *dma_dev;
	XAxiDma_Config *Config;
	u32 i;
	unsigned long start, end, stop, total_count;
	long diff, msec, kbyte_per_sec;

	/*Probe       */
	dma_dev = (axi_dma_device *)(mem0 + 0x7000000);

	dma_dev->axi_base = base/*bar0 addr*/;
	dma_dev->axi_len = 0x10000/*bar0 len*/;
	dma_dev->reg_base = (u32 *)base;
	printf("base 0x%x, size 0x%x, mmr 0x%lx\n",
			dma_dev->axi_base, dma_dev->axi_len, (unsigned long)dma_dev->reg_base);


	Config = AxiDma_Config((u32)(dma_dev->reg_base));
	/* Initialize DMA engine */
	err = XAxiDma_CfgInitialize(&dma_dev->AxiDma, Config);
	if (err != XST_SUCCESS) {
		printf("Cfg error!\n");
	}
	printf("Cfg pass!\n");

#if 1
	axi_mm_out32(intc_base + IRQ_MER, 0);
	axi_mm_out32(intc_base + IRQ_IER, 0xffffffff);
	axi_mm_out32(intc_base + IRQ_IAR, 0xffffffff);
	axi_mm_out32(intc_base + IRQ_MER, 3);
#endif
#if 1
	/* Cfg word 0 */
	axi_mm_out32(mac_base + MDIO_CFG0, (1<<6)|1);
	/* turn on tx disable 1.9.0  */
	//mdio_write_reg(0x0, 0x1, 0x9, 0x1);
	//mdio_write_reg(0x0, 0x1, 0x9, 0x0);
	/* reset the pma/pcs  3.0.15 */
	//mdio_write_reg(0x0, 0x3, 0x0, 0x1<<15);
	/* turn off tx disable 1.9.0  */
	//mdio_write_reg(0x0, 0x1, 0x9, 0x0);
	/* XAxiDma_Reset(&dma_dev->AxiDma);*/
#endif
	if(!XAxiDma_HasSg(&dma_dev->AxiDma)) {
		printf("Device configured as Simple mode \n");
		return 1;
	}
        /*axi_dma_mem_alloc*/
	err = axi_dma_mem_alloc(dma_dev);

	if (err != XST_SUCCESS) {
		printf("Failed mem alloc\n");
	}
	printf("alloc mem ok!\n");

	err = TxSetup(dma_dev);
	if (err != XST_SUCCESS) {
		printf("Failed TX setup\n");
	}
	printf("Tx  ok!\n");

	err = RxSetup(dma_dev);
	if (err != XST_SUCCESS) {
		printf("Failed RX setup\n");
	}
	printf("Rx  ok!\n");

	/* testing mac register read */
	uint32_t macbase = mac_base + 0x4F8;
	printf("verstion %08x\n", axi_mm_in32(macbase));

	/* Initialize flags before start transfer test  */
	TxDone = 0;
	RxDone = 0;
	Error = 0;

	for (i = 0; i < TOTAL_NUM; i++) {
		unsigned long flags;

		/* Send a packet */
		err = SendPacket(dma_dev);
		
		if (err != XST_SUCCESS) {
			printf("Failed send packet %d\n", i);
			return XST_FAILURE;
		}
		TxDone = 0;
		RxDone = 0;
	}

	return 0;
}

static int axi_dma_mem_alloc(struct axi_dma_device *dma_dev)
{
	u32 Bdsize, i, j;
	u32 **page_dst;
	u32 **page_src;
	unsigned char *ptr;
	
	/* Setup Tx BD size  base addr 0x1010000*/
	Bdsize = XAxiDma_mBdRingMemCalc(XAXIDMA_BD_MINIMUM_ALIGNMENT,TX_BD_CNT);
	
	dma_dev->tx_desc_virt = (u32 *) (mem0 + 0x1010000);
	dma_dev->tx_desc_size = Bdsize;

	/* Setup Rx BD size  base addr 0x1020000*/
	Bdsize = XAxiDma_mBdRingMemCalc(XAXIDMA_BD_MINIMUM_ALIGNMENT,RX_BD_CNT);
	dma_dev->rx_desc_size = Bdsize;
	dma_dev->rx_desc_virt = (u32 *) (mem0 + 0x1020000);
	
	dma_dev->tx_desc_phys = (char *)dma_dev->tx_desc_virt - (char *)mem0;
	dma_dev->rx_desc_phys = (char *)dma_dev->rx_desc_virt - (char *)mem0;
	printf("dma_dev->tx_desc_virt : %x, phy %x\n", dma_dev->tx_desc_virt,
			dma_dev->tx_desc_phys);
	printf("dma_dev->rx_desc_virt : %x, phy %x\n", dma_dev->rx_desc_virt,
			dma_dev->rx_desc_phys);

	/*Alloc page for RX data base_offset 0x200000*/
	page_dst = dma_dev->page_dst;
	for (i = 0 ; i < RX_BD_CNT; i++) {
		page_dst[i] = (u32 *) (mem0 + 0x200000 + i*0x1000);
		printf("page_dst [%d]: %x\n", i, page_dst[i]);
	}
	for (i = 0 ; i < RX_BD_CNT; i++) {
		ptr = (unsigned char *) dma_dev->page_dst[i];
		for (j = 0; j < SIZE; j++) {
			ptr[j] = 0xff;
		}	
		dma_dev->dma_dst[i] = ((u32)dma_dev -> page_dst[i] - (u32)mem0); 
		printf("dma_dev->dma_dst [%d]: %x\n", i,  dma_dev->dma_dst[i]);
	}
	
	/*Alloc page for TX data base_offset 0x100000*/
	page_src = dma_dev->page_src;
	for (i = 0 ; i < RX_BD_CNT; i++) {
		page_src[i] = (u32 *) (mem0 + 0x100000 + i*0x1000);
		printf("page_src [%d]: %x\n", i, page_src[i]);
	}
	for (i = 0 ; i < TX_BD_CNT; i++) {
		ptr = (unsigned char *) dma_dev->page_src[i];
		for (j = 0; j < SIZE; j++) {
			ptr[j] = j;
		}	
		dma_dev->dma_src[i] = ((u32)dma_dev -> page_src[i] - (u32)mem0); 
		printf("dma_dev->dma_src [%d]: %x\n", i,  dma_dev->dma_src[i]);
	}
	return 0;
}

static int TxSetup(struct axi_dma_device *dma_dev)
{
	XAxiDma *AxiDmaInstPtr = &dma_dev->AxiDma;
	XAxiDma_BdRing *TxRingPtr = XAxiDma_GetTxRing(AxiDmaInstPtr);
	XAxiDma_Bd BdTemplate;
	XAxiDma_Bd *BdCurPtr;
	int Status;
	int RingIndex = 0;

	/* Disable all TX interrupts before TxBD space setup */
	XAxiDma_mBdRingIntDisable(TxRingPtr, XAXIDMA_IRQ_ALL_MASK);

	Status = XAxiDma_BdRingCreate(TxRingPtr, dma_dev->tx_desc_phys,
				     (u32)dma_dev->tx_desc_virt,
				     XAXIDMA_BD_MINIMUM_ALIGNMENT, TX_BD_CNT);
	if (Status != XST_SUCCESS) {
		printf("Failed create BD ring, status %d\n", Status);
		return XST_FAILURE;
	}

	/*
	 * Like the RxBD space, we create a template and set all BDs to be the
	 * same as the template. The sender has to set up the BDs as needed.
	 */
	XAxiDma_BdClear(&BdTemplate);
	Status = XAxiDma_BdRingClone(TxRingPtr, &BdTemplate);
	if (Status != XST_SUCCESS) {

		printf("Failed clone BDs, status %d\n", Status);
		return XST_FAILURE;
	}

	/*
	 * Set the coalescing threshold, so only one transmit interrupt
	 * occurs for this example
	 *
	 * If you would like to have multiple interrupts to happen, change
	 * the COALESCING_COUNT to be a smaller value
	 */
	Status = XAxiDma_BdRingSetCoalesce(TxRingPtr, COALESCING_COUNT,
			DELAY_TIMER_COUNT);
	if (Status != XST_SUCCESS) {
		printf("Failed set coalescing"
		" %d/%d, Status %d\n",COALESCING_COUNT, DELAY_TIMER_COUNT, Status);
		return XST_FAILURE;
	}

	/* Enable all TX interrupts */
	XAxiDma_mBdRingIntEnable(TxRingPtr, XAXIDMA_IRQ_ALL_MASK);

	/* Start the TX channel */
	Status = XAxiDma_BdRingStart(TxRingPtr, RingIndex);
	if (Status != XST_SUCCESS) {

		printf("Failed bd start\n");
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

static int RxSetup(struct axi_dma_device *dma_dev)
{
	XAxiDma_BdRing *RxRingPtr;
	int Status;
	XAxiDma_Bd BdTemplate;
	XAxiDma_Bd *BdPtr;
	XAxiDma_Bd *BdCurPtr;
	int FreeBdCount;
	u32 RxBufferPtr;
	int Index;
	int RingIndex = 0;
	XAxiDma *AxiDmaInstPtr = &dma_dev->AxiDma;

	RxRingPtr = XAxiDma_GetRxRing(AxiDmaInstPtr, RingIndex);

	/* Disable all RX interrupts before RxBD space setup */
	XAxiDma_mBdRingIntDisable(RxRingPtr, XAXIDMA_IRQ_ALL_MASK);

	Status = XAxiDma_BdRingCreate(RxRingPtr, dma_dev->rx_desc_phys,
					(u32)dma_dev->rx_desc_virt,
					XAXIDMA_BD_MINIMUM_ALIGNMENT, RX_BD_CNT);
	if (Status != XST_SUCCESS) {
		printf("Rx bd create failed with %d\n", Status);
		return XST_FAILURE;
	}

	/*
	 * Setup a BD template for the Rx channel. Then copy it to every RX BD.
	 */
	XAxiDma_BdClear(&BdTemplate);
	Status = XAxiDma_BdRingClone(RxRingPtr, &BdTemplate);
	if (Status != XST_SUCCESS) {
		printf("Rx bd clone failed with %d\n", Status);
		return XST_FAILURE;
	}

	/* Attach buffers to RxBD ring so we are ready to receive packets */
	FreeBdCount = XAxiDma_mBdRingGetFreeCnt(RxRingPtr);

	Status = XAxiDma_BdRingAlloc(RxRingPtr, FreeBdCount, &BdPtr);
	if (Status != XST_SUCCESS) {
		printf("Rx bd alloc failed with %d\n", Status);
		return XST_FAILURE;
	}

	BdCurPtr = BdPtr;
	RxBufferPtr = dma_dev->dma_dst[0];
	
	for (Index = 0; Index < FreeBdCount; Index++) {

		Status = XAxiDma_BdSetBufAddr(BdCurPtr, RxBufferPtr);
		if (Status != XST_SUCCESS) {
			printf("Rx set buffer addr %x on BD %x failed %d\n",
			(unsigned int)RxBufferPtr,
			(unsigned int)BdCurPtr, Status);

			return XST_FAILURE;
		}

		Status = XAxiDma_BdSetLength(BdCurPtr, SIZE,
					RxRingPtr->MaxTransferLen);
		if (Status != XST_SUCCESS) {
			printf("Rx set length %d on BD %x failed %d\n",
			    SIZE, (unsigned int)BdCurPtr, Status);

			return XST_FAILURE;
		}

		/* Receive BDs do not need to set anything for the control
		 * The hardware will set the SOF/EOF bits per stream status
		 */
		XAxiDma_BdSetCtrl(BdCurPtr, RingIndex);

		XAxiDma_BdSetId(BdCurPtr, RxBufferPtr);
		
		XAxiDma_DumpBd(BdCurPtr);

		RxBufferPtr = dma_dev->dma_dst[Index + 1];
		BdCurPtr = XAxiDma_mBdRingNext(RxRingPtr, BdCurPtr);
	}

	/*
	 * Set the coalescing threshold, so only one receive interrupt
	 * occurs for this example
	 *
	 * If you would like to have multiple interrupts to happen, change
	 * the COALESCING_COUNT to be a smaller value
	 */
	Status = XAxiDma_BdRingSetCoalesce(RxRingPtr, COALESCING_COUNT,
			DELAY_TIMER_COUNT);
	if (Status != XST_SUCCESS) {
		printf("Rx set coalesce failed with %d\n", Status);
		return XST_FAILURE;
	}

	Status = XAxiDma_BdRingToHw(RxRingPtr, FreeBdCount, BdPtr, RingIndex);
	if (Status != XST_SUCCESS) {
		printf("Rx ToHw failed with %d\n", Status);
		return XST_FAILURE;
	}

	/* Enable all RX interrupts */
	XAxiDma_mBdRingIntEnable(RxRingPtr, XAXIDMA_IRQ_ALL_MASK);

	/* Start RX DMA channel */
	Status = XAxiDma_BdRingStart(RxRingPtr, RingIndex);
	if (Status != XST_SUCCESS) {
		printf("Rx start BD ring failed with %d\n", Status);
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

static int SendPacket(struct axi_dma_device *dma_dev)
{
	XAxiDma *AxiDmaInstPtr = &dma_dev->AxiDma;
	XAxiDma_BdRing *TxRingPtr = XAxiDma_GetTxRing(AxiDmaInstPtr);
	XAxiDma_Bd *BdPtr, *BdCurPtr;
	int Status;
	int Index, Pkts;
	u32 BufferAddr;
	int RingIndex = 0;

	/*
	 * Each packet is limited to TxRingPtr->MaxTransferLen
	 *
	 * This will not be the case if hardware has store and forward built in
	 */
	if (SIZE * NUMBER_OF_BDS_PER_PKT > 
			TxRingPtr->MaxTransferLen) {

		printf("Invalid total per packet transfer length for the "
		    "packet %ld/%d\n",
		    SIZE * NUMBER_OF_BDS_PER_PKT,
		    TxRingPtr->MaxTransferLen);

		return XST_INVALID_PARAM;
	}
	//printf("%s--%d, %d\n", __func__, __LINE__, TxRingPtr->FreeCnt);
	Status = XAxiDma_BdRingAlloc(TxRingPtr, NUMBER_OF_BDS_TO_TRANSFER,
								&BdPtr);
								
	if (Status != XST_SUCCESS) {

		printf("Failed bd alloc\n");
		return XST_FAILURE;
	}

	BufferAddr = dma_dev->dma_src[0];
	BdCurPtr = BdPtr;
	/*
	 * Set up the BD using the information of the packet to transmit
	 * Each transfer has NUMBER_OF_BDS_PER_PKT BDs
	 */
	for(Index = 0; Index < NUMBER_OF_PKTS_TO_TRANSFER; Index++) {

		for(Pkts = 0; Pkts < NUMBER_OF_BDS_PER_PKT; Pkts++) {
			u32 CrBits = 0;

			Status = XAxiDma_BdSetBufAddr(BdCurPtr, BufferAddr);
			if (Status != XST_SUCCESS) {
				printf("Tx set buffer addr %x on BD %x failed %d\n",
				(unsigned int)BufferAddr,
				(unsigned int)BdCurPtr, Status);

				return XST_FAILURE;
			}

			Status = XAxiDma_BdSetLength(BdCurPtr, SIZE,
						TxRingPtr->MaxTransferLen);
			if (Status != XST_SUCCESS) {
				printf("Tx set length %ld on BD %x failed %d\n",
				SIZE, (unsigned int)BdCurPtr, Status);

				return XST_FAILURE;
			}

			if (Pkts == 0) {
				/* The first BD has SOF set
				 */
				CrBits |= XAXIDMA_BD_CTRL_TXSOF_MASK;

			}

			if(Pkts == (NUMBER_OF_BDS_PER_PKT - 1)) {
				/* The last BD should have EOF and IOC set
				 */
				CrBits |= XAXIDMA_BD_CTRL_TXEOF_MASK;
			}

			XAxiDma_BdSetCtrl(BdCurPtr, CrBits);
			XAxiDma_BdSetId(BdCurPtr, BufferAddr);

			BufferAddr = dma_dev->dma_src[NUMBER_OF_BDS_PER_PKT*Index + 1];
			BdCurPtr = XAxiDma_mBdRingNext(TxRingPtr, BdCurPtr);
		}
	}
//	printf("ready to bdringtohw\n");
	/* Give the BD to hardware */
	Status = XAxiDma_BdRingToHw(TxRingPtr, NUMBER_OF_BDS_TO_TRANSFER,
						BdPtr, RingIndex);
	if (Status != XST_SUCCESS) {

		printf("Failed to hw, length %d\n",
			(int)XAxiDma_BdGetLength(BdPtr,
					TxRingPtr->MaxTransferLen));

		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

static int SendArp(struct axi_dma_device *dma_dev)
{
	XAxiDma *AxiDmaInstPtr = &dma_dev->AxiDma;
	XAxiDma_BdRing *TxRingPtr = XAxiDma_GetTxRing(AxiDmaInstPtr);
	XAxiDma_Bd *BdPtr, *BdCurPtr;
	int Status;
	int Index, Pkts;
	u32 BufferAddr;
	int RingIndex = 0;
	u32 CrBits = 0;

	Status = XAxiDma_BdRingAlloc(TxRingPtr, 1, &BdPtr);
	if (Status != XST_SUCCESS) {
		printf("Failed bd alloc\n");
		return XST_FAILURE;
	}

	u8 *dbuf  = (u8 *)dma_dev->page_src[0];
	/* dst */
	dbuf[0] = 0xff;
	dbuf[1] = 0xff;
	dbuf[2] = 0xff;
	dbuf[3] = 0xff;
	dbuf[4] = 0xff;
	dbuf[5] = 0xff;
	/* src */
	dbuf[6] = 0x01;
	dbuf[7] = 0x02;
	dbuf[8] = 0x03;
	dbuf[9] = 0x04;
	dbuf[10]= 0x05;
	dbuf[11]= 0x06;
	/* arp header */
	BufferAddr = dma_dev->dma_src[0];
	BdCurPtr = BdPtr;
	/*
	 * Set up the BD using the information of the packet to transmit
	 * Each transfer has NUMBER_OF_BDS_PER_PKT BDs
	 */
	Status = XAxiDma_BdSetBufAddr(BdCurPtr, BufferAddr);
	if (Status != XST_SUCCESS) {
		printf("Tx set buffer addr %x on BD %x failed %d\n",
				(unsigned int)BufferAddr, (unsigned int)BdCurPtr, Status);
		return XST_FAILURE;
	}

	Status = XAxiDma_BdSetLength(BdCurPtr, SIZE, TxRingPtr->MaxTransferLen);
	if (Status != XST_SUCCESS) {
		printf("Tx set length %ld on BD %x failed %d\n",
				SIZE, (unsigned int)BdCurPtr, Status);

		return XST_FAILURE;
	}
	CrBits  = XAXIDMA_BD_CTRL_TXSOF_MASK;
	CrBits |= XAXIDMA_BD_CTRL_TXEOF_MASK;

	XAxiDma_BdSetCtrl(BdCurPtr, CrBits);
	XAxiDma_BdSetId(BdCurPtr, BufferAddr);

	/* Give the BD to hardware */
	Status = XAxiDma_BdRingToHw(TxRingPtr, 1, BdPtr, RingIndex);
	if (Status != XST_SUCCESS) {
		printf("Failed to hw, length %d\n",
			(int)XAxiDma_BdGetLength(BdPtr, TxRingPtr->MaxTransferLen));
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

int osChip_interrupt(uint32_t base)
{	
	fmTraceFuncEnter("ab");
	fmTraceFuncExit('a', "aa");
}
