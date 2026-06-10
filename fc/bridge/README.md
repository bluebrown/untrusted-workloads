# VSOCK UDS Bridge

A small example of using a tap device inside the guest and socat to
bridge tap->vsock->firecracker->uds->proxy. 

The forwarder is intended to be run inside the fm, and the listener is
intended to run on the host.

