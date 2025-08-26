terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.7.0"
    }
  }
}

provider "docker" {
    host = "unix:///var/run/docker.sock"
}
