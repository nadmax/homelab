terraform {
  required_version = "v1.10.2"
  required_providers {
    incus = {
      source  = "lxc/incus"
      version = "0.3.1"
    }
  }
}

provider "incus" {
}
