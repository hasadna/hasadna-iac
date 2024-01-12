resource "cloudflare_record" "infra" {
  for_each = toset([
    "argo",
    "forum",
    "leafy",
    "dear-diary",
    "open-pension-ng",
    "open-law-archive",
    "*.k8s",
  ])
  zone_id = data.cloudflare_zone.hasadna_org_il.zone_id
  name    = each.value
  value   = values(cloudflare_record.ingress)[0].hostname
  type    = "CNAME"
}

data "cloudflare_zone" "kikar_org" {
  name = "kikar.org"
}

data "cloudflare_zone" "kikar_org_il" {
  name = "kikar.org.il"
}

data "cloudflare_zone" "otrain_org" {
  name = "otrain.org"
}

resource "cloudflare_record" "extra" {
  for_each = {
    "kikar_org": {
      "zone_id": data.cloudflare_zone.kikar_org.zone_id,
      "name": data.cloudflare_zone.kikar_org.name
    },
    "www_kikar_org": {
      "zone_id": data.cloudflare_zone.kikar_org.zone_id,
      "name": "www.${data.cloudflare_zone.kikar_org.name}"
    },
    "kikar_org_il": {
      "zone_id": data.cloudflare_zone.kikar_org_il.zone_id,
      "name": data.cloudflare_zone.kikar_org_il.name
    },
    "www_kikar_org_il": {
      "zone_id": data.cloudflare_zone.kikar_org_il.zone_id,
      "name": "www.${data.cloudflare_zone.kikar_org_il.name}"
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
  value   = values(cloudflare_record.ingress)[0].hostname
  type = "CNAME"
  proxied = false
}
