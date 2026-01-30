locals {
  openbus_repo_deploy_keys = {
    # repo name under hasadna/ org - to allow to make changes to using the deploy key
    open-bus-stride-api = [
      # repo names that will hold the secret with the private key and use it to make changes
      "open-bus-stride-db"
    ]
  }
}

resource "tls_private_key" "openbus_repo_deploy_keys" {
  for_each = toset(keys(local.openbus_repo_deploy_keys))
  algorithm = "RSA"
}

resource "github_repository_deploy_key" "openbus_repo_deploy_keys" {
  for_each = toset(keys(local.openbus_repo_deploy_keys))
  repository = each.key
  title = each.key
  key = tls_private_key.openbus_repo_deploy_keys[each.key].public_key_openssh
  read_only = false
}

resource "github_actions_secret" "openbus_repo_deploy_keys" {
  for_each = {
    for d in flatten(
      [
        for deploy_repo_name, target_repo_names in local.openbus_repo_deploy_keys: [
          for target_repo_name in target_repo_names : {
            deploy_repo_name = deploy_repo_name
            target_repo_name = target_repo_name
          }
        ]
      ]
    ) : "${d.deploy_repo_name}_${d.target_repo_name}" => d
  }
  repository = each.value["target_repo_name"]
  secret_name = join("_", [replace(upper(each.value["deploy_repo_name"]), "-", "_"), "DEPLOY_KEY"])
  plaintext_value = tls_private_key.openbus_repo_deploy_keys[each.value["deploy_repo_name"]].private_key_pem
}
