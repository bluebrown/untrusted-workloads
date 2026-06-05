#!/usr/bin/env bash
set -Eeuo pipefail

k0s kubectl delete secret/bifrost-env cm/bifrost-config --ignore-not-found
k0s kubectl create secret generic bifrost-env --from-env-file bifrost.env
k0s kubectl create cm bifrost-config --from-file=config.json=bifrost.config.json
