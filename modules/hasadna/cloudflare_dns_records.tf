resource "cloudflare_record" "k972il_jenkins" {
  zone_id = data.cloudflare_zone.domain_infra_1.id
  name    = "k972il-jenkins"
  value   = kamatera_server.k972il_jenkins.public_ips[0]
  type    = "A"
  ttl     = 120
  allow_overwrite = false
}

resource "cloudflare_record" "k972il_rancher" {
  zone_id = data.cloudflare_zone.domain_infra_1.id
  name    = "k972il-rancher"
  value   = kamatera_server.k972il_cluster2_management.public_ips[0]
  type    = "A"
  ttl     = 120
  allow_overwrite = false
}
