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

  lifecycle {
    ignore_changes = [image_id]
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
    version = 3
  }
  provisioner "remote-exec" {
    connection {
      host = kamatera_server.hasadna_ssh_access_point.public_ips[0]
      private_key = var.ssh_private_key
      port = var.hasadna_ssh_access_point_ssh_port
    }
    inline = [
      <<EOF
ufw --force reset &&\
ufw default allow outgoing &&\
ufw default deny incoming &&\
ufw default deny routed &&\
ufw allow ${var.hasadna_ssh_access_point_ssh_port} &&\
ufw --force enable
EOF
    ]
  }
}

resource null_resource "hasadna_ssh_access_point_provision" {
  depends_on = [null_resource.authorized_keys_hasadna_ssh_access_point]
  triggers = {
    version = 5
  }
  provisioner "remote-exec" {
    connection {
      host        = kamatera_server.hasadna_ssh_access_point.public_ips[0]
      private_key = var.ssh_private_key
      port        = var.hasadna_ssh_access_point_ssh_port
    }
    inline = [
      <<EOF
sed -Ei 's/^Port .*$/Port ${var.hasadna_ssh_access_point_ssh_port}/' /etc/ssh/sshd_config &&\
sed -Ei 's/^PasswordAuthentication .*$/PasswordAuthentication no/' /etc/ssh/sshd_config &&\
systemctl reload ssh.service &&\
if ! [ -e .ssh/id_rsa ]; then ssh-keygen -t rsa -b 4096 -C "hasadna-ssh-access-point" -N "" -f .ssh/id_rsa; fi &&\
wget -Orancher.tar.gz https://releases.rancher.com/cli2/v2.3.2/rancher-linux-amd64-v2.3.2.tar.gz &&\
tar -xzvf rancher.tar.gz && mv rancher-v2.3.2/rancher /usr/local/bin/rancher &&\
chmod +x /usr/local/bin/rancher && rm -rf rancher-v2.3.2 && rancher --version &&\
rancher login --token ${var.rancher_admin_token} --context ${local.rancher_context_hasadna_default} https://${cloudflare_record.k972il_rancher.hostname}
EOF
    ]
  }
}
