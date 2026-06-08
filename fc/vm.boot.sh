#!/usr/bin/env bash
set -Eeuo pipefail

iface="tap0"
boot_args="console=ttyS0 reboot=k panic=1"

kernel="./.local/vmlinux"
rootfs="./.local/ubuntu.ext4"
socket="./.local/fc.sock"
config="./.local/fc-$iface.json"
vsock=."/.local/v.sock"

ip addr show "$iface"

cat >"$config" <<EOF
{
  "boot-source": { "kernel_image_path": "${kernel}", "boot_args": "${boot_args}" },
  "drives": [{ "drive_id": "rootfs", "path_on_host": "${rootfs}", "is_root_device": true, "is_read_only": false }],
  "vsock": {"guest_cid": 3, "uds_path": "${vsock}" }
}
EOF

rm -f "$socket" "$vsock"
exec firecracker --api-sock "$socket" --config-file "$config" --enable-pci "$@"
