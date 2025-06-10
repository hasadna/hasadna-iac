data "cloudflare_zone" "datacity" {
  filter = {
    name = "datacity.org.il"
  }
}

resource "cloudflare_dns_record" "ckan" {
  for_each = { for site in local.sites : site.name => site }
  zone_id = data.cloudflare_zone.datacity.zone_id
  name = "${each.key}.${data.cloudflare_zone.datacity.name}"
  content = "clustering.datacity.org.il"
  ttl = 1
  type = "CNAME"
  proxied = true
}

resource "cloudflare_dns_record" "rke2" {
  for_each = {
    "app" = {"content" = "kamatera-cluster.datacity.org.il"}
    "geocode" = {"content" = "kamatera-cluster.datacity.org.il"}
    "tabula" = {"content" = "kamatera-cluster.datacity.org.il"}
    "api" = {"content" = "kamatera-cluster.datacity.org.il"}
    "ckan-dgp" = {"content" = "rke2-ingress.hasadna.org.il"}
    "mapali" = {"content" = "rke2-ingress.hasadna.org.il"}
    "baserow" = {"content" = "rke2-ingress.hasadna.org.il"}
  }
  zone_id = data.cloudflare_zone.datacity.zone_id
  name    = "${each.key}.${data.cloudflare_zone.datacity.name}"
  content   = each.value.content
  type    = "CNAME"
  proxied = true
  ttl = 1
}
