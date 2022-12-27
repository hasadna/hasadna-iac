resource "aws_s3_bucket" "hasadna_kamatera_cluster_backups" {
    bucket = "hasadna-kamatera-cluster-backups"
    provider = aws.us_east_1
    tags = {
        Description = "Backups of all data from Hasadna cluster using Restic"
    }
}

resource "aws_s3_bucket" "hasadna_discourse_backup" {
    bucket = "hasadna-discourse-backup"
    tags = {
        Description = "Backups from Hasadna forum only last 5 weekly backups are kept"
    }
}

resource "aws_s3_bucket" "israeltiles" {
    bucket = "israeltiles"
    # We are not sure what this bucket is for, we blocked public access and waiting to see if anyone complains (Dec 27, 2022)
    # The bucket is already archived in glacier, so if no one complains we can delete it
}


resource "aws_s3_bucket" "hasadna_archive_cold_storage" {
    bucket = "hasadna-archive-cold-storage"
    provider = aws.eu_west_3
    tags = {
        Description = "Archive of data which is not in use using Glacier pay attention to the costs"
    }
}
