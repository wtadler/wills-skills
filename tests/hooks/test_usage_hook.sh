#!/usr/bin/env bash
# The usage hook resolves its reader next to itself and stays silent without a cache.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
hook="$root/skills/usage-pacing/scripts/usage_hook.sh"
if grep -q '\.claude/skills' "$hook"; then echo "FAIL: hook still points at ~/.claude/skills"; exit 1; fi
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
out="$(TMPDIR="$tmp" CLAUDE_USAGE_CACHE_DIR="$tmp/empty-cache" bash "$hook" < /dev/null)"
if [[ -n "$out" ]]; then echo "FAIL: expected no output without a cache, got: $out"; exit 1; fi
echo "test_usage_hook: ok"
