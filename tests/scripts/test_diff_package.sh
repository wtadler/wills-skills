#!/usr/bin/env bash
# diff-package.sh writes log, stat, and diff sections for <base>...HEAD.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
script="$root/skills/review/scripts/diff-package.sh"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
git -C "$tmp" init -q -b main
git -C "$tmp" -c user.email=t@t -c user.name=t commit -q --allow-empty -m "base"
git -C "$tmp" checkout -q -b feature
echo "hello" > "$tmp/a.txt"
git -C "$tmp" add a.txt && git -C "$tmp" -c user.email=t@t -c user.name=t commit -q -m "feat: add a"
bash "$script" "$tmp" main "$tmp/pkg.md" > /dev/null
for want in "## Log" "## Stat" "## Diff" "feat: add a" "+hello"; do
  grep -qF -- "$want" "$tmp/pkg.md" || { echo "FAIL: missing '$want'"; exit 1; }
done
if bash "$script" "$tmp" no-such-base "$tmp/bad.md" > /dev/null 2>&1; then echo "FAIL: unknown base should fail"; exit 1; fi
[ ! -e "$tmp/bad.md" ] || { echo "FAIL: unknown base left an out-file"; exit 1; }
# A worktree path and an out-file path that contain spaces.
sp="$tmp/work tree"
git -C "$tmp" worktree add -q -b spaced "$sp" feature
bash "$script" "$sp" main "$tmp/out dir.md" > /dev/null || { echo "FAIL: path with spaces"; exit 1; }
grep -qF -- "+hello" "$tmp/out dir.md" || { echo "FAIL: spaced path package missing diff"; exit 1; }
echo "test_diff_package: ok"
