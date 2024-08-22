resource "github_repository_webhook" "argocd" {
  repository = "hasadna-k8s"
  events = ["push"]
  configuration {
      url = "https://argocd.hasadna.org.il/api/webhook"
      content_type = "json"
      insecure_ssl = false
  }
}
