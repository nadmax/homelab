# Homelab Setup

## Before Starting
You need to install Just on your host machine.  
Just is a command runner similar to Make, designed to save and run project-specific commands. It helps streamline development workflows by storing recipes in a justfile.  

You can install Just using one of the following methods:
### On Debian/Ubuntu
```bash
sudo apt update
sudo apt install just
```

### On Fedora
```bash
sudo dnf install just
```

### Using Cargo (cross-platform)
If you have Rust installed:
```bash
cargo install just
```

### Prerequisites for VMs Creation
Before creating VMs, you need to install required tools.  
Run the following recipe:
```bash
sudo just install-tools
```

You will also need two things:
- A `.passwd` file in the `opentofu` directory.
- An SSH public key  

Run the following command to create your `.passwd` file:
```bash
just generate-passwd
```

## 1. Provisioning
Now, you can create the VMs.  
I use OpenTofu, an open-source alternative and compatible with Terraform to create them automatically with allocated resources (memory, vCPU, ...)  

Run the following commands to create VMs:
```bash
just tofu-init
just tofu-plan
just tofu-apply
```
## 2. Ansible Inventory setup
Once the VMs have been created, run the following command to setup the inventory.
```bash
just setup-inventory
```

## 3. Ansible Vault setup 
You need to create your own vault containing your remote user's password to get sudo privileges.  
Run the following command:
```bash
just setup-vault
```

## 4. Update Packages (recommended)
To update packages, run the following playbook:
```bash
just update-packages
```
Run it twice if you want to see the differences.

## 5. k8s Cluster Setup
The most interesting part, the k8s cluster setup.  
The following command allows you to create the cluster:
```bash
just setup-k8s
```

After a couple of minutes, your cluster is setup and ready to be use.