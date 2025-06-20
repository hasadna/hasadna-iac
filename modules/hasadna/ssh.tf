locals {
  # TODO: Remove, get it from var.ssh_authorized_keys, only allow specific users, not servers
  hasadna_authorized_keys = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAU8I7VawhtQ4suRZGbMLTNkwqHWQe5xASYlyBje1UX1yUv88dbHnIh736O4DlbNODhPdaDkYxofwbpai5o4CTTbuWiqjc5duKG+tb1dSu89+2HYbufVIkdIiZCNZN3A2fDNPkXzX8tjVsXC7RRjgZMYZDpAgytQPuP8HC9HK/rcfhaYIZYYveEydXZj+P/XpKGGmIpaDCzjG0s3vZFw4p2tAOnmuzhbp1+Zl4wgWi83Z7CT5bsMQKATxT6WdkByTE9cHaCfaxWhF9EsoQl3f1itoGpW6EYAD7rHnY8YtDTNeLUAGj513mqa2UkjsXlOdX8aCDtOIuQUgHkAnwpXO+Cu6kxrFf8yi6R+W5uHjN2aEMhPBiM9Iz42Os7WQrMybsqzxvBHtkqpCbi4Y81Rcbs8LJrAy6AZ7D2YhPbycJXJZu+DQ1dy6OtE2NIAWzofD6aVYxzK8VzSA2tw0dCbhdOUOEjIhguFA4Z4IQennVkAHBNF/SHmjsBxPOPcHNz+geaCz4Q1otgb9ZRf8HuPkf/jHuG3h+5M0Gn7TUdDmWIDoOqN+CslJAkhffzwl/MtT8yXg6etl+9l+2ngVtfSYkxPOON0XpgZxdAWZwhJFKEzZlPc5M0+lA9Wy63/YMU4h1EA0QxE3fIa2Ojtj1Pmshlp0BTJx09sdOiv9oNogfRw== Ori Hoch
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIATFdULUxXTCW3vzS6I0Jj9ML3A3tWULhS245FNGanH/ hasadna-iac
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCh/CcXLAChnViZWwZCi2rmh0wk35GfZKeLAVsKqWtt4nPC4FOP4VIUUdxh1o1nsRBmeOA+9Q8jeedNCEivnx13Cb93EeaMU36CXa6c4JBLo9CmZHpa9RQ5L9B5KgRFrPNpSfhVTE0BtMfgzEOLCoPv7ZwG2yWyw8IzMOApckhgPXJNIIS9nH1Cz4rln4VUabPjfueBRn27QQQsbNgGfGr1Eu+Sscw7wGI3L1Oxts6Ej1fmker5bv8/juP6cvxpNYxVfkvDcXMnUletcomtVGkKo6AsQqnbvAG4PTOz3o/mp5vP3eSq80neXo1adi3rGdnw5A4i8IQeb/f85a6IBb72gW2T+gBO1xShIP7ovrYEMLdrTz6JCnmLhQ11DGTC1pjxbDOn/O0a8xXl8XZtsAxeOmNOM4YVIfn6BdResUWsmpkUfAKzUwn0al+U42/pQobEGacZG58v++7RD8nNrJtA6pecSzeA6LRWIRRerjHxt+nGgbnSFJTC8jApE0DJxdfuUX4VpwIuwpqLkYhlQzYUnKG+OG65uI75Vo32hRYqs7+ihArzDbALxDW2Kbdtf9BCqom22DfeXBop5nKULaofmfXsjlVnkm6p6xEa0Kt419h01HKpOJxe94WY3imbg1yOvciOKJQyDwQQFQgPkak0kLkBuXprgacDChatvEUkIw== hasadna-k8s
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1SUQpPgUcMKvwG0Xk9kYOsLhfaTx9jK1uy3FzNCYoT3AdmeovC+alS82NIdE09l92n1RJgc0w/XFqCOlKEwJJ7AVOIdmtyu+GzDyDnSRAGjkCg37ruZN2YDdG6unQHmH3hku+1+mm67tXW9tiNF2Ghv6AZLh8wuZL5zISAEQJgDZ1FsQ+xwYN+XfxsuHpiL+jrK39SY4xy034vXXYVorR5C3mPUzO8smX74VFc0KEL3mvO3w14gbk5u/9XkM8pqFNk+XD1XPX5dEMPKgI929FU3gokyY4qEq3alfbasCH4O6n+Gz4/yu53gpGzAzAp8hOHrB2plMRYD036Ccmx325
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZmytOYF/XMbF8x5/M+TUEHucU0SdYOw2hVqiguc+yAO17woC+kXFLixiTeMb7NNnQkY4p8m3gufWnMjA7VvEewzU8lTdGa2zwKV+myG/eZwnC1NyyBpPmsvCQnzXSMSONdsIqydKjna/YDDIASF9VIcYmPs9NtOJKeqIA3c9hi7/0Ckr7JlnTevXJkNiAFVrD2Pg7mCOwcWIrUj3qQq4ymTm4mpBPwoWQQ71JNwCRNPZR3mv5o7YbeOrkl7WIq2ouC+LiUmPnvYsxRifv5iUhD9sWlfKKIZzJ9TZigGnmZQbsnkJIEOA8BY7W15FruqQbLHZEq3vsWM1qfDNoV4QPUBvYe5Joc8CbKbH2VFzDJ63jjKIli7t7a3azthPyZUNSqvmu7KBj006IUChZGIkUkYmivKyYcrWE6wSkiOx544bjn9MWI5jX+zxC3NSImMyMl2QOBqBJUCZKYKC0UknXdhZnbEBZTWoIgrEcuTRuvFa4NqKAOdm33vOFfZR1DIIg60NbDE1/gmAuGPAiC7aeHeXwpZgHGiAk1vxDNJ58ELDcV/hO1PTHkE5ZzrNihtrNHnNI4B0rIuuJQ05KIDTHjhczRkf4kTxtwpcufiaGee9HmHL4lmT7+K2MwjRH0GDwapSiAFNijDpgBKRGTJo97EfGBagCLUiGhVtowNK0Dw== hasadna-ssh-access-point
EOF
}

