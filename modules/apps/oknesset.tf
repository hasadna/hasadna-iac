locals {
  oknesset_publicdb_readonly_users = [
    "betaknesset"
  ]
}

resource "random_password" "oknesset_publicdb_readonly_username" {
  for_each = toset(local.oknesset_publicdb_readonly_users)
  length   = 6
  special  = false
}

resource "random_password" "oknesset_publicdb_readonly_password" {
  for_each = toset(local.oknesset_publicdb_readonly_users)
  length   = 20
  special  = false
}

resource "terraform_data" "oknesset_publicdb_readonly_users" {
  for_each = toset(local.oknesset_publicdb_readonly_users)
  triggers_replace = {
    command = <<-EOT
    cat <<EOF | kubectl exec -in oknesset deploy/publicdb -- bash -c "psql -U postgres"
      CREATE ROLE "${each.key}-readonly";
      GRANT USAGE ON SCHEMA public TO "${each.key}-readonly";
      GRANT SELECT ON ALL TABLES IN SCHEMA public TO "${each.key}-readonly";
      ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO "${each.key}-readonly";
      CREATE USER "${each.key}-${random_password.oknesset_publicdb_readonly_username[each.key].result}" WITH PASSWORD '${random_password.oknesset_publicdb_readonly_password[each.key].result}';
      GRANT "${each.key}-readonly" TO "${each.key}-${random_password.oknesset_publicdb_readonly_username[each.key].result}";
    EOF
    EOT
  }
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = self.triggers_replace.command
  }
}

output "oknesset_publicdb_readonly_users" {
  value = {
    for user in local.oknesset_publicdb_readonly_users : user => {
      username = "${user}-${random_password.oknesset_publicdb_readonly_username[user].result}"
      password = random_password.oknesset_publicdb_readonly_password[user].result
    }
  }
  sensitive = true
}
