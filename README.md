# Second Memory

A personal content curation app that saves, organizes, and lets you query everything interesting you find online — YouTube videos, Instagram reels, LinkedIn posts, GitHub repos, Facebook posts, TikTok videos, Reddit threads, or any URL.

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
| Embeddings | Google AI Studio — Gemini `gemini-embedding-001` (768-dim, API) |
| LLM | Groq API — qwen/qwen3-32b via LangChain |
| Frontend | Flutter 3.41 + Riverpod + go_router (Android + Web) |

## Quick Start

### 1. Configure environment

```bash
cp .env.example .env
# Edit .env and set:
#   GROQ_API_KEY=your_groq_key_here
#   GOOGLE_API_KEY=your_google_ai_studio_key_here
```

### 2. Start the backend

```bash
docker compose up -d --build
docker compose exec backend uv run alembic upgrade head

# First time only: re-embed any existing items with the new model
docker compose exec backend uv run python scripts/reembed_all.py
```

API available at `http://localhost:8000`
Swagger docs at `http://localhost:8000/docs`

### 3. Run the web frontend

```bash
cd frontend
flutter run -d chrome --web-port=4200
```

App available at `http://localhost:4200`

### 4. Android setup

```bash
cd frontend
flutter run                  # Connected device or emulator

# Build release APK
flutter build apk --release
```

> **Android API URL**: The Android app points to `http://10.0.2.2:8000` (emulator localhost).
> For a real device on the same network, set `BACKEND_URL` at build time:
> ```bash
> flutter build apk --dart-define=BACKEND_URL=http://192.168.1.x:8000
> ```

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
└── frontend/                 # Flutter app
    ├── lib/
    │   ├── main.dart
    │   ├── config/           # environment.dart, router.dart
    │   ├── models/           # Item, ChatMessage (Freezed)
    │   ├── services/         # api_service.dart, share_service.dart
    │   ├── providers/        # Riverpod: items_provider, chat_provider
    │   ├── theme/            # app_theme.dart (Material 3 dark)
    │   ├── widgets/          # item_card, filter_bar, chat_item_card, …
    │   └── pages/            # home, add_item, item_detail, chat
    ├── assets/
    │   └── logo.svg          # App logo (also used as launcher icon)
    └── android/
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
| GET | `/api/proxy/image?url=...` | Image proxy (bypasses CDN CORS on web) |

## Frontend Development

```bash
cd frontend

# Run on web (Chrome)
flutter run -d chrome

# Run on Android emulator / connected device
flutter run

# Build release APK
flutter build apk --release

# Regenerate Freezed / JSON models after editing model files
dart run build_runner build --delete-conflicting-outputs

# Regenerate app icons after changing assets/logo.svg
dart run flutter_launcher_icons
```

## Debugging the Backend in Docker

A `docker-compose-debug.yml` override enables `debugpy` remote debugging on port `5678`.

### Start in debug mode

```bash
docker compose -f docker-compose.yml -f docker-compose-debug.yml up -d --build
```

The backend starts normally and serves requests immediately. Attach the debugger at any time.

### Attach from VS Code

Add to `.vscode/launch.json`:

```json
{
  "name": "Docker: Remote Attach",
  "type": "debugpy",
  "request": "attach",
  "connect": { "host": "localhost", "port": 5678 },
  "pathMappings": [{ "localRoot": "${workspaceFolder}/backend", "remoteRoot": "/app" }]
}
```

Then press **F5** (or Run → Start Debugging) with the `Docker: Remote Attach` config selected.

### Attach from PyCharm

Run → Edit Configurations → **+** → Python Remote Debug → host `localhost`, port `5678`, path mapping: local `<project>/backend` → remote `/app` → OK → click the debug button.

> **Note:** Hot-reload (`--reload`) is disabled in debug mode. Uvicorn's reloader forks child processes and `debugpy` only attaches to the parent, making breakpoints unreliable. Restart the container to pick up code changes.

## Changing the LLM

The backend uses LangChain. To switch from Groq to another provider:

1. Install the provider's LangChain package (e.g., `langchain-openai`)
2. Update `app/services/ai_service.py` and `app/routers/chat.py` to use the new LLM class
3. Update `.env` with the new API key

No other changes needed — the rest of the app is provider-agnostic.
