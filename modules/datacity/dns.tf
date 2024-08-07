data "cloudflare_zone" "datacity" {
  name = "datacity.org.il"
}

resource "cloudflare_record" "ckan" {
  for_each = { for site in local.sites : site.name => site }
  zone_id = data.cloudflare_zone.datacity.id
  name = each.key
  value = "clustering.datacity.org.il"
  type = "CNAME"
  proxied = true
  allow_overwrite = false
  timeouts {

  }
}
