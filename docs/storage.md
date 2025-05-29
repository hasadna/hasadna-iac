# Storage

We have 2 types of storage:

* NFS - Stored on a central NFS server, should be used for most workloads
* Local - Stored in dedicated disk on the worker nodes themselves, only for critical or large storage needs

Storage is defined in `modules/hasadna/rke2_storage.tf` at the top of the file under the `rke2_storage` local.
See the comments there for a description of the configuration values.

If you add or change values, it will create / modify the storage after terraform apply.
If you delete items, it will not delete the storage, storage must be deleted manually.

The storage configuration is also used for backup which is handled by a cronjob in each server.
Backups are stored in AWS S3 using Koptic. It stores snapshots with retention periods, see `modules/hasadna/rke2_backup.tf` for more details.

## Using the data in Kubernetes Workloads

The storage configurations by default create a `PersistentVolume` and a `PersistentVolumeClaim` for each storage item in the relevant namespace.

## Moving data between servers

If you want to move data from one storage server to another, you can use `rsync` over SSH

Run something like this on the target server:

```
cat ~/.ssh/id_rsa.pub
# copy the output to the source server's authorized_keys file
# rsync over ssh from source server to the current target server (important to use the trailing slash on the paths)
# following example syncs from nfs server
rsync -az --delete --checksum 172.16.0.9:/export/SOURCE_PATH/ /mnt/storage/TARGET_PATH/
```
