#!/usr/bin/env bash
# Fresh sandbox clone for one scenario run. Usage: sandbox-clone.sh <workdir> [branch]
set -euo pipefail
git clone --quiet "https://github.com/${WSK_SANDBOX:-wtadler/wills-skills-sandbox}" "$1"
git -C "$1" checkout --quiet "${2:-main}"
