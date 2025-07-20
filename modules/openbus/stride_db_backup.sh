#!/usr/bin/env bash

set -euo pipefail

cd /var/lib/postgresql
echo `date +"%Y-%m-%d %H:%M"` creating stride_db backup
pg_dump -n public --no-privileges | zstd -19 -o ./stride_db.sql.zst
du -h ./stride_db.sql.zst
. /var/lib/postgresql/stride-backup.env
echo `date +"%Y-%m-%d %H:%M"` copying backup to S3
/usr/local/bin/aws s3 cp --quiet ./stride_db.sql.zst s3://${BUCKET_NAME}/stride_db.sql.zst
rm ./stride_db.sql.zst
echo `date +"%Y-%m-%d %H:%M"` sending heartbeat to StatusCake
curl "$STRIDE_DB_BACKUP_CHECK_URL"
echo `date +"%Y-%m-%d %H:%M"` heartbeat sent to StatusCake
echo `date +"%Y-%m-%d %H:%M"` Great Success!
