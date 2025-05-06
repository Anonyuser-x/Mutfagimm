from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import auth, products

# Uygulama oluşturuluyor
app = FastAPI()

# CORS middleware'i ekleniyor
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Tüm domainlerden erişime izin veriyor
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Rotaları bağlamak
app.include_router(auth.router)
app.include_router(products.router)

# Ana sayfa rotası
@app.get("/")
def read_root():
    return {"message": "Merhaba, KitchenAI API'ye hoş geldiniz!"}
