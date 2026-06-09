#!/usr/bin/env bash
set -Eeuo pipefail

arch="$(uname -m)"
vers=v1.15 # 1.16 has no artifacts
# vers="$(firecracker --version | awk 'NR==1{print $2}')"
prefix="$PWD/.local"

mkdir -p "$prefix"
cd "$prefix"

kkey=$(curl "http://spec.ccfc.min.s3.amazonaws.com/?prefix=firecracker-ci/$vers/$arch/vmlinux-&list-type=2" |
  grep -oP "(?<=<Key>)(firecracker-ci/$vers/$arch/vmlinux-[0-9]+\.[0-9]+\.[0-9]{1,3})(?=</Key>)" |
  sort -V | tail -1)

ukey=$(curl "http://spec.ccfc.min.s3.amazonaws.com/?prefix=firecracker-ci/$vers/$arch/ubuntu-&list-type=2" |
  grep -oP "(?<=<Key>)(firecracker-ci/$vers/$arch/ubuntu-[0-9]+\.[0-9]+\.squashfs)(?=</Key>)" |
  sort -V | tail -1)

curl -Lo ci.vmlinux "https://s3.amazonaws.com/spec.ccfc.min/$kkey"
curl -Lo ci.ubuntu.squashfs "https://s3.amazonaws.com/spec.ccfc.min/$ukey"
