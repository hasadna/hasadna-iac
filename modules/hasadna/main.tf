terraform {
  required_providers {
    kamatera = {
      source  = "Kamatera/kamatera"
    }
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
