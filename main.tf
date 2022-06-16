terraform {
  backend "pg" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.18.0"
    }
    kamatera = {
      source  = "Kamatera/kamatera"
      version = "0.8.7"
    }
  }
}

provider "aws" {
    region = "eu-west-1"
}

module "anyway" {
  source = "./modules/anyway"
}

module "hasadna" {
  source = "./modules/hasadna"
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