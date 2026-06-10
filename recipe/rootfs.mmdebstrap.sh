#!/usr/bin/env bash
set -Eeuo pipefail

# ✦ ❯ sudo apt install mmdebstrap
# ✦ ❯ sudo apt install libarchive-tools e2fsprogs fuse
# ✦ ❯ sudo apt install fuse2fs
#
: "${PREFIX:=.local}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
cd "$tmpdir"

mmdebstrap \
  --mode=unshare \
  --variant=minbase \
  --include=busybox-static,curl,socat \
  --dpkgopt="path-exclude=/usr/share/doc/*" \
  --dpkgopt="path-exclude=/usr/share/man/*" \
  --dpkgopt="path-exclude=/usr/share/locale/*" \
  bookworm \
  rootfs.tar # use tar and not ext4 due to permission

truncate -s 250M rootfs.ext4
mkfs.ext4 rootfs.ext4

mkdir -p mnt
fuse2fs -o fakeroot rootfs.ext4 mnt/
# exclude dev to avoid permission issues
tar --exclude='./dev' -xf rootfs.tar -C mnt/
mkdir mnt/dev # add empty dev to make devtmpfs work

# manual symlink to not use chroot
for applet in $(mnt/usr/bin/busybox --list); do
  [ "$applet" = "busybox" ] && continue
  ln -sf busybox "mnt/usr/bin/$applet" 2>/dev/null || true
done

# non standard location found with strings command:
# strings /usr/bin/busybox | grep default.script
default_script="etc/udhcpc/default.script"
mkdir -p "mnt/$(dirname "$default_script")"
curl -Lo "mnt/$default_script" \
  https://raw.githubusercontent.com/mirror/busybox/refs/heads/master/examples/udhcp/simple.script
chmod +x "mnt/$default_script"

cp "$PREFIX/bin/gvforwarder" mnt/usr/local/bin/
chmod +x mnt/usr/local/bin/gvforwarder

cat >mnt/usr/local/bin/gvforwarder-run <<'EOF'
#!/usr/bin/busybox sh
mkdir -p /var/log
exec /usr/local/bin/gvforwarder >> /var/log/gvforwarder.log 2>&1
EOF
chmod +x mnt/usr/local/bin/gvforwarder-run

cat >mnt/etc/inittab <<'EOF'
::sysinit:/bin/mount -t proc     none /proc
::sysinit:/bin/mount -t sysfs    none /sys
::sysinit:/bin/mount -t devtmpfs none /dev
::sysinit:/bin/ip link set lo up
::respawn:/usr/local/bin/gvforwarder-run
ttyS0::respawn:/sbin/getty -L -n -l /bin/sh ttyS0 115200 vt100
EOF

cat >mnt/usr/sbin/init <<'EOF'
#!/usr/bin/busybox sh
exec /bin/busybox init
EOF
chmod +x mnt/usr/sbin/init

fusermount -u mnt/
rmdir mnt
rm rootfs.tar
mv rootfs.ext4 "${PREFIX?}/"
