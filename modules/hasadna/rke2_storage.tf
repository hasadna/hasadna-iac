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
    }
  }
  rke2_storage_flat = {
    for s in flatten(
      [
        for namespace, storages in local.rke2_storage: [
          for name, storage in storages : {
            namespace = namespace
            name = name
            node = storage.node
            create_pvc = lookup(storage, "create_pvc", true)
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
  for_each = local.rke2_storage_flat
  depends_on = [null_resource.rke2_mount_workers_storage]
  triggers = {
    counter = lookup(each.value, "counter", 0)
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
      KUBECONFIG=${var.rke2_kubeconfig_path} kubectl create namespace ${each.key} || true
    EOF
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
  for_each = local.rke2_storage_flat
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
        path = "/mnt/storage/${each.value.namespace}/${each.value.name}"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "rke2_storage" {
  for_each = {for k, v in local.rke2_storage_flat : k => v if v.create_pvc}
  depends_on = [kubernetes_persistent_volume.rke2_storage, null_resource.rke2_ensure_storage_namespaces]
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
