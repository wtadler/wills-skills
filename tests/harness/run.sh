#!/usr/bin/env bash
# Run one pressure scenario headless and save its transcript.
# Usage: run.sh <scenario-dir> <baseline|skill> <rep>
set -euo pipefail
scenario="$(cd "$1" && pwd)"; arm="$2"; rep="$3"
root="$(cd "$(dirname "$0")/../.." && pwd)"
group="$(basename "$(dirname "$scenario")")"; name="$(basename "$scenario")"
out_dir="$root/tests/results/$group/$name"; mkdir -p "$out_dir"
out="$out_dir/$arm-$rep.jsonl"
work="$(mktemp -d "${TMPDIR:-/tmp}/wsk-$name-XXXX")/repo"
bash "$scenario/setup.sh" "$work"
prompt="$(cat "$scenario/prompt.md")"
while IFS='=' read -r key value; do
  [[ -n "$key" ]] && prompt="${prompt//\{\{$key\}\}/$value}"
done < "$root/tests/sandbox.env"
plugin_args=()
[[ "$arm" == skill ]] && plugin_args=(--plugin-dir "$root")
( cd "$work" && GH_REPO="${WSK_SANDBOX:-wtadler/wills-skills-sandbox}" \
    claude -p "$prompt" --model sonnet --output-format stream-json --verbose \
      --permission-mode bypassPermissions ${plugin_args[@]+"${plugin_args[@]}"} ) > "$out" 2>&1 || true
digest="$(python3 "$root/tests/harness/tools.py" "$out")"
printf '%s\n' "$digest"
echo "transcript: $out"
echo "workdir: $work"
if [[ "$arm" == baseline ]]; then
  case "$(printf '%s\n' "$digest" | head -n 1)" in
    *wills-skills*) echo "INVALID BASELINE: wills-skills loaded" >&2; exit 1 ;;
  esac
fi
