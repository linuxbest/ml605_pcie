#ifndef _OSCHIP_H_
#define _OSCHIP_H_

#ifdef __cplusplus
extern "C" {
#endif

	extern int osChip_init(uint32_t base);
	extern int osChip_intr(uint32_t base);

	extern uint32_t osChipRegRead(uint32_t base);
	extern void osChipRegWrite(uint32_t base, uint32_t val);

	extern void systemc_stop(void);

#ifdef __cplusplus
}
#endif

#endif
