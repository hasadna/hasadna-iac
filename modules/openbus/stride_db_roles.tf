locals {
  default_readonly_user_sql = <<-EOF
ALTER ROLE __role_name__ SET statement_timeout = '60s';
ALTER ROLE __role_name__ SET lock_timeout = '10s';
ALTER ROLE __role_name__ SET idle_in_transaction_session_timeout = '120s';
ALTER ROLE __role_name__ SET idle_session_timeout = '0';
REVOKE ALL ON DATABASE postgres FROM __role_name__;
REVOKE ALL ON SCHEMA public FROM __role_name__;
GRANT CONNECT ON DATABASE postgres TO __role_name__;
GRANT USAGE ON SCHEMA public TO __role_name__;
GRANT SELECT ON TABLE public.artifact TO __role_name__;
GRANT SELECT ON TABLE public.clustertoline TO __role_name__;
GRANT SELECT ON TABLE public.gtfs_data TO __role_name__;
GRANT SELECT ON TABLE public.gtfs_data_task TO __role_name__;
GRANT SELECT ON TABLE public.gtfs_ride TO __role_name__;
GRANT SELECT ON TABLE public.gtfs_ride_stop TO __role_name__;
GRANT SELECT ON TABLE public.gtfs_stop TO __role_name__;
GRANT SELECT ON TABLE public.gtfs_route TO __role_name__;
GRANT SELECT ON TABLE public.gtfs_stop_mot_id TO __role_name__;
GRANT SELECT ON TABLE public.siri_ride TO __role_name__;
GRANT SELECT ON TABLE public.siri_ride_stop TO __role_name__;
GRANT SELECT ON TABLE public.siri_route TO __role_name__;
GRANT SELECT ON TABLE public.siri_snapshot TO __role_name__;
GRANT SELECT ON TABLE public.siri_stop TO __role_name__;
GRANT SELECT ON TABLE public.siri_vehicle_location TO __role_name__;
EOF
  stride_db_roles = {
    "redash_reader": {
      "role_with": "NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS"
      "set_password": true
      "sql" = local.default_readonly_user_sql
    }
    "api": {
      "role_with": "NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS"
      "set_password": true
      "sql" = local.default_readonly_user_sql
    }
  }
}

resource "random_password" "stride_db_role" {
  for_each = {for role_name, role in local.stride_db_roles : role_name => role if role.set_password}
  length = 32
  lower = true
  upper = true
  numeric = true
  special = false
}

resource "vault_kv_secret_v2" "stride_db_roles" {
  data_json = jsonencode(merge(
    {
      for role_name, role in local.stride_db_roles : "${role_name}-password" => random_password.stride_db_role[role_name].result if role.set_password
    },
    {
      for role_name, role in local.stride_db_roles : "${role_name}-pgbouncer-auth-file" => "\"${role_name}\" \"${random_password.stride_db_role[role_name].result}\"" if role.set_password
    }
  ))
  mount = "/kv"
  name = "Projects/OBus/stride-db-roles"
}

resource "terraform_data" "stride_db_role" {
  for_each = local.stride_db_roles
  triggers_replace = {
    script = nonsensitive(<<-EOF
ssh stride-db sudo -u postgres bash <<'EOT'
set -euo pipefail
cd
export LC_ALL=C.UTF-8
psql -Atqc "CREATE ROLE ${each.key};" || true
psql -Atqc "ALTER ROLE ${each.key} WITH ${each.value.role_with};"
if [ "${each.value.set_password}" = "true" ]; then
  psql -Atqc "ALTER ROLE ${each.key} WITH PASSWORD '${random_password.stride_db_role[each.key].result}';"
fi
psql -Atqc "
BEGIN;
${replace(each.value.sql, "__role_name__", each.key)}
COMMIT;
"
EOT
EOF
    )
  }
  provisioner "local-exec" {
    command = self.triggers_replace.script
    interpreter = ["bash", "-c"]
  }
}
