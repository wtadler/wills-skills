#!/usr/bin/env bash
set -euo pipefail
h="$(cd "$(dirname "$0")/../../../harness" && pwd)"
bash "$h/sandbox-clone.sh" "$1" feature/reserve
bash "$h/../../skills/review/scripts/diff-package.sh" "$1" origin/main "$1/review-package.md" > /dev/null
