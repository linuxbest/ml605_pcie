#include <stdio.h>
#include <stdint.h>

#include "osChip.h"

int osChip_init(uint32_t base)
{
	uint32_t val;
	printf("Calling osChip_init\n");

	val = osChipRegRead(base);
	printf("osChipRegRead %08x\n", val);

	return 0;
}

int osChip_intr(uint32_t base)
{
}
