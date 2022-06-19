resource "cloudflare_record" "ingress" {
  for_each = toset(local.ingress_names)
  zone_id = var.cloudflare_zone_hasadna_org_il.id
  name    = each.key
  value   = var.cluster_ingress_hostname
  type    = "CNAME"
}

resource "cloudflare_record" "ingress_stride_api" {
  zone_id = var.cloudflare_zone_hasadna_org_il.id
  name    = "open-bus-stride-api"
  value   = var.cluster_ingress_hostname
  type    = "CNAME"
}
