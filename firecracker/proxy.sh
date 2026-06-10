#!/usr/bin/env bash
set -Eeuo pipefail

: "${PREFIX:=.local}"
: "${V_SOCK:=$PREFIX/v.sock}"

exec gvproxy \
  -listen "unix:///${V_SOCK}_1024" \
  -listen "unix:///$PREFIX/gvproxy.sock"
