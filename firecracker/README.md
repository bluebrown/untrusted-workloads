# Firecracker

Example based on getting-started guide from firecracker docs:
<https://github.com/firecracker-microvm/firecracker/blob/main/docs/getting-started.md>

> [!NOTE]  
> [`vsock`](https://www.man7.org/linux/man-pages/man7/vsock.7.html) is
> used to avoid certain host-kernel network interface based risks.


## Basics

Install firecracker in the user home (assuming `~/.local/bin` is in
`$PATH`):

    bash -x recipe/firecracker.sh

Get a guest kernel and rootfs from the firecracker CI, for testing:

    bash -x recipe/firecracker.guest.sh
    bash -x recipe/firecracker.rootfs.sh

Make sure user has permission to kvm:

    sudo usermod -aG kvm $USER

Remove the sockets from the previous run, and start firecracker:

    bash -x firecracker/boot.sh

> [!TIP]  
> Executing the `reboot` command inside the vm will shut it down.

Start a listener on the host:

    socat - UNIX-LISTEN:./.local/v.sock_52,fork

In the guest vm after logging in with user and pw == `root`:

     nohup socat TCP-LISTEN:8080,fork VSOCK-CONNECT:2:52 &
     curl localhost:8080

## Integrating with gVisor

Download
[gvisor-tap-vsock](https://github.com/containers/gvisor-tap-vsock)
binaries:

    bash -x recipe/gvisor.tap-vsock.sh

Build a custom rootfs (assumes debian host):

    bash -x recipe/rootfs.mmdebstrap.sh

Also build a custom vmlinux with the required kernel modules such as
vsock and tun enabled:

    bash -x recipe/vmlinux.fc.sh

Starting the VM after telling firecracker to use the custom kernel and
rootfs.

     export FC_CONFIG=./firecracker/boot.custom.vsock.json
     bash -x firecracker/boot.sh

Then on the host to start the gvproxy:
    
    bash -x firecracker/proxy.sh

The logs inside the guest should report success:

    cat /var/log/gvforwarder.log

The ip can be verified with the ip command:

    ip addr show tap0

Now something like a curl request should work:

    curl redhat.com
