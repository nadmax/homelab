resource "libvirt_domain" "vms" {
  for_each  = local.vms
  name      = each.key
  memory    = each.value.memory
  vcpu      = each.value.vcpu
  cloudinit = libvirt_cloudinit_disk.cloudinit[each.key].id

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