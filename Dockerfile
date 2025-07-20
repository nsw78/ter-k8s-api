# Dockerfile Simplificado para Teste Local

FROM python:3.10-slim-bullseye

# Define o diretório de trabalho dentro do contêiner
WORKDIR /app

# Instala algumas dependências de sistema essenciais (menos do que antes, para ser mínimo)
# 'curl' é útil para debug, 'libpq-dev' se você usa PostgreSQL (pode remover se não for o caso)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copia o arquivo de dependências para a raiz do WORKDIR e instala
COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia o restante do código da sua aplicação para o contêiner
COPY src/ /app/src/

# Expõe a porta que sua aplicação vai usar
EXPOSE 8000

# Comando para rodar a aplicação quando o contêiner for iniciado
# Usamos 'python -m gunicorn' para garantir que o gunicorn seja encontrado
# O caminho da aplicação é 'src.api.main:app' porque o código está em /app/src
CMD ["python", "-m", "gunicorn", "-w", "1", "-k", "uvicorn.workers.UvicornWorker", "src.api.main:app", "--bind", "0.0.0.0:8000"]