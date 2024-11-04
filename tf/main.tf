locals {
  base_name     = "${var.domain}-${var.environment}-${var.role}"
  context_name  = trim("kind-${kind_cluster.this.id}", "-")
  git_repo_root = "${path.root}/.."

  k8s_base_labels = {
    "app.kubernetes.io/name"       = local.base_name
    "app.kubernetes.io/managed-by" = "terraform"
    "domain"                       = var.domain
    "environment"                  = var.environment
    "role"                         = var.role
    "app"                          = local.base_name
  }
}

provider "kind" {}

provider "kubernetes" {
  config_path    = kind_cluster.this.kubeconfig_path
  config_context = local.context_name

}

provider "docker" {}

provider "helm" {
  kubernetes {
    config_path = kind_cluster.this.kubeconfig_path
  }
}
