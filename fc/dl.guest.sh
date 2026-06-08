#!/usr/bin/env bash
set -Eeuo pipefail

mkdir -p .local
cd .local

arch="$(uname -m)"
vers=v1.15 # 1.16 has no artifacts
# vers="$(firecracker --version | awk 'NR==1{print $2}')"

kkey=$(curl "http://spec.ccfc.min.s3.amazonaws.com/?prefix=firecracker-ci/$vers/$arch/vmlinux-&list-type=2" |
  grep -oP "(?<=<Key>)(firecracker-ci/$vers/$arch/vmlinux-[0-9]+\.[0-9]+\.[0-9]{1,3})(?=</Key>)" |
  sort -V | tail -1)

ukey=$(curl "http://spec.ccfc.min.s3.amazonaws.com/?prefix=firecracker-ci/$vers/$arch/ubuntu-&list-type=2" |
  grep -oP "(?<=<Key>)(firecracker-ci/$vers/$arch/ubuntu-[0-9]+\.[0-9]+\.squashfs)(?=</Key>)" |
  sort -V | tail -1)

kernel="vmlinux"
upstream="ubuntu.squashfs"

curl -Lo "$kernel" "https://s3.amazonaws.com/spec.ccfc.min/$kkey"
curl -Lo "$upstream" "https://s3.amazonaws.com/spec.ccfc.min/$ukey"

rootfs="${upstream%.*}.ext4"
pwh=$(openssl passwd -6 "root")

sudo rm -rf squashfs-root "$rootfs"
unsquashfs "$upstream"
sed -i "s|^root:[^:]*:|root:${pwh}:|" squashfs-root/etc/shadow
sudo chown -R root:root squashfs-root
truncate -s 1G "$rootfs"
sudo mkfs.ext4 -d squashfs-root -F "$rootfs"
sudo rm -rf squashfs-root
