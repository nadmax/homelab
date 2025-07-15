data "cloudinit_config" "user_data" {
  for_each = local.vms

  part {
    content_type = "text/cloud-config"
    content = yamlencode({
      hostname = each.key
      fqdn     = "${each.key}.localdomain"
      prefer_fqdn_over_hostname = false
      create_hostname_file = true

      network = {
        version = 2
        ethernets = {
          eth0 = {
            dhcp4 = true
          }
        }
      }

      ssh_pwauth = false
      disable_root = true
      allow_public_ssh_keys = true

      users = [{
        name = "user01"
        shell = "/bin/bash"
        sudo = "ALL=(ALL) ALL"
        groups = ["wheel"]
        lock_passwd = true
        ssh_authorized_keys = [tls_private_key.ssh_key.public_key_openssh]
      }]

      packages = [
        "python3-libdnf5",
        "vim",
        "firewalld",
        "containerd"
      ]

      yum_repos = {
        kubernetes = {
          name = "Kubernetes"
          baseurl = "https://pkgs.k8s.io/core:/stable:/v1.33/rpm/"
          gpgcheck = true
          gpgkey = "https://pkgs.k8s.io/core:/stable:/v1.33/rpm/repodata/repomd.xml.key"
          enabled = true
        }
      }

      yum_repo_dir = "/etc/yum.repos.d/"

    })
  }
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  for_each  = local.vms
  name      = "${each.key}-cloudinit.iso"
  pool      = "default"
  user_data = data.cloudinit_config.user_data[each.key].rendered
}
