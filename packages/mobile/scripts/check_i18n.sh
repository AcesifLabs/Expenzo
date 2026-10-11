#!/usr/bin/env bash
# Fails when a Bangla translation is missing or an English key is unused.
# Run from packages/mobile: scripts/check_i18n.sh
set -euo pipefail
cd "$(dirname "$0")/.."

out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT

dart run slang >/dev/null
dart run slang analyze --full --outdir="$out" >/dev/null

python3 - "$out" <<'PY'
import json, sys

out = sys.argv[1]
missing = json.load(open(f"{out}/_missing_translations.json"))
unused = json.load(open(f"{out}/_unused_translations.json"))
problems = {
    "missing in bn": {k: v for k, v in missing.items() if not k.startswith("@@") and v},
    "unused or extra": {k: v for k, v in unused.items() if not k.startswith("@@") and v},
}
problems = {k: v for k, v in problems.items() if v}
if problems:
    print(json.dumps(problems, ensure_ascii=False, indent=2))
    sys.exit(1)
print("i18n OK: every key is translated and used.")
PY
