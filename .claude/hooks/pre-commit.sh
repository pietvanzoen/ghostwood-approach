#!/bin/bash
# Pre-commit hook: sync usage-log.jsonl.local -> usage-log.jsonl so token
# usage is captured in commits without manual intervention.
set -euo pipefail

LOCAL=".claude/usage-log.jsonl.local"
TRACKED=".claude/usage-log.jsonl"

if [ -f "$LOCAL" ]; then
  touch "$TRACKED"
  # Merge: start with tracked entries, upsert any session from local on top
  tmp=$(mktemp)
  # Keep tracked entries whose session_id doesn't appear in local
  while IFS= read -r line; do
    sid=$(echo "$line" | jq -r '.session_id')
    if ! grep -qF "\"session_id\":\"$sid\"" "$LOCAL"; then
      echo "$line"
    fi
  done < "$TRACKED" > "$tmp"
  # Append all entries from local
  cat "$LOCAL" >> "$tmp"
  mv "$tmp" "$TRACKED"
  git add "$TRACKED"
fi
