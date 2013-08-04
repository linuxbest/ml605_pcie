#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <malloc.h>

#include "osChip.h"

size_t mem_size = 1 * 1024 * 1024;
unsigned char *base0;

int osChip_init(uint32_t base)
{
	uint32_t val;

	printf("Calling osChip_init\n");

	base0 = (unsigned char *)memalign(mem_size, mem_size);
	if (base0 == NULL) 
		return -1;

	val = osChipRegRead(base);
	printf("osChipRegRead %08x\n", val);

	return 0;
}

int osChip_intr(uint32_t base)
{
}
