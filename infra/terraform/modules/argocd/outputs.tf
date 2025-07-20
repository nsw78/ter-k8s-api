# infra/terraform/modules/argocd/outputs.tf

output "argocd_url" {
  description = "URL para acessar a UI do Argo CD."
  # Use a NodePort diretamente da variável de entrada do módulo, se possível,
  # ou do serviço real se ele for populado no data source.
  value       = "http://localhost:${var.argocd_server_node_port}"
}

output "argocd_admin_password_secret_name" {
  description = "Nome do Secret que contém a senha do admin do Argo CD. Use `kubectl -n argocd get secret <nome> -o jsonpath='{.data.password}' | base64 --decode` para obter a senha."
  value       = "${var.release_name}-argocd-initial-admin-secret"
}