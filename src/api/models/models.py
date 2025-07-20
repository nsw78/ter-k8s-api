# Exemplo do modelo Pydantic
from pydantic import BaseModel

class ClientCreate(BaseModel):
    name: str
    email: str

class Client(ClientCreate):
    id: int
    # Outros campos se houver

# Exemplo do modelo SQLAlchemy (em src/api/database.py ou src/api/models.py)
from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class ClientDB(Base):
    __tablename__ = "clients"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    email = Column(String, unique=True, index=True)