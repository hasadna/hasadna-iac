output "kubernetes_tf_outputs" {
  value = {
    for name in concat(local.ingress_names, [cloudflare_record.ingress_stride_api.name]):
      "ingress-${name}" => "${name}.${var.cloudflare_zone_hasadna_org_il.name}"
  }
}
