locals {
  kopia_version = "0.20.1"
}

resource "aws_s3_bucket" "hasadna_kopia_backups" {
  bucket = "hasadna-kopia-backups"
  provider = aws.eu_west_3
}

resource "aws_s3_bucket_public_access_block" "hasadna_kopia_backups" {
  bucket = aws_s3_bucket.hasadna_kopia_backups.id
  provider = aws.eu_west_3
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "kopia_backups" {
  name = "kopia_backups"
}

resource "aws_iam_access_key" "kopia_backups" {
  user = aws_iam_user.kopia_backups.name
}

resource "aws_iam_user_policy" "kopia_backups" {
  name = "kopia_backups_policy"
  user = aws_iam_user.kopia_backups.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.hasadna_kopia_backups.arn,
          "${aws_s3_bucket.hasadna_kopia_backups.arn}/*"
        ]
      }
    ]
  })
}

resource "random_password" "kopia_backups_password" {
  length  = 16
  special = true
}

resource "vault_kv_secret_v2" "kopia" {
  data_json = jsonencode({
    password = random_password.kopia_backups_password.result
    aws_user_name = aws_iam_user.kopia_backups.name
    aws_access_key_id = aws_iam_access_key.kopia_backups.id
    aws_secret_access_key = aws_iam_access_key.kopia_backups.secret
    bucket_name = aws_s3_bucket.hasadna_kopia_backups.bucket
    bucket_region = aws_s3_bucket.hasadna_kopia_backups.region
  })
  mount     = "/kv"
  name      = "Projects/iac/kopia"
}

resource "null_resource" "kopia_init_repo" {
  depends_on = [
    aws_s3_bucket.hasadna_kopia_backups
  ]
  triggers = {
    command = <<-EOT
      set -euo pipefail
      export KOPIA_PASSWORD=${random_password.kopia_backups_password.result}
      export AWS_ACCESS_KEY_ID=${aws_iam_access_key.kopia_backups.id}
      export AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.kopia_backups.secret}
      docker run --rm -e KOPIA_PASSWORD -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY --entrypoint bash kopia/kopia:${local.kopia_version} -c '
        set -euo pipefail
        if ! kopia repository connect s3 --bucket=${aws_s3_bucket.hasadna_kopia_backups.bucket} --region=${aws_s3_bucket.hasadna_kopia_backups.region}; then
          kopia repository create s3 --bucket=${aws_s3_bucket.hasadna_kopia_backups.bucket} --region=${aws_s3_bucket.hasadna_kopia_backups.region}
        fi
        kopia policy set --global \
          --keep-annual 10 \
          --keep-monthly 12 \
          --keep-weekly 4 \
          --keep-daily 7 \
          --keep-hourly 48 \
          --keep-latest 10 \
          --max-parallel-snapshots 1 \
          --max-parallel-file-reads 1
      '
    EOT
  }
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = self.triggers.command
  }
}

locals {
  rke2_kopia_backup_servers = {
    for server in concat(
      ["hasadna-nfs1"],
      [for node_name in keys(kamatera_server.rke2) : "hasadna-rke2-${node_name}"]
    ) : server => {
      backup_paths = join(" ", [for k, v in local.rke2_storage_backup_paths : v.path if v.server == server])
      has_backup_paths = length([for k, v in local.rke2_storage_backup_paths : v.path if v.server == server]) > 0
    }
  }
}

resource "statuscake_heartbeat_check" "rke2_backups" {
  for_each = {for k, v in local.rke2_kopia_backup_servers : k => v if v.has_backup_paths}
  name = "rke2-backups-${each.key}"
  period = 60 * 60 * 24 * 2  # if backup doesn't ping this check for 2 days, it will be considered failed
  contact_groups = ["35660"]  # DevOps contact group
}

resource "null_resource" "kopia_init_node" {
    for_each = local.rke2_kopia_backup_servers
    depends_on = [
      null_resource.kopia_init_repo,
      statuscake_heartbeat_check.rke2_backups
    ]
    triggers = {
        server = each.key
        hash = join("\n", [
          sha256(file("${path.module}/rke2_backups_kopia_connect.sh")),
          sha256(file("${path.module}/rke2_backups_cronjob.sh")),
        ])
        command = <<-EOT
        set -euo pipefail
        scp ${path.module}/rke2_backups_kopia_connect.sh ${each.key}:/root/kopia_connect.sh
        scp ${path.module}/rke2_backups_cronjob.sh ${each.key}:/root/backups_cronjob.sh
        ssh ${each.key} "
          set -euo pipefail
          rm -f kopia-${local.kopia_version}-linux-x64.tar.gz
          wget https://github.com/kopia/kopia/releases/download/v${local.kopia_version}/kopia-${local.kopia_version}-linux-x64.tar.gz
          tar -xzvf kopia-${local.kopia_version}-linux-x64.tar.gz
          mv kopia-${local.kopia_version}-linux-x64/kopia /usr/local/bin/
          chmod +x /usr/local/bin/kopia
          rm -rf kopia-${local.kopia_version}-linux-x64 kopia-${local.kopia_version}-linux-x64.tar.gz
          echo '
          export KOPIA_PASSWORD=\"${random_password.kopia_backups_password.result}\"
          export AWS_ACCESS_KEY_ID=\"${aws_iam_access_key.kopia_backups.id}\"
          export AWS_SECRET_ACCESS_KEY=\"${aws_iam_access_key.kopia_backups.secret}\"
          export KOPIA_CHECK_FOR_UPDATES=\"false\"
          BUCKET=\"${aws_s3_bucket.hasadna_kopia_backups.bucket}\"
          REGION=\"${aws_s3_bucket.hasadna_kopia_backups.region}\"
          STATUSCAKE_HEATBEAT_URL=\"${each.value.has_backup_paths ? statuscake_heartbeat_check.rke2_backups[each.key].check_url : ""}\"
          ' > /root/.kopia.env
          echo ${each.value.backup_paths} > /root/.kopia.backup_paths
          chmod +x /root/kopia_connect.sh /root/backups_cronjob.sh
          echo 35 1 '*' '*' '*' root /root/backups_cronjob.sh > /etc/cron.d/kopia_backups_cronjob
          systemctl restart cron
        "
        EOT
    }
    provisioner "local-exec" {
        interpreter = ["bash", "-c"]
        command = self.triggers.command
    }
}
