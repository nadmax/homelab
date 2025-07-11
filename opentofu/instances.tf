resource "incus_storage_pool" "pool" {
  name   = var.storage_pool
  driver = "btrfs"
}

# Remove the default profile or make it minimal
resource "incus_profile" "no_apparmor_profile" {
  name = "no_apparmor"
  config = {
    "raw.lxc" = "lxc.apparmor.profile=unconfined"
  }
}

resource "incus_profile" "k8s_profile" {
  name = "k8s"
  config = {
    "security.privileged"  = "true"
    "security.nesting"     = "true"
    "linux.kernel_modules" = "ip_tables,ip6_tables,netlink_diag,nf_nat,overlay,br_netfilter"
  }
}

resource "incus_network" "main" {
  name = var.network_name
  config = {
    "ipv4.address" = "192.168.100.1/24"
    "ipv4.nat"     = "true"
    "ipv6.address" = "none"
  }
}

resource "incus_instance" "instances" {
  for_each   = local.instances
  name       = each.key
  image      = var.image_alias
  type       = "container"
  depends_on = [incus_network.main]

  wait_for {
    type = "ipv4"
  }

  config = {
    "limits.memory"        = each.value.memory
    "limits.cpu"           = each.value.cpu
    "cloud-init.user-data" = data.template_file.user_data[each.key].rendered
  }

  profiles = [incus_profile.no_apparmor_profile.name, incus_profile.k8s_profile.name]

  device {
    name = "root"
    type = "disk"
    properties = {
      pool = incus_storage_pool.pool.name
      path = "/"
    }
  }

  device {
    name = "eth0"
    type = "nic"
    properties = {
      network = incus_network.main.name
    }
  }

  running = true
}
