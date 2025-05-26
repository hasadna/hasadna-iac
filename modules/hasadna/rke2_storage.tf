locals {
  rke2_storage = {
    # namespace = {
    #   pvc_name = {
    monitoring = {
      alertmanager = {
        node = "worker1"
        create_pvc = false
      }
      grafana = {
        node = "worker1"
      }
      prometheus = {
        node = "worker1"
        create_pvc = false
      }
    }
    vault = {
      vault = {
        node = "worker1"
      }
    }
    default = {
      terraformstatedb = {
        node = "worker1"
      }
      labelstudio = {
        pvc_only_ref_nfs_path = "/nfs-client-provisioner/default-hasadna-ls-pvc-pvc-2bddbca1-c952-42a6-86c8-13a702303479"
      }
      labelstudio-postgres  = {
        pvc_only_ref_nfs_path = "/export/nfs-client-provisioner/default-data-hasadna-postgresql-0-pvc-ece037c0-79d8-4e15-ad3a-45a8bc05a962"
      }
    }
    oknesset = {
      data = {
        node = "worker1"
        create_pv = false
        # rsync -az --delete --checksum 172.16.0.9:/export/mnt/sdb3/srv/default/oknesset/pipelines/data/oknesset-nfs-gcepd/ /mnt/storage/oknesset/data/
        # done
      }
      pipelines = {
        pvc_only_ref_existing = "data"
      }
      nginx = {
        pvc_only_ref_existing = "data"
      }
      airflow-scheduler = {
        pvc_only_ref_existing = "data"
      }
    }
    budgetkey = {
      postgres = {
        node = "worker1"
        # rsync -az --delete --checksum 172.16.0.9:/export/budgetkey/postgres/ /mnt/storage/budgetkey/postgres/
        # done
      }
      pipelines = {
        node = "worker2"
        # rsync -az --delete --checksum 172.16.0.9:/export/budgetkey/pipelines/ /mnt/storage/budgetkey/pipelines/
        # done
      }
      elasticsearch = {
        node = "worker2"
        # rsync -az --delete --checksum 172.16.0.9:/export/budgetkey/elasticsearch8/ /mnt/storage/budgetkey/elasticsearch/
        # done
      }
    }
    odata = {
      datastore-db = {
        node = "worker2"
        # rsync -az --delete --checksum 172.16.0.9:/export/odata/datastore-db-postgresql-data/ /mnt/storage/odata/datastore-db/
        # done
      }
      data = {
        node = "worker2"
        create_pv = false
        # rsync -az --delete --checksum 172.16.0.9:/export/odata/ckan/ /mnt/storage/odata/data/
        # done
      }
      nginx = {
        pvc_only_ref_existing = "data"
      }
      pipelines = {
        pvc_only_ref_existing = "data"
      }
      ckan = {
        pvc_only_ref_existing = "data"
      }
      ckan-jobs = {
        pvc_only_ref_existing = "data"
      }
    }
    openbus = {
      gtfs = {
        node = "worker2"
        create_pv = false
        # rsync -az --delete --checksum 172.16.0.9:/export/openbus/gtfs/ /mnt/storage/openbus/gtfs/
        # done
      }
      gtfs-nginx = {
        pvc_only_ref_existing = "gtfs"
      }
      airflow-scheduler = {
        pvc_only_ref_existing = "gtfs"
      }
    }
    srm-etl-production = {
      data = {
        node = "worker1"
        create_pv = false
        # rsync -az --delete --checksum 172.16.0.9:/export/srm/etl-production/ /mnt/storage/srm-etl-production/data/
        # done
      }
      minio = {
        pvc_only_ref_existing = "data"
        pv_subpath = "/minio"
      }
      db = {
        pvc_only_ref_existing = "data"
        pv_subpath = "/db"
      }
      elasticsearch = {
        pvc_only_ref_existing = "data"
        pv_subpath = "/elasticsearch"
      }
    }
    srm-etl-staging = {
      data = {
        node = "worker2"
        create_pv = false
        # rsync -az --delete --checksum 172.16.0.9:/export/srm/etl-staging/ /mnt/storage/srm-etl-staging/data/
        # done
      }
      minio = {
        pvc_only_ref_existing = "data"
        pv_subpath = "/minio"
      }
      db = {
        pvc_only_ref_existing = "data"
        pv_subpath = "/db"
      }
      elasticsearch = {
        pvc_only_ref_existing = "data"
        pv_subpath = "/elasticsearch"
      }
    }
    forum = {
      discourse = {
        pvc_only_ref_nfs_path = "/nfs-client-provisioner/forum-forum-discourse-pvc-6965541d-4753-42ba-81bf-9d3184a8272f"
      }
      postgres = {
        pvc_only_ref_nfs_path = "/nfs-client-provisioner/forum-data-forum-postgresql-0-pvc-a8c93ad1-2872-4528-a50f-6d7393bcd36d"
      }
      redis = {
        pvc_only_ref_nfs_path = "/nfs-client-provisioner/forum-redis-data-forum-redis-master-0-pvc-f9279b40-54d0-4651-a363-b6788d98c772"
      }
    }
  }
  rke2_storage_flat = {
    for s in flatten(
      [
        for namespace, storages in local.rke2_storage: [
          for name, storage in storages : {
            namespace = namespace
            name = name
            node = lookup(storage, "node", false)
            create_pv = lookup(storage, "create_pv", true)
            create_pvc = lookup(storage, "create_pvc", true)
            pvc_only_ref_existing = lookup(storage, "pvc_only_ref_existing", false)
            pv_subpath = lookup(storage, "pv_subpath", "")
            counter = lookup(storage, "counter", 0)
            pvc_only_ref_nfs_path = lookup(storage, "pvc_only_ref_nfs_path", false)
          }
        ]
      ]
    ) : "${s.namespace}_${s.name}" => s
  }
}

