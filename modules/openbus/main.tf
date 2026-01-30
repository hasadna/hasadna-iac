terraform {
  required_providers {
    kamatera = {
      source  = "Kamatera/kamatera"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    statuscake = {
      source = "StatusCakeDev/statuscake"
    }
    github = {
      source  = "integrations/github"
    }
  }
}

provider "github" {
  owner = "hasadna"
}
