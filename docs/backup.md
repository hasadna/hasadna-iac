# Backups

## Legacy Restic Backups

These are old backups that are no longer updated, but you might want to restore something from them.

You can SSH to hasadna-nfs1 and run `./restic.sh --help` to interact with restic. By default it's connected
to the storage backup, but there are other repos too, see the names in AWS S3 `hasadna-kamatera-cluster-backups` bucket
To connect to another repo set REPO env var, for example: `REPO=etcd`
