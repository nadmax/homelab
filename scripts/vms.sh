#!/bin/sh

delete_vms() {
    virsh undefine controlplane
    virsh undefine node01
    virsh undefine node02
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
    echo "  start          Start the virtual machines: controlplane, node01, node02"
    echo "  stop           Shutdown the virtual machines: controlplane, node01, node02"
    echo "  delete         Delete the virtual machines: controlplane, node01, node02"
    echo -e "  help           Show this help message\n"
    echo "Options:"
    echo -e "  -h, --help   Show this help message\n"
    echo "Examples:"
    echo "  $0 start      (Start all VMs)"
    echo "  $0 help       (Display help)"
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