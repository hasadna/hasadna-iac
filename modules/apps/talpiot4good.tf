resource "cloudflare_dns_record" "talpiot4good_site" {
  zone_id = var.cloudflare_zone_hasadna_org_il.zone_id
  name    = "talpiot4good.${var.cloudflare_zone_hasadna_org_il.name}"
  content   = "hasadna.github.io"
  type    = "CNAME"
  ttl = 300
  proxied = false
}
