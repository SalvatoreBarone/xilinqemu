#!/bin/bash

usage() { 
	echo "Usage: $0 -r /rfios_home -x /xilinx_home"; 
	exit 1; 
}

while getopts "r:x:" o; do
    case "${o}" in
        r)
            rfios_root=${OPTARG}
            ;;
        x)
            xilinx_root=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${rfios_root}" ] || [ -z "${xilinx_root}" ]; then
    usage
fi

echo "rfios_root = ${rfios_root}"
echo "xilinx_root = ${xilinx_root}"

xhost local:docker
docker run --rm -e DISPLAY=unix$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix -v $(pwd)/shared:/shared -v $rfios_root:/rfios -v $xilinx_root:/xilinx --privileged -it "xilinx-qemu-aarch64" /bin/zsh
