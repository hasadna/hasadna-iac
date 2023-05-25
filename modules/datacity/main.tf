terraform {
  required_providers {
    statuscake = {
      source = "StatusCakeDev/statuscake"
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
