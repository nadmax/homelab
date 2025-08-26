output "cloud_init" {
  value = [for init in data.template_file.user_data : init.rendered]
}

output "vm_ipv4_addresses" {
  description = "IPv4 addresses of all VMs"
  value = {
    for name, vm in libvirt_domain.vms : name => vm.network_interface[0].addresses[0]
  }
}