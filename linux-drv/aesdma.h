#ifndef _AES_DMA_API_
#define _AES_DMA_API_

typedef void (*aes_cb_t)(void *priv);
int aes_submit(struct scatterlist *src_sg, int src_cnt, int src_sz,
		struct scatterlist *dst_sg, int dst_cnt, int dst_sz,
		aes_cb_t cb, char *priv, uint32_t *key);

#endif
