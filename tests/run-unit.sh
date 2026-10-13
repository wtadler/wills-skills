#!/usr/bin/env bash
# Run every unit test in the repo.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
python3 "$root/tests/harness/test_tools.py"
for t in "$root"/tests/hooks/test_*.sh "$root"/tests/scripts/test_*.sh; do
  [[ -f "$t" ]] && bash "$t"
done
[[ -f "$root/skills/usage-pacing/scripts/check_usage.test.js" ]] && node --test "$root/skills/usage-pacing/scripts/check_usage.test.js"
echo "all unit tests passed"
