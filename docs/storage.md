# Storage

We have 2 types of storage for the Kubernetes cluster:

* Local - Stored in dedicated disk on the worker nodes themselves
* NFS - Stored on a central NFS server

## Local

* Nodes elgible for storage are defined in `modules/hasadna/rke2.tf` - they need to have 2 disks and set storage to the 2nd storage device
* Storage paths are set in `modules/hasadna/rke2_storage.tf` - see the map at the top of the file

## NFS

* TODO

## Advanced

### Rsyncing from nfs to local

```
mkdir -p /mnt/nfs
mount -t nfs4 nfs_private_ip:/ /mnt/nfs
rsync -a /mnt/nfs/path/ /mnt/storage/namespace/name/
```
