# Firecracker

Example based on getting-started guide from firecracker docs:
<https://github.com/firecracker-microvm/firecracker/blob/main/docs/getting-started.md>

> [!NOTE]  
> [`vsock`](https://www.man7.org/linux/man-pages/man7/vsock.7.html) is
> used to avoid certain host-kernel network interface based risks.


## Basics

First cd into the fc directory:

    cd fc

Install firecracker in the user home (assuming `~/.local/bin` is in
`$PATH`):

    bash -x dl.fc.sh

Get a guest kernel and rootfs from the firecracker CI, for testing:

    bash -x dl.guest.ci.sh
    bash -x build.rootfs.ci.sh

Make sure user has permission to kvm:

    sudo usermod -aG kvm $USER

Remove the sockets from the previous run, and start firecracker:

    bash -x boot.vm.sh

> [!TIP]  
> Executing the `reboot` command inside the vm will shut it down.

Start a listener on the host:

    socat - UNIX-LISTEN:./.local/v.sock_52,fork

In the guest vm after logging in with user and pw == `root`:

     nohup socat TCP-LISTEN:8080,fork VSOCK-CONNECT:2:52 &
     curl localhost:8080

There is also a [tap](./tap/vm.tap0.sh) based network setup, but this
requires manually adjusting the vm config, and perform live operation
with ip and bridge command.

## Integrating with gVisor

> [!NOTE]  
> Manual change of the [boot script](./boot.vm.sh), to point to custom
> kernel and rootfs, required.

Download
[gvisor-tap-vsock](https://github.com/containers/gvisor-tap-vsock)
binaries:

    bash -x dl.gvisor.sh

Build a custom rootfs (assumes debian host):

    bash -x build.rootfs.sh

Also build a custom vmlinux with the required kernel modules such as
vsock and tun enabled:

    bash -x build.kernel.sh

After adjusting the [boot script](./boot.vm.sh):

    bash -x boot.vm.sh

Then on the host to start the gvproxy:

    .local/bin/gvproxy \
      -listen unix:///$(pwd)/.local/v.sock_1024 \
      -listen unix:///tmp/network.sock

The logs inside the guest should report success:

    $ tail -n 3 /var/log/gvforwarder.log
    time="2026-06-09T09:56:07Z" level=info msg="waiting for packets..."
    udhcpc: broadcasting select for 192.168.127.2, server 192.168.127.1
    udhcpc: lease of 192.168.127.2 obtained from 192.168.127.1, lease time 3600

