resource "kamatera_server" "dev_server_eu1" {
  name = "hasadna-dev-server-eu1"
  datacenter_id = "EU"
  image_id = "6000C29549da189eaef6ea8a31001a34"  # Ubuntu 24.04
  cpu_type = "B"
  cpu_cores = 8
  ram_mb = 16384
  disk_sizes_gb = [100]
  billing_cycle = "hourly"
  ssh_pubkey = var.ssh_authorized_keys

  lifecycle {
    ignore_changes = [power_on]
  }
}

locals {
  dev_server_eu1_ssh_port = var.hasadna_ssh_access_point_ssh_port
  dev_server_eu1_public_ip = kamatera_server.dev_server_eu1.public_ips[0]
}

resource "null_resource" "dev_server_eu1_init_ssh" {
  depends_on = [kamatera_server.dev_server_eu1]
  triggers = {
    command = <<-EOF
      if [ -f /etc/ssh/sshd_config.d/50-cloud-init.conf ]; then
        sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config.d/50-cloud-init.conf
      fi &&\
      mkdir -p /etc/systemd/system/ssh.socket.d &&\
      echo '[Socket]' > /etc/systemd/system/ssh.socket.d/override.conf &&\
      echo 'ListenStream=' >> /etc/systemd/system/ssh.socket.d/override.conf &&\
      echo 'ListenStream=${local.dev_server_eu1_public_ip}:${local.dev_server_eu1_ssh_port}' >> /etc/systemd/system/ssh.socket.d/override.conf &&\
      systemctl daemon-reload &&\
      systemctl restart ssh.socket &&\
      systemctl restart ssh.service
    EOF
  }
  provisioner "local-exec" {
    command = <<-EOT
      if ssh -p ${local.dev_server_eu1_ssh_port} root@${local.dev_server_eu1_public_ip} true; then
        ssh -p ${local.dev_server_eu1_ssh_port} root@${local.dev_server_eu1_public_ip} "${self.triggers.command}"
      else
        ssh root@${local.dev_server_eu1_public_ip} "${self.triggers.command}"
      fi
    EOT
  }
}

resource "null_resource" "dev_server_eu1_init" {
  triggers = {
    command = <<-EOF
      set -euo pipefail
      ssh hasadna-dev-server-eu1 bash -c '
        set -euo pipefail
        if ! which docker; then
          apt-get update
          apt-get install -y ca-certificates curl
          install -m 0755 -d /etc/apt/keyrings
          curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
          chmod a+r /etc/apt/keyrings/docker.asc
          echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
            tee /etc/apt/sources.list.d/docker.list > /dev/null
          apt-get update
          apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        fi
      '
    EOF
  }
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = self.triggers.command
  }
}
