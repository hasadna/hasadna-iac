resource "cloudflare_record" "infra" {
  for_each = toset([
    "argo",
    "forum",
  ])
  zone_id = data.cloudflare_zone.hasadna_org_il.zone_id
  name    = each.value
  value   = values(cloudflare_record.ingress)[0].hostname
  type    = "CNAME"
}
