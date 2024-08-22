terraform {
  required_version = ">=1.9.3"
  backend "pg" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.18.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    kamatera = {
      source  = "Kamatera/kamatera"
      version = "0.8.7"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "3.17.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.2.3"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
