# OpenTofu Configuration

This directory contains OpenTofu configuration files for provisioning and managing containers.  
Below is a brief description of each file and its role in the deployment process.  

## File Descriptions

### ``instance.tf``

Declares the compute instance(s) to be created.  
This file defines attributes such as container image, container memory, etc...

### ``provider.tf``

Specifies Docker provider with its options.

### ``variables.tf``

Declares input variables used throughout the configuration.  
This file includes variable names, descriptions, default values (if any), and type constraints to ensure valid input during runtime.

