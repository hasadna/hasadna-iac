output "kubernetes_tf_outputs" {
  value = {
    for name in concat(local.ingress_names, ["open-bus-stride-api"]):
      "ingress-${name}" => "${name}.${var.cloudflare_zone_hasadna_org_il.name}"
  }
}
