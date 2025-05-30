resource "kubernetes_namespace" "rke2_argocd" {
  depends_on = [null_resource.rke2_kubeconfig]
  provider = kubernetes.rke2
  metadata {
    name = "argocd"
  }
}

resource "vault_policy" "rke2_argocd_read_only" {
  name = "rke2_argocd_read_only"
  policy = <<EOF
    path "kv/data/*" {
      capabilities = [ "read" ]
    }
  EOF
}

resource "vault_approle_auth_backend_role" "rke2_argocd_read_only" {
  role_name = "rke2_argocd_read_only"
  token_policies = [vault_policy.rke2_argocd_read_only.name]
  token_ttl = 3600
  token_max_ttl = 14400
}

resource "vault_approle_auth_backend_role_secret_id" "rke2_argocd_read_only" {
  role_name = vault_approle_auth_backend_role.rke2_argocd_read_only.role_name
}

resource "kubernetes_secret" "rke2_vault_plugin_credentials" {
    depends_on = [vault_approle_auth_backend_role_secret_id.rke2_argocd_read_only]
    provider = kubernetes.rke2
    metadata {
        name = "argocd-vault-plugin-credentials"
        namespace = kubernetes_namespace.rke2_argocd.metadata[0].name
    }
    data = {
        VAULT_ADDR = trimsuffix(var.vault_addr, "/")
        AVP_TYPE = "vault"
        AVP_AUTH_TYPE = "approle"
        AVP_ROLE_ID = vault_approle_auth_backend_role.rke2_argocd_read_only.role_id
        AVP_SECRET_ID = vault_approle_auth_backend_role_secret_id.rke2_argocd_read_only.secret_id
    }
}

resource "null_resource" "rke2_argocd_install" {
  depends_on = [kubernetes_namespace.rke2_argocd]
  triggers = {
    counter = 8
  }
  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${var.rke2_kubeconfig_path}
      export KUBE_VERSION=${local.kube_version}
      bash ${path.module}/rke2_argocd_install.sh
    EOT
  }
}

# see modules/datacity/argocd.tf - for secrets that need to be created
# see hasadna-k8s/apps/argoworkflows - for secrets that need to be created

# Create a GitHub OAUTH app under Hasadna org:
#  name: rke2-argocd
#  homepage URL: https://argocd.{rke2_catchall_hostname}
#  Authorization callback URL: https://argocd.{rke2_catchall_hostname}/api/dex/callback
# set in vault Projects/k8s/argocd
#  rke2_github_client_id
#  rke2_github_client_secret
# reinstall rke2 argocd to apply the new secrets
