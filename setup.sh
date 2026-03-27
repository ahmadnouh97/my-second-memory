#!/usr/bin/env bash
# Second Memory — First-time setup script
set -e

echo "=== Second Memory Setup ==="

# 1. Copy .env
if [ ! -f .env ]; then
  cp .env.example .env
  echo "[!] Created .env — add your GROQ_API_KEY before starting."
fi

# 2. Build and start backend
echo "[1/3] Starting Docker services..."
docker compose up -d --build

echo "[2/3] Running database migrations..."
docker compose exec backend uv run alembic upgrade head

echo "[3/3] Backend ready at http://localhost:8001"
echo "      API docs at http://localhost:8001/docs"

echo ""
echo "=== Frontend setup ==="
echo "Run the following to set up the Ionic frontend:"
echo ""
echo "  cd frontend"
echo "  npm install"
echo "  npx ionic serve          # Web"
echo ""
echo "=== Android setup ==="
echo ""
echo "  cd frontend"
echo "  npm install"
echo "  npx cap add android"
echo "  npx cap sync"
echo "  # Then apply the intent filter patch from android-manifest-patch.xml"
echo "  npx cap open android     # Opens Android Studio"
