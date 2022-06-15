resource "aws_s3_bucket_policy" "hasadna_kamatera_cluster_backups" {
    bucket = aws_s3_bucket.hasadna_kamatera_cluster_backups.id
    policy = "{\"Version\":\"2012-10-17\",\"Id\":\"Policy1580027936722\",\"Statement\":[{\"Sid\":\"Stmt1580027931015\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"arn:aws:iam::518193018304:user/hasadna-kamatera-backups\"},\"Action\":\"s3:*\",\"Resource\":\"arn:aws:s3:::hasadna-kamatera-cluster-backups\"}]}"
    provider = aws.us_east_1
}

resource "aws_s3_bucket_policy" "israelites" {
    bucket = aws_s3_bucket.israeltiles.id
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"PublicReadForGetBucketObjects\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::israeltiles/*\"}]}"
}
