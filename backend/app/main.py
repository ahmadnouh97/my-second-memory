from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.routers import chat, items, proxy
from app.services.embedding_service import embedding_service


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Warm up the embedding model on startup
    embedding_service.warmup()
    yield


app = FastAPI(
    title="Second Memory API",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(items.router, prefix="/api/items", tags=["items"])
app.include_router(chat.router, prefix="/api/chat", tags=["chat"])
app.include_router(proxy.router, prefix="/api/proxy", tags=["proxy"])


@app.get("/health")
async def health():
    return {"status": "ok"}
