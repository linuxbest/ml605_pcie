#!/bin/bash

cp ../../xco/pcie_7x_v1_10.xco .
cp ../../xco/coregen.cgp .
coregen -p coregen.cgp -b pcie_7x_v1_10.xco
