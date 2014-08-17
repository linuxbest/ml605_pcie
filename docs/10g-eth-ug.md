#10G Ethernet IP Core User Guide

##Current Feature
 * 4port 10Gps, one port data path 64bit @ 200Mhz = 12.8Gps
 * aes dma, data path 128bit @ 200Mhz = 25.6Gps
 * TCPv4, UDPv4 txsum & rxsum support
 * linux 2.6/3.x driver support

##Build FPGA envirment
 * Ubuntu 12.04 64bit
 * Xilinx EDK 14.6

##Build FPGA guide
 * loading the xilinx edk env
   <pre><code>
$. /opt/Xilinx/14.6/ISE_DS/settings64.sh
   </code></pre>
 * run edk as command line
   <pre><code>
$ xps -nw k7aes.xmp
XPS% save make
XPS% exit
$ make -f k7aes.make bits
   </code></pre>

##Build Linux device driver
 * make sure you installed linux-header and gcc
   <pre><code>
$ sudo apt-get install    linux-headers-`uname -r`
$ sudo apt-get build-dep  linux-headers-`uname -r`
   </code></pre>

 * build device driver
   <pre><code>
$ cd linux-drver
$ make
   </code></pre>

 * after build, we will have 3 ko files.
  * vpci.ko    virtual pci device driver.
  * aes10g.ko  aes device driver.
  * eth10g.ko  eth device driver.

##Test it
 * put k7aes card into a test machine (same linux version)
 * loading the bit using chipscope or impact.
 * after config bit, reboot linux machine
 * make sure after linux reboot, lspci can found a new xilinx device
 * loading device driver.
 <pre><code>
 # insmod /tmp/vpci.ko
 # insmod /tmp/aes10g.ko
 # insmod /tmp/eth10g.ko
 </code></pre>