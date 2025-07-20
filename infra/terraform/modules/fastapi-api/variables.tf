# infra/terraform/modules/fastapi-api/variables.tf

variable "app_name" {
  description = "Nome da aplicação, usado para labels e prefixos."
  type        = string
}

variable "namespace_name" {
  description = "Nome do namespace onde a API será implantada."
  type        = string
}

variable "image_name" {
  description = "Nome da imagem Docker da API (ex: my-fastapi-app:latest)."
  type        = string
}

variable "image_pull_policy" {
  description = "Política de pull da imagem (ex: IfNotPresent, Always)."
  type        = string
  default     = "IfNotPresent"
}

variable "container_port" {
  description = "Porta que o contêiner da API escuta internamente."
  type        = number
  default     = 8000
}

variable "service_port" {
  description = "Porta do Service Kubernetes (dentro do cluster)."
  type        = number
  default     = 80
}

variable "node_port" {
  description = "Porta NodePort exposta no host para acesso externo."
  type        = number
}

variable "replica_count" {
  description = "Número de réplicas do deployment da API."
  type        = number
  default     = 1
}