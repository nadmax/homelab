# Homelab

The aim of this project is to create a local k3s cluster that can be replicated on your premises.  
It is built with automation and scalability in mind.  
Perfect for learning, testing, and tinkering.  

## Overview

The lab consists of a k3s Docker container.
It means you are free to deploy as many containers as you wish, as long as you have the resources to run them.

**Tech Stack:**

- [OpenTofu](https://opentofu.org/): Infrastructure as Code (IaC) to define and deploy the container  
- [k3s](https://k3s.io/): A Kubernetes distribution designed for production workloads
- [Docker](https://www.docker.com/): Container runtime for k3s node
- [Terratest](https://terratest.gruntwork.io/): A Go library for testing infrastructure
- [Just](https://just.systems/): Command runner to simplify project automation and scripting  

## Documentation

The documentation is available [here](https://github.com/nadmax/homelab/blob/master/docs/README.md).  
**Please read it carefully!**

## Contributing

All contributions are welcome and appreciated.  
Please make sur to read the [contributing guide](https://github.com/nadmax/homelab/blob/master/CONTRIBUTING.md) for guidelines before submitting a pull request.
