locals {
  rke2_storage = {
    # namespace = {
    #   name = {
    #
    #     node: create local storage on this node
    #       if set to "nfs" - it will use the central NFS server
    #       if set to "rook" - it will use the Rook Ceph cluster
    #           by default it will allow single pod to use the storage, to share storage with multiple pods, set rook_shared: true
    #           you must set rook_storage_request_gi to specify the requested storage size
    #
    #     path: if set, will use this as the suffix for the storage path, otherwise will use the name
    #     namespace_path: if set, will use this as the prefix for the storage path, otherwise will use the namespace name
    #     full_path: if set, will use this as the full path from the server root, ignoring the name and namespace_path
    #
    #     create_pv: default true, if false, will not create a Persistent Volume for this storage (and also will not create a Persistent Volume Claim)
    #                 ignored for rook, because it must provision them to allocate the storage
    #     create_pvc: default true, if false, will not create a Persistent Volume Claim for this storage
    #                 ignored for rook, because it must provision them to allocate the storage
    #
    #     ref_existing: special mode, if set, the value needs to match another storage item from the same namespace
    #                   this is used for cases where the same storage is shared by multiple workloads
    #                   so each one can get it's own PV/PVC but all reference the same storage location
    #
    #     pv_subpath: if set, will suffix this subpath to the PV storage path, mostly useful in combination with ref_existing
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
    argo = {
      postgres2 = {
        node = "rook"
        rook_storage_request_gi = 10
      }
    }
    default = {
      terraformstatedb = {
        node = "worker1"
      }
      labelstudio = {
        node = "nfs"
        namespace_path = "nfs-client-provisioner"
        path = "default-hasadna-ls-pvc-pvc-2bddbca1-c952-42a6-86c8-13a702303479"
      }
      labelstudio2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      labelstudio-postgres  = {
        node = "nfs"
        namespace_path = "export/nfs-client-provisioner"
        path = "default-data-hasadna-postgresql-0-pvc-ece037c0-79d8-4e15-ad3a-45a8bc05a962"
      }
      labelstudio-postgres2  = {
        node = "rook"
        rook_storage_request_gi = 1
      }
      rke2-snapshots = {
        node = "controlplane1"
        create_pv = false
        full_path = "/var/lib/rancher/rke2/server/db/snapshots"
      }
    }
    oknesset = {
      data = {
        node = "worker1"
        create_pv = false
      }
      pipelines = {
        ref_existing = "data"
      }
      nginx = {
        ref_existing = "data"
      }
      airflow-scheduler = {
        ref_existing = "data"
      }
      airflow-db = {
        node = "nfs"
        create_pv = false
      }
      airflow-db2 = {
        node = "rook"
        rook_storage_request_gi = 1
      }
      airflow-home = {
        node = "nfs"
        create_pv = false
      }
      airflow-home2 = {
        node = "rook"
        rook_shared = true
        rook_storage_request_gi = 10
      }
      site-db = {
        node = "nfs"
        create_pv = false
      }
      site-db2 = {
        node = "rook"
        rook_storage_request_gi = 1
      }
    }
    budgetkey = {
      postgres = {
        node = "worker1"
      }
      pipelines = {
        node = "worker2"
      }
      elasticsearch = {
        node = "worker2"
      }
      api = {
        node = "nfs"
        create_pv = false
      }
      api2 = {
        node = "rook"
        rook_storage_request_gi = 2
      }
      data-input-db = {
        node = "nfs"
        create_pv = false
      }
      data-input-db2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      elasticsearch-certs = {
        node = "nfs"
        create_pv = false
      }
      elasticsearch-certs2 = {
        node = "rook"
        rook_shared = true
        rook_storage_request_gi = 1
      }
      kibana-data = {
        node = "nfs"
        create_pv = false
      }
      kibana-data2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
    }
    odata = {
      ckan = {
        node = "worker2"
        # rsync -az --delete --checksum 172.16.0.9:/export/odata/ckan/ /mnt/storage/odata/ckan/
      }
      pipelines = {
        node = "nfs"
        create_pv = false
      }
      pipelines2 = {
        node = "rook"
        rook_shared = true
        rook_storage_request_gi = 1
      }
      ckan-jobs-db = {
        node = "nfs"
        create_pv = false
      }
      ckan-jobs-db2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      datastore-db = {
        node = "worker2"
        # rsync -az --delete --checksum 172.16.0.9:/export/odata/datastore-db-postgresql-data/ /mnt/storage/odata/datastore-db/
      }
      postgresql-data = {
        node = "nfs"
        create_pv = false
      }
      postgresql-data2 = {
        node = "rook"
        rook_storage_request_gi = 10
      }
      pipelines-redis = {
        node = "nfs"
        create_pv = false
      }
      pipelines-redis2 = {
        node = "rook"
        rook_storage_request_gi = 1
      }
      solr = {
        node = "nfs"
        create_pv = false
      }
      solr2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
    }
    openbus = {
      gtfs = {
        node = "worker2"
        create_pv = false
        # rsync -az --delete --checksum 172.16.0.9:/export/openbus/gtfs/ /mnt/storage/openbus/gtfs/
      }
      gtfs-nginx = {
        ref_existing = "gtfs"
      }
      airflow-scheduler = {
        ref_existing = "gtfs"
      }
      airflow-db = {
        node = "nfs"
        create_pv = false
      }
      airflow-db2 = {
        node = "rook"
        rook_storage_request_gi = 15
      }
      airflow-home = {
        node = "nfs"
        create_pv = false
      }
      airflow-home2 = {
        node = "rook"
        rook_shared = true
        rook_storage_request_gi = 5
      }
      legacy = {
        node = "nfs"
        create_pv = false
      }
      legacy2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      siri-requester = {
        node = "nfs"
        create_pv = false
      }
      siri-requester2 = {
        node = "rook"
        rook_storage_request_gi = 20
      }
    }
    srm-etl-production = {
      data = {
        node = "worker1"
        create_pv = false
        # rsync -az --delete --checksum 172.16.0.9:/export/srm/etl-production/ /mnt/storage/srm-etl-production/data/
      }
      minio = {
        ref_existing = "data"
        pv_subpath = "/minio"
      }
      db = {
        ref_existing = "data"
        pv_subpath = "/db"
      }
      elasticsearch = {
        ref_existing = "data"
        pv_subpath = "/elasticsearch"
      }
    }
    srm-etl-staging = {
      data = {
        node = "worker2"
        create_pv = false
        # rsync -az --delete --checksum 172.16.0.9:/export/srm/etl-staging/ /mnt/storage/srm-etl-staging/data/
      }
      minio = {
        ref_existing = "data"
        pv_subpath = "/minio"
      }
      db = {
        ref_existing = "data"
        pv_subpath = "/db"
      }
      elasticsearch = {
        ref_existing = "data"
        pv_subpath = "/elasticsearch"
      }
    }
    forum = {
      discourse = {
        node = "nfs"
        namespace_path = "nfs-client-provisioner"
        path = "forum-forum-discourse-pvc-6965541d-4753-42ba-81bf-9d3184a8272f"
      }
      discourse2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      postgres = {
        node = "nfs"
        namespace_path = "nfs-client-provisioner"
        path = "forum-data-forum-postgresql-0-pvc-a8c93ad1-2872-4528-a50f-6d7393bcd36d"
      }
      postgres2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      redis = {
        node = "nfs"
        namespace_path = "nfs-client-provisioner"
        path = "forum-redis-data-forum-redis-master-0-pvc-f9279b40-54d0-4651-a363-b6788d98c772"
      }
      redis2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
    }
    betaknesset = {
      elasticsearch = {
        node = "nfs"
        namespace_path = "nfs-client-provisioner"
        # the actual path is archived-betaknesset-elasticsearch-data-betaknesset-elasticsearch-es-default-0-pvc-ea756c0c-256f-4d50-8095-146a9084bfff
        # there is a bind mount that puts it in this path
        path = "betaknesset-elasticsearch-data-betaknesset-elasticsearch-es-default-0-pvc-ea756c0c-256f-4d50-8095-146a9084bfff"
        create_pvc = false
      }
      elasticsearch2 = {
        node = "rook"
        rook_storage_request_gi = 15
      }
      postgres = {
        node = "nfs"
        create_pv = false
      }
      postgres = {
        node = "rook"
        rook_storage_request_gi = 20
      }
    }
    datacity = {
      baserow = {
        node = "nfs"
        create_pv = false
      }
      ckan-dgp-db = {
        node = "nfs"
        create_pv = false
      }
      ckan-dgp-logs = {
        node = "nfs"
        create_pv = false
      }
      importer = {
        node = "nfs"
        create_pv = false
      }
      mapali = {
        node = "nfs"
        create_pv = false
      }
      baserow2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      ckan-dgp-db2 = {
        node = "rook"
        rook_storage_request_gi = 15
      }
      ckan-dgp-logs2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      importer2 = {
        node = "rook"
        rook_storage_request_gi = 15
      }
      mapali2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
    }
    dear-diary = {
      db = {
        node = "nfs"
        create_pv = false
      }
      db2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
    }
    israelproxy = {
      differ = {
        node = "nfs"
        create_pv = false
      }
      differ2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
    }
    leafy = {
      db = {
        node = "nfs"
        create_pv = false
      }
      db2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
    }
    migdar = {
      elasticsearch = {
        node = "nfs"
        create_pv = false
      }
      elasticsearch2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      internal-search-ui = {
        node = "nfs"
        create_pv = false
      }
      internal-search-ui2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      pipelines = {
        node = "nfs"
        create_pv = false
      }
      pipelines2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      postgres = {
        node = "nfs"
        create_pv = false
      }
      postgres2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
    }
    openlaw = {
      archive_db = {
        node = "nfs"
        create_pv = false
      }
      archive_db2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
    }
    openpension = {
      db = {
        node = "nfs"
        create_pv = false
      }
      db2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      ng_db = {
        node = "nfs"
        create_pv = false
      }
      ng_db2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      staging-db = {
        node = "nfs"
        create_pv = false
      }
      staging-db2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      staging-mongodb = {
        node = "nfs"
        create_pv = false
      }
      staging-mongodb2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
    }
    redash = {
      postgres = {
        node = "nfs"
        create_pv = false
      }
      postgres2 = {
        node = "rook"
        rook_storage_request_gi = 15
      }
    }
    reportit = {
      botkit = {
        node = "nfs"
        create_pv = false
      }
      botkit2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      postgres = {
        node = "nfs"
        create_pv = false
      }
      postgres2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      strapi = {
        node = "nfs"
        create_pv = false
      }
      strapi2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
    }
    resourcesaver = {
      proxy = {
        node = "nfs"
        create_pv = false
      }
      proxy2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
    }
    treebase = {
      db = {
        node = "nfs"
        create_pv = false
      }
      db2 = {
        node = "rook"
        rook_storage_request_gi = 15
      }
      importer = {
        node = "nfs"
        create_pv = false
      }
      importer2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
    }
    wordpress = {
      datacity = {
        node = "nfs"
        create_pv = false
      }
      datacity2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
      db = {
        node = "nfs"
        create_pv = false
      }
      db2 = {
        node = "rook"
        rook_storage_request_gi = 5
      }
    }
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

locals {
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
            ref_existing = lookup(storage, "ref_existing", false)
            pv_subpath = lookup(storage, "pv_subpath", "")
            counter = lookup(storage, "counter", 0)
            namespace_path = lookup(storage, "namespace_path", namespace)
            path = lookup(storage, "path", name)
            full_path = lookup(storage, "full_path", "${lookup(storage, "node", false) == "nfs" ? "/export" : "/mnt/storage"}/${lookup(storage, "namespace_path", namespace)}/${lookup(storage, "path", name)}")
            _base_path = lookup(storage, "node", false) == "nfs" ? "/export" : "/mnt/storage"
            rook_shared = lookup(storage, "rook_shared", false)
            rook_storage_request_gi = lookup(storage, "rook_storage_request_gi", false)
          }
        ]
      ]
    ) : "${s.namespace}_${s.name}" => s
  }

  # paths to backup per node, used for kopia backups as defined in rke2_backups.tf
  rke2_storage_backup_paths = {
    for k, v in local.rke2_storage_flat : k => {
      path = v.full_path
      server = v.node == "nfs" ? "hasadna-nfs1" : "hasadna-rke2-${v.node}"
    } if v.ref_existing == false && v.node != "rook"
  }

  # paths to create on each node
  rke2_storage_local_node_mkdir_paths = {
    for k, v in local.rke2_storage_flat : k => {
      counter = v.counter
      node = v.node
      mkdir_path = v.full_path
    } if v.ref_existing == false && v.node != "nfs" && v.node != false && v.node != "rook"
  }

  # paths to create on the nfs server
  rke2_storage_nfs_mkdir_paths = {
    for k, v in local.rke2_storage_flat : k => {
      counter = v.counter
      mkdir_path = v.full_path
    } if v.ref_existing == false && v.node == "nfs"
  }

  # Persistent Volumes to create for local storage paths
  rke2_storage_pv_create_local = {
    for k, v in local.rke2_storage_flat : k => {
      counter = v.counter
      namespace = v.namespace
      name = v.name
      node = v.ref_existing == false ? v.node : local.rke2_storage_flat["${v.namespace}_${v.ref_existing}"].node
      path = "${v._base_path}/${v.ref_existing == false ? v.namespace_path : local.rke2_storage_flat["${v.namespace}_${v.ref_existing}"].namespace_path}/${v.ref_existing == false ? v.path : local.rke2_storage_flat["${v.namespace}_${v.ref_existing}"].path}${v.pv_subpath}"
    } if v.create_pv && !contains(["nfs", "rook"], v.ref_existing == false ? v.node : local.rke2_storage_flat["${v.namespace}_${v.ref_existing}"].node)
  }

  # Persistent Volumes to create for NFS storage paths
  rke2_storage_pv_create_nfs = {
    for k, v in local.rke2_storage_flat : k => {
      counter = v.counter
      namespace = v.namespace
      name = v.name
      path = "/${v.ref_existing == false ? v.namespace_path : local.rke2_storage_flat["${v.namespace}_${v.ref_existing}"].namespace_path}/${v.ref_existing == false ? v.path : local.rke2_storage_flat["${v.namespace}_${v.ref_existing}"].path}${v.pv_subpath}"
    } if v.create_pv && (v.ref_existing == false ? v.node : local.rke2_storage_flat["${v.namespace}_${v.ref_existing}"].node) == "nfs"
  }
}

