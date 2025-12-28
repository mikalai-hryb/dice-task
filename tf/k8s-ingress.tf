
# NOTE: Read README.md to get more information why "kubernetes_manifest" is not used instead
resource "terraform_data" "manage_kind_ingress" {
  input = {
    kind_ingress_configuration_file_path = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"
  }

  provisioner "local-exec" {
    when    = create
    command = "kubectl apply -f ${self.input.kind_ingress_configuration_file_path}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f ${self.input.kind_ingress_configuration_file_path}"
  }
}

resource "kubernetes_ingress_v1" "this" {
  metadata {
    name = "${var.domain}-${var.environment}"
    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
    }
  }

  spec {
    rule {
      http {

        path {
          path = "/${var.dice_app_path_prefix}(/|$)(.*)"
          backend {
            service {
              name = kubernetes_service.dice.metadata[0].name
              port {
                number = kubernetes_service.dice.spec[0].port[0].port
              }
            }
          }
        }

        # TODO: use this ingress instead of built-in (from the helm chart - values/kube-prometheus-stack.yaml)
        # path {
        #   path = "/prometheus(/|$)(.*)"
        #   backend {
        #     service {
        #       name = "prometheus-kube-prometheus-prometheus"
        #       port {
        #         number = 8080
        #       }
        #     }
        #   }
        # }

        path {
          path = "/${var.grafana_path_prefix}(/|$)(.*)"
          backend {
            service {
              name = "prometheus-grafana"
              port {
                number = 80
              }
            }
          }
        }

        path {
          path = "/${var.dashboard_path_prefix}(/|$)(.*)"
          backend {
            service {
              name = "kubernetes-dashboard-kong-proxy"
              port {
                number = 80
              }
            }
          }
        }

        path {
          path      = "/argocd(/|$)(.*)"
          backend {
            service {
              name = kubernetes_service_v1.argocd_server.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }

      }
    }
  }
}
