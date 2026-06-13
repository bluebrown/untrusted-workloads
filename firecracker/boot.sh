#!/usr/bin/env bash
set -Eeuo pipefail

rm -f "$FC_SOCK" "$V_SOCK"
exec firecracker --api-sock "$FC_SOCK" --config-file "$FC_CONFIG" --enable-pci --boot-timer "$@"
