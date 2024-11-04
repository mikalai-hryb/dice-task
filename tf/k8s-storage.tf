resource "kubernetes_storage_class" "this" {
  metadata {
    name   = "local-storage"
    labels = local.k8s_base_labels
  }
  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "WaitForFirstConsumer"
  reclaim_policy      = "Delete"
}

resource "kubernetes_persistent_volume" "this" {
  metadata {
    name   = "${local.base_name}-pv"
    labels = local.k8s_base_labels
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    capacity           = { storage = "10Mi" }
    storage_class_name = kubernetes_storage_class.this.metadata[0].name

    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "node-role.kubernetes.io/control-plane"
            operator = "Exists"
          }
        }
      }
    }
    persistent_volume_source {
      local {
        path = kind_cluster.this.kind_config[0].node[0].extra_mounts[0].container_path
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "this" {
  metadata {
    name   = "${local.base_name}-pvc"
    labels = local.k8s_base_labels
  }
  spec {
    access_modes       = kubernetes_persistent_volume.this.spec[0].access_modes
    storage_class_name = kubernetes_storage_class.this.metadata[0].name
    volume_name        = kubernetes_persistent_volume.this.metadata[0].name

    resources {
      requests = {
        storage = kubernetes_persistent_volume.this.spec[0].capacity.storage
      }
    }
  }
}
