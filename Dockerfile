FROM debian:10.3
LABEL maintainer="Salvatore Barone <salvator.barone@gmail.com>"

## Install neded packages
RUN	apt-get update 
RUN apt-get install -y libglib2.0-dev libgcrypt20-dev zlib1g-dev autoconf \
	automake libtool bison flex wget unzip python libpixman-1-dev libfdt-dev \
	openssh-server xz-utils cmake make gcc g++ clang git fzf zsh fonts-powerline \
	device-tree-compiler vim-nox

## Cleaning the apt cache
RUN apt-get clean 
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## Getting oh-my-zsh and vim plugins
RUN wget --quiet https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN sed -i "s/git/git sudo docker fzf/g" ~/.zshrc
RUN sed -i "s/robbyrussell/xiong-chiamiov-plus/g" ~/.zshrc
RUN	git clone https://gitlab.com/SalvatoreBarone/myvimrc.git && \
	cp myvimrc/vimrc /root/.vimrc && \
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim && \
	vim +PluginInstall +qall

# Getting dtbs for qemu
RUN git clone https://github.com/Xilinx/qemu-devicetrees

# Getting Qemu for Xilinx boards
RUN git clone git://github.com/Xilinx/qemu.git
WORKDIR qemu
RUN git submodule update --init dtc
RUN ./configure --target-list="arm-softmmu,aarch64-softmmu,microblazeel-softmmu" --enable-fdt --disable-kvm --disable-xen 
RUN make -j `nproc` 
RUN make install -j `nproc`

WORKDIR /qemu-devicetrees
RUN make

WORKDIR /

# Network setting for GDB
#EXPOSE 1440
