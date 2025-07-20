-----

# 🚀 Usando o OpenTofu + Kubernetes + FastAPI + Grafana + Prometheus + ArgoCD 🚀

Bem-vindo ao *ter-k8s-api*\! Este repositório contém uma aplicação **FastAPI** de exemplo e toda a infraestrutura como código necessária para implantá-la em um cluster Kubernetes local (Docker Desktop).

-----

## 📚 Visão Geral do Projeto

Este projeto demonstra uma estrutura de diretórios organizada para aplicações Python com FastAPI, Docker, OpenTofu e Kubernetes. Ele inclui:

  * Uma **API FastAPI** simples para gerenciamento de clientes, que permite operações de **cadastro**, consulta, atualização e exclusão.
  * **Documentação interativa da API com Swagger UI (OpenAPI)**, gerada automaticamente pelo FastAPI, facilitando a exploração e o teste dos endpoints.
  * Templates Jinja2 e arquivos estáticos para uma interface web básica.
  * Um `Dockerfile` para conteinerizar a aplicação.
  * Módulos **OpenTofu** para definir a infraestrutura Kubernetes, incluindo o deployment da API, monitoramento e configuração de ferramentas de observabilidade e CI/CD.
  * Implantação de **Prometheus** para coleta de métricas e **Grafana** para visualização e dashboards, garantindo a monitoração robusta da aplicação e do cluster.
  * Configuração do **ArgoCD** para orquestração de pipelines de Continuous Delivery (CD), automatizando a implantação e sincronização do estado da aplicação no cluster.
  * Scripts PowerShell para automatizar tarefas comuns de desenvolvimento e deployment local.

-----

## 🌳 Estrutura do Repositório

