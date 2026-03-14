#!/bin/bash
# Pre-commit hook: sync usage-log.jsonl.local -> usage-log.jsonl so token
# usage is captured in commits without manual intervention.
set -euo pipefail

LOCAL=".claude/usage-log.jsonl.local"
TRACKED=".claude/usage-log.jsonl"

if [ -f "$LOCAL" ]; then
  cp "$LOCAL" "$TRACKED"
  git add "$TRACKED"
fi
