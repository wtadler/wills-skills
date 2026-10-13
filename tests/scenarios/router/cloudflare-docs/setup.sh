#!/usr/bin/env bash
set -euo pipefail
h="$(cd "$(dirname "$0")/../../../harness" && pwd)"
bash "$h/sandbox-clone.sh" "$1"; printf '{\n  "name": "sandbox-worker",\n  "main": "src/index.js",\n  "compatibility_date": "2026-09-01"\n}\n' > "$1/wrangler.jsonc"
