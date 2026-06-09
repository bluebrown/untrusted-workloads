#!/usr/bin/env bash
set -Eeuo pipefail

prefix=".local"
download=https://github.com/containers/gvisor-tap-vsock/releases/download/v0.8.9

mkdir -p "$prefix/bin"

curl -o "$prefix/bin/gvproxy" -fsSL "$download/gvproxy-linux-amd64"
chmod 0755 "$prefix/bin/gvproxy"

curl -o "$prefix/bin/gvforwarder" -fsSL "$download/gvforwarder"
chmod 0755 "$prefix/bin/gvforwarder"
