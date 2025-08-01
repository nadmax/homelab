# Homelab

The aim of this project is to create a local Kubernetes cluster that can be replicated on your premises.  
It is built with automation and scalability in mind.  
Perfect for learning, testing, and tinkering.  

## Overview

The architecture consists of **three virtual machines** orchestrated into a Kubernetes cluster.  
Each VM is provisioned, configured, and container-ready with Docker and Kubernetes.

**Tech Stack:**

- [OpenTofu](https://opentofu.org/): Infrastructure as Code (IaC) to define and deploy VMs  
- [Cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html): Associated with OpenTofu to define VMs users and metadatas
- [libvirt](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs):  Local virtual machine management  
- [Ansible](https://docs.ansible.com/ansible/latest/index.html): Automates k8s cluster setup and configuration tasks  
- [Docker](https://www.docker.com/): Container runtime for workloads  
- [Kubernetes](https://kubernetes.io/): Container orchestration for deploying and managing applications  
- [Just](https://just.systems/): Command runner to simplify project automation and scripting  

## Documentation

The documentation is available [here](https://github.com/nadmax/homelab/blob/master/docs/README.md).  
**Please read it carefully!**

## Contributing

All contributions are welcome and appreciated.  
Please make sur to read the [contributing guide](https://github.com/nadmax/homelab/blob/master/CONTRIBUTING.md) for guidelines before submitting a pull request.
