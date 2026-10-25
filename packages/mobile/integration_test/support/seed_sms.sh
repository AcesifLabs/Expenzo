#!/usr/bin/env bash
# Puts bank messages in an emulator's inbox for integration_test/sms_scan_test.dart.
# Usage: integration_test/support/seed_sms.sh emulator-5560
set -euo pipefail

device="${1:?pass the emulator serial, e.g. emulator-5560}"
case "$device" in
  emulator-*) ;;
  *) echo "Only emulators: adb emu sms needs one." >&2; exit 1 ;;
esac

send() { adb -s "$device" emu sms send 16216 "$1" > /dev/null; }

send "Tk 1,250.00 debited from A/C XX1234 at Shwapno on 05-Oct-2026. Avl Bal Tk 12,340.00"
send "Tk 480.50 debited from A/C XX1234 for Pathao Food. Avl Bal Tk 11,859.50"
echo "Seeded 2 messages on $device"
