output "hasadna_nfs1_internal_ip" {
  value = kamatera_server.hasadna_nfs1.private_ips[0]
}

output "hasadna_ssh_access_point_public_ip" {
  value = kamatera_server.hasadna_ssh_access_point.public_ips[0]
  sensitive = true
}
