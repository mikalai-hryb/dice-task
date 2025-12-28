# NOTE: Read README.md to get more information why "kubernetes_manifest" is not used instead
resource "terraform_data" "manage_argocd" {
  input = {
    argocd_configuration_file_path = "https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
    namespace                      = kubernetes_namespace_v1.argocd.metadata[0].name
  }

  provisioner "local-exec" {
    when    = create
    command = "kubectl apply -n ${self.input.namespace} -f ${self.input.argocd_configuration_file_path}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -n ${self.input.namespace} -f ${self.input.argocd_configuration_file_path}"
  }
}

resource "kubernetes_service_v1" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = "default"
  }
  spec {
    type          = "ExternalName"
    external_name = "argocd-server.${kubernetes_namespace_v1.argocd.metadata[0].name}.svc.cluster.local"
    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }
    port {
      name        = "https"
      port        = 443
      target_port = "https"
    }
  }
}
