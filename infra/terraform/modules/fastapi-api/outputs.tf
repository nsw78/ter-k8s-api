# infra/terraform/modules/fastapi-api/outputs.tf

output "api_namespace_name" {
  description = "Nome do namespace onde a API FastAPI foi implantada."
  value       = kubernetes_namespace_v1.api_namespace.metadata[0].name # <-- Referência CORRETA
}

output "api_url" {
  description = "URL para acessar a API FastAPI (via NodePort)."
  # Ajuste para usar a NodePort que você está configurando.
  value       = "http://localhost:${var.node_port}"
}