resource "null_resource" "rke2_mount_workers_storage" {
  for_each = {
    for name, server in local.rke2_servers : name => server if server.type == "worker" && server.storage != false
  }
  depends_on = [null_resource.rke2_install_workers]
  triggers = {
    counter = 1
    command = <<-EOF
      ssh hasadna-rke2-${each.key} "
        if ! [ -d /mnt/storage ]; then
          mkdir /mnt/storage &&\
          mkfs.ext4 ${each.value.storage} &&\
          echo ${each.value.storage} /mnt/storage ext4 defaults 0 2 >> /etc/fstab &&\
          systemctl daemon-reload &&\
          mount -a
        fi
      "
    EOF
  }
  provisioner "local-exec" {
    command = self.triggers.command
  }
}

resource "null_resource" "rke2_storage" {
  for_each = {for k, v in local.rke2_storage_flat : k => v if v.node != false}
  depends_on = [null_resource.rke2_mount_workers_storage]
  triggers = {
    counter = each.value.counter
    command = <<-EOF
      ssh hasadna-rke2-${each.value.node} "mkdir -p /mnt/storage/${each.value.namespace}/${each.value.name}"
    EOF
  }
  provisioner "local-exec" {
    command = self.triggers.command
  }
}

resource "null_resource" "rke2_ensure_storage_namespaces" {
  for_each = toset([for namespace, storages in local.rke2_storage : namespace])
  depends_on = [null_resource.rke2_kubeconfig]
  triggers = {
    command = <<-EOF
      export KUBECONFIG=${var.rke2_kubeconfig_path}
      if ! kubectl get namespace ${each.key} >/dev/null 2>&1; then
        echo "creating namespace ${each.key}"
        kubectl create namespace ${each.key}
      else
        echo "Namespace ${each.key} already exists"
      fi
    EOF
  }
  provisioner "local-exec" {
    command = self.triggers.command
  }
}

resource "kubernetes_storage_class" "rke2_local_storage" {
  depends_on = [null_resource.rke2_kubeconfig]
  provider = kubernetes.rke2
  metadata {
    name = "local-storage"
  }
  storage_provisioner  = "kubernetes.io/no-provisioner"
  volume_binding_mode  = "WaitForFirstConsumer"
  reclaim_policy       = "Retain"
}

resource "kubernetes_persistent_volume" "rke2_storage" {
  for_each = {for k, v in local.rke2_storage_flat : k => v if v.create_pv && v.pvc_only_ref_nfs_path == false}
  depends_on = [null_resource.rke2_kubeconfig, null_resource.rke2_storage]
  provider = kubernetes.rke2
  metadata {
    name = "${each.value.namespace}-${each.value.name}"
    labels = {
      "app.kubernetes.io/name" = "${each.value.namespace}-${each.value.name}"
      "app.kubernetes.io/managed-by" = "terraform-hasadna-rke2-storage"
    }
  }
  spec {
    storage_class_name = kubernetes_storage_class.rke2_local_storage.metadata[0].name
    capacity = {
      storage = "500Gi"
    }
    access_modes = ["ReadWriteMany"]
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values = [each.value.pvc_only_ref_existing == false ? each.value.node : local.rke2_storage[each.value.namespace][each.value.pvc_only_ref_existing].node]
          }
        }
      }
    }
    persistent_volume_source {
      local {
        path = "/mnt/storage/${each.value.namespace}/${each.value.pvc_only_ref_existing == false ? each.value.name : each.value.pvc_only_ref_existing}${each.value.pv_subpath}"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "rke2_storage_ref_nfs" {
  for_each = {for k, v in local.rke2_storage_flat : k => v if v.create_pv && v.pvc_only_ref_nfs_path != false}
  depends_on = [null_resource.rke2_kubeconfig, null_resource.rke2_storage]
  provider = kubernetes.rke2
  metadata {
    name = "${each.value.namespace}-${each.value.name}"
    labels = {
      "app.kubernetes.io/name" = "${each.value.namespace}-${each.value.name}"
      "app.kubernetes.io/managed-by" = "terraform-hasadna-rke2-storage"
    }
  }
  spec {
    storage_class_name = kubernetes_storage_class.rke2_local_storage.metadata[0].name
    capacity = {
      storage = "500Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      nfs {
        path   = each.value.pvc_only_ref_nfs_path
        server = kamatera_server.hasadna_nfs2.private_ips[0]
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "rke2_storage" {
  for_each = {for k, v in local.rke2_storage_flat : k => v if v.create_pvc && v.create_pv}
  depends_on = [kubernetes_persistent_volume.rke2_storage, null_resource.rke2_ensure_storage_namespaces, kubernetes_persistent_volume.rke2_storage_ref_nfs]
  provider = kubernetes.rke2
  wait_until_bound = false
  metadata {
    name = each.value.name
    namespace = each.value.namespace
    labels = {
      "app.kubernetes.io/name" = "${each.value.namespace}-${each.value.name}"
      "app.kubernetes.io/managed-by" = "terraform-hasadna-rke2-storage"
    }
  }
  spec {
    storage_class_name = kubernetes_storage_class.rke2_local_storage.metadata[0].name
    resources {
      requests = {
        storage = "500Gi"
      }
    }
    access_modes = ["ReadWriteMany"]
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "${each.value.namespace}-${each.value.name}"
        "app.kubernetes.io/managed-by" = "terraform-hasadna-rke2-storage"
      }
    }
  }
}
