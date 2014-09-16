#!/bin/bash

KDIR=$PWD/../linux-image/linux-3.8.0/

(cd ../linux-drv && make KERNELDIR=../linux-image/linux-3.8.0/)

cp ../linux-drv/Module.symvers scst/src/Module.symvers

make -C iscsi-scst/usr CC="gcc -m32"
make -C iscsi-scst/ KDIR=$KDIR
make -C scst KDIR=$KDIR

mkdir -p out/
cp `find iscsi* scst* -name \*.ko ` out/
cp iscsi-scst/usr/iscsi-scstd  iscsi-scst/usr/iscsi-scst-adm out/
