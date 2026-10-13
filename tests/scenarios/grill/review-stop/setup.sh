#!/usr/bin/env bash
set -euo pipefail
h="$(cd "$(dirname "$0")/../../../harness" && pwd)"
bash "$h/sandbox-clone.sh" "$1"; (cd "$1" && bash scripts/make-prod-db.sh >/dev/null)
