# Second Memory

A personal content curation app that saves, organizes, and lets you query everything interesting you find online — YouTube videos, Instagram reels, articles, blogs, or any URL.

## Features

- **Smart saving**: Paste or share any URL → AI extracts title, generates summary + tags
- **Android share intent**: Share directly from any Android app
- **Hybrid search**: Semantic (vector) + full-text search combined with RRF
- **Filter**: By tags, content type, and date
- **AI assistant**: Ask natural language questions, get answers with clickable item widgets
- **Fully self-hosted**: Docker Compose, no external dependencies except Groq API

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Python 3.12 + FastAPI |
| Database | PostgreSQL 16 + pgvector |
| Embeddings | sentence-transformers (all-MiniLM-L6-v2, local) |
| LLM | Groq API — qwen/qwen3-32b via LangChain |
| Frontend | Ionic 8 + Angular 17 (Standalone) + Capacitor 6 |

## Quick Start

### 1. Configure environment

```bash
cp .env.example .env
# Edit .env and set GROQ_API_KEY=your_key_here
```

### 2. Start the backend

```bash
docker compose up -d --build
docker compose exec backend uv run alembic upgrade head
```

API available at `http://localhost:8000`
Swagger docs at `http://localhost:8000/docs`

### 3. Run the web frontend

```bash
npm install -g @ionic/cli   # one-time
cd frontend
npm install
npx ionic serve
```

App available at `http://localhost:8100`

### 4. Android setup

```bash
cd frontend
npm install
npx cap add android
npx cap sync

# Apply the share intent filter from android-manifest-patch.xml
# to android/app/src/main/AndroidManifest.xml

npx cap open android   # Opens Android Studio → Run on device/emulator
```

> **Android API URL**: The Android app points to `http://10.0.2.2:8000` (emulator localhost).
> For a real device on the same network, update `src/environments/environment.prod.ts`
> with your machine's local IP (e.g., `http://192.168.1.x:8000`).

## Project Structure

```
my-second-memory/
├── docker-compose.yml
├── .env.example
├── backend/
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── pyproject.toml
│   ├── alembic/              # DB migrations
│   └── app/
│       ├── main.py
│       ├── config.py
│       ├── database.py
│       ├── models/           # SQLAlchemy ORM
│       ├── schemas/          # Pydantic schemas
│       ├── repositories/     # Data access layer
│       ├── services/         # Business logic
│       │   ├── metadata_extractor.py
│       │   ├── ai_service.py
│       │   ├── embedding_service.py
│       │   └── search_service.py
│       └── routers/
│           ├── items.py      # CRUD + search
│           └── chat.py       # AI assistant (SSE)
└── frontend/
    ├── src/app/
    │   ├── pages/            # home, add-item, item-detail, chat
    │   ├── components/       # item-card, filter-bar, chat-item-widget
    │   ├── services/         # api.service.ts, share.service.ts
    │   └── models/           # TypeScript interfaces
    └── android-manifest-patch.xml
```

## API Reference

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/items/extract` | Extract + AI-enrich URL metadata (preview) |
| POST | `/api/items` | Save item |
| GET | `/api/items` | List with filters (tags, type, date, page) |
| GET | `/api/items/search?q=...` | Hybrid search |
| GET | `/api/items/{id}` | Get single item |
| PUT | `/api/items/{id}` | Update item |
| DELETE | `/api/items/{id}` | Delete item |
| POST | `/api/chat` | AI assistant (SSE streaming) |

## Changing the LLM

The backend uses LangChain. To switch from Groq to another provider:

1. Install the provider's LangChain package (e.g., `langchain-openai`)
2. Update `app/services/ai_service.py` and `app/routers/chat.py` to use the new LLM class
3. Update `.env` with the new API key

No other changes needed — the rest of the app is provider-agnostic.
