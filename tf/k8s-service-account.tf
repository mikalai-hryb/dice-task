resource "kubernetes_service_account_v1" "admin_user" {
  metadata {
    name = "admin-user"
  }
}

resource "kubernetes_cluster_role_binding_v1" "admin_user" {
  metadata {
    name = kubernetes_service_account_v1.admin_user.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.admin_user.metadata[0].name
    namespace = kubernetes_service_account_v1.admin_user.metadata[0].namespace
  }
}
