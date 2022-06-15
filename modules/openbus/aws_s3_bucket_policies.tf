resource "aws_s3_bucket_policy" "openbus_stride_public" {
    bucket = aws_s3_bucket.openbus_stride_public.id
    policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Sid\":\"Statement1\",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":[\"s3:GetObject\",\"s3:ListBucket\"],\"Resource\":[\"arn:aws:s3:::openbus-stride-public/*\",\"arn:aws:s3:::openbus-stride-public\"]}]}"
}

resource "aws_s3_bucket_policy" "s3_obus_hasadna_org_il" {
    bucket = aws_s3_bucket.s3_obus_hasadna_org_il.id
    policy = "{\"Version\":\"2012-10-17\",\"Id\":\"Policy1530550905692\",\"Statement\":[{\"Sid\":\"Stmt1530550887240\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"*\"},\"Action\":\"s3:GetObject\",\"Resource\":\"arn:aws:s3:::s3.obus.hasadna.org.il/*\"}]}"
}
