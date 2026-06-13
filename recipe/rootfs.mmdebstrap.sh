#!/usr/bin/env sh
set -eu

# options

image_size="350M"
attach_tty=1

# $ sudo apt install mmdebstrap libarchive-tools e2fsprogs fuse fuse2fs

: "${PREFIX:=$PWD/.local}"

if ! test -x "$PREFIX/bin/gvforwarder"; then
  printf "run gvisor.tap-vsock.sh first"
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
cd "$tmpdir"

mmdebstrap \
  --mode=unshare \
  --variant=minbase \
  --include=busybox-static,socat,curl,ca-certificates,openssh-server \
  --dpkgopt="path-exclude=/usr/share/doc/*" \
  --dpkgopt="path-exclude=/usr/share/man/*" \
  --dpkgopt="path-exclude=/usr/share/locale/*" \
  bookworm \
  rootfs.tar

truncate -s "$image_size" rootfs.ext4
mkfs.ext4 rootfs.ext4

# use fuse2fs to avoid running with root permissions
mkdir -p mnt
fuse2fs -o fakeroot rootfs.ext4 mnt/
# exclude dev to avoid permission issues
tar --exclude='./dev' --exclude='./temp' -xf rootfs.tar -C mnt/
mkdir -p mnt/dev/pts

# create proper world writebale tmp dir
mkdir -p mnt/tmp && chmod 1777 mnt/tmp

# manual symlink to not use chroot
for applet in $(mnt/usr/bin/busybox --list); do
  [ "$applet" = "busybox" ] && continue
  ln -sf busybox "mnt/usr/bin/$applet" 2>/dev/null || true
done

# busybox uses udhcpc as dhcp client. gvproxy will provide
# the lease but a script to configure the guest is required.
# non standard location found with strings command:
# strings /usr/bin/busybox | grep default.script
default_script="etc/udhcpc/default.script"
mkdir -p "mnt/$(dirname "$default_script")"
curl -Lo "mnt/$default_script" \
  https://raw.githubusercontent.com/mirror/busybox/refs/heads/master/examples/udhcp/simple.script
chmod +x "mnt/$default_script"

# the forwarder agents connects a tap to a vsock and runs
# a dhcp client to get a lease
cp "$PREFIX/bin/gvforwarder" mnt/usr/local/bin/
chmod +x mnt/usr/local/bin/gvforwarder

# small shim to capture the logs
cat >mnt/usr/local/bin/gvforwarder-run <<'EOF'
#!/usr/bin/busybox sh
mkdir -p /var/log
exec /usr/local/bin/gvforwarder >> /var/log/gvforwarder.log 2>&1
EOF
chmod +x mnt/usr/local/bin/gvforwarder-run

# add ssh ssh keys, to connect through the gvproxy port forwarding
ssh-keygen -t ed25519 -f guest0 -N ''
mkdir -p mnt/root/.ssh
cp guest0.pub mnt/root/.ssh/authorized_keys
chown -R 0:0 mnt/root
chmod -R 600 mnt/root/.ssh

# magic boot values to access mmio boot timer.
#  requires to run firecreacker with --boot-timer
# https://github.com/firecracker-microvm/firecracker/blob/255ecb950b34455eb7701e46321c0ef0180e0a70/resources/rebuild.sh#L71
MAGIC_BOOT_ADDRESS=0xc0000000
MAGIC_BOOT_VALUE=123

# use busybox init system
cat >mnt/etc/inittab <<EOF
::sysinit:/bin/mkdir -p /dev/pts /run/sshd

::sysinit:/bin/mount -t proc    none /proc
::sysinit:/bin/mount -t sysfs   none /sys
::sysinit:/bin/mount -t tmpfs   tmpfs /tmp
::sysinit:/bin/mount -t devpts  devpts /dev/pts -o gid=5,mode=620,ptmxmode=666

::sysinit:/bin/ip link set lo up
::sysinit:/bin/devmem $MAGIC_BOOT_ADDRESS 8 $MAGIC_BOOT_VALUE

::respawn:/usr/sbin/sshd
::respawn:/usr/local/bin/gvforwarder-run
EOF

# optionally attach tty when firecracker boots the guest
if [ "$attach_tty" = 1 ]; then
  printf "ttyS0::respawn:/sbin/getty -L -n -l /bin/sh ttyS0 115200 vt100\n" >>mnt/etc/inittab
fi

# cleanup
fusermount -u mnt/
rmdir mnt
rm rootfs.tar

# publish artifact
mv rootfs.ext4 guest0 guest0.pub "${PREFIX?}/"
