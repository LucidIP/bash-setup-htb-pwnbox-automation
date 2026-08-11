#!/bin/bash
set -e
# install_shell_tools.sh — Penelope (shell handler) + rlwrap
# Run cleanup.sh first if you want a fresh slate.

echo "📦 Ensuring uv is installed..."
if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

echo "📥 Installing Penelope (shell handler)..."
uv tool install --force "git+https://github.com/brightio/penelope.git"

echo "📥 Installing rlwrap..."
sudo apt update -qq
sudo apt install -y rlwrap

hash -r

echo
echo "🔍 DEBUG: shell tools"
echo "====================="
rlwrap --version
command -v penelope >/dev/null 2>&1 && penelope --help | head -3 || echo "⚠️  penelope not on PATH yet — open a new shell"
echo "✅ Shell tools ready!"
