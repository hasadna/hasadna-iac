locals {
  rke2_maintenance_servers = merge(
    {
      for k, v in local.rke2_servers : k => {
        server = "hasadna-rke2-${k}"
      }
    },
    {
      nfs1 = {
          server = "hasadna-nfs1"
      }
    }
  )
}

resource "statuscake_heartbeat_check" "rke2_maintenance" {
  for_each = toset(keys(local.rke2_maintenance_servers))
  name = "rke2-maintenance-${each.key}"
  period = 60 * 60 * 24 * 2  # if the cronjob doesn't ping this check for 2 days, it will be considered failed
  contact_groups = ["35660"]  # DevOps contact group
}

resource "null_resource" "rke2_maintenance_cronjob" {
    for_each = local.rke2_maintenance_servers
    depends_on = [
      statuscake_heartbeat_check.rke2_maintenance,
      null_resource.rke2_install_controlplane1,
      null_resource.rke2_install_workers
    ]
    triggers = {
      hash = join("\n", concat([
        sha256(file("${path.module}/maintenance_rke2_cronjob.py")),
        sha256(file("${path.module}/maintenance_hasadna_k8s.sh"))
      ]))
      command = <<-EOT
        set -euo pipefail
        scp ${path.module}/maintenance_rke2_cronjob.py ${each.value.server}:/root/rke2_maintenance_cronjob.py
        scp ${path.module}/maintenance_hasadna_k8s.sh ${each.value.server}:/root/hasadna_k8s.sh
        ssh ${each.value.server} "
          set -euo pipefail
          echo '${statuscake_heartbeat_check.rke2_maintenance[each.key].check_url}' > /root/rke2_maintenance_heartbeat_url
          chmod +x /root/rke2_maintenance_cronjob.py /root/hasadna_k8s.sh
          /root/hasadna_k8s.sh --help
          echo 21 2 '*' '*' '*' root /root/rke2_maintenance_cronjob.py > /etc/cron.d/rke2_maintenance
          systemctl restart cron
        "
      EOT
    }
    provisioner "local-exec" {
        interpreter = ["bash", "-c"]
        command = self.triggers.command
    }
}
