data "template_file" "kube_prometheus_stack" {
  template = file("${path.module}/values/kube-prometheus-stack.yaml.tpl")
  vars = {
    prometheus_path_prefix = var.prometheus_path_prefix
    grafana_path_prefix    = var.grafana_path_prefix
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name      = "prometheus"
  namespace = "default"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  values = [
    data.template_file.kube_prometheus_stack.rendered
  ]
}

resource "helm_release" "kubernetes_dashboard" {
  name      = "kubernetes-dashboard"
  namespace = "default"

  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"

  values = [
    "${file("values/kubernetes-dashboard.yaml")}"
  ]
}
