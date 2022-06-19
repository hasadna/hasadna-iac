module "anyway" {
  source = "./modules/anyway"
}

module "hasadna" {
  source = "./modules/hasadna"
  domain_infra_1 = var.domain_infra_1
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
