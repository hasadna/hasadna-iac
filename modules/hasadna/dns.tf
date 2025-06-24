data "cloudflare_zone" "hasadna_org_il" {
  filter = {
    name = "hasadna.org.il"
  }
}

locals {
  rke2_ingress_cnames_names = {
    "*.k8s" = {}
    "*.rke2" = {}
    "dear-diary" = {}
    "argo" = {}
    "betaknesset-elasticsearch" = {}
    "betaknesset-kibana" = {}
    "forum" = {}
    "leafy" = {}
    "open-pension-ng" = {}
    "open-law-archive" = {}
    "redash" = {}
    "resourcesaverproxy" = {}
    "vault" = {}
    "argocd" = {}
    "atlantis" = {proxied = true}
  }
}

resource "cloudflare_dns_record" "rke2_ingress_cnames" {
  for_each = local.rke2_ingress_cnames_names
  zone_id = data.cloudflare_zone.hasadna_org_il.zone_id
  name    = "${each.key}.${data.cloudflare_zone.hasadna_org_il.name}"
  content   = "${local.rke2_ingress_name}.${data.cloudflare_zone.hasadna_org_il.name}"
  type    = "CNAME"
  ttl = 1
  proxied = lookup(each.value, "proxied", false)
}

data "cloudflare_zone" "kikar_org" {
  filter = {
    name = "kikar.org"
  }
}

data "cloudflare_zone" "otrain_org" {
  filter = {
    name = "otrain.org"
  }
}

resource "cloudflare_dns_record" "extra" {
  for_each = {
    "kikar_org": {
      "zone_id": data.cloudflare_zone.kikar_org.zone_id,
      "name": data.cloudflare_zone.kikar_org.name
    },
    "www_kikar_org": {
      "zone_id": data.cloudflare_zone.kikar_org.zone_id,
      "name": "www.${data.cloudflare_zone.kikar_org.name}"
    },
    "otrain_org": {
      "zone_id": data.cloudflare_zone.otrain_org.zone_id,
      "name": data.cloudflare_zone.otrain_org.name
    },
    "www_otrain_org": {
      "zone_id": data.cloudflare_zone.otrain_org.zone_id,
      "name": "www.${data.cloudflare_zone.otrain_org.name}"
    },
  }
  zone_id = each.value["zone_id"]
  name    = each.value["name"]
  content   = "${local.rke2_ingress_name}.${data.cloudflare_zone.hasadna_org_il.name}"
  type = "CNAME"
  proxied = true
  ttl = 1
}

output "cloudflare_zone_hasadna_org_il" {
  value = data.cloudflare_zone.hasadna_org_il
}

output "cloudflare_records_rke2_ingress_cnames_hostnames" {
  value = {
    for name, _ in local.rke2_ingress_cnames_names : name => "${name}.${data.cloudflare_zone.hasadna_org_il.name}"
  }
}

output "rke2_cluster_ingress_hostname" {
  value = "${local.rke2_ingress_name}.${data.cloudflare_zone.hasadna_org_il.name}"
}

locals {
  rke2_ingress_ips = [
    for name, server in local.rke2_servers : local.rke2_server_public_ip[name]
      if server.ingress
  ]
  rke2_ingress_name = "rke2-ingress"
}

resource "cloudflare_dns_record" "rke2_ingress" {
  for_each = toset(local.rke2_ingress_ips)
  zone_id = data.cloudflare_zone.hasadna_org_il.zone_id
  name    = "${local.rke2_ingress_name}.${data.cloudflare_zone.hasadna_org_il.name}"
  type    = "A"
  content   = each.key
  ttl = 1
}

resource "cloudflare_dns_record" "legacy_ingress" {
  zone_id = data.cloudflare_zone.hasadna_org_il.zone_id
  name    = "ingress.${data.cloudflare_zone.hasadna_org_il.name}"
  type    = "CNAME"
  content   = "${local.rke2_ingress_name}.${data.cloudflare_zone.hasadna_org_il.name}"
  ttl = 1
}

output "rke2_catchall_hostname" {
  value = replace("rke2.${data.cloudflare_zone.hasadna_org_il.name}", "*.", "")
}
