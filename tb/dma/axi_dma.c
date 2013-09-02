#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>

#include "osChip.h"

typedef unsigned char byte;
typedef unsigned int word;

void encrypt_128_key_expand_inline_no_branch(word state[], word key[]);
void encrypt_192_key_expand_inline_no_branch(word state[], word key[]);
void encrypt_256_key_expand_inline_no_branch(word state[], word key[]);

word rand_word();
void rand_word_array(word w[], int bit_num);
void print_verilog_hex(word w[], int bit_num);


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

	uint8_t *dst  = (uint8_t *)(base0 + 0x200000);
	for (i = 0; i < 1024; i ++) {
		dst[i] = i;
	}
	struct sg *dsg = (struct sg *)(base0 + 0x2000);
	memset(dsg, 0, 0x40);
	dsg->nextdesc = 0x2040;
	dsg->buffer   = 0x200000;
	dsg->ctrl     = 4096;       /* LEN */
	dsg->ctrl    |= 0x08000000; /* SOF */
	dsg->ctrl    |= 0x04000000; /* EOF */

	dsg = (struct sg *)(base0 + 0x2040);
	memset(dsg, 0, 0x40);
	dsg->nextdesc = 0x2080;
	dsg->buffer   = 0x300000;
	dsg->ctrl     = 4096;       /* LEN */
	dsg->ctrl    |= 0x08000000; /* SOF */
	dsg->ctrl    |= 0x04000000; /* EOF */


	uint8_t *src = (uint8_t *)(base0 + 0x100000);
	for (i = 0; i < 4096; i ++) {
		src[i] = i;
	}
	struct sg *rsg = (struct sg *)(base0 + 0x1000);
	memset(rsg, 0, 0x40);
	rsg->nextdesc = 0x1040;
	rsg->buffer   = 0x100000;
	rsg->ctrl     = 4096;       /* LEN */
	rsg->ctrl    |= 0x08000000; /* SOF */
	rsg->ctrl    |= 0x04000000; /* EOF */

	rsg = (struct sg *)(base0 + 0x1040);
	memset(rsg, 0, 0x40);
	rsg->nextdesc = 0x1080;
	rsg->buffer   = 0x200000;
	rsg->ctrl     = 4096;       /* LEN */
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
	osChipRegWrite(base + 0x40, 0x2040);

	/* write cur desc */
	osChipRegWrite(base + 0x08, 0x1000);
	/* start dma */
	osChipRegWrite(base + 0x00, 0x1 | (1<<12) | (1<<13) | (1<<14));
	/* write tail desc */
	osChipRegWrite(base + 0x10, 0x1040);

	for (;;) {
		val = osChipRegRead(base + 0x34);
		if (val & (1<<12))
			break;
	}

	uint32_t dst_good[4096] = {0};
	uint32_t key[8] = {0x00000000, 0x00000000, 0x00000000, 0x00000000,
		0x00000000, 0x00000000, 0x00000000, 0x00000000};

	for (i = 0; i < 4096; i += 4) {
		dst_good[i] = (i/4) & 0x1f;
		encrypt_256_key_expand_inline_no_branch(&dst_good[i], key);
	}

	uint32_t *src_u32 = (uint32_t *)src;
	uint32_t *dst_u32 = (uint32_t *)dst;
	for (i = 0; i < 256; i ++) {
		uint32_t dst_ok = dst_good[i] ^ src_u32[i];
		printf("%04x: %08x/%08x, %08x/%08x, %s\n",
				i, dst_u32[i], src_u32[i], dst_good[i], dst_ok,
				dst_u32[i] == dst_ok ? "O" : "E");
	}

	return 0;
}

int osChip_intr(uint32_t base)
{
}
