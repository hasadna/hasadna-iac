resource "aws_s3_bucket" "hasadna_logs" {
    bucket = "hasadna-logs"
}

resource "aws_s3_bucket" "hasadna_kamatera_cluster_backups" {
    bucket = "hasadna-kamatera-cluster-backups"
    provider = aws.us_east_1
}

resource "aws_s3_bucket" "hasadna_discourse_backup" {
    bucket = "hasadna-discourse-backup"
}

resource "aws_s3_bucket" "hasadna_design" {
    bucket = "hasadna-design"
}

resource "aws_s3_bucket" "opencommunity_db_backup" {
    bucket = "opencommunity-db-backup"
    provider = aws.us_east_1
}

resource "aws_s3_bucket" "israeltiles" {
    bucket = "israeltiles"
}

resource "aws_s3_bucket" "kikar_dev" {
    bucket = "kikar-dev"
}

resource "aws_s3_bucket" "oway_org_il" {
    bucket = "oway.org.il"
}

resource "aws_s3_bucket" "opentrain_db_backup" {
    bucket = "opentrain-db-backup"
}
