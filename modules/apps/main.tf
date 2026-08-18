terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    vault = {
      source = "hashicorp/vault"
    }
    github = {
      source = "integrations/github"
    }
    statuscake = {
      source = "StatusCakeDev/statuscake"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
    }
  }
}

provider "github" {
  owner = "hasadna"
}

variable "vault_addr" {
  type = string
}

variable "cloudflare_zone_hasadna_org_il" {
  type = any
}
