from sqlalchemy.ext.mutable import MutableList
from sqlalchemy import Column, Integer, String, Float, Date, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from app.database import Base
from pydantic import BaseModel
from typing import List, Optional
from datetime import date

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    age = Column(Integer)
    products = relationship("Product", back_populates="user")
    vitamin_status = relationship("UserVitaminStatus", back_populates="user")

class Product(Base):
    __tablename__ = "products"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    category = Column(String)
    quantity = Column(Float)
    price = Column(Float, nullable=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    expiration_date = Column(Float, nullable=True)
    date_added = Column(Date)
    user = relationship("User", back_populates="products")
    vitamins = relationship("ProductVitamin", back_populates="product")


# Pydantic Model: ProductBase (JSON çıktısı için)
class ProductBase(BaseModel):
    id: int
    name: str
    category: str
    quantity: float
    user_id: int
    price: float
    expiration_date: date
    date_added: date
    is_consumed: bool
    is_discarded: bool

    class Config:
        from_attributes = True
# Pydantic Model: RecipeBase (JSON çıktısı için)
class RecipeBase(BaseModel):
    id: int
    yemek: str
    mutfagi: str
    sure: int
    malzeme: List[str]
    yapilisi: str

    class Config:
        from_attributes = True
