#!/usr/bin/env bash
set -euo pipefail

echo "Building image..."
docker compose build

echo "Restarting container..."
docker compose up -d --force-recreate

echo "Waiting for health check..."
sleep 5

if docker compose ps | grep -q "healthy\|running"; then
  echo "Deploy successful!"
  docker compose logs --tail=20
else
  echo "Container may not be healthy, checking logs..."
  docker compose logs --tail=50
  exit 1
fi
