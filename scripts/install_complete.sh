#!/bin/sh

install_opentofu_for_rhel() {
        cat >/etc/yum.repos.d/opentofu.repo << EOF
[opentofu]
name=opentofu
baseurl=https://packages.opentofu.org/opentofu/tofu/rpm_any/rpm_any/\$basearch
repo_gpgcheck=0
gpgcheck=1
enabled=1
gpgkey=https://get.opentofu.org/opentofu.gpg
       https://packages.opentofu.org/opentofu/tofu/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

[opentofu-source]
name=opentofu-source
baseurl=https://packages.opentofu.org/opentofu/tofu/rpm_any/rpm_any/SRPMS
repo_gpgcheck=0
gpgcheck=1
enabled=1
gpgkey=https://get.opentofu.org/opentofu.gpg
       https://packages.opentofu.org/opentofu/tofu/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
EOF
    sudo yum install -y tofu
}

install_opentofu_for_debian() {    
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://get.opentofu.org/opentofu.gpg | sudo tee /etc/apt/keyrings/opentofu.gpg >/dev/null
    curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | sudo gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg >/dev/null
    sudo chmod a+r /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg
    echo \
    "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main
    deb-src [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | \
    sudo tee /etc/apt/sources.list.d/opentofu.list > /dev/null
    sudo chmod a+r /etc/apt/sources.list.d/opentofu.list
    sudo apt-get update
    sudo apt-get install -y tofu
}

install_ansible() {
    echo "Checking if pip3 is installed..."

    if ! command -v pip3 &> /dev/null; then
        echo "pip3 not found, installing pip..."

        if [ "$OS" = "Debian" ]; then
            sudo apt update
            sudo apt install -y python3-pip
        elif [ "$OS" = "RHEL" ]; then
            sudo dnf install -y python3-pip
        else
            echo "Unsupported OS detected. Exiting..."
            exit 1
        fi
    else
        echo "pip3 is already installed."
        echo "Installing Ansible using pip3..."
        pip3 install ansible
    fi
}

install_virt_packages() {
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

main() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run with sudo privileges."
        exit 1
    fi

    if grep -qEi "debian|ubuntu" /etc/os-release; then
        OS="Debian"
    elif grep -qEi "rhel|centos|fedora|rocky|almalinux" /etc/os-release; then
        OS="RHEL"
    else
        echo "Unsupported OS detected. Exiting..."
        exit 1
    fi

    install_virt_packages
    install_ansible
    if [ "$OS" = "Debian" ]; then
        install_opentofu_for_debian
    elif [ "$OS" = "RHEL" ]; then
        install_opentofu_for_rhel
}

main