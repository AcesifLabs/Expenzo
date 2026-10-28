#!/usr/bin/env bash


set -euo pipefail
cd "$(dirname "$0")/.."

out="$(mktemp -d)"
trap 'rm -rf "$out"' EXIT

dart run slang >/dev/null
dart run slang analyze --full --outdir="$out" >/dev/null

python3 - "$out" lib <<'PY'
import json, pathlib, re, sys

out, lib = sys.argv[1], pathlib.Path(sys.argv[2])
missing = json.load(open(f"{out}/_missing_translations.json"))
unused = json.load(open(f"{out}/_unused_translations.json"))




PATH = r"[A-Za-z_]\w*(?:\.[A-Za-z_]\w*)*"
ALIAS = re.compile(rf"\b([A-Za-z_]\w*)\s*(?:=|=>)\s*(?:context\.)?({PATH})\s*;")
DIRECT = re.compile(rf"(?<![\w.])(?:context\.)?t\.({PATH})")

reached = set()
for file in lib.rglob("*.dart"):
    if file.name.endswith(".g.dart"):
        continue
    src = file.read_text(encoding="utf-8")
    alias_spans, aliases = set(), {}

    changed = True
    while changed:
        changed = False
        for m in ALIAS.finditer(src):
            name, rhs = m.group(1), m.group(2)
            head, _, rest = rhs.partition(".")
            if head == "t":
                bases = {rest} if rest else set()
            else:
                bases = {f"{b}.{rest}" if rest else b for b in aliases.get(head, ())}
            new = bases - aliases.get(name, set())
            if new:
                aliases.setdefault(name, set()).update(new)
                changed = True
            if bases:
                alias_spans.add(m.span(2))
    for m in DIRECT.finditer(src):

        if not any(s <= m.start() < e for s, e in alias_spans):
            reached.add(m.group(1))
    for name, bases in aliases.items():
        for m in re.finditer(rf"(?<![\w.]){re.escape(name)}\.({PATH})", src):
            reached.update(f"{b}.{m.group(1)}" for b in bases)

def is_reached(key):


    return any(key == p or key.startswith(p + ".") or p.startswith(key + ".")
               for p in reached)

def prune(node, prefix=""):
    kept = {}
    for k, v in node.items():
        if k.startswith("@@"):
            continue
        path = f"{prefix}.{k}" if prefix else k
        if isinstance(v, dict):
            sub = prune(v, path)
            if sub:
                kept[k] = sub
        elif not is_reached(path):
            kept[k] = v
    return kept



problems = {
    "missing in bn": {k: v for k, v in missing.items() if not k.startswith("@@") and v},
    "unused or extra": {
        k: prune(v) if k == "en" else v
        for k, v in unused.items()
        if not k.startswith("@@") and v
    },
}
problems["unused or extra"] = {k: v for k, v in problems["unused or extra"].items() if v}
problems = {k: v for k, v in problems.items() if v}
if problems:
    print(json.dumps(problems, ensure_ascii=False, indent=2))
    sys.exit(1)
print("i18n OK: every key is translated and used.")
PY
