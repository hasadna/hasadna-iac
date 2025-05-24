locals {
  rke2_storage = {
    monitoring = {
      alertmanager = {
        node = "worker1"
      }
      grafana = {
        node = "worker1"
      }
      prometheus = {
        node = "worker1"
      }
    }
    infra = {
      vault = {
        node = "worker1"
        rsync_from_nfs_path = "/hasadna/vault"
      }
    }
  }
}

resource "null_resource" "rke2_storage" {
  for_each = {
    for s in flatten(
      [
        for group_name, storages in local.rke2_storage: [
          for name, storage in storages : {
            group = group_name
            name = name
            node = storage.node
            rsync_from_nfs_path = lookup(storage, "rsync_from_nfs_path", "")
          }
        ]
      ]
    ) : "${s.group}_${s.name}" => s
  }
  triggers = {
    counter = lookup(each.value, "counter", 0)
    command = <<-EOF
      ssh hasadna-rke2-${each.value.node} "mkdir -p /srv/storage/${each.value.group}/${each.value.name}" &&\
      if [ "${each.value.rsync_from_nfs_path}" != "" ]; then
        echo rsync from nfs path: ${each.value.rsync_from_nfs_path} &&\
        ssh hasadna-rke2-${each.value.node} "
          if ! [ -d /mnt/nfs ]; then mkdir -p /mnt/nfs; fi &&\
          if ! which mount.nfs4; then apt update && apt install -y nfs-common; fi &&\
          mount -t nfs4 ${kamatera_server.hasadna_nfs2.private_ips[0]}:/ /mnt/nfs &&\
          rsync -a --delete /mnt/nfs${each.value.rsync_from_nfs_path}/ /srv/storage/${each.value.group}/${each.value.name}/
        "
      fi
    EOF
  }
  provisioner "local-exec" {
    command = self.triggers.command
  }
}
