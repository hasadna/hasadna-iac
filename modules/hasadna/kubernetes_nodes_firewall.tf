resource "kubernetes_namespace" "firewall" {
  metadata {
    name = "firewall"
    labels = {
      "field.cattle.io/projectId" = local.rancher_project_system
    }
  }
  lifecycle {
    ignore_changes = [
      metadata.0.annotations
    ]
  }
}

resource "kubernetes_daemonset" "firewall" {
  depends_on = [kubernetes_namespace.firewall]
  metadata {
    name = "firewall"
    namespace = "firewall"
  }
  spec {
    selector {
      match_labels = {
        app = "firewall"
      }
    }
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = "100%"
      }
    }
    template {
      metadata {
        labels = {
          app = "firewall"
        }
      }
      spec {
        toleration {
          key = "controlplane"
          value = "true"
          effect = "NoSchedule"
        }
        automount_service_account_token = false
        host_ipc = true
        host_network = true
        host_pid = true
        init_container {
          name = "firewall"
          # pulled Jun 19, 2022
          image = "alpine@sha256:686d8c9dfa6f3ccfc8230bc3178d23f84eeaf7e457f36f271ab1acc53015037c"
          security_context {
            privileged = true
          }
          command = [
            "sh", "-c",
            <<EOF
chroot /host bash -c "
  ufw --force reset &&\
  ufw default allow outgoing &&\
  ufw default allow incoming &&\
  ufw default deny routed &&\
  ufw allow in from ${kamatera_server.k972il_cluster2_management.public_ips[0]} to any &&\
  ufw allow in from ${kamatera_server.k972il_jenkins.public_ips[0]} to any &&\
  ufw allow in from ${kamatera_server.hasadna_ssh_access_point.public_ips[0]} to any &&\
  ufw deny in on eth0 to any port 22 &&\
  ufw --force enable && ufw status verbose
"
EOF
          ]
          volume_mount {
            mount_path = "/host"
            name       = "hostfs"
          }
        }
        container {
          name = "pause"
          command = ["sh", "-c", "while true; do sleep 86400; done"]
          image = "busybox"
        }
        volume {
          name = "hostfs"
          host_path {
            path = "/"
            type = ""
          }
        }
      }
    }
  }
}