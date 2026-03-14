#!/bin/bash
set -euo pipefail

OS=$(uname -s)

if [ "$OS" = "Darwin" ]; then
  echo "Installing via Homebrew..."
  brew install lua@5.4 luarocks stylua jq
  luarocks install luacheck
  luarocks install busted

elif [ "$OS" = "Linux" ]; then
  echo "Installing via apt + luarocks..."
  SUDO=$(command -v sudo 2>/dev/null || true)
  $SUDO apt-get update -qq
  $SUDO apt-get install -y lua5.4 luarocks curl jq unzip
  luarocks install luacheck
  luarocks install busted

  if ! command -v stylua >/dev/null 2>&1; then
    STYLUA_ZIP=/tmp/stylua.zip
    STYLUA_SHA256="f9c84c210712061cb03ab8354a34a5d4f5fcf1f369d2ce916bea3ab9f7addac8"
    curl -sL "https://github.com/JohnnyMorganz/StyLua/releases/download/v2.4.0/stylua-linux-x86_64.zip" \
      -o "$STYLUA_ZIP"
    echo "$STYLUA_SHA256  $STYLUA_ZIP" | sha256sum -c -
    if [ "$(id -u)" = "0" ]; then
      STYLUA_BIN=/usr/local/bin
    else
      STYLUA_BIN=$HOME/.local/bin
      mkdir -p "$STYLUA_BIN"
    fi
    unzip -o "$STYLUA_ZIP" -d "$STYLUA_BIN" stylua
    chmod +x "$STYLUA_BIN/stylua"
    rm "$STYLUA_ZIP"
    echo "stylua installed to $STYLUA_BIN — ensure it is in your PATH"
  fi

else
  echo "Unsupported OS: $OS"
  exit 1
fi
