# Homelab Setup

## 1. Provisioner
The first step to reproduce the homelab is to use a provisioner.  
It was the opportunity to use OpenTofu, an open-source alternative and compatible with Terraform.  

Run the following commands to create VMs:
```bash
cd opentofu
tofu init
tofu plan
tofu apply
```
