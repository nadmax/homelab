variable "memory" {
    description = "Container memory size"
    type = number
    default = 8192
}

variable "internal_port" {
    description = "Container internal port"
    type = number
    default = 80
}

variable "external_port" {
    description = "Container external_port"
    type = number
    default = 8080
}

variable "restart_condition" {
    description = "Container restart condition"
    type = string
    default = "unless-stopped"
}
