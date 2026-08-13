#!/bin/bash
set -e
# install_shell_tools.sh — Penelope (shell handler) + rlwrap
# Run cleanup.sh first if you want a fresh slate.
source "$(dirname "$0")/_common.sh"

echo "📦 Ensuring uv is installed..."
if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

echo "📥 Installing Penelope (shell handler)..."
# Installed from PyPI (stable release) rather than git — the git main branch
# carries a newer _ephemeral_root/real_home code path that can misresolve the
# home directory (seen crashing with: PermissionError: /root/.penelope).
uv tool install --force penelope-shell-handler

echo "📥 Installing rlwrap..."
apt_update
apt_install rlwrap

hash -r

echo
echo "🔍 DEBUG: shell tools"
echo "====================="
rlwrap --version
command -v penelope >/dev/null 2>&1 && penelope --help | head -3 || echo "⚠️  penelope not on PATH yet — open a new shell"
echo "✅ Shell tools ready!"
