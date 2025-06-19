resource "vault_kv_secret_v2" "iac_outputs_hasadna_argocd" {
  mount = "kv"
  name = "Projects/iac/outputs/hasadna_argocd"
  data_json = jsonencode({
    github_webhook_secret = module.hasadna.argocd_github_webhook_secret
  })
}

resource "vault_kv_secret_v2" "iac_outputs_hasadna_argoevents" {
  mount = "kv"
  name = "Projects/iac/outputs/hasadna_argoevents"
  data_json = jsonencode({
    github_webhook_secret = module.hasadna.argoevents_github_webhook_secret
  })
}

resource "vault_kv_secret_v2" "iac_outputs_hasadna_ssh_access_point" {
  mount = "kv"
  name = "Projects/iac/outputs/hasadna_ssh_access_point"
  data_json = jsonencode({
    public_ip = module.hasadna.hasadna_ssh_access_point_public_ip
    public_port = var.hasadna_ssh_access_point_ssh_port
  })
}
