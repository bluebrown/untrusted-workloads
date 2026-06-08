#!/usr/bin/env bash
set -Eeuo pipefail

# can be used instead of vsock

ip tuntap add dev tap0 mode tap
ip link set dev tap0 up
ip addr add dev tap0 172.16.0.1/30
