from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import SessionLocal
from .crud import (
    get_products,
    update_product,
    delete_product,
    create_product,
    suggest_recipes_by_ingredients,
    create_kitchen_with_gemini
)
from app.models import Product, User
from pydantic import BaseModel
from typing import List
from .auth import get_current_user

router = APIRouter(
    prefix="/products",
    tags=["Products"],
)

# --------------------------
# MODELLER
# --------------------------
class IngredientRequest(BaseModel):
    ingredients: List[str]

class ProductCreate(BaseModel):
    name: str
    category: str
    quantity: float
    price:float

class ProductUpdate(BaseModel):
    name: str
    category: str
    quantity: float
    price:float

class ProductResponse(BaseModel):
    id: int
    name: str
    category: str
    quantity: float
    price:float


    class Config:
        from_attributes = True

# --------------------------
# DATABASE SESSION
# --------------------------

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --------------------------
# READ - Giriş Yapan Kullanıcının Ürünlerini Listele
# --------------------------

@router.get("/", response_model=List[ProductResponse])
def read_my_products(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    products = get_products(db, current_user["id"], skip=skip, limit=limit)
    return products

# --------------------------
# CREATE - Yeni Ürün Ekle
# --------------------------

@router.post("/", response_model=ProductResponse)
def create_new_product(product: ProductCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    db_product = create_product(db, current_user["id"], product.name, product.category, product.quantity,product.price)
    return db_product

# --------------------------
# UPDATE - Ürün Güncelle
# --------------------------

@router.put("/{product_id}", response_model=ProductResponse)
def update_existing_product(product_id: int, product: ProductUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    db_product = update_product(db, current_user["id"], product_id, product.name, product.category, product.quantity,product.price)
    if not db_product:
        raise HTTPException(status_code=404, detail="Product not found")
    return db_product

# --------------------------
# DELETE - Ürün Sil
# --------------------------

@router.delete("/{product_id}", response_model=ProductResponse)
def delete_existing_product(product_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    db_product = delete_product(db, current_user["id"], product_id)
    if not db_product:
        raise HTTPException(status_code=404, detail="Product not found")
    return db_product


# --------------------------
# AI - Tarif Önerisi (Malzemeye Göre)
# --------------------------
@router.post("/ai/suggest-recipes")
def suggest_recipes(request: IngredientRequest):
    if not request.ingredients:
        raise HTTPException(status_code=400, detail="Malzeme listesi boş olamaz.")

    try:
        results = suggest_recipes_by_ingredients(request.ingredients)
        return {"suggested_recipes": results}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Tarif önerilemedi: {str(e)}")

# --------------------------
# AI - Tarif Önerisi (Son Kullanma Tarihine Göre)
# --------------------------
@router.get("/ai/suggest-recipes-from-expired")
def suggest_recipes_from_expired_ingredients(db: Session = Depends(get_db)):
    try:
        five_days_ago = datetime.utcnow() - timedelta(days=5)

        expired_products = db.query(Product).filter(Product.date_added <= five_days_ago).all()

        if not expired_products:
            raise HTTPException(status_code=404, detail="5 günden eski ürün bulunamadı.")

        ingredients = [product.name for product in expired_products]

        results = suggest_recipes_by_ingredients(ingredients)
        return {
            "used_ingredients": ingredients,
            "suggested_recipes": results
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Tarif önerilemedi: {str(e)}")



# --------------------------
# AI - Vitamin Önerisi Al
# --------------------------
@router.get("/ai/suggest-products-from-kitchen")
def suggest_products_from_kitchen(
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):

    try:
        user_id = current_user["id"]
        suggestions = create_kitchen_with_gemini(db=db, user_id=user_id)
        return {
            "user_id": user_id,
            "suggestions": suggestions
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ürün önerisi oluşturulamadı: {str(e)}")