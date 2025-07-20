# infra/terraform/modules/monitoring/outputs.tf

output "grafana_url" {
  description = "URL para acessar o dashboard do Grafana."
  value       = "http://localhost:${var.grafana_node_port}"
}