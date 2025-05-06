# 🏡 Homelab
![logo](https://github.com/nadmax/homelab/blob/master/assets/logo.png)

A personal project to set up a local Kubernetes cluster using virtual machines.  
This homelab is built with automation and scalability in mind.  
Perfect for learning, testing, and tinkering.  

## Overview

The architecture consists of **three virtual machines** orchestrated into a Kubernetes cluster.  
Each VM is provisioned, configured, and container-ready with Docker and Kubernetes.

**Tech Stack:**

- [OpenTofu](https://opentofu.org/) — Infrastructure as Code (IaC) to define and deploy VMs  
- [Cloud-init](https://cloudinit.readthedocs.io/en/latest/index.html) — Associated with OpenTofu to define VMs users and metadatas
- [libvirt](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs) — Local virtual machine management  
- [Ansible](https://docs.ansible.com/ansible/latest/index.html) — Automates setup and configuration tasks  
- [Docker](https://www.docker.com/) — Container runtime for workloads  
- [Kubernetes](https://kubernetes.io/) — Container orchestration for deploying and managing applications  

## Features

- Automated VM provisioning and container runtime setup  
- Local Kubernetes cluster bootstrapped and ready for deployments  
- Modular infrastructure code and playbooks for easy maintenance  

## 🛠️ Planned Improvements

- 🔴 **Centralized Logging** — Will depend on the selected monitoring stack  

## 🗒️ Docs
Docs are available [here](https://github.com/nadmax/homelab/blob/master/docs).  
**Please read them carefully!**