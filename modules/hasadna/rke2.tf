locals {
  kube_version = "v1.33.1"
  rke2_version = "${local.kube_version}+rke2r1"
  rke2_servers = {
    controlplane1 = {
      type = "controlplane1"
      cpu_cores = 8
      ram_mb = 16384
      disk_sizes_gb = [100]
      ingress = false
      storage = false
    }
    # used for critical non application workloads only
    critical1 = {
      type = "critical"
      cpu_cores = 8
      ram_mb = 16384
      disk_sizes_gb = [100, 1000]  # the extra disk is used directly by Ceph
      ingress = false
      storage = false
    }
    worker1 = {
      type = "worker"
      cpu_cores = 24
      ram_mb = 65536
      disk_sizes_gb = [100, 500]
      ingress = true
      storage = "/dev/sdb1"
    }
    worker2 = {
      type = "worker"
      cpu_cores = 24
      ram_mb = 65536
      disk_sizes_gb = [100, 700]
      ingress = true
      storage = "/dev/sdb1"
    }
    worker3 = {
      type = "worker"
      cpu_cores = 24
      ram_mb = 65536
      disk_sizes_gb = [100]
      ingress = true
      storage = false
    }
    worker4 = {
      type = "worker"
      cpu_cores = 24
      ram_mb = 65536
      disk_sizes_gb = [100]
      ingress = false
      storage = false
    }
  }
}

resource "kamatera_server" "rke2" {
  for_each = local.rke2_servers
  name = "hasadna-rke2-${each.key}"
  datacenter_id = "IL"
  cpu_type = "B"
  cpu_cores = each.value.cpu_cores
  ram_mb = each.value.ram_mb
  disk_sizes_gb = each.value.disk_sizes_gb
  billing_cycle = "monthly"
  image_id = local.kamatera_image_israel_ubuntu_2404_id

  network {
    name = "wan"
  }

  network {
    name = kamatera_network.hasadna.full_name
  }
}

locals {
  rke2_server_public_ip = {
    for name, server in local.rke2_servers : name => kamatera_server.rke2[name].public_ips[0]
  }
  rke2_server_private_ip = {
    for name, server in local.rke2_servers : name => kamatera_server.rke2[name].private_ips[0]
  }
}

output "rke2_server_public_ips" {
  value = local.rke2_server_public_ip
}

output "rke2_server_private_ips" {
    value = local.rke2_server_private_ip
}

output "rke2_server_passwords" {
    value = {
        for name, server in local.rke2_servers : name => kamatera_server.rke2[name].generated_password
    }
    sensitive = true
}

resource "null_resource" "rke2_init_ssh" {
  for_each = local.rke2_servers
  depends_on = [kamatera_server.rke2]
  triggers = {
    command = <<-EOF
      echo ${base64encode(var.ssh_authorized_keys)} | base64 -d > .ssh/authorized_keys &&\
      if [ -f /etc/ssh/sshd_config.d/50-cloud-init.conf ]; then
        sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config.d/50-cloud-init.conf
      fi &&\
      mkdir -p /etc/systemd/system/ssh.socket.d &&\
      echo '[Socket]' > /etc/systemd/system/ssh.socket.d/override.conf &&\
      echo 'ListenStream=' >> /etc/systemd/system/ssh.socket.d/override.conf &&\
      echo 'ListenStream=${local.rke2_server_private_ip[each.key]}:${var.hasadna_ssh_access_point_ssh_port}' >> /etc/systemd/system/ssh.socket.d/override.conf &&\
      systemctl daemon-reload &&\
      systemctl restart ssh.socket &&\
      systemctl restart ssh.service
    EOF
  }
  provisioner "local-exec" {
    command = <<-EOT
      if ssh -o ProxyJump=hasadna-ssh-access-point -p ${var.hasadna_ssh_access_point_ssh_port} root@${local.rke2_server_private_ip[each.key]} true; then
        ssh -o ProxyJump=hasadna-ssh-access-point -p ${var.hasadna_ssh_access_point_ssh_port} root@${local.rke2_server_private_ip[each.key]} \
          "${self.triggers.command}"
      else
        sshpass -p '${kamatera_server.rke2[each.key].generated_password}' \
          ssh -o StrictHostKeyChecking=no root@${local.rke2_server_public_ip[each.key]} \
            "${self.triggers.command}"
      fi
    EOT
  }
}

