module "hasadna" {
  source = "./modules/hasadna"
  domain_infra_1 = var.domain_infra_1
  ssh_private_key = var.ssh_private_key
  hasadna_ssh_access_point_ssh_port = var.hasadna_ssh_access_point_ssh_port
  rancher_admin_token = var.rancher_admin_token
}

module "openbus" {
  source = "./modules/openbus"
  hasadna_ssh_access_point_provision = module.hasadna.hasadna_ssh_access_point_provision
  hasadna_authorized_keys = module.hasadna.hasadna_authorized_keys
  hasadna_ssh_access_point_public_ip = module.hasadna.hasadna_ssh_access_point_public_ip
  hasadna_ssh_access_point_ssh_port = var.hasadna_ssh_access_point_ssh_port
  ssh_private_key = var.ssh_private_key
  cloudflare_zone_hasadna_org_il = module.hasadna.cloudflare_zone_hasadna_org_il
  cluster_ingress_hostname = module.hasadna.cluster_ingress_hostname
}

module "srm" {
  source = "./modules/srm"
}

module "datacity" {
  source = "./modules/datacity"
}
