#!/bin/bash

KDIR=$PWD/../linux-image/linux-3.8.0/

make -C iscsi-scst/usr CC="gcc -m32"
make -C iscsi-scst/ KDIR=$KDIR
make -C scst KDIR=$KDIR

mkdir out/
cp `find iscsi* scst* -name \*.ko ` out/
cp iscsi-scst/usr/iscsi-scstd  iscsi-scst/usr/iscsi-scst-adm out/
