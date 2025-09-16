# this user is created manually in Grafana by adding "terraform-admin" user with admin permissions
data "vault_kv_secret_v2" "grafana_terraform_admin_creds" {
  mount = "kv"
  name = "Projects/k8s/grafana-terraform-admin"
}

output "grafana_terraform_admin" {
  value     = {
    url = "https://grafana.rke2.${data.cloudflare_zone.hasadna_org_il.name}"
    auth = "${data.vault_kv_secret_v2.grafana_terraform_admin_creds.data.username}:${data.vault_kv_secret_v2.grafana_terraform_admin_creds.data.password}"
  }
  sensitive = true
}
