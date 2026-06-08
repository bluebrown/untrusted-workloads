# Firecracker

Example based on getting-started guide from firecracker docs:
<https://github.com/firecracker-microvm/firecracker/blob/main/docs/getting-started.md>

> [!NOTE]  
> [`vsock`](https://www.man7.org/linux/man-pages/man7/vsock.7.html) is
> used to avoid certain host-kernel network interface based risks.

First cd into the fc directory:

    cd fc

Install firecracker in the user home (assuming `~/.local/bin` is in
`$PATH`):

    bash -x dl.fc.sh

Get a guest kernel and rootfs from the firecracker CI, for testing:

    bash -x dl.guest.sh

Make sure user has permission to kvm:

    sudo usermod -aG kvm $USER

Remove the sockets from the previous run, and start firecracker:

    bash -x vm.boot.sh

> [!TIP]  
> Executing the `reboot` command inside the vm will shut it down.

Start a listener on the host:

    socat - UNIX-LISTEN:./.local/v.sock_52,fork

In the guest vm after logging in with user and pw == `root`:

     nohup socat TCP-LISTEN:8080,fork VSOCK-CONNECT:2:52 &
     curl localhost


There is also a [tap](./tap/vm.tap0.sh) based network setup, but this
requires manually adjusting the vm config, and perform live operation
with ip and bridge command.
