data "vault_kv_secret_v2" "aws_email_senders" {
  mount = "/kv"
  name  = "Projects/iac/aws_email_senders"
}

locals {
  aws_email_senders = {
    for sender, email in nonsensitive(data.vault_kv_secret_v2.aws_email_senders.data) : nonsensitive(sender) => nonsensitive(email)
  }
  aws_email_sender_domains = toset([
    for email in values(local.aws_email_senders) : split("@", email)[1]
  ])
}

locals {
  aws_email_senders_smtp_host = "email-smtp.us-east-1.amazonaws.com"
  aws_email_senders_smtp_port = 587
  aws_email_sender_domain_dkim_records = merge([
    for domain in local.aws_email_sender_domains : {
      for index in range(3) : "${domain}-${index}" => {
        domain = domain
        token  = aws_ses_domain_dkim.aws_email_sender_domains[domain].dkim_tokens[index]
      }
    }
  ]...)
}

data "cloudflare_zone" "aws_email_sender_domains" {
  for_each = local.aws_email_sender_domains

  filter = {
    name = each.value
  }
}

resource "aws_ses_domain_identity" "aws_email_sender_domains" {
  for_each = local.aws_email_sender_domains

  domain   = each.value
  provider = aws.us_east_1
}

resource "aws_ses_domain_dkim" "aws_email_sender_domains" {
  for_each = local.aws_email_sender_domains

  domain   = aws_ses_domain_identity.aws_email_sender_domains[each.key].domain
  provider = aws.us_east_1
}

resource "cloudflare_dns_record" "aws_email_sender_domain_verification" {
  for_each = local.aws_email_sender_domains

  zone_id = data.cloudflare_zone.aws_email_sender_domains[each.key].zone_id
  name    = "_amazonses.${each.key}"
  content = aws_ses_domain_identity.aws_email_sender_domains[each.key].verification_token
  type    = "TXT"
  ttl     = 1
}

resource "cloudflare_dns_record" "aws_email_sender_domain_dkim" {
  for_each = local.aws_email_sender_domain_dkim_records

  zone_id = data.cloudflare_zone.aws_email_sender_domains[each.value.domain].zone_id
  name    = "${each.value.token}._domainkey.${each.value.domain}"
  content = "${each.value.token}.dkim.amazonses.com"
  type    = "CNAME"
  ttl     = 1
}

resource "aws_ses_domain_identity_verification" "aws_email_sender_domains" {
  for_each = local.aws_email_sender_domains

  domain   = aws_ses_domain_identity.aws_email_sender_domains[each.key].id
  provider = aws.us_east_1

  depends_on = [cloudflare_dns_record.aws_email_sender_domain_verification]
}

resource "aws_iam_user" "aws_email_senders" {
  for_each = local.aws_email_senders

  name = "hasadna-iac-email-sender-${each.key}"
}

resource "aws_iam_access_key" "aws_email_senders" {
  for_each = local.aws_email_senders

  user = aws_iam_user.aws_email_senders[each.key].name
}

resource "aws_iam_user_policy" "aws_email_senders" {
  for_each = local.aws_email_senders

  name = "hasadna-iac-email-sender-${each.key}-ses-send"
  user = aws_iam_user.aws_email_senders[each.key].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = aws_ses_domain_identity.aws_email_sender_domains[split("@", each.value)[1]].arn
        Condition = {
          StringEquals = {
            "ses:FromAddress" = each.value
          }
        }
      }
    ]
  })
}

resource "vault_kv_secret_v2" "aws_email_sender_smtp_credentials" {
  data_json = jsonencode({
    for sender, email in local.aws_email_senders : sender => {
      allowed_from_email     = email
      smtp_host              = local.aws_email_senders_smtp_host
      smtp_port              = local.aws_email_senders_smtp_port
      smtp_username          = aws_iam_access_key.aws_email_senders[sender].id
      smtp_password          = aws_iam_access_key.aws_email_senders[sender].ses_smtp_password_v4
    }
  })
  mount = "/kv"
  name  = "Projects/iac/aws_email_sender_smtp_credentials"
}
