module "hasadna" {
  source = "./modules/hasadna"
  domain_infra_1 = var.domain_infra_1
  ssh_private_key = var.ssh_private_key
  hasadna_ssh_access_point_ssh_port = var.hasadna_ssh_access_point_ssh_port
  rancher_admin_token = var.rancher_admin_token
  ssh_authorized_keys = var.ssh_authorized_keys
  vault_addr = var.vault_addr
  rke2_kubeconfig_path = var.rke2_kubeconfig_path
}

module "openbus" {
  source = "./modules/openbus"
  hasadna_ssh_access_point_provision = module.hasadna.hasadna_ssh_access_point_provision
  hasadna_authorized_keys = module.hasadna.hasadna_authorized_keys
  hasadna_ssh_access_point_public_ip = module.hasadna.hasadna_ssh_access_point_public_ip
  hasadna_ssh_access_point_ssh_port = var.hasadna_ssh_access_point_ssh_port
  ssh_private_key = var.ssh_private_key
  cloudflare_zone_hasadna_org_il = module.hasadna.cloudflare_zone_hasadna_org_il
  cluster_ingress_hostname = module.hasadna.rke2_cluster_ingress_hostname
  # cluster_ingress_hostname = module.hasadna.cluster_ingress_hostname
}

module "srm" {
  source = "./modules/srm"
}

module "datacity" {
  source = "./modules/datacity"
  google_service_account = base64decode(var.datacity_google_service_account_b64)
}
