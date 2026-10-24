#!/usr/bin/env bash
# Starts local dev services (Postgres), applies migrations, and runs the backend in watch mode.
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  echo "Missing packages/backend/.env" >&2
  exit 1
fi

[ -d node_modules ] || npm install

echo "Starting dev services..."
docker compose -f docker-compose.dev.yml up -d --wait

echo "Running migrations..."
npm run migration:run

# Lets a connected device or emulator reach the backend at localhost:3000
if command -v adb >/dev/null && adb get-state >/dev/null 2>&1; then
  adb reverse tcp:3000 tcp:3000
else
  echo "No Android device connected, skipping adb reverse"
fi

npm run start:dev
