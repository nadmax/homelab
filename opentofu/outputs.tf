output "cloud_init" {
  value = [for init in data.template_file.user_data : init.rendered]
}

output "vm_ipv4_addresses" {
  description = "IPv4 addresses of all VMs"
  value = {
    for name, vm in libvirt_domain.vms : name => vm.network_interface[0].addresses[0]
  }
}

output "ssh_private_key" {
  description = "Generated SSH private key"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "ssh_public_key" {
  description = "Generated SSH public key"
  value       = tls_private_key.ssh_key.public_key_openssh
}
