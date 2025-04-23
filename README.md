# Homelab
The goal is to build a Kubernetes local cluster with 3 VMs.  
I use [OpenTofu](https://opentofu.org/) to create VMs with [libvirt](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs) provider.  
I use [Ansible](https://docs.ansible.com/ansible/latest/index.html) to automate VMs updates, SSH and Kubernetes setup.  

## To implement
- Containers (Docker or Podman)  
- VMs Monitoring (Prometheus/Grafana or Zabbix)  
- Logs monitoring (Depends on VMs monitoring tools)  