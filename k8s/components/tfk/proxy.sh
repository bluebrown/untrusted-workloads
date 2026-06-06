#!/usr/bin/env bash
set -Eeuo pipefail

# makeshift bare metal loadbalancer. set traefik service to type NodePort
# an run this script in the background or another terminal.
# access treafik dashboard in the browser at <http://localhost>

nport="$(k0s kubectl get service traefik -o jsonpath='{.spec.ports[0].nodePort}')"
socat "TCP-LISTEN:80,fork,reuseaddr" "TCP:127.0.0.1:$nport"
