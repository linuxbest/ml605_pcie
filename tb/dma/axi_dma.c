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
	int i;

	printf("Calling osChip_init\n");

	base0 = (unsigned char *)memalign(mem_size, mem_size);
	if (base0 == NULL) 
		return -1;

	/* Reset DMA */
	osChipRegWrite(base + 0x00, 0x4);
	/* wait for Reset done */
	for (i = 0; i < 100; i ++) {
		osChipRegRead(base);
	}
	/* write cur desc */
	osChipRegWrite(base + 0x08, 0x1000);
	/* start dma */
	osChipRegWrite(base + 0x00, 0x1);
	/* write tail desc */
	osChipRegWrite(base + 0x10, 0x1020);

	return 0;
}

int osChip_intr(uint32_t base)
{
}
