variable "image_alias" {
  description = "Incus image alias or fingerprint"
  type        = string
  default     = "fedora/42/cloud"
}

variable "storage_pool" {
  description = "Incus storage pool name"
  type        = string
  default     = "default"
}

variable "instances" {
  description = "Map of instances with memory and CPU settings"
  type = map(object({
    memory = string
    cpu    = string
  }))
  default = {
    controlplane = {
      memory = "8GiB"
      cpu    = "4"
    }
    node01 = {
      memory = "4GiB"
      cpu    = "2"
    }
    node02 = {
      memory = "4GiB"
      cpu    = "2"
    }
  }
}

variable "hashed_password" {
  description = "Hashed password for user account"
  type        = string
  default     = ""
  sensitive   = true
}

variable "network_name" {
  description = "Incus network name"
  type        = string
  default     = "incusbr0"
}

variable "password_file_path" {
  description = "Path to the hashed password file (used if hashed_password is empty)"
  type        = string
  default     = ".passwd"
}

variable "ssh_public_key_content" {
  description = "SSH public key content"
  type        = string
  default     = ""
}

variable "root_disk_size" {
  description = "Size of root disk (e.g., '100GiB')"
  type        = string
  default     = "100GiB"
}
