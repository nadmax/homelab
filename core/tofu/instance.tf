resource "docker_image" "debian" {
  name = "debian:12"
  keep_locally = false
}

resource "docker_container" "container" {
  image = docker_image.debian.image_id
  name = "controlplane"
  command = ["tail", "-f", "/dev/null"]

  ports  {
    internal = var.internal_port
    external = var.external_port
  }

  memory = var.memory
  restart = var.restart_condition

  networks_advanced {
    name = "bridge"
  }

  healthcheck {
    test = ["CMD", "echo", "healthy"]
    interval = "30s"
    timeout = "3s"
    retries = 3
  }
}
