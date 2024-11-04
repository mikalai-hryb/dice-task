output "context_name" {
  value       = "kind-${kind_cluster.this.name}"
  description = "Kubernetes context name."
}

output "handy_urls" {
  value = {
    dice_app   = "https://localhost/${var.dice_app_path_prefix}"
    prometheus = "https://localhost/${var.prometheus_path_prefix}"
    grafana    = "https://localhost/${var.grafana_path_prefix}"
    dashboard  = "https://localhost/${var.dashboard_path_prefix}"
  }
}

output "admin_user_token" {
  value     = kubernetes_secret_v1.admin_user.data["token"]
  sensitive = true
}

output "grafana_credentials" {
  value     = data.kubernetes_secret_v1.prometheus_grafana.data
  sensitive = true
}

output "dice_deployment_name" {
  value = local.base_name
}
