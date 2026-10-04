#!/bin/env bash

if [ "$1" = "-a" ] || [ "$1" = "--all" ]; then
    if [ "$#" -ne 1 ]; then
        echo "Error: -a/--all does not take additional arguments" >&2
        echo "Usage: shutdown-rhel-server -a|--all" >&2
        exit 1
    fi

    virsh -c qemu:///system list | awk '/rhel-server-/ {print $2}' | xargs -I {} virsh -c qemu:///system shutdown {}
    exit 0
fi

if [ "$#" -ne 1 ]; then
    echo "Error: exactly one argument required (server name suffix)" >&2
    echo "Usage: shutdown-rhel-server <server-suffix>" >&2
    echo "       shutdown-rhel-server -a|--all" >&2
    exit 1
fi

virsh -c qemu:///system shutdown "rhel-server-$1"

if [ "$?" -eq 1 ]; then
    printf "RHEL servers status:\n\n" >&2
    virsh -c qemu:///system list --all | awk 'NR<=2 || /rhel-server-/'
fi
