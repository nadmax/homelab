#!/bin/sh

install_pip() {
    echo "Checking if pip3 is installed..."

    if ! command -v pip3 &> /dev/null; then
        echo "pip3 not found, installing pip..."

        if grep -qEi "debian|ubuntu" /etc/os-release; then
            sudo apt update
            sudo apt install -y python3-pip
        elif grep -qEi "rhel|centos|fedora|rocky|almalinux" /etc/os-release; then
            sudo dnf install -y python3-pip
        else
            echo "Unsupported OS detected. Exiting..."
            exit 1
        fi
    else
        echo "pip3 is already installed."
    fi
}

install_ansible_with_pip() {
    echo "Installing Ansible using pip3..."
    pip3 install ansible
}

install_pip
install_ansible_with_pip