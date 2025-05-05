output "vm_names" {
  value = [for vm in libvirt_domain.vms : vm.name]
}

output "cloud_init" {
  value = [for init in data.template_file.user_data : init.rendered]
}