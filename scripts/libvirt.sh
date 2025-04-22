#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root or with sudo privileges."
    exit 1
fi

echo_step "Detecting Linux distribution..."
if [ -f /etc/debian_version ]; then
    DISTRO="debian"
    echo "Debian/Ubuntu-based distribution detected."
elif [ -f /etc/fedora-release ]; then
    DISTRO="fedora"
    echo "Fedora distribution detected."
else
    echo "Unsupported distribution. This script supports Debian/Ubuntu and Fedora only."
    exit 1
fi

echo_step "Installing virtualization packages..."
if [ "$DISTRO" = "debian" ]; then
    apt update
    apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
    apt install -y virtinst libosinfo-bin
    usermod -aG libvirt $USER || echo "Could not add user to libvirt group. You may need to add your user manually."
elif [ "$DISTRO" = "fedora" ]; then
    dnf install -y @virtualization virt-manager libvirt qemu-kvm
    usermod -aG libvirt $USER || echo "Could not add user to libvirt group. You may need to add your user manually."
fi

echo_step "Starting and enabling libvirt service..."
systemctl start libvirtd
systemctl enable libvirtd
if systemctl is-active --quiet libvirtd; then
    echo "Libvirt service is running."
else
    echo "Failed to start libvirt service. Please check the system logs."
    exit 1
fi

echo_step "Verifying KVM module..."
if lsmod | grep -q kvm; then
    echo "KVM module is loaded."
else
    echo "KVM module is not loaded. Please check if your CPU supports virtualization and if it's enabled in BIOS."
    exit 1
fi

echo_step "Virtualization setup information:"
echo "Libvirt status: $(systemctl is-active libvirtd)"
echo "Libvirt enabled on boot: $(systemctl is-enabled libvirtd)"
echo_step "Setup completed successfully!"
echo "You can now run virt-manager with the following command:"
echo "$ virt-manager"
echo ""
echo "NOTE: You may need to log out and log back in for group changes to take effect."
