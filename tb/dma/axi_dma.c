#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>

#include "osChip.h"

size_t mem_size = 32 * 1024 * 1024;
unsigned char *base0;

struct sg {
	uint32_t nextdesc;
	uint32_t u0;
	uint32_t buffer;
	uint32_t u1;
	uint32_t u2;
	uint32_t u3;
	uint32_t ctrl;
	uint32_t status;
	uint32_t app0;
	uint32_t app1;
	uint32_t app2;
	uint32_t app3;
	uint32_t app4;
};

int osChip_init(uint32_t base)
{
	uint32_t val;
	int i;

	printf("Calling osChip_init\n");

	base0 = (unsigned char *)memalign(mem_size, mem_size);
	if (base0 == NULL) 
		return -1;

	uint32_t *dst  = (uint32_t *)(base0 + 0x200000);
	for (i = 0; i < 1024; i ++) {
		dst[i] = i;
	}
	struct sg *dsg = (struct sg *)(base0 + 0x2000);
	memset(dsg, 0, 0x40);
	dsg->nextdesc = 0x2040;
	dsg->buffer   = 0x200000;
	dsg->ctrl     = 512;       /* LEN */
	dsg->ctrl    |= 0x08000000; /* SOF */
	dsg->ctrl    |= 0x04000000; /* EOF */

	uint32_t *src = (uint32_t *)(base0 + 0x100000);
	for (i = 0; i < 1024; i ++) {
		src[i] = i;
	}
	struct sg *rsg = (struct sg *)(base0 + 0x1000);
	memset(rsg, 0, 0x40);
	rsg->nextdesc = 0x1040;
	rsg->buffer   = 0x100000;
	rsg->ctrl     = 512;       /* LEN */
	rsg->ctrl    |= 0x08000000; /* SOF */
	rsg->ctrl    |= 0x04000000; /* EOF */

	/* Reset DMA */
	osChipRegWrite(base + 0x00, 0x4 | (1<<12) | (1<<13) | (1<<14));
	osChipRegWrite(base + 0x30, 0x4 | (1<<12) | (1<<13) | (1<<14));

	/* wait for Reset done */
	for (i = 0; i < 100; i ++) {
		osChipRegRead(base);
	}
	/* write cur desc */
	osChipRegWrite(base + 0x38, 0x2000);
	/* start dma */
	osChipRegWrite(base + 0x30, 0x1 | (1<<12) | (1<<13) | (1<<14));
	/* write tail desc */
	osChipRegWrite(base + 0x40, 0x2000);

	/* write cur desc */
	osChipRegWrite(base + 0x08, 0x1000);
	/* start dma */
	osChipRegWrite(base + 0x00, 0x1 | (1<<12) | (1<<13) | (1<<14));
	/* write tail desc */
	osChipRegWrite(base + 0x10, 0x1000);

	return 0;
}

int osChip_intr(uint32_t base)
{
}
