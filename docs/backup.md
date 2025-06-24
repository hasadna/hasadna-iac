# Backups

Backups are done using Kopia and stored in AWS S3.

You can interact with the backups by either:

* execing into `rook-ceph-toolbox` deployment in the `rook-ceph` namespace and running `kopia` commands
* SSHing into one of the nodes hat have local storage and running `./kopia_connect.sh` then `kopia` commands

## Storage

* Rook Ceph backup is done by daily argo cron workflow `hasadna-k8s-pvc-backup-all-daily` defined in `hasadna-k8s/apps/storage` - it backs up all PVCs.
  * You can initiate a backup manually for a specific PVC by running argo workflow template `hasadna-k8s-pvc-backup`
  * Kopia sources are named `ceph@NAMESPACE:PVC_NAME`
* Local backup is done daily by cronjob on each node, defined in `modules/hasadna/backup.tf`.
  * You can initiate a backup manually by SSHing into the node and running `./kopia_connect.sh && kopia snapshot create /mnt/storage/PATH`
  * Kopia sources are named `root@hasadna-rke2-NODE_NAME:/mnt/storage/PATH`

StatusCake heartbeat is sent after each backup, if heartbeat was not received in 2 days, it will send an alert.

## ETCD Snapshots

RKE2 Creates regular snapshots of the etcd database to `/var/lib/rancher/rke2/server/db/snapshots` this is backed up by the local backup cronjob
and availalbe in the local storage backups in Kopia.
