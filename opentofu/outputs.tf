output "cloud_init" {
  value = [for init in data.template_file.user_data : init.rendered]
}

output "instances_ipv4_addresses" {
  description = "IPv4 addresses of all instances"
  value = {
    for name, instance in incus_instance.instances : name => instance.ipv4_address
  }
}
