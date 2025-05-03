terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "fedora_iso" {
  name   = "fedora-server.iso"
  pool   = "default"
  source = var.iso_path
  format = "raw"
}

locals {
  vms = var.vm_definitions
}

resource "libvirt_volume" "vm_disks" {
  for_each = local.vms

  name   = "${each.key}.qcow2"
  pool   = "default"
  format = "qcow2"
  size   = var.disk_size_gb * 1024 * 1024 * 1024
}

resource "libvirt_domain" "vms" {
  for_each = local.vms

  name   = each.key
  memory = each.value.memory
  vcpu   = each.value.vcpu

  disk {
    volume_id = libvirt_volume.vm_disks[each.key].id
  }

  disk {
    file = libvirt_volume.fedora_iso.id
  }

  network_interface {
    network_name   = var.network_name
    wait_for_lease = false
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }

  boot_device {
    dev = ["cdrom", "hd"]
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}