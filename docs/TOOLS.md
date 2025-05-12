# 🗒️ Installing tools

You need virtualization packages, Ansible and OpenTofu on your host machine to install my homelab.  
I create a script that installs required packages.  
To use it, run the following commands:
```bash
chmod -c u+x ./install_tools.sh
sudo ./install_tools.sh
```

To install opentofu, you can choose to install from github or repo.
You must comment the line according to your choice.

```bash
    # source "$(dirname $0)/install_opentofu_from_repo.sh"
    source "$(dirname $0)/install_opentofu_from_github.sh"
```

You need sudo privileges to run the install script as it uses your package manager.  
⚠️ Currently works on Debian and RHEL based distributions.