resource "null_resource" "rke2_prepare_nodes" {
  for_each = local.rke2_servers
  depends_on = [null_resource.rke2_init_ssh]
  triggers = {
    counter = 1
    command = <<-EOF
      set -euo pipefail
      echo 'vm.max_map_count = 262144' > /etc/sysctl.d/99-hasadna.conf
      echo 'net.ipv4.tcp_retries2 = 8' >> /etc/sysctl.d/99-hasadna.conf
      echo 'fs.inotify.max_user_instances = 1024' >> /etc/sysctl.d/99-hasadna.conf
      echo 'fs.inotify.max_user_watches   = 2097152' >> /etc/sysctl.d/99-hasadna.conf
      echo 'fs.inotify.max_queued_events  = 65536' >> /etc/sysctl.d/99-hasadna.conf
      echo 'net.core.somaxconn = 65535' >> /etc/sysctl.d/99-hasadna.conf
      echo 'net.core.netdev_max_backlog = 16384' >> /etc/sysctl.d/99-hasadna.conf
      echo 'net.ipv4.tcp_max_syn_backlog = 8192' >> /etc/sysctl.d/99-hasadna.conf
      sysctl --system
      rm -f /etc/systemd/system/systemd-networkd-wait-online.service.d/override.conf
      systemctl daemon-reload
      systemctl restart systemd-networkd-wait-online.service
      apt update && apt install -y nfs-common
      if ! [ -e /root/.ssh/id_rsa ]; then ssh-keygen -t rsa -b 4096 -N '' -f /root/.ssh/id_rsa; fi
      echo 'export PATH="/var/lib/rancher/rke2/bin/:$PATH"' > /etc/profile.d/00-hasadna.sh
      echo 'export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml' >> /etc/profile.d/00-hasadna.sh
      echo 'export CONTAINERD_ADDRESS=/run/k3s/containerd/containerd.sock' >> /etc/profile.d/00-hasadna.sh
      echo 'export CONTAINERD_NAMESPACE=k8s.io' >> /etc/profile.d/00-hasadna.sh
      if [ -e /etc/rancher/rke2/rke2.yaml ]; then
        echo 'export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"' >> /etc/profile.d/00-hasadna.sh
      fi
    EOF
  }
  provisioner "local-exec" {
    command = <<-EOT
      ssh -o ProxyJump=hasadna-ssh-access-point -p ${var.hasadna_ssh_access_point_ssh_port} root@${local.rke2_server_private_ip[each.key]} \
        "${self.triggers.command}"
    EOT
  }
}

resource "null_resource" "rke2_install_controlplane1" {
  depends_on = [null_resource.rke2_prepare_nodes]
  triggers = {
    counter = 2
    authn = <<-EOF
      apiVersion: apiserver.config.k8s.io/v1beta1
      kind: AuthenticationConfiguration
      jwt:
        - issuer:
            url: "https://argocd.hasadna.org.il/api/dex"
            audiences:
              - kubectl
          claimMappings:
            username:
              claim: preferred_username
              prefix: argocddex_github_
            groups:
              claim: groups
              prefix: argocddex_github_
    EOF
    config = <<-EOF
      node-name: controlplane1
      node-ip: ${local.rke2_server_private_ip["controlplane1"]}
      node-external-ip: ${local.rke2_server_public_ip["controlplane1"]}
      advertise-address: ${local.rke2_server_private_ip["controlplane1"]}
      tls-san:
        - 0.0.0.0
        - ${local.rke2_server_private_ip["controlplane1"]}
        - ${local.rke2_server_public_ip["controlplane1"]}
      etcd-snapshot-retention: 14  # snapshot every 12 hours, total of 1 week
      kube-apiserver-arg:
        - "--authentication-config=/etc/rancher/rke2/authn/authn.yaml"
    EOF
    command = <<-EOF
      curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=${local.rke2_version} sh - &&\
      if systemctl is-active --quiet rke2-server.service; then
        systemctl restart rke2-server.service
      else
        systemctl enable rke2-server.service &&\
        systemctl start rke2-server.service
      fi
    EOF
  }
  provisioner "local-exec" {
    command = <<-EOT
      ssh -o ProxyJump=hasadna-ssh-access-point -p ${var.hasadna_ssh_access_point_ssh_port} root@${local.rke2_server_private_ip["controlplane1"]} \
        mkdir -p /etc/rancher/rke2/authn &&\
      echo "${self.triggers.config}" \
        | ssh -o ProxyJump=hasadna-ssh-access-point -p ${var.hasadna_ssh_access_point_ssh_port} root@${local.rke2_server_private_ip["controlplane1"]} \
          "cat > /etc/rancher/rke2/config.yaml" &&\
      echo "${self.triggers.authn}" \
        | ssh -o ProxyJump=hasadna-ssh-access-point -p ${var.hasadna_ssh_access_point_ssh_port} root@${local.rke2_server_private_ip["controlplane1"]} \
          "cat > /etc/rancher/rke2/authn/authn.yaml" &&\
      ssh -o ProxyJump=hasadna-ssh-access-point -p ${var.hasadna_ssh_access_point_ssh_port} root@${local.rke2_server_private_ip["controlplane1"]} \
        "${self.triggers.command}"
    EOT
  }
}

