#!/usr/bin/env bash
# Report upstream changes under tracked paths since the last-checked commits.
# Usage: drift-check.sh [manifest]   (default: upstream.json at the repo root)
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
manifest="${1:-$root/upstream.json}"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
python3 - "$manifest" > "$tmp/list" <<'PY'
import json, sys
for u in json.load(open(sys.argv[1]))["upstreams"]:
    print(u["url"], u["lastChecked"], " ".join(u["paths"]))
PY
i=0
while read -r url last paths; do
  i=$((i + 1)); dir="$tmp/u$i"
  git clone --quiet "$url" "$dir" 2> /dev/null
  # shellcheck disable=SC2086  # paths is a space-separated list by design
  changes="$(git -C "$dir" diff --name-status -M "$last" HEAD -- $paths)"
  if [[ -n "$changes" ]]; then
    echo "## $url ($(git -C "$dir" rev-parse --short "$last")..$(git -C "$dir" rev-parse --short HEAD))"
    echo "$changes"
    echo
  fi
done < "$tmp/list"
