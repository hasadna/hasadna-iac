resource "kubernetes_config_map" "tf_outputs" {
  metadata {
    name = "tf-outputs"
    namespace = "argocd"
  }

  data = merge(
    {
      hasadna_nfs1_internal_ip = module.hasadna.hasadna_nfs1_internal_ip,
      ingress-leafy-webapp = module.hasadna.cloudflare_records_infra["leafy"].hostname,
      ingress-dear-diary-webapp = module.hasadna.cloudflare_records_infra["dear-diary"].hostname,
    },
    module.openbus.kubernetes_tf_outputs
  )
}
