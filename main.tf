terraform {
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
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
