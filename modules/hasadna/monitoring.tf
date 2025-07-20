# slack https://api.slack.com/apps -> create new app "hasadna-iac-monitoring" in Public Knowledge Slack workspace
#    enable incoming webhooks
#    add webhook to channel cluster-rke2-notifications
#    copy the webhook URL
#    paste in Vault `Projects/iac/monitoring` under `slack-webhook-cluster-rke2-notifications`

resource "statuscake_heartbeat_check" "monitoring_watchdog" {
  name = "prometheus-watchdog"
  period = 60 * 20  # expects a ping every 20 minutes
  contact_groups = ["35660"]  # DevOps contact group
}

resource "vault_kv_secret_v2" "statuscake_monitoring_watchdog" {
  data_json = jsonencode({
    webhook-url = statuscake_heartbeat_check.monitoring_watchdog.check_url
  })
  mount = "/kv"
  name = "Projects/iac/monitoring-statuscake-watchdog"
}