Para entender a organização, consulte o arquivo detalhado de estrutura: [docs/detail\_structure.md](https://www.google.com/search?q=docs/detail_structure.md)

```
├───.vscode
├───docs
│       detalif_structure.md
│
├───infra
│   └───terraform
│       │   .terraform.lock.hcl
│       │   main.tf
│       │   terraform.tfstate
│       │   terraform.tfstate.backup
│       │
│       ├───.terraform
│       │   ├───modules
│       │   │       modules.json
│       │   │
│       │   └───providers
│       │       ├───registry.opentofu.org
│       │       │   └───hashicorp
│       │       │       ├───helm
│       │       │       │   └───3.0.2
│       │       │       │       └───windows_amd64
│       │       │       │               CHANGELOG.md
│       │       │       │               CHANGELOG_GUIDE.md
│       │       │       │               LICENSE
│       │       │       │               README.md
│       │       │       │               terraform-provider-helm.exe
│       │       │       │
│       │       │       ├───kubernetes
│       │       │       │   └───2.37.1
│       │       │       │       └───windows_amd64
│       │       │       │               CHANGELOG.md
│       │       │       │               CHANGELOG_GUIDE.md
│       │       │       │               LICENSE
│       │       │       │               README.md
│       │       │       │               terraform-provider-kubernetes.exe
│       │       │       │
│       │       │       └───null
│       │       │           └───3.2.4
│       │       │               └───windows_amd64
│       │       │                       CHANGELOG.md
│       │       │                       LICENSE
│       │       │                       README.md
│       │       │                       terraform-provider-null.exe
│       │       │
│       │       └───registry.terraform.io
│       │           └───hashicorp
│       │               └───aws
│       │                   └───5.100.0
│       │                       └───windows_amd64
│       │                               LICENSE.txt
│       │                               terraform-provider-aws_v5.100.0_x5.exe
│       │
│       ├───environments
│       │   ├───dev
│       │   ├───prod
│       │   └───stage
│       └───modules
│           ├───argocd
│           │       main.tf
│           │       outputs.tf
│           │       values.yaml
│           │       variables.tf
│           │       version.tf
│           │
│           ├───fastapi-api
│           │   │   main.tf
│           │   │   outputs.tf
│           │   │   variables.tf
│           │   │   version.tf
│           │   │
│           │   └───ingress
│           │           main.tf
│           │
│           └───monitoring
│               │   main.tf
│               │   outputs.tf
│               │   values.yaml
│               │   variables.tf
│               │   version.tf
│               │
│               └───chart
├───kubernetes
│       deployment.yaml
│       service.yaml
│
├───scripts
│       install-opentofu.ps1
│
└───src
    │   database.py
    │   requirements.txt
    │
    ├───api
    │   │   main.py
    │   │   __init__.py
    │   │
    │   ├───models
    │   │   │   client.py
    │   │   │   models.py
    │   │   │
    │   │   └───__pycache__
    │   │           client.cpython-313.pyc
    │   │
    │   ├───static
    │   │   └───css
    │   │           style.css
    │   │
    │   ├───templates
    │   │       about.html
    │   │       base.html
    │   │       clients.html
    │   │       index.html
    │   │
    │   └───__pycache__
    │           main.cpython-313.pyc
    │           __init__.cpython-313.pyc
    │
    ├───tests
    └───__pycache__
            database.cpython-313.pyc
            security.cpython-313.pyc
```

-----

## ⚡ Primeiros Passos

### Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas:

  * [**Git**](https://git-scm.com/): Para clonar o repositório.
  * [**Python 3.9+**](https://www.python.org/downloads/): Para desenvolver a aplicação FastAPI.
  * [**Docker Desktop**](https://www.docker.com/products/docker-desktop/): Com o **Kubernetes habilitado** nas configurações.
  * [**kubectl**](https://kubernetes.io/docs/tasks/tools/install-kubectl/): Ferramenta de linha de comando para Kubernetes.
  * [**OpenTofu**](https://opentofu.org/docs/): Para provisionar a infraestrutura.
  * [**PowerShell**](https://docs.microsoft.com/en-us/powershell/): Para executar os scripts de automação.

### Configuração do Ambiente Local

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/nsw78/ter-k8s-api.git
    cd ter-k8s-api
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
    ```powershell
    uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
    ```
    Acesse a API em seu navegador: `http://localhost:8000`
    Você também pode acessar a **documentação interativa da API (Swagger UI)** em `http://localhost:8000/docs`. Para explorar as definições OpenAPI (JSON), utilize `http://localhost:8000/openapi.json`.

-----

## ☁️ Deploy no Kubernetes Local (Docker Desktop)

Este projeto integra o deployment da aplicação, Prometheus, Grafana e ArgoCD no seu cluster Kubernetes local, tudo gerenciado via OpenTofu.

1.  **Construir a imagem Docker da API:**

    ```powershell
    .\scripts\build_docker_image.ps1
    ```

2.  **Inicializar e aplicar OpenTofu para o ambiente local:**

    ```powershell
    cd infra\opentofu\environments\local
    opentofu init
    opentofu apply -auto-approve
    ```

3.  **Verificar o deployment:**

    ```powershell
    kubectl get pods -n default
    kubectl get svc -n default
    kubectl get ingress -n default
    ```

    Aguarde até que os pods estejam `Running`.
    A URL de acesso da aplicação dependerá da configuração do seu Ingress. Se você estiver usando o Ingress padrão do Docker Desktop Kubernetes (normalmente `localhost`), a aplicação deve estar acessível via `http://localhost:<porta_do_ingress>` ou `http://localhost/<caminho_do_ingress>`.

      * **Prometheus:** Geralmente exposto via Ingress ou Port-Forwarding (verifique os logs do OpenTofu ou serviços Kubernetes).
      * **Grafana:** Geralmente exposto via Ingress ou Port-Forwarding. A URL e credenciais padrão podem ser encontradas na documentação do Helm Chart ou nos outputs do OpenTofu.
      * **ArgoCD:** Acesse-o via Ingress ou Port-Forwarding. A URL e credenciais padrão podem ser encontradas na documentação do Helm Chart ou nos outputs do OpenTofu.

-----

## 🧹 Limpeza do Ambiente Local

Para derrubar toda a infraestrutura criada pelo OpenTofu:

```powershell
cd infra\opentofu\environments\local
opentofu destroy -auto-approve
```