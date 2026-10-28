#!/usr/bin/env bash


set -euo pipefail

device="${1:?pass the device serial, e.g. emulator-5554}"
events="${2:-10000}"
package=com.acesiflabs.expenzo
log=build/monkey-logcat.txt
mkdir -p build

adb -s "$device" logcat -c



adb -s "$device" shell monkey -p "$package" --pct-syskeys 0 --ignore-crashes \
  --throttle 100 -s 42 -v "$events" > build/monkey.txt 2>&1 || true
adb -s "$device" logcat -d > "$log"



if grep -A1 "FATAL EXCEPTION" "$log" | grep -q "Process: $package" ||
  grep -q "ANR in $package" "$log"; then
  echo "::error::The monkey run crashed or froze the app (see $log)."
  exit 1
fi
echo "No crash or ANR in $events monkey events."
