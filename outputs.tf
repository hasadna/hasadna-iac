output "hasadna_ssh_access_point_public_ip" {
  value = module.hasadna.hasadna_ssh_access_point_public_ip
  sensitive = true
}

output "hasadna_ssh_access_point_public_port" {
  value = var.hasadna_ssh_access_point_ssh_port
  sensitive = true
}

output "hasadna_argoevents_github_webhook_secret" {
  value = module.hasadna.argoevents_github_webhook_secret
  sensitive = true
}

output "hasadna_argocd_github_webhook_secret" {
  value = module.hasadna.argocd_github_webhook_secret
  sensitive = true
}
