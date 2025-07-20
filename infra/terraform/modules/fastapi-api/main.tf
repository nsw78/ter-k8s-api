# infra/terraform/modules/fastapi-api/main.tf

# Define o provedor Kubernetes para uso neste módulo
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}

resource "kubernetes_namespace_v1" "api_namespace" { # <-- Garanta que o nome local é "api_namespace"
  metadata {
    name   = var.namespace_name
    labels = {
      app = var.app_name
    }
  }
}

resource "kubernetes_deployment_v1" "fastapi_app_deployment" {
  metadata {
    name      = "${var.app_name}-deployment"
    namespace = kubernetes_namespace_v1.api_namespace.metadata[0].name # <-- Referência CORRETA
    labels = {
      app = var.app_name
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.app_name
      }
    }
    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }
      spec {
        container {
          name  = var.app_name
          image = var.image_name
          port {
            container_port = 8000 # Porta interna da sua aplicação FastAPI
          }
        }
      }
    }
  }
  depends_on = [kubernetes_namespace_v1.api_namespace]
}

resource "kubernetes_service_v1" "fastapi_app_service" {
  metadata {
    name      = "${var.app_name}-service"
    namespace = kubernetes_namespace_v1.api_namespace.metadata[0].name # <-- Referência CORRETA
    labels = {
      app = var.app_name
    }
  }
  spec {
    selector = {
      app = var.app_name
    }
    port {
      protocol    = "TCP"
      port        = 80      # Porta interna do serviço Kubernetes
      target_port = 8000    # Porta do container (fastapi)
      node_port   = var.node_port # Porta exposta no nó do cluster
    }
    type = "NodePort"
  }
  depends_on = [kubernetes_deployment_v1.fastapi_app_deployment]
}

# Não deve haver outputs aqui, eles devem estar em outputs.tf