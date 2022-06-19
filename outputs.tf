output "hasadna_ssh_access_point_public_ip" {
  value = module.hasadna.hasadna_ssh_access_point_public_ip
  sensitive = true
}

output "hasadna_ssh_access_point_public_port" {
  value = var.hasadna_ssh_access_point_ssh_port
  sensitive = true
}
