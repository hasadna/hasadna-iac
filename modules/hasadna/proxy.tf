# hasadna-proxy1 server
# was setup manually, can ssh to it's private IP from hasadna-ssh-access-point server
# Server public IP is allowlisted in Israel Government so it can be used as a proxy for scraping

data "vault_kv_secret_v2" "proxy" {
  mount = "/kv"
  name = "Projects/iac/proxy"
}

locals {
  hasadna_proxy1_private_ip = data.vault_kv_secret_v2.proxy.data["hasadna-proxy1-private-ip"]
  # hasadna_proxy1_public_ip = data.vault_kv_secret_v2.proxy.data["hasadna-proxy1-public-ip"]
}

resource "null_resource" "proxy1_squid" {
  triggers = {
    command = <<-EOT
      ssh hasadna-proxy1 "
        set -euo pipefail
        docker rm -f squid || true
        docker run -d --name squid --restart unless-stopped -p ${local.hasadna_proxy1_private_ip}:9999:3128 ubuntu/squid:5.2-22.04_beta
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
  for_each = toset(["openbus", "oknesset"])
  metadata {
    name = "hasadna-proxy1"
    namespace = each.key
  }
  data = {
    "HTTP_PROXY" = "http://${local.hasadna_proxy1_private_ip}:9999"
    "HTTPS_PROXY" = "http://${local.hasadna_proxy1_private_ip}:9999"
  }
}
