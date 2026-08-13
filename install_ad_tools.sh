#!/bin/bash
set -e
# install_ad_tools.sh — Certipy, Impacket, NetExec, BloodyAD via uv
# Run cleanup.sh first if you want a fresh slate.
source "$(dirname "$0")/_common.sh"

echo "📦 Ensuring uv is installed..."
if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

echo "🦀 Ensuring Rust is installed (NetExec's aardwolf dep needs it to build)..."
if ! command -v cargo >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
export PATH="$HOME/.cargo/bin:$PATH"

echo "📥 Installing Certipy..."
uv tool install --force "git+https://github.com/ly4k/Certipy"

echo "📥 Installing Impacket..."
uv tool install --force "git+https://github.com/fortra/impacket"

echo "📥 Installing NetExec (nxc)..."
uv tool install --force "git+https://github.com/Pennyw0rth/NetExec"

echo "📥 Installing BloodyAD..."
uv tool install --force "git+https://github.com/CravateRouge/bloodyAD" --with minikerberos

hash -r

echo
echo "🔍 DEBUG: installed AD tools"
echo "============================"
uv tool list
echo "✅ AD tools ready!"
