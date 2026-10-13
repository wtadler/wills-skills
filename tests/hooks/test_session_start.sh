#!/usr/bin/env bash
# The SessionStart hook emits the router body as additionalContext, under the size ceiling.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
out="$(CLAUDE_PLUGIN_ROOT="$root" bash "$root/hooks/session-start")"
python3 - "$out" <<'PY'
import json, sys
data = json.loads(sys.argv[1])["hookSpecificOutput"]
ctx = data["additionalContext"]
assert data["hookEventName"] == "SessionStart", data["hookEventName"]
assert "# Using wills-skills" in ctx, "router heading missing"
assert "name: using-wills-skills" not in ctx, "frontmatter leaked"
assert len(ctx) < 3500, f"router is {len(ctx)} chars; ceiling is 3500"
print(f"test_session_start: ok ({len(ctx)} chars)")
PY
