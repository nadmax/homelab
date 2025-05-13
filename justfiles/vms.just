start-vms:
    @echo "Starting VMs..."
    @virsh start controlplane
    @virsh start node01
    @virsh start node02

stop-vms:
    @echo "Stopping VMs..."
    @virsh shutdown controlplane
    @virsh shutdown node01
    @virsh shutdown node02

[script("sh")]
delete-volumes:
    volumes=$(virsh vol-list default | awk 'NR > 2 {print $1}')
    if [ -z "$$volumes" ]; then
        echo "No volumes found in pool default."
        exit 0
    fi

    for vol in $volumes; do 
        echo "Deleting volume: $vol"
        virsh vol-delete "$vol" --pool default
    done

delete-vms: 
    @echo "Undefining VMs..."
    @virsh undefine controlplane
    @virsh undefine node01
    @virsh undefine node02

reset-vms: stop-vms delete-vms delete-volumes