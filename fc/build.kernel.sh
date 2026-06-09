#!/usr/bin/env bash
set -Eeuo pipefail

# apt install \
#   gcc-12 \
#   build-essential \
#   flex \
#   bison \
#   bc \
#   libssl-dev \
#   libelf-dev \
#   dwarves \
#   python3 \
#   rsync \
#   cpio

cd /tmp

if ! [ -d linux ]; then
  git clone --depth=1 --branch v6.1 https://github.com/torvalds/linux.git
fi

cd linux

if ! [ -f .config ]; then
  curl -o .config \
    https://raw.githubusercontent.com/firecracker-microvm/firecracker/main/resources/guest_configs/microvm-kernel-ci-x86_64-6.1.config

  echo "CONFIG_TUN=y" >>.config
fi

make clean
make olddefconfig
make vmlinux CC=gcc-12 -j"$(nproc)"

cd -
mv /tmp/linux/vmlinux .local/
