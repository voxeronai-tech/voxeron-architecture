#!/usr/bin/env bash
set -euo pipefail

echo "== Voxeron Contract Validation =="

echo "[1/3] Checking schema files exist..."
find schemas -name "*.json" -print >/dev/null

echo "[2/3] Validating JSON parses (empty files allowed initially)..."
python3 - << 'PY'
import json, glob, sys
paths = glob.glob("schemas/**/*.json", recursive=True)
bad = []
for p in paths:
    with open(p, "r", encoding="utf-8") as f:
        txt = f.read().strip()
        if not txt:
            continue
        try:
            json.loads(txt)
        except Exception as e:
            bad.append((p, str(e)))
if bad:
    print("JSON parse errors:")
    for p,e in bad:
        print(f"- {p}: {e}")
    sys.exit(1)
print(f"OK: checked {len(paths)} schema files")
PY

echo "[3/3] Done."
