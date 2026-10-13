#!/usr/bin/env bash
set -euo pipefail
h="$(cd "$(dirname "$0")/../../../harness" && pwd)"
bash "$h/sandbox-clone.sh" "$1"
