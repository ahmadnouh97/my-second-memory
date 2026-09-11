#!/usr/bin/env bash
# Second Memory — First-time setup script
set -euo pipefail

echo "=== Second Memory Setup ==="

# 1. Copy .env
if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env. Set GROQ_API_KEY, GOOGLE_API_KEY, JWT_SECRET, and REGISTRATION_ALLOWED_EMAILS."
  echo "Then run this script again."
  exit 0
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
echo "Run the following to start the Flutter frontend:"
echo ""
echo "  cd frontend"
echo "  flutter pub get"
echo "  flutter run -d chrome --web-port=4200"
echo "  # For an allowlisted email, register at http://localhost:4200/#/register"
echo ""
echo "=== Android setup ==="
echo ""
echo "  cd frontend"
echo "  flutter run --dart-define=BACKEND_URL=http://10.0.2.2:8001"
