terraform {
  required_version = ">=1.9.3"
  backend "pg" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.98.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    kamatera = {
      source  = "Kamatera/kamatera"
      version = "0.8.15"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "3.17.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.0.0"
    }
    statuscake = {
      source = "StatusCakeDev/statuscake"
      version = "2.2.2"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "kubernetes" {
  alias = "rancher"
  config_path = var.rancher_kubeconfig_path
}

provider "kubernetes" {
  alias = "rke2"
  config_path = var.rke2_kubeconfig_path
}
