locals {
  tf_outputs_data = merge(
    {
      hasadna_nfs1_internal_ip = module.hasadna.hasadna_nfs1_internal_ip,
      ingress-leafy-webapp = module.hasadna.cloudflare_records_infra["leafy"].hostname,
      ingress-dear-diary-webapp = module.hasadna.cloudflare_records_infra["dear-diary"].hostname,
      ingress-open-pension-ng-webapp = module.hasadna.cloudflare_records_infra["open-pension-ng"].hostname,
      ingress-open-law-archive-webapp = module.hasadna.cloudflare_records_infra["open-law-archive"].hostname,
      rancher_ip = module.hasadna.rancher_ip
      jenkins_ip = module.hasadna.jenkins_ip
      default_admin_email = var.default_admin_email
      rke2_catchall_hostname = module.hasadna.rke2_catchall_hostname
    },
    module.openbus.kubernetes_tf_outputs
  )
}

resource "kubernetes_config_map" "tf_outputs" {
  provider = kubernetes.rancher
  metadata {
    name = "tf-outputs"
    namespace = "argocd"
  }
  data = local.tf_outputs_data
}

resource "kubernetes_config_map" "rke2_tf_outputs" {
  provider = kubernetes.rke2
  metadata {
    name = "tf-outputs"
    namespace = "argocd"
  }
  data = local.tf_outputs_data
}
