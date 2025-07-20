# TODO: add the backup script to the DB server here
# the backup runs as a cronjob from postgres user
# you can see it by SSH to the DB server and run:
#     crontab -u postgres -l
#
# 37 1 * * * bash /var/lib/postgresql/stride-backup.sh 2>&1 >> /var/lib/postgresql/stride-backup.log
#
# copy stride_db_backup.sh to the server at /var/lib/postgresql/stride-backup.sh


resource "statuscake_heartbeat_check" "stride_db_backup" {
  name = "stride-db-backup"
  period = 60 * 60 * 24 * 2  # every 2 days
  contact_groups = ["35660"]  # DevOps contact group
}

output "stride_db_backup_check_url" {
  value = statuscake_heartbeat_check.stride_db_backup.check_url
}
