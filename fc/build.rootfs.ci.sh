#!/usr/bin/env bash
set -Eeuo pipefail

prefix="$PWD/.local"
upstream="ci.ubuntu.squashfs"

mkdir -p "$prefix"
cd "$prefix"

rootfs="ci.rootfs.ext4"
pwh=$(openssl passwd -6 "root")

unsquashfs "$upstream"
trap 'sudo rm -rf squashfs-root' EXIT

sed -i "s|^root:[^:]*:|root:${pwh}:|" squashfs-root/etc/shadow
cp bin/gvforwarder squashfs-root/bin/

sudo chown -R root:root squashfs-root
truncate -s 1G "$rootfs"
sudo mkfs.ext4 -d squashfs-root -F "$rootfs"
