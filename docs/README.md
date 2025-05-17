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

## Getting started

### 1. Create VMs
I combined the OpenTofu provisioning and Ansible configuration into a single recipe:  
```bash
just deploy
```

### 2. Cluster Initialization
For convenience, I created a recipe that combines both package updates and Kubernetes cluster setup into a single command:  
```bash
just init-cluster
```

After a couple of minutes, your cluster is setup and ready to be use.  

## Need a Reminder?

To see a list of all available commands and what they do, run:
```bash
just help
```
This will show a helpful summary of all recipes included in the project.  