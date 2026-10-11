#!/usr/bin/env bash
# Inject dummy bank/payment SMS into a running Android emulator.
# Groups of messages share the same format; group sizes are random and sum to TOTAL.
#
# Usage:
#   ./scripts/simulate-sms.sh              # 50 messages, auto-detect emulator
#   ./scripts/simulate-sms.sh 30           # custom count
#   ./scripts/simulate-sms.sh 50 emulator-5554
#   DELAY_MS=200 ./scripts/simulate-sms.sh
set -euo pipefail

TOTAL="${1:-50}"
DEVICE="${2:-}"
DELAY_MS="${DELAY_MS:-150}"
MIN_GROUP="${MIN_GROUP:-2}"
MAX_GROUP="${MAX_GROUP:-8}"

if ! [[ "$TOTAL" =~ ^[0-9]+$ ]] || [ "$TOTAL" -lt 1 ]; then
  echo "usage: $0 [total] [device-serial]" >&2
  exit 1
fi

if [ -z "$DEVICE" ]; then
  DEVICE=$(adb devices | awk '/^emulator-/{print $1; exit}')
fi
if [ -z "$DEVICE" ]; then
  echo "no emulator found; start one with ./scripts/run-emulator.sh first" >&2
  exit 1
fi

# Each format: sender|body template with placeholders:
#   {amt} {bal} {acct} {merchant} {ref} {date}
FORMATS=(
  'VX-HDFCBK|HDFC Bank: Rs.{amt} debited from A/c **{acct} on {date} to {merchant}. Avl Bal: Rs.{bal}. Not you? Call 1800111222'
  'VM-ICICIB|ICICI Bank Acct XX{acct} debited for Rs {amt} on {date}; {merchant}. Available Balance: INR {bal}. Ref {ref}'
  'VK-SBIUPI|SBI: Rs.{amt} spent on UPI/{merchant}/{ref} from A/c XX{acct} on {date}. Avl bal Rs.{bal}'
  'AD-PHONEPE|Paid Rs.{amt} to {merchant} via PhonePe UPI. UPI Ref: {ref}. On {date}. Debited from XX{acct}'
  'AX-GPAY|Google Pay: You paid ₹{amt} to {merchant}. UPI transaction ID: {ref}. {date}'
  'JX-AMAZON|Amazon: Order for Rs.{amt} confirmed. Delivery by {date}. Order ID {ref}. Pay via Amazon Pay later'
  'AD-PAYTMB|Paytm: Rs.{amt} paid to {merchant} on {date}. Order ID {ref}. From wallet linked to XX{acct}'
  'BK-AXISBK|Axis Bank: INR {amt} withdrawn at {merchant} ATM from A/c XX{acct} on {date}. Available bal INR {bal}'
  'BX-KOTAKB|Kotak: Rs.{amt} credited to A/c XX{acct} on {date} from {merchant}. Avl Bal Rs.{bal}. Ref:{ref}'
  'VM-ENBD|Dear Customer, AED {amt} was debited from your account ****{acct} at {merchant}. Avl Bal AED {bal}'
  'VK-FABUAE|Trx. of AED {amt} on your a/c ****{acct} at {merchant}. Avl Bal is AED {bal}'
  'AD-BHIMUP|BHIM UPI: Rs.{amt} sent to {merchant}@{ref} on {date} from A/c XX{acct}. Bal Rs.{bal}'
)

MERCHANTS=(
  'CARREFOUR' 'SWIGGY' 'ZOMATO' 'AMAZON' 'FLIPKART' 'UBER' 'METRO'
  'STARBUCKS' 'BIGBAZAAR' 'IRCTC' 'NETFLIX' 'SPOTIFY' 'SHELL'
)
DATES=(
  '12-OCT-26' '11-OCT-26' '10-OCT-26' '09-OCT-26' '08-OCT-26'
  '07-OCT-26' '06-OCT-26' '05-OCT-26' '04-OCT-26' '03-OCT-26'
)

