resource "aws_s3_bucket" "oknesset_devdb" {
    bucket = "oknesset-devdb"
    provider = aws.us_east_1
}

resource "aws_s3_bucket" "mkmap_log" {
    bucket = "mkmap-log"
}

resource "aws_s3_bucket" "ok_qa_media" {
    bucket = "ok-qa-media"
}

resource "aws_s3_bucket" "oknesset_db_backup" {
    bucket = "oknesset-db-backup"
}

resource "aws_s3_bucket" "knesset_data" {
    bucket = "knesset-data"
    provider = aws.us_east_1
}

resource "aws_s3_bucket" "bchirometer_oknesset_rg" {
    bucket = "bchirometer.oknesset.org"
}

resource "aws_s3_bucket" "mkmap_oknesset_org" {
    bucket = "mkmap.oknesset.org"
}

resource "aws_s3_bucket" "oknesset_media" {
    bucket = "oknesset-media"
}

resource "aws_s3_bucket" "bchirometer_log" {
    bucket = "bchirometer-log"
}

resource "aws_s3_bucket" "oknesset_virtualbox" {
    bucket = "oknesset-virtualbox"
}
