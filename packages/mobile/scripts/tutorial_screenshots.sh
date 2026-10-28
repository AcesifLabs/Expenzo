#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
device="${1:-emulator-5554}"

for theme in light dark; do
  adb -s "$device" uninstall com.acesiflabs.expenzo >/dev/null 2>&1 || true
  flutter drive -d "$device" \
    --driver test_driver/screenshot_driver.dart \
    --target screenshots/tutorial_screenshots_test.dart \
    --dart-define=THEME="$theme"
done
