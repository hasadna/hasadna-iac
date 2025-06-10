resource "cloudflare_dns_record" "ingress" {
  for_each = toset(local.ingress_names)
  zone_id = var.cloudflare_zone_hasadna_org_il.zone_id
  name    = "${each.key}.${var.cloudflare_zone_hasadna_org_il.name}"
  content   = var.cluster_ingress_hostname
  type    = "CNAME"
  ttl = 1
}

resource "cloudflare_dns_record" "ingress_stride_api" {
  zone_id = var.cloudflare_zone_hasadna_org_il.zone_id
  name    = "open-bus-stride-api.${var.cloudflare_zone_hasadna_org_il.name}"
  content   = var.cluster_ingress_hostname
  type    = "CNAME"
  ttl = 1
}