# TODO: upgrade
resource "kamatera_server" "hasadna_ssh_access_point" {
  name = "hasadna-ssh-access-point"
  datacenter_id = "IL"
  cpu_type = "A"
  cpu_cores = 1
  ram_mb = 512
  disk_sizes_gb = [5]
  billing_cycle = "monthly"
  image_id = local.kamatera_image_israel_ubuntu_1804_id

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
if ! [ -e .ssh/id_rsa ]; then ssh-keygen -t rsa -b 4096 -C "hasadna-ssh-access-point" -N "" -f .ssh/id_rsa; fi
EOF
    ]
  }
}

output "hasadna_ssh_access_point_public_ip" {
  value = kamatera_server.hasadna_ssh_access_point.public_ips[0]
  sensitive = true
}

output "hasadna_ssh_access_point_provision" {
  value = null_resource.hasadna_ssh_access_point_provision
}

output "hasadna_authorized_keys" {
  value = local.hasadna_authorized_keys
}

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
  rke2_ssh_known_hosts = join("\n", [
    for name, ip in local.rke2_server_private_ip : "ssh-keyscan -p ${var.hasadna_ssh_access_point_ssh_port} ${ip}"
  ])
}

output "rke2_ssh_config" {
  value = <<-EOF
    Host hasadna-ssh-access-point
      HostName ${kamatera_server.hasadna_ssh_access_point.public_ips[0]}
      User root
      Port ${var.hasadna_ssh_access_point_ssh_port}

    Host hasadna-proxy1
      HostName ${local.hasadna_proxy1_private_ip}
      User root
      ProxyJump hasadna-ssh-access-point

    Host hasadna-dev-server-eu1
      HostName ${kamatera_server.dev_server_eu1.public_ips[0]}
      User root
      Port ${local.dev_server_eu1_ssh_port}

    ${local.rke2_ssh_config_servers}
  EOF
}

resource "null_resource" "rke2_ssh_known_hosts" {
  triggers = {
    command = <<-EOT
      set -euo pipefail
      ssh-keyscan -p ${var.hasadna_ssh_access_point_ssh_port} ${kamatera_server.hasadna_ssh_access_point.public_ips[0]} > .rke2_ssh_known_hosts
      ssh -p ${var.hasadna_ssh_access_point_ssh_port} -o UserKnownHostsFile=.rke2_ssh_known_hosts root@${kamatera_server.hasadna_ssh_access_point.public_ips[0]} "
        ssh-keyscan ${local.hasadna_proxy1_private_ip}
        ${local.rke2_ssh_known_hosts}
      " >> .rke2_ssh_known_hosts
      vault kv put kv/Projects/iac/ssh_rke2_known_hosts known_hosts=@.rke2_ssh_known_hosts
      rm .rke2_ssh_known_hosts
    EOT
  }
  provisioner "local-exec" {
    command = self.triggers.command
    interpreter = ["bash", "-c"]
  }
}
