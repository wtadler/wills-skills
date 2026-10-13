#!/usr/bin/env bash
# drift-check.sh reports changes under tracked paths only, including deletions,
# and never reports "no drift" when it could not check: clone failures, vanished
# commits, missing tracked paths, and malformed manifests are all loud failures.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
script="$root/scripts/drift-check.sh"
rc=0
fail() { echo "FAIL: $*"; rc=1; }

# run <manifest>: sets out (stdout), err (stderr), status (exit code).
run() {
  set +e
  out="$(bash "$script" "$1" 2> "$tmp/stderr")"; status=$?
  set -e
  err="$(cat "$tmp/stderr")"
}
expect_ok_silent() {   # <label>: exit 0 and nothing on stdout
  [[ "$status" -eq 0 ]] || fail "$1: expected exit 0, got $status"
  [[ -z "$out" ]] || fail "$1: expected no output, got: $out"
}
expect_line() {        # <label> <exact stdout line>
  grep -qxF -- "$2" <<<"$out" || fail "$1: missing line '$2' in: $out"
}
expect_error_exit() {  # <label>: non-zero exit
  [[ "$status" -ne 0 ]] || fail "$1: expected non-zero exit, got 0"
}

up="$tmp/upstream"; git init -q -b main "$up"
c() { git -C "$up" -c user.email=t@t -c user.name=t commit -q "$@"; }
mkdir -p "$up/skills/a" "$up/skills/b" "$up/skills/gone"
echo v1 > "$up/skills/a/SKILL.md"; echo v1 > "$up/skills/b/SKILL.md"; echo v1 > "$up/skills/gone/SKILL.md"
git -C "$up" add -A; c -m init
last="$(git -C "$up" rev-parse HEAD)"
url="file://$up"
cat > "$tmp/manifest.json" <<JSON
{"upstreams": [{"url": "$url", "lastChecked": "$last", "paths": ["skills/a", "skills/gone"]}]}
JSON

# No drift: silent, exit 0.
run "$tmp/manifest.json"; expect_ok_silent "no drift"

# Drift: modifications and deletions under tracked paths only, with a header.
echo v2 > "$up/skills/a/SKILL.md"; echo v2 > "$up/skills/b/SKILL.md"; git -C "$up" rm -q -r skills/gone
mkdir -p "$up/skills/new"; echo v1 > "$up/skills/new/SKILL.md"
git -C "$up" add -A; c -m change
head="$(git -C "$up" rev-parse HEAD)"
run "$tmp/manifest.json"
[[ "$status" -eq 0 ]] || fail "drift: expected exit 0, got $status"
expect_line "drift header" "## $url ($(git -C "$up" rev-parse --short "$last")..$(git -C "$up" rev-parse --short "$head"))"
grep -q $'^M\tskills/a/SKILL.md' <<<"$out" || fail "missing modify: $out"
grep -q $'^D\tskills/gone/SKILL.md' <<<"$out" || fail "missing delete: $out"
if grep -q 'skills/b' <<<"$out"; then fail "untracked path reported: $out"; fi
if grep -q 'ERROR' <<<"$out"; then fail "a path present at one end only is not an error: $out"; fi

# A tracked path added upstream since the last check exists at HEAD only: reported, not an error.
cat > "$tmp/added.json" <<JSON
{"upstreams": [{"url": "$url", "lastChecked": "$last", "paths": ["skills/new"]}]}
JSON
run "$tmp/added.json"
[[ "$status" -eq 0 ]] || fail "added path: expected exit 0, got $status"
grep -q $'^A\tskills/new/SKILL.md' <<<"$out" || fail "added path not reported: $out"
if grep -q 'ERROR' <<<"$out"; then fail "added path flagged as error: $out"; fi

# Clone failure: ERROR on stdout, non-zero exit.
bad="file://$tmp/does-not-exist"
cat > "$tmp/clone.json" <<JSON
{"upstreams": [{"url": "$bad", "lastChecked": "$last", "paths": ["skills/a"]}]}
JSON
run "$tmp/clone.json"
grep -qF -- "## $bad ERROR: clone failed: " <<<"$out" || fail "clone failure: no ERROR line in: $out"
expect_error_exit "clone failure"

# lastChecked that is not in the upstream: ERROR on stdout, non-zero exit.
ghost="$(printf 'ab%.0s' $(seq 1 20))"
cat > "$tmp/ghost.json" <<JSON
{"upstreams": [{"url": "$url", "lastChecked": "$ghost", "paths": ["skills/a"]}]}
JSON
run "$tmp/ghost.json"
expect_line "vanished sha" "## $url ERROR: lastChecked $ghost not found upstream (history rewritten?)"
expect_error_exit "vanished sha"

# A failure on the first upstream does not hide the second one's drift.
cat > "$tmp/two.json" <<JSON
{"upstreams": [
  {"url": "$bad", "lastChecked": "$last", "paths": ["skills/a"]},
  {"url": "$url", "lastChecked": "$last", "paths": ["skills/a", "skills/gone"]}
]}
JSON
run "$tmp/two.json"
grep -qF -- "## $bad ERROR: clone failed: " <<<"$out" || fail "two upstreams: no clone ERROR in: $out"
grep -q $'^M\tskills/a/SKILL.md' <<<"$out" || fail "two upstreams: second upstream's drift lost: $out"
expect_error_exit "two upstreams"

# A tracked path that exists at neither commit is a typo, not "no drift".
cat > "$tmp/typo.json" <<JSON
{"upstreams": [{"url": "$url", "lastChecked": "$last", "paths": ["skills/a", "skills/typo"]}]}
JSON
run "$tmp/typo.json"
expect_line "missing path" "## $url ERROR: tracked path skills/typo not found"
grep -q $'^M\tskills/a/SKILL.md' <<<"$out" || fail "missing path: other paths still reported: $out"
expect_error_exit "missing path"

# Malformed manifests fail with a message on stderr and nothing on stdout.
expect_rejected() {    # <label> <manifest json>
  printf '%s\n' "$2" > "$tmp/bad.json"
  run "$tmp/bad.json"
  expect_error_exit "$1"
  [[ -z "$out" ]] || fail "$1: expected empty stdout, got: $out"
  [[ -n "$err" ]] || fail "$1: expected a message on stderr"
}
expect_rejected "empty upstreams" '{"upstreams": []}'
expect_rejected "ref-name lastChecked" "{\"upstreams\": [{\"url\": \"$url\", \"lastChecked\": \"main\", \"paths\": [\"skills/a\"]}]}"
expect_rejected "short lastChecked" "{\"upstreams\": [{\"url\": \"$url\", \"lastChecked\": \"${last:0:7}\", \"paths\": [\"skills/a\"]}]}"
expect_rejected "empty paths" "{\"upstreams\": [{\"url\": \"$url\", \"lastChecked\": \"$last\", \"paths\": []}]}"

[[ "$rc" -eq 0 ]] || exit 1
echo "test_drift_check: ok"
