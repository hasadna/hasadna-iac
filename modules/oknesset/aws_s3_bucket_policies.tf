resource "aws_s3_bucket_policy" "mkmap_oknesset_org" {
    bucket = aws_s3_bucket.mkmap_oknesset_org.id
    policy = "{\"Version\":\"2008-10-17\",\"Statement\":[{\"Sid\":\"AddPerm\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"*\"},\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::mkmap.oknesset.org/*\"}]}"
}
