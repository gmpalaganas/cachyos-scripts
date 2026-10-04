#!/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "Error: exactly one argument required (server name suffix)" >&2
    echo "Usage: start-rhel-server <server-suffix>" >&2
    exit 1
fi

virsh -c qemu:///system start "rhel-server-$1"

if [ "$?" -eq 1 ]; then
    printf "RHEL servers status:\n\n" >&2
    virsh -c qemu:///system list --all | awk 'NR<=2 || /rhel-server-/'
fi
