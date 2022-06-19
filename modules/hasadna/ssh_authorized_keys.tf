resource null_resource "authorized_keys_hasadna_ssh_access_point" {
  triggers = {
    authorized_keys = local.hasadna_authorized_keys
  }

  provisioner "file" {
    connection {
      host = kamatera_server.hasadna_ssh_access_point.public_ips[0]
      private_key = var.ssh_private_key
      port = var.hasadna_ssh_access_point_ssh_port
    }
    content = local.hasadna_authorized_keys
    destination = ".ssh/authorized_keys"
  }
}
