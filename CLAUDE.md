# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

**Second Memory** — a personal, single-user content curation app. Save any URL (YouTube, Instagram, articles, links), get AI-generated title/summary/tags, search with hybrid semantic+full-text search, and query your collection via an AI chat assistant. Fully self-hosted via Docker Compose.

## Commands

### Backend

```bash
# Start all services (first time: builds image, ~5 min for sentence-transformers)
docker compose up -d --build

# Run DB migrations (required after first build or new migration)
docker compose exec backend uv run alembic upgrade head

# View backend logs
docker compose logs -f backend

# Stop everything
docker compose down

# Run a command inside the backend container
docker compose exec backend uv run <command>

# Create a new Alembic migration
docker compose exec backend uv run alembic revision --autogenerate -m "description"
```

### Frontend

```bash
cd frontend
npm install
npx ionic serve          # Web dev server at http://localhost:8100

# Android
npx cap add android      # First time only
npx cap sync             # After any frontend build
npx cap open android     # Open Android Studio
```

### Local backend development (without Docker)

```bash
cd backend
uv sync                  # Creates .venv at /opt/venv or local .venv
uv run uvicorn app.main:app --reload
uv run alembic upgrade head
```

## Architecture

### Overview

```
docker-compose.yml
├── db      pgvector/pgvector:pg16 (PostgreSQL + pgvector + pg_trgm)
└── backend Python 3.12 FastAPI app
```

The frontend is a separate Ionic Angular standalone app (not containerised in dev) that talks to the backend over HTTP. On Android, Capacitor wraps it as a native app.

### Backend (`backend/app/`)

Layered architecture: **Router → Service → Repository → DB**

| Layer | Location | Responsibility |
|---|---|---|
| Routers | `routers/items.py`, `routers/chat.py` | HTTP endpoints, request/response validation |
| Services | `services/` | Business logic — extraction, AI, embeddings, search |
| Repository | `repositories/item_repository.py` | All DB access (SQLAlchemy async) |
| Models | `models/item.py` | SQLAlchemy ORM (`Item` table) |
| Schemas | `schemas/item.py` | Pydantic request/response models |

**Key services:**
- `metadata_extractor.py` — detects URL type (YouTube/Instagram/article/link), extracts raw metadata using `yt-dlp` (YouTube/Instagram), `trafilatura` (articles), or `BeautifulSoup4` (OpenGraph fallback)
- `ai_service.py` — LangChain + Groq (`qwen/qwen3-32b`) with `.with_structured_output()` to generate refined title, 2–3 sentence summary, and 5–8 tags from raw metadata
- `embedding_service.py` — singleton wrapping `sentence-transformers/all-MiniLM-L6-v2` (384-dim, loaded at startup via `lifespan` in `main.py`)
- `search_service.py` — Reciprocal Rank Fusion (RRF, k=60) combining pgvector cosine similarity and PostgreSQL `tsvector` full-text search

**AI chat** (`routers/chat.py`): LangGraph `create_react_agent` with two tools (`search_items_tool`, `list_items_tool`) streamed over SSE. The agent appends `ITEMS_JSON: [...]` at the end of its response; the frontend strips this and renders item widgets.

**Save flow:** `POST /api/items/extract` (preview only, not saved) → user edits → `POST /api/items` (saves + generates embedding).

### Database schema

Single table `items` with:
- `embedding VECTOR(384)` — ivfflat cosine index
- `fts_vector TSVECTOR` — generated always from `title + summary + content`, GIN index
- `tags TEXT[]` — GIN index, queried with `.overlap()`
- `updated_at` auto-updated via a PostgreSQL trigger

### Frontend (`frontend/src/app/`)

Ionic 8 + Angular 17 **standalone components** (no NgModules). Routes lazy-load each page.

- `app.config.ts` — bootstraps `IonicRouteStrategy`, `HttpClient`, `Router`
- `app.component.ts` — calls `ShareService.checkIncomingShare()` on init (Android share intent)
- `services/api.service.ts` — all HTTP calls + `chatStreamFetch()` async generator for SSE
- `services/share.service.ts` — reads incoming Android share intent via `send-intent` plugin, navigates to `/add-item?url=...`
- Chat SSE is consumed with `fetch` + `ReadableStream` (not `EventSource`) since the endpoint requires a POST body

### Key configuration

- `UV_PROJECT_ENVIRONMENT=/opt/venv` — venv lives outside `/app` so the dev volume mount (`./backend:/app`) doesn't clobber it
- `UV_LINK_MODE=copy` — required on Docker Desktop (different filesystems)
- `backend/.dockerignore` excludes `.venv/` — critical, a Linux `.venv` left in `backend/` will break the Windows Docker build context
- Android emulator uses `http://10.0.2.2:8000`; real device needs the host machine's LAN IP in `environment.prod.ts`

### Adding a new LLM provider

Replace `ChatGroq(...)` in `services/ai_service.py` and `routers/chat.py` with any LangChain chat model. No other changes needed.
