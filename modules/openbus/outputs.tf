data "vault_kv_secret_v2" "openbus_ingress_nginx_configuration_snippet" {
  mount = "kv"
  name = "Projects/OBus/nginx-ingress-configuration-snipper"
}

output "kubernetes_tf_outputs" {
  value = merge(
    {
      openbus-ingress-nginx-configuration-snippet = data.vault_kv_secret_v2.openbus_ingress_nginx_configuration_snippet.data["snippet"],
      openbus-ingress-nginx-denylist-source-range = data.vault_kv_secret_v2.openbus_ingress_nginx_configuration_snippet.data["denylist"],
    },
    {
      for name in concat(local.ingress_names, ["open-bus-stride-api"]):
        "ingress-${name}" => "${name}.${var.cloudflare_zone_hasadna_org_il.name}"
    }
  )
}
