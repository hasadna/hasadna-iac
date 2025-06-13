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