resource "null_resource" "rke2_storage" {
  for_each = local.rke2_storage_local_node_mkdir_paths
  depends_on = [null_resource.rke2_mount_workers_storage]
  triggers = {
    counter = each.value.counter
    command = <<-EOF
      ssh hasadna-rke2-${each.value.node} "mkdir -p ${each.value.mkdir_path}"
    EOF
  }
  provisioner "local-exec" {
    command = self.triggers.command
  }
}

resource "null_resource" "rke2_storage_init_nfs" {
  for_each = local.rke2_storage_nfs_mkdir_paths
  depends_on = [null_resource.rke2_mount_workers_storage]
  triggers = {
    counter = each.value.counter
    command = <<-EOF
      ssh hasadna-nfs1 "
        if [ -e ${each.value.mkdir_path} ]; then
          echo "${each.value.mkdir_path}: already exists"
        else
          echo "${each.value.mkdir_path}: creating" &&\
          mkdir -p ${each.value.mkdir_path}
        fi
      "
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
  for_each = local.rke2_storage_pv_create_local
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
            values = [each.value.node]
          }
        }
      }
    }
    persistent_volume_source {
      local {
        path = each.value.path
      }
    }
  }
}

resource "kubernetes_persistent_volume" "rke2_storage_ref_nfs" {
  for_each = local.rke2_storage_pv_create_nfs
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
        path   = each.value.path
        server = kamatera_server.hasadna_nfs2.private_ips[0]
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "rke2_storage" {
  for_each = {for k, v in local.rke2_storage_flat : k => v if v.create_pvc && v.create_pv && v.node != "rook"}
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

resource "kubernetes_persistent_volume_claim" "rke2_storage_rook_block" {
  for_each = {for k, v in local.rke2_storage_flat : k => v if v.node == "rook" && v.rook_shared == false}
  depends_on = [null_resource.rke2_ensure_storage_namespaces]
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
    storage_class_name = "rook-ceph-block"
    resources {
      requests = {
        storage = "${each.value.rook_storage_request_gi}Gi"
      }
    }
    access_modes = ["ReadWriteOnce"]
  }
}

resource "kubernetes_persistent_volume_claim" "rke2_storage_rook_shared" {
  for_each = {for k, v in local.rke2_storage_flat : k => v if v.node == "rook" && v.rook_shared == true}
  depends_on = [null_resource.rke2_ensure_storage_namespaces]
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
    storage_class_name = "rook-cephfs-shared"
    resources {
      requests = {
        storage = "${each.value.rook_storage_request_gi}Gi"
      }
    }
    access_modes = ["ReadWriteMany"]
  }
}
