#!/usr/bin/env bash
set -Eeuo pipefail

# run in fresh wsl distro on recet windows 11 (has systemd and kvm enabled by default)

kata_url=https://github.com/kata-containers/kata-containers/releases/download/3.31.0/kata-static-3.31.0-amd64.tar.zst
kata_confd=/opt/kata/share/defaults/kata-containers/config.d
containerd_confd=/etc/k0s/containerd.d/

cat <<-EOF >/etc/apt/sources.list.d/0000debian.sources
	Types: deb
	URIs: https://deb.debian.org/debian
	Suites: testing
	Components: main
	Signed-By: /usr/share/keyrings/debian-archive-keyring.pgp

	Types: deb
	URIs: https://security.debian.org/debian-security
	Suites: testing-security
	Components: main
	Signed-By: /usr/share/keyrings/debian-archive-keyring.pgp
EOF

apt update && apt upgrade && apt full-upgrade
apt install curl zstd

mkdir -p .local
cd .local

if ! [ -d /opt/kata ]; then
	curl -o kata.tar.zst -L $kata_url
	zstd -d kata.tar.zst
	mkdir -p /opt/kata
	tar -C /opt/kata --strip-components 3 -xf kata.tar
	ln -s /opt/kata/bin/* /usr/local/bin/
fi

if ! [ -d /etc/k0s ]; then
	curl -L https://get.k0s.sh -o install-k0s.sh
	bash ./install-k0s.sh
fi

cd -

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
