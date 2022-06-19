variable "domain_infra_1" {
  type = string
}

variable "ssh_private_key" {
  type = string
  sensitive = true
}

variable "hasadna_ssh_access_point_ssh_port" {
  type = string
  sensitive = true
}
