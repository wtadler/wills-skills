#!/usr/bin/env bash
# Report upstream changes under tracked paths since the last-checked commits.
# Usage: drift-check.sh [manifest]   (default: upstream.json at the repo root)
# Prints nothing when there is no drift. An upstream that cannot be checked
# prints "## <url> ERROR: ..." and makes the exit status non-zero; the remaining
# upstreams are still checked. A malformed manifest is rejected up front.
set -euo pipefail
export GIT_TERMINAL_PROMPT=0
root="$(cd "$(dirname "$0")/.." && pwd)"
manifest="${1:-$root/upstream.json}"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
python3 - "$manifest" > "$tmp/list" <<'PY'
import json, re, sys

def bad(msg):
    sys.exit("drift-check: invalid manifest: " + msg)

try:
    with open(sys.argv[1]) as f:
        data = json.load(f)
except (OSError, ValueError) as e:
    bad(str(e))
upstreams = data.get("upstreams") if isinstance(data, dict) else None
if not isinstance(upstreams, list) or not upstreams:
    bad("upstreams must be a non-empty list")
for u in upstreams:
    if not isinstance(u, dict):
        bad("each upstream must be an object")
    url, last, paths = u.get("url"), u.get("lastChecked"), u.get("paths")
    if not isinstance(url, str) or not url or re.search(r"\s", url):
        bad("url must be a string without whitespace: %r" % (url,))
    if not isinstance(last, str) or not re.fullmatch(r"[0-9a-f]{40}", last):
        bad("%s: lastChecked must be a full 40-character commit SHA, not %r" % (url, last))
    if (not isinstance(paths, list) or not paths
            or not all(isinstance(p, str) and p and not re.search(r"\s", p) for p in paths)):
        bad("%s: paths must be a non-empty list of strings without whitespace" % url)
    print(url, last, " ".join(paths))
PY
fail=0
i=0
while read -r url last paths; do
  i=$((i + 1)); dir="$tmp/u$i"
  if ! git clone --quiet "$url" "$dir" 2> "$tmp/err" < /dev/null; then
    echo "## $url ERROR: clone failed: $(head -n 1 "$tmp/err")"; echo
    fail=1; continue
  fi
  if ! git -C "$dir" cat-file -e "$last^{commit}" 2> /dev/null; then
    echo "## $url ERROR: lastChecked $last not found upstream (history rewritten?)"; echo
    fail=1; continue
  fi
  # A tracked path must exist at one end of the range (added or deleted is drift);
  # one that exists at neither is a typo or a rename that would otherwise read as no drift.
  # shellcheck disable=SC2086  # paths is a space-separated list by design
  for p in $paths; do
    [[ "$p" == "." ]] && continue
    if ! git -C "$dir" cat-file -e "$last:$p" 2> /dev/null && ! git -C "$dir" cat-file -e "HEAD:$p" 2> /dev/null; then
      echo "## $url ERROR: tracked path $p not found"; echo
      fail=1
    fi
  done
  # shellcheck disable=SC2086
  if ! changes="$(git -C "$dir" diff --name-status -M "$last" HEAD -- $paths 2> "$tmp/err")"; then
    echo "## $url ERROR: diff failed: $(head -n 1 "$tmp/err")"; echo
    fail=1; continue
  fi
  if [[ -n "$changes" ]]; then
    echo "## $url ($(git -C "$dir" rev-parse --short "$last")..$(git -C "$dir" rev-parse --short HEAD))"
    echo "$changes"
    echo
  fi
done < "$tmp/list"
exit "$fail"
