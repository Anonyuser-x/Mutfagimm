from dotenv import load_dotenv
from sqlalchemy.orm import Session
from app.models import Product
from datetime import datetime
import os
import re
import pandas as pd
import pickle
from keras._tf_keras.keras.models import load_model
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import google.generativeai as genai
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import HumanMessage
import markdown
from bs4 import BeautifulSoup

# ------------------------
# CREATE - Ürün Oluşturma
# ------------------------

def create_product(db: Session, user_id: int, name: str, category: str, quantity: float,price: float):
    db_product = Product(
        name=name,
        category=category,
        quantity=quantity,
        price=price,
        user_id=user_id,
        date_added=datetime.today().date()
    )
    db.add(db_product)
    db.commit()
    db.refresh(db_product)
    return db_product


# ------------------------
# READ - Kullanıcının Ürünlerini Listeleme
# ------------------------

def get_products(db: Session, user_id: int, skip: int = 0, limit: int = 100):
    return db.query(Product).filter(Product.user_id == user_id).offset(skip).limit(limit).all()

def get_product_by_id(db: Session, user_id: int, product_id: int):
    return db.query(Product).filter(Product.id == product_id, Product.user_id == user_id).first()


# ------------------------
# UPDATE - Ürün Güncelleme
# ------------------------

def update_product(db: Session, user_id: int, product_id: int, name: str, category: str, quantity: float,price: float):
    db_product = db.query(Product).filter(Product.id == product_id, Product.user_id == user_id).first()
    if db_product:
        db_product.name = name
        db_product.category = category
        db_product.quantity = quantity
        db_product.price = price
        db.commit()
        db.refresh(db_product)
        return db_product
    return None


# ------------------------
# DELETE - Ürün Silme
# ------------------------

def delete_product(db: Session, user_id: int, product_id: int):
    db_product = db.query(Product).filter(Product.id == product_id, Product.user_id == user_id).first()
    if db_product:
        db.delete(db_product)
        db.commit()
        return db_product
    return None


# ------------------------
# AI - Seçilen Ürünlere Göre Tarif Önerisi
# ------------------------

# --- Yardımcı fonksiyonlar ---
def turkish_lower(text):
    return text.lower().replace("I", "ı").replace("İ", "i")

def normalize_turkish_chars(text):
    tr_map = str.maketrans("çğıöşü", "cgiosu")
    return text.translate(tr_map)

def parse_ingredients(ingredient_str):
    raw_ingredients = re.split(r"[,\n]", ingredient_str)
    ingredients = []

    for item in raw_ingredients:
        item = turkish_lower(item)
        item = re.sub(r"(\d+[\.,]?\d*|\d+/\d+|½|¼|¾)\s*", "", item)
        item = re.sub(
            r"\b(adet|kaşık|tatlı kaşığı|yemek kaşığı|çay kaşığı|fincan|su bardağı|bardağı|bardak|gram|gr|kg|kilogram|"
            r"tane|paket|çimdik|tutam|dal|diş|kutu|lt|litre|ml|mililitre|bağ|demet|orta boy|küçük boy|büyük boy)\b",
            "",
            item
        )
        item = re.sub(
            r"\b(biraz|az|yeteri kadar|bir miktar|göz kararı|isteğe bağlı|arzuya göre|gerektiği kadar)\b",
            "",
            item
        )
        item = re.sub(r"[^\w\sçğıöşü]", "", item)
        item = item.strip()
        if item:
            ingredients.append(item)
    return ingredients

def suggest_recipes_by_ingredients(user_ingredients: list[str], top_n: int = 5):
    recipes = pd.read_csv("turkish_food_recipes.csv", sep=";")
    recipes["parsed_ingredients"] = recipes["ingredients"].apply(parse_ingredients)

    with open("vocab.pkl", "rb") as f:
        vocabulary = pickle.load(f)
    vectorizer = CountVectorizer(vocabulary=vocabulary)
    encoder = load_model("encoder_model.h5")

    all_ingredient_texts = [" ".join(ings) for ings in recipes["parsed_ingredients"]]
    X = vectorizer.transform(all_ingredient_texts).toarray().astype("float32")
    recipe_embeddings = encoder.predict(X)

    user_ingredients_cleaned = [
        turkish_lower(re.sub(r"[^\w\sçğıöşü]", "", ing)).strip() for ing in user_ingredients
    ]
    user_text = " ".join(user_ingredients_cleaned)
    user_vector = vectorizer.transform([user_text]).toarray().astype("float32")
    user_embedding = encoder.predict(user_vector)

    similarities = cosine_similarity(user_embedding, recipe_embeddings)[0]
    recipes["similarity"] = similarities

    top_matches = recipes.sort_values(by="similarity", ascending=False).head(top_n)

    return top_matches[["title", "similarity", "parsed_ingredients", "instructions"]].to_dict(orient="records")



# ------------------------
# AI - Vitamin Önerisi
# ------------------------
def markdown_to_text(markdown_string):
    html = markdown.markdown(markdown_string)
    soup = BeautifulSoup(html, "html.parser")
    return soup.get_text()


def get_kitchen_products_from_db(db: Session, user_id: int):
    products = db.query(Product).filter(Product.user_id == user_id).all()
    return [product.name for product in products]


def create_kitchen_with_gemini(db: Session, user_id: int):
    load_dotenv()

    genai.configure(api_key=os.environ.get('GOOGLE_API_KEY'))

    llm = ChatGoogleGenerativeAI(model="gemini-2.0-flash")

    kitchen_products = get_kitchen_products_from_db(db, user_id)

    if not kitchen_products:
        return "Kullanıcının sisteme eklediği ürün bulunamadı."

    kitchen_string = "Kullanıcının haftalık olarak tükettiği mutfak ürünleri şunlardır:\n\n" + "\n".join(
        f"- {item}" for item in kitchen_products)

    prompt = (
        "Aşağıda kullanıcıya ait mutfak ürünleri yer almaktadır. "
        "Bu ürünlerin içerdiği vitamin ve mineralleri değerlendirerek haftalık eksiklikleri analiz et. "
        "Eksik kalan besin öğelerini tamamlayacak, sağlıklı ve çeşitli ürün önerileri oluştur. "
        "Önerilerin kullanıcı alışkanlıklarına ve dengeli beslenmeye uygun olmalıdır."
    )

    response = llm.invoke([
        HumanMessage(content=prompt),
        HumanMessage(content=kitchen_string),
    ])

    return markdown_to_text(response.content)