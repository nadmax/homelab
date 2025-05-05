# Homelab Setup

## 0. The beginning
Before creating VMs, you need to have two things:
- A ``.passwd`` file in the ``opentofu`` directory.
- An SSH public key  

The ``.passwd`` must contain the hashed password of your user. 
Run the following command, enter your password and press enter:
```bash
mkpasswd --method=SHA-512 --rounds=4096
```
Paste the output of the previous command in the ``.passwd`` file.  

See [``cloud-init.yaml``](https://github.com/nadmax/homelab/blob/master/opentofu/cloud-init.yaml), [``cloud-init.tf``](https://github.com/nadmax/homelab/blob/master/opentofu/cloud-init.tf) and [``variables.tf``](https://github.com/nadmax/homelab/blob/master/opentofu/variables.tf) for more details on how it is configured.

## 1. Provisioner
Now, you can create the VMs.  
I use OpenTofu, an open-source alternative and compatible with Terraform to create them automatically with allocated resources (memory, vCPU, ...)  

Run the following commands to create VMs:
```bash
cd opentofu
tofu init
tofu plan
tofu apply
```

## 2. Ansible Vault setup
At project's root, you can create a ``.vault_pass`` file to avoid typing the vault password all the time.  
Then, you need to create your own vault containing your remote user's password to get sudo privileges:  
```bash
mkdir -p ansible/playbooks/vaults
ansible-vault encrypt_string '<remote-user-password>' --name 'ansible_become_pass' # This will output the encrypted password
ansible-vault create ansible/playbooks/vaults/vault
```
Paste the encrypted password you previously had on output, and save the file.

## 3. Update packages (recommended)
To update packages, run the following playbook:
```bash
ansible-playbook ansible/playbooks/packages_update.yaml
```
Run it twice if you want to see the differences.

## 4. k8s cluster setup
The most interesting part, the k8s cluster setup.  
The following playbook allows you to create the cluster:
```bash
ansible-playbook ansible/playbooks/k8s.yaml
```

After a couple of minutes, your cluster is setup and ready to be use.