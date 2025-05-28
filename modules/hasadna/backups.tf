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
      export KOPIA_PASSWORD=${random_password.kopia_backups_password.result}
      export AWS_ACCESS_KEY_ID=${aws_iam_access_key.kopia_backups.id}
      export AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.kopia_backups.secret}
      docker run --rm \
        -e KOPIA_PASSWORD \
        -e AWS_ACCESS_KEY_ID \
        -e AWS_SECRET_ACCESS_KEY \
        kopia/kopia:${local.kopia_version} \
        repository create s3 \
          --bucket=${aws_s3_bucket.hasadna_kopia_backups.bucket} \
          --region=${aws_s3_bucket.hasadna_kopia_backups.region}
    EOT
  }
  provisioner "local-exec" {
    command = self.triggers.command
  }
}
