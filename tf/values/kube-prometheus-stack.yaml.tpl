# https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml

grafana:
  grafana.ini:
    security:
      cookie_secure: false
    server:
      root_url: http://localhost/${grafana_path_prefix}

prometheus:
  ingress:
    enabled: true
  prometheusSpec:
    externalUrl: http://localhost/${prometheus_path_prefix}
    routePrefix: /${prometheus_path_prefix}
