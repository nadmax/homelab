locals {
  instances = var.instances
  hashed_passwd = var.hashed_password != "" ? var.hashed_password : (
    fileexists(var.password_file_path) ? file(var.password_file_path) : ""
  )
  resolved_password_path = var.password_file_path == ".passwd" ? "${path.module}/.passwd" : var.password_file_path
  ssh_public_key = var.ssh_public_key_content != "" ? var.ssh_public_key_content : (
    fileexists(local.resolved_password_path) ? file(local.resolved_password_path) : ""
  )
}
