resource "random_string" "atlantis_webhook_secret" {
  length = 32
  special = false
}

resource "random_string" "atlantis_web_password" {
  length = 16
  special = true
  upper = true
  lower = true
}

resource "random_string" "atlantis_web_username" {
  length = 6
  special = false
  upper = false
}

resource "github_organization_webhook" "atlantis" {
  events = [
    "pull_request_review",
    "issue_comment",
    "pull_request",
    "push",
  ]
  configuration {
    url = "https://atlantis.hasadna.org.il/events"
    content_type = "json"
    insecure_ssl = false
    secret = random_string.atlantis_webhook_secret.result
  }
}

resource "vault_kv_secret_v2" "atlantis_webhook" {
  mount = "/kv"
  name = "Projects/iac/atlantis"
  data_json_wo = jsonencode({
    webhook_secret = random_string.atlantis_webhook_secret.result
    web_username = random_string.atlantis_web_username.result
    web_password = random_string.atlantis_web_password.result
  })
}


resource "vault_approle_auth_backend_role" "atlantis_iac_admin" {
  role_name = "atlantis_iac_admin"
  token_policies = ["admin"]
  token_ttl = 3600
  token_max_ttl = 14400
}

resource "vault_approle_auth_backend_role_secret_id" "atlantis_iac_admin" {
  role_name = vault_approle_auth_backend_role.atlantis_iac_admin.role_name
}

resource "kubernetes_secret" "atlantis_vault_creds" {
    depends_on = [vault_approle_auth_backend_role_secret_id.atlantis_iac_admin]
    metadata {
        name = "atlantis-vault-creds"
        namespace = "default"
    }
    data = {
        ADDR = trimsuffix(var.vault_addr, "/")
        ROLE_ID = vault_approle_auth_backend_role.atlantis_iac_admin.role_id
        SECRET_ID = vault_approle_auth_backend_role_secret_id.atlantis_iac_admin.secret_id
    }
}
