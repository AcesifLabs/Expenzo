#!/usr/bin/env bash



set -euo pipefail

device="${1:?pass the device serial, e.g. emulator-5554}"
limit="${2:-1500}"
package=com.acesiflabs.expenzo

times=()
for _ in $(seq 10); do
  adb -s "$device" shell am force-stop "$package"
  total=$(adb -s "$device" shell am start -W -n "$package/.MainActivity" \
    | awk -F': ' '/TotalTime/ { print $2 }' | tr -d '\r')
  times+=("$total")
  sleep 2
done

median=$(printf '%s\n' "${times[@]}" | sort -n | awk '{ a[NR] = $1 } END { print a[int((NR + 1) / 2)] }')
echo "Cold start median: ${median} ms (runs: ${times[*]})"
if [ "$median" -gt "$limit" ]; then
  echo "::warning::Cold start median ${median} ms is over ${limit} ms."
fi
