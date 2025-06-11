ephemeral "random_password" "wordpress_socialpro_social_db" {
  length           = 16
  special          = true
}

resource "vault_kv_secret_v2" "wordpress_socialpro_social" {
  mount = "/kv"
  name = "Projects/wordpress/socialpro_social"
  data_json_wo = jsonencode({
    db_password = ephemeral.random_password.wordpress_socialpro_social_db.result
  })
}
