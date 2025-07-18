# run manually with the Vault root token:
# vault auth tune -default-lease-ttl=4h -max-lease-ttl=4h userpass

data "vault_kv_secret_v2" "cluster-admins" {
  mount = "kv"
  name = "Projects/k8s/auth"
}

locals {
  cluster_admins = split(",", data.vault_kv_secret_v2.cluster-admins.data["cluster-admins"])
}

resource "kubernetes_cluster_role_binding" "cluster-admins" {
  provider = kubernetes.rke2
  metadata {
    name = "cluster-admins"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  dynamic "subject" {
    for_each = toset(local.cluster_admins)
    content {
      kind = "User"
      name = subject.value
      api_group = "rbac.authorization.k8s.io"
    }
  }
}

// this role is meant to be used by AI / automation tools
resource "kubernetes_cluster_role" "cluster-admin-readonly" {
  provider = kubernetes.rke2
  metadata {
    name = "cluster-admin-readonly"
  }
  rule {
    api_groups = [""]
    resources = [
      // all except secrets
      "pods", "services", "configmaps", "persistentvolumeclaims", "persistentvolumes", "nodes", "namespaces", "endpoints", "events", "replicationcontrollers"
    ]
    verbs = ["get", "list", "watch"]
  }
  // use for each to allow multiple groups all resources get list watch
  dynamic "rule" {
    for_each = toset([
      "apps", "batch", "networking.k8s.io", "rbac.authorization.k8s.io", "autoscaling", "policy", "coordination.k8s.io", "storage.k8s.io",
      "scheduling.k8s.io", "argoproj.io", "ceph.rook.io", "monitoring.coreos.com", "acme.cert-manager.io", "cert-manager.io"
    ])
    content {
      api_groups = [rule.value]
      resources = ["*"]
      verbs = ["get", "list", "watch"]
    }
  }
}

resource "kubernetes_cluster_role_binding" "cluster-admins-readonly" {
  provider = kubernetes.rke2
  metadata {
    name = "cluster-admins-readonly"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = kubernetes_cluster_role.cluster-admin-readonly.metadata[0].name
  }
  dynamic "subject" {
    for_each = toset(local.cluster_admins)
    content {
      kind = "User"
      name = subject.value
      api_group = "rbac.authorization.k8s.io"
    }
  }
}

resource "null_resource" "pinniped_kubeconfig" {
  triggers = {
    command = <<-EOT
      set -euo pipefail
      CADATA="$(ssh hasadna-rke2-controlplane1 cat /var/lib/rancher/rke2/server/tls/server-ca.crt | base64 -w0)"
      echo 'apiVersion: v1
      clusters:
      - cluster:
          certificate-authority-data: '$CADATA'
          server: https://${local.rke2_server_public_ip["controlplane1"]}:6443
        name: hasadna-pinniped
      contexts:
      - context:
          cluster: hasadna-pinniped
          user: hasadna-pinniped
        name: hasadna-pinniped
      current-context: hasadna-pinniped
      kind: Config
      preferences: {}
      users:
      - name: hasadna-pinniped
        user:
          exec:
            apiVersion: client.authentication.k8s.io/v1beta1
            args:
            - login
            - oidc
            - --issuer=https://argocd.hasadna.org.il/api/dex
            - --client-id=kubectl
            - --scopes=openid,email,groups,profile
            - --listen-port=18000
            command: pinniped
            env: []
            installHint: The pinniped CLI does not appear to be installed.  See https://get.pinniped.dev/cli
              for more details
            provideClusterInfo: true' > .kubeconfig-pinniped.yaml
      vault kv put kv/Projects/k8s/auth-pinniped-kubeconfig kubeconfig=@.kubeconfig-pinniped.yaml
      rm .kubeconfig-pinniped.yaml .kubeconfig-pinniped-readonly.yaml
    EOT
  }
  provisioner "local-exec" {
    command = self.triggers.command
    interpreter = ["bash", "-c"]
  }
}
