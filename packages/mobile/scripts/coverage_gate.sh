#!/usr/bin/env bash




set -euo pipefail
cd "$(dirname "$0")/.."

info=coverage/lcov.info
if [ ! -f "$info" ]; then
  echo "No $info: run flutter test --coverage first." >&2
  exit 1
fi

read -r found hit < <(awk '
  /^SF:/ { skip = ($0 ~ /\.g\.dart$/ || $0 ~ /lib\/i18n\//) }
  /^LF:/ && !skip { split($0, a, ":"); lf += a[2] }
  /^LH:/ && !skip { split($0, a, ":"); lh += a[2] }
  END { print lf + 0, lh + 0 }' "$info")
percent=$(awk -v h="$hit" -v f="$found" 'BEGIN { printf "%.2f", f ? 100 * h / f : 0 }')
baseline=$(tr -d ' \n' < coverage_baseline.txt)

echo "Line coverage: ${percent}% (${hit}/${found} lines). Baseline: ${baseline}%."
if ! awk -v p="$percent" -v b="$baseline" 'BEGIN { exit !(p + 0 >= b + 0) }'; then
  echo "::error::Line coverage ${percent}% is below the baseline ${baseline}%."
  exit 1
fi
