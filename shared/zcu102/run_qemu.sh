#!/bin/bash



APP_NAME="/rfios/build/zynqmp/debug/tests/test_syscalls/app1/app1"
SUPERVISOR_NAME="/rfios/build/zynqmp/debug/tests/test_syscalls/supervisor/supervisor"
RFIOS_NAME="/rfios/build/zynqmp/debug/tests/test_syscalls/RfiOsConfigured"
XIL_PATH="/xilinx/Vitis/2019.2/gnu/aarch64/lin/aarch64-none/bin"

EMU_TMP="/tmp"
GDB_PORT="9000"
TELNET_PORT="9010"
PMUFW_ELF="/shared/zcu102/pmufw.elf"
PMU_DTB="/shared/zcu102/zynqmp-pmu.dtb"
ARM_DTB="/shared/zcu102/zcu102-arm.dtb"
PMU_SHA="/shared/zcu102/pmu_rom_qemu_sha3.elf"
BL31_BIN="/shared/zcu102/bl31.bin"
BL31_ELF="/shared/zcu102/bl31.elf"
FSBL_ELF="/shared/zcu102/fsbl.elf"

export PATH=$PATH:${XIL_PATH}
echo $PATH

xterm -title "Microblaze PMU" -e "qemu-system-microblazeel -M microblaze-fdt -nographic -dtb ${PMU_DTB} -kernel ${PMU_SHA} -device loader,file=${PMUFW_ELF} -machine-path ${EMU_TMP}; read" &
sleep 1
xterm -title "ARM Cortex A53 - Log window" -e "qemu-system-aarch64 -M arm-generic-fdt -nographic -serial mon:stdio -serial telnet::${TELNET_PORT},server,nowait -display none -dtb ${ARM_DTB} -global xlnx,zynqmp-boot.cpu-num=0 -global xlnx,zynqmp-boot.use-pmufw=true -global xlnx,zynqmp-boot.load-pmufw-cfg=false -device loader,file=${BL31_BIN},addr=0x1000 -device loader,file=${RFIOS_NAME}.bin,addr=0x8000000 -device loader,file=${FSBL_ELF},cpu-num=0 -machine-path ${EMU_TMP} -gdb tcp::${GDB_PORT}; read" &
sleep 3
xterm -title "ARM Cortex A53 - Standard output"	-e "telnet localhost ${TELNET_PORT}; read" &
sleep 4
xterm -title "ARM Cortex A53 - GDB" -e "aarch64-none-elf-gdb -ex 'set confirm off' -ex 'add-symbol-file ${BL31_ELF}' -ex 'add-symbol-file ${RFIOS_NAME}.elf' -ex 'add-symbol-file ${APP_NAME}.elf' -ex 'add-symbol-file ${SUPERVISOR_NAME}.elf' -ex 'set confirm on' -ex 'target remote : ${GDB_PORT}' -ex 'thread 1' -ex 'set \$pc = 0x1000' -ex c; read" &
