#!/bin/bash
set -euo pipefail

# Only run in Claude Code remote (cloud) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo '{"async": true, "asyncTimeout": 300000}'

make -C "$CLAUDE_PROJECT_DIR" install >&2
