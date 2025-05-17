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
    if [ "$(id -u)" -ne 0 ]; then
        echo "It must be run with sudo privileges."
        exit 1
    fi

    OS=$(cat .os-type)
    if [ "$OS" = "Debian" ]; then 
        install -m 0755 -d /etc/apt/keyrings 
        curl -fsSL https://get.opentofu.org/opentofu.gpg | tee /etc/apt/keyrings/opentofu.gpg >/dev/null 
        curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg >/dev/null 
        chmod a+r /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg 
        echo "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | tee /etc/apt/sources.list.d/opentofu.list > /dev/null 
        echo "deb-src [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | tee -a /etc/apt/sources.list.d/opentofu.list > /dev/null 
        chmod a+r /etc/apt/sources.list.d/opentofu.list 
        apt update 
        apt install -y tofu 
    elif [ "$OS" = "RHEL" ]; then 
        echo '[opentofu]' > /etc/yum.repos.d/opentofu.repo
        echo 'name=opentofu' >> /etc/yum.repos.d/opentofu.repo
        echo 'baseurl=https://packages.opentofu.org/opentofu/tofu/rpm_any/rpm_any/$basearch' >> /etc/yum.repos.d/opentofu.repo
        echo 'repo_gpgcheck=0' >> /etc/yum.repos.d/opentofu.repo
        echo 'gpgcheck=1' >> /etc/yum.repos.d/opentofu.repo
        echo 'enabled=1' >> /etc/yum.repos.d/opentofu.repo
        echo 'gpgkey=https://get.opentofu.org/opentofu.gpg' >> /etc/yum.repos.d/opentofu.repo
        echo '       https://packages.opentofu.org/opentofu/tofu/gpgkey' >> /etc/yum.repos.d/opentofu.repo
        echo 'sslverify=1' >> /etc/yum.repos.d/opentofu.repo
        echo 'sslcacert=/etc/pki/tls/certs/ca-bundle.crt' >> /etc/yum.repos.d/opentofu.repo
        echo 'metadata_expire=300' >> /etc/yum.repos.d/opentofu.repo
        echo '' >> /etc/yum.repos.d/opentofu.repo
        echo '[opentofu-source]' >> /etc/yum.repos.d/opentofu.repo
        echo 'name=opentofu-source' >> /etc/yum.repos.d/opentofu.repo
        echo 'baseurl=https://packages.opentofu.org/opentofu/tofu/rpm_any/rpm_any/SRPMS' >> /etc/yum.repos.d/opentofu.repo
        echo 'repo_gpgcheck=0' >> /etc/yum.repos.d/opentofu.repo
        echo 'gpgcheck=1' >> /etc/yum.repos.d/opentofu.repo
        echo 'enabled=1' >> /etc/yum.repos.d/opentofu.repo
        echo 'gpgkey=https://get.opentofu.org/opentofu.gpg' >> /etc/yum.repos.d/opentofu.repo
        echo '       https://packages.opentofu.org/opentofu/tofu/gpgkey' >> /etc/yum.repos.d/opentofu.repo
        echo 'sslverify=1' >> /etc/yum.repos.d/opentofu.repo
        echo 'sslcacert=/etc/pki/tls/certs/ca-bundle.crt' >> /etc/yum.repos.d/opentofu.repo
        echo 'metadata_expire=300' >> /etc/yum.repos.d/opentofu.repo
    fi
    dnf install -y tofu

[script("sh")]
install-ansible:
    if [ "$(id -u)" -ne 0 ]; then
        echo "It must be run with sudo privileges."
        exit 1
    fi

    OS=$(cat .os-type)
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
    fi
    echo "Installing Ansible using pip3..."
    pip3 install ansible

[script("sh")]
install-virt-packages:
    if [ "$(id -u)" -ne 0 ]; then
        echo "It must be run with sudo privileges."
        exit 1
    fi

    OS=$(cat .os-type)
    echo "Installing virtualization packages..."
    if [ "$OS" = "Debian" ]; then
        apt update
        apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
        apt install -y virtinst libosinfo-bin
    elif [ "$OS" = "RHEL" ]; then
        dnf install -y @virtualization
    fi

    usermod -aG libvirt $USER || echo "Could not add user to libvirt group. You may need to add your user manually."

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

    echo "Setup completed successfully!"
    echo "You can now run virt-manager with: virt-manager"
    echo "NOTE: You may need to log out and back in for group changes to take effect."

install-tools: detect-os install-virt-packages install-ansible install-opentofu