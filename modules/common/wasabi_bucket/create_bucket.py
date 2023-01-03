import os
import sys
import boto3
from textwrap import dedent


def main(name, region='eu-west-2', public_read_only=False):
    public_read_only = public_read_only == 'true'
    print(f"Creating bucket '{name}' in region {region} public_read_only={public_read_only}")
    s3 = boto3.client(
        's3',
        endpoint_url=f'https://s3.{region}.wasabisys.com',
        aws_access_key_id=os.environ['WASABI_ACCESS_KEY_ID'],
        aws_secret_access_key=os.environ['WASABI_SECRET_ACCESS_KEY'],
    )
    s3.create_bucket(Bucket=name)
    if public_read_only:
        s3.put_bucket_policy(
            Bucket=name,
            Policy=dedent('''
            {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Sid": "AllowPublicRead", 
                        "Effect": "Allow", 
                        "Principal": {
                            "AWS": "*"
                        },
                        "Action": [ "s3:GetObject", "s3:ListBucket" ],
                        "Resource": [
                            "arn:aws:s3:::__BUCKET_NAME__",
                            "arn:aws:s3:::__BUCKET_NAME__/*"
                        ]
                    }
                ]
            }
            '''.replace('__BUCKET_NAME__', name))
        )
    print("OK")


if __name__ == '__main__':
    main(*sys.argv[1:])
