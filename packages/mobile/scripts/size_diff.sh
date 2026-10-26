#!/usr/bin/env bash




set -euo pipefail
cd "$(dirname "$0")/.."

bundle=build/app/outputs/bundle/release/app-release.aab
size=$(stat -c %s "$bundle")

if [ "${1:-}" = "--update" ]; then
  printf '{"aab_bytes": %s}\n' "$size" > size_baseline.json
  echo "Baseline set to $size bytes."
  exit 0
fi

baseline=$(grep -o '[0-9]\+' size_baseline.json)
growth=$((size - baseline))
echo "App bundle: $size bytes (baseline $baseline, change $growth)."
if [ "$growth" -gt 1048576 ] || [ $((growth * 100)) -gt $((baseline * 5)) ]; then
  echo "::error::The app bundle grew by $growth bytes, over 5% or 1 MB."
  exit 1
fi
