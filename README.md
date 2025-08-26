# Homelab

The aim of this project is to create a local Kubernetes cluster that can be replicated on your premises.  
It is built with automation and scalability in mind.  
Perfect for learning, testing, and tinkering.  

## Overview

The lab consists of a Docker container deployed by default where inside you can run Kubernetes.
It means you are free to deploy as many containers as you wish, as long as you have the resources to run them.

**Tech Stack:**

- [OpenTofu](https://opentofu.org/): Infrastructure as Code (IaC) to define and deploy the container  
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
