locals {
  dice_app_container_port  = 8090
  dice_deployment_manifest = <<-DEPLOYMEMNT
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: ${local.base_name}
      namespace: default
      labels:%{for key in keys(local.k8s_base_labels)}
        ${key}: ${local.k8s_base_labels[key]}%{endfor}
    spec:
      replicas: 4
      selector:
        matchLabels:
          app: ${local.k8s_base_labels["app"]}
      template:
        metadata:
          labels:%{for key in keys(local.k8s_base_labels)}
            ${key}: ${local.k8s_base_labels[key]}%{endfor}
        spec:
          containers:
          - name: app
            image: ${local.tagged_image_name}
            ports:
            - containerPort: ${local.dice_app_container_port}
            volumeMounts:
            - name: data
              mountPath: /assets
            env:
            - name: DICE_APP_PORT
              value: ${local.dice_app_container_port}
            - name: DICE_APP_CSV_FILE_PATH
              value: /assets/dice.csv
            - name: DICE_APP_PATH_PREFIX
              value: ${var.dice_app_path_prefix}
            readinessProbe:
              httpGet:
                path: /health
                port: ${local.dice_app_container_port}
                scheme: HTTP
              initialDelaySeconds: 5
              periodSeconds: 2
              timeoutSeconds: 1
            livenessProbe:
              httpGet:
                path: /health
                port: ${local.dice_app_container_port}
                scheme: HTTP
              initialDelaySeconds: 10
              periodSeconds: 15
              timeoutSeconds: 1
              failureThreshold: 2
          initContainers:
          - name: sidecar
            image: alpine:latest
            restartPolicy: Always
            command: ['sh', '-c', 'tail -F /assets/dice.csv']
            volumeMounts:
            - name: data
              mountPath: /assets
            readinessProbe:
              exec:
                command:
                - stat
                - /assets/dice.csv
              initialDelaySeconds: 5
              periodSeconds: 2
            livenessProbe:
              exec:
                command:
                - stat
                - /assets/dice.csv
              initialDelaySeconds: 10
              periodSeconds: 15
              timeoutSeconds: 1
              failureThreshold: 1
          volumes:
          - name: data
            persistentVolumeClaim:
              claimName: ${kubernetes_persistent_volume_claim.this.metadata[0].name}
  DEPLOYMEMNT
}

# NOTE: For now, the "kubernetes_deployment_v1" does not support restart_policy option
#       https://github.com/hashicorp/terraform-provider-kubernetes/issues/2446
#       As a result, it's not possible to create a sidecar container within the deployment resource.
#       I decided to use "kubernetes_manifest" instead.
#
# TODO: Replace "kubernetes_manifest" with "kubernetes_deployment_v1" when resource is updated.
resource "kubernetes_manifest" "dice_deployment" {
  manifest = provider::kubernetes::manifest_decode(local.dice_deployment_manifest)
}

resource "kubernetes_service" "dice" {
  metadata {
    name   = local.base_name
    labels = local.k8s_base_labels
  }
  spec {
    selector = {
      app = local.k8s_base_labels["app"]
    }
    port {
      port        = local.dice_app_container_port
      target_port = local.dice_app_container_port
    }
  }
}
