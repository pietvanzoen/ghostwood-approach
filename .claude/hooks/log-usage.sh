#!/usr/bin/env bash
# Appends a usage summary line to .claude/usage-log.jsonl at the project root.
# Invoked by Claude Code as a Stop hook (receives JSON on stdin).
#
# Parses the main session transcript plus any sibling transcripts (subagents)
# that started within the session's time range.
#
# Requires: jq

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
USAGE_LOG="$PROJECT_ROOT/.claude/usage-log.jsonl"

input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id')
transcript_path=$(echo "$input" | jq -r '.transcript_path' | sed "s|^~|$HOME|")

# Exit if required fields are missing or null (jq -r returns "null" for missing fields)
if [[ -z "$session_id" || "$session_id" == "null" || -z "$transcript_path" || "$transcript_path" == "null" ]]; then
  exit 0
fi

[[ -f "$transcript_path" ]] || exit 0

transcript_dir=$(dirname "$transcript_path")

# Get the session's time range to identify sibling transcripts (subagents)
session_start=$(jq -rn 'first(inputs | select(.timestamp? != null)) | .timestamp' "$transcript_path" 2>/dev/null || true)
session_end=$(jq -rn 'last(inputs | select(.timestamp? != null)) | .timestamp' "$transcript_path" 2>/dev/null || true)

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

# Sum token counts per model from all assistant messages across all transcripts
data=$(cat "${transcripts[@]}" | jq -rn \
  '[inputs | select(.type == "assistant") | select(.message.usage != null)
   | {model: (.message.model // "unknown"),
      input_tokens:          (.message.usage.input_tokens                  // 0),
      output_tokens:         (.message.usage.output_tokens                 // 0),
      cache_read_tokens:     (.message.usage.cache_read_input_tokens       // 0),
      cache_creation_tokens: (.message.usage.cache_creation_input_tokens   // 0)}]
  | group_by(.model)
  | map({
      key: .[0].model,
      value: {
        input_tokens:          (map(.input_tokens)          | add),
        output_tokens:         (map(.output_tokens)         | add),
        cache_read_tokens:     (map(.cache_read_tokens)     | add),
        cache_creation_tokens: (map(.cache_creation_tokens) | add)
      }
    })
  | map(select(.value.input_tokens + .value.output_tokens > 0))
  | from_entries')

# Skip empty sessions
total=$(echo "$data" | jq '[.[] | .input_tokens + .output_tokens] | add // 0')
[[ "$total" -gt 0 ]] || exit 0

# Estimate energy usage (Wh) per model.
# Output tokens dominate energy; input tokens ~0.25x output; cached tokens ~0.025x output.
# Wh per output token by model class (H100 hardware, realistic serving conditions):
#   Large  (opus):   0.003   Wh/output token
#   Medium (sonnet): 0.0005  Wh/output token
#   Small  (haiku):  0.0001  Wh/output token
# Sources: TokenPowerBench (Dec 2024), Ren et al. "How Hungry is AI?" (May 2025),
#          vLLM energy benchmarks (Sep 2025). These are rough estimates — actual
#          consumption varies with batch size, hardware, quantisation, and context length.
energy_wh=$(echo "$data" | jq '
  to_entries | map(
    (.key | if
      startswith("claude-opus-4")        then 0.003
      elif startswith("claude-sonnet-4") then 0.0005
      elif startswith("claude-haiku-4")  then 0.0001
      else                                    0.0005
    end) as $rate |
    (.value.output_tokens * $rate) +
    (.value.input_tokens * $rate * 0.25) +
    ((.value.cache_read_tokens + .value.cache_creation_tokens) * $rate * 0.025)
  ) | add // 0 | . * 1000 | round / 1000')

# Build and upsert log entry
date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
entry=$(echo "$data" | jq -c \
  --arg session_id "$session_id" \
  --arg date       "$date" \
  --argjson energy_wh "$energy_wh" \
  '{session_id: $session_id, date: $date, energy_wh: $energy_wh, models: .}')

touch "$USAGE_LOG"
if grep -qF "\"session_id\":\"$session_id\"" "$USAGE_LOG"; then
  tmp=$(mktemp)
  grep -vF "\"session_id\":\"$session_id\"" "$USAGE_LOG" > "$tmp" || true
  echo "$entry" >> "$tmp"
  mv "$tmp" "$USAGE_LOG"
else
  echo "$entry" >> "$USAGE_LOG"
fi
