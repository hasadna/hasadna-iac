resource "aws_s3_bucket" "anyway" {
    bucket = "anyway"
}

resource "aws_s3_bucket" "anyway_full_db_dumps" {
    bucket = "anyway-full-db-dumps"
}

resource "aws_s3_bucket" "anyway_co_il" {
    bucket = "anyway.co.il"
}

resource "aws_s3_bucket" "anyway_cbs" {
    bucket = "anyway-cbs"
}

resource "aws_s3_bucket" "anyway_partial_db_dumps" {
    bucket = "anyway-partial-db-dumps"
}
