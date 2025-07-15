terraform {
  required_version = "1.10.2"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "2.3.7"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.1.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}
