import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.config import settings
from app.errors import ERROR_TYPE_RATE_LIMIT, RateLimitError
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


@app.exception_handler(RateLimitError)
async def rate_limit_handler(request: Request, exc: RateLimitError) -> JSONResponse:
    logger.warning("Rate limit hit: service=%s retry_after=%s", exc.service, exc.retry_after)
    headers = {"Retry-After": str(exc.retry_after)} if exc.retry_after is not None else {}
    return JSONResponse(
        status_code=429,
        content={
            "error_type": ERROR_TYPE_RATE_LIMIT,
            "service": exc.service,
            "retry_after": exc.retry_after,
            "message": exc.message,
        },
        headers=headers,
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
