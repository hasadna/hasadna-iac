data "external" "google_load_balancer_ip" {
  program = [
    "bash", "-c",
    "vault kv get -format=json kv/Projects/datacity/google_load_balancer | jq -cM '{ip: .data.data.ip}'"
  ]
}

output "google_load_balancer_ip" {
  value = data.external.google_load_balancer_ip.result.ip
}

output "ckan_all_host_names" {
  value = concat(
    [for site in local.sites : split("/", site.url)[2] if !strcontains(site.url, "datacity.org.il")],
    [for site in local.sites : "${site.name}.datacity.org.il"]
  )
}
