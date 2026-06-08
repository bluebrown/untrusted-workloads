# Firecracker

Example based on getting-started guide from firecracker docs:
<https://github.com/firecracker-microvm/firecracker/blob/main/docs/getting-started.md>

First cd into the fc directory:

    cd fc

Install firecracker in the user home, assuming ~/.local/bin is in $PATH.

    bash -x fc.get.sh

Get a guest kernel and rootfs from the firecracker CI, for testing:

    bash -x guest.get.sh

Make sure user has permission to kvm:

    sudo usermod -aG kvm $USER

> [!NOTE]  
> Review the files in [.local](./.local) and adjust the [vm
> config](./vm_config.json) before starting fire cracker.

Remove the socket from the previous run, and start firecracker:

    rm -f .local/firecracker.socket
    firecracker  \
      --api-sock $PWD/.local/firecracker.socket \
      --enable-pci \
      --config-file vm_config.json

> [!TIP]  
> Executing the `reboot` command inside the vm will shut it down.

