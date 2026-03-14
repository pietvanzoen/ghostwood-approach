#!/bin/bash
set -euo pipefail

# Only run in Claude Code remote (cloud) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo '{"async": true, "asyncTimeout": 300000}'

echo "Installing Stillwater Approach dev dependencies..."

# Lua + LuaRocks (for luacheck and busted)
if ! command -v lua &>/dev/null || ! command -v luarocks &>/dev/null; then
  apt-get install -y lua5.4 luarocks
fi

# luacheck (linter)
if ! command -v luacheck &>/dev/null; then
  luarocks install luacheck
fi

# busted (test runner)
if ! command -v busted &>/dev/null; then
  luarocks install busted
fi

# stylua (formatter) — install latest binary from GitHub releases
if ! command -v stylua &>/dev/null; then
  STYLUA_VERSION=$(curl -s https://api.github.com/repos/JohnnyMorganz/StyLua/releases/latest | grep '"tag_name"' | sed 's/.*"tag_name": "\(.*\)".*/\1/')
  curl -sL "https://github.com/JohnnyMorganz/StyLua/releases/download/${STYLUA_VERSION}/stylua-linux-x86_64.zip" -o /tmp/stylua.zip
  unzip -o /tmp/stylua.zip -d /usr/local/bin/
  chmod +x /usr/local/bin/stylua
  rm /tmp/stylua.zip
fi

# jq (used by log-usage.sh hook)
if ! command -v jq &>/dev/null; then
  apt-get install -y jq
fi

echo "All dependencies installed."

# Install git hooks
make -C "$CLAUDE_PROJECT_DIR" install-hooks
