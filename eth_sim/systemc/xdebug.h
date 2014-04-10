#ifndef XDEBUG
#define XDEBUG

#define DEBUG

#if defined(DEBUG) && !defined(NDEBUG)

#ifndef XDEBUG_WARNING
#define XDEBUG_WARNING
#warning DEBUG is enabled
#endif

//#define xil_printf(format) printf format

#define XDBG_DEBUG_ERROR             0x00000001    /* error condition messages */
#define XDBG_DEBUG_GENERAL           0x00000002    /* general debug  messages */
#define XDBG_DEBUG_ALL               0xFFFFFFFF    /* all debugging data */

#define XDBG_DEBUG_FIFO_REG          0x00000100    /* display register reads/writes */
#define XDBG_DEBUG_FIFO_RX           0x00000101    /* receive debug messages */
#define XDBG_DEBUG_FIFO_TX           0x00000102    /* transmit debug messages */
#define XDBG_DEBUG_FIFO_ALL          0x0000010F    /* all fifo debug messages */

#define XDBG_DEBUG_TEMAC_REG         0x00000400    /* display register reads/writes */
#define XDBG_DEBUG_TEMAC_RX          0x00000401    /* receive debug messages */
#define XDBG_DEBUG_TEMAC_TX          0x00000402    /* transmit debug messages */
#define XDBG_DEBUG_TEMAC_ALL         0x0000040F    /* all temac  debug messages */

#define XDBG_DEBUG_TEMAC_ADPT_RX     0x00000800    /* receive debug messages */
#define XDBG_DEBUG_TEMAC_ADPT_TX     0x00000801    /* transmit debug messages */
#define XDBG_DEBUG_TEMAC_ADPT_IOCTL  0x00000802    /* ioctl debug messages */
#define XDBG_DEBUG_TEMAC_ADPT_MISC   0x00000803    /* debug msg for other routines */
#define XDBG_DEBUG_TEMAC_ADPT_ALL    0x0000080F    /* all temac adapter debug messages */

//#define xdbg_current_types (XDBG_DEBUG_ERROR | XDBG_DEBUG_GENERAL | XDBG_DEBUG_FIFO_REG | XDBG_DEBUG_TEMAC_REG)
#define xdbg_current_types (DBG_DEBUG_ALL)

#define xdbg_stmnt(x)  x
#define xdbg_printf(type, ...) printf (__VA_ARGS__)

#else
#define xdbg_stmnt(x)
#define xdbg_printf(...)
#endif




#endif /* XDEBUG */
