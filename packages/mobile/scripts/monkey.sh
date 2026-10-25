#!/usr/bin/env bash
# Random taps and swipes on an installed build; fails on a crash or ANR.
# Usage: scripts/monkey.sh <device> [events]
set -euo pipefail

device="${1:?pass the device serial, e.g. emulator-5554}"
events="${2:-10000}"
package=com.acesiflabs.expenzo
log=build/monkey-logcat.txt
mkdir -p build

adb -s "$device" logcat -c
# A crash ends the monkey run early with a non-zero exit; logcat says why.
# No system keys: they open screenshots and settings, whose crashes aren't
# ours. Other apps' crashes don't stop the run.
adb -s "$device" shell monkey -p "$package" --pct-syskeys 0 --ignore-crashes \
  --throttle 100 -s 42 -v "$events" > build/monkey.txt 2>&1 || true
adb -s "$device" logcat -d > "$log"

# A crash counts only in this app's process; logcat names it on the line
# after FATAL EXCEPTION.
if grep -A1 "FATAL EXCEPTION" "$log" | grep -q "Process: $package" ||
  grep -q "ANR in $package" "$log"; then
  echo "::error::The monkey run crashed or froze the app (see $log)."
  exit 1
fi
echo "No crash or ANR in $events monkey events."
