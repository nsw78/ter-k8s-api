# src/api/models/client.py
from pydantic import BaseModel, ConfigDict
from sqlalchemy import Column, Integer, String
# Importa Base do arquivo de database
from ...database import Base 

class ClientDB(Base):
    __tablename__ = "clients"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)   # O nome do cliente
    email = Column(String, unique=True, index=True) # O e-mail do cliente

    # Método para depuração: mostra o que o SQLAlchemy está lendo
    def __repr__(self):
        return f"<ClientDB(id={self.id}, name='{self.name}', email='{self.email}')>"

# Modelos Pydantic para validação de entrada/saída de dados
class ClientBase(BaseModel):
    name: str
    email: str

class ClientCreate(ClientBase):
    pass

class Client(ClientBase):
    id: int
    # Configuração crucial para Pydantic trabalhar com objetos SQLAlchemy
    model_config = ConfigDict(from_attributes=True)