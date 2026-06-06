#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname -- "$(readlink -f -- "$0")")"

k0s install controller --single --start --config k0s.config.yaml

until [ -d /var/lib/k0s/manifests ]; do
	sleep 1
done

cp -r manifests/* /var/lib/k0s/manifests/
