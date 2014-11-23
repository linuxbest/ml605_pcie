all: k7_pcie.bit

export XIL_PAR_DESIGN_CHECK_VERBOSE=1

pcie_7x_v1_10_readme.txt: pcie_7x_v1_10.xco k7_325.cgp
	coregen -p k7_325.cgp -b pcie_7x_v1_10.xco

xilinx_pcie_2_1_ep_7x.ngc: xilinx_pcie_2_1_ep_7x.xst
	xst -ifn xilinx_pcie_2_1_ep_7x.xst -ofn xilinx_pcie_2_1_ep_7x.log

k7_pcie.ngd: xilinx_pcie_2_1_ep_7x.ngc k7_pcie.ucf
	ngdbuild -verbose -uc k7_pcie.ucf xilinx_pcie_2_1_ep_7x.ngc -sd . ./k7_pcie.ngd

k7_pcie_map.ncd: k7_pcie.ngd
	map -w -register_duplication on -ol high -o $@ $^ k7_pcie.pcf

k7_pcie_rt.ncd: k7_pcie_map.ncd
	par -ol high -w $^ $@ k7_pcie.pcf

k7_pcie.twr: k7_pcie_rt.ncd
	trce -u -e 100 k7_pcie_rt.ncd k7_pcie.pcf

k7_pcie.bit: k7_pcie.twr k7_pcie_rt.ncd
	bitgen -w k7_pcie_rt.ncd k7_pcie.bit

clean:
	rm -fr *.ngd *.ncd *.pcf *.twr *.bit pcie_7x_v1_10
