#!/usr/bin/env bash
# Appends a usage summary line to usage-log.jsonl at the project root.
# Invoked by Claude Code as a Stop hook (receives JSON on stdin).
#
# Requires: jq

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
USAGE_LOG="$PROJECT_ROOT/.claude/usage-log.jsonl"

# Read hook input
input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id')
transcript_path=$(echo "$input" | jq -r '.transcript_path')

[[ -f "$transcript_path" ]] || exit 0

# Extract token usage and model from all assistant messages in the transcript.
# Model is taken from the last assistant message (most recent in the session).
data=$(jq -rn \
  '[inputs | select(.type == "assistant")] |
   {
     model:                   (last | .message.model),
     input_tokens:            (map(.message.usage.input_tokens             // 0) | add // 0),
     output_tokens:           (map(.message.usage.output_tokens            // 0) | add // 0),
     cache_read_tokens:       (map(.message.usage.cache_read_input_tokens  // 0) | add // 0),
     cache_creation_tokens:   (map(.message.usage.cache_creation_input_tokens // 0) | add // 0)
   }' "$transcript_path")

# Skip empty sessions
total=$(echo "$data" | jq '.input_tokens + .output_tokens')
[[ "$total" -gt 0 ]] || exit 0

# Approximate cost in USD based on model.
# Rates are per 1M tokens. Update if pricing changes.
# https://www.anthropic.com/pricing
model=$(echo "$data" | jq -r '.model')
case "$model" in
  claude-opus-4-6)
    ir=15.00; outr=75.00; crr=1.50; ccr=18.75 ;;
  claude-sonnet-4-6|claude-sonnet-4-5*)
    ir=3.00;  outr=15.00; crr=0.30; ccr=3.75 ;;
  claude-haiku-4-5*)
    ir=0.80;  outr=4.00;  crr=0.08; ccr=1.00 ;;
  *)
    ir=3.00;  outr=15.00; crr=0.30; ccr=3.75 ;;
esac

cost=$(echo "$data" | jq \
  --argjson ir   "$ir" \
  --argjson outr "$outr" \
  --argjson crr  "$crr" \
  --argjson ccr  "$ccr" \
  '((.input_tokens * $ir) + (.output_tokens * $outr) + (.cache_read_tokens * $crr) + (.cache_creation_tokens * $ccr))
   / 1000000 | . * 10000 | round / 10000')

# Build log entry
date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
entry=$(echo "$data" | jq -c \
  --arg session_id "$session_id" \
  --arg date       "$date" \
  --argjson cost   "$cost" \
  '{session_id: $session_id, date: $date, model, cost_usd: $cost,
    input_tokens, output_tokens, cache_read_tokens, cache_creation_tokens}')

# Upsert: replace existing entry for this session, or append if new
touch "$USAGE_LOG"
if grep -qF "\"session_id\":\"$session_id\"" "$USAGE_LOG"; then
  tmp=$(mktemp)
  grep -vF "\"session_id\":\"$session_id\"" "$USAGE_LOG" > "$tmp" || true
  echo "$entry" >> "$tmp"
  mv "$tmp" "$USAGE_LOG"
else
  echo "$entry" >> "$USAGE_LOG"
fi
