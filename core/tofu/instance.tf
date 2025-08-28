resource "docker_image" "debian_k3s" {
  name         = "rancher/k3s:v1.32.8-k3s1-amd64"
  keep_locally = false
  force_remove = true
}

resource "docker_container" "container" {
  image   = docker_image.debian_k3s.image_id
  name    = "controlplane"
  command = ["server", "--disable=traefik"]
  remove_volumes = true

  ports {
    internal = var.docker_internal_port
    external = var.docker_external_port
  }

  ports {
    internal = var.k8s_internal_port
    external = var.k8s_external_port
  }

  memory     = var.memory
  restart    = var.restart_condition
  privileged = true

  networks_advanced {
    name = "bridge"
  }

  healthcheck {
    test     = ["CMD", "echo", "healthy"]
    interval = "30s"
    timeout  = "5s"
    retries  = 5
  }
}
