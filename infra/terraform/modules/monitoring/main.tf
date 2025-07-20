# infra/terraform/modules/monitoring/main.tf

# Define o provedor Kubernetes para uso neste módulo
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}

# Define o provedor Helm para uso neste módulo.
provider "helm" {
  kubernetes = { # Sintaxe CORRETA: 'kubernetes = {'
    config_path    = "~/.kube/config"
    config_context = "docker-desktop"
  }
}

resource "kubernetes_namespace_v1" "monitoring_namespace" {
  metadata {
    name   = var.namespace_name
    labels = {
      app = "monitoring"
    }
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name       = var.release_name
  repository = "prometheus-community"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace_v1.monitoring_namespace.metadata[0].name
  version    = "75.12.0" # Versão do Chart Kube-Prometheus-Stack - verifique se esta é a mais recente/compatível
  values     = [file("${path.module}/values.yaml")]
  wait       = true
  timeout    = 600 # Tempo de espera em segundos. O valor deve ser um número.

  # Garante que o NodePort do Grafana seja passado como número
  set = [
    {
      name  = "grafana.service.nodePort"
      value = var.grafana_node_port
    },
    {
      name  = "prometheus-node-exporter.enabled"
      value = "false"
    }
  ]
  depends_on = [kubernetes_namespace_v1.monitoring_namespace]
}

data "kubernetes_service" "grafana_service" {
  metadata {
    name      = "${var.release_name}-grafana"
    namespace = kubernetes_namespace_v1.monitoring_namespace.metadata[0].name
  }
  depends_on = [helm_release.kube_prometheus_stack]
}

# Não deve haver outputs aqui, eles devem estar no arquivo outputs.tf do módulo.