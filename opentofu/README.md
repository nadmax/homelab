# OpenTofu Configuration
This directory contains OpenTofu configuration files for provisioning and managing VMs.  
Below is a brief description of each file and its role in the deployment process.  

## File Descriptions
### ``cloud-init.tf``
Defines the mechanism to embed cloud-init configuration into the instance(s).  
This file typically references a local file (e.g., cloud-init.yaml) and passes its contents as user data to the virtual machines during boot.  

### ``cloud-init.yaml``
A YAML-formatted cloud-init script used to initialize virtual machines.  
This can include package installations, file creation, user setup, and other instance-specific configuration actions performed on first boot.

### ``instance.tf``
Declares the compute instance(s) to be created.  
This file defines attributes such as instance type, image ID, networking settings, and links to cloud-init for provisioning.

### ``local.tf``
Contains local values used throughout the configuration.  
These are intermediate variables useful for simplifying expressions or improving configuration readability and reusability.

### ``outputs.tf``
Defines output values to display after the configuration is applied.  
These might include public IP addresses, instance IDs, or other useful deployment results for users or scripts to consume.

### ``provider.tf``
Configures the OpenTofu provider and specifies authentication details, regions, or other provider-specific settings required to interact with the target infrastructure platform.

### ``variables.tf``
Declares input variables used throughout the configuration.  
This file includes variable names, descriptions, default values (if any), and type constraints to ensure valid input during runtime.

### ``volumes.tf``
Defines any storage resources, such as block volumes, attached disks, or file systems.  
It may include volume creation and attachment to specific instances.

### ``.passwd``
This file is used by the cloud-init configuration.  
You need to create it yourself, because it must contain the hash of your user password.