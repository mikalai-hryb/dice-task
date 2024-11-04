data "kubernetes_secret_v1" "prometheus_grafana" {
  metadata {
    name = "prometheus-grafana"
  }

  depends_on = [ helm_release.kube_prometheus_stack ]
}

resource "kubernetes_secret_v1" "admin_user" {
  metadata {
    name = kubernetes_service_account_v1.admin_user.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.admin_user.metadata[0].name
    }
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}
