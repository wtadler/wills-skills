#!/usr/bin/env bash
# drift-check.sh reports changes under tracked paths only, including deletions.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
up="$tmp/upstream"; git init -q -b main "$up"
c() { git -C "$up" -c user.email=t@t -c user.name=t commit -q "$@"; }
mkdir -p "$up/skills/a" "$up/skills/b" "$up/skills/gone"
echo v1 > "$up/skills/a/SKILL.md"; echo v1 > "$up/skills/b/SKILL.md"; echo v1 > "$up/skills/gone/SKILL.md"
git -C "$up" add -A; c -m init
last="$(git -C "$up" rev-parse HEAD)"
cat > "$tmp/manifest.json" <<JSON
{"upstreams": [{"url": "file://$up", "lastChecked": "$last", "paths": ["skills/a", "skills/gone"]}]}
JSON
[[ -z "$(bash "$root/scripts/drift-check.sh" "$tmp/manifest.json")" ]] || { echo "FAIL: expected no drift"; exit 1; }
echo v2 > "$up/skills/a/SKILL.md"; echo v2 > "$up/skills/b/SKILL.md"; git -C "$up" rm -q -r skills/gone
git -C "$up" add -A; c -m change
out="$(bash "$root/scripts/drift-check.sh" "$tmp/manifest.json")"
grep -q $'^M\tskills/a/SKILL.md' <<<"$out" || { echo "FAIL: missing modify"; echo "$out"; exit 1; }
grep -q $'^D\tskills/gone/SKILL.md' <<<"$out" || { echo "FAIL: missing delete"; echo "$out"; exit 1; }
if grep -q 'skills/b' <<<"$out"; then echo "FAIL: untracked path reported"; exit 1; fi
echo "test_drift_check: ok"
