#ifndef MAC_REGS_H_
#define MAC_REGS_H_

/***************************** Include Files *********************************/

#include <linux/kernel.h>
#include <linux/delay.h>
#include <asm/io.h>


#include "xio.h"
#include "xdebug.h"


/* 	0x0000~0x3FFF		PCI Express Avalon-MM Bridge Control Register
 * 	0x4000~0x43FF		AXI DMA Control and Status Register
 *	0x40000~0x7FFFF		AXI Ethernet Register
 *	0x80000~0xFFFFF		10G Ethernet MAC CSR(include XAUI PHY)	
 */

#define PCIE_HW_IP_CRA		0x00000
#define AXI_DMA_REG		0x10000
#define MAC_ADDR_BASE 		0x18000

/* The next few constants help upper layers determine the size of memory
 * pools used for Ethernet buffers and descriptor lists.
 */
#define XTE_MAC_ADDR_SIZE   6		/* MAC addresses are 6 bytes */
#define XTE_MTU             1500	/* max MTU size of an Ethernet frame */
#define XTE_JUMBO_MTU       8982	/* max MTU size of a jumbo Ethernet frame */
#define XTE_HDR_SIZE        14	/* size of an Ethernet header */
#define XTE_HDR_VLAN_SIZE   18	/* size of an Ethernet header with VLAN */
#define XTE_TRL_SIZE        4	/* size of an Ethernet trailer (FCS) */
#define XTE_MAX_FRAME_SIZE       (XTE_MTU + XTE_HDR_SIZE + XTE_TRL_SIZE)
#define XTE_MAX_VLAN_FRAME_SIZE  (XTE_MTU + XTE_HDR_VLAN_SIZE + XTE_TRL_SIZE)
#define XTE_MAX_JUMBO_FRAME_SIZE (XTE_JUMBO_MTU + XTE_HDR_SIZE + XTE_TRL_SIZE)

/************************** Constant Definitions *****************************/

#define RX_TRANSFER_CTL_REG                       (0X0)
#define RX_TRANSFER_STATUS_REG                    (0X4)

#define RX_PADCRC_CTL_REG                         (0x100)
#define RX_CRCCHECK_CTL_REG                       (0X200)

#define RX_PKTOVRFLOW_ERR_REG                     (0x304)
#define RX_PKTOVERFLOW_ETH_STATS_DROPEVENTS_REG   (0x308)

#define RX_PREAMBLE_INSERTER_CTL_REG              (0x400)
#define RX_LANE_DECODER_PREAMBLE_CTL_REG          (0x500)

#define RX_FRAME_CTL_REG                          (0x2000)
#define RX_FRAME_MAXLEN_REG                       (0x2004)
#define RX_FRAME_ADDR0_REG                        (0x400)
#define RX_FRAME_ADDR1_REG                        (0x404)

/*fields in FRAME_CTL_REG*/
#define CTL_EN_ALLUCASE_MASK                      (1)
#define CTL_EN_ALLUCAST_OFFSET                    (0)
#define CTL_EN_ALLMCASE_MASK                      (1<<1)
#define CTL_EN_ALLMCASE_OFFSET                    (1)
#define CTL_FWD_CONTROL_MASK                      (1<<3)
#define CTL_FWD_CONTROL_OFFSET                    (3)
#define CTL_FWD_PAUSE_MASK                        (1<<4) 
#define CTL_FWD_PAUSE_OFFSET                      (4)
#define CTL_IGNORE_PAUSE_MASK                     (1<<5)
#define CTL_IGNORE_PAUSE_OFFSET                   (5)
#define CTL_EN_SUPP0_MASK                         (1<<16)
#define CTL_EN_SUPP0_OFFSET                       (16)
#define CTL_EN_SUPP1_MASK                         (1<<17)
#define CTL_EN_SUPP1_OFFSET                       (17)
#define CTL_EN_SUPP2_MASK                         (1<<18)
#define CTL_EN_SUPP2_OFFSET                       (18)
#define CTL_EN_SUPP3_MASK                         (1<<19)
#define CTL_EN_SUPP3_OFFSET                       (19)

#define RX_FRAME_SPADDR0_0_REG                    (0x2010)
#define RX_FRAME_SPADDR0_1_REG                    (0x2014)
#define RX_FRAME_SPADDR1_0_REG 	                  (0x2018)
#define RX_FRAME_SPADDR1_1_REG 	                  (0x201C)
#define RX_FRAME_SPADDR2_0_REG 	                  (0x2020)
#define RX_FRAME_SPADDR2_1_REG 	                  (0x2024)
#define RX_FRAME_SPADDR3_0_REG 	                  (0x2028)
#define RX_FRAME_SPADDR3_1_REG 	                  (0x202c)

