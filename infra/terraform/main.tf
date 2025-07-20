# main.tf

# Configurações gerais do OpenTofu
terraform {
  required_version = ">= 1.6.0" # Defina a versão mínima do OpenTofu (ou Terraform)
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0" # Defina uma versão compatível para o provedor Kubernetes
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11.0" # Defina uma versão compatível para o provedor Helm
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0" # Defina uma versão compatível para o provedor Null
    }
  }
}

# --- Provedores ---
# Configura o provedor Kubernetes para se conectar ao cluster Docker Desktop.
# Ele usa o arquivo kubeconfig padrão e o contexto 'docker-desktop'.
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}

# Configura o provedor Helm, que depende da conexão com o Kubernetes.
# Ele automaticamente herda a configuração do provedor Kubernetes definido acima
# quando usado no módulo raiz.
provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "docker-desktop"
  }
}

# Provedor Null é usado para gatilhos locais, como comandos shell.
provider "null" {}

# --- Recursos Locais (fora dos módulos para ações específicas) ---

# Recurso nulo para adicionar o repositório Helm do Argo CD.
resource "null_resource" "add_argo_repo" {
  provisioner "local-exec" {
    command = "helm repo add argo https://argoproj.github.io/argo-helm --force-update"
  }
  triggers = {
    always_run = timestamp() # Garante que o comando seja executado a cada 'apply'
  }
}

# Recurso nulo para adicionar o repositório Helm do Prometheus Community.
resource "null_resource" "add_prometheus_repo" {
  provisioner "local-exec" {
    command = "helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update"
  }
  triggers = {
    always_run = timestamp() # Garante que o comando seja executado a cada 'apply'
  }
}

# Recurso nulo para atualizar todos os repositórios Helm.
resource "null_resource" "update_helm_repos" {
  provisioner "local-exec" {
    command = "helm repo update"
  }
  triggers = {
    always_run = timestamp() # Garante que o comando seja executado a cada 'apply'
  }
  # Garante que os repositórios sejam adicionados antes de tentar atualizá-los
  depends_on = [
    null_resource.add_argo_repo,
    null_resource.add_prometheus_repo
  ]
}

# --- Chamadas dos Módulos ---
# Agora que os módulos têm suas próprias configurações de provedor,
# não precisamos mais passar os provedores ou usar 'depends_on' diretamente aqui.

# Chamada do Módulo da API (fastapi-api)
module "my_fastapi_app" {
  source = "./modules/fastapi-api" # Caminho para o módulo da API

  app_name       = "fastapi-app"
  namespace_name = "fastapi-app"
  image_name     = "my-fastapi-app:latest"
  node_port      = 30007
}

# Chamada do Módulo de Monitoramento (cluster_monitoring)
module "cluster_monitoring" {
  source = "./modules/monitoring" # Caminho para o módulo de monitoramento

  namespace_name    = "monitoring" # Nome do namespace para monitoramento
  release_name      = "kube-prom"  # Nome da release Helm
  grafana_node_port = 30090        # NodePort para acessar o Grafana
}

# Chamada do Módulo do Argo CD (gitops_argocd)
module "gitops_argocd" {
  source = "./modules/argocd" # Caminho para o módulo do Argo CD

  namespace_name          = "argocd" # Nome do namespace para o Argo CD
  release_name            = "argocd" # Nome da release Helm
  argocd_server_node_port = 30080    # NodePort para acessar a UI do Argo CD
}

# --- Saídas (Outputs) ---
# Define as saídas do módulo raiz para informações importantes.

output "fastapi_api_namespace" {
  description = "Namespace onde a API FastAPI foi implantada."
  value       = module.my_fastapi_app.api_namespace_name
}

output "fastapi_api_url" {
  description = "URL para acessar a API FastAPI."
  value       = module.my_fastapi_app.api_url
}

output "grafana_dashboard_url" {
  description = "URL para acessar o dashboard do Grafana."
  value       = module.cluster_monitoring.grafana_url
}

output "argocd_ui_url" {
  description = "URL para acessar a UI do Argo CD."
  value       = module.gitops_argocd.argocd_url
}

output "argocd_admin_password_secret" {
  description = "Nome do Secret que contém a senha do admin do Argo CD."
  value       = module.gitops_argocd.argocd_admin_password_secret_name
}