# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

**Second Memory** — a personal, single-user content curation app. Save any URL (YouTube, Instagram, articles, links), get AI-generated title/summary/tags, search with hybrid semantic+full-text search, and query your collection via an AI chat assistant. Fully self-hosted via Docker Compose.

## Commands

### Backend

```bash
# Start all services (first build is fast — no local model download)
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

### Frontend (Flutter)

```bash
cd frontend

# Run on web (Chrome) — always on port 4200
flutter run -d chrome --web-port=4200

# Run on Android emulator / connected device
flutter run

# Build APK
flutter build apk --release

# Regenerate Freezed / JSON models after editing model files
dart run build_runner build --delete-conflicting-outputs

# Install / update dependencies
flutter pub get
flutter pub upgrade
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

The frontend is a Flutter app (not containerised in dev) that talks to the backend over HTTP. It targets Android (native) and web (Chrome). No Ionic/Angular — replaced with Flutter + Riverpod + go_router.

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
- `metadata_extractor.py` — detects URL type (YouTube/Instagram/LinkedIn/GitHub/Facebook/TikTok/Reddit/other), extracts raw metadata using `yt-dlp` (YouTube/Instagram/TikTok), or `BeautifulSoup4` (OpenGraph fallback for all others)
- `ai_service.py` — LangChain + Groq (`qwen/qwen3-32b`) with `.with_structured_output()` to generate refined title, 2–3 sentence summary, and 5–8 tags from raw metadata. At extract time, receives the current distinct tag list from the DB and includes it in the prompt so the LLM reuses existing tags where they fit.
- `embedding_service.py` — singleton using Google AI Studio (`gemini-embedding-001`, 768-dim). `warmup()` is called in `lifespan` to validate the API key at startup. `encode()` uses `RETRIEVAL_QUERY` task type; `encode_for_item()` uses `RETRIEVAL_DOCUMENT`.
- `search_service.py` — Reciprocal Rank Fusion (RRF, k=60) combining pgvector cosine similarity and PostgreSQL `tsvector` full-text search
- `export_service.py` — exports all items as JSON or CSV (`StreamingResponse` with attachment header)
- `import_service.py` — imports items from JSON or CSV; skips duplicates by URL; returns `ImportResult` with counts and errors

**AI chat** (`routers/chat.py`): LangGraph `create_react_agent` with two tools (`search_items_tool`, `list_items_tool`) streamed over SSE. The agent appends `ITEMS_JSON: [...]` at the end of its response; the frontend strips this and renders item widgets.

**Save flow:** `POST /api/items/extract` (fetches existing tags, passes to AI for context, returns preview — not saved) → user edits → `POST /api/items` (saves + generates embedding).

**Tag management** (`routers/tags.py`): `GET /api/tags` lists all tags with counts. `PATCH /api/tags/{tag}` renames a tag across all items via `array_replace`. `DELETE /api/tags/{tag}` removes a tag from all items via `array_remove`.

**Import/Export** (`routers/items.py`): `GET /api/items/export?format=json|csv` streams all items as a file download. `POST /api/items/import` accepts a JSON or CSV file, skips duplicate URLs, returns counts. `DELETE /api/items` bulk-deletes all items.

### Database schema

One table:

`items` with:
- `embedding VECTOR(768)` — ivfflat cosine index
- `fts_vector TSVECTOR` — generated always from `title + summary + content`, GIN index
- `tags TEXT[]` — GIN index, queried with `.overlap()`
- `updated_at` auto-updated via a PostgreSQL trigger

### Frontend (`frontend/lib/`)

Flutter + Riverpod + go_router + Material 3. Targets Android (native) and web (Chrome, port 4200).

- `main.dart` — app entry point, sets up `ProviderScope` and `GoRouter`
- `config/environment.dart` — resolves `baseUrl` (`localhost:8001` on web, `10.0.2.2:8001` on Android emulator)
- `config/router.dart` — go_router route definitions
- `services/api_service.dart` — all HTTP calls; `chatStream()` async generator consumes SSE via `fetch` + `ReadableStream`
- `services/share_service.dart` — reads incoming Android share intent, navigates to `/add-item?url=...`
- `providers/` — Riverpod providers: `items_provider.dart`, `chat_provider.dart`, `tags_provider.dart`
- `utils/image_utils.dart` — `proxyImageUrl()`: routes CDN image URLs through `/api/proxy/image` on web (CORS fix); no-op on Android
- `utils/download_utils.dart` — platform-aware file download (`_web.dart` triggers browser download, `_io.dart` saves to device, `_stub.dart` no-op)
- Chat SSE: the agent appends `ITEMS_JSON: [...]`; the frontend strips it and renders item widgets
- Tags page at `/tags` — searchable list of all tags with usage counts; inline Rename dialog and Delete confirmation; after rename/delete, `itemsProvider` is reset and reloaded via `resetAndReload()`

### Key configuration

- `UV_PROJECT_ENVIRONMENT=/opt/venv` — venv lives outside `/app` so the dev volume mount (`./backend:/app`) doesn't clobber it
- `UV_LINK_MODE=copy` — required on Docker Desktop (different filesystems)
- `backend/.dockerignore` excludes `.venv/` — critical, a Linux `.venv` left in `backend/` will break the Windows Docker build context
- Android emulator uses `http://10.0.2.2:8001`; real device needs the host machine's LAN IP passed via `--dart-define=BACKEND_URL=http://192.168.x.x:8001`
- `REGISTRATION_ALLOWED_EMAILS` — comma-separated list of allowed emails/patterns for registration. Supports exact emails (`alice@example.com`), domain wildcards (`*@company.com`), or `*` to allow all. Empty/unset = **no one can register** (fail-closed). Precedence: `REGISTRATION_ENABLED=false` > whitelist. The Flutter login page hides the "Create an account" button when registration is not open.

### Adding a new LLM provider

Replace `ChatGroq(...)` in `services/ai_service.py` and `routers/chat.py` with any LangChain chat model. No other changes needed.
