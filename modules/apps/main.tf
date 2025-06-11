terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    vault = {
      source  = "hashicorp/vault"
    }
  }
}
