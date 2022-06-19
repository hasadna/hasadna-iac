data "cloudflare_zone" "domain_infra_1" {
  name = var.domain_infra_1
}

data "cloudflare_zone" "hasadna_org_il" {
  name = "hasadna.org.il"
}
