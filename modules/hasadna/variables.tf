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

variable "rancher_admin_token" {
  type = string
  sensitive = true
}

variable "ssh_authorized_keys" {
  type = string
  sensitive = true
}

variable "vault_addr" {
  type = string
  sensitive = true
}

variable "rke2_kubeconfig_path" {
  type = string
  sensitive = true
}
