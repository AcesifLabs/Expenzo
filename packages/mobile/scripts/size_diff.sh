#!/usr/bin/env bash
# Compares the arm64 app bundle size with size_baseline.json; fails on growth
# over 5% or 1 MB. Run after:
#   flutter build appbundle --analyze-size --target-platform android-arm64
# Write a new baseline with: scripts/size_diff.sh --update
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
