resource "incus_instance" "instances" {
  for_each = local.instances
  name     = each.key
  image    = var.image_alias
  type     = "virtual-machine"

  config = {
    "limits.memory"        = each.value.memory
    "limits.cpu"           = each.value.cpu
    "cloud-init.user-data" = data.template_file.user_data[each.key].rendered
  }

  device {
    name = "root"
    type = "disk"
    properties = {
      pool = var.storage_pool
      path = "/"
      size = var.root_disk_size
    }
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = var.network_name
    }
  }

  running = true
}
