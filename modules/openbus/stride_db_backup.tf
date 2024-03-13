# TODO: add the backup script to the DB server here
# the backup runs as a cronjob from postgres user
# you can see it by SSH to the DB server and run:
#     crontab -u postgres -l
#
# 37 1 * * * bash /var/lib/postgresql/stride-backup.sh 2>&1 >> /var/lib/postgresql/stride-backup.log
#
#cd /var/lib/postgresql &&\
#echo `date +"%Y-%m-%d %H:%M"` creating stride_db backup &&\
#pg_dump -n public --no-privileges | gzip -c > ./stride_db.sql.gz &&\
#du -h ./stride_db.sql.gz &&\
#. /var/lib/postgresql/stride-backup.env &&\
#echo `date +"%Y-%m-%d %H:%M"` copying backup to S3 &&\
#/usr/local/bin/aws s3 cp --quiet ./stride_db.sql.gz s3://${BUCKET_NAME}/stride_db.sql.gz &&\
#rm ./stride_db.sql.gz &&\
#echo `date +"%Y-%m-%d %H:%M"` Great Success!
