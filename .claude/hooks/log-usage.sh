#!/usr/bin/env bash
# Appends a usage summary line to .claude/usage-log.jsonl at the project root.
# Invoked by Claude Code as a Stop hook (receives JSON on stdin).
#
# Parses the main session transcript plus any sibling transcripts (subagents)
# that started within the session's time range. Cost is calculated per-message
# using each message's own model rates.
#
# Requires: jq

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
USAGE_LOG="$PROJECT_ROOT/.claude/usage-log.jsonl"

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id')
transcript_path=$(echo "$input" | jq -r '.transcript_path' | sed "s|^~|$HOME|")

[[ -f "$transcript_path" ]] || exit 0

transcript_dir=$(dirname "$transcript_path")

# Get the session's time range to identify sibling transcripts (subagents)
session_start=$(jq -rn 'first(inputs | select(.timestamp? != null)) | .timestamp' "$transcript_path")
session_end=$(jq -rn 'last(inputs | select(.timestamp? != null)) | .timestamp' "$transcript_path")

# Collect main transcript plus siblings whose first timestamp falls within our session
transcripts=("$transcript_path")
if [[ -n "$session_start" && "$session_start" != "null" && -n "$session_end" && "$session_end" != "null" ]]; then
  for sibling in "$transcript_dir"/*.jsonl; do
    [[ "$sibling" == "$transcript_path" ]] && continue
    sibling_start=$(jq -rn 'first(inputs | select(.timestamp? != null)) | .timestamp' "$sibling" 2>/dev/null || true)
    if [[ -n "$sibling_start" && "$sibling_start" != "null" \
          && "$sibling_start" > "$session_start" && "$sibling_start" < "$session_end" ]]; then
      transcripts+=("$sibling")
    fi
  done
fi

# Calculate total token counts and cost across all transcripts.
# Cost is computed per-message using each message's own model.
# Rates per 1M tokens — update if pricing changes: https://www.anthropic.com/pricing
data=$(cat "${transcripts[@]}" | jq -rn \
  '[inputs | select(.type == "assistant" and (.message.usage != null) and (.message.model != null))] |
   {
     input_tokens:          (map(.message.usage.input_tokens                  // 0) | add // 0),
     output_tokens:         (map(.message.usage.output_tokens                 // 0) | add // 0),
     cache_read_tokens:     (map(.message.usage.cache_read_input_tokens       // 0) | add // 0),
     cache_creation_tokens: (map(.message.usage.cache_creation_input_tokens   // 0) | add // 0),
     cost_usd: (
       map(
         . as $m |
         ($m.message.model // "" | if
           startswith("claude-opus-4-6")      then {ir: 15.00, outr: 75.00, crr: 1.50,  ccr: 18.75}
           elif startswith("claude-sonnet-4") then {ir:  3.00, outr: 15.00, crr: 0.30,  ccr:  3.75}
           elif startswith("claude-haiku-4")  then {ir:  0.80, outr:  4.00, crr: 0.08,  ccr:  1.00}
           else                                    {ir:  3.00, outr: 15.00, crr: 0.30,  ccr:  3.75}
         end) as $r |
         (($m.message.usage.input_tokens                // 0) * $r.ir   +
          ($m.message.usage.output_tokens               // 0) * $r.outr +
          ($m.message.usage.cache_read_input_tokens     // 0) * $r.crr  +
          ($m.message.usage.cache_creation_input_tokens // 0) * $r.ccr) / 1000000
       ) | add // 0 | . * 10000 | round / 10000
     )
   }')

# Skip empty sessions
total=$(echo "$data" | jq '.input_tokens + .output_tokens')
[[ "$total" -gt 0 ]] || exit 0

# Build and upsert log entry
date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
entry=$(echo "$data" | jq -c \
  --arg session_id "$session_id" \
  --arg date       "$date" \
  '{session_id: $session_id, date: $date, cost_usd,
    input_tokens, output_tokens, cache_read_tokens, cache_creation_tokens}')

touch "$USAGE_LOG"
if grep -qF "\"session_id\":\"$session_id\"" "$USAGE_LOG"; then
  tmp=$(mktemp)
  grep -vF "\"session_id\":\"$session_id\"" "$USAGE_LOG" > "$tmp" || true
  echo "$entry" >> "$tmp"
  mv "$tmp" "$USAGE_LOG"
else
  echo "$entry" >> "$USAGE_LOG"
fi
