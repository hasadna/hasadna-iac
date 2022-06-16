resource "kubernetes_config_map" "tf_outputs" {
  metadata {
    name = "tf-outputs"
    namespace = "argocd"
  }

  data = {
    hasadna_nfs1_internal_ip = module.hasadna.hasadna_nfs1_internal_ip
  }
}
