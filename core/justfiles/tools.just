set unstable

[script("sh")]
install-opentofu:
    if grep -qEi "debian|ubuntu" /etc/os-release; then 
        sudo install -m 0755 -d /etc/apt/keyrings 
        curl -fsSL https://get.opentofu.org/opentofu.gpg | sudo tee /etc/apt/keyrings/opentofu.gpg >/dev/null 
        curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | sudo gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg >/dev/null 
        sudo chmod a+r /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg 
        echo "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | sudo tee /etc/apt/sources.list.d/opentofu.list > /dev/null 
        echo "deb-src [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | sudo tee -a /etc/apt/sources.list.d/opentofu.list > /dev/null 
        sudo chmod a+r /etc/apt/sources.list.d/opentofu.list 
        sudo apt update 
        sudo apt install -y tofu 
    elif grep -qEi "rhel|centos|fedora|rocky|almalinux" /etc/os-release; then 
        echo '[opentofu]' | sudo tee /etc/yum.repos.d/opentofu.repo
        echo 'name=opentofu' | sudo tee -a /etc/yum.repos.d/opentofu.repo
        echo 'baseurl=https://packages.opentofu.org/opentofu/tofu/rpm_any/rpm_any/$basearch' | sudo tee -a /etc/yum.repos.d/opentofu.repo
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
install-docker:
    echo "Installing virtualization packages..."
    if grep -qEi "debian|ubuntu" /etc/os-release; then
        sudo apt update
        sudo apt install ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    elif grep -qEi "rhel|centos|fedora|rocky|almalinux" /etc/os-release; then
        sudo dnf -y install dnf-plugins-core
        sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
        sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi

    sudo systemctl enable --now docker

install: install-opentofu install-docker
