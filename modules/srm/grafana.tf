# we need to give editor role to allow accessing explore logs

resource "random_password" "srm_editor_password" {
  length = 16
}

resource "grafana_user" "srm_editor" {
  name = "srm-editor"
  email = "srm-editor@localhost"
  login = "srm-editor"
  password = random_password.srm_editor_password.result
}

resource "vault_kv_secret_v2" "srm_editor" {
  mount = "/kv"
  name  = "Projects/srm/grafana_editor"
  data_json = jsonencode({
    user = grafana_user.srm_editor.login
    password = random_password.srm_editor_password.result
  })
}
