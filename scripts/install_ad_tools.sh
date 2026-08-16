#!/bin/bash
set -e
# install_ad_tools.sh — Certipy, Impacket, NetExec, BloodyAD, via uv (PyPI releases, not git —
# same tools, no per-tool git clone + source build; NetExec's aardwolf dep may still need Rust).
source "$(dirname "$0")/_common.sh"

ensure_uv
ensure_cargo  # NetExec's aardwolf dep needs Rust if no prebuilt wheel for this arch

uv tool install --force certipy-ad
uv tool install --force impacket
uv tool install --force netexec
uv tool install --force bloodyAD --with minikerberos
hash -r

echo "🔍 DEBUG: AD tools"; uv tool list
echo "✅ AD tools ready!"