#define RX_PFC_CTL_REG 	                          (0x2060)

/*fields in PFG_CTL_REG*/
#define PFC_IGNORE_PAUSE_0_MASK                   (1)
#define PFC_IGNORE_PAUSE_0_OFFSET                 (0)
#define PFC_IGNORE_PAUSE_1_MASK                   (1<<1)
#define PFC_IGNORE_PAUSE_1_OFFSET                 (1)
#define PFC_IGNORE_PAUSE_2_MASK                   (1<<2)
#define PFC_IGNORE_PAUSE_2_OFFSET                 (2) 
#define PFC_IGNORE_PAUSE_3_MASK                   (1<<3)
#define PFC_IGNORE_PAUSE_3_OFFSET                 (3)
#define PFC_IGNORE_PAUSE_4_MASK                   (1<<4)
#define PFC_IGNORE_PAUSE_4_OFFSET                 (4)
#define PFC_IGNORE_PAUSE_5_MASK                   (1<<5)
#define PFC_IGNORE_PAUSE_5_OFFSET                 (5)
#define PFC_IGNORE_PAUSE_6_MASK                   (1<<6)
#define PFC_IGNORE_PAUSE_6_OFFSET                 (6)
#define PFC_IGNORE_PAUSE_7_MASK                   (1<<7)
#define PFC_IGNORE_PAUSE_7_OFFSET                 (7)
#define FWD_PFC_MASK                              (1<<16)
#define FWD_PFC_OFFSET                            (16)

#define TX_TRANSFER_CTL_REG                       (0x4000)
#define TX_TRANSFER_STATUS_REG 	                  (0x4004)

#define TX_PADINS_CTL_REG 		          (0x4100)
#define TX_CRCINS_CTL_REG 		          (0x4200)
#define TX_PKTUNDERFLOW_ERR_REG                   (0x4300)
#define TX_PREAMBLE_CTL_REG                       (0x4400)

#define TX_PAUSEFRAME_CTL_REG 			  (0x4500)
#define TX_PAUSEFRAME_QUANTA_REG                  (0x4504)
#define TX_PAUSEFRAME_ENABLE_REG                  (0x4508)

#define PFC_PAUSE_QUANTA_0_REG                    (0x4600)
#define PFC_PAUSE_QUANTA_1_REG                    (0x4604)
#define PFC_PAUSE_QUANTA_2_REG                    (0x4608)
#define PFC_PAUSE_QUANTA_3_REG                    (0x460c)
#define PFC_PAUSE_QUANTA_4_REG                    (0x4610)
#define PFC_PAUSE_QUANTA_5_REG                    (0x4614)
#define PFC_PAUSE_QUANTA_6_REG                    (0x4618)
#define PFC_PAUSE_QUANTA_7_REG                    (0x461c)

#define PFC_HOLDOFF_QUANTA_0_REG                  (0x4640)
#define PFC_HOLDOFF_QUANTA_1_REG                  (0x4644)
#define PFC_HOLDOFF_QUANTA_2_REG                  (0x4648)
#define PFC_HOLDOFF_QUANTA_3_REG                  (0x464c)
#define PFC_HOLDOFF_QUANTA_4_REG                  (0x4650)
#define PFC_HOLDOFF_QUANTA_5_REG                  (0x4654)
#define HOLDOFF_QUANTA_6_REG                      (0x4658)
#define HOLDOFF_QUANTA_7_REG                      (0x465c)

#define TX_PFC_PRIORITY_ENABLE_REG                (0x4680)

#define TX_ADDRINS_CTL_REG  			  (0x4800)
#define TX_ADDRINS_MACADDR0_REG                   (0x4804)
#define TX_ADDRINS_MACADDR1_REG                   (0x4808)

#define TX_FRAME_MAXLENGTH_REG                    (0x6004)

#define RX_STATS_CLS_REG 			  (0x3000)
#define TX_STATS_CLS_REG 			  (0x7000)

#define RX_STATS_FRAMESOK_REG                     (0x3008)
#define TX_STATS_FRAMESOK_REG                     (0x7008)

#define RX_STATS_FRAMESERR_REG                    (0x3010)
#define TX_STATS_FRAMESERR_REG                    (0x7010)

#define RX_STATS_FRAMESCRCERR_REG                 (0x3018) 
#define TX_STATS_FRAMESCRCERR_REG                 (0x7018)

#define RX_STATS_OCTETSOK_REG                     (0x3020)
#define TX_STATS_OCTETSOK_REG                     (0x7020)

#define RX_STATS_PAUSEMACCTL_FRAMES_REG           (0x3028)
#define TX_STATS_PAUSEMACCTL_FRAMES_REG           (0x7028)

