variable "hasadna_ssh_access_point_provision" {
  type = object({})
}

variable "hasadna_authorized_keys" {
  type = string
}

variable "hasadna_ssh_access_point_public_ip" {
  type = string
}

variable "ssh_private_key" {
  type = string
}

variable "hasadna_ssh_access_point_ssh_port" {
  type = string
}

variable "cloudflare_zone_hasadna_org_il" {
  type = any
}

variable "cluster_ingress_hostname" {
  type = string
}