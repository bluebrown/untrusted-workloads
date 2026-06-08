# Firecracker

Example based on getting-started guide from firecracker docs:
<https://github.com/firecracker-microvm/firecracker/blob/main/docs/getting-started.md>

First cd into the fc directory:

    cd fc

Install firecracker in the user home (assuming `~/.local/bin` is in
`$PATH`):

    bash -x dl.fc.sh

Get a guest kernel and rootfs from the firecracker CI, for testing:

    bash -x dl.guest.sh

Make sure user has permission to kvm:

    sudo usermod -aG kvm $USER

Create the tap device:

    bash -x vm.tap0.sh

Remove the socket from the previous run, and start firecracker:

    bash -x vm.boot.sh

> [!TIP]  
> Executing the `reboot` command inside the vm will shut it down.

