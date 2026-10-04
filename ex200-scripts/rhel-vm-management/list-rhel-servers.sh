#!/bin/env bash

if [ "$#" -ge 1 ]; then
    echo "Error: command does not take arguments" >&2
    echo "Usage: list-rhel-servers" >&2
    exit 1
fi

virsh -c qemu:///system list --all | awk 'NR<=2 || /rhel-server-/'
