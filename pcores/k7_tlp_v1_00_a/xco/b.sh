#!/bin/bash

set -x 
set -e

for i in icon3.xco  ila128_16.xco  ila256_16.xco
do
	coregen -p coregen.cgp -b $i
done
