locals {
  hasadna_k8s_deploy_keys = {
    # "name of deploy key in hasadna-k8s repo": {
    #   "repos": {
    #       "name of github repo in hasadna org": {}
    "open-pension": {
      "repos": {
        "open-pension-ng": {}
      }
    }
    "open-bus-rides-history": {
      "repos": {
        "open-bus-rides-history": {}
      }
    }
    "socialsocialpro": {
      "repos": {
        "socialsocialpro": {}
      }
    }
  }
}

resource "tls_private_key" "hasadna_k8s_deploy_keys" {
  for_each = local.hasadna_k8s_deploy_keys
  algorithm = "RSA"
}

resource "github_repository_deploy_key" "hasadna_k8s" {
  for_each = local.hasadna_k8s_deploy_keys
  repository = "hasadna-k8s"
  title = each.key
  key = tls_private_key.hasadna_k8s_deploy_keys[each.key].public_key_openssh
  read_only = false
}

resource "github_actions_secret" "hasadna_k8s_deploy_keys" {
  for_each = {
    for d in flatten(
      [
        for deploy_key_name, deploy_key_config in local.hasadna_k8s_deploy_keys: [
          for repo_name, repo_config in deploy_key_config["repos"] : {
            secret = lookup(repo_config, "secret_name", "HASADNA_K8S_DEPLOY_KEY")
            repo = repo_name
            deploy_key = deploy_key_name
          }
        ]
      ]
    ) : "${d.deploy_key}_${d.repo}" => d
  }
  repository = each.value["repo"]
  secret_name = each.value["secret"]
  plaintext_value = tls_private_key.hasadna_k8s_deploy_keys[each.value["deploy_key"]].private_key_pem
}

# hasadna-k8s github app was created manually in the GitHub UI
# Private key was generated and uploaded to Vault at `Projects/k8s/github-app` under key `private-key.pem`
# App was manually installed on `hasadna` organization for all current and future repositories
# following values are also stored in Vault at `Projects/k8s/github-app`:
# - `app_id`
# - `installation_id`
