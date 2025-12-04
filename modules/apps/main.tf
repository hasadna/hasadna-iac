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
      source  = "StatusCakeDev/statuscake"
    }
  }
}

provider "github" {
  owner = "hasadna"
}

variable "vault_addr" {
  type = string
}
