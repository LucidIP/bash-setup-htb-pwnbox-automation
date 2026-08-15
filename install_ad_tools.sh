#!/bin/bash
set -e
# install_ad_tools.sh — Certipy, Impacket, NetExec, BloodyAD, via uv.
source "$(dirname "$0")/_common.sh"

ensure_uv
ensure_cargo  # NetExec's aardwolf dep needs Rust to build

uv tool install --force "git+https://github.com/ly4k/Certipy"
uv tool install --force "git+https://github.com/fortra/impacket"
uv tool install --force "git+https://github.com/Pennyw0rth/NetExec"
uv tool install --force "git+https://github.com/CravateRouge/bloodyAD" --with minikerberos
hash -r

echo "🔍 DEBUG: AD tools"; uv tool list
echo "✅ AD tools ready!"
