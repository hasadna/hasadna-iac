resource "cloudflare_dns_record" "knesset-mk-tracking" {
  zone_id = var.cloudflare_zone_hasadna_org_il.zone_id
  name    = "knesset-mk-tracking.${var.cloudflare_zone_hasadna_org_il.name}"
  content   = "ingress.hasadna.org.il"
  type    = "CNAME"
  ttl = 1
  proxied = true
}
