import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.routers import auth, chat, items, proxy, tags
from app.services.embedding_service import embedding_service

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    embedding_service.warmup()
    allowed = settings.allowed_emails_list
    if not allowed:
        logger.warning("REGISTRATION_ALLOWED_EMAILS is unset — all new registrations are blocked")
    else:
        logger.info("Registration whitelist: %d pattern(s) configured", len(allowed))
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

app.include_router(auth.router, prefix="/api/auth", tags=["auth"])
app.include_router(items.router, prefix="/api/items", tags=["items"])
app.include_router(chat.router, prefix="/api/chat", tags=["chat"])
app.include_router(proxy.router, prefix="/api/proxy", tags=["proxy"])
app.include_router(tags.router, prefix="/api/tags", tags=["tags"])


@app.get("/health")
async def health():
    return {"status": "ok"}
