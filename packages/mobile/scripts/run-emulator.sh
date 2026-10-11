#!/usr/bin/env bash
set -euo pipefail

AVD="${1:-kadipay_pixel}"
EMULATOR="${ANDROID_HOME:-$HOME/Android/Sdk}/emulator/emulator"

adb kill-server && adb start-server && sleep 3

DEVICE=$(adb devices | awk '/^emulator-/{print $1; exit}')
if [ -z "$DEVICE" ]; then
  "$EMULATOR" -avd "$AVD" -no-snapshot-load >/dev/null 2>&1 &
  adb wait-for-device
  DEVICE=$(adb devices | awk '/^emulator-/{print $1; exit}')
fi

until [ "$(adb -s "$DEVICE" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do
  sleep 2
done

adb -s "$DEVICE" reverse tcp:3000 tcp:3000 && flutter clean && flutter run -d "$DEVICE"
