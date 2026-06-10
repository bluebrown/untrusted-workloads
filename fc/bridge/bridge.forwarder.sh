#!/bin/sh
exec socat -dd -D VSOCK-CONNECT:2:52 TUN:172.16.42.2/24,up
