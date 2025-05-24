locals {
  rke2_ingress_ips = [
    for name, server in local.rke2_servers : local.rke2_server_public_ip[name]
      if server.ingress
  ]
  rke2_ingress_name = "rke2-ingress"
}

resource "cloudflare_record" "rke2_ingress" {
  for_each = toset(local.rke2_ingress_ips)
  zone_id = data.cloudflare_zone.hasadna_org_il.id
  name    = local.rke2_ingress_name
  type    = "A"
  value   = each.key
}

resource "cloudflare_record" "rke2_catchall" {
  zone_id = data.cloudflare_zone.hasadna_org_il.zone_id
  name    = "*.rke2"
  value   = values(cloudflare_record.rke2_ingress)[0].hostname
  type    = "CNAME"
}

output "rke2_catchall_hostname" {
  value = replace(cloudflare_record.rke2_catchall.hostname, "*.", "")
}
