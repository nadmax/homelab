# Homelab Setup

## 1. Download ISO
Before creating VMs, you need to download an iso.
I use Fedora Server 42, you can download it [here](https://download.fedoraproject.org/pub/fedora/linux/releases/42/Server/x86_64/iso/Fedora-Server-dvd-x86_64-42-1.1.iso)  

After downloading it, run the following command:
```bash
sudo mv /path/to/downloaded.iso /var/lib/libvirt/images
```
If you want to use another iso, you have to modify ``variables.tf`` file located in ``opentofu`` folder.

## 2. Provisioner
To reproduce the homelab is to use a provisioner.  
It was the opportunity to use OpenTofu, an open-source alternative and compatible with Terraform.  

Run the following commands to create VMs:
```bash
cd opentofu
tofu init
tofu plan
tofu apply
```

⚠️ Currently, you need to process Fedora Server installation manually.  
I'm working on automated solution.

## 3. SSH Hardening
After installing Fedora Server on each VM, I recommend adding VM IPs in ``/etc/hosts`` on your host machine as follows:
```bash
---
<controlplane-ip> controlplane
<node01-ip> node01
<node02-ip> node02
```

Because, I also recommend using an SSH key to avoid typing user's password on each machine.  
To do so, run the following commands on your host machine:
```bash
ssh-copy-id <username>@controlplane
ssh-copy-id <username>@node01
ssh-copy-id <username>@node02
```

Now you are ready to harden SSH on remote machines.  
You need to have these options in ``/etc/ssh/sshd_config``:
```bash
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
```

Restart SSH to apply modifications:
```bash
sudo systemctl restart sshd
```

## 4. Install python3-libdnf5 package
Connect with SSH on each machines, to install the ``python3-libdnf5``:
```bash
sudo dnf install -y python3-libdnf5
```
Ansible need this package and it isn't available after installing Fedora Server.  

## 5. Ansible Vault setup
At project's root, you can create a ``.vault_pass`` file to avoid typing the vault password all the time.  
Then, you need to create your own vault containing your remote user's password to get sudo privileges.  

To do so, run the following commands at:
```bash
mkdir -p ansible/playbooks/vaults
ansible-vault encrypt_string '<remote-user-password>' --name 'ansible_become_pass' # This will output the encrypted password
ansible-vault create ansible/playbooks/vaults/vault
```
Paste encrypted password you previously had on output, and save the file.

## 6. Update packages (recommended)
To do so, run the following playbook:
```bash
ansible-playbook ansible/playbooks/packages_update.yaml
```
Run it twice if you want to see the differences.

## 7. k8s cluster setup
The most interesting part, the k8s cluster setup.  
Run the following playbook:
```bash
ansible-playbook ansible/playbooks/k8s.yaml
```

After a couple of minutes, your cluster is setup and ready to be use.