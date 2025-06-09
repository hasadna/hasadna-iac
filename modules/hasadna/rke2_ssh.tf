locals {
  rke2_ssh_config_servers = join("\n", [
    for name, ip in local.rke2_server_private_ip : <<-EOT
        Host hasadna-rke2-${name}
          HostName ${ip}
          User root
          Port ${var.hasadna_ssh_access_point_ssh_port}
          ProxyJump hasadna-ssh-access-point
    EOT
  ])
}

resource "local_file" "rke2_ssh_config" {
  content = <<-EOF
    Host hasadna-ssh-access-point
      HostName ${kamatera_server.hasadna_ssh_access_point.public_ips[0]}
      User root
      Port 25766

    Host hasadna-proxy1
      HostName ${local.hasadna_proxy1_private_ip}
      User root
      ProxyJump hasadna-ssh-access-point

    ${local.rke2_ssh_config_servers}

  EOF
  filename = "/etc/hasadna/rke2_ssh_config"
}
