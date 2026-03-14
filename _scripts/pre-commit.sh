#!/bin/bash
# Pre-commit hook: sync usage-log.jsonl.local -> usage-log.jsonl so token
# usage is captured in commits without manual intervention.
set -euo pipefail

LOCAL=".claude/usage-log.jsonl.local"
TRACKED=".claude/usage-log.jsonl"

if [ ! -f "$LOCAL" ]; then
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Warning: jq not found, skipping usage log sync. Run 'make install'." >&2
  exit 0
fi

touch "$TRACKED"

# Merge: keep tracked entries not present in local, then append all local entries
tmp=$(mktemp)
while IFS= read -r line; do
  [ -z "$line" ] && continue
  sid=$(printf '%s\n' "$line" | jq -r '.session_id' 2>/dev/null || true)
  [ -z "$sid" ] || [ "$sid" = "null" ] && continue
  if ! grep -qF "\"session_id\":\"$sid\"" "$LOCAL"; then
    echo "$line"
  fi
done < "$TRACKED" > "$tmp"
cat "$LOCAL" >> "$tmp"
mv "$tmp" "$TRACKED"
git add "$TRACKED"
