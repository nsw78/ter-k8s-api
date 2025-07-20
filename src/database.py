# src/database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# URL de conexão com o banco de dados SQLite
# O arquivo 'sql_app.db' será criado na raiz do seu contêiner.
SQLALCHEMY_DATABASE_URL = "sqlite:///./sql_app.db"

# Cria a engine do SQLAlchemy
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False} # Necessário para SQLite em FastAPI
)

# Configura a sessão de banco de dados
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base para os modelos declarativos do SQLAlchemy
Base = declarative_base()

# Função de dependência para obter a sessão do banco de dados
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()