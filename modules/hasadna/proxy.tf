# hasadna-proxy1 server
# was setup manually, can ssh to it's private IP from hasadna-ssh-access-point server
# Server public IP is allowlisted in Israel Government so it can be used as a proxy for scraping

# following namespaces will have configmap hasadna-proxy1 with HTTP_PROXY and HTTPS_PROXY env vars
# add it to deployment specs that need to use the proxy:
# envFrom:
# - configMapRef:
#     name: hasadna-proxy1

locals {
  hasadna_proxy1_namespaces = [
    "openbus",
    "oknesset",
    "meirim"
  ]

  # for testing, can temporarily enable public IP for the proxy
  # remember to disable it after testing, to avoid unnecessary exposure
  hasadna_proxy1_enable_public = false

  hasadna_proxy1_private_ip = data.vault_kv_secret_v2.proxy.data["hasadna-proxy1-private-ip"]
  hasadna_proxy1_public_ip = data.vault_kv_secret_v2.proxy.data["hasadna-proxy1-public-ip"]
  hasadna_proxy1_docker_port_host = local.hasadna_proxy1_enable_public ? "0.0.0.0" : local.hasadna_proxy1_private_ip
}

output "hasadna_proxy1_public_ip" {
  value = local.hasadna_proxy1_enable_public ? local.hasadna_proxy1_public_ip : ""
}

data "vault_kv_secret_v2" "proxy" {
  mount = "/kv"
  name = "Projects/iac/proxy"
}

resource "null_resource" "proxy1_squid" {
  triggers = {
    command = <<-EOT
      ssh hasadna-proxy1 "
        set -euo pipefail
        docker rm -f squid || true
        docker run -d --name squid --restart unless-stopped -p ${local.hasadna_proxy1_docker_port_host}:9999:3128 ubuntu/squid:5.2-22.04_beta
      "
    EOT
  }
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = self.triggers.command
  }
}

resource "kubernetes_config_map" "proxy1_configmap" {
  provider = kubernetes.rke2
  for_each = toset(local.hasadna_proxy1_namespaces)
  metadata {
    name = "hasadna-proxy1"
    namespace = each.key
  }
  data = {
    "HTTP_PROXY" = "http://${local.hasadna_proxy1_private_ip}:9999"
    "http_proxy" = "http://${local.hasadna_proxy1_private_ip}:9999"
    "HTTPS_PROXY" = "http://${local.hasadna_proxy1_private_ip}:9999"
    "https_proxy" = "http://${local.hasadna_proxy1_private_ip}:9999"
  }
}
