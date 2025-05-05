resource "libvirt_volume" "fedora_iso" {
  name   = "fedora-server.iso"
  pool   = "default"
  source = var.iso_path
  format = "raw"
}

resource "libvirt_volume" "vm_disks" {
  for_each = local.vms
  name     = "${each.key}.qcow2"
  pool     = "default"
  format   = "qcow2"
  size     = var.disk_size
}