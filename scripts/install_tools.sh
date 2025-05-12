#!/usr/bin/env bash

source "$(dirname $0)/install_libvirtd.sh"
# source "$(dirname $0)/install_opentofu_from_repo.sh"
source "$(dirname $0)/install_opentofu_from_github.sh"

install_ansible() {
    echo "Checking if pip3 is installed..."

    if ! command -v pip3 &> /dev/null; then
        echo "pip3 not found, installing pip..."

        if [ "$OS" = "Debian" ]; then
             apt update
             apt install -y python3-pip
        elif [ "$OS" = "RHEL" ]; then
             dnf install -y python3-pip
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
    fi
}

main
