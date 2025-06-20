# Storage

We have 2 types of storage:

* Rook Ceph - Uses Ceph cluster deployed on the Kubernetes cluster, recommended for most workloads
* Local - Stored in dedicated disk on the worker nodes themselves, only for critical or large storage needs

Storage is defined in `modules/hasadna/rke2_storage.tf` at the top of the file under the `rke2_storage` local.
See the comments there for a description of the configuration values.

If you add or change values, it will create / modify the storage after terraform apply.
If you delete items, it will not delete the storage, storage must be deleted manually.

The storage configuration is also used for backup which is handled by a cronjob in each server.
Backups are stored in AWS S3 using Kopia. It stores snapshots with retention periods, see `modules/hasadna/rke2_backup.tf` for more details.

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

## Moving data to Rook storage

Example:

```
#                         NAMESPACE  SOURCE_TYPE  SOURCE_PATH      TARGET_PVC
bin/rke2_storage_rsync.sh argo       nfs          /argo/postgres   postgres2
```

## Disk Resize

* Change the disk size in Kamatera Console (without reboot)
* Update the size in rke2.tf to match
* Run the following on the server to resize the partition:

```
STORAGE_DEVICE=sdb
PARTITION_DEVICE=/dev/sdb1
echo 1 > /sys/class/block/$STORAGE_DEVICE/device/rescan
sgdisk -e /dev/$STORAGE_DEVICE
sgdisk -d 1 -n 1:0:0 -t 1:8300 -c 1:"Linux filesystem" /dev/$STORAGE_DEVICE
partprobe /dev/$STORAGE_DEVICE
resize2fs $PARTITION_DEVICE
```
