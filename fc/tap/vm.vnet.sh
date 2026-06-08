#!/usr/bin/env bash
set -Eeuo pipefail

# example of bridged vms with vlan filtering.
# change vm.boot.sh to use tap1 or tap2

# central bridge with vlan filtering enabled
ip link add br0 type bridge
ip link set dev br0 up
ip link set dev br0 type bridge vlan_filtering 1
ip addr add 172.16.0.1/24 dev br0

# vm link for tap1 with vlan id 10
ip tuntap add dev tap1 mode tap
ip link set tap1 master br0
bridge vlan add dev tap1 vid 10 pvid untagged
ip link set dev tap1 up

# vm link for tap2 with vlan id 20
ip tuntap add dev tap2 mode tap
ip link set tap2 master br0
bridge vlan add dev tap2 vid 20 pvid untagged
ip link set dev tap2 up
