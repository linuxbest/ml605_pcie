GITVERSION="git-$(shell git describe --dirty --always) `date "+%Y %D %H:%M:%S"`"
EXTRA_CFLAGS += -DGITVERSION=\"${GITVERSION}\"
EXTRA_CFLAGS += -DCONFIG_VPCI
#EXTRA_CFLAGS += -DDEBUG -g

KERNELDIR ?= /lib/modules/`uname -r`/build

obj-m := aes10g.o eth10g.o vpci.o #xilinx_emac.o
aes10g-objs := aesdma.o xaxidma_bd.o xaxidma_bdring.o xaxidma.o xio.o
eth10g-objs := ethdma.o xaxidma_bd.o xaxidma_bdring.o xaxidma.o xio.o axitemac.o
xilinx_emac-objs := xilinx_axienet_main.o xilinx_axienet_mdio.o

default:
	        $(MAKE) -C $(KERNELDIR) SUBDIRS=$(PWD) modules

clean:
	rm -f *.o *.ko .*.cmd *.mod.c .*.d .depend Modules.symvers \
		Module.symvers Module.markers modules.order
	rm -rf .tmp_versions
