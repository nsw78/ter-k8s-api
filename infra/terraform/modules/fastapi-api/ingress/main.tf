# Dentro de infra/terraform/modules/fastapi-api/main.tf

# ... (Deployment e Service acima) ...

module "api_ingress" {
  source = "./features/ingress" # Caminho relativo para o submódulo

  # Passa variáveis necessárias do módulo pai para o submódulo
  app_name        = var.app_name
  namespace_name  = kubernetes_namespace_v1.api_namespace.metadata[0].name
  service_name    = kubernetes_service_v1.fastapi_app_service.metadata[0].name
  service_port    = var.service_port
}