set unstable

os := ""

[script("sh")]
detect-os:
    if grep -qEi "debian|ubuntu" /etc/os-release; then 
        echo "Debian" > .os-type
    elif grep -qEi "rhel|centos|fedora|rocky|almalinux" /etc/os-release; then 
        echo "RHEL" > .os-type
    else 
        echo "Unsupported OS detected. Exiting..." 
        exit 1
    fi

    echo "Detected OS: $(cat .os-type)"

[script("sh")]
install-opentofu:
    OS=$(cat .os-type)
    if [ "$OS" = "Debian" ]; then 
        sudo install -m 0755 -d /etc/apt/keyrings 
        curl -fsSL https://get.opentofu.org/opentofu.gpg | sudo tee /etc/apt/keyrings/opentofu.gpg >/dev/null 
        curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | sudo gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg >/dev/null 
        sudo chmod a+r /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg 
        echo "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | sudo tee /etc/apt/sources.list.d/opentofu.list > /dev/null 
        echo "deb-src [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | sudo tee -a /etc/apt/sources.list.d/opentofu.list > /dev/null 
        sudo chmod a+r /etc/apt/sources.list.d/opentofu.list 
        sudo apt update 
        sudo apt install -y tofu 
    elif [ "$OS" = "RHEL" ]; then 
        echo '[opentofu]' | sudo tee /etc/yum.repos.d/opentofu.repo
        echo 'name=opentofu' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'baseurl=https://packages.opentofu.org/opentofu/tofu/rpm_any/rpm_any/$basearch' >> /etc/yum.repos.d/opentofu.repo
        echo 'repo_gpgcheck=0' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'gpgcheck=1' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'enabled=1' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'gpgkey=https://get.opentofu.org/opentofu.gpg' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo '       https://packages.opentofu.org/opentofu/tofu/gpgkey' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'sslverify=1' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'sslcacert=/etc/pki/tls/certs/ca-bundle.crt' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'metadata_expire=300' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo '' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo '[opentofu-source]' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'name=opentofu-source' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'baseurl=https://packages.opentofu.org/opentofu/tofu/rpm_any/rpm_any/SRPMS' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'repo_gpgcheck=0' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'gpgcheck=1' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'enabled=1' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'gpgkey=https://get.opentofu.org/opentofu.gpg' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo '       https://packages.opentofu.org/opentofu/tofu/gpgkey' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'sslverify=1' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'sslcacert=/etc/pki/tls/certs/ca-bundle.crt' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'metadata_expire=300' | sudo tee -a /etc/yum.repos.d/opentofu.repo
    fi
    sudo dnf install -y tofu

[script("sh")]
install-ansible:
    OS=$(cat .os-type)
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
    fi
    echo "Installing Ansible using pip3..."
    pip3 install ansible

[script("sh")]
install-virt-packages:
    OS=$(cat .os-type)
    echo "Installing virtualization packages..."
    if [ "$OS" = "Debian" ]; then
        sudo apt update
        sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
        sudo apt install -y virtinst libosinfo-bin
    elif [ "$OS" = "RHEL" ]; then
        sudo dnf install -y @virtualization
    fi

    sudo usermod -aG libvirt $USER || echo "Could not add user to libvirt group. You may need to add your user manually."

    echo "Starting and enabling libvirt service..."
    sudo systemctl start libvirtd
    sudo systemctl enable libvirtd

    if sudo systemctl is-active --quiet libvirtd; then
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

    echo "Setup completed successfully!"
    echo "You can now run virt-manager with: virt-manager"
    echo "NOTE: You may need to log out and back in for group changes to take effect."

install-tools: detect-os install-virt-packages install-opentofu install-ansible