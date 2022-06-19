resource "kamatera_server" "hasadna_ssh_access_point" {
  name = "hasadna-ssh-access-point"
  datacenter_id = "IL"
  cpu_type = "A"
  cpu_cores = 1
  ram_mb = 512
  disk_sizes_gb = [5]
  billing_cycle = "monthly"
  image_id = data.kamatera_image.israel_ubuntu_1804.id

  network {
    name = "wan"
  }

  network {
    name = kamatera_network.hasadna.full_name
    ip = "172.16.0.7"
  }
}

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

resource null_resource "firewall_hasadna_ssh_access_point" {
  depends_on = [null_resource.authorized_keys_hasadna_ssh_access_point]
  triggers = {
    version = 2
  }
  provisioner "remote-exec" {
    connection {
      host = kamatera_server.hasadna_ssh_access_point.public_ips[0]
      private_key = var.ssh_private_key
      port = var.hasadna_ssh_access_point_ssh_port
    }
    inline = [
      "ufw --force reset && ufw allow ${var.hasadna_ssh_access_point_ssh_port} && ufw --force enable"
    ]
  }
}
