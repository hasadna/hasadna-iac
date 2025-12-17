#!/usr/bin/env bash

set -euo pipefail

cd /var/lib/postgresql
if [ -f ./stride_db.pid ]; then
  PID=$(cat ./stride_db.pid)
  if ps -p $PID > /dev/null; then
    echo stride_db backup process already running with PID $PID, will not run
    exit 0
  else
    echo stale stride_db.pid file found, removing
    rm ./stride_db.pid
  fi
fi
echo $$ > ./stride_db.pid
echo `date +"%Y-%m-%d %H:%M"` creating stride_db backup
if [ -f ./stride_db.sql.zst ]; then
  echo previous backup file found, removing
  rm ./stride_db.sql.zst
fi
pg_dump -n public --no-privileges | zstd -19 -o ./stride_db.sql.zst
du -h ./stride_db.sql.zst
. /var/lib/postgresql/stride-backup.env
echo `date +"%Y-%m-%d %H:%M"` copying backup to S3
/usr/local/bin/aws s3 cp --quiet ./stride_db.sql.zst s3://${BUCKET_NAME}/stride_db.sql.zst
rm ./stride_db.sql.zst
echo `date +"%Y-%m-%d %H:%M"` sending heartbeat to StatusCake
curl "$STRIDE_DB_BACKUP_CHECK_URL"
echo `date +"%Y-%m-%d %H:%M"` heartbeat sent to StatusCake
rm ./stride_db.pid
echo `date +"%Y-%m-%d %H:%M"` Great Success!
exit 0