#define RX_STATS_IFERRORS_REG                     (0x3030)
#define TX_STATS_IFERRORS_REG                     (0x7030)

#define RX_STATS_UNICAST_FRAMESOK_REG             (0x3038)
#define TX_STATS_UNICAST_FRAMESOK_REG             (0x7038)

#define RX_STATS_UNICAST_FRAMESERR_REG            (0x3040)
#define TX_STATS_UNICAST_FRAMESERR_REG            (0x7040)

#define RX_STATS_MULTICAST_FRAMESOK_REG           (0x3048)
#define TX_STATS_MULTICAST_FRAMESOK_REG           (0x7048)

#define RX_STATS_MULTICAST_FRAMESERR_REG          (0x3050)
#define TX_STATS_MULTICAST_FRAMESERR_REG          (0x7050)

#define RX_STATS_BROADCAST_FRAMESOK_REG           (0x3058)
#define TX_STATS_BROADCAST_FRAMESOK_REG           (0x7058)

#define RX_STATS_BROADCAST_FRAMESERR_REG          (0x3060)
#define TX_STATS_BROADCAST_FRAMESERR_REG          (0x7060)

#define RX_STATS_ETHERSTATS_OCTETS_REG            (0x3068)
#define TX_STATS_ETHERSTATS_OCTETS_REG            (0x7068)

#define RX_STATS_ETHERSTATSPKTS_REG               (0x3070)
#define TX_STATS_ETHERSTATSPKTS_REG               (0x7070)

#define RX_STATS_ETHERSTATS_UNDERSIZEPKTS_REG     (0x3078)
#define TX_STATS_ETHERSTATS_UNDERSIZEPKTS_REG     (0x7078)

#define RX_STATS_ETHERSTATS_OVERSIZEPKTS_REG      (0x3080)
#define TX_STATS_ETHERSTATS_OVERSIZEPKTS_REG      (0x7080)
 
#define RX_STATS_ETHERSTATS_PKTS64OCTETS_REG      (0x3088)
#define TX_STATS_ETHERSTATS_PKTS64OCTETS_REG      (0x7088)

#define RX_STATS_ETHERSTATS_PKTS65TO127OCTETS_REG (0x3090)
#define TX_STATS_ETHERSTATS_PKTS65TO127OCTETS_REG (0x7090)

#define RX_STATS_ETHERSTATS_PKTS128TO255OCETS_REG (0x3098)
#define TX_STATS_ETHERSTATS_PKTS128TO255OCETS_REG (0x7098)

#define RX_STATS_ETHERSTATS_PKTS256TO511OCETS_REG (0x30a0)
#define TX_STATS_ETHERSTATS_PKTS256TO511OCETS_REG (0x70a0)

#define RX_STATS_ETHERSTATS_PKTS512TO1023OCETS_REG (0x30a8)
#define TX_STATS_ETHERSTATS_PKTS512TO1023OCETS_REG (0x70a8)

#define RX_STATS_ETHERSTATS_PKTS1024TO1518OCETS_REG (0x30b0)
#define TX_STATS_ETHERSTATS_PKTS1024TO1518OCETS_REG (0x70b0)

#define RX_STATS_ETHERSTATS_PKTS1519TOXOCETS_REG  (0x30b8)
#define TX_STATS_ETHERSTATS_PKTS1519TOXOCETS_REG  (0x70b8)

#define RX_STATS_ETHERSTATS_FRAGMENTS             (0x30c0)
#define TX_STATS_ETHERSTATS_FRAGMENTS             (0x70c0)

#define RX_STATS_ETHERSTATS_JABBERS               (0x30c8)
#define TX_STATS_ETHERSTATS_JABBERS               (0x70c8)

#define RX_STATS_ETHERSTATS_CRCERR                (0x30d0)
#define TX_STATS_ETHERSTATS_CRCERR                (0x70d0)

#define RX_STATS_UNICASTMAC_CTLFRAMES             (0x30d8)
#define TX_STATS_UNICASTMAC_CTLFRAMES             (0x70d8)

#define RX_STATS_MULTICASTMAC_CTLFRAMES           (0x30e0)
#define TX_STATS_MULTICASTMAC_CTLFRAMES           (0x70e0)

#define RX_STATS_BROADCASTMAC_CTLFRAMES           (0x30e8)
#define TX_STATS_BROADCASTMAC_CTLFRAMES           (0x70e8)

#define RX_STATS_PFCMACCTLFRAMES                  (0x30f0)
#define TX_STATS_PFCMACCTLFRAMES                  (0x70f0)



/************************** Function Prototypes ******************************/

/*
 * Initialization and control functions in axitemac.c
 */


int axitemac_start(void *reg_base);

#endif/*MAC_REGS_H_ */


