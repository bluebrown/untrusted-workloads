#!/usr/bin/env bash
set -Eeuo pipefail

k0s install controller --single --start --config k0s.config.yaml
