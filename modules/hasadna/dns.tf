# comments in brackets are the argo app that use that DNS record

resource "cloudflare_record" "infra" {
  for_each = toset([
    # "argo",
    # "forum",
    # "leafy",
    # "open-pension-ng",
    # "open-law-archive",
    "*.k8s",
  ])
  zone_id = data.cloudflare_zone.hasadna_org_il.zone_id
  name    = each.value
  value   = values(cloudflare_record.ingress)[0].hostname
  type    = "CNAME"
}

resource "cloudflare_record" "rke2_ingress_cnames" {
  for_each = toset([
    "dear-diary",
    # "*.k8s",   # argo-events-github (argoevents), label-studio (hasadna)
    "label-studio.k8s",
    "argo-events-github.k8s",
    "argo",  # (argoworkflows)
    "betaknesset-elasticsearch",  # (betaknesset)
    "betaknesset-kibana",  # (betaknesset)
    "forum",  # (forum)
    "leafy",  # (leafy)
    "open-pension-ng",  # (openpension)
    "open-law-archive",  # (openlaw)
    "redash",  # (redash)
    "resourcesaverproxy",  # (resourcesaverproxy)
    # already created manually -> # "vault",  # (vault)
    # "argocd",  # (argocd)
  ])
  zone_id = data.cloudflare_zone.hasadna_org_il.zone_id
  name    = each.value
  value   = values(cloudflare_record.rke2_ingress)[0].hostname
  type    = "CNAME"
}

data "cloudflare_zone" "kikar_org" {
  name = "kikar.org"
}

data "cloudflare_zone" "otrain_org" {
  name = "otrain.org"
}

resource "cloudflare_record" "extra" {
  for_each = {
    "kikar_org": {  # (hasadna)
      "zone_id": data.cloudflare_zone.kikar_org.zone_id,
      "name": data.cloudflare_zone.kikar_org.name
    },
    "www_kikar_org": {  # (hasadna)
      "zone_id": data.cloudflare_zone.kikar_org.zone_id,
      "name": "www.${data.cloudflare_zone.kikar_org.name}"
    },
    "otrain_org": {  # (hasadna)
      "zone_id": data.cloudflare_zone.otrain_org.zone_id,
      "name": data.cloudflare_zone.otrain_org.name
    },
    "www_otrain_org": {  # (hasadna)
      "zone_id": data.cloudflare_zone.otrain_org.zone_id,
      "name": "www.${data.cloudflare_zone.otrain_org.name}"
    },
  }
  zone_id = each.value["zone_id"]
  name    = each.value["name"]
  value   = values(cloudflare_record.rke2_ingress)[0].hostname
  # value   = values(cloudflare_record.ingress)[0].hostname
  type = "CNAME"
  proxied = true
}
