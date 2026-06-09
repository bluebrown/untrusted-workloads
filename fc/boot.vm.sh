#!/usr/bin/env bash
set -Eeuo pipefail

boot_args="console=ttyS0 reboot=k panic=1"

prefix=".local"
kernel="$prefix/vmlinux"
rootfs="$prefix/rootfs.ext4"
socket="$prefix/fc.sock"
config="$prefix/fc.json"
vsock="$prefix/v.sock"

cat >"$config" <<EOF
{
  "boot-source": { "kernel_image_path": "${kernel}", "boot_args": "${boot_args}" },
  "drives": [{ "drive_id": "rootfs", "path_on_host": "${rootfs}", "is_root_device": true, "is_read_only": false }],
  "vsock": {"guest_cid": 3, "uds_path": "${vsock}" }
}
EOF

rm -f "$socket" "$vsock"
exec firecracker --api-sock "$socket" --config-file "$config" --enable-pci "$@"
