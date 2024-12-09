resource "random_string" "argoevents_github_webhook_secret" {
  length = 32
  special = false
}

resource "github_organization_webhook" "argoevents_push" {
  events = ["push"]
  configuration {
    url = "https://argo-events-github.k8s.hasadna.org.il/push"
    content_type = "json"
    insecure_ssl = false
    secret = random_string.argoevents_github_webhook_secret.result
  }
}

output "argoevents_github_webhook_secret" {
  value = random_string.argoevents_github_webhook_secret.result
  sensitive = true
}
