data "template_file" "user_data" {
  for_each = local.instances
  template = file("${path.module}/cloud-init.yaml")

  vars = {
    hostname       = each.key
    ssh_public_key = local.ssh_public_key
    hashed_passwd  = local.hashed_passwd
  }
}
