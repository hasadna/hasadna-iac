output "hasadna_nfs1_internal_ip" {
  value = kamatera_server.hasadna_nfs1.private_ips[0]
}

output "hasadna_ssh_access_point_public_ip" {
  value = kamatera_server.hasadna_ssh_access_point.public_ips[0]
  sensitive = true
}

output "hasadna_ssh_access_point_provision" {
  value = null_resource.hasadna_ssh_access_point_provision
}

output "hasadna_authorized_keys" {
  value = local.hasadna_authorized_keys
}

output "cloudflare_zone_hasadna_org_il" {
  value = data.cloudflare_zone.hasadna_org_il
}

output "cluster_ingress_hostname" {
  value = local.cluster_ingress_hostname
}