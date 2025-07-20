# src/api/main.py

import os
from typing import List

from fastapi import FastAPI, Form, Request, status, Depends, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles

from sqlalchemy.orm import Session

# Importa os modelos Pydantic e SQLAlchemy
from .models.client import Client, ClientBase, ClientDB

# Importa as configurações do banco de dados e a função de dependência
from ..database import SessionLocal, engine, Base, get_db

# Cria as tabelas no banco de dados (se não existirem)
Base.metadata.create_all(bind=engine)

# Instancia a aplicação FastAPI
app = FastAPI()

# --- Configurações de Diretórios para Templates e Arquivos Estáticos ---
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
TEMPLATES_DIR = os.path.join(BASE_DIR, "templates")
STATIC_FILES_DIR = os.path.join(BASE_DIR, "static")

# Configura o Jinja2 para renderizar templates HTML
templates = Jinja2Templates(directory=TEMPLATES_DIR)

# Monta o diretório 'static' para servir arquivos CSS, JS, imagens, etc.
app.mount("/static", StaticFiles(directory=STATIC_FILES_DIR), name="static")

# =========================================================
# Rotas do Site (Páginas HTML Renderizadas por Jinja2)
# =========================================================

@app.get("/", response_class=HTMLResponse, summary="Página inicial de cadastro de clientes")
async def home_page(request: Request):
    """
    Renderiza a página inicial para cadastrar novos clientes.
    """
    return templates.TemplateResponse("index.html", {"request": request})

@app.post("/create-client", response_class=HTMLResponse, summary="Processa o cadastro de um novo cliente via formulário HTML")
async def create_client(
    request: Request,
    name: str = Form(...),
    email: str = Form(...),
    db: Session = Depends(get_db)
):
    """
    Recebe os dados do formulário HTML para cadastrar um novo cliente.
    Redireciona para a lista de clientes após o sucesso ou exibe erro se o e-mail já existe.
    """
    # --- DEBUG: Dados que o FastAPI está recebendo do formulário ---
    print(f"\n--- DEBUG: Dados recebidos do formulário em /create-client ---")
    print(f"Nome do Formulário (variável 'name'): '{name}'")
    print(f"Email do Formulário (variável 'email'): '{email}'")
    print(f"--- Fim do Debug de Formulário em /create-client ---\n")
    # --- FIM DEBUG ---

    db_client = db.query(ClientDB).filter(ClientDB.email == email).first()
    if db_client:
        return templates.TemplateResponse("index.html", {
            "request": request,
            "error": "E-mail já cadastrado! Por favor, use outro e-mail."
        })
    
    new_client_db = ClientDB(name=name, email=email)
    db.add(new_client_db)
    db.commit()
    db.refresh(new_client_db)
    
    return RedirectResponse(url="/clients", status_code=status.HTTP_303_SEE_OTHER)

@app.get("/clients", response_class=HTMLResponse, summary="Lista todos os clientes cadastrados em uma página HTML")
async def list_clients(request: Request, db: Session = Depends(get_db)):
    clients_from_db = db.query(ClientDB).all()

    # --- DEBUG: Clientes como são lidos do Banco de Dados ---
    print("\n--- DEBUG: Clientes do Banco de Dados LIDOS na rota /clients ---")
    if not clients_from_db:
        print("Nenhum cliente encontrado no banco de dados.")
    for c in clients_from_db:
        # Usará o __repr__ do ClientDB (definido em models/client.py)
        print(f"Objeto ClientDB: {c}") 
        # Este print mostra os atributos diretamente do objeto SQLAlchemy
        print(f"    ID: {c.id}, Name (DB): '{c.name}', Email (DB): '{c.email}'")
    print("--- Fim do Debug de Leitura do DB em /clients ---\n")
    # --- FIM DEBUG ---

    # IMPORTANTE PARA DEBUG: Passe os objetos SQLAlchemy diretamente para o template.
    # O template clients.html está esperando 'client.name' e 'client.email'.
    clients = clients_from_db 

    return templates.TemplateResponse("clients.html", {"request": request, "clients": clients})

@app.get("/about", response_class=HTMLResponse, summary="Página 'Sobre Nós' do site")
async def about_page(request: Request):
    """
    Renderiza a página 'Sobre Nós' para fornecer informações sobre a aplicação ou equipe.
    """
    return templates.TemplateResponse("about.html", {"request": request})


# =========================================================
# Rotas da API (Endpoints JSON para interações programáticas)
# =========================================================

@app.post("/api/clients/", response_model=Client, status_code=status.HTTP_201_CREATED, summary="Cria um novo cliente via API JSON")
def create_client_api(client: ClientBase, db: Session = Depends(get_db)):
    """
    Cria um novo cliente no banco de dados.
    - **name**: Nome do cliente.
    - **email**: E-mail único do cliente.
    """
    db_client = db.query(ClientDB).filter(ClientDB.email == client.email).first()
    if db_client:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    db_client = ClientDB(name=client.name, email=client.email)
    db.add(db_client)
    db.commit()
    db.refresh(db_client)
    return db_client

@app.get("/api/clients/", response_model=List[Client], summary="Lista todos os clientes via API JSON")
def read_clients_api(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """
    Retorna uma lista de todos os clientes cadastrados.
    - **skip**: Número de clientes a pular (paginação).
    - **limit**: Número máximo de clientes a retornar (paginação).
    """
    clients = db.query(ClientDB).offset(skip).limit(limit).all()
    return clients

@app.get("/api/clients/{client_id}", response_model=Client, summary="Obtém um cliente específico pelo ID via API JSON")
def read_client_by_id_api(client_id: int, db: Session = Depends(get_db)):
    """
    Retorna um cliente específico com base no seu ID.
    - **client_id**: ID do cliente a ser retornado.
    """
    client = db.query(ClientDB).filter(ClientDB.id == client_id).first()
    if client is None:
        raise HTTPException(status_code=404, detail="Client not found")
    return client

@app.put("/api/clients/{client_id}", response_model=Client, summary="Atualiza um cliente existente via API JSON")
def update_client_api(client_id: int, client: ClientBase, db: Session = Depends(get_db)):
    """
    Atualiza os dados de um cliente existente.
    - **client_id**: ID do cliente a ser atualizado.
    - **name**: Novo nome do cliente.
    - **email**: Novo e-mail do cliente (deve ser único).
    """
    db_client = db.query(ClientDB).filter(ClientDB.id == client_id).first()
    if db_client is None:
        raise HTTPException(status_code=404, detail="Client not found")
    
    # Verifica se o novo email já existe para outro cliente (se o email mudou)
    if client.email != db_client.email and db.query(ClientDB).filter(ClientDB.email == client.email).first():
        raise HTTPException(status_code=400, detail="Email already registered for another client")

    db_client.name = client.name
    db_client.email = client.email
    db.commit()
    db.refresh(db_client)
    return db_client

@app.delete("/api/clients/{client_id}", status_code=status.HTTP_204_NO_CONTENT, summary="Deleta um cliente via API JSON")
def delete_client_api(client_id: int, db: Session = Depends(get_db)):
    """
    Deleta um cliente específico do banco de dados.
    - **client_id**: ID do cliente a ser deletado.
    """
    db_client = db.query(ClientDB).filter(ClientDB.id == client_id).first()
    if db_client is None:
        raise HTTPException(status_code=404, detail="Client not found")
    
    db.delete(db_client)
    db.commit()
    return {"message": "Client deleted successfully"}