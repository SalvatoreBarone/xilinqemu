#!/bin/bash
sudo docker run --rm -v $(pwd)/shared:/shared --privileged -it "xilinx-qemu-aarch64" /bin/zsh
