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
    is_consumed = Column(Boolean, default=False)
    is_discarded = Column(Boolean, default=False)
    user = relationship("User", back_populates="products")
    vitamins = relationship("ProductVitamin", back_populates="product")

class Vitamin(Base):
    __tablename__ = "vitamins"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(String)
    products = relationship("ProductVitamin", back_populates="vitamin")

# SQLAlchemy Model: ProductVitamin
class ProductVitamin(Base):
    __tablename__ = "product_vitamins"
    product_id = Column(Integer, ForeignKey("products.id"), primary_key=True)
    vitamin_id = Column(Integer, ForeignKey("vitamins.id"), primary_key=True)
    amount_mg = Column(Float)
    product = relationship("Product", back_populates="vitamins")
    vitamin = relationship("Vitamin", back_populates="products")

# SQLAlchemy Model: UserVitaminStatus
class UserVitaminStatus(Base):
    __tablename__ = "user_vitamin_status"
    user_id = Column(Integer, ForeignKey("users.id"), primary_key=True)
    vitamin_id = Column(Integer, ForeignKey("vitamins.id"), primary_key=True)
    current_level = Column(Float)
    recommended_level = Column(Float)
    user = relationship("User", back_populates="vitamin_status")
    vitamin = relationship("Vitamin")

# SQLAlchemy Model: Recipe
class Recipe(Base):
    __tablename__ = "recipes"
    id = Column(Integer, primary_key=True, index=True)
    yemek = Column(String, index=True)
    mutfagi = Column(String)
    sure = Column(Integer)
    malzeme = Column(MutableList.as_mutable(String))
    yapilisi = Column(String)


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
