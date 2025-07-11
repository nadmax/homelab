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
    if command -v tofu &> /dev/null; then
        echo "OpenTofu is already installed: $(tofu version)"
    else
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
    fi

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
install-incus-packages:
    OS=$(cat .os-type)
    echo "Installing Incus packages..."

    if [ "$OS" = "Debian" ]; then
        sudo apt update
        sudo apt install -y incus
    elif [ "$OS" = "RHEL" ]; then
        sudo dnf install -y incus
    fi

    sudo groupadd incus-admin || echo "Incus group already exists."
    sudo usermod -aG incus-admin $USER || echo "Could not add user to incus group. You may need to add your user manually."

    echo "Starting and enabling Incus service..."
    sudo systemctl start incus
    sudo systemctl enable incus

    sleep 2

    if sudo incus admin init --minimal 2>/dev/null; then
        echo "Incus service is running and initialized."
    else
        echo "Incus service may not be running properly. Let's try to initialize it..."
        echo "Initializing Incus with default settings..."
        sudo incus admin init --auto

        if [ $? -eq 0 ]; then
            echo "Incus initialized successfully."
        else
            echo "Failed to initialize Incus. Please check the system logs."
            exit 1
        fi
    fi

    echo "Verifying virtualization support..."
    if [ -e /dev/kvm ]; then
        echo "KVM is available for hardware acceleration."
    else
        echo "KVM is not available. Instances will run without hardware acceleration."
    fi

    if ! grep -Fxq "export INCUS_SOCKET=/run/incus/unix.socket" ~/.bashrc; then
        echo "Adding INCUS_SOCKET export to .bashrc"
        echo 'export INCUS_SOCKET=/run/incus/unix.socket' >> ~/.bashrc
    else
        echo "INCUS_SOCKET export already exists in .bashrc"
    fi

    echo "Add cloud image..."
     sudo incus image copy images:fedora/42/cloud local: --alias fedora/42/cloud || echo "Failed to copy Fedora image"

    echo "Setup completed successfully!"
    echo "Available commands:"
    echo "  incus list                    - List instances"
    echo "  incus image list             - List available images"
    echo "  incus launch <image> <name>  - Create and start instance"
    echo "  incus exec <name> bash       - Access instance shell"
    echo ""
    echo "NOTE: You may need to log out and back in for group changes to take effect."
    echo "Test with: incus version"

install-tools: detect-os install-incus-packages install-opentofu install-ansible
