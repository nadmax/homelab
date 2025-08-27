variable "memory" {
    description = "Container memory size"
    type = number
    default = 8192
}

variable "docker_internal_port" {
    description = "Container internal port"
    type = number
    default = 80
}

variable "docker_external_port" {
    description = "Container external port"
    type = number
    default = 8080
}

variable "k8s_internal_port" {
  description = "Port inside the container where the Kubernetes API server listens"
  type = number
  default = 6443
}

variable "k8s_external_port" {
  description = "Port on the host machine mapped to the container's Kubernetes API server port"
  type = number
  default = 16443
}

variable "restart_condition" {
    description = "Container restart condition"
    type = string
    default = "unless-stopped"
}
