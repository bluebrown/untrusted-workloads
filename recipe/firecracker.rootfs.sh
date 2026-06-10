#!/usr/bin/env bash
set -Eeuo pipefail

: "${PREFIX:=.local}"

upstream="ci.ubuntu.squashfs"
rootfs="ci.rootfs.ext4"
pwh=$(openssl passwd -6 "root")

mkdir -p "$PREFIX"
cd "$PREFIX"

unsquashfs "$upstream"
trap 'sudo rm -rf squashfs-root' EXIT

sed -i "s|^root:[^:]*:|root:${pwh}:|" squashfs-root/etc/shadow
if [ -x bin/gvforwarder ]; then
  cp bin/gvforwarder squashfs-root/bin/
fi

sudo chown -R root:root squashfs-root
truncate -s 1G "$rootfs"
sudo mkfs.ext4 -d squashfs-root -F "$rootfs"
