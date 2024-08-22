terraform {
  required_providers {
    kamatera = {
      source = "Kamatera/kamatera"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    github = {
      source  = "integrations/github"
    }
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu_west_3"
  region = "eu-west-3"
}

provider "github" {
  owner = "hasadna"
}
