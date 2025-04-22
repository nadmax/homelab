variable "iso_path" {
    description = "Path to Fedora Server ISO"
    type        = string
    default     = "/var/lib/libvirt/images/Fedora-Server-dvd-x86_64-41-1.4.iso"
}

variable "disk_size_gb" {
    description = "Size of each VM disk in GiB"
    type        = number
    default     = 100
}

variable "vm_definitions" {
    description = "Map of VMs with memory and vCPU settings"
    type = map(object({
        memory = number
        vcpu   = number
    }))
    default = {
        controlplane = {
            memory = 8192
            vcpu   = 4
        }
        node01 = {
            memory = 4096
            vcpu   = 2
        }
        node02 = {
            memory = 4096
            vcpu   = 2
        }
    }
}

variable "network_name" {
    description = "Libvirt network name"
    type        = string
    default     = "default"
}