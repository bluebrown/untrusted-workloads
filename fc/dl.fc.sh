#!/usr/bin/env bash
set -Eeuo pipefail

version="v1.16.0"
suffix="$version-x86_64"
tarball="firecracker-$suffix.tgz"
download_url="https://github.com/firecracker-microvm/firecracker/releases/download/$version/$tarball"
prefix="$HOME/.local"

mkdir -p "$prefix/bin"
cd "$prefix"

if ! [ -f "$tarball" ]; then
  curl -LO "$download_url"
fi

# the directory inside the tarball is named release-<version> not
# firecracker-<version>. use these variables to fix this, during
# decompress
dest="${tarball%.*}"
release="release-${dest#*-}"

if ! [ -d "$dest" ]; then
  rm -rf "$release" "$dest"
  tar -xzf "$tarball"
  mv "$release" "$dest"
fi

for prog in firecracker jailer; do
  ln -srf "$dest/$prog-$suffix" bin/$prog
done
