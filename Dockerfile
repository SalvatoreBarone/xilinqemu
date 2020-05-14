FROM ubuntu:18.04
LABEL maintainer="Salvatore Barone <salvator.barone@gmail.com>"
ARG DEBIAN_FRONTEND=noninteractive

## Install neded packages
RUN	apt-get update 
RUN apt-get install -y libglib2.0-dev libgcrypt20-dev zlib1g-dev autoconf \
	automake libtool bison flex wget unzip python libpixman-1-dev libfdt-dev \
	openssh-server xz-utils cmake make gcc g++ clang git zsh fonts-powerline \
	device-tree-compiler vim-nox xterm telnet

## Cleaning the apt cache
RUN apt-get clean 
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Getting oh-my-zsh 
RUN wget --quiet https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN sed -i "s/robbyrussell/xiong-chiamiov-plus/g" ~/.zshrc

# Getting dtbs for qemu
RUN git clone https://github.com/Xilinx/qemu-devicetrees
RUN git clone https://github.com/Xilinx/qemu.git

# Compiling qemu
WORKDIR qemu
RUN git checkout xilinx-v2019.2
RUN git submodule update --init dtc
RUN ./configure --target-list="aarch64-softmmu,microblazeel-softmmu" --enable-fdt --disable-kvm --disable-xen --disable-gtk --disable-werror
RUN make -j `nproc` 
RUN make install -j `nproc`

#compiling device trees
WORKDIR /qemu-devicetrees
RUN make

WORKDIR /

# Network setting for GDB
EXPOSE 9000

# Network setting for Telnet
EXPOSE 9010

