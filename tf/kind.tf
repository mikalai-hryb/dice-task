# https://kind.sigs.k8s.io/docs/user/configuration/
resource "kind_cluster" "this" {
  name           = "mhryb-dice"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      extra_mounts {
        host_path = "/tmp/kind"
        container_path = "/tmp/k8s/pv"
      }
      extra_port_mappings {
        container_port = 80
        host_port      = 80
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
        protocol       = "TCP"
      }
      labels = {
        "ingress-ready" = true
      }
    }

    # node {
    #   role = "worker"
    # }

    # node {
    #   role = "worker"
    # }
  }
}

# https://kind.sigs.k8s.io/docs/user/quick-start/#loading-an-image-into-your-cluster
resource "terraform_data" "upload_image_to_kind_nodes" {
  triggers_replace = [docker_image.this.image_id]

  provisioner "local-exec" {
    command = "kind load docker-image --name ${kind_cluster.this.name} ${local.tagged_image_name}"
  }
}
