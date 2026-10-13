#!/usr/bin/env bash
# PostToolUse hook — injects the current Claude 5-hour usage state into the model's
# context (NOT just the transcript UI) via hookSpecificOutput.additionalContext.
#
#   - Healthy (< 80%): a quiet usage line, at most every ~20 min.
#   - Critical (>= 80%): a loud wrap-up/checkpoint reminder, at most every ~2 min.
#
# This paces on the 5-hour window and its deterministic resets_at. The weekly fields
# in the cache are often null or 0, so they are not used here.
#
# Reads and discards stdin (required so the hook doesn't block the tool pipeline).
cat > /dev/null

STAMP_DIR="${TMPDIR:-/tmp}"
STAMP_RUN="$STAMP_DIR/claude_usage_last_run"      # throttles node startup (>=120s)
STAMP_SHOWN="$STAMP_DIR/claude_usage_last_shown"  # throttles quiet injections (>=1200s)
RUN_FLOOR=120

now=$(date +%s)

# Cheap pre-gate: never spawn node more than once per RUN_FLOOR seconds.
if [[ -f "$STAMP_RUN" ]]; then
  last_run=$(cat "$STAMP_RUN" 2>/dev/null || echo 0)
  (( now - last_run < RUN_FLOOR )) && exit 0
fi
echo "$now" > "$STAMP_RUN"

HERE="$(cd "$(dirname "$0")" && pwd)"
LINE=$(node "$HERE/check_usage.js" --compact 2>/dev/null)
[[ -z "$LINE" ]] && exit 0

# Parse the 5-hour percentage out of e.g. "[Claude usage] 5h: 9% (resets in 3h38m) ..."
PCT=$(printf '%s' "$LINE" | sed -nE 's/.*5h: ([0-9]+)%.*/\1/p')
PCT=${PCT:-0}

if [[ "$LINE" == *"5h: unknown"* ]]; then
  # Stale cache: say so plainly, never "healthy". Same quiet throttle as healthy.
  if [[ -f "$STAMP_SHOWN" ]]; then
    last_shown=$(cat "$STAMP_SHOWN" 2>/dev/null || echo 0)
    (( now - last_shown < 1200 )) && exit 0
  fi
  echo "$now" > "$STAMP_SHOWN"
  MSG="${LINE} — usage unknown. Not a reason to stop interactive work, but don't treat it as headroom; an unattended loop should rely on rate-limit errors instead."
elif (( PCT >= 80 )); then
  # Critical zone: re-inject on (nearly) every tool call — this is the moment that
  # mid-task focus blows past. The RUN_FLOOR above is the only throttle.
  echo "$now" > "$STAMP_SHOWN"
  MSG="⚠️ ${LINE} — past 80% of the 5-hour window. Finish only the current step, then commit and checkpoint, and start no new expensive steps (subagent dispatch, dev server, opening a PR). In an unattended run, write a handoff and schedule a resume for just after the window resets. Keep every verification gate. Trust resets_at over a stale 'as of' stamp."
else
  # Healthy zone: quiet line at most every 20 min.
  if [[ -f "$STAMP_SHOWN" ]]; then
    last_shown=$(cat "$STAMP_SHOWN" 2>/dev/null || echo 0)
    (( now - last_shown < 1200 )) && exit 0
  fi
  echo "$now" > "$STAMP_SHOWN"
  MSG="${LINE} — usage healthy; continue."
fi

python3 -c 'import json,sys; print(json.dumps({"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":sys.argv[1]}}))' "$MSG"
exit 0
