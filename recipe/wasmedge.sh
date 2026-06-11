#!/usr/bin/env sh
set -eu

: "${PREFIX:=.local}"

curl -sSf https://raw.githubusercontent.com/WasmEdge/WasmEdge/master/utils/install_v2.sh |
  bash -s -- -p "$PREFIX"
