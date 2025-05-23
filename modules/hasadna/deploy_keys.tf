locals {
  default_repo_secret_name = "HASADNA_K8S_DEPLOY_KEY"
  hasadna_k8s_deploy_keys = {
    "open-pension": {}
  }
  hasadna_k8s_deploy_keys_repo_secrets = {
    "open-pension-ng": {
      "key": "open-pension",
      "secret": local.default_repo_secret_name
    }
  }
}

resource "tls_private_key" "hasadna_k8s_deploy_keys" {
  for_each = local.hasadna_k8s_deploy_keys
  algorithm = "RSA"
}

resource "github_repository_deploy_key" "hasadna_k8s" {
  for_each = local.hasadna_k8s_deploy_keys
  repository = "hasadna-k8s"
  title = each.key
  key = tls_private_key.hasadna_k8s_deploy_keys[each.key].public_key_openssh
  read_only = false
}

resource "github_actions_secret" "hasadna_k8s_deploy_keys" {
  for_each = local.hasadna_k8s_deploy_keys_repo_secrets
  repository = each.key
  secret_name = each.value["secret"]
  plaintext_value = tls_private_key.hasadna_k8s_deploy_keys[each.value["key"]].private_key_pem
}
