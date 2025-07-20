# 🚀 Usando o OpenTofu + Kubernetes + FastAPI + Grafana + Prometheus + ArgoCD 🚀

Bem-vindo ao *OpenTofu*! Este repositório contém uma aplicação FastAPI de exemplo e toda a infraestrutura como código necessária para implantá-la em um cluster Kubernetes local (Docker Desktop).

---

## 📚 Visão Geral do Projeto

Este projeto demonstra uma estrutura de diretórios organizada para aplicações Python com FastAPI, Docker, Terraform e Kubernetes. Ele inclui:

* Uma API FastAPI simples para gerenciamento de clientes.
* Templates Jinja2 e arquivos estáticos para uma interface web básica.
* Um `Dockerfile` para conteinerizar a aplicação.
* Módulos Terraform para definir a infraestrutura Kubernetes (deployment da API, monitoramento).
* Scripts PowerShell para automatizar tarefas comuns de desenvolvimento e deployment local.

---

## 🌳 Estrutura do Repositório

Para entender a organização, consulte o arquivo detalhado de estrutura: [docs/detail_structure.md](docs/detail_structure.md)

---

## ⚡ Primeiros Passos

### Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas:

* [**Git**](https://git-scm.com/): Para clonar o repositório.
* [**Python 3.9+**](https://www.python.org/downloads/): Para desenvolver a aplicação FastAPI.
* [**Docker Desktop**](https://www.docker.com/products/docker-desktop/): Com o **Kubernetes habilitado** nas configurações.
* [**kubectl**](https://kubernetes.io/docs/tasks/tools/install-kubectl/): Ferramenta de linha de comando para Kubernetes.
* [**Terraform**](https://developer.hashicorp.com/terraform/downloads): Para provisionar a infraestrutura.
* [**PowerShell**](https://docs.microsoft.com/en-us/powershell/): Para executar os scripts de automação.

### Configuração do Ambiente Local

1.  **Clone o repositório:**
    ```bash
    git clone [https://github.com/seu-usuario/seu-novo-projeto.git](https://github.com/seu-usuario/seu-novo-projeto.git)
    cd seu-novo-projeto
    ```
2.  **Crie a estrutura de pastas:**
    (Se você não usou o script de criação de pastas anteriormente, execute o script `scripts/create_project_structure.ps1` ou o comando `mkdir` ajustado)
3.  **Configurar o autocomplete do kubectl no PowerShell (se ainda não fez):**
    Execute o script `scripts/setup_local_env.ps1`.
4.  **Configurar ambiente virtual Python:**
    ```powershell
    python -m venv .venv
    .\.venv\Scripts\Activate.ps1 # No Windows PowerShell
    # source ./.venv/bin/activate # No Bash/WSL
    ```
5.  **Instalar dependências Python:**
    ```powershell
    pip install -r src/requirements.txt
    ```

### Rodando a Aplicação Localmente (Desenvolvimento)

Para rodar a API em modo de desenvolvimento (com *hot-reload*):

1.  Certifique-se de que seu ambiente virtual esteja ativado.
2.  Navegue até o diretório `src/`:
    ```powershell
    cd src
    ```
3.  Execute o Uvicorn:
    ```powersell
    uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
    ```
    Acesse a API em seu navegador: `http://localhost:8000`

### Deploy no Kubernetes Local (Docker Desktop)

1.  **Construir a imagem Docker da API:**
    ```powershell
    .\scripts\build_docker_image.ps1
    ```
2.  **Inicializar e aplicar Terraform para o ambiente local:**
    ```powershell
    cd infra\terraform\environments\local
    terraform init
    terraform apply -auto-approve
    ```
3.  **Verificar o deployment:**
    ```powershell
    kubectl get pods -n default
    kubectl get svc -n default
    kubectl get ingress -n default
    ```
    Aguarde até que os pods estejam `Running`.
    A URL de acesso dependerá da configuração do seu Ingress. Se você estiver usando o Ingress padrão do Docker Desktop Kubernetes (normalmente `localhost`), a aplicação deve estar acessível via `http://localhost:<porta_do_ingress>` ou `http://localhost/<caminho_do_ingress>`.

### Limpeza do Ambiente Local

Para derrubar a infraestrutura criada pelo Terraform:

```powershell
cd infra\terraform\environments\local
terraform destroy -auto-approve