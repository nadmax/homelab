#!/bin/sh

delete_volumes() {
    volumes=$(virsh vol-list default | awk 'NR > 2 {print $1}')
    if [ -z "$volumes" ]; then
        echo "No volumes found in pool default."
        exit 0
    fi

    for vol in $volumes; do
        echo "Deleting volume: $vol"
        virsh vol-delete "$vol" --pool default
    done
}

delete_vms() {
    virsh undefine controlplane
    virsh undefine node01
    virsh undefine node02
    delete_volumes
}

stop_vms() {
    virsh shutdown controlplane
    virsh shutdown node01
    virsh shutdown node02
}

start_vms() {
    virsh start controlplane
    virsh start node01
    virsh start node02
}

help() {
    echo -e "Usage: $0 [COMMAND]"
    echo "Commands:"
    echo "  start          Start the virtual machines"
    echo "  stop           Shutdown the virtual machines"
    echo "  delete         Delete the virtual machines with their associated volumes"
    echo -e "  help           Show this help message\n"
    echo "Options:"
    echo -e "  -h, --help   Show this help message\n"
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 help"
}

if [ "$#" -eq 0 ]; then
    echo -e "No arguments supplied\n"
    help
    exit 1
fi
case "$1" in
    start) start_vms;;
    stop) stop_vms;;
    delete) delete_vms;;
    -h|--help|help) help;;
    *)
        echo -e "Invalid argument: $1\n"
        help
        exit 1
        ;;
esac