locals {
  tf_outputs_data = merge(
    {
      hasadna_nfs1_internal_ip = module.hasadna.hasadna_nfs1_internal_ip,
      ingress-leafy-webapp = module.hasadna.cloudflare_records_rke2_ingress_cnames_hostnames["leafy"],
      ingress-dear-diary-webapp = module.hasadna.cloudflare_records_rke2_ingress_cnames_hostnames["dear-diary"],
      ingress-open-pension-ng-webapp = module.hasadna.cloudflare_records_rke2_ingress_cnames_hostnames["open-pension-ng"],
      ingress-open-law-archive-webapp = module.hasadna.cloudflare_records_rke2_ingress_cnames_hostnames["open-law-archive"],
      default_admin_email = var.default_admin_email
      rke2_catchall_hostname = module.hasadna.rke2_catchall_hostname
    },
    module.openbus.kubernetes_tf_outputs
  )
}

resource "kubernetes_config_map" "rke2_tf_outputs" {
  provider = kubernetes.rke2
  metadata {
    name = "tf-outputs"
    namespace = "argocd"
  }
  data = local.tf_outputs_data
}
