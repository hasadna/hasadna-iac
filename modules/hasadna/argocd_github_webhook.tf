resource "random_string" "argocd_github_webhook_secret" {
  length = 32
  special = false
}

resource "github_organization_webhook" "argocd_push" {
  events = ["push"]
  configuration {
    url = "https://argocd.hasadna.org.il/api/webhook"
    content_type = "json"
    insecure_ssl = false
    secret = random_string.argocd_github_webhook_secret.result
  }
}

output "argocd_github_webhook_secret" {
  value = random_string.argocd_github_webhook_secret.result
  sensitive = true
}
