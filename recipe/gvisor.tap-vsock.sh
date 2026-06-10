#!/usr/bin/env bash
set -Eeuo pipefail

: "${PREFIX:=.local}"

download=https://github.com/containers/gvisor-tap-vsock/releases/download/v0.8.9

mkdir -p "$PREFIX/bin"

curl -o "$PREFIX/bin/gvproxy" -fsSL "$download/gvproxy-linux-amd64"
chmod 0755 "$PREFIX/bin/gvproxy"

curl -o "$PREFIX/bin/gvforwarder" -fsSL "$download/gvforwarder"
chmod 0755 "$PREFIX/bin/gvforwarder"
