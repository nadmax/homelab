resource "libvirt_volume" "rootfs_base" {
  for_each = local.vms
  name     = "${each.key}.qcow2"
  pool     = "default"
  source   = var.qcow2_path
  format   = "qcow2"
}

resource "libvirt_volume" "rootfs" {
  for_each       = local.vms
  name           = "${each.key}-resized.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.rootfs_base[each.key].id
  size           = var.disk_size
}