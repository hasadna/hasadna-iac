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
  }
}

provider "aws" {
    region = "eu-west-1"
}
