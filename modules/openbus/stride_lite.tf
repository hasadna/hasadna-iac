# stride-lite: the Stride API rebuilt on ClickHouse (https://github.com/NoamGaash/stride-lite).
# The server is bootstrapped from that repo by scripts/bootstrap-node.sh, run once over SSH:
#
#   ssh stride-lite 'curl -fsSL https://raw.githubusercontent.com/NoamGaash/stride-lite/main/scripts/bootstrap-node.sh |
#     DATA_DEVICE=/dev/sdb BACKUP_URL=s3://stride-lite-backup-621816331709/full/ \
#     BACKUP_PUBLISH=s3://openbus-stride-lite-backup/full/ \
#     AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... bash'
#
# The key is in Vault under Projects/OBus/stride-lite.

resource "kamatera_server" "stride_lite" {
  name          = "hasadna-stride-lite"
  datacenter_id = "IL"
  cpu_type      = "B"
  cpu_cores     = 2
  ram_mb        = 8192
  # The second disk is ClickHouse's data; the database is about 260 GB.
  disk_sizes_gb = [30, 400]
  billing_cycle = "monthly"
  image_id      = "ubuntu"

  network {
    name = "wan"
  }

  lifecycle {
    ignore_changes = [disk_sizes_gb]
  }
}

resource "cloudflare_dns_record" "stride_lite" {
  zone_id = var.cloudflare_zone_hasadna_org_il.zone_id
  name    = "open-bus-api.${var.cloudflare_zone_hasadna_org_il.name}"
  content = kamatera_server.stride_lite.public_ips[0]
  type    = "A"
  proxied = true
  ttl     = 1
}

resource "null_resource" "stride_lite_ssh_access_point" {
  depends_on = [kamatera_server.stride_lite, var.hasadna_ssh_access_point_provision]
  triggers = {
    authorized_keys = var.hasadna_authorized_keys
    version         = 1
  }
  provisioner "remote-exec" {
    connection {
      host        = var.hasadna_ssh_access_point_public_ip
      private_key = var.ssh_private_key
      port        = var.hasadna_ssh_access_point_ssh_port
    }
    inline = [
      <<EOF
if ! cat .ssh/config | grep "Host stride-lite"; then
echo "
Host stride-lite
  HostName ${kamatera_server.stride_lite.public_ips[0]}
  User root
" >> .ssh/config
fi &&\
if ! cat .ssh/known_hosts | grep "^# stride-lite"; then
  echo "# stride-lite" >> .ssh/known_hosts &&\
  ssh-keyscan -H ${kamatera_server.stride_lite.public_ips[0]} >> .ssh/known_hosts
fi &&\
scp .ssh/authorized_keys stride-lite:.ssh/authorized_keys &&\
ssh stride-lite "
ufw --force reset &&\
ufw default allow outgoing &&\
ufw default deny incoming &&\
ufw allow in from ${var.hasadna_ssh_access_point_public_ip} to any port 22 &&\
ufw allow in to any port 80 &&\
ufw --force enable
"
EOF
    ]
  }
}

# A copy of the built database, in ClickHouse's own backup format: restoring it takes
# an hour where rebuilding from openbus-stride-public takes days. Public-read like that
# bucket, since everything in it is already public.
resource "aws_s3_bucket" "stride_lite_backup" {
  bucket = "openbus-stride-lite-backup"
}

resource "aws_s3_bucket_public_access_block" "stride_lite_backup" {
  bucket                  = aws_s3_bucket.stride_lite_backup.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "stride_lite_backup" {
  bucket     = aws_s3_bucket.stride_lite_backup.id
  depends_on = [aws_s3_bucket_public_access_block.stride_lite_backup]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = ["s3:GetObject", "s3:ListBucket"]
      Resource  = [aws_s3_bucket.stride_lite_backup.arn, "${aws_s3_bucket.stride_lite_backup.arn}/*"]
    }]
  })
}

resource "aws_iam_user" "stride_lite_backup" {
  name = "stride_lite_backup"
}

resource "aws_iam_access_key" "stride_lite_backup" {
  user = aws_iam_user.stride_lite_backup.name
}

resource "aws_iam_user_policy" "stride_lite_backup" {
  name = "stride_lite_backup_policy"
  user = aws_iam_user.stride_lite_backup.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:ListBucket", "s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:AbortMultipartUpload"]
        Resource = [
          aws_s3_bucket.stride_lite_backup.arn,
          "${aws_s3_bucket.stride_lite_backup.arn}/*",
        ]
      },
      {
        # The first load restores from the bucket stride-lite started in, in another
        # account. It is public, but a signed request across accounts also needs this
        # side's allow. Remove once the backup above has been published.
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetObject"]
        Resource = ["arn:aws:s3:::stride-lite-backup-621816331709", "arn:aws:s3:::stride-lite-backup-621816331709/*"]
      },
    ]
  })
}

resource "vault_kv_secret_v2" "stride_lite" {
  mount = "/kv"
  name  = "Projects/OBus/stride-lite"
  data_json = jsonencode({
    server_ip             = kamatera_server.stride_lite.public_ips[0]
    aws_access_key_id     = aws_iam_access_key.stride_lite_backup.id
    aws_secret_access_key = aws_iam_access_key.stride_lite_backup.secret
    backup_bucket         = aws_s3_bucket.stride_lite_backup.bucket
  })
}
