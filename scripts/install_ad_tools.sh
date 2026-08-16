#!/bin/bash
set -e
# install_ad_tools.sh — Certipy, Impacket, NetExec, BloodyAD, via uv. Certipy/Impacket/BloodyAD
# from PyPI (their own documented method, no per-tool git clone+build). NetExec stays on git+ --
# "netexec" isn't resolvable as a plain PyPI name via uv despite what its own docs imply.
source "$(dirname "$0")/_common.sh"

ensure_uv
ensure_cargo  # NetExec's aardwolf dep needs Rust if no prebuilt wheel for this arch

uv tool install --force certipy-ad
uv tool install --force impacket
uv tool install --force "git+https://github.com/Pennyw0rth/NetExec"
uv tool install --force bloodyAD --with minikerberos
hash -r

echo "🔍 DEBUG: AD tools"; uv tool list
echo "✅ AD tools ready!"
