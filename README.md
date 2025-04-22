# Homelab
The goal is to build a Kubernetes local cluster with 3 VMs.  
I use Terraform to create VMs with [libvirt](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs) provider.  
I use Ansible to automate VMs updates, SSH and Kubernetes setup.  

## Unimplemented
❌ Containers (Docker or Podman)  
❌ VMs Monitoring (Prometheus/Grafana or Zabbix)  
❌ Logs monitoring (Depends on VMs monitoring tools)  