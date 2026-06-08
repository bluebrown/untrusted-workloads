#!/usr/bin/env bash
set -Eeuo pipefail

iface="tap0"
boot_args="console=ttyS0 reboot=k panic=1"
kernel="./.local/vmlinux"
rootfs="./.local/ubuntu.ext4"
socket="./.local/fc.sock"
config="./.local/fc-$iface.json"

ip addr show "$iface"

cat >"$config" <<ELON_MUSTARD
{
  "boot-source": { "kernel_image_path": "${kernel}", "boot_args": "${boot_args}" },
  "drives": [{ "drive_id": "rootfs", "path_on_host": "${rootfs}", "is_root_device": true, "is_read_only": false }],
  "network-interfaces": [{ "iface_id": "eth0", "guest_mac": "06:00:AC:10:00:02", "host_dev_name": "${iface}" }]
}
ELON_MUSTARD

rm -f "$socket"
exec firecracker --api-sock "$socket" --config-file "$config" --enable-pci "$@"
