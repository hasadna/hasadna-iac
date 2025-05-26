# Storage

We have 2 types of storage for the Kubernetes cluster:

* NFS - Stored on a central NFS server, should be used for most workloads
* Local - Stored in dedicated disk on the worker nodes themselves, only for critical or large storage needs

## NFS

* SSH to the nfs server and create required directory structure under `/export/`
* use the NFS from hasadna-k8s - see other workloads that use NFS for examples 

## Local

* Storage paths are set in `modules/hasadna/rke2_storage.tf` - see the map at the top of the file
* Nodes eligible for storage are defined in `modules/hasadna/rke2.tf` - they need to have 2 disks and set storage to the 2nd storage device

## Advanced

### Rsyncing from nfs to local

Run on target worker node:

```
cat ~/.ssh/id_rsa.pub
# copy the output to the NFS server's authorized_keys file
# rsync over ssh from nfs server to local (important to use the trailing slash on the paths)
rsync -az --delete --checksum 172.16.0.9:/export/SOURCE_PATH/ /mnt/storage/TARGET_PATH/
```
