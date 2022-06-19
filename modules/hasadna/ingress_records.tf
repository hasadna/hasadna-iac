resource "cloudflare_record" "ingress" {
  for_each = toset(local.cluster_ingress_ips)
  zone_id = data.cloudflare_zone.hasadna_org_il.id
  name    = local.cluster_ingress_name
  type    = "A"
  value   = each.key
}
