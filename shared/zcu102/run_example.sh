#!/bin/bash

/qemu/aarch64-softmmu/qemu-system-aarch64 \
	-accel accel=tcg,thread=multi -m 2G \
	-machine xlnx-zcu102 -cpu cortex-a53 -smp cpus=4,maxcpus=4,cores=4,threads=1 \
	-nographic -serial mon:stdio -serial /dev/null -display none \
	-device loader,addr=0xfd1a0104,data=0x8000000e,data-len=4 \
 	-device loader,file=/shared/zcu102/bl31.elf,cpu-num=0 \
	-device loader,file=/shared/zcu102/u-boot.elf \
	-dtb /qemu-devicetrees/LATEST/SINGLE_ARCH/zcu102-arm.dtb
