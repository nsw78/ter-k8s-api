# infra/terraform/modules/monitoring/variables.tf

variable "namespace_name" {
  description = "Nome do namespace para os recursos de monitoramento."
  type        = string
  default     = "monitoring"
}

variable "release_name" {
  description = "Nome do release Helm para o kube-prometheus-stack."
  type        = string
  default     = "kube-prom"
}

variable "grafana_node_port" {
  description = "Porta NodePort para acesso ao Grafana."
  type        = number
  default     = 30090 # Uma porta diferente da sua API para o Grafana
}