resource "null_resource" "rke2_install_workers" {
  for_each = {
    for name, server in local.rke2_servers : name => server if server.type == "worker" || server.type == "critical"
  }
  depends_on = [null_resource.rke2_install_controlplane1]
  triggers = {
    counter = 2
    config = <<-EOF
      node-name: ${each.key}
      node-ip: ${local.rke2_server_private_ip[each.key]}
      node-external-ip: ${local.rke2_server_public_ip[each.key]}
      token-file: /etc/rancher/rke2/node-token
      server: https://${local.rke2_server_private_ip["controlplane1"]}:9345
    EOF
    command = <<-EOF
      curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=${local.rke2_version} INSTALL_RKE2_TYPE=agent sh - &&\
      if systemctl is-active --quiet rke2-agent.service; then
        systemctl restart rke2-agent.service
      else
        systemctl enable rke2-agent.service &&\
        systemctl start rke2-agent.service
      fi
    EOF
  }
  provisioner "local-exec" {
    command = <<-EOT
      ssh -o ProxyJump=hasadna-ssh-access-point -p ${var.hasadna_ssh_access_point_ssh_port} root@${local.rke2_server_private_ip[each.key]} \
        mkdir -p /etc/rancher/rke2 &&\
      ssh -o ProxyJump=hasadna-ssh-access-point -p ${var.hasadna_ssh_access_point_ssh_port} root@${local.rke2_server_private_ip["controlplane1"]} \
        "cat /var/lib/rancher/rke2/server/node-token" \
          | ssh -o ProxyJump=hasadna-ssh-access-point -p ${var.hasadna_ssh_access_point_ssh_port} root@${local.rke2_server_private_ip[each.key]} \
            "cat > /etc/rancher/rke2/node-token" &&\
      echo "${self.triggers.config}" \
        | ssh -o ProxyJump=hasadna-ssh-access-point -p ${var.hasadna_ssh_access_point_ssh_port} root@${local.rke2_server_private_ip[each.key]} \
          "cat > /etc/rancher/rke2/config.yaml" &&\
      ssh -o ProxyJump=hasadna-ssh-access-point -p ${var.hasadna_ssh_access_point_ssh_port} root@${local.rke2_server_private_ip[each.key]} \
        "${self.triggers.command}"
    EOT
  }
}

resource "null_resource" "rke2_kubeconfig" {
  depends_on = [null_resource.rke2_install_controlplane1]
  triggers = {
    counter = 2
  }
  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p ${dirname(var.rke2_kubeconfig_path)} &&\
      ssh -o ProxyJump=hasadna-ssh-access-point -p ${var.hasadna_ssh_access_point_ssh_port} root@${local.rke2_server_private_ip["controlplane1"]} \
        cat /etc/rancher/rke2/rke2.yaml \
          > ${var.rke2_kubeconfig_path} &&\
      sed -i 's|https://127.0.0.1:6443|https://${local.rke2_server_public_ip["controlplane1"]}:6443|' ${var.rke2_kubeconfig_path}
    EOT
  }
}

provider "kubernetes" {
  alias = "rke2"
  config_path = var.rke2_kubeconfig_path
}

resource "kubernetes_node_taint" "rke2_controlplane_criticalonly" {
  depends_on = [null_resource.rke2_kubeconfig]
  provider = kubernetes.rke2
  metadata {
    name = "controlplane1"
  }
  taint {
    key    = "CriticalAddonsOnly"
    value  = "true"
    effect = "NoExecute"
  }
}

resource "kubernetes_node_taint" "rke2_critical" {
  depends_on = [null_resource.rke2_kubeconfig]
  provider = kubernetes.rke2
  for_each = {
    for name, server in local.rke2_servers : name => server if server.type == "critical"
  }
  metadata {
      name = each.key
  }
  taint {
    key    = "CriticalAddonsOnly"
    value  = "true"
    effect = "NoExecute"
  }
}

ephemeral "vault_kv_secret_v2" "rke2_registries" {
  mount = "/kv"
  name = "Projects/k8s/rke2-registries"
}

resource "null_resource" "rke2_registries" {
  depends_on = [null_resource.rke2_install_controlplane1, null_resource.rke2_install_workers]
  for_each = local.rke2_servers
  triggers = {
    counter = 2
  }
  provisioner "local-exec" {
    command = <<-EOF
    ssh hasadna-rke2-${each.key} "
      set -euo pipefail
      echo ${base64encode(ephemeral.vault_kv_secret_v2.rke2_registries.data["registries.yaml"])} | base64 -d > /etc/rancher/rke2/registries.yaml
    "
    EOF
  }
}
