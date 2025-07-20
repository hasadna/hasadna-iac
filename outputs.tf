output "rke2_server_passwords" {
    value = module.hasadna.rke2_server_passwords
    sensitive = true
}

output "rke2_ssh_config" {
  value = module.hasadna.rke2_ssh_config
  sensitive = true
}

output "openbus_stride_db_backup_check_url" {
  value = module.openbus.stride_db_backup_check_url
}
