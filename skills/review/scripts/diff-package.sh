#!/usr/bin/env bash
# Build a review package (log, stat, diff -U10) for <base>...HEAD.
# Usage: diff-package.sh <worktree> <base> <out-file>
set -euo pipefail
wt="$1"; base="$2"; out="$3"
git -C "$wt" rev-parse --verify --quiet "$base" > /dev/null || { echo "unknown base: $base" >&2; exit 1; }
{
  echo "# Review package: $(git -C "$wt" rev-parse --abbrev-ref HEAD) vs $base"
  echo; echo "## Log"; git -C "$wt" log --oneline "$base..HEAD"
  echo; echo "## Stat"; git -C "$wt" diff --stat=200 "$base...HEAD"
  echo; echo "## Diff"; git -C "$wt" diff -U10 "$base...HEAD"
} > "$out"
echo "$out: $(wc -l < "$out" | tr -d ' ') lines"
