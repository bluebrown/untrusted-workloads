#!/usr/bin/env bash
set -Eeuo pipefail

kata_confd=/opt/kata/share/defaults/kata-containers/config.d
containerd_confd=/etc/k0s/containerd.d/

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
cd "$tmpdir"

if ! [ -d /etc/k0s ]; then
  curl -L https://get.k0s.sh -o install-k0s.sh
  bash ./install-k0s.sh
fi

mkdir -p $kata_confd
cat <<-EOF >$kata_confd/k0s.toml
	[runtime]
	kubelet_root_dir = "/var/lib/k0s/kubelet"
EOF

mkdir -p $containerd_confd
cat <<-EOF >$containerd_confd/kata.toml
	[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.kata]
	  runtime_type = "io.containerd.kata.v2"
	  privileged_without_host_devices = true
	  pod_annotations = ["io.katacontainers.*"]
	  container_annotations = ["io.katacontainers.*"]
	  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.kata.options]
	    ConfigPath = "/opt/kata/share/defaults/kata-containers/configuration.toml"
EOF
