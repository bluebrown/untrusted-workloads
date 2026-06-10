#!/usr/bin/env bash
set -Eeuo pipefail

: "${PREFIX:=.local}"

version="v1.16.0"
suffix="$version-x86_64"
file="firecracker-$suffix.tgz"
download_url="https://github.com/firecracker-microvm/firecracker/releases/download/$version/$file"

release="release-${file#*-}"
release="${release%.*}"
dest="${file%.*}"

mkdir -p "$PREFIX/bin"
cd "$PREFIX"

if ! [ -f "$file" ]; then
  curl -LO "$download_url"
fi

if ! [ -d "$dest" ]; then
  rm -rf "$release" "$dest"
  tar -xzf "$file"
  mv "$release" "$dest"
fi

# ln -srf "$dest/firecracker-$suffix" bin/firecracker
# ln -srf "$dest/jailer-$suffix" bin/jailer

install "$dest/firecracker-$suffix" bin/firecracker
install "$dest/jailer-$suffix" bin/jailer
