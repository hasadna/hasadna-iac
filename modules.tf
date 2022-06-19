module "anyway" {
  source = "./modules/anyway"
}

module "hasadna" {
  source = "./modules/hasadna"
  domain_infra_1 = var.domain_infra_1
  ssh_private_key = var.ssh_private_key
  hasadna_ssh_access_point_ssh_port = var.hasadna_ssh_access_point_ssh_port
  rancher_admin_token = var.rancher_admin_token
}

module "oknesset" {
  source = "./modules/oknesset"
}

module "openbus" {
  source = "./modules/openbus"
}

module "srm" {
  source = "./modules/srm"
}
