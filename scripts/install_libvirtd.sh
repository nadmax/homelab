#!/usr/bin/env sh

install_virt_packages() {
    # https://github.com/zjagust/kvm-qemu-install-script/blob/main/kvm-qemu-autoinstall.sh
    # https://www.golinuxcloud.com/virt-install-examples-kvm-virt-commands-linux/
    # https://www.linuxtechi.com/how-to-install-kvm-on-ubuntu-22-04/
    echo "Check if Virtualization is enabled"

    echo "Installing virtualization packages..."
    if [ "$OS" = "Debian" ]; then
        apt update
        apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
        apt install -y virtinst libosinfo-bin
        usermod -aG libvirt $USER || echo "Could not add user to libvirt group. You may need to add your user manually."
    elif [ "$OS" = "RHEL" ]; then
        dnf install -y @virtualization virt-manager libvirt qemu-kvm
        usermod -aG libvirt $USER || echo "Could not add user to libvirt group. You may need to add your user manually."
    fi

    echo "Starting and enabling libvirt service..."
    systemctl start libvirtd
    systemctl enable libvirtd
    if systemctl is-active --quiet libvirtd; then
        echo "Libvirt service is running."
    else
        echo "Failed to start libvirt service. Please check the system logs."
        exit 1
    fi

    echo "Verifying KVM module..."
    if lsmod | grep -q kvm; then
        echo "KVM module is loaded."
    else
        echo "KVM module is not loaded. Please check if your CPU supports virtualization and if it's enabled in BIOS."
        exit 1
    fi

    echo "Virtualization setup information:"
    echo "Libvirt status: $(systemctl is-active libvirtd)"
    echo "Libvirt enabled on boot: $(systemctl is-enabled libvirtd)"
    echo "Setup completed successfully!"
    echo "You can now run virt-manager with the following command:"
    echo "$ virt-manager"
    echo ""
    echo "NOTE: You may need to log out and log back in for group changes to take effect."
}
