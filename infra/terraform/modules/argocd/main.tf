# infra/terraform/modules/argocd/main.tf

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

resource "kubernetes_namespace_v1" "argocd_namespace" {
  metadata {
    name   = var.namespace_name
    labels = {
      app = "argocd"
    }
  }
}

resource "helm_release" "argocd_release" {
  name       = var.release_name
  repository = "argo"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace_v1.argocd_namespace.metadata[0].name
  version    = "8.1.3" # Versão do Chart Argo CD - verifique se esta é a mais recente/compatível
  values     = [file("${path.module}/values.yaml")] # Carrega as configurações base
  wait       = true
  timeout    = 600 # Tempo de espera em segundos. O valor deve ser um número.

  # Sobrescreve o NodePort dinamicamente usando 'set', que é a prática recomendada.
  set = [
    {
      # O caminho correto no chart do Argo CD é 'server.service.nodePorts.http'
      name  = "server.service.nodePorts.http"
      value = var.argocd_server_node_port
    }
  ]
  depends_on = [kubernetes_namespace_v1.argocd_namespace]
}

data "kubernetes_service" "argocd_server_service" {
  metadata {
    name      = "${var.release_name}-argocd-server"
    namespace = kubernetes_namespace_v1.argocd_namespace.metadata[0].name
  }
  depends_on = [helm_release.argocd_release]
}

# Não deve haver outputs aqui, eles devem estar no arquivo outputs.tf do módulo.