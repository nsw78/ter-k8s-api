# infra/terraform/modules/argocd/variables.tf

variable "namespace_name" {
  description = "Nome do namespace para os recursos do Argo CD."
  type        = string
  default     = "argocd"
}

variable "release_name" {
  description = "Nome do release Helm para o Argo CD."
  type        = string
  default     = "argocd"
}

variable "argocd_server_node_port" {
  description = "Porta NodePort para acesso à UI do Argo CD Server."
  type        = number
  default     = 30080 # Uma porta diferente para o Argo CD
}