rand_int() {
  local min=$1 max=$2
  echo $((min + RANDOM % (max - min + 1)))
}

rand_pick() {
  local -n arr=$1
  echo "${arr[$((RANDOM % ${#arr[@]}))]}"
}

# Random partition of TOTAL into group sizes in [MIN_GROUP, MAX_GROUP].
# Last group absorbs the remainder (may be smaller than MIN_GROUP).
partition_groups() {
  local remaining=$TOTAL
  local sizes=()
  while [ "$remaining" -gt 0 ]; do
    if [ "$remaining" -le "$MAX_GROUP" ]; then
      sizes+=("$remaining")
      break
    fi
    local upper=$MAX_GROUP
    local leave=$((remaining - MIN_GROUP))
    if [ "$leave" -lt "$MAX_GROUP" ]; then
      upper=$leave
    fi
    if [ "$upper" -lt "$MIN_GROUP" ]; then
      sizes+=("$remaining")
      break
    fi
    local size
    size=$(rand_int "$MIN_GROUP" "$upper")
    sizes+=("$size")
    remaining=$((remaining - size))
  done
  printf '%s\n' "${sizes[@]}"
}

format_message() {
  local template=$1
  local amt bal acct merchant ref date
  amt=$(printf '%d.%02d' "$(rand_int 10 9999)" "$(rand_int 0 99)")
  bal=$(printf '%d.%02d' "$(rand_int 1000 99999)" "$(rand_int 0 99)")
  acct=$(printf '%04d' "$(rand_int 1000 9999)")
  merchant=$(rand_pick MERCHANTS)
  ref=$(printf '%012d' "$(rand_int 100000000 999999999)")
  date=$(rand_pick DATES)

  template=${template//\{amt\}/$amt}
  template=${template//\{bal\}/$bal}
  template=${template//\{acct\}/$acct}
  template=${template//\{merchant\}/$merchant}
  template=${template//\{ref\}/$ref}
  template=${template//\{date\}/$date}
  printf '%s' "$template"
}

mapfile -t GROUP_SIZES < <(partition_groups)

# Shuffle format indices so each group gets a distinct template until we wrap.
FORMAT_COUNT=${#FORMATS[@]}
mapfile -t FORMAT_ORDER < <(seq 0 $((FORMAT_COUNT - 1)) | shuf)

echo "device: $DEVICE"
echo "total:  $TOTAL messages across ${#GROUP_SIZES[@]} format groups"
echo

MESSAGES=()
SENDERS=()
gi=0
for size in "${GROUP_SIZES[@]}"; do
  fi="${FORMAT_ORDER[$((gi % FORMAT_COUNT))]}"
  entry="${FORMATS[$fi]}"
  sender="${entry%%|*}"
  template="${entry#*|}"
  echo "group $((gi + 1)): $size × $sender"
  for ((n = 0; n < size; n++)); do
    body=$(format_message "$template")
    MESSAGES+=("$body")
    SENDERS+=("$sender")
  done
  gi=$((gi + 1))
done

# Shuffle send order so same-format messages are interleaved.
ORDER=($(seq 0 $((${#MESSAGES[@]} - 1)) | shuf))

echo
echo "sending ${#ORDER[@]} SMS..."
sent=0
for idx in "${ORDER[@]}"; do
  sender="${SENDERS[$idx]}"
  body="${MESSAGES[$idx]}"
  # adb emu sms send <from> <text...>
  adb -s "$DEVICE" emu sms send "$sender" "$body" >/dev/null
  sent=$((sent + 1))
  printf '\r  %d/%d' "$sent" "${#ORDER[@]}"
  if [ "$DELAY_MS" -gt 0 ]; then
    sleep "$(awk -v ms="$DELAY_MS" 'BEGIN { printf "%.3f", ms / 1000 }')"
  fi
done
echo
echo "done: injected $sent SMS into $DEVICE"
