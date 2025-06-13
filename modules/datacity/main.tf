terraform {
  required_providers {
    statuscake = {
      source = "StatusCakeDev/statuscake"
    }
    google = {
      source = "hashicorp/google"
      version = "6.39.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

data "external" "sites" {
  working_dir = path.cwd
  program = ["python3", "modules/datacity/get_sites.py"]
}

locals {
  sites = jsondecode(data.external.sites.result.sites)
}

variable "google_service_account" {
  type = string
  sensitive = true
}

provider "google" {
  credentials = var.google_service_account
  project = "datacity-k8s"
  region = "europe-west1"
}
