output "vm_names" {
  value = [for vm in libvirt_domain.vms : vm.name